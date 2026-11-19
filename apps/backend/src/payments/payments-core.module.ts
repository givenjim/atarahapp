import { Module } from '@nestjs/common';
import { PaymentCrypto } from './payment-crypto';
import { PaymentNotificationsListener } from './payment-notifications.listener';
import { PaymentProviderRegistry } from './payment-provider.registry';
import { PaymentPurposeRegistry, SandboxPurposeHandler } from './payment-purposes';
import { PaymentsService } from './payments.service';
import { CardProvider } from './providers/card.provider';
import { MpesaDarajaProvider } from './providers/mpesa-daraja.provider';
import { PAYMENT_PROVIDERS } from './providers/payment-provider';

/**
 * Everything payments needs without HTTP: providers, the state machine service, purpose registry and the notification
 * listener. The API (`PaymentsModule`) and the worker (`PaymentsWorkerModule`) both import it, so a payment settled by
 * a callback in the API or by the fallback job in the worker raises the same events with the same listeners.
 */
@Module({
  providers: [
    PaymentCrypto,
    MpesaDarajaProvider,
    CardProvider,
    {
      provide: PAYMENT_PROVIDERS,
      inject: [MpesaDarajaProvider, CardProvider],
      useFactory: (mpesa: MpesaDarajaProvider, card: CardProvider) => [mpesa, card],
    },
    PaymentProviderRegistry,
    PaymentPurposeRegistry,
    SandboxPurposeHandler,
    PaymentsService,
    PaymentNotificationsListener,
  ],
  exports: [PaymentsService, PaymentPurposeRegistry, PaymentProviderRegistry, PaymentCrypto],
})
export class PaymentsCoreModule {}
