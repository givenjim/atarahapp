import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { type AuthContext } from '../access/access.types';
import { CurrentAuth, OptionalAuth, RequiresPermission, Viewer } from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { Paged } from '../common/response-envelope.interceptor';
import { ConnectionsService } from './connections.service';
import {
  ConnectionListItemDto,
  ConnectionsQueryDto,
  ConnectionStateDto,
  GrowthDto,
  OwnProfileDto,
  PassportDto,
  PublicProfileDto,
  PublicProfileQueryDto,
  SectionVisibilityDto,
  SetSectionVisibilityDto,
  UpdateProfileDto,
} from './profile.dto';
import { ProfileService } from './profile.service';

@ApiTags('Profile')
@ApiBearerAuth('access-token')
@Controller()
export class ProfileController {
  constructor(
    private readonly profile: ProfileService,
    private readonly connections: ConnectionsService,
  ) {}

  @RequiresPermission('profile.view')
  @ApiEnvelope(OwnProfileDto)
  @Get('me/profile')
  myProfile(@CurrentAuth() auth: AuthContext) {
    return this.profile.me(auth.userId);
  }

  @RequiresPermission('profile.edit')
  @ApiEnvelope(OwnProfileDto)
  @Patch('me/profile')
  updateProfile(@CurrentAuth() auth: AuthContext, @Body() dto: UpdateProfileDto) {
    return this.profile.update(auth.userId, dto);
  }

  @RequiresPermission('profile.view')
  @ApiEnvelope(PassportDto)
  @Get('me/passport')
  myPassport(@CurrentAuth() auth: AuthContext) {
    return this.profile.passport(auth.userId);
  }

  @RequiresPermission('profile.edit')
  @ApiEnvelope(SectionVisibilityDto, { isArray: true })
  @Patch('me/passport/visibility')
  setVisibility(@CurrentAuth() auth: AuthContext, @Body() dto: SetSectionVisibilityDto) {
    return this.profile.setVisibility(auth.userId, dto.section, dto.visibility);
  }

  @RequiresPermission('profile.view')
  @ApiEnvelope(GrowthDto)
  @Get('me/growth')
  myGrowth(@CurrentAuth() auth: AuthContext) {
    return this.profile.growth(auth.userId);
  }

  /** Works signed out. What comes back depends on who is asking. */
  @OptionalAuth()
  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiEnvelope(PublicProfileDto)
  @Get('creatives/:handle')
  creative(
    @Param('handle') handle: string,
    @Query() q: PublicProfileQueryDto,
    @Viewer() viewer?: AuthContext,
  ) {
    return this.profile.publicProfile(handle.slice(0, 64), viewer, q.previewAs);
  }

  // ---- connections ----

  @RequiresPermission('profile.view')
  @Throttle({ default: { limit: 30, ttl: 3_600_000 } })
  @HttpCode(200)
  @ApiEnvelope(ConnectionStateDto)
  @Post('creatives/:handle/connect')
  connect(@CurrentAuth() auth: AuthContext, @Param('handle') handle: string) {
    return this.connections.connect(auth.userId, handle.slice(0, 64));
  }

  @RequiresPermission('profile.view')
  @HttpCode(200)
  @ApiEnvelope(ConnectionStateDto)
  @Post('connections/:id/accept')
  accept(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.connections.respond(auth.userId, id, 'accept');
  }

  @RequiresPermission('profile.view')
  @HttpCode(200)
  @ApiEnvelope(ConnectionStateDto)
  @Post('connections/:id/decline')
  decline(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.connections.respond(auth.userId, id, 'decline');
  }

  @RequiresPermission('profile.view')
  @ApiEnvelope(ConnectionStateDto)
  @Delete('connections/:id')
  removeConnection(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.connections.remove(auth.userId, id);
  }

  @RequiresPermission('profile.view')
  @ApiEnvelope(ConnectionListItemDto, { isArray: true })
  @Get('me/connections')
  async myConnections(@CurrentAuth() auth: AuthContext, @Query() q: ConnectionsQueryDto) {
    const { items, meta } = await this.connections.list(auth.userId, q);
    return new Paged(items, meta);
  }
}
