import { Module } from '@nestjs/common';
import { AdminModule } from '../admin/admin.module';
import { MediaModule } from '../media/media.module';
import { AdminOpportunitiesController } from './admin-opportunities.controller';
import { AdminOpportunitiesService } from './admin-opportunities.service';
import { OpportunitiesController } from './opportunities.controller';
import { OpportunitiesService } from './opportunities.service';
import { OpportunityNotificationsListener } from './opportunity-notifications.listener';
import { OpportunityViewsService } from './opportunity-views.service';
import { ProviderOpportunitiesController } from './provider-opportunities.controller';
import { RuleEngineService } from './rule-engine.service';

/** Opportunities (P1-M9): discovery, the profile-gap check, saving and tracking, and staff and provider operations. */
@Module({
  imports: [AdminModule, MediaModule],
  controllers: [
    OpportunitiesController,
    AdminOpportunitiesController,
    ProviderOpportunitiesController,
  ],
  providers: [
    OpportunityViewsService,
    RuleEngineService,
    OpportunitiesService,
    AdminOpportunitiesService,
    OpportunityNotificationsListener,
  ],
  exports: [OpportunitiesService, OpportunityViewsService, RuleEngineService],
})
export class OpportunitiesModule {}
