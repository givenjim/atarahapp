import { Body, Controller, Get, HttpCode, Param, ParseUUIDPipe, Post, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiHeader, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { type AuthContext } from '../access/access.types';
import {
  ClientIp,
  CurrentAuth,
  RequestIdParam,
  RequiresPermission,
  RequiresRecentAuth,
} from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { Paged } from '../common/response-envelope.interceptor';
import { AdminPaymentsService } from './admin-payments.service';
import { IdempotencyKeyHeader } from './idempotency-key';
import {
  AdminPaymentDetailDto,
  AdminPaymentDto,
  AdminPaymentsQueryDto,
  CompleteRefundDto,
  RefundPaymentDto,
} from './payments.dto';

/**
 * Staff view of payments under /api/v1/admin. Reading needs `payment.view`; re-querying and refunding need
 * `payment.manage` (a separate permission that platform admins do not hold), a fresh authenticator check, and are
 * audited. The responses carry metadata only: never card data, never the raw provider payloads.
 */
@ApiTags('Admin payments')
@ApiBearerAuth('access-token')
@Controller('admin/payments')
export class AdminPaymentsController {
  constructor(private readonly admin: AdminPaymentsService) {}

  @RequiresPermission('admin.access', 'payment.view')
  @ApiEnvelope(AdminPaymentDto, { isArray: true })
  @Get()
  async list(@Query() q: AdminPaymentsQueryDto) {
    const { items, meta } = await this.admin.list(q);
    return new Paged(items, meta);
  }

  @RequiresPermission('admin.access', 'payment.view')
  @ApiEnvelope(AdminPaymentDetailDto)
  @Get(':id')
  detail(@Param('id', ParseUUIDPipe) id: string) {
    return this.admin.detail(id);
  }

  @RequiresPermission('admin.access', 'payment.manage')
  @RequiresRecentAuth()
  @Throttle({ default: { limit: 30, ttl: 60_000 } })
  @HttpCode(200)
  @ApiEnvelope(AdminPaymentDetailDto)
  @Post(':id/requery')
  requery(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.requery(id, { userId: auth.userId, ip, requestId });
  }

  @RequiresPermission('admin.access', 'payment.manage')
  @RequiresRecentAuth()
  @Throttle({ default: { limit: 20, ttl: 60_000 } })
  @ApiHeader({
    name: 'Idempotency-Key',
    required: false,
    description: 'Repeating a refund request with the same key creates one refund.',
  })
  @ApiEnvelope(AdminPaymentDetailDto, { status: 201 })
  @Post(':id/refunds')
  refund(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: RefundPaymentDto,
    @IdempotencyKeyHeader() idempotencyKey?: string,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.refund(
      id,
      { amountMinor: dto.amountMinor, reason: dto.reason.trim(), idempotencyKey },
      { userId: auth.userId, ip, requestId },
    );
  }

  /** Finance confirms a refund it paid out by hand (the provider has no automatic route yet). */
  @RequiresPermission('admin.access', 'payment.manage')
  @RequiresRecentAuth()
  @Throttle({ default: { limit: 20, ttl: 60_000 } })
  @HttpCode(200)
  @ApiEnvelope(AdminPaymentDetailDto)
  @Post(':id/refunds/:refundId/complete')
  completeRefund(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Param('refundId', ParseUUIDPipe) refundId: string,
    @Body() dto: CompleteRefundDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.completeRefund(id, refundId, dto.providerReference?.trim() || undefined, {
      userId: auth.userId,
      ip,
      requestId,
    });
  }

  /** Abandons a manual refund that will not be paid, releasing its amount. */
  @RequiresPermission('admin.access', 'payment.manage')
  @RequiresRecentAuth()
  @Throttle({ default: { limit: 20, ttl: 60_000 } })
  @HttpCode(200)
  @ApiEnvelope(AdminPaymentDetailDto)
  @Post(':id/refunds/:refundId/cancel')
  cancelRefund(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Param('refundId', ParseUUIDPipe) refundId: string,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.cancelRefund(id, refundId, { userId: auth.userId, ip, requestId });
  }
}
