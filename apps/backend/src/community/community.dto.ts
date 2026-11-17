import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsBoolean,
  IsEnum,
  IsIn,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  MinLength,
} from 'class-validator';
import {
  GroupRole,
  GroupType,
  MuteTargetType,
  PostAudience,
  PostType,
  ReportReason,
  ReportTargetType,
} from '@prisma/client';
import { CursorQueryDto, PageQueryDto } from '../common/pagination';
import { CreativeCardDto } from '../discover/discover.dto';
import { MAX_COMMENT_BODY, MAX_POST_BODY, MAX_POST_MEDIA } from './rules';

const POST_TYPES = Object.values(PostType);
const AUDIENCES = Object.values(PostAudience);
const GROUP_TYPES = Object.values(GroupType);
const REPORT_REASONS = Object.values(ReportReason);
const REPORT_TARGETS = Object.values(ReportTargetType);
const MUTE_TARGETS = Object.values(MuteTargetType);
const GROUP_ROLES = Object.values(GroupRole);

const flag = ({ value }: { value: unknown }) =>
  value === true || value === 'true' || value === '1'
    ? true
    : value === false || value === 'false' || value === '0'
      ? false
      : value;

// ---- posts ------------------------------------------------------------------------------------------------

export class PostAuthorDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({
    nullable: true,
    type: String,
    description: 'Null for staff accounts without a profile.',
  })
  handle!: string | null;
  @ApiProperty() displayName!: string;
  @ApiProperty({ nullable: true, type: String }) avatarUrl!: string | null;
  @ApiProperty({ nullable: true, type: String }) headline!: string | null;
  @ApiProperty({ description: 'Verified by Atarah.' }) verified!: boolean;
}

export class PostGroupRefDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() slug!: string;
  @ApiProperty() name!: string;
}

export class PostMediaItemDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ enum: ['IMAGE', 'VIDEO'], enumName: 'PostMediaKind' }) kind!: string;
  @ApiProperty({
    nullable: true,
    type: String,
    description: 'Signed URL; null until processing finished.',
  })
  url!: string | null;
  @ApiProperty({ nullable: true, type: String, description: 'Smaller rendition for lists.' })
  thumbUrl!: string | null;
  @ApiProperty({ nullable: true, type: Number }) width!: number | null;
  @ApiProperty({ nullable: true, type: Number }) height!: number | null;
}

export class PostLinkPreviewDto {
  @ApiProperty() url!: string;
  @ApiProperty({ nullable: true, type: String }) title!: string | null;
  @ApiProperty({ nullable: true, type: String }) description!: string | null;
  @ApiProperty({ nullable: true, type: String }) image!: string | null;
  @ApiProperty({ nullable: true, type: String }) siteName!: string | null;
}

export class PostViewerDto {
  @ApiProperty() reacted!: boolean;
  @ApiProperty() saved!: boolean;
  @ApiProperty({ description: 'The viewer muted this thread.' }) muted!: boolean;
  @ApiProperty({ description: 'The viewer wrote it: edit and delete are available.' })
  isAuthor!: boolean;
}

export class PostViewDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ enum: POST_TYPES, enumName: 'PostType' }) type!: string;
  @ApiProperty() body!: string;
  @ApiProperty({ enum: AUDIENCES, enumName: 'PostAudience' }) audience!: string;
  @ApiProperty({ type: PostGroupRefDto, nullable: true }) group!: PostGroupRefDto | null;
  @ApiProperty({ type: PostAuthorDto }) author!: PostAuthorDto;
  @ApiProperty({ type: [PostMediaItemDto] }) media!: PostMediaItemDto[];
  @ApiProperty({ type: PostLinkPreviewDto, nullable: true }) link!: PostLinkPreviewDto | null;
  @ApiProperty() reactionCount!: number;
  @ApiProperty() replyCount!: number;
  @ApiProperty() isStaffAnnouncement!: boolean;
  @ApiProperty({
    enum: ['VISIBLE', 'HIDDEN'],
    enumName: 'PostViewStatus',
    description: 'HIDDEN only on the author’s own post after a moderator hid it.',
  })
  status!: string;
  @ApiProperty({ type: PostViewerDto }) viewer!: PostViewerDto;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
  @ApiProperty({ type: String, format: 'date-time', nullable: true }) editedAt!: Date | null;
}

