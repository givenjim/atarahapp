import { Body, Controller, Get, HttpCode, Param, Patch, Put } from '@nestjs/common';
import { ApiBearerAuth, ApiProperty, ApiPropertyOptional, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { IsBoolean, IsDefined, IsOptional, IsString, MaxLength } from 'class-validator';
import { type AuthContext } from '../access/access.types';
import {
  ClientIp,
  CurrentAuth,
  RequestIdParam,
  RequiresPermission,
  RequiresRecentAuth,
} from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { ApiException } from '../common/api.exception';
import { FeatureFlagService } from '../feature-flags/feature-flag.service';
import { PlatformSettingsService } from '../feature-flags/platform-settings.service';
import { PrismaService } from '../prisma/prisma.service';

class FeatureFlagDto {
  @ApiProperty({ example: 'opportunities' }) key!: string;
  @ApiProperty() description!: string;
  @ApiProperty() enabled!: boolean;
  @ApiProperty({ description: 'The Master Prompt phase that delivers the capability.' })
  phase!: number;
}

class SetFlagDto {
  @ApiProperty() @IsBoolean() enabled!: boolean;
}

class PlatformSettingDto {
  @ApiProperty({ example: 'membership.pro.price_minor' }) key!: string;
  @ApiProperty({
    description: 'A string, number or boolean.',
    oneOf: [{ type: 'string' }, { type: 'number' }, { type: 'boolean' }],
  })
  value!: string | number | boolean;
  @ApiPropertyOptional({ type: String, nullable: true }) description!: string | null;
  @ApiProperty({ type: String, format: 'date-time' }) updatedAt!: Date;
}

class SetSettingDto {
  @ApiProperty({
    description:
      'The new value. It must be the same kind (string, number or boolean) as the current one.',
  })
  @IsDefined()
  value!: string | number | boolean;

  @ApiPropertyOptional({ maxLength: 300 })
  @IsOptional()
  @IsString()
  @MaxLength(300)
  description?: string;
}

/** Platform switches and tunable values under /api/v1/admin. Every change is audited by the services that make it. */
@ApiTags('Admin platform')
@ApiBearerAuth('access-token')
@Controller('admin')
export class AdminPlatformController {
  constructor(
    private readonly flags: FeatureFlagService,
    private readonly settings: PlatformSettingsService,
    private readonly prisma: PrismaService,
  ) {}

  @RequiresPermission('admin.access', 'settings.manage')
  @ApiEnvelope(FeatureFlagDto, { isArray: true })
  @Get('feature-flags')
  listFlags() {
    return this.flags.list();
  }

  @RequiresPermission('admin.access', 'settings.manage')
  @RequiresRecentAuth()
  @Throttle({ default: { limit: 30, ttl: 60_000 } })
  @ApiEnvelope(FeatureFlagDto)
  @Patch('feature-flags/:key')
  setFlag(
    @CurrentAuth() auth: AuthContext,
    @Param('key') key: string,
    @Body() dto: SetFlagDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.flags.set(key.slice(0, 80), dto.enabled, { id: auth.userId, ip, requestId });
  }

  @RequiresPermission('admin.access', 'settings.manage')
  @ApiEnvelope(PlatformSettingDto, { isArray: true })
  @Get('settings')
  async listSettings(): Promise<PlatformSettingDto[]> {
    const rows = await this.prisma.platformSetting.findMany({ orderBy: { key: 'asc' } });
    return rows.map((r) => ({
      key: r.key,
      value: r.value as string | number | boolean,
      description: r.description,
      updatedAt: r.updatedAt,
    }));
  }

  /** Changes an existing setting. New keys are created by migrations and seeds, never from the console. */
  @RequiresPermission('admin.access', 'settings.manage')
  @RequiresRecentAuth()
  @Throttle({ default: { limit: 30, ttl: 60_000 } })
  @HttpCode(200)
  @ApiEnvelope(PlatformSettingDto)
  @Put('settings/:key')
  async setSetting(
    @CurrentAuth() auth: AuthContext,
    @Param('key') key: string,
    @Body() dto: SetSettingDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ): Promise<PlatformSettingDto> {
    const existing = await this.prisma.platformSetting.findUnique({
      where: { key: key.slice(0, 120) },
    });
    if (!existing) throw ApiException.notFound('That setting does not exist.');
    const kind = (v: unknown) =>
      typeof v === 'string' || typeof v === 'number' || typeof v === 'boolean' ? typeof v : 'other';
    if (kind(dto.value) === 'other' || kind(dto.value) !== kind(existing.value)) {
      throw ApiException.validation(`That setting holds a ${kind(existing.value)}.`, {
        field: 'value',
      });
    }
    await this.settings.set(
      existing.key,
      dto.value,
      { id: auth.userId, ip, requestId },
      dto.description,
    );
    const row = await this.prisma.platformSetting.findUniqueOrThrow({
      where: { key: existing.key },
    });
    return {
      key: row.key,
      value: row.value as string | number | boolean,
      description: row.description,
      updatedAt: row.updatedAt,
    };
  }
}
