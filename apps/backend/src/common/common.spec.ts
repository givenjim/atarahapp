import { HttpException, HttpStatus } from '@nestjs/common';
import { ThrottlerException } from '@nestjs/throttler';
import { firstValueFrom, of } from 'rxjs';
import { ApiException } from './api.exception';
import { ErrorCode } from './error-codes';
import { AllExceptionsFilter } from './http-exception.filter';
import { cursorPage, decodeCursor, encodeCursor, pageMeta, toSkipTake } from './pagination';
import { resolveRequestId } from './request-id.middleware';
import { Paged, ResponseEnvelopeInterceptor } from './response-envelope.interceptor';
import { resolveSort, type SortKey } from './sorting';

function runFilter(exception: unknown, headers: Record<string, string> = {}) {
  const res = {
    statusCode: 0,
    body: undefined as unknown,
    headers: {} as Record<string, string>,
    status(code: number) {
      this.statusCode = code;
      return this;
    },
    json(b: unknown) {
      this.body = b;
      return this;
    },
    setHeader(k: string, v: string) {
      this.headers[k] = v;
    },
  };
  const host = {
    switchToHttp: () => ({
      getResponse: () => res,
      getRequest: () => ({ headers }),
    }),
  };
  new AllExceptionsFilter().catch(exception, host as never);
  return res;
}

describe('AllExceptionsFilter', () => {
  it('maps ApiException to the envelope with its own code, message and details', () => {
    const res = runFilter(ApiException.conflict('Handle taken', { handle: 'nia' }), {
      'x-request-id': 'req-12345678',
    });
    expect(res.statusCode).toBe(409);
    expect(res.body).toEqual({
      error: {
        code: 'CONFLICT',
        message: 'Handle taken',
        details: { handle: 'nia' },
        requestId: 'req-12345678',
      },
    });
  });

  it.each([
    [HttpStatus.UNAUTHORIZED, ErrorCode.AUTHENTICATION_REQUIRED],
    [HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN],
    [HttpStatus.NOT_FOUND, ErrorCode.RESOURCE_NOT_FOUND],
    [HttpStatus.SERVICE_UNAVAILABLE, ErrorCode.EXTERNAL_SERVICE_ERROR],
  ])(
    'maps framework HttpException %i to %s without leaking the framework message',
    (status, code) => {
      const res = runFilter(new HttpException('Cannot GET /secret/internal/path', status));
      const err = (res.body as { error: { code: string; message: string } }).error;
      expect(res.statusCode).toBe(status);
      expect(err.code).toBe(code);
      expect(err.message).not.toContain('secret');
    },
  );

  it('maps throttling to RATE_LIMITED with a Retry-After header', () => {
    const res = runFilter(new ThrottlerException());
    expect(res.statusCode).toBe(429);
    expect((res.body as { error: { code: string } }).error.code).toBe('RATE_LIMITED');
    expect(res.headers['Retry-After']).toBe('60');
  });

  it('hides unexpected errors behind INTERNAL_ERROR (no stack, SQL or message)', () => {
    const res = runFilter(
      new Error('duplicate key value violates unique constraint "users_email_key"'),
    );
    const err = (res.body as { error: { code: string; message: string } }).error;
    expect(res.statusCode).toBe(500);
    expect(err.code).toBe('INTERNAL_ERROR');
    expect(JSON.stringify(res.body)).not.toMatch(/duplicate key|users_email_key|at Object/);
  });
});

describe('ResponseEnvelopeInterceptor', () => {
  const interceptor = new ResponseEnvelopeInterceptor<unknown>();
  const wrap = (value: unknown) =>
    firstValueFrom(interceptor.intercept({} as never, { handle: () => of(value) }));

  it('wraps plain values as { data }', async () => {
    expect(await wrap({ a: 1 })).toEqual({ data: { a: 1 } });
  });
  it('turns undefined into data: null', async () => {
    expect(await wrap(undefined)).toEqual({ data: null });
  });
  it('passes Paged data and meta through', async () => {
    expect(await wrap(new Paged([1, 2], { page: 1, limit: 20, total: 2 }))).toEqual({
      data: [1, 2],
      meta: { page: 1, limit: 20, total: 2 },
    });
  });
});

describe('pagination', () => {
  it('computes skip/take and meta', () => {
    expect(toSkipTake({ page: 3, limit: 20 })).toEqual({ skip: 40, take: 20 });
    expect(pageMeta({ page: 3, limit: 20 }, 55)).toEqual({ page: 3, limit: 20, total: 55 });
  });

  it('round-trips cursors and rejects garbage with VALIDATION_ERROR', () => {
    const c = encodeCursor({ id: 'abc', t: 5 });
    expect(decodeCursor(c)).toEqual({ id: 'abc', t: 5 });
    expect(() => decodeCursor('not-a-cursor')).toThrow(ApiException);
    expect(() => decodeCursor(Buffer.from('[1,2]').toString('base64url'))).toThrow(ApiException);
  });

  it('cursorPage trims the look-ahead row and only emits nextCursor when more rows exist', () => {
    const more = cursorPage([{ id: 1 }, { id: 2 }, { id: 3 }], 2, (l) => ({ id: l.id }));
    expect(more.items).toHaveLength(2);
    expect(decodeCursor(more.meta.nextCursor!)).toEqual({ id: 2 });

    const last = cursorPage([{ id: 1 }, { id: 2 }], 2, (l) => ({ id: l.id }));
    expect(last.items).toHaveLength(2);
    expect(last.meta.nextCursor).toBeNull();
  });
});

describe('resolveSort', () => {
  const allowed: Partial<Record<SortKey, Record<string, 'asc' | 'desc'>>> = {
    recent: { createdAt: 'desc' },
    deadline: { deadline: 'asc' },
  };

  it('uses the fallback when no key is supplied', () => {
    expect(resolveSort(undefined, allowed, 'recent').key).toBe('recent');
  });
  it('returns the mapped order for a whitelisted key', () => {
    expect(resolveSort('deadline', allowed, 'recent').order).toEqual({ deadline: 'asc' });
  });
  it('rejects keys outside the whitelist, including prototype keys', () => {
    expect(() => resolveSort('price', allowed, 'recent')).toThrow(ApiException);
    expect(() => resolveSort('constructor', allowed, 'recent')).toThrow(ApiException);
  });
});

describe('resolveRequestId', () => {
  it('keeps a well-formed inbound id', () => {
    expect(resolveRequestId('abc-123_XYZ.456')).toBe('abc-123_XYZ.456');
  });
  it('replaces missing, short, long or unsafe ids with a UUID', () => {
    const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-/;
    for (const bad of [undefined, '', 'short', 'x'.repeat(65), 'has space and <script>']) {
      expect(resolveRequestId(bad)).toMatch(uuid);
    }
  });
});
