import { Module } from '@nestjs/common';
import { AdminModule } from '../admin/admin.module';
import { MediaModule } from '../media/media.module';
import { AdminLearningController } from './admin-learning.controller';
import { AdminLearningService } from './admin-learning.service';
import { LearningController } from './learning.controller';
import { LearningService } from './learning.service';
import { LearningNotificationsListener } from './learning-notifications.listener';
import { LearningViewsService } from './learning-views.service';
import { LessonService } from './lesson.service';

/** Skill Labs (P1-M10): hub, categories, courses and lessons, progress, certificates, and the learning CMS. */
@Module({
  imports: [AdminModule, MediaModule],
  controllers: [LearningController, AdminLearningController],
  providers: [
    LearningViewsService,
    LearningService,
    LessonService,
    AdminLearningService,
    LearningNotificationsListener,
  ],
  exports: [LearningService],
})
export class LearningModule {}
