import {
  type ArgumentsHost,
  Catch,
  type ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { ThrottlerException } from '@nestjs/throttler';
import type { Request, Response } from 'express';
import { ApiException } from './api.exception';
import { ErrorCode } from './error-codes';
import { REQUEST_ID_HEADER } from './request-id.middleware';

export interface ErrorEnvelope {
  error: {
    code: ErrorCode;
    message: string;
    details: Record<string, unknown>;
    requestId: string;
  };
}

const STATUS_TO_CODE: Record<number, ErrorCode> = {
  [HttpStatus.BAD_REQUEST]: ErrorCode.VALIDATION_ERROR,
  [HttpStatus.UNAUTHORIZED]: ErrorCode.AUTHENTICATION_REQUIRED,
  [HttpStatus.FORBIDDEN]: ErrorCode.FORBIDDEN,
  [HttpStatus.NOT_FOUND]: ErrorCode.RESOURCE_NOT_FOUND,
  [HttpStatus.CONFLICT]: ErrorCode.CONFLICT,
  [HttpStatus.UNPROCESSABLE_ENTITY]: ErrorCode.VALIDATION_ERROR,
  [HttpStatus.TOO_MANY_REQUESTS]: ErrorCode.RATE_LIMITED,
  [HttpStatus.BAD_GATEWAY]: ErrorCode.EXTERNAL_SERVICE_ERROR,
  [HttpStatus.SERVICE_UNAVAILABLE]: ErrorCode.EXTERNAL_SERVICE_ERROR,
};

const FRIENDLY: Partial<Record<ErrorCode, string>> = {
  [ErrorCode.AUTHENTICATION_REQUIRED]: 'Please sign in to continue.',
  [ErrorCode.FORBIDDEN]: 'You do not have permission to do that.',
  [ErrorCode.RESOURCE_NOT_FOUND]: 'We could not find what you were looking for.',
  [ErrorCode.RATE_LIMITED]: 'You are doing that too often. Please wait a moment and try again.',
  [ErrorCode.VALIDATION_ERROR]: 'Some of the information you sent is not valid.',
  [ErrorCode.CONFLICT]: 'That conflicts with the current state. Please refresh and try again.',
  [ErrorCode.EXTERNAL_SERVICE_ERROR]:
    'A service Atarah depends on is not responding. Please try again shortly.',
  [ErrorCode.INTERNAL_ERROR]: 'Something went wrong on our side. Please try again.',
};

/**
 * Turns every thrown error into the Atarah error envelope. Stack traces, SQL and library
 * messages for unexpected errors never leave the server; they are logged against the requestId.
 */
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger('ExceptionFilter');

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const res = ctx.getResponse<Response>();
    const req = ctx.getRequest<Request>();
    const requestId = String(req.headers?.[REQUEST_ID_HEADER] ?? 'unknown');

    const { status, code, message, details } = this.normalise(exception);

    if (!(exception instanceof HttpException)) {
      this.logger.error({ requestId, err: exception }, 'Unhandled error');
    } else if (status >= 500) {
      this.logger.warn({ requestId, status, code }, 'Request failed with a server error');
    }

    const body: ErrorEnvelope = { error: { code, message, details, requestId } };
    if (status === HttpStatus.TOO_MANY_REQUESTS) res.setHeader('Retry-After', '60');
    res.status(status).json(body);
  }

  private normalise(exception: unknown): {
    status: number;
    code: ErrorCode;
    message: string;
    details: Record<string, unknown>;
  } {
    if (exception instanceof ApiException) {
      return {
        status: exception.getStatus(),
        code: exception.code,
        message: exception.message,
        details: exception.details,
      };
    }
    if (exception instanceof ThrottlerException) {
      return {
        status: HttpStatus.TOO_MANY_REQUESTS,
        code: ErrorCode.RATE_LIMITED,
        message: FRIENDLY[ErrorCode.RATE_LIMITED]!,
        details: {},
      };
    }
    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const code =
        STATUS_TO_CODE[status] ?? (status >= 500 ? ErrorCode.INTERNAL_ERROR : ErrorCode.CONFLICT);
      // Framework messages (e.g. "Cannot GET /x") are replaced with friendly text; no internals leak.
      const message = FRIENDLY[code] ?? 'Request failed.';
      return { status, code, message, details: {} };
    }
    return {
      status: HttpStatus.INTERNAL_SERVER_ERROR,
      code: ErrorCode.INTERNAL_ERROR,
      message: FRIENDLY[ErrorCode.INTERNAL_ERROR]!,
      details: {},
    };
  }
}
