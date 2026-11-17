import { type OpenAPIObject } from '@nestjs/swagger';
import { ErrorCode } from './error-codes';

type Operation = {
  parameters?: Array<{ in?: string }>;
  requestBody?: unknown;
  security?: unknown[];
  responses: Record<string, unknown>;
  [key: string]: unknown;
};

const METHODS = ['get', 'post', 'put', 'patch', 'delete'] as const;
const ERROR_SCHEMA = 'ErrorEnvelopeDto';

const example = (code: string, message: string, details: Record<string, unknown> = {}) => ({
  error: { code, message, details, requestId: 'c0a8012e-7b6d-4d2e-9a43-0f3c1d6a9b10' },
});

const response = (
  description: string,
  code: string,
  message: string,
  details?: Record<string, unknown>,
) => ({
  description,
  content: {
    'application/json': {
      schema: { $ref: `#/components/schemas/${ERROR_SCHEMA}` },
      example: example(code, message, details),
    },
  },
});

/**
 * Documents the error responses every operation can give (Master Prompt 7.2 / 7.9): the standard error envelope with an
 * example and the stable error codes, chosen from what the operation takes (a body or parameters can be invalid, a
 * path parameter can miss, a write can conflict, every authenticated operation can be refused). Added to the generated
 * document after Nest builds it, so controllers do not repeat the same decorators on every route. Each operation also
 * lists its possible codes in `x-error-codes`.
 */
export function documentErrors(doc: OpenAPIObject): OpenAPIObject {
  doc.components ??= {};
  doc.components.schemas ??= {};
  doc.components.schemas[ERROR_SCHEMA] ??= {
    type: 'object',
    required: ['error'],
    properties: {
      error: {
        type: 'object',
        required: ['code', 'message', 'details', 'requestId'],
        properties: {
          code: {
            type: 'string',
            description: 'Stable code, e.g. VALIDATION_ERROR, FORBIDDEN, RESOURCE_NOT_FOUND.',
          },
          message: { type: 'string', description: 'Human-readable, safe to show to the user.' },
          details: { type: 'object', additionalProperties: true },
          requestId: { type: 'string', description: 'Echo of X-Request-Id for support and logs.' },
        },
      },
    },
  };

  for (const methods of Object.values(doc.paths)) {
    for (const m of METHODS) {
      const op = (methods as Record<string, Operation | undefined>)[m];
      if (!op) continue;
      const hasInput = op.requestBody !== undefined || (op.parameters ?? []).length > 0;
      const hasPathParam = (op.parameters ?? []).some((p) => p.in === 'path');
      const authenticated = (op.security ?? []).length > 0;
      const codes: string[] = [];
      const add = (
        status: string,
        code: string,
        description: string,
        message: string,
        details?: Record<string, unknown>,
      ) => {
        if (op.responses[status] !== undefined) return;
        op.responses[status] = response(description, code, message, details);
        if (!codes.includes(code)) codes.push(code);
      };
      if (hasInput)
        add(
          '400',
          ErrorCode.VALIDATION_ERROR,
          'The request is not valid. `details.fields` lists each problem.',
          'Some of the information you sent is not valid.',
          { fields: [{ field: 'title', messages: ['title must be a string'] }] },
        );
      if (authenticated) {
        add(
          '401',
          ErrorCode.AUTHENTICATION_REQUIRED,
          'No valid session: sign in again.',
          'Please sign in to continue.',
        );
        add(
          '403',
          ErrorCode.FORBIDDEN,
          'The account or role may not do this (also PREMIUM_REQUIRED and VERIFICATION_REQUIRED).',
          'You do not have permission to do that.',
        );
      }
      if (hasPathParam)
        add(
          '404',
          ErrorCode.RESOURCE_NOT_FOUND,
          'It does not exist, or it is not yours or not visible to you.',
          'We could not find what you were looking for.',
        );
      if (m !== 'get')
        add(
          '409',
          ErrorCode.CONFLICT,
          'The change conflicts with the current state (CONFLICT or INVALID_STATE).',
          'That cannot be done in its current state.',
        );
      add(
        '429',
        ErrorCode.RATE_LIMITED,
        'Too many requests. Wait for `Retry-After` seconds.',
        'Too many requests. Please try again shortly.',
      );
      op['x-error-codes'] = codes;
    }
  }
  return doc;
}
