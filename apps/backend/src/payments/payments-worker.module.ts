import { Module } from '@nestjs/common';
import { PaymentsCoreModule } from './payments-core.module';
import { PaymentsProcessor } from './payments.processor';

/** Worker side of payments: the fallback job on the `payments` queue. */
@Module({ imports: [PaymentsCoreModule], providers: [PaymentsProcessor] })
export class PaymentsWorkerModule {}
