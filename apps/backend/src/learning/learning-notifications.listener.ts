import { Injectable, Logger, type OnModuleInit } from '@nestjs/common';
import { DomainEventBus } from '../community-core/domain-events';
import { NotificationsService } from '../notifications/notifications.service';
import { PrismaService } from '../prisma/prisma.service';

/** Tells a member when they earn a certificate. A notification problem never fails the lesson write. */
@Injectable()
export class LearningNotificationsListener implements OnModuleInit {
  private readonly log = new Logger(LearningNotificationsListener.name);

  constructor(
    private readonly bus: DomainEventBus,
    private readonly notifications: NotificationsService,
    private readonly prisma: PrismaService,
  ) {}

  onModuleInit(): void {
    this.bus.on('CourseCompleted', async (e) => {
      const course = await this.prisma.learningContent.findUnique({
        where: { id: e.courseId },
        select: { title: true },
      });
      if (!course) return;
      try {
        await this.notifications.notify({
          userId: e.userId,
          category: 'LEARNING',
          title: 'Certificate earned',
          body: `You completed ${course.title}. Your Skill Lab certificate is on your Passport.`,
          deepLink: `/learning/courses/${e.courseId}`,
        });
      } catch (err) {
        this.log.warn(
          `Certificate notification to ${e.userId} failed: ${err instanceof Error ? err.message : String(err)}`,
        );
      }
    });
  }
}
