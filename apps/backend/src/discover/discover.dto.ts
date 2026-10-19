import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  IsBoolean,
  IsIn,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  MinLength,
} from 'class-validator';
import { PageQueryDto } from '../common/pagination';
import { ArticleCardDto } from '../content/content.dto';
import { DisciplineLite } from '../creative/creative.dto';

export const CREATIVE_SORTS = ['relevance', 'recent'] as const;
/** Everything search can return. Types without a built feature yet return no group. */
export const SEARCH_TYPES = [
  'creatives',
  'articles',
  'opportunities',
  'learning',
  'marketplace',
  'mentors',
] as const;
export type SearchType = (typeof SEARCH_TYPES)[number];
/** The types that exist today. */
export const BUILT_SEARCH_TYPES: readonly SearchType[] = ['creatives', 'articles'];

export const MAX_QUERY = 80;
export const MIN_QUERY = 2;
export const GROUP_PREVIEW = 3;
export const MAX_RECENT = 10;

const flag = ({ value }: { value: unknown }) =>
  value === true || value === 'true' || value === '1'
    ? true
    : value === false || value === 'false' || value === '0'
      ? false
      : value;

// ---- creatives --------------------------------------------------------------------------------------------

export class CreativesQueryDto extends PageQueryDto {
  @ApiPropertyOptional({
    maxLength: MAX_QUERY,
    description: 'Name, headline, discipline or skill.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(MAX_QUERY)
  q?: string;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsOptional()
  @IsUUID()
  disciplineId?: string;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsOptional()
  @IsUUID()
  specialisationId?: string;

  @ApiPropertyOptional({
    format: 'uuid',
    description: 'Only people who chose to show their county to you.',
  })
  @IsOptional()
  @IsUUID()
  countyId?: string;

  @ApiPropertyOptional({ description: 'Only people open to commissions.' })
  @IsOptional()
  @Transform(flag)
  @IsBoolean()
  available?: boolean;

  @ApiPropertyOptional({ description: 'Only people Atarah has verified.' })
  @IsOptional()
  @Transform(flag)
  @IsBoolean()
  verified?: boolean;

  @ApiPropertyOptional({ enum: CREATIVE_SORTS, default: 'relevance' })
  @IsOptional()
  @IsIn(CREATIVE_SORTS)
  sort?: (typeof CREATIVE_SORTS)[number];
}

export class CreativeCardDto {
  @ApiProperty() handle!: string;
  @ApiProperty() displayName!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) headline!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) avatarUrl!: string | null;
  @ApiPropertyOptional({ type: DisciplineLite, nullable: true })
  discipline!: DisciplineLite | null;
  @ApiProperty({
    type: [String],
    description: 'Up to three skills, only when the member shows them.',
  })
  tags!: string[];
  @ApiPropertyOptional({
    type: String,
    nullable: true,
    description: 'County, only when the member shows it to you.',
  })
  location!: string | null;
  @ApiProperty({ description: 'Verified by Atarah.' }) verified!: boolean;
  @ApiProperty() openToCommissions!: boolean;
  @ApiPropertyOptional({
    type: String,
    nullable: true,
    description: 'Why this person is suggested.',
  })
  reason!: string | null;
}

// ---- search -----------------------------------------------------------------------------------------------

export class SearchQueryDto extends PageQueryDto {
  @ApiProperty({ minLength: MIN_QUERY, maxLength: MAX_QUERY })
  @IsString()
  @MaxLength(MAX_QUERY)
  q!: string;

  @ApiPropertyOptional({
    enum: SEARCH_TYPES,
    description: 'One kind of result, paged. Leave out for every kind, three each.',
  })
  @IsOptional()
  @IsIn(SEARCH_TYPES)
  type?: SearchType;
}

export class SearchHitDto {
  @ApiProperty({ enum: SEARCH_TYPES }) type!: string;
  @ApiProperty() id!: string;
  @ApiProperty() title!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) subtitle!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) imageUrl!: string | null;
  @ApiProperty({ description: 'Verified by Atarah.' }) verified!: boolean;
  @ApiProperty({ description: 'In-app route that opens it.' }) path!: string;
}

export class SearchGroupDto {
  @ApiProperty({ enum: SEARCH_TYPES }) type!: string;
  @ApiProperty({ description: 'How many results there are in all.' }) count!: number;
  @ApiProperty({ type: [SearchHitDto] }) items!: SearchHitDto[];
}

export class SearchResultDto {
  @ApiProperty() query!: string;
  @ApiProperty({
    type: [SearchGroupDto],
    description:
      'One group per kind that exists today. A kind with no results has a count of zero.',
  })
  groups!: SearchGroupDto[];
}

export class RecentSearchDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() query!: string;
}

export class RecordSearchDto {
  @ApiProperty({ minLength: MIN_QUERY, maxLength: MAX_QUERY })
  @IsString()
  @MinLength(1)
  @MaxLength(MAX_QUERY)
  query!: string;
}

// ---- home -------------------------------------------------------------------------------------------------

export const HOME_SECTIONS = ['recommended', 'creatives', 'article'] as const;

export class RecommendationDto {
  @ApiProperty({
    enum: ['ARTICLE'],
    description: 'More kinds join as opportunities and Skill Labs arrive.',
  })
  type!: string;
  @ApiProperty() id!: string;
  @ApiProperty() title!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) subtitle!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) imageUrl!: string | null;
  @ApiProperty({ description: 'In-app route that opens it.' }) path!: string;
  @ApiProperty({ description: 'Why it is suggested, e.g. "Because you selected Animation".' })
  reason!: string;
}

export class HomeDto {
  @ApiProperty() firstName!: string;
  @ApiProperty({ minimum: 0, maximum: 100 }) completionPercent!: number;
  @ApiProperty() unreadNotifications!: number;
  @ApiPropertyOptional({
    type: ArticleCardDto,
    nullable: true,
    description: 'The pinned article, else the newest.',
  })
  article!: ArticleCardDto | null;
  @ApiProperty({ type: [RecommendationDto] }) recommended!: RecommendationDto[];
  @ApiProperty({ type: [CreativeCardDto] }) creatives!: CreativeCardDto[];
  @ApiProperty({
    type: [String],
    enum: HOME_SECTIONS,
    description: 'Sections that could not be loaded this time. The client hides them.',
  })
  unavailable!: string[];
}
