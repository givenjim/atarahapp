import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';
import { PageQueryDto } from '../common/pagination';

export const PAYMENT_METHODS = ['MPESA', 'CARD'] as const;
export const PAYMENT_PURPOSES = ['MEMBERSHIP', 'MENTORSHIP', 'VERIFICATION', 'OTHER'] as const;
export const PAYMENT_STATUSES = [
  'INITIATED',
  'PENDING',
  'SUCCEEDED',
  'FAILED',
  'CANCELLED',
  'REFUNDED',
  'PARTIALLY_REFUNDED',
] as const;

export type PaymentMethodValue = (typeof PAYMENT_METHODS)[number];
export type PaymentPurposeValue = (typeof PAYMENT_PURPOSES)[number];
export type PaymentStatusValue = (typeof PAYMENT_STATUSES)[number];

// ---- member ----------------------------------------------------------------------------------------

export class InitiatePaymentDto {
  @ApiProperty({ enum: PAYMENT_PURPOSES, example: 'MEMBERSHIP' })
  @IsIn(PAYMENT_PURPOSES)
  purpose!: PaymentPurposeValue;

  @ApiPropertyOptional({
    format: 'uuid',
    description:
      'What is being paid for (a booking, a membership order). The server decides the amount.',
  })
  @IsOptional()
  @IsUUID()
  referenceId?: string;

  @ApiProperty({ enum: PAYMENT_METHODS, example: 'MPESA' })
  @IsIn(PAYMENT_METHODS)
  method!: PaymentMethodValue;

  @ApiPropertyOptional({
    example: '+254712345678',
    description:
      'The Safaricom number that gets the M-Pesa prompt. Required for MPESA. Never stored in full.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  phone?: string;

  @ApiPropertyOptional({
    description:
      'Only the OTHER (sandbox check) purpose reads this: minor units, KES 1 to 100. Ignored otherwise.',
    example: 100,
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(10_000)
  sandboxAmountMinor?: number;
}

export class PaymentActionDto {
  @ApiProperty({ enum: ['STK_PROMPT', 'REDIRECT'] }) type!: 'STK_PROMPT' | 'REDIRECT';
  @ApiPropertyOptional() message?: string;
  @ApiPropertyOptional() url?: string;
}

export class PaymentDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ enum: PAYMENT_STATUSES }) status!: PaymentStatusValue;
  @ApiProperty({ enum: PAYMENT_PURPOSES }) purpose!: PaymentPurposeValue;
  @ApiProperty({ enum: PAYMENT_METHODS }) method!: PaymentMethodValue;
  @ApiProperty({ description: 'Minor units (KES cents).', example: 120000 }) amountMinor!: number;
  @ApiProperty({ example: 'KES' }) currency!: string;
  @ApiProperty({ type: String, nullable: true }) description!: string | null;
  @ApiProperty({ type: String, nullable: true }) referenceType!: string | null;
  @ApiProperty({ type: String, nullable: true, format: 'uuid' }) referenceId!: string | null;
  @ApiProperty({ type: String, nullable: true, description: 'M-Pesa receipt once paid.' })
  receiptNumber!: string | null;
  @ApiProperty({
    type: String,
    nullable: true,
    description: 'Stable code such as CANCELLED_BY_USER or TIMEOUT.',
  })
  failureCode!: string | null;
  @ApiProperty({
    type: String,
    nullable: true,
    description: 'What to tell the member and what to do next.',
  })
  failureReason!: string | null;
  @ApiProperty({ description: 'Minor units already refunded.' }) refundedMinor!: number;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: string;
  @ApiProperty({ nullable: true, type: String, format: 'date-time' }) completedAt!: string | null;
  @ApiProperty({ nullable: true, type: String, format: 'date-time' }) expiresAt!: string | null;
  @ApiProperty({
    description:
      'Still open after its time limit: the app offers "Try again" and the server keeps checking.',
  })
  timedOut!: boolean;
  @ApiProperty({ description: 'Seconds the app should wait before asking again.' })
  pollAfterSeconds!: number;
  @ApiPropertyOptional({
    type: () => PaymentActionDto,
    description: 'Present on the response that starts a payment.',
  })
  action?: PaymentActionDto;
}

export class PaymentMethodOptionDto {
  @ApiProperty({ enum: PAYMENT_METHODS }) method!: PaymentMethodValue;
  @ApiProperty({ example: 'M-Pesa' }) label!: string;
  @ApiProperty({ example: 'Pay with your Safaricom line' }) description!: string;
}

export class PaymentMethodsDto {
  @ApiProperty({ type: () => [PaymentMethodOptionDto] }) methods!: PaymentMethodOptionDto[];
}

// ---- admin -----------------------------------------------------------------------------------------

export class AdminPaymentsQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ enum: PAYMENT_STATUSES })
  @IsOptional()
  @IsIn(PAYMENT_STATUSES)
  status?: PaymentStatusValue;
  @ApiPropertyOptional({ enum: PAYMENT_METHODS })
  @IsOptional()
  @IsIn(PAYMENT_METHODS)
  paymentMethod?: PaymentMethodValue;
  @ApiPropertyOptional({ enum: PAYMENT_PURPOSES })
  @IsOptional()
  @IsIn(PAYMENT_PURPOSES)
  purpose?: PaymentPurposeValue;
  @ApiPropertyOptional({
    description: 'Payment id, M-Pesa receipt or provider reference (exact), or the payer name.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  q?: string;
}

export class AdminPayerDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() fullName!: string;
}

