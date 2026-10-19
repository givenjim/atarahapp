import { Module } from '@nestjs/common';
import { ContentModule } from '../content/content.module';
import { CreativeModule } from '../creative/creative.module';
import { MediaModule } from '../media/media.module';
import { CreativesDiscoveryService } from './creatives-discovery.service';
import { DiscoverController } from './discover.controller';
import { HomeService } from './home.service';
import { SearchService } from './search.service';

/** Home, finding creatives, and search. */
@Module({
  imports: [MediaModule, CreativeModule, ContentModule],
  controllers: [DiscoverController],
  providers: [HomeService, CreativesDiscoveryService, SearchService],
})
export class DiscoverModule {}
