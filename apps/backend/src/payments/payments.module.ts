import { Module } from '@nestjs/common';
import { AdminPaymentsController } from './admin-payments.controller';
import { AdminPaymentsService } from './admin-payments.service';
import { PaymentsCoreModule } from './payments-core.module';
import { PaymentsController } from './payments.controller';
import { PaymentsWebhookController } from './payments-webhook.controller';

/** Payments (P2-M1): member endpoints, the provider webhook and the finance console. The logic is in `PaymentsCoreModule`. */
@Module({
  imports: [PaymentsCoreModule],
  controllers: [PaymentsController, PaymentsWebhookController, AdminPaymentsController],
  providers: [AdminPaymentsService],
  exports: [PaymentsCoreModule],
})
export class PaymentsModule {}