export class AdminPaymentDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: string;
  @ApiProperty({ enum: PAYMENT_STATUSES }) status!: PaymentStatusValue;
  @ApiProperty({ enum: PAYMENT_PURPOSES }) purpose!: PaymentPurposeValue;
  @ApiProperty({ enum: PAYMENT_METHODS }) method!: PaymentMethodValue;
  @ApiProperty({ enum: ['MPESA_DARAJA', 'CARD'] }) provider!: string;
  @ApiProperty() amountMinor!: number;
  @ApiProperty() refundedMinor!: number;
  @ApiProperty() currency!: string;
  @ApiProperty({ type: String, nullable: true }) receiptNumber!: string | null;
  @ApiProperty({ type: String, nullable: true }) failureCode!: string | null;
  @ApiProperty({ type: String, nullable: true }) referenceType!: string | null;
  @ApiProperty({ type: String, nullable: true, format: 'uuid' }) referenceId!: string | null;
  @ApiProperty({ type: () => AdminPayerDto }) payer!: AdminPayerDto;
}

export class AdminPaymentEventDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({
    enum: ['INITIATED', 'CALLBACK', 'STATUS_QUERY', 'STATUS_CHANGE', 'REFUND', 'REVIEW'],
  })
  kind!: string;
  @ApiProperty({ enum: ['API', 'PROVIDER_CALLBACK', 'STATUS_QUERY', 'JOB', 'ADMIN'] })
  source!: string;
  @ApiProperty({ nullable: true, enum: PAYMENT_STATUSES }) fromStatus!: PaymentStatusValue | null;
  @ApiProperty({ nullable: true, enum: PAYMENT_STATUSES }) toStatus!: PaymentStatusValue | null;
  @ApiProperty() summary!: string;
  @ApiProperty({ type: String, nullable: true, format: 'uuid' }) actorId!: string | null;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: string;
}

export class AdminRefundDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() amountMinor!: number;
  @ApiProperty() reason!: string;
  @ApiProperty({ enum: ['PENDING', 'SUCCEEDED', 'FAILED'] }) status!: string;
  @ApiProperty({ enum: ['AUTOMATIC', 'MANUAL'] }) mode!: string;
  @ApiProperty({ type: String, nullable: true }) providerReference!: string | null;
  @ApiProperty({ type: String, nullable: true }) failureReason!: string | null;
  @ApiProperty({ type: String, nullable: true, format: 'uuid' }) requestedById!: string | null;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: string;
  @ApiProperty({ nullable: true, type: String, format: 'date-time' }) completedAt!: string | null;
}

export class AdminLedgerEntryDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ enum: ['PAYMENT', 'REFUND'] }) type!: string;
  @ApiProperty() grossMinor!: number;
  @ApiProperty() platformFeeMinor!: number;
  @ApiProperty() netMinor!: number;
  @ApiProperty({ type: String, nullable: true, format: 'uuid' }) payeeId!: string | null;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: string;
}

export class AdminPaymentDetailDto extends AdminPaymentDto {
  @ApiProperty({ type: String, nullable: true }) providerReference!: string | null;
  @ApiProperty({ type: String, nullable: true }) merchantReference!: string | null;
  @ApiProperty({
    type: String,
    nullable: true,
    description: 'Last four digits of the paying number. The full number is never stored.',
  })
  msisdnLast4!: string | null;
  @ApiProperty({ type: String, nullable: true }) description!: string | null;
  @ApiProperty({ type: String, nullable: true }) failureReason!: string | null;
  @ApiProperty({ type: String, nullable: true, format: 'uuid' }) payeeId!: string | null;
  @ApiProperty() platformFeeMinor!: number;
  @ApiProperty() queryAttempts!: number;
  @ApiProperty({ nullable: true, type: String, format: 'date-time' }) lastQueriedAt!: string | null;
  @ApiProperty({ nullable: true, type: String, format: 'date-time' }) expiresAt!: string | null;
  @ApiProperty({ nullable: true, type: String, format: 'date-time' }) completedAt!: string | null;
  @ApiProperty({
    description: 'Minor units that can still be refunded (excludes refunds in progress).',
  })
  refundableMinor!: number;
  @ApiProperty({ type: () => [AdminPaymentEventDto] }) events!: AdminPaymentEventDto[];
  @ApiProperty({ type: () => [AdminRefundDto] }) refunds!: AdminRefundDto[];
  @ApiProperty({ type: () => [AdminLedgerEntryDto] }) ledger!: AdminLedgerEntryDto[];
}

export class RefundPaymentDto {
  @ApiPropertyOptional({
    description: 'Minor units. Omit to refund everything still refundable.',
    example: 50000,
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  amountMinor?: number;

  @ApiProperty({ description: 'Why (kept in the audit log).', minLength: 5, maxLength: 500 })
  @IsString()
  @MinLength(5)
  @MaxLength(500)
  reason!: string;
}

export class CompleteRefundDto {
  @ApiPropertyOptional({
    description: 'Reference of the manual payout (M-Pesa receipt or bank reference).',
  })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  providerReference?: string;
}