export class FeedQueryDto extends CursorQueryDto {
  @ApiPropertyOptional({
    enum: POST_TYPES,
    enumName: 'PostType',
    description: 'Only this kind of post (the Discussions tab uses DISCUSSION).',
  })
  @IsOptional()
  @IsEnum(POST_TYPES)
  type?: PostType;
}

export class GroupPostsQueryDto extends CursorQueryDto {
  @ApiPropertyOptional({ enum: POST_TYPES, enumName: 'PostType' })
  @IsOptional()
  @IsEnum(POST_TYPES)
  type?: PostType;
}

export class SavedPostsQueryDto extends CursorQueryDto {}

export class CreatePostDto {
  @ApiProperty({
    enum: POST_TYPES,
    enumName: 'PostType',
    description: 'ANNOUNCEMENT needs the community.announce permission.',
  })
  @IsEnum(POST_TYPES)
  type!: PostType;

  @ApiPropertyOptional({
    maxLength: MAX_POST_BODY,
    description: 'Required unless the post has media or a link.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(MAX_POST_BODY)
  body?: string;

  @ApiPropertyOptional({
    enum: AUDIENCES,
    enumName: 'PostAudience',
    default: 'MEMBERS',
    description: 'GROUP is implied by `groupId`.',
  })
  @IsOptional()
  @IsEnum(AUDIENCES)
  audience?: PostAudience;

  @ApiPropertyOptional({ format: 'uuid', description: 'Post into a group you belong to.' })
  @IsOptional()
  @IsUUID()
  groupId?: string;

  @ApiPropertyOptional({
    type: [String],
    maxItems: MAX_POST_MEDIA,
    description: 'Your uploaded images or videos (POST /media/uploads), in display order.',
  })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(MAX_POST_MEDIA)
  @IsUUID('all', { each: true })
  mediaIds?: string[];

  @ApiPropertyOptional({
    description: 'One web link; its preview is fetched by the server shortly after posting.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(2048)
  linkUrl?: string;
}

export class GroupPostBodyDto {
  @ApiProperty({ enum: POST_TYPES, enumName: 'PostType' })
  @IsEnum(POST_TYPES)
  type!: PostType;

  @ApiPropertyOptional({ maxLength: MAX_POST_BODY })
  @IsOptional()
  @IsString()
  @MaxLength(MAX_POST_BODY)
  body?: string;

  @ApiPropertyOptional({ type: [String], maxItems: MAX_POST_MEDIA })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(MAX_POST_MEDIA)
  @IsUUID('all', { each: true })
  mediaIds?: string[];

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(2048)
  linkUrl?: string;
}

export class UpdatePostDto {
  @ApiProperty({ minLength: 1, maxLength: MAX_POST_BODY })
  @IsString()
  @MinLength(1)
  @MaxLength(MAX_POST_BODY)
  body!: string;
}

export class ReactionStateDto {
  @ApiProperty() reacted!: boolean;
  @ApiProperty() reactionCount!: number;
}

export class SavedStateDto {
  @ApiProperty() saved!: boolean;
}

// ---- comments ---------------------------------------------------------------------------------------------

export class ReplyViewDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ format: 'uuid' }) postId!: string;
  @ApiProperty({ format: 'uuid' }) parentCommentId!: string;
  @ApiProperty() body!: string;
  @ApiProperty({ type: PostAuthorDto }) author!: PostAuthorDto;
  @ApiProperty() isMine!: boolean;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
  @ApiProperty({ type: String, format: 'date-time', nullable: true }) editedAt!: Date | null;
}

export class CommentViewDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ format: 'uuid' }) postId!: string;
  @ApiProperty({
    nullable: true,
    type: String,
    format: 'uuid',
    description: 'Always null on a top-level comment.',
  })
  parentCommentId!: string | null;
  @ApiProperty() body!: string;
  @ApiProperty({ type: PostAuthorDto }) author!: PostAuthorDto;
  @ApiProperty() isMine!: boolean;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
  @ApiProperty({ type: String, format: 'date-time', nullable: true }) editedAt!: Date | null;
  @ApiProperty({ type: [ReplyViewDto], description: 'Oldest first. One reply level only.' })
  replies!: ReplyViewDto[];
}

