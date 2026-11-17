import { Module } from '@nestjs/common';
import { OpportunitiesModule } from '../opportunities/opportunities.module';
import { SavedModule } from '../saved/saved.module';
import { ActivityController } from './activity.controller';
import { ActivityService } from './activity.service';

/** The Activity hub (P1-M11). */
@Module({
  imports: [OpportunitiesModule, SavedModule],
  controllers: [ActivityController],
  providers: [ActivityService],
})
export class ActivityModule {}
