import { Module } from '@nestjs/common';
import { MediaModule } from '../media/media.module';
import { AdminTaxonomyController } from './admin-taxonomy.controller';
import { AdminTaxonomyService } from './admin-taxonomy.service';
import { CreativeProfileService } from './creative-profile.service';
import {
  CreativeProfileController,
  LocationsController,
  TaxonomyController,
} from './creative.controller';
import { TaxonomyService } from './taxonomy.service';

/** Creative identity: taxonomies, locations, onboarding, the profile completion engine and the Passport. */
@Module({
  imports: [MediaModule],
  controllers: [
    TaxonomyController,
    LocationsController,
    CreativeProfileController,
    AdminTaxonomyController,
  ],
  providers: [TaxonomyService, CreativeProfileService, AdminTaxonomyService],
  exports: [CreativeProfileService, TaxonomyService],
})
export class CreativeModule {}
