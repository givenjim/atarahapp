import { Module } from '@nestjs/common';
import { ContentModule } from '../content/content.module';
import { MediaModule } from '../media/media.module';
import { OpportunitiesModule } from '../opportunities/opportunities.module';
import { SavedController } from './saved.controller';
import { SavedService } from './saved.service';

/** The Saved screen and the save buttons of every kind (P1-M11). */
@Module({
  imports: [ContentModule, MediaModule, OpportunitiesModule],
  controllers: [SavedController],
  providers: [SavedService],
  exports: [SavedService],
})
export class SavedModule {}
