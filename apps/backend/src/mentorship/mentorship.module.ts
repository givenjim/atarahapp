import { Module } from '@nestjs/common';
import { AdminModule } from '../admin/admin.module';
import { MediaModule } from '../media/media.module';
import { AdminMentorshipController } from './admin-mentorship.controller';
import { AdminMentorshipService } from './admin-mentorship.service';
import { AvailabilityService } from './availability.service';
import { MentorshipHooks } from './busy-slots';
import { MentorApplicationService } from './mentor-application.service';
import { MentorToolsService } from './mentor-tools.service';
import { MentorViewsService } from './mentor-views.service';
import {
  MentorApplicationController,
  MentorshipController,
  MentorToolsController,
} from './mentorship.controller';
import { MentorshipService } from './mentorship.service';

/**
 * Mentorship discovery and mentor onboarding (P2-M4): hub, directory, mentor profile, applications, mentor tools and
 * staff operations. Booking, payment and sessions arrive in P2-M5, which plugs into `AvailabilityService` and
 * `MentorshipHooks` (both exported) instead of changing this module.
 */
@Module({
  imports: [AdminModule, MediaModule],
  controllers: [
    MentorshipController,
    MentorApplicationController,
    MentorToolsController,
    AdminMentorshipController,
  ],
  providers: [
    MentorshipHooks,
    AvailabilityService,
    MentorViewsService,
    MentorshipService,
    MentorApplicationService,
    MentorToolsService,
    AdminMentorshipService,
  ],
  exports: [MentorshipHooks, AvailabilityService],
})
export class MentorshipModule {}
