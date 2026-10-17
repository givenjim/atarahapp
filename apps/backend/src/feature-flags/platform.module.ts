import { Global, Module } from '@nestjs/common';
import { FeatureFlagService } from './feature-flag.service';
import { PlatformSettingsService } from './platform-settings.service';

@Global()
@Module({
  providers: [FeatureFlagService, PlatformSettingsService],
  exports: [FeatureFlagService, PlatformSettingsService],
})
export class PlatformModule {}
