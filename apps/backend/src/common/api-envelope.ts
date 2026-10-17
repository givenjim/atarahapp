import { applyDecorators, type Type } from '@nestjs/common';
import { ApiExtraModels, ApiProperty, ApiResponse, getSchemaPath } from '@nestjs/swagger';

/** Documents a success response in the standard `{ data, meta? }` envelope, so generated clients are typed. */
export function ApiEnvelope<T extends Type<unknown>>(
  model: T,
  options: { status?: number; isArray?: boolean; description?: string } = {},
) {
  const data = options.isArray
    ? { type: 'array', items: { $ref: getSchemaPath(model) } }
    : { $ref: getSchemaPath(model) };
  return applyDecorators(
    ApiExtraModels(model),
    ApiResponse({
      status: options.status ?? 200,
      description: options.description ?? '',
      schema: {
        type: 'object',
        required: ['data'],
        properties: {
          data,
          meta: { type: 'object', additionalProperties: true },
        },
      },
    }),
  );
}

/** Body of every error response (Master Prompt section 7.2). */
export class ErrorBodyDto {
  @ApiProperty({
    description:
      'Stable code, e.g. VALIDATION_ERROR, INVALID_CREDENTIALS, PREMIUM_REQUIRED, RATE_LIMITED.',
  })
  code!: string;

  @ApiProperty({ description: 'Human-readable, safe to show to the user.' })
  message!: string;

  @ApiProperty({ type: 'object', additionalProperties: true })
  details!: Record<string, unknown>;

  @ApiProperty({ description: 'Echo of X-Request-Id for support and logs.' })
  requestId!: string;
}

export class ErrorEnvelopeDto {
  @ApiProperty({ type: ErrorBodyDto })
  error!: ErrorBodyDto;
}
