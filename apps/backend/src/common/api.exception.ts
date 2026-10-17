import { HttpException, HttpStatus } from '@nestjs/common';
import { ErrorCode } from './error-codes';

/** The only exception type domain code should throw. The filter turns it into the error envelope. */
export class ApiException extends HttpException {
  constructor(
    readonly code: ErrorCode,
    message: string,
    status: number = HttpStatus.BAD_REQUEST,
    readonly details: Record<string, unknown> = {},
  ) {
    super({ code, message, details }, status);
  }

  static notFound(message = 'We could not find what you were looking for.', details = {}) {
    return new ApiException(ErrorCode.RESOURCE_NOT_FOUND, message, HttpStatus.NOT_FOUND, details);
  }
  static forbidden(message = 'You do not have permission to do that.', details = {}) {
    return new ApiException(ErrorCode.FORBIDDEN, message, HttpStatus.FORBIDDEN, details);
  }
  static unauthenticated(message = 'Please sign in to continue.') {
    return new ApiException(ErrorCode.AUTHENTICATION_REQUIRED, message, HttpStatus.UNAUTHORIZED);
  }
  static conflict(message: string, details = {}) {
    return new ApiException(ErrorCode.CONFLICT, message, HttpStatus.CONFLICT, details);
  }
  static invalidState(message: string, details = {}) {
    return new ApiException(ErrorCode.INVALID_STATE, message, HttpStatus.CONFLICT, details);
  }
  static validation(message: string, details = {}) {
    return new ApiException(ErrorCode.VALIDATION_ERROR, message, HttpStatus.BAD_REQUEST, details);
  }
  static external(message: string, details = {}) {
    return new ApiException(
      ErrorCode.EXTERNAL_SERVICE_ERROR,
      message,
      HttpStatus.SERVICE_UNAVAILABLE,
      details,
    );
  }
}
