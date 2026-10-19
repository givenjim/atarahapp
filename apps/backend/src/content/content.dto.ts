import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsEnum,
  IsIn,
  IsISO8601,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  ValidateNested,
} from 'class-validator';
import { PageQueryDto } from '../common/pagination';

export const ARTICLE_STATUSES = ['DRAFT', 'IN_REVIEW', 'PUBLISHED', 'ARCHIVED'] as const;
export const CONTENT_SOURCES = ['ATARAH', 'PARTNER', 'EXTERNAL'] as const;
export const BLOCK_TYPES = ['paragraph', 'heading', 'callout', 'image', 'quote'] as const;
export const SAVED_TYPES = ['ARTICLE'] as const;

export const MAX_ARTICLE_TITLE = 140;
export const MAX_ARTICLE_SUMMARY = 300;
export const MAX_BLOCKS = 200;
export const MAX_BLOCK_TEXT = 5000;
export const MAX_ARTICLE_TAGS = 8;

// ---- article blocks ---------------------------------------------------------------------------------------

export class ArticleBlockInputDto {
  @ApiProperty({ enum: BLOCK_TYPES })
  @IsIn(BLOCK_TYPES)
  type!: (typeof BLOCK_TYPES)[number];

  @ApiPropertyOptional({
    maxLength: MAX_BLOCK_TEXT,
    description: 'The words of a paragraph, heading, callout or quote.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(MAX_BLOCK_TEXT)
  text?: string;

  @ApiPropertyOptional({
    maxLength: 60,
    description: 'Callout heading, such as "Rule of thumb".',
  })
  @IsOptional()
  @IsString()
  @MaxLength(60)
  title?: string;

  @ApiPropertyOptional({
    format: 'uuid',
    description: 'An image block: a PUBLIC image you uploaded.',
  })
  @IsOptional()
  @IsUUID()
  mediaId?: string;

  @ApiPropertyOptional({ maxLength: 200 })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  caption?: string;

  @ApiPropertyOptional({ maxLength: 120, description: 'Who said it, for a quote.' })
  @IsOptional()
  @IsString()
  @MaxLength(120)
  attribution?: string;
}

export class ArticleBlockDto {
  @ApiProperty({ enum: BLOCK_TYPES }) type!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) text!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) title!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true, description: 'Signed image URL.' })
  imageUrl!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) caption!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) attribution!: string | null;
}

export class AdminArticleBlockDto extends ArticleBlockDto {
  @ApiPropertyOptional({ type: String, format: 'uuid', nullable: true })
  mediaId!: string | null;
}

// ---- articles (members and visitors) ----------------------------------------------------------------------

export class ArticlesQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ description: 'Only articles with this tag.' })
  @IsOptional()
  @IsString()
  @MaxLength(60)
  tag?: string;
}

export class ArticleCardDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() slug!: string;
  @ApiProperty() title!: string;
  @ApiProperty() summary!: string;
  @ApiProperty({ enum: CONTENT_SOURCES }) source!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) sourceLabel!: string | null;
  @ApiProperty() authorName!: string;
  @ApiProperty() readMinutes!: number;
  @ApiProperty({ type: String, format: 'date-time' }) publishedAt!: Date;
  @ApiPropertyOptional({ type: String, nullable: true }) heroUrl!: string | null;
  @ApiProperty({ type: [String] }) tags!: string[];
}

export class ArticleDto extends ArticleCardDto {
  @ApiProperty({ type: [ArticleBlockDto] }) blocks!: ArticleBlockDto[];
  @ApiProperty({ description: 'Whether the signed-in viewer saved it. False when signed out.' })
  saved!: boolean;
  @ApiProperty({ description: 'Public link to share.' }) shareUrl!: string;
}

// ---- saved items ------------------------------------------------------------------------------------------

export class SavedQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ enum: SAVED_TYPES, default: 'ARTICLE' })
  @IsOptional()
  @IsEnum(SAVED_TYPES)
  type?: (typeof SAVED_TYPES)[number];
}

export class SavedArticleDto {
  @ApiProperty({ type: String, format: 'date-time' }) savedAt!: Date;
  @ApiProperty({ type: ArticleCardDto }) article!: ArticleCardDto;
}

// ---- admin ------------------------------------------------------------------------------------------------

