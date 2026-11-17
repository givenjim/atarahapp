import { Controller, Get, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { type AuthContext } from '../access/access.types';
import { CurrentAuth, RequiresPermission } from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { Paged } from '../common/response-envelope.interceptor';
import { PeopleQueryDto, PersonToMeetDto } from './community.dto';
import { PeopleService } from './people.service';

/** Registered through PeopleModule, which AppModule lists before CreativeModule. */
@ApiTags('Community')
@ApiBearerAuth('access-token')
@RequiresPermission('profile.view')
@Controller()
export class PeopleController {
  constructor(private readonly people: PeopleService) {}

  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiEnvelope(PersonToMeetDto, { isArray: true })
  @Get('creatives/suggestions')
  async listPeopleToMeet(@CurrentAuth() auth: AuthContext, @Query() q: PeopleQueryDto) {
    const { items, meta } = await this.people.suggest(auth.userId, q);
    return new Paged(items, meta);
  }
}
