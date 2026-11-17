import { Module } from '@nestjs/common';
import { AdminHelpController, HelpController } from './help.controller';
import { AdminHelpService, HelpService } from './help.service';

/** Help centre, FAQ and the legal documents (P1-M11). */
@Module({
  controllers: [HelpController, AdminHelpController],
  providers: [HelpService, AdminHelpService],
  exports: [HelpService],
})
export class HelpModule {}
