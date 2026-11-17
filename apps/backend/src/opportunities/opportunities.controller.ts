import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  Param,
  ParseUUIDPipe,
  Post,
  Put,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { type AuthContext } from '../access/access.types';
import { CurrentAuth, RequiresPermission } from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { Paged } from '../common/response-envelope.interceptor';
import {
  MyOpportunitiesQueryDto,
  MyOpportunityDto,
  OpportunitiesHomeDto,
  OpportunitiesQueryDto,
  OpportunityCardDto,
  OpportunityDetailQueryDto,
  OpportunityDto,
  TrackingStateDto,
  TrackOpportunityDto,
} from './opportunities.dto';
import { OpportunitiesService } from './opportunities.service';

/** Opportunities for members: discover, check eligibility, save, track. Needs `opportunity.view`. */
@ApiTags('Opportunities')
@ApiBearerAuth('access-token')
@RequiresPermission('opportunity.view')
@Controller()
export class OpportunitiesController {
  constructor(private readonly opportunities: OpportunitiesService) {}

  // `home` is registered before `:id` so it is never read as an id.
  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiEnvelope(OpportunitiesHomeDto)
  @Get('opportunities/home')
  home(@CurrentAuth() auth: AuthContext) {
    return this.opportunities.home(auth.userId);
  }

  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiEnvelope(OpportunityCardDto, { isArray: true })
  @Get('opportunities')
  async list(@CurrentAuth() auth: AuthContext, @Query() q: OpportunitiesQueryDto) {
    const { items, meta } = await this.opportunities.list(auth.userId, q);
    return new Paged(items, meta);
  }

  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiEnvelope(OpportunityDto)
  @Get('opportunities/:id')
  detail(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Query() q: OpportunityDetailQueryDto,
  ) {
    return this.opportunities.detail(auth.userId, id, q);
  }

  @Throttle({ default: { limit: 60, ttl: 60_000 } })
  @HttpCode(200)
  @ApiEnvelope(TrackingStateDto)
  @Put('opportunities/:id/save')
  save(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.opportunities.save(auth.userId, id);
  }

  @Throttle({ default: { limit: 60, ttl: 60_000 } })
  @HttpCode(204)
  @Delete('opportunities/:id/save')
  async unsave(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    await this.opportunities.unsave(auth.userId, id);
  }

  @Throttle({ default: { limit: 60, ttl: 60_000 } })
  @HttpCode(200)
  @ApiEnvelope(TrackingStateDto)
  @Post('opportunities/:id/track')
  track(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: TrackOpportunityDto,
  ) {
    return this.opportunities.track(auth.userId, id, dto);
  }

  @ApiEnvelope(MyOpportunityDto, { isArray: true })
  @Get('me/opportunities')
  async mine(@CurrentAuth() auth: AuthContext, @Query() q: MyOpportunitiesQueryDto) {
    const { items, meta } = await this.opportunities.mine(auth.userId, q);
    return new Paged(items, meta);
  }
}