export class CommentsQueryDto extends CursorQueryDto {}

export class CreateCommentDto {
  @ApiProperty({ minLength: 1, maxLength: MAX_COMMENT_BODY })
  @IsString()
  @MinLength(1)
  @MaxLength(MAX_COMMENT_BODY)
  body!: string;

  @ApiPropertyOptional({ format: 'uuid', description: 'Reply to this top-level comment.' })
  @IsOptional()
  @IsUUID()
  parentCommentId?: string;
}

export class UpdateCommentDto {
  @ApiProperty({ minLength: 1, maxLength: MAX_COMMENT_BODY })
  @IsString()
  @MinLength(1)
  @MaxLength(MAX_COMMENT_BODY)
  body!: string;
}

// ---- groups -----------------------------------------------------------------------------------------------

export class GroupCardDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() slug!: string;
  @ApiProperty({ enum: GROUP_TYPES, enumName: 'GroupType' }) type!: string;
  @ApiProperty() name!: string;
  @ApiProperty() description!: string;
  @ApiProperty({ nullable: true, type: String }) coverUrl!: string | null;
  @ApiProperty() memberCount!: number;
  @ApiProperty({ description: 'Run by Atarah.' }) isOfficial!: boolean;
  @ApiProperty({
    nullable: true,
    type: String,
    description: 'Discipline or county the group is about.',
  })
  focus!: string | null;
  @ApiProperty() joined!: boolean;
  @ApiProperty({ enum: GROUP_ROLES, enumName: 'GroupRole', nullable: true, type: String }) role!:
    string | null;
}

export class GroupViewerDto {
  @ApiProperty() joined!: boolean;
  @ApiProperty({ enum: GROUP_ROLES, enumName: 'GroupRole', nullable: true, type: String }) role!:
    string | null;
  @ApiProperty({ description: 'Members can post into the group.' }) canPost!: boolean;
}

export class GroupDetailDto extends GroupCardDto {
  @ApiProperty({ enum: ['OPEN', 'PRIVATE'], enumName: 'GroupVisibility' }) visibility!: string;
  @ApiProperty({
    type: PostViewDto,
    nullable: true,
    description: 'The latest pinned announcement.',
  })
  pinned!: PostViewDto | null;
  @ApiProperty({ type: [PostViewDto], description: 'The latest discussions, newest first.' })
  recentDiscussions!: PostViewDto[];
  @ApiProperty({ type: GroupViewerDto }) viewer!: GroupViewerDto;
}

export class GroupsQueryDto extends PageQueryDto {
  @ApiPropertyOptional({
    enum: ['discover', 'mine', 'all'],
    enumName: 'GroupScope',
    default: 'discover',
    description: 'discover = groups you have not joined; mine = your groups.',
  })
  @IsOptional()
  @IsIn(['discover', 'mine', 'all'])
  scope: 'discover' | 'mine' | 'all' = 'discover';

  @ApiPropertyOptional({ enum: GROUP_TYPES, enumName: 'GroupType' })
  @IsOptional()
  @IsEnum(GROUP_TYPES)
  type?: GroupType;

  @ApiPropertyOptional({ maxLength: 80, description: 'Part of the group name.' })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  q?: string;
}

export class GroupMembershipStateDto {
  @ApiProperty({ format: 'uuid' }) groupId!: string;
  @ApiProperty() joined!: boolean;
  @ApiProperty() memberCount!: number;
}

// ---- blocks, mutes, reports -------------------------------------------------------------------------------

export class BlockMemberDto {
  @ApiPropertyOptional({ format: 'uuid' })
  @IsOptional()
  @IsUUID()
  userId?: string;

  @ApiPropertyOptional({ description: 'The member’s handle, as an alternative to `userId`.' })
  @IsOptional()
  @IsString()
  @MaxLength(64)
  handle?: string;
}

