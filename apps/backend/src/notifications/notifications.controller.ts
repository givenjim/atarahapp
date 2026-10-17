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
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { type AuthContext } from '../access/access.types';
import { CurrentAuth, RequiresPermission } from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import {
  DeviceDto,
  PreferencesDto,
  RegisterDeviceDto,
  UpdatePreferencesDto,
} from './notifications.dto';
import { NotificationsService } from './notifications.service';

@ApiTags('Notifications')
@ApiBearerAuth('access-token')
@RequiresPermission('notification.manage.own')
@Controller()
export class NotificationsController {
  constructor(private readonly notifications: NotificationsService) {}

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
