import { Body, Controller, Get, HttpCode, Param, ParseUUIDPipe, Post, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiHeader, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { type AuthContext } from '../access/access.types';
import { CurrentAuth } from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { ApiException } from '../common/api.exception';
import { PageQueryDto } from '../common/pagination';
import { Paged } from '../common/response-envelope.interceptor';
import { IdempotencyKeyHeader } from './idempotency-key';
import { InitiatePaymentDto, PaymentDto, PaymentMethodsDto } from './payments.dto';
import { PaymentsService } from './payments.service';

const LABELS = {
  MPESA: { label: 'M-Pesa', description: 'Pay with your Safaricom line' },
  CARD: { label: 'Card', description: 'Visa or Mastercard' },
} as const;

/**
 * Member payments. The amount is never read from the request: a purpose handler registered by the selling module sets
 * it. A payment's status only ever comes from the server, which only trusts the provider.
 */
@ApiTags('Payments')
@ApiBearerAuth('access-token')
@Controller('payments')
export class PaymentsController {
  constructor(private readonly payments: PaymentsService) {}

  /** The methods the app may show. Card is absent until the `card-payments` flag is on and a provider is connected. */
  @ApiEnvelope(PaymentMethodsDto)
  @Get('methods')
  async methods(): Promise<PaymentMethodsDto> {
    const available = await this.payments.availableMethods();
    return { methods: available.map((method) => ({ method, ...LABELS[method] })) };
  }

  @ApiEnvelope(PaymentDto, { isArray: true })
  @Get()
  async list(@CurrentAuth() auth: AuthContext, @Query() q: PageQueryDto) {
    const { items, total } = await this.payments.listForPayer(auth.userId, q.page, q.limit);
    return new Paged(items, { page: q.page, limit: q.limit, total });
  }

  /**
   * Starts a payment (an M-Pesa prompt for MPESA). `Idempotency-Key` is required: repeating the request with the same
   * key returns the same payment and never a second prompt.
   */
  @ApiHeader({
    name: 'Idempotency-Key',
    required: true,
    description: 'A fresh UUID per attempt (8 to 128 characters).',
  })
  @ApiEnvelope(PaymentDto, { status: 201 })
  @Throttle({ default: { limit: 6, ttl: 60_000 } })
  @Post()
  initiate(
    @CurrentAuth() auth: AuthContext,
    @Body() dto: InitiatePaymentDto,
    @IdempotencyKeyHeader() idempotencyKey?: string,
  ) {
    if (!idempotencyKey || idempotencyKey.length < 8 || idempotencyKey.length > 128) {
      throw ApiException.validation('Send an Idempotency-Key header (8 to 128 characters).', {
        header: 'Idempotency-Key',
      });
    }
    return this.payments.initiateForPurpose({
      userId: auth.userId,
      purpose: dto.purpose,
      referenceId: dto.referenceId ?? null,
      method: dto.method,
      phone: dto.phone,
      idempotencyKey,
      sandboxAmountMinor: dto.sandboxAmountMinor,
    });
  }

  /** Status for the waiting screen. Poll every few seconds (`pollAfterSeconds`); the server keeps the provider honest. */
  @ApiEnvelope(PaymentDto)
  @Throttle({ default: { limit: 60, ttl: 60_000 } })
  @HttpCode(200)
  @Get(':id')
  get(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.payments.getForPayer(id, auth.userId);
  }
}
