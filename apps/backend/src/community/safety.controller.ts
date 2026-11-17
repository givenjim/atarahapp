import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  Param,
  ParseEnumPipe,
  ParseUUIDPipe,
  Post,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiParam, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { MuteTargetType } from '@prisma/client';
import { type AuthContext } from '../access/access.types';
import { CurrentAuth, RequiresPermission } from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { Paged } from '../common/response-envelope.interceptor';
import {
  BlockedMemberDto,
  BlockedQueryDto,
  BlockMemberDto,
  CreateReportDto,
  MuteStateDto,
  MuteTargetDto,
  MyReportDto,
  MyReportsQueryDto,
} from './community.dto';
import { SafetyService } from './safety.service';

const DAY = 86_400_000;

@ApiTags('Community safety')
@ApiBearerAuth('access-token')
@RequiresPermission('community.view')
@Controller()
export class SafetyController {
  constructor(private readonly safety: SafetyService) {}

  // ---- blocks ----

  @Throttle({ default: { limit: 60, ttl: 3_600_000 } })
  @HttpCode(200)
  @ApiEnvelope(BlockedMemberDto)
  @Post('blocks')
  blockMember(@CurrentAuth() auth: AuthContext, @Body() dto: BlockMemberDto) {
    return this.safety.block(auth.userId, dto);
  }

  @HttpCode(204)
  @Delete('blocks/:userId')
  async unblockMember(
    @CurrentAuth() auth: AuthContext,
    @Param('userId', ParseUUIDPipe) userId: string,
  ) {
    await this.safety.unblock(auth.userId, userId);
  }

  @ApiEnvelope(BlockedMemberDto, { isArray: true })
  @Get('me/blocks')
  async listBlockedMembers(@CurrentAuth() auth: AuthContext, @Query() q: BlockedQueryDto) {
    const { items, meta } = await this.safety.blocked(auth.userId, q);
    return new Paged(items, meta);
  }

  // ---- mutes ----

  @Throttle({ default: { limit: 120, ttl: 3_600_000 } })
  @HttpCode(200)
  @ApiEnvelope(MuteStateDto)
  @Post('mutes')
  muteTarget(@CurrentAuth() auth: AuthContext, @Body() dto: MuteTargetDto) {
    return this.safety.mute(auth.userId, dto);
  }

  @ApiParam({ name: 'targetType', enum: Object.values(MuteTargetType) })
  @ApiEnvelope(MuteStateDto)
  @Delete('mutes/:targetType/:targetId')
  unmuteTarget(
    @CurrentAuth() auth: AuthContext,
    @Param('targetType', new ParseEnumPipe(MuteTargetType)) targetType: MuteTargetType,
    @Param('targetId', ParseUUIDPipe) targetId: string,
  ) {
    return this.safety.unmute(auth.userId, targetType, targetId);
  }

  // ---- reports ----

  @Throttle({ default: { limit: 20, ttl: DAY } })
  @ApiEnvelope(MyReportDto, { status: 201 })
  @Post('reports')
  submitReport(@CurrentAuth() auth: AuthContext, @Body() dto: CreateReportDto) {
    return this.safety.report(auth.userId, dto);
  }

  @ApiEnvelope(MyReportDto, { isArray: true })
  @Get('me/reports')
  async listMyReports(@CurrentAuth() auth: AuthContext, @Query() q: MyReportsQueryDto) {
    const { items, meta } = await this.safety.myReports(auth.userId, q);
    return new Paged(items, meta);
  }
}