export class BlockedMemberDto {
  @ApiProperty({ format: 'uuid' }) userId!: string;
  @ApiProperty({ nullable: true, type: String }) handle!: string | null;
  @ApiProperty() displayName!: string;
  @ApiProperty({ nullable: true, type: String }) avatarUrl!: string | null;
  @ApiProperty({ type: String, format: 'date-time' }) blockedAt!: Date;
}

export class MuteTargetDto {
  @ApiProperty({ enum: MUTE_TARGETS, enumName: 'MuteTargetType' })
  @IsEnum(MUTE_TARGETS)
  targetType!: MuteTargetType;

  @ApiPropertyOptional({ format: 'uuid', description: 'A user id (USER) or a post id (POST).' })
  @IsOptional()
  @IsUUID()
  targetId?: string;

  @ApiPropertyOptional({ description: 'For USER: the handle, instead of `targetId`.' })
  @IsOptional()
  @IsString()
  @MaxLength(64)
  handle?: string;
}

export class MuteStateDto {
  @ApiProperty({ enum: MUTE_TARGETS, enumName: 'MuteTargetType' }) targetType!: string;
  @ApiProperty({ format: 'uuid' }) targetId!: string;
  @ApiProperty() muted!: boolean;
}

export class CreateReportDto {
  @ApiProperty({ enum: REPORT_TARGETS, enumName: 'ReportTargetType' })
  @IsEnum(REPORT_TARGETS)
  targetType!: ReportTargetType;

  @ApiPropertyOptional({ format: 'uuid', description: 'The post, comment, user or group id.' })
  @IsOptional()
  @IsUUID()
  targetId?: string;

  @ApiPropertyOptional({ description: 'For USER: the handle, instead of `targetId`.' })
  @IsOptional()
  @IsString()
  @MaxLength(64)
  handle?: string;

  @ApiProperty({ enum: REPORT_REASONS, enumName: 'ReportReason' })
  @IsEnum(REPORT_REASONS)
  reason!: ReportReason;

  @ApiPropertyOptional({ maxLength: 1000 })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  note?: string;
}

export class MyReportDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ enum: REPORT_TARGETS, enumName: 'ReportTargetType' }) targetType!: string;
  @ApiProperty({ enum: REPORT_REASONS, enumName: 'ReportReason' }) reason!: string;
  @ApiProperty({
    enum: ['SUBMITTED', 'UNDER_REVIEW', 'REVIEWED'],
    enumName: 'PublicReportStatus',
    description: 'What a reporter may know. Who decided, how and why stays internal.',
  })
  status!: string;
  @ApiProperty({
    enum: ['ACTION_TAKEN', 'NO_ACTION'],
    enumName: 'ReportOutcome',
    nullable: true,
    type: String,
    description: 'Only once reviewed.',
  })
  outcome!: string | null;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
  @ApiProperty({ type: String, format: 'date-time', nullable: true }) reviewedAt!: Date | null;
}

export class MyReportsQueryDto extends PageQueryDto {}
export class BlockedQueryDto extends PageQueryDto {}

// ---- people to meet ---------------------------------------------------------------------------------------

export class PeopleQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ format: 'uuid' })
  @IsOptional()
  @IsUUID()
  disciplineId?: string;

  @ApiPropertyOptional({ format: 'uuid', description: 'Only people who show their county to you.' })
  @IsOptional()
  @IsUUID()
  countyId?: string;

  @ApiPropertyOptional({ description: 'Only people Atarah has verified.' })
  @IsOptional()
  @Transform(flag)
  @IsBoolean()
  verified?: boolean;

  @ApiPropertyOptional({ description: 'Only people open to work (open to commissions).' })
  @IsOptional()
  @Transform(flag)
  @IsBoolean()
  available?: boolean;
}

export class PersonToMeetDto {
  @ApiProperty({
    type: CreativeCardDto,
    description: '`person.reason` is the line shown under the name.',
  })
  person!: CreativeCardDto;
  @ApiProperty({
    enum: ['NONE', 'PENDING_SENT'],
    enumName: 'PersonConnectionState',
    description: 'PENDING_SENT shows "Requested".',
  })
  connectionState!: string;
  @ApiProperty({
    type: String,
    format: 'uuid',
    nullable: true,
    description: 'Use it to cancel a sent request.',
  })
  connectionId!: string | null;
}
