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
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { type AuthContext } from '../access/access.types';
import { CurrentAuth, RequiresPermission } from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { Paged } from '../common/response-envelope.interceptor';
import {
  CategoryQueryDto,
  EnrolmentDto,
  LearningCardDto,
  LearningDetailDto,
  LearningHubDto,
  LearningItemProgressDto,
  LearningSearchQueryDto,
  LearningStatsDto,
  LessonDto,
  LessonProgressBodyDto,
  LessonVideoDto,
  MyLearningItemDto,
  MyLearningQueryDto,
  ProgressResultDto,
} from './learning.dto';
import { LearningService } from './learning.service';
import { LessonService } from './lesson.service';

/** Skill Labs for members. Needs `learning.browse` (a member default). */
@ApiTags('Learning')
@ApiBearerAuth('access-token')
@RequiresPermission('learning.browse')
@Controller()
export class LearningController {
  constructor(
    private readonly learning: LearningService,
    private readonly lessons: LessonService,
  ) {}

  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiEnvelope(LearningHubDto)
  @Get('learning')
  hub(@CurrentAuth() auth: AuthContext) {
    return this.learning.hub(auth.userId);
  }

  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiEnvelope(LearningCardDto, { isArray: true })
  @Get('learning/search')
  async search(@CurrentAuth() auth: AuthContext, @Query() q: LearningSearchQueryDto) {
    const { items, meta } = await this.learning.search(auth.userId, q);
    return new Paged(items, meta);
  }

  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiEnvelope(LearningCardDto, {
    isArray: true,
    description: 'meta.category and meta.types describe the category.',
  })
  @Get('learning/categories/:slug')
  async category(
    @CurrentAuth() auth: AuthContext,
    @Param('slug') slug: string,
    @Query() q: CategoryQueryDto,
  ) {
    const { page, items, meta } = await this.learning.category(auth.userId, slug.slice(0, 80), q);
    return new Paged(items, {
      ...meta,
      category: page.category,
      total_all: page.total,
      types: page.types,
    });
  }

  // Fixed paths before `learning/:id`.
  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiEnvelope(LessonDto)
  @Get('learning/lessons/:id')
  lesson(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.lessons.get(auth.userId, id);
  }

  @Throttle({ default: { limit: 60, ttl: 60_000 } })
  @ApiEnvelope(LessonVideoDto)
  @Get('learning/lessons/:id/video')
  video(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.lessons.video(auth.userId, id);
  }

  @Throttle({ default: { limit: 240, ttl: 60_000 } })
  @ApiEnvelope(ProgressResultDto)
  @Put('learning/lessons/:id/progress')
  progress(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: LessonProgressBodyDto,
  ) {
    return this.lessons.progress(auth.userId, id, dto);
  }

  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiEnvelope(LearningDetailDto)
  @Get('learning/:id')
  detail(@CurrentAuth() auth: AuthContext, @Param('id') id: string) {
    return this.learning.detail(auth.userId, id.slice(0, 120));
  }

  @Throttle({ default: { limit: 30, ttl: 60_000 } })
  @HttpCode(200)
  @ApiEnvelope(EnrolmentDto)
  @Post('learning/:id/enrol')
  enrol(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.learning.enrol(auth.userId, id);
  }

  @Throttle({ default: { limit: 60, ttl: 60_000 } })
  @HttpCode(200)
  @ApiEnvelope(LearningItemProgressDto)
  @Post('learning/:id/start')
  start(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.learning.start(auth.userId, id);
  }

  @Throttle({ default: { limit: 60, ttl: 60_000 } })
  @HttpCode(200)
  @ApiEnvelope(LearningItemProgressDto)
  @Post('learning/:id/complete')
  complete(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.learning.completeItem(auth.userId, id);
  }

  @Throttle({ default: { limit: 60, ttl: 60_000 } })
  @HttpCode(204)
  @Put('learning/:id/save')
  async save(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    await this.learning.save(auth.userId, id);
  }

  @Throttle({ default: { limit: 60, ttl: 60_000 } })
  @HttpCode(204)
  @Delete('learning/:id/save')
  async unsave(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    await this.learning.unsave(auth.userId, id);
  }

  @ApiEnvelope(MyLearningItemDto, { isArray: true })
  @Get('me/learning')
  async mine(@CurrentAuth() auth: AuthContext, @Query() q: MyLearningQueryDto) {
    const { items, meta } = await this.learning.mine(auth.userId, q);
    return new Paged(items, meta);
  }

  @ApiEnvelope(LearningStatsDto)
  @Get('me/learning/stats')
  stats(@CurrentAuth() auth: AuthContext) {
    return this.learning.stats(auth.userId);
  }
}
