import { Body, Controller, Delete, Get, HttpCode, Param, Patch, Post, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { type AuthContext } from '../access/access.types';
import { CurrentAuth, RequiresPermission } from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { CreativeProfileService } from './creative-profile.service';
import {
  CountiesQueryDto,
  CountryDto,
  CountyDto,
  CountyMatchDto,
  CountyMatchQueryDto,
  DisciplineDto,
  HandleAvailabilityDto,
  OnboardingCompleteDto,
  OnboardingStateDto,
  SaveOnboardingStepDto,
  SetAvatarDto,
  SkillsQueryDto,
  SuggestionReceiptDto,
  SuggestSpecialisationDto,
  TaxonomyItemDto,
} from './creative.dto';
import { TaxonomyService } from './taxonomy.service';

@ApiTags('Taxonomy')
@ApiBearerAuth('access-token')
@Controller('taxonomy')
export class TaxonomyController {
  constructor(private readonly taxonomy: TaxonomyService) {}

  @ApiEnvelope(DisciplineDto, { isArray: true })
  @Get('disciplines')
  disciplines() {
    return this.taxonomy.disciplines();
  }

  @ApiEnvelope(TaxonomyItemDto, { isArray: true })
  @Get('skills')
  skills(@Query() q: SkillsQueryDto) {
    return this.taxonomy.skills(q.discipline);
  }

  @ApiEnvelope(TaxonomyItemDto, { isArray: true })
  @Get('interests')
  interests() {
    return this.taxonomy.interests();
  }

  @ApiEnvelope(TaxonomyItemDto, { isArray: true })
  @Get('development-areas')
  developmentAreas() {
    return this.taxonomy.developmentAreas();
  }

  @RequiresPermission('profile.edit')
  @Throttle({ default: { limit: 10, ttl: 3_600_000 } })
  @HttpCode(201)
  @ApiEnvelope(SuggestionReceiptDto, { status: 201 })
  @Post('specialisations/suggestions')
  suggest(@CurrentAuth() auth: AuthContext, @Body() dto: SuggestSpecialisationDto) {
    return this.taxonomy.suggest(auth.userId, dto.disciplineId, dto.name);
  }
}

@ApiTags('Locations')
@ApiBearerAuth('access-token')
@Controller('locations')
export class LocationsController {
  constructor(private readonly taxonomy: TaxonomyService) {}

  @ApiEnvelope(CountryDto, { isArray: true })
  @Get('countries')
  countries() {
    return this.taxonomy.countries();
  }

  @ApiEnvelope(CountyDto, { isArray: true })
  @Get('counties')
  counties(@Query() q: CountiesQueryDto) {
    return this.taxonomy.counties(q.country);
  }

  @ApiEnvelope(CountyMatchDto)
  @Throttle({ default: { limit: 30, ttl: 60_000 } })
  @Get('counties/match')
  match(@Query() q: CountyMatchQueryDto) {
    return this.taxonomy.matchCounty(q.q, q.country);
  }
}

@ApiTags('Onboarding')
@ApiBearerAuth('access-token')
@Controller()
export class CreativeProfileController {
  constructor(private readonly profiles: CreativeProfileService) {}

  @RequiresPermission('profile.edit')
  @ApiEnvelope(OnboardingStateDto)
  @Get('me/onboarding')
  state(@CurrentAuth() auth: AuthContext) {
    return this.profiles.state(auth.userId);
  }

  @RequiresPermission('profile.edit')
  @ApiEnvelope(OnboardingStateDto)
  @Patch('me/onboarding')
  saveStep(@CurrentAuth() auth: AuthContext, @Body() dto: SaveOnboardingStepDto) {
    return this.profiles.saveStep(auth.userId, dto);
  }

  @RequiresPermission('profile.edit')
  @HttpCode(200)
  @ApiEnvelope(OnboardingCompleteDto)
  @Post('me/onboarding/complete')
  completeOnboarding(@CurrentAuth() auth: AuthContext) {
    return this.profiles.complete(auth.userId);
  }

  @RequiresPermission('profile.edit')
  @HttpCode(200)
  @ApiEnvelope(OnboardingStateDto)
  @Post('me/avatar')
  setAvatar(@CurrentAuth() auth: AuthContext, @Body() dto: SetAvatarDto) {
    return this.profiles.setAvatar(auth.userId, dto.mediaId);
  }

  @RequiresPermission('profile.edit')
  @ApiEnvelope(OnboardingStateDto)
  @Delete('me/avatar')
  removeAvatar(@CurrentAuth() auth: AuthContext) {
    return this.profiles.removeAvatar(auth.userId);
  }

  @RequiresPermission('profile.edit')
  @Throttle({ default: { limit: 40, ttl: 60_000 } })
  @ApiEnvelope(HandleAvailabilityDto)
  @Get('handles/:handle/availability')
  availability(@CurrentAuth() auth: AuthContext, @Param('handle') handle: string) {
    return this.profiles.handleAvailability(auth.userId, handle.slice(0, 64));
  }
}
