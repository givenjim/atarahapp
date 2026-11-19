import { Injectable } from '@nestjs/common';
import { type Payment, Prisma, type Refund } from '@prisma/client';
import { AuditService } from '../audit/audit.service';
import { ApiException } from '../common/api.exception';
import { toSkipTake } from '../common/pagination';
import { PrismaService } from '../prisma/prisma.service';
import type {
  AdminLedgerEntryDto,
  AdminPaymentDetailDto,
  AdminPaymentDto,
  AdminPaymentsQueryDto,
  AdminRefundDto,
} from './payments.dto';
import { type Actor, PaymentsService } from './payments.service';

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

type WithPayer = Payment & { payer: { id: string; fullName: string } };

const refundDto = (r: Refund): AdminRefundDto => ({
  id: r.id,
  amountMinor: Number(r.amountMinor),
  reason: r.reason,
  status: r.status,
  mode: r.mode,
  providerReference: r.providerReference,
  failureReason: r.failureReason,
  requestedById: r.requestedById,
  createdAt: r.createdAt.toISOString(),
  completedAt: r.completedAt?.toISOString() ?? null,
});

/**
 * Console view of payments: metadata only. Raw provider payloads (stored encrypted) and the paying number are never
 * returned; the number is only ever stored as its last four digits. Card data is never held at all.
 */
@Injectable()
export class AdminPaymentsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly payments: PaymentsService,
    private readonly audit: AuditService,
  ) {}

  async list(q: AdminPaymentsQueryDto) {
    const search = q.q?.trim();
    const where: Prisma.PaymentWhereInput = {
      ...(q.status ? { status: q.status } : {}),
      ...(q.paymentMethod ? { method: q.paymentMethod } : {}),
      ...(q.purpose ? { purpose: q.purpose } : {}),
      ...(search
        ? {
            OR: [
              ...(UUID.test(search) ? [{ id: search }, { payerId: search }] : []),
              { receiptNumber: search },
              { providerReference: search },
              { payer: { fullName: { contains: search, mode: 'insensitive' as const } } },
            ],
          }
        : {}),
    };
    const [total, rows] = await this.prisma.$transaction([
      this.prisma.payment.count({ where }),
      this.prisma.payment.findMany({
        where,
        include: { payer: { select: { id: true, fullName: true } } },
        orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
        ...toSkipTake(q),
      }),
    ]);
    return { items: rows.map((r) => this.toDto(r)), meta: { page: q.page, limit: q.limit, total } };
  }

  async detail(id: string): Promise<AdminPaymentDetailDto> {
    const p = await this.prisma.payment.findUnique({
      where: { id },
      include: {
        payer: { select: { id: true, fullName: true } },
        events: { orderBy: { createdAt: 'asc' } },
        refunds: { orderBy: { createdAt: 'asc' } },
        transactions: { orderBy: { createdAt: 'asc' } },
      },
    });
    if (!p) throw ApiException.notFound('We could not find that payment.');
    const refundable = ['SUCCEEDED', 'PARTIALLY_REFUNDED'].includes(p.status)
      ? await this.payments.refundable(this.prisma, p)
      : 0;
    const ledger: AdminLedgerEntryDto[] = p.transactions.map((t) => ({
      id: t.id,
      type: t.type,
      grossMinor: Number(t.grossMinor),
      platformFeeMinor: Number(t.platformFeeMinor),
      netMinor: Number(t.netMinor),
      payeeId: t.payeeId,
      createdAt: t.createdAt.toISOString(),
    }));
    return {
      ...this.toDto(p),
      providerReference: p.providerReference,
      merchantReference: p.merchantReference,
      msisdnLast4: p.msisdnLast4,
      description: p.description,
      failureReason: p.failureReason,
      payeeId: p.payeeId,
      platformFeeMinor: Number(p.platformFeeMinor),
      queryAttempts: p.queryAttempts,
      lastQueriedAt: p.lastQueriedAt?.toISOString() ?? null,
      expiresAt: p.expiresAt?.toISOString() ?? null,
      completedAt: p.completedAt?.toISOString() ?? null,
      refundableMinor: refundable,
      events: p.events.map((e) => ({
        id: e.id,
        kind: e.kind,
        source: e.source,
        fromStatus: e.fromStatus,
        toStatus: e.toStatus,
        summary: e.summary,
        actorId: e.actorId,
        createdAt: e.createdAt.toISOString(),
      })),
      refunds: p.refunds.map(refundDto),
      ledger,
    };
  }

  /** Asks the provider again. The audit entry names who asked; any status change is audited by the payments core. */
  async requery(id: string, actor: Actor): Promise<AdminPaymentDetailDto> {
    const before = await this.prisma.payment.findUnique({
      where: { id },
      select: { status: true },
    });
    const after = await this.payments.requery(id, actor);
    await this.audit.record({
      actorType: 'ADMIN',
      actorId: actor.userId ?? null,
      action: 'payment.requery',
      entityType: 'payment',
      entityId: id,
      before: { status: before?.status },
      after: { status: after.status },
      ip: actor.ip ?? null,
      requestId: actor.requestId ?? null,
    });
    return this.detail(id);
  }

  async refund(
    id: string,
    input: { amountMinor?: number; reason: string; idempotencyKey?: string },
    actor: Actor,
  ): Promise<AdminPaymentDetailDto> {
    await this.payments.refund({ paymentId: id, ...input, actor });
    return this.detail(id);
  }

  async completeRefund(
    id: string,
    refundId: string,
    providerReference: string | undefined,
    actor: Actor,
  ): Promise<AdminPaymentDetailDto> {
    await this.payments.confirmManualRefund(id, refundId, providerReference ?? null, actor);
    return this.detail(id);
  }

  async cancelRefund(id: string, refundId: string, actor: Actor): Promise<AdminPaymentDetailDto> {
    await this.payments.cancelManualRefund(id, refundId, actor);
    return this.detail(id);
  }

  private toDto(p: WithPayer): AdminPaymentDto {
    return {
      id: p.id,
      createdAt: p.createdAt.toISOString(),
      status: p.status,
      purpose: p.purpose,
      method: p.method,
      provider: p.provider,
      amountMinor: Number(p.amountMinor),
      refundedMinor: Number(p.refundedMinor),
      currency: p.currency,
      receiptNumber: p.receiptNumber,
      failureCode: p.failureCode,
      referenceType: p.referenceType,
      referenceId: p.referenceId,
      payer: p.payer,
    };
  }
}
