import { type ValidationError, ValidationPipe } from '@nestjs/common';
import { ApiException } from './api.exception';

interface FieldIssue {
  field: string;
  messages: string[];
}

function flatten(errors: ValidationError[], parent = ''): FieldIssue[] {
  return errors.flatMap((e) => {
    const field = parent ? `${parent}.${e.property}` : e.property;
    const own = e.constraints ? [{ field, messages: Object.values(e.constraints) }] : [];
    return [...own, ...flatten(e.children ?? [], field)];
  });
}

/** Whitelist + forbid unknown properties; failures become VALIDATION_ERROR with per-field details. */
export function createValidationPipe(): ValidationPipe {
  return new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
    transformOptions: { enableImplicitConversion: false },
    exceptionFactory: (errors) =>
      ApiException.validation('Some of the information you sent is not valid.', {
        fields: flatten(errors),
      }),
  });
}
