/**
 * Provider abstractions for outbound messages (Master Prompt §5.1). Production adapters are owner
 * decisions (§12 #2 email, #3 SMS); only development implementations exist today.
 */
export interface EmailMessage {
  to: string;
  subject: string;
  text: string;
  html?: string;
}

export interface SmsMessage {
  /** E.164 */
  to: string;
  text: string;
}

export interface EmailProvider {
  send(message: EmailMessage): Promise<void>;
}

export interface SmsProvider {
  send(message: SmsMessage): Promise<void>;
}

export const EMAIL_PROVIDER = Symbol('EMAIL_PROVIDER');
export const SMS_PROVIDER = Symbol('SMS_PROVIDER');
