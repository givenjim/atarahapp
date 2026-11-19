import { createParamDecorator, type ExecutionContext } from '@nestjs/common';
import type { Request } from 'express';

/**
 * The `Idempotency-Key` request header (Master Prompt 7.2). A param decorator rather than `@Headers()` so the header is
 * documented once, by `@ApiHeader`, with the right `required` flag; `@Headers()` would add a second, optional entry and
 * the generated client would get two parameters of the same name.
 */
export const IdempotencyKeyHeader = createParamDecorator(
  (_: unknown, ctx: ExecutionContext): string | undefined => {
    const v = ctx.switchToHttp().getRequest<Request>().headers['idempotency-key'];
    return typeof v === 'string' ? v.trim() : undefined;
  },
);
