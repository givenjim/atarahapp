import { createHmac, timingSafeEqual } from 'node:crypto';
import { Inject, Injectable } from '@nestjs/common';
import { ApiException } from '../common/api.exception';
import { AppConfigService } from '../config/app-config.service';
import { SMS_PROVIDER, type SmsProvider } from '../messaging/messaging';

const TOLERANCE_SECONDS = 5 * 60;

export interface SendSmsPayload {
  user?: { phone?: string };
  sms?: { otp?: string };
}

/**
 * Supabase Auth's "Send SMS" hook. Supabase signs the request with the Standard Webhooks scheme; the signature
 * is verified before anything is sent, then the code goes out through the SMS-provider adapter (a log sink in
 * development, the Kenyan SMS provider in production, section 12 #19).
 */
@Injectable()
export class SmsHookService {
  constructor(
    private readonly config: AppConfigService,
    @Inject(SMS_PROVIDER) private readonly sms: SmsProvider,
  ) {}

  verifySignature(
    rawBody: Buffer | undefined,
    headers: { id?: string; timestamp?: string; signature?: string },
    now = Date.now(),
  ): void {
    const { id, timestamp, signature } = headers;
    if (!rawBody || !id || !timestamp || !signature) throw ApiException.unauthenticated();
    const ts = Number(timestamp);
    if (!Number.isFinite(ts) || Math.abs(now / 1000 - ts) > TOLERANCE_SECONDS)
      throw ApiException.unauthenticated();

    const secret = Buffer.from(
      this.config.supabase.smsHookSecret.replace(/^v1,whsec_/, ''),
      'base64',
    );
    const expected = createHmac('sha256', secret)
      .update(`${id}.${timestamp}.`)
      .update(rawBody)
      .digest();
    const valid = signature.split(' ').some((part) => {
      const [version, value] = part.split(',');
      if (version !== 'v1' || !value) return false;
      const given = Buffer.from(value, 'base64');
      return given.length === expected.length && timingSafeEqual(given, expected);
    });
    if (!valid) throw ApiException.unauthenticated();
  }

  async send(payload: SendSmsPayload): Promise<void> {
    const phone = payload.user?.phone;
    const otp = payload.sms?.otp;
    if (!phone || !otp) throw ApiException.validation('Missing phone or code.');
    await this.sms.send({
      to: phone.startsWith('+') ? phone : `+${phone}`,
      text: `Your Atarah code is ${otp}. It expires in 10 minutes. Never share it.`,
    });
  }
}
