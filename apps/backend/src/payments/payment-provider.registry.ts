import { Inject, Injectable } from '@nestjs/common';
import { type PaymentMethod, type PaymentProviderKey } from '@prisma/client';
import { PAYMENT_PROVIDERS, type PaymentProvider } from './providers/payment-provider';

/** Finds the adapter for a payment method or a provider key. Tests replace the `PAYMENT_PROVIDERS` token with a fake. */
@Injectable()
export class PaymentProviderRegistry {
  constructor(@Inject(PAYMENT_PROVIDERS) private readonly providers: PaymentProvider[]) {}

  forMethod(method: PaymentMethod): PaymentProvider | undefined {
    return this.providers.find((p) => p.method === method);
  }

  forKey(key: PaymentProviderKey): PaymentProvider | undefined {
    return this.providers.find((p) => p.key === key);
  }

  all(): PaymentProvider[] {
    return [...this.providers];
  }
}