export class AdminArticlesQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ enum: ARTICLE_STATUSES })
  @IsOptional()
  @IsEnum(ARTICLE_STATUSES)
  status?: (typeof ARTICLE_STATUSES)[number];

  @ApiPropertyOptional({ description: 'Title or byline contains.' })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  q?: string;
}

export class CreateArticleDto {
  @ApiProperty({ maxLength: MAX_ARTICLE_TITLE })
  @IsString()
  @MaxLength(MAX_ARTICLE_TITLE)
  title!: string;

  @ApiProperty({ maxLength: 120, description: 'The byline.' })
  @IsString()
  @MaxLength(120)
  authorName!: string;
}

export class UpdateArticleDto {
  @ApiPropertyOptional({ maxLength: MAX_ARTICLE_TITLE })
  @IsOptional()
  @IsString()
  @MaxLength(MAX_ARTICLE_TITLE)
  title?: string;

  @ApiPropertyOptional({ maxLength: MAX_ARTICLE_SUMMARY })
  @IsOptional()
  @IsString()
  @MaxLength(MAX_ARTICLE_SUMMARY)
  summary?: string;

  @ApiPropertyOptional({ maxLength: 120 })
  @IsOptional()
  @IsString()
  @MaxLength(120)
  authorName?: string;

  @ApiPropertyOptional({ enum: CONTENT_SOURCES })
  @IsOptional()
  @IsEnum(CONTENT_SOURCES)
  source?: (typeof CONTENT_SOURCES)[number];

  @ApiPropertyOptional({ maxLength: 80, description: 'Who it came from. Empty clears it.' })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  sourceLabel?: string;

  @ApiPropertyOptional({
    format: 'uuid',
    description: 'A PUBLIC image you uploaded. Send an empty string to remove it.',
  })
  @IsOptional()
  @IsString()
  heroMediaId?: string;

  @ApiPropertyOptional({ type: [String], maxItems: MAX_ARTICLE_TAGS })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(MAX_ARTICLE_TAGS)
  @IsString({ each: true })
  @MaxLength(40, { each: true })
  tags?: string[];

  @ApiPropertyOptional({ type: [ArticleBlockInputDto], maxItems: MAX_BLOCKS })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(MAX_BLOCKS)
  @ValidateNested({ each: true })
  @Type(() => ArticleBlockInputDto)
  blocks?: ArticleBlockInputDto[];
}

export class PublishArticleDto {
  @ApiPropertyOptional({
    type: String,
    format: 'date-time',
    description: 'Go live at this time. Leave out to publish now.',
  })
  @IsOptional()
  @IsISO8601()
  publishAt?: string;
}

export class AdminArticleListItemDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() slug!: string;
  @ApiProperty() title!: string;
  @ApiProperty() authorName!: string;
  @ApiProperty({ enum: ARTICLE_STATUSES }) status!: string;
  @ApiProperty({ enum: CONTENT_SOURCES }) source!: string;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true })
  publishedAt!: Date | null;
  @ApiProperty({ description: 'Published with a time that has not come yet.' })
  scheduled!: boolean;
  @ApiProperty({ description: 'Pinned on Home.' }) featured!: boolean;
  @ApiProperty({ type: String, format: 'date-time' }) updatedAt!: Date;
}

export class AdminArticleDto extends AdminArticleListItemDto {
  @ApiProperty() summary!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) sourceLabel!: string | null;
  @ApiProperty() readMinutes!: number;
  @ApiProperty({ type: [String] }) tags!: string[];
  @ApiPropertyOptional({ type: String, format: 'uuid', nullable: true })
  heroMediaId!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) heroUrl!: string | null;
  @ApiProperty({ type: [AdminArticleBlockDto] }) blocks!: AdminArticleBlockDto[];
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
}

export class HomeConfigDto {
  @ApiPropertyOptional({ type: String, format: 'uuid', nullable: true })
  featuredArticleId!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) featuredArticleTitle!: string | null;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true })
  updatedAt!: Date | null;
}

export class SetHomeConfigDto {
  @ApiPropertyOptional({
    type: String,
    format: 'uuid',
    nullable: true,
    description: 'A published article. Null un-pins.',
  })
  @IsOptional()
  @IsUUID()
  featuredArticleId?: string | null;
}
