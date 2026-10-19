import 'dart:async';

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/token_store.dart';
import 'failures.dart';
import 'request_id.dart';
import 'session_refresher.dart';

/// Paths that must never carry (or refresh) a bearer token.
const _publicPaths = <String>[
  '/api/v1/auth/register',
  '/api/v1/auth/verify',
  '/api/v1/auth/resend-code',
  '/api/v1/auth/login',
  '/api/v1/auth/refresh',
  '/api/v1/auth/password/',
  '/api/v1/auth/google',
];

bool _isPublic(String path) => _publicPaths.any(path.startsWith);

/// `details.reason` values that mean "the session is over" rather than "try refreshing".
const _terminalReasons = {'TOKEN_REUSED', 'SESSION_IDLE'};

BaseOptions _baseOptions(AppConfig config) => BaseOptions(
  baseUrl: config.apiBaseUrl,
  connectTimeout: const Duration(seconds: 12),
  receiveTimeout: const Duration(seconds: 20),
  sendTimeout: const Duration(seconds: 20),
  contentType: Headers.jsonContentType,
  responseType: ResponseType.json,
  headers: {'Accept': 'application/json'},
);

/// A Dio with no auth handling, used for the refresh call itself (avoids refresh loops).
Dio buildPlainDio(AppConfig config) {
  final dio = Dio(_baseOptions(config));
  dio.interceptors.add(_RequestIdInterceptor());
  return dio;
}

/// The app's Dio: request ids, bearer tokens, single-flight refresh on 401, retry for safe GETs.
Dio buildApiDio({
  required AppConfig config,
  required TokenStore store,
  required SessionRefresher refresher,
  required void Function() onSessionExpired,
  Duration retryDelay = const Duration(milliseconds: 300),
}) {
  final dio = Dio(_baseOptions(config));
  dio.interceptors.addAll([
    _RequestIdInterceptor(),
    _OmitNullFieldsInterceptor(),
    AuthInterceptor(
      dio: dio,
      store: store,
      refresher: refresher,
      onSessionExpired: onSessionExpired,
    ),
    RetryInterceptor(dio: dio, delay: retryDelay),
  ]);
  return dio;
}

/// The generated models write every unset field as `null`. For a partial update that would read as "set it to
/// nothing", so unset top-level fields are left out of the body: the server then leaves them alone.
class _OmitNullFieldsInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final data = options.data;
    if (data is Map<String, dynamic> && data.containsValue(null)) {
      options.data = {
        for (final e in data.entries)
          if (e.value != null) e.key: e.value,
      };
    }
    handler.next(options);
  }
}

class _RequestIdInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent('X-Request-Id', newRequestId);
    handler.next(options);
  }
}

/// Adds the bearer token and, on a 401, refreshes once (shared across requests) and retries the call.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.dio,
    required this.store,
    required this.refresher,
    required this.onSessionExpired,
  });

  final Dio dio;
  final TokenStore store;
  final SessionRefresher refresher;
  final void Function() onSessionExpired;

  static const _retriedKey = 'atarah.auth_retried';
  static const _tokenKey = 'atarah.auth_token_used';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublic(options.path)) {
      final tokens = await store.read();
      if (tokens != null) {
        options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
        options.extra[_tokenKey] = tokens.accessToken;
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final req = err.requestOptions;
    final failure = mapError(err);
    final canRefresh =
        err.response?.statusCode == 401 &&
        !_isPublic(req.path) &&
        req.extra[_retriedKey] != true &&
        req.extra[_tokenKey] != null &&
        failure is ApiFailure;

    if (!canRefresh) return handler.next(err);

    final reason = failure.reason;
    if (_terminalReasons.contains(reason)) {
      onSessionExpired();
      return handler.next(err);
    }

    final tokens = await refresher.refresh(req.extra[_tokenKey] as String?);
    if (tokens == null) {
      onSessionExpired();
      return handler.next(err);
    }

    try {
      final retry =
          req.copyWith(
              headers: {
                ...req.headers,
                'Authorization': 'Bearer ${tokens.accessToken}',
              },
            )
            ..extra = {
              ...req.extra,
              _retriedKey: true,
              _tokenKey: tokens.accessToken,
            };
      handler.resolve(await dio.fetch<dynamic>(retry));
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}

/// Retries idempotent GETs a couple of times on connection problems. Writes are never retried automatically.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    required this.delay,
    this.maxRetries = 2,
  });

  final Dio dio;
  final Duration delay;
  final int maxRetries;
  static const _attemptKey = 'atarah.retry_attempt';

  bool _retryable(DioException e) =>
      e.requestOptions.method.toUpperCase() == 'GET' &&
      (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = (err.requestOptions.extra[_attemptKey] as int?) ?? 0;
    if (!_retryable(err) || attempt >= maxRetries) return handler.next(err);
    await Future<void>.delayed(delay * (attempt + 1));
    try {
      final opts = err.requestOptions.copyWith()
        ..extra = {...err.requestOptions.extra, _attemptKey: attempt + 1};
      handler.resolve(await dio.fetch<dynamic>(opts));
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
