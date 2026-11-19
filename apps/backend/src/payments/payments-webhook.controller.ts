import { Body, Controller, HttpCode, Logger, Param, Post, Req } from '@nestjs/common';
import { ApiExcludeController } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { type Request } from 'express';
import { Public } from '../access/decorators';
import { ApiException } from '../common/api.exception';
import { PaymentProviderRegistry } from './payment-provider.registry';
import { PaymentsService } from './payments.service';

/**
 * Provider callbacks under /api/v1/webhooks/payments. Public (a provider has no member token), kept out of the OpenAPI
 * contract, and authenticated by the provider adapter. Daraja callbacks are unsigned, so the route carries an
 * unguessable path token (and optionally an IP allow-list). A wrong token answers 404 as if the route did not exist.
 *
 * The callback only starts a check: the payment becomes SUCCEEDED when the provider confirms it through a status query.
 */
@ApiExcludeController()
@Controller('webhooks/payments')
export class PaymentsWebhookController {
  private readonly log = new Logger(PaymentsWebhookController.name);

  constructor(
    private readonly payments: PaymentsService,
    private readonly providers: PaymentProviderRegistry,
  ) {}

  @Public()
  @Throttle({ default: { limit: 300, ttl: 60_000 } })
  @HttpCode(200)
  @Post('mpesa/:token')
  async mpesa(
    @Param('token') token: string,
    @Body() body: unknown,
    @Req() req: Request & { rawBody?: Buffer },
  ) {
    const provider = this.providers.forKey('MPESA_DARAJA');
    if (!provider || !provider.verifyWebhook({ token, ip: req.ip, headers: req.headers, body })) {
      throw ApiException.notFound();
    }
    const raw = req.rawBody?.toString('utf8') ?? JSON.stringify(body);
    try {
      const outcome = await this.payments.handleCallback(provider, body, raw);
      this.log.log(`M-Pesa callback ${outcome}`);
    } catch (e) {
      // Daraja retries on an error, and the fallback job asks the provider anyway: log and acknowledge.
      this.log.error(`M-Pesa callback failed: ${e instanceof Error ? e.message : String(e)}`);
    }
    return { ResultCode: 0, ResultDesc: 'Accepted' };
  }
}
