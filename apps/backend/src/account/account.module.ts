import { Module } from '@nestjs/common';
import { CreativeModule } from '../creative/creative.module';
import { IdentityModule } from '../identity/identity.module';
import { AccountController } from './account.controller';
import { AccountService } from './account.service';
import { DeletionService } from './deletion.service';
import { ExportService } from './export.service';
import {
  MembershipViewService,
  PrivacyService,
  TwoStepService,
} from './privacy-twostep-membership.service';

/** Settings: account, privacy, security, export, deletion and the membership view (P1-M11). */
@Module({
  imports: [IdentityModule, CreativeModule],
  controllers: [AccountController],
  providers: [
    AccountService,
    PrivacyService,
    TwoStepService,
    ExportService,
    DeletionService,
    MembershipViewService,
  ],
  exports: [AccountService, ExportService, DeletionService],
})
export class AccountModule {}
