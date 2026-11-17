import {
  Controller,
  Get,
  Param,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { type AuthContext } from '../access/access.types';
import { OptionalAuth, Viewer } from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { Paged } from '../common/response-envelope.interceptor';
import { ArticlesService } from './articles.service';
import {
  ArticleCardDto,
  ArticleDto,
  ArticlesQueryDto,
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
}
