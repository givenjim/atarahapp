import { Module } from '@nestjs/common';
import { ContentModule } from '../content/content.module';
import { CreativeModule } from '../creative/creative.module';
import { DiscoverModule } from '../discover/discover.module';
import { PeopleController } from './people.controller';
import { PeopleService } from './people.service';

/**
 * "People to meet" (`GET /creatives/suggestions`). A module of its own so AppModule can list it before
 * `CreativeModule`: the static path has to be registered ahead of `GET /creatives/:handle`. The imports are in the
 * same order AppModule always had (creative, content, discover), which keeps the order of the generated API
 * operations, and therefore the names of generated enums, stable.
 */
@Module({
  imports: [CreativeModule, ContentModule, DiscoverModule],
  controllers: [PeopleController],
  providers: [PeopleService],
})
export class PeopleModule {}
