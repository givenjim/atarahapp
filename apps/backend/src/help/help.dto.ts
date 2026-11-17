import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsBoolean,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Length,
  Matches,
  Max,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';
import { LegalDocumentType } from '@prisma/client';
import { PageQueryDto } from '../common/pagination';
import { ArticleBlockInputDto, MAX_BLOCKS } from '../content/content.dto';

export const DRAFT_LABEL = 'DRAFT — pending legal review';

// ---- members ---------------------------------------------------------------------------------------------

export class HelpQueryDto {
  @ApiPropertyOptional({ maxLength: 80, description: 'Search the articles and the FAQ.' })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  q?: string;
}

export class HelpBlockDto {
  @ApiProperty({ enum: ['paragraph', 'heading', 'callout', 'quote'] }) type!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) text!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) title!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) attribution!: string | null;
}

export class HelpArticleCardDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() slug!: string;
  @ApiProperty() title!: string;
  @ApiProperty() summary!: string;
}

export class HelpArticleDto extends HelpArticleCardDto {
  @ApiProperty({ type: [HelpBlockDto] }) blocks!: HelpBlockDto[];
}

export class FaqDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() question!: string;
  @ApiProperty() answer!: string;
}

export class HelpResultDto {
  @ApiProperty({ type: [HelpArticleCardDto] }) articles!: HelpArticleCardDto[];
  @ApiProperty({ type: [FaqDto] }) faq!: FaqDto[];
}

export class HelpContactDto {
  @ApiProperty({ description: 'Where "Chat with us" sends the member: a support email.' })
  email!: string;
  @ApiProperty() note!: string;
}

export class LegalSummaryDto {
  @ApiProperty({ enum: LegalDocumentType, enumName: 'LegalDocumentType' }) type!: LegalDocumentType;
  @ApiProperty() title!: string;
  @ApiProperty() version!: string;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true })
  effectiveAt!: Date | null;
  @ApiProperty() isDraft!: boolean;
  @ApiPropertyOptional({
    type: String,
    nullable: true,
    description: 'Shown while the text is a draft.',
  })
  draftLabel!: string | null;
}

export class LegalFullDto extends LegalSummaryDto {
  @ApiProperty() body!: string;
}

// ---- staff -----------------------------------------------------------------------------------------------

const slugPattern = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;

export class HelpArticleFieldsDto {
  @ApiProperty({
    maxLength: 120,
    description: 'Lower-case words and dashes. Never changed after publishing.',
  })
  @IsString()
  @Length(3, 120)
  @Matches(slugPattern, { message: 'Use lower-case words separated by dashes.' })
  slug!: string;

  @ApiProperty({ maxLength: 140 }) @IsString() @Length(3, 140) title!: string;
  @ApiPropertyOptional({ maxLength: 300 })
  @IsOptional()
  @IsString()
  @MaxLength(300)
  summary?: string;

  @ApiPropertyOptional({
    type: [ArticleBlockInputDto],
    description: 'Paragraph, heading, callout and quote blocks.',
  })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(MAX_BLOCKS)
  @ValidateNested({ each: true })
  @Type(() => ArticleBlockInputDto)
  blocks?: ArticleBlockInputDto[];

  @ApiPropertyOptional() @IsOptional() @IsInt() @Min(0) @Max(10_000) sortOrder?: number;
  @ApiPropertyOptional() @IsOptional() @IsBoolean() published?: boolean;
}

export class UpdateHelpArticleDto {
  @ApiPropertyOptional() @IsOptional() @IsString() @Length(3, 140) title?: string;
  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(300) summary?: string;
  @ApiPropertyOptional({ type: [ArticleBlockInputDto] })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(MAX_BLOCKS)
  @ValidateNested({ each: true })
  @Type(() => ArticleBlockInputDto)
  blocks?: ArticleBlockInputDto[];
  @ApiPropertyOptional() @IsOptional() @IsInt() @Min(0) @Max(10_000) sortOrder?: number;
  @ApiPropertyOptional() @IsOptional() @IsBoolean() published?: boolean;
}

export class AdminHelpArticleDto extends HelpArticleDto {
  @ApiProperty() sortOrder!: number;
  @ApiProperty() published!: boolean;
  @ApiProperty({ type: String, format: 'date-time' }) updatedAt!: Date;
}

export class FaqFieldsDto {
  @ApiProperty({ maxLength: 200 }) @IsString() @Length(5, 200) question!: string;
  @ApiProperty({ maxLength: 2000 }) @IsString() @Length(5, 2000) answer!: string;
  @ApiPropertyOptional() @IsOptional() @IsInt() @Min(0) @Max(10_000) sortOrder?: number;
  @ApiPropertyOptional() @IsOptional() @IsBoolean() published?: boolean;
}

export class UpdateFaqDto {
  @ApiPropertyOptional() @IsOptional() @IsString() @Length(5, 200) question?: string;
  @ApiPropertyOptional() @IsOptional() @IsString() @Length(5, 2000) answer?: string;
  @ApiPropertyOptional() @IsOptional() @IsInt() @Min(0) @Max(10_000) sortOrder?: number;
  @ApiPropertyOptional() @IsOptional() @IsBoolean() published?: boolean;
}

export class AdminFaqDto extends FaqDto {
  @ApiProperty() sortOrder!: number;
  @ApiProperty() published!: boolean;
}

export class AdminListQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ maxLength: 80 }) @IsOptional() @IsString() @MaxLength(80) q?: string;
}

export class NewLegalVersionDto {
  @ApiProperty({ enum: LegalDocumentType, enumName: 'LegalDocumentType' })
  @IsEnum(LegalDocumentType)
  type!: LegalDocumentType;

  @ApiProperty({ maxLength: 20, example: '2026.2' })
  @IsString()
  @Length(1, 20)
  @Matches(/^[A-Za-z0-9._-]+$/)
  version!: string;

  @ApiProperty({ maxLength: 120 }) @IsString() @Length(3, 120) title!: string;
  @ApiProperty({ description: 'The full text.' }) @IsString() @Length(20, 200_000) body!: string;
}

export class UpdateLegalDraftDto {
  @ApiPropertyOptional() @IsOptional() @IsString() @Length(3, 120) title?: string;
  @ApiPropertyOptional() @IsOptional() @IsString() @Length(20, 200_000) body?: string;
}

export class PublishLegalDto {
  @ApiPropertyOptional({
    type: String,
    format: 'date-time',
    description: 'When it takes effect. Defaults to now.',
  })
  @IsOptional()
  @IsString()
  effectiveAt?: string;
}

export class AdminLegalDto extends LegalFullDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ enum: ['DRAFT', 'IN_REVIEW', 'PUBLISHED', 'ARCHIVED'] }) status!: string;
  @ApiProperty({ type: String, format: 'date-time' }) updatedAt!: Date;
}
