import { Module } from '@nestjs/common';
import { MediaModule } from '../media/media.module';
import { AdminArticlesController } from './admin-articles.controller';
import { AdminMediaController } from './admin-media.controller';
import { AdminArticlesService } from './admin-articles.service';
import { ArticlesController } from './articles.controller';
import { ArticlesService } from './articles.service';

/** Editorial content: articles, saved items and what admins pin on Home. */
@Module({
  imports: [MediaModule],
  controllers: [ArticlesController, AdminArticlesController, AdminMediaController],
  providers: [ArticlesService, AdminArticlesService],
  exports: [ArticlesService],
})
export class ContentModule {}
