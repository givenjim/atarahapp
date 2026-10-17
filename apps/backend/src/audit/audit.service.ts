import { Injectable } from '@nestjs/common';
import { type AuditActorType, Prisma } from '@prisma/client';
import { PrismaService, type TxClient } from '../prisma/prisma.service';

export interface AuditEntry {
  actorType: AuditActorType;
  actorId?: string | null;
  /** Dotted verb, e.g. `user.suspend`, `membership.grant`, `payment.refund`. */
  action: string;
  entityType: string;
  entityId?: string | null;
  before?: unknown;
  after?: unknown;
  ip?: string | null;
  requestId?: string | null;
}

/** Keys whose values must never be written to the audit log, at any depth. */
const SENSITIVE_KEYS =
  /password|secret|token|authorization|cookie|idnumber|nationalid|^(code|otp|pin)$/i;

export function scrub(value: unknown, depth = 0): unknown {
  if (value === null || typeof value !== 'object') return value;
  if (depth > 6) return '[truncated]';
  if (Array.isArray(value)) return value.map((v) => scrub(v, depth + 1));
  if (value instanceof Date) return value.toISOString();
  return Object.fromEntries(
    Object.entries(value as Record<string, unknown>).map(([k, v]) => [
      k,
      SENSITIVE_KEYS.test(k) ? '[redacted]' : scrub(v, depth + 1),
    ]),
  );
}

function toJson(value: unknown): Prisma.InputJsonValue | typeof Prisma.JsonNull | undefined {
  if (value === undefined) return undefined;
  if (value === null) return Prisma.JsonNull;
  return scrub(value) as Prisma.InputJsonValue;
}

/**
 * Append-only audit trail (Master Prompt §7.4). Pass the active transaction client when the audited
 * change happens in a transaction so the record commits or rolls back with it.
 */
@Injectable()
export class AuditService {
  constructor(private readonly prisma: PrismaService) {}

  async record(entry: AuditEntry, tx?: TxClient): Promise<{ id: string }> {
    const db = tx ?? this.prisma;
    const row = await db.auditLog.create({
      data: {
        actorType: entry.actorType,
        actorId: entry.actorId ?? null,
        action: entry.action,
        entityType: entry.entityType,
        entityId: entry.entityId ?? null,
        before: toJson(entry.before),
        after: toJson(entry.after),
        ip: entry.ip ?? null,
        requestId: entry.requestId ?? null,
      },
      select: { id: true },
    });
    return row;
  }
}
