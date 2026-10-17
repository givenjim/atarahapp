import 'package:dio/dio.dart';

/// Everything that can go wrong talking to the API, as typed values the UI can branch on.
sealed class AppFailure implements Exception {
  const AppFailure();

  /// Safe to show to the member.
  String get message;
}

/// No connection, or the server did not answer in time.
class NetworkFailure extends AppFailure {
  const NetworkFailure({this.timedOut = false});

  final bool timedOut;

  @override
  String get message => timedOut
      ? 'That took too long. Check your connection and try again.'
      : "You're offline. Check your connection and try again.";
}

/// The API answered with the Atarah error envelope.
class ApiFailure extends AppFailure {
  const ApiFailure({
    required this.code,
    required this.message,
    required this.statusCode,
    this.details = const {},
    this.requestId,
  });

  /// Stable code, e.g. `INVALID_CREDENTIALS`, `VALIDATION_ERROR`, `PREMIUM_REQUIRED`, `RATE_LIMITED`.
  final String code;
  @override
  final String message;
  final int statusCode;
  final Map<String, Object?> details;
  final String? requestId;

  /// `details.reason`, e.g. `ACCOUNT_NOT_VERIFIED`, `SIGN_IN_LOCKED`, `TOKEN_REUSED`.
  String? get reason => details['reason'] as String?;

  /// First message for a form field from a `VALIDATION_ERROR`.
  String? fieldError(String field) {
    final fields = details['fields'];
    if (fields is! List) return null;
    for (final f in fields) {
      if (f is Map && f['field'] == field) {
        final messages = f['messages'];
        if (messages is List && messages.isNotEmpty) {
          return messages.first.toString();
        }
      }
    }
    return null;
  }

  bool get isAuthenticationFailure => code == 'AUTHENTICATION_REQUIRED';

  @override
  String toString() => 'ApiFailure($code, $statusCode, $message)';
}

class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure([this.cause]);

  final Object? cause;

  @override
  String get message => 'Something went wrong. Please try again.';
}

/// Converts any error thrown by Dio or the generated client into an [AppFailure].
AppFailure mapError(Object error) {
  if (error is AppFailure) return error;
  if (error is DioException) {
    final inner = error.error;
    if (inner is AppFailure) return inner;
    final body = error.response?.data;
    if (body is Map && body['error'] is Map) {
      final e = body['error'] as Map;
      return ApiFailure(
        code: (e['code'] ?? 'INTERNAL_ERROR').toString(),
        message: (e['message'] ?? 'Something went wrong. Please try again.')
            .toString(),
        statusCode: error.response?.statusCode ?? 0,
        details: Map<String, Object?>.from((e['details'] as Map?) ?? const {}),
        requestId: e['requestId']?.toString(),
      );
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const NetworkFailure(timedOut: true);
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return UnexpectedFailure(error);
    }
  }
  return UnexpectedFailure(error);
}
