import { Module } from '@nestjs/common';
import { MediaModule } from '../media/media.module';
import { AdminPortfolioController } from './admin-portfolio.controller';
import { AdminPortfolioService } from './admin-portfolio.service';
import { AdminTaxonomyController } from './admin-taxonomy.controller';
import { AdminTaxonomyService } from './admin-taxonomy.service';
import { CreativeProfileService } from './creative-profile.service';
import {
  CreativeProfileController,
  LocationsController,
  TaxonomyController,
} from './creative.controller';
import { ConnectionsService } from './connections.service';
import { PortfolioController } from './portfolio.controller';
import { PortfolioService } from './portfolio.service';
import { ProfileController } from './profile.controller';
import { ProfileService } from './profile.service';
import { TaxonomyService } from './taxonomy.service';

/** Creative identity: taxonomies, locations, onboarding, the profile completion engine, the Passport and the portfolio. */
@Module({
  imports: [MediaModule],
  controllers: [
    TaxonomyController,
    LocationsController,
    CreativeProfileController,
    AdminTaxonomyController,
    ProfileController,
    PortfolioController,
    AdminPortfolioController,
  ],
  providers: [
    TaxonomyService,
    CreativeProfileService,
    AdminTaxonomyService,
    ProfileService,
    ConnectionsService,
    PortfolioService,
    AdminPortfolioService,
  ],
  exports: [CreativeProfileService, TaxonomyService, ProfileService, ConnectionsService],
})
export class CreativeModule {}
