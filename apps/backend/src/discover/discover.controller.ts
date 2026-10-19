import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { type AuthContext } from '../access/access.types';
import { CurrentAuth, RequiresPermission } from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { Paged } from '../common/response-envelope.interceptor';
import { CreativesDiscoveryService } from './creatives-discovery.service';
import {
  CreativeCardDto,
  CreativesQueryDto,
  HomeDto,
  RecentSearchDto,
  RecordSearchDto,
  SearchQueryDto,
  SearchResultDto,
} from './discover.dto';
import { HomeService } from './home.service';
import { SearchService } from './search.service';

@ApiTags('Discover')
@ApiBearerAuth('access-token')
@RequiresPermission('profile.view')
@Controller()
export class DiscoverController {
  constructor(
    private readonly home: HomeService,
    private readonly creatives: CreativesDiscoveryService,
    private readonly search: SearchService,
  ) {}

  @Throttle({ default: { limit: 60, ttl: 60_000 } })
  @ApiEnvelope(HomeDto)
  @Get('home')
  homeFeed(@CurrentAuth() auth: AuthContext) {
    return this.home.home(auth.userId);
  }

  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiEnvelope(CreativeCardDto, { isArray: true })
  @Get('creatives')
  async creativeList(@CurrentAuth() auth: AuthContext, @Query() q: CreativesQueryDto) {
    const { items, meta } = await this.creatives.search(auth.userId, q);
    return new Paged(items, meta);
  }

  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiEnvelope(SearchResultDto)
  @Get('search')
  find(@CurrentAuth() auth: AuthContext, @Query() q: SearchQueryDto) {
    return this.search.search(auth.userId, q);
  }

  @ApiEnvelope(RecentSearchDto, { isArray: true })
  @Get('me/recent-searches')
  recent(@CurrentAuth() auth: AuthContext) {
    return this.search.recent(auth.userId);
  }

  @HttpCode(200)
  @ApiEnvelope(RecentSearchDto)
  @Post('me/recent-searches')
  record(@CurrentAuth() auth: AuthContext, @Body() dto: RecordSearchDto) {
    return this.search.record(auth.userId, dto.query);
  }

  @HttpCode(204)
  @Delete('me/recent-searches')
  async clear(@CurrentAuth() auth: AuthContext) {
    await this.search.clear(auth.userId);
  }

  @HttpCode(204)
  @Delete('me/recent-searches/:id')
  async remove(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    await this.search.remove(auth.userId, id);
  }
}
