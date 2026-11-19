import {
  Body,
  Controller,
  Get,
  HttpCode,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { type AuthContext } from '../access/access.types';
import {
  ClientIp,
  CurrentAuth,
  RequestIdParam,
  RequiresPermission,
  RequiresRecentAuth,
} from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { Paged } from '../common/response-envelope.interceptor';
import { AdminMentorshipService } from './admin-mentorship.service';
import {
  AdminApplicationDto,
  AdminApplicationsQueryDto,
  AdminMentorDto,
  AdminMentorsQueryDto,
  AdminSessionTypeDto,
  AdminSessionTypesQueryDto,
  DecideApplicationDto,
  FeatureMentorDto,
  MentorStatusChangeDto,
  StaffSessionTypeDto,
} from './mentorship.dto';

/** Staff operations on mentorship under /api/v1/admin. Every route needs `mentor.manage`; actions are audited. */
@ApiTags('Admin mentorship')
@ApiBearerAuth('access-token')
@RequiresPermission('admin.access', 'mentor.manage')
@Controller('admin')
export class AdminMentorshipController {
  constructor(private readonly admin: AdminMentorshipService) {}

  private actor(auth: AuthContext, ip?: string, requestId?: string) {
    return { userId: auth.userId, ip, requestId };
  }

  // ---- applications ----

  @ApiEnvelope(AdminApplicationDto, { isArray: true })
  @Get('mentor-applications')
  async applications(@Query() q: AdminApplicationsQueryDto) {
    const { items, meta } = await this.admin.listApplications(q);
    return new Paged(items, meta);
  }

  @ApiEnvelope(AdminApplicationDto)
  @Get('mentor-applications/:id')
  application(@Param('id', ParseUUIDPipe) id: string) {
    return this.admin.getApplication(id);
  }

  @HttpCode(200)
  @ApiEnvelope(AdminApplicationDto)
  @Post('mentor-applications/:id/approve')
  approve(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: DecideApplicationDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.approve(this.actor(auth, ip, requestId), id, dto.reason);
  }

  @HttpCode(200)
  @ApiEnvelope(AdminApplicationDto)
  @Post('mentor-applications/:id/reject')
  reject(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: DecideApplicationDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.reject(this.actor(auth, ip, requestId), id, dto.reason);
  }

  // ---- mentors ----

  @ApiEnvelope(AdminMentorDto, { isArray: true })
  @Get('mentors')
  async mentors(@Query() q: AdminMentorsQueryDto) {
    const { items, meta } = await this.admin.listMentors(q);
    return new Paged(items, meta);
  }

  @HttpCode(200)
  @ApiEnvelope(AdminMentorDto)
  @Post('mentors/:id/pause')
  pause(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: MentorStatusChangeDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.pause(this.actor(auth, ip, requestId), id, dto.reason);
  }

  @HttpCode(200)
  @ApiEnvelope(AdminMentorDto)
  @Post('mentors/:id/resume')
  resume(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: MentorStatusChangeDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.resume(this.actor(auth, ip, requestId), id, dto.reason);
  }

  /** Removing a mentor revokes a role, so it needs a fresh authenticator code. */
  @RequiresRecentAuth()
  @HttpCode(200)
  @ApiEnvelope(AdminMentorDto)
  @Post('mentors/:id/remove')
  remove(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: MentorStatusChangeDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.remove(this.actor(auth, ip, requestId), id, dto.reason);
  }

  @ApiEnvelope(AdminMentorDto)
  @Patch('mentors/:id/featured')
  feature(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: FeatureMentorDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.feature(this.actor(auth, ip, requestId), id, dto.featured);
  }

  // ---- session type oversight ----

  @ApiEnvelope(AdminSessionTypeDto, { isArray: true })
  @Get('mentor-session-types')
  async sessionTypes(@Query() q: AdminSessionTypesQueryDto) {
    const { items, meta } = await this.admin.listSessionTypes(q);
    return new Paged(items, meta);
  }

  @ApiEnvelope(AdminSessionTypeDto)
  @Patch('mentor-session-types/:id')
  setDisabled(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: StaffSessionTypeDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.setSessionTypeDisabled(
      this.actor(auth, ip, requestId),
      id,
      dto.disabled,
      dto.note,
    );
  }
}
