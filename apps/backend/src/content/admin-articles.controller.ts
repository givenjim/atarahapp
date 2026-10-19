import {
  Body,
  Controller,
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
import { type AuthContext } from '../access/access.types';
import { ClientIp, CurrentAuth, RequestIdParam, RequiresPermission } from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { Paged } from '../common/response-envelope.interceptor';
import { AdminArticlesService } from './admin-articles.service';
import {
  AdminArticleDto,
  AdminArticleListItemDto,
  AdminArticlesQueryDto,
  CreateArticleDto,
  HomeConfigDto,
  PublishArticleDto,
  SetHomeConfigDto,
  UpdateArticleDto,
} from './content.dto';

@ApiTags('Admin Content')
@ApiBearerAuth('access-token')
@RequiresPermission('admin.access', 'article.manage')
@Controller('admin')
export class AdminArticlesController {
  constructor(private readonly admin: AdminArticlesService) {}

  private actor(auth: AuthContext, ip?: string, requestId?: string) {
    return { userId: auth.userId, ip, requestId };
  }

  @ApiEnvelope(AdminArticleListItemDto, { isArray: true })
  @Get('articles')
  async list(@Query() q: AdminArticlesQueryDto) {
    const { items, meta } = await this.admin.list(q);
    return new Paged(items, meta);
  }

  @HttpCode(201)
  @ApiEnvelope(AdminArticleDto, { status: 201 })
  @Post('articles')
  create(
    @CurrentAuth() auth: AuthContext,
    @Body() dto: CreateArticleDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.create(this.actor(auth, ip, requestId), dto);
  }

  @ApiEnvelope(AdminArticleDto)
  @Get('articles/:id')
  get(@Param('id', ParseUUIDPipe) id: string) {
    return this.admin.get(id);
  }

  @ApiEnvelope(AdminArticleDto)
  @Patch('articles/:id')
  update(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateArticleDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.update(this.actor(auth, ip, requestId), id, dto);
  }

  @HttpCode(200)
  @ApiEnvelope(AdminArticleDto)
  @Post('articles/:id/submit')
  submit(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.submit(this.actor(auth, ip, requestId), id);
  }

  @HttpCode(200)
  @ApiEnvelope(AdminArticleDto)
  @Post('articles/:id/return')
  returnToDraft(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.returnToDraft(this.actor(auth, ip, requestId), id);
  }

  @HttpCode(200)
  @ApiEnvelope(AdminArticleDto)
  @Post('articles/:id/publish')
  publish(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: PublishArticleDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.publish(this.actor(auth, ip, requestId), id, dto.publishAt);
  }

  @HttpCode(200)
  @ApiEnvelope(AdminArticleDto)
  @Post('articles/:id/archive')
  archive(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.archive(this.actor(auth, ip, requestId), id);
  }

  @HttpCode(200)
  @ApiEnvelope(AdminArticleDto)
  @Post('articles/:id/restore')
  restore(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.restore(this.actor(auth, ip, requestId), id);
  }

  @ApiEnvelope(HomeConfigDto)
  @Get('home')
  homeConfig() {
    return this.admin.homeConfig();
  }

  @ApiEnvelope(HomeConfigDto)
  @Put('home')
  setHomeConfig(
    @CurrentAuth() auth: AuthContext,
    @Body() dto: SetHomeConfigDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.setHomeConfig(this.actor(auth, ip, requestId), dto.featuredArticleId ?? null);
  }
}
