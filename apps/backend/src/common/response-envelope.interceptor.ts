import {
  type CallHandler,
  type ExecutionContext,
  Injectable,
  type NestInterceptor,
  StreamableFile,
} from '@nestjs/common';
import { map, type Observable } from 'rxjs';

/** Return this from a controller to supply `meta` (pagination, cursors) alongside `data`. */
export class Paged<T> {
  constructor(
    readonly data: T,
    readonly meta: Record<string, unknown>,
  ) {}
}

export interface SuccessEnvelope<T> {
  data: T;
  meta?: Record<string, unknown>;
}

/** Wraps every successful response as `{ data, meta? }` (Master Prompt §7.2). */
@Injectable()
export class ResponseEnvelopeInterceptor<T> implements NestInterceptor<T, SuccessEnvelope<T>> {
  intercept(_ctx: ExecutionContext, next: CallHandler<T>): Observable<SuccessEnvelope<T>> {
    return next.handle().pipe(
      map((value) => {
        if (value instanceof StreamableFile) return value as unknown as SuccessEnvelope<T>;
        if (value instanceof Paged) return { data: value.data as T, meta: value.meta };
        return { data: (value ?? null) as T };
      }),
    );
  }
}
