import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsOptional, IsString, MaxLength } from 'class-validator';
import { PageQueryDto } from '../common/pagination';
import { ArticleCardDto } from '../content/content.dto';

/** Everything a member can save. LISTING and MENTOR arrive in Phase 2 and are refused until then. */
export const SAVED_KINDS = [
  'ARTICLE',
  'POST',
  'LEARNING',
  'CREATIVE',
  'OPPORTUNITY',
  'LISTING',
  'MENTOR',
] as const;
export type SavedKind = (typeof SAVED_KINDS)[number];
/** The kinds that can be saved today. */
export const BUILT_SAVED_KINDS: readonly SavedKind[] = [
  'ARTICLE',
  'POST',
  'LEARNING',
  'CREATIVE',
  'OPPORTUNITY',
  'LISTING',
];
export const MAX_COLLECTION = 40;

export class SavedQueryDto extends PageQueryDto {
  @ApiPropertyOptional({
    enum: SAVED_KINDS,
    enumName: 'SavedKind',
    description: 'Only this kind. Omit for everything.',
  })
  @IsOptional()
  @IsEnum(SAVED_KINDS)
  type?: SavedKind;

  @ApiPropertyOptional({ maxLength: MAX_COLLECTION, description: 'Only this collection.' })
  @IsOptional()
  @IsString()
  @MaxLength(MAX_COLLECTION)
  collection?: string;
}

export class SaveBodyDto {
  @ApiPropertyOptional({
    maxLength: MAX_COLLECTION,
    description: 'File it under this collection. Empty clears it.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(MAX_COLLECTION)
  collection?: string;
}

/** One row of the Saved screen, whatever its kind. */
export class SavedItemDto {
  @ApiProperty({ enum: SAVED_KINDS, enumName: 'SavedKind' }) type!: SavedKind;
  @ApiProperty({ description: 'Id of the saved thing (a creative is saved by profile id).' })
  targetId!: string;
  @ApiProperty({ type: String, format: 'date-time' }) savedAt!: Date;
  @ApiPropertyOptional({ type: String, nullable: true }) collection!: string | null;
  @ApiProperty() title!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) subtitle!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) imageUrl!: string | null;
  @ApiProperty({ description: 'The in-app path that opens it.' }) path!: string;
  @ApiPropertyOptional({
    type: ArticleCardDto,
    nullable: true,
    description: 'Present for ARTICLE rows.',
  })
  article!: ArticleCardDto | null;
}

export class SavedCountsDto {
  @ApiProperty() total!: number;
  @ApiProperty({
    type: 'object',
    additionalProperties: { type: 'number' },
    description: 'Per kind.',
  })
  byType!: Record<string, number>;
}
