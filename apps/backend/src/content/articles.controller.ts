import {
  Controller,
  Delete,
  Get,
  HttpCode,
  Param,
  ParseUUIDPipe,
  Put,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiParam, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { type AuthContext } from '../access/access.types';
import { CurrentAuth, OptionalAuth, RequiresPermission, Viewer } from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { ApiException } from '../common/api.exception';
import { Paged } from '../common/response-envelope.interceptor';
import { ArticlesService } from './articles.service';
import {
  ArticleCardDto,
  ArticleDto,
  ArticlesQueryDto,
  SAVED_TYPES,
  SavedArticleDto,
  SavedQueryDto,
} from './content.dto';

@ApiTags('Articles')
@ApiBearerAuth('access-token')
@Controller()
export class ArticlesController {
  constructor(private readonly articles: ArticlesService) {}

  @OptionalAuth()
  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiEnvelope(ArticleCardDto, { isArray: true })
  @Get('articles')
  async list(@Query() q: ArticlesQueryDto) {
    const { items, meta } = await this.articles.list(q);
    return new Paged(items, meta);
  }

  @OptionalAuth()
  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiEnvelope(ArticleDto)
  @Get('articles/:slug')
  detail(@Param('slug') slug: string, @Viewer() viewer?: AuthContext) {
    return this.articles.detail(slug.slice(0, 120), viewer?.userId);
  }

  // ---- saved items ----

  @RequiresPermission('saved.manage.own')
  @ApiEnvelope(SavedArticleDto, { isArray: true })
  @Get('me/saved')
  async saved(@CurrentAuth() auth: AuthContext, @Query() q: SavedQueryDto) {
    const { items, meta } = await this.articles.saved(auth.userId, q);
    return new Paged(items, meta);
  }

  @RequiresPermission('saved.manage.own')
  @HttpCode(204)
  @ApiParam({ name: 'type', enum: SAVED_TYPES })
  @Put('me/saved/:type/:id')
  async save(
    @CurrentAuth() auth: AuthContext,
    @Param('type') type: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    await this.articles.save(auth.userId, this.savedType(type), id);
  }

  @RequiresPermission('saved.manage.own')
  @HttpCode(204)
  @ApiParam({ name: 'type', enum: SAVED_TYPES })
  @Delete('me/saved/:type/:id')
  async unsave(
    @CurrentAuth() auth: AuthContext,
    @Param('type') type: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    await this.articles.unsave(auth.userId, this.savedType(type), id);
  }

  private savedType(type: string): 'ARTICLE' {
    if (type !== 'ARTICLE') {
      throw ApiException.validation('That cannot be saved yet.', { field: 'type' });
    }
    return type;
  }
}
