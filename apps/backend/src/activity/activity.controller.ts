import { Controller, Get, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { type AuthContext } from '../access/access.types';
import { CurrentAuth, RequiresPermission } from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { Paged } from '../common/response-envelope.interceptor';
import { ActivityDto, ApplicationItemDto, ApplicationsQueryDto } from './activity.dto';
import { ActivityService } from './activity.service';

/** The Activity hub and the Applications list. */
@ApiTags('Activity')
@ApiBearerAuth('access-token')
@Controller('me')
export class ActivityController {
  constructor(private readonly activity: ActivityService) {}

  @RequiresPermission('profile.view')
  @ApiEnvelope(ActivityDto)
  @Get('activity')
  hub(@CurrentAuth() auth: AuthContext) {
    return this.activity.activity(auth.userId);
  }

  @RequiresPermission('opportunity.view')
  @ApiEnvelope(ApplicationItemDto, { isArray: true })
  @Get('applications')
  async applications(@CurrentAuth() auth: AuthContext, @Query() q: ApplicationsQueryDto) {
    const { items, meta } = await this.activity.applications(auth.userId, q);
    return new Paged(items, meta);
  }
}
