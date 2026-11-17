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
import { ApiBearerAuth, ApiProperty, ApiTags } from '@nestjs/swagger';
import { type AuthContext } from '../access/access.types';
import {
  ClientIp,
  CurrentAuth,
  RequestIdParam,
  RequiresPermission,
  RequiresRecentAuth,
} from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { Paged } from '../common/response-envelope.interceptor';
import { AdminLearningService } from './admin-learning.service';
import {
  AdminCategoryDto,
  AdminContentDto,
  AdminContentsQueryDto,
  CategoryFieldsDto,
  ContentFieldsDto,
  LearningAnalyticsDto,
  LessonFieldsDto,
  ProgressOverrideDto,
  ReorderLessonsDto,
  UpdateCategoryDto,
  UpdateContentDto,
  UpdateLessonDto,
} from './learning.dto';

class OverrideResultDto {
  @ApiProperty() ok!: boolean;
  @ApiProperty() courseCompleted!: boolean;
}

class EmbedHostsDto {
  @ApiProperty({ type: [String] }) hosts!: string[];
}

/** The learning CMS under /api/v1/admin. Every route needs `admin.access` and `learning.manage`. */
@ApiTags('Admin learning')
@ApiBearerAuth('access-token')
@RequiresPermission('admin.access', 'learning.manage')
@Controller('admin')
export class AdminLearningController {
  constructor(private readonly admin: AdminLearningService) {}

  @ApiEnvelope(EmbedHostsDto)
  @Get('learning/embed-hosts')
  async hosts() {
    return { hosts: await this.admin.embedHosts() };
  }

  @ApiEnvelope(AdminCategoryDto, { isArray: true })
  @Get('learning/categories')
  categories() {
    return this.admin.listCategories();
  }

  @ApiEnvelope(AdminCategoryDto, { status: 201 })
  @Post('learning/categories')
  createCategory(
    @CurrentAuth() auth: AuthContext,
    @Body() dto: CategoryFieldsDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.createCategory({ userId: auth.userId, ip, requestId }, dto);
  }

  @ApiEnvelope(AdminCategoryDto)
  @Patch('learning/categories/:id')
  updateCategory(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateCategoryDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.updateCategory({ userId: auth.userId, ip, requestId }, id, dto);
  }

  // Fixed paths before `learning/contents/:id`.
  @ApiEnvelope(LearningAnalyticsDto)
  @Get('learning/analytics')
  analytics() {
    return this.admin.analytics();
  }

  @RequiresRecentAuth()
  @HttpCode(200)
  @ApiEnvelope(OverrideResultDto)
  @Post('learning/progress-overrides')
  progressOverride(
    @CurrentAuth() auth: AuthContext,
    @Body() dto: ProgressOverrideDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.progressOverride({ userId: auth.userId, ip, requestId }, dto);
  }

  @ApiEnvelope(AdminContentDto, { isArray: true })
  @Get('learning/contents')
  async list(@Query() q: AdminContentsQueryDto) {
    const { items, meta } = await this.admin.list(q);
    return new Paged(items, meta);
  }

  @ApiEnvelope(AdminContentDto)
  @Get('learning/contents/:id')
  get(@Param('id', ParseUUIDPipe) id: string) {
    return this.admin.get(id);
  }

  @ApiEnvelope(AdminContentDto, { status: 201 })
  @Post('learning/contents')
  create(
    @CurrentAuth() auth: AuthContext,
    @Body() dto: ContentFieldsDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.create({ userId: auth.userId, ip, requestId }, dto);
  }

  @ApiEnvelope(AdminContentDto)
  @Patch('learning/contents/:id')
  update(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateContentDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.update({ userId: auth.userId, ip, requestId }, id, dto);
  }

  @HttpCode(200)
  @ApiEnvelope(AdminContentDto)
  @Post('learning/contents/:id/publish')
  publish(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.publish({ userId: auth.userId, ip, requestId }, id);
  }

  @HttpCode(200)
  @ApiEnvelope(AdminContentDto)
  @Post('learning/contents/:id/unpublish')
  unpublish(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.setStatus({ userId: auth.userId, ip, requestId }, id, 'DRAFT');
  }

  @HttpCode(200)
  @ApiEnvelope(AdminContentDto)
  @Post('learning/contents/:id/archive')
  archive(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.setStatus({ userId: auth.userId, ip, requestId }, id, 'ARCHIVED');
  }

  // ---- lessons of a course (the content id of the course) ----

  @ApiEnvelope(AdminContentDto, { status: 201 })
  @Post('courses/:id/lessons')
  addLesson(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: LessonFieldsDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.addLesson({ userId: auth.userId, ip, requestId }, id, dto);
  }

  @ApiEnvelope(AdminContentDto)
  @Put('courses/:id/lessons/order')
  reorder(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ReorderLessonsDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.reorder({ userId: auth.userId, ip, requestId }, id, dto);
  }

  @ApiEnvelope(AdminContentDto)
  @Patch('courses/:id/lessons/:lessonId')
  updateLesson(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Param('lessonId', ParseUUIDPipe) lessonId: string,
    @Body() dto: UpdateLessonDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.updateLesson({ userId: auth.userId, ip, requestId }, id, lessonId, dto);
  }

  @ApiEnvelope(AdminContentDto)
  @Delete('courses/:id/lessons/:lessonId')
  deleteLesson(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Param('lessonId', ParseUUIDPipe) lessonId: string,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.deleteLesson({ userId: auth.userId, ip, requestId }, id, lessonId);
  }
}
