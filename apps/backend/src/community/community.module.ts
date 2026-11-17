import { Module } from '@nestjs/common';
import { AdminModule } from '../admin/admin.module';
import { MediaModule } from '../media/media.module';
import { AdminCommunityController } from './admin-community.controller';
import { AdminGroupsService } from './admin-groups.service';
import { CommentsService } from './comments.service';
import { CommunityController } from './community.controller';
import { CommunityNotificationsListener } from './community-notifications.listener';
import { FeedService } from './feed.service';
import { GroupsController } from './groups.controller';
import { GroupsService } from './groups.service';
import { ModerationService } from './moderation.service';
import { PostViewsService } from './post-views.service';
import { PostsService } from './posts.service';
import { SafetyController } from './safety.controller';
import { SafetyService } from './safety.service';

/** Community (P1-M8): feed, posts, comments, reactions, groups, blocks, mutes, reports and the moderation queue. */
@Module({
  imports: [AdminModule, MediaModule],
  controllers: [CommunityController, GroupsController, SafetyController, AdminCommunityController],
  providers: [
    PostViewsService,
    FeedService,
    PostsService,
    CommentsService,
    GroupsService,
    SafetyService,
    ModerationService,
    AdminGroupsService,
    CommunityNotificationsListener,
  ],
})
export class CommunityModule {}
