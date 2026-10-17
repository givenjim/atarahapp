import { Injectable, Logger } from '@nestjs/common';
import { createTransport, type Transporter } from 'nodemailer';
import { AppConfigService } from '../config/app-config.service';
import {
  type EmailMessage,
  type EmailProvider,
  type SmsMessage,
  type SmsProvider,
} from './messaging';

/**
 * Development outbox. Tests and local tooling read delivered messages here. It exists only in dev/test
 * (the SMS "log" provider is rejected by the env schema in staging and production).
 */
export class DevOutbox {
  readonly emails: EmailMessage[] = [];
  readonly sms: SmsMessage[] = [];
  /** Push notifications the development push sink "delivered". */
  readonly push: Array<{
    tokens: string[];
    title: string;
    body: string;
    data: Record<string, string>;
  }> = [];

  clear(): void {
    this.emails.length = 0;
    this.sms.length = 0;
    this.push.length = 0;
  }

  lastCodeTo(destination: string): string | undefined {
    const all = [...this.emails.map((m) => ({ to: m.to, text: m.text })), ...this.sms];
    const hit = [...all].reverse().find((m) => m.to === destination);
    return hit?.text.match(/\b(\d{6})\b/)?.[1];
  }
}

/** Email over SMTP. Locally this is Mailpit (http://localhost:58025); production uses a real provider. */
@Injectable()
export class SmtpEmailProvider implements EmailProvider {
  private readonly transport: Transporter;

  constructor(
    private readonly config: AppConfigService,
    private readonly outbox: DevOutbox,
  ) {
    this.transport = createTransport({
      host: config.smtp.host,
      port: config.smtp.port,
      secure: false,
      tls: { rejectUnauthorized: config.isDeployed },
    });
  }

  async send(message: EmailMessage): Promise<void> {
    if (!this.config.isDeployed) this.outbox.emails.push(message);
    // Tests assert on the outbox; they never need an SMTP server.
    if (this.config.environment === 'test') return;
    await this.transport.sendMail({
      from: this.config.smtp.from,
      to: message.to,
      subject: message.subject,
      text: message.text,
      html: message.html,
    });
  }
}

/**
 * Development SMS sink: records the message in the outbox and prints it to the console so a developer can
 * read the code. This is the only place a one-time code is ever printed, and only outside deployed envs.
 */
@Injectable()
export class LogSmsProvider implements SmsProvider {
  private readonly logger = new Logger('DevSms');

  constructor(
    private readonly config: AppConfigService,
    private readonly outbox: DevOutbox,
  ) {}

  async send(message: SmsMessage): Promise<void> {
    if (this.config.isDeployed)
      throw new Error('The SMS log sink must not be used in staging or production.');
    this.outbox.sms.push(message);
    if (this.config.environment === 'dev')
      this.logger.log(`[DEV SMS] to ${message.to}: ${message.text}`);
  }
}
