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
import { type AuthContext } from '../access/access.types';
import { CurrentAuth, RequiresPermission } from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { Paged } from '../common/response-envelope.interceptor';
import {
  DeviceDto,
  MarkAllReadDto,
  MarkedReadDto,
  NotificationItemDto,
  NotificationsQueryDto,
  PreferencesDto,
  RegisterDeviceDto,
  UnreadCountDto,
  UnreadDto,
  UpdatePreferencesDto,
} from './notifications.dto';
import { NotificationsService } from './notifications.service';

@ApiTags('Notifications')
@ApiBearerAuth('access-token')
@RequiresPermission('notification.manage.own')
@Controller()
export class NotificationsController {
  constructor(private readonly notifications: NotificationsService) {}

  /** The notification centre: newest first, optionally one category, with the unread total in `meta`. */
  @ApiEnvelope(NotificationItemDto, { isArray: true })
  @Get('notifications')
  async list(@CurrentAuth() auth: AuthContext, @Query() q: NotificationsQueryDto) {
    const { items, meta } = await this.notifications.list(auth.userId, q);
    return new Paged(items, meta);
  }

  @ApiEnvelope(UnreadCountDto)
  @Get('notifications/unread-count')
  unreadCount(@CurrentAuth() auth: AuthContext) {
    return this.notifications.unreadCount(auth.userId);
  }

  @HttpCode(200)
  @ApiEnvelope(MarkedReadDto)
  @Post('notifications/read-all')
  readAll(@CurrentAuth() auth: AuthContext, @Body() dto: MarkAllReadDto) {
    return this.notifications.markAllRead(auth.userId, dto.category);
  }

  @HttpCode(200)
  @ApiEnvelope(UnreadDto)
  @Post('notifications/:id/read')
  markRead(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.notifications.markRead(auth.userId, id);
  }

  @ApiEnvelope(PreferencesDto)
  @Get('notifications/preferences')
  async preferences(@CurrentAuth() auth: AuthContext) {
    return { preferences: await this.notifications.preferences(auth.userId) };
  }

  @ApiEnvelope(PreferencesDto)
  @Put('notifications/preferences')
  async updatePreferences(@CurrentAuth() auth: AuthContext, @Body() dto: UpdatePreferencesDto) {
    return {
      preferences: await this.notifications.updatePreferences(auth.userId, dto.preferences),
    };
  }

  @HttpCode(200)
  @ApiEnvelope(DeviceDto)
  @Post('devices')
  registerDevice(@CurrentAuth() auth: AuthContext, @Body() dto: RegisterDeviceDto) {
    return this.notifications.registerDevice(auth.userId, dto);
  }

  @HttpCode(204)
  @Delete('devices/:id')
  async removeDevice(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    await this.notifications.removeDevice(auth.userId, id);
  }
}
