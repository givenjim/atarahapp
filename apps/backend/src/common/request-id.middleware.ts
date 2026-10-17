import { randomUUID } from 'node:crypto';
import type { NextFunction, Request, Response } from 'express';

export const REQUEST_ID_HEADER = 'x-request-id';
const SAFE_ID = /^[A-Za-z0-9._-]{8,64}$/;

/** Accepts a well-formed inbound X-Request-Id (so mobile and web can correlate) or mints a UUID. */
export function resolveRequestId(inbound: unknown): string {
  return typeof inbound === 'string' && SAFE_ID.test(inbound) ? inbound : randomUUID();
}

export function requestIdMiddleware(req: Request, res: Response, next: NextFunction): void {
  const id = resolveRequestId(req.headers[REQUEST_ID_HEADER]);
  req.headers[REQUEST_ID_HEADER] = id;
  res.setHeader('X-Request-Id', id);
  next();
}
