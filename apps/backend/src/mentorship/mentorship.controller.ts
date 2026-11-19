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
  Put,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { type AuthContext } from '../access/access.types';
import { CurrentAuth, RequiresEntitlement, RequiresPermission } from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { PageQueryDto } from '../common/pagination';
import { Paged } from '../common/response-envelope.interceptor';
import {
  AddExceptionDto,
  ApplicationPrefillDto,
  ApplyMentorDto,
  AvailabilityDto,
  BookingRequestDto,
  ExceptionDto,
  MentorApplicationDto,
  MentorCardDto,
  MentorDetailDto,
  MentorsQueryDto,
  MentorshipHomeDto,
  MyApplicationDto,
  MyMentorDto,
  SessionTypeDto,
  SessionTypeFieldsDto,
  SetMentorPausedDto,
  SetWeeklyAvailabilityDto,
  SlotsDto,
  SlotsQueryDto,
  UpdateMentorProfileDto,
  UpdateSessionTypeDto,
} from './mentorship.dto';
import { MentorApplicationService } from './mentor-application.service';
import { MentorToolsService } from './mentor-tools.service';
import { MentorshipService } from './mentorship.service';

/**
 * Mentorship discovery. Open to every member (`mentor.browse`); only the slots route needs the
 * MENTORSHIP_BOOKING entitlement, so a Free member gets the PREMIUM_REQUIRED response there.
 */
@ApiTags('Mentorship')
@ApiBearerAuth('access-token')
@RequiresPermission('mentor.browse')
@Controller()
export class MentorshipController {
  constructor(private readonly mentorship: MentorshipService) {}

  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiEnvelope(MentorshipHomeDto)
  @Get('mentorship/home')
  home(@CurrentAuth() auth: AuthContext) {
    return this.mentorship.home(auth.userId);
  }

  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiEnvelope(MentorCardDto, { isArray: true })
  @Get('mentors')
  async list(@CurrentAuth() auth: AuthContext, @Query() q: MentorsQueryDto) {
    const { items, meta } = await this.mentorship.list(auth.userId, q);
    return new Paged(items, meta);
  }

  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiEnvelope(MentorDetailDto)
  @Get('mentors/:id')
  detail(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.mentorship.detail(auth.userId, id);
  }

  /** Bookable slots for one session type: availability minus bookings. Pro only. */
  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @RequiresEntitlement('MENTORSHIP_BOOKING')
  @ApiEnvelope(SlotsDto)
  @Get('mentors/:id/slots')
  slots(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Query() q: SlotsQueryDto,
  ) {
    return this.mentorship.slots(auth.userId, id, q);
  }
}

/** "Become a mentor": prefill, apply, status, withdraw. Needs `mentor.apply`. */
@ApiTags('Mentorship')
@ApiBearerAuth('access-token')
@RequiresPermission('mentor.apply')
@Controller('me/mentor-application')
export class MentorApplicationController {
  constructor(private readonly applications: MentorApplicationService) {}

  @ApiEnvelope(ApplicationPrefillDto)
  @Get('prefill')
  prefill(@CurrentAuth() auth: AuthContext) {
    return this.applications.prefill(auth.userId);
  }

  @ApiEnvelope(MyApplicationDto)
  @Get()
  mine(@CurrentAuth() auth: AuthContext) {
    return this.applications.mine(auth.userId);
  }

  @Throttle({ default: { limit: 5, ttl: 3_600_000 } })
  @ApiEnvelope(MentorApplicationDto, { status: 201 })
  @Post()
  apply(@CurrentAuth() auth: AuthContext, @Body() dto: ApplyMentorDto) {
    return this.applications.apply(auth.userId, dto);
  }

  @HttpCode(200)
  @ApiEnvelope(MentorApplicationDto)
  @Post('withdraw')
  withdraw(@CurrentAuth() auth: AuthContext) {
    return this.applications.withdraw(auth.userId);
  }
}

/** Mentor tools. Every route needs the MENTOR role's permissions and is scoped to the caller's own profile. */
@ApiTags('Mentor tools')
@ApiBearerAuth('access-token')
@Controller('me/mentor')
export class MentorToolsController {
  constructor(private readonly tools: MentorToolsService) {}

  @RequiresPermission('mentor.profile.manage')
  @ApiEnvelope(MyMentorDto)
  @Get()
  me(@CurrentAuth() auth: AuthContext) {
    return this.tools.me(auth.userId);
  }

  @RequiresPermission('mentor.profile.manage')
  @ApiEnvelope(MyMentorDto)
  @Patch('profile')
  updateProfile(@CurrentAuth() auth: AuthContext, @Body() dto: UpdateMentorProfileDto) {
    return this.tools.updateProfile(auth.userId, dto);
  }

  @RequiresPermission('mentor.profile.manage')
  @ApiEnvelope(MyMentorDto)
  @Put('paused')
  setPaused(@CurrentAuth() auth: AuthContext, @Body() dto: SetMentorPausedDto) {
    return this.tools.setPaused(auth.userId, dto.paused);
  }

  @RequiresPermission('mentor.availability.manage')
  @ApiEnvelope(AvailabilityDto)
  @Get('availability')
  availability(@CurrentAuth() auth: AuthContext) {
    return this.tools.getAvailability(auth.userId);
  }

  @RequiresPermission('mentor.availability.manage')
  @ApiEnvelope(AvailabilityDto)
  @Put('availability')
  setWeekly(@CurrentAuth() auth: AuthContext, @Body() dto: SetWeeklyAvailabilityDto) {
    return this.tools.setWeekly(auth.userId, dto);
  }

  @RequiresPermission('mentor.availability.manage')
  @ApiEnvelope(ExceptionDto, { status: 201 })
  @Post('availability/exceptions')
  addException(@CurrentAuth() auth: AuthContext, @Body() dto: AddExceptionDto) {
    return this.tools.addException(auth.userId, dto);
  }

  @RequiresPermission('mentor.availability.manage')
  @HttpCode(204)
  @Delete('availability/exceptions/:id')
  async removeException(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    await this.tools.removeException(auth.userId, id);
  }

  @RequiresPermission('mentor.availability.manage')
  @ApiEnvelope(SessionTypeDto, { status: 201 })
  @Post('session-types')
  createSessionType(@CurrentAuth() auth: AuthContext, @Body() dto: SessionTypeFieldsDto) {
    return this.tools.createSessionType(auth.userId, dto);
  }

  @RequiresPermission('mentor.availability.manage')
  @ApiEnvelope(SessionTypeDto)
  @Patch('session-types/:id')
  updateSessionType(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateSessionTypeDto,
  ) {
    return this.tools.updateSessionType(auth.userId, id, dto);
  }

  @RequiresPermission('mentor.availability.manage')
  @HttpCode(204)
  @Delete('session-types/:id')
  async deactivateSessionType(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    await this.tools.deactivateSessionType(auth.userId, id);
  }

  /** Empty until P2-M5 registers its provider (see MentorshipHooks). */
  @RequiresPermission('mentor.bookings.manage')
  @ApiEnvelope(BookingRequestDto, { isArray: true })
  @Get('booking-requests')
  async bookingRequests(@CurrentAuth() auth: AuthContext, @Query() q: PageQueryDto) {
    const { items, meta } = await this.tools.bookingRequests(auth.userId, q);
    return new Paged(items, meta);
  }
}
