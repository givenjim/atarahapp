import 'dart:async';

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'failures.dart';
import 'request_id.dart';

/// Paths that never carry a bearer token (public content). A stale token must not be able to fail them.
const _publicPaths = <String>['/api/v1/config/public', '/api/v1/legal/'];

bool _isPublic(String path) => _publicPaths.any(path.startsWith);

BaseOptions _baseOptions(AppConfig config) => BaseOptions(
  baseUrl: config.apiBaseUrl,
  connectTimeout: const Duration(seconds: 12),
  receiveTimeout: const Duration(seconds: 20),
  sendTimeout: const Duration(seconds: 20),
  contentType: Headers.jsonContentType,
  responseType: ResponseType.json,
  headers: {'Accept': 'application/json'},
);

/// A Dio with no auth handling: for requests that must not carry the API token (uploads to signed URLs).
Dio buildPlainDio(AppConfig config) {
  final dio = Dio(_baseOptions(config));
  dio.interceptors.add(_RequestIdInterceptor());
  return dio;
}

/// The app's Dio: request ids, the Supabase bearer token, one refresh-and-retry on 401, retry for safe GETs.
Dio buildApiDio({
  required AppConfig config,
  required AccessTokenSource tokens,
  required void Function() onSessionExpired,
  void Function()? onTwoStepRequired,
  Duration retryDelay = const Duration(milliseconds: 300),
}) {
  final dio = Dio(_baseOptions(config));
  dio.interceptors.addAll([
    _RequestIdInterceptor(),
    _OmitNullFieldsInterceptor(),
    AuthInterceptor(
      dio: dio,
      tokens: tokens,
      onSessionExpired: onSessionExpired,
    ),
    if (onTwoStepRequired != null) _TwoStepInterceptor(onTwoStepRequired),
    RetryInterceptor(dio: dio, delay: retryDelay),
  ]);
  return dio;
}

/// A `403` whose reason is `TWO_STEP_REQUIRED` means this device must complete the second step of sign-in before the
/// API accepts requests (Master Prompt P1-M11). The request still fails; the app is told so it can show the challenge.
class _TwoStepInterceptor extends Interceptor {
  _TwoStepInterceptor(this.onRequired);

  final void Function() onRequired;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final body = err.response?.data;
    if (err.response?.statusCode == 403 &&
        body is Map &&
        body['error'] is Map &&
        (body['error'] as Map)['details'] is Map &&
        ((body['error'] as Map)['details'] as Map)['reason'] ==
            'TWO_STEP_REQUIRED') {
      onRequired();
    }
    handler.next(err);
  }
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

/// The current Supabase access token, and a way to get a fresh one. The Supabase SDK refreshes tokens on its
/// own schedule; [refresh] is only used when the API has just rejected a token.
abstract interface class AccessTokenSource {
  String? get current;

  /// A fresh token, or null when the session is over. Throws when the provider cannot be reached.
  Future<String?> refresh();
}

/// Adds the bearer token and, on a 401, refreshes once (shared across requests) and retries the call.
/// When the session cannot be refreshed the member is signed out.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.dio,
    required this.tokens,
    required this.onSessionExpired,
  });

  final Dio dio;
  final AccessTokenSource tokens;
  final void Function() onSessionExpired;

  static const _retriedKey = 'atarah.auth_retried';
  static const _tokenKey = 'atarah.auth_token_used';

  Future<String?>? _inFlight;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_isPublic(options.path)) {
      final token = tokens.current;
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        options.extra[_tokenKey] = token;
      }
    }
    handler.next(options);
  }

  /// Many requests can hit 401 together when the token expires; they share one refresh. If the SDK already
  /// holds a newer token than the one the request used, no refresh is needed.
  Future<String?> _fresh(String used) {
    final current = tokens.current;
    if (current != null && current != used) return Future.value(current);
    return _inFlight ??= tokens.refresh().whenComplete(() => _inFlight = null);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final req = err.requestOptions;
    final canRefresh =
        err.response?.statusCode == 401 &&
        !_isPublic(req.path) &&
        req.extra[_retriedKey] != true &&
        req.extra[_tokenKey] != null &&
        mapError(err) is ApiFailure;

    if (!canRefresh) return handler.next(err);

    final String? token;
    try {
      token = await _fresh(req.extra[_tokenKey] as String);
    } on Object {
      // Offline: keep the session, report the original failure.
      return handler.next(err);
    }
    if (token == null) {
      onSessionExpired();
      return handler.next(err);
    }

    try {
      final retry = req.copyWith(
        headers: {...req.headers, 'Authorization': 'Bearer $token'},
      )..extra = {...req.extra, _retriedKey: true, _tokenKey: token};
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
