import { Global, Module } from '@nestjs/common';
import { DevOutbox, LogSmsProvider, SmtpEmailProvider } from './dev-providers';
import { EMAIL_PROVIDER, SMS_PROVIDER } from './messaging';

@Global()
@Module({
  providers: [
    DevOutbox,
    SmtpEmailProvider,
    LogSmsProvider,
    { provide: EMAIL_PROVIDER, useExisting: SmtpEmailProvider },
    { provide: SMS_PROVIDER, useExisting: LogSmsProvider },
  ],
  exports: [DevOutbox, EMAIL_PROVIDER, SMS_PROVIDER],
})
export class MessagingModule {}
