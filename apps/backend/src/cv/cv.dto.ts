import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { CreativeDocumentFormat, ProfileSection, Visibility } from '@prisma/client';
import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsEnum,
  IsInt,
  IsOptional,
  IsUUID,
  Max,
  Min,
} from 'class-validator';

export const MAX_CV_PROJECTS = 12;
export const MAX_SHARE_DAYS = 365;

// ---- requests ----------------------------------------------------------------------------------------------------

/** Every field is optional; what is sent replaces the stored choice. */
export class UpdateCvDto {
  @ApiPropertyOptional({ enum: ProfileSection, isArray: true })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(10)
  @IsEnum(ProfileSection, { each: true })
  sections?: ProfileSection[];

  @ApiPropertyOptional({
    type: [String],
    description: 'The member’s own published projects to list.',
  })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(MAX_CV_PROJECTS)
  @IsUUID('all', { each: true })
  projectIds?: string[];

  @ApiPropertyOptional({
    enum: ProfileSection,
    isArray: true,
    description:
      'Sections that are not public (members only or private) that the member explicitly allows into this document.',
  })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(10)
  @IsEnum(ProfileSection, { each: true })
  restricted?: ProfileSection[];
}

export class CreateShareDto {
  @ApiPropertyOptional({
    description: 'The link stops working after this many days. Omit for no expiry.',
    minimum: 1,
    maximum: MAX_SHARE_DAYS,
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(MAX_SHARE_DAYS)
  expiresInDays?: number;
}

// ---- responses ---------------------------------------------------------------------------------------------------

export class CvFormatInfoDto {
  @ApiProperty({ enum: CreativeDocumentFormat }) format!: CreativeDocumentFormat;
  @ApiProperty() label!: string;
  @ApiProperty({ enum: ProfileSection, isArray: true }) allowedSections!: ProfileSection[];
  @ApiProperty({ enum: ProfileSection, isArray: true }) defaultSections!: ProfileSection[];
  @ApiProperty({
    description: 'The most projects the layout lists (0 means the format lists none).',
  })
  maxProjects!: number;
}

export class CvConfigDto {
  @ApiProperty({ enum: ProfileSection, isArray: true }) sections!: ProfileSection[];
  @ApiProperty({ type: [String] }) projectIds!: string[];
  @ApiProperty({ enum: ProfileSection, isArray: true }) restricted!: ProfileSection[];
}

export class CvSectionAudienceDto {
  @ApiProperty({ enum: ProfileSection }) section!: ProfileSection;
  @ApiProperty({ enum: Visibility }) visibility!: Visibility;
  @ApiProperty({ description: 'Whether the member may include it in this format at all.' })
  available!: boolean;
}

export class CvProjectChoiceDto {
  @ApiProperty() id!: string;
  @ApiProperty() title!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) role!: string | null;
  @ApiPropertyOptional({ type: Number, nullable: true }) year!: number | null;
  @ApiProperty({ enum: Visibility }) visibility!: Visibility;
}

export class CvPreviewSkillDto {
  @ApiProperty() name!: string;
  @ApiProperty({ description: 'True only when Atarah has verified this skill.' })
  verified!: boolean;
}

export class CvPreviewWorkDto {
  @ApiProperty() title!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) role!: string | null;
  @ApiPropertyOptional({ type: Number, nullable: true }) year!: number | null;
}

/** The in-app preview card: exactly what the output will contain after visibility filtering. */
export class CvPreviewDto {
  @ApiProperty() displayName!: string;
  @ApiProperty({ description: 'The format label shown under the name, e.g. "Creative CV".' })
  subtitle!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) avatarUrl!: string | null;
  @ApiProperty() identityVerified!: boolean;
  @ApiPropertyOptional({ type: String, nullable: true }) summary!: string | null;
  @ApiProperty({ type: [CvPreviewWorkDto] }) work!: CvPreviewWorkDto[];
  @ApiProperty({ type: [CvPreviewSkillDto] }) skills!: CvPreviewSkillDto[];
  @ApiProperty({ enum: ProfileSection, isArray: true }) included!: ProfileSection[];
  @ApiProperty({
    enum: ProfileSection,
    isArray: true,
    description: 'Picked sections left out because they are not public and not explicitly allowed.',
  })
  withheld!: ProfileSection[];
}

export class CvRenderDto {
  @ApiProperty() id!: string;
  @ApiProperty({ enum: ['QUEUED', 'PROCESSING', 'READY', 'FAILED'] }) status!: string;
  @ApiProperty() requestedAt!: Date;
  @ApiPropertyOptional({ type: Date, nullable: true }) readyAt!: Date | null;
  @ApiPropertyOptional({
    type: String,
    nullable: true,
    description: 'Plain-language reason when FAILED.',
  })
  error!: string | null;
}

export class CvDownloadDto {
  @ApiProperty({ description: 'Signed link to the private PDF; it works for a few minutes.' })
  url!: string;
  @ApiProperty() expiresAt!: Date;
}

export class CvShareDto {
  @ApiProperty() id!: string;
  @ApiProperty({
    description:
      'Last characters of the token, to tell links apart. The full link is shown only once.',
  })
  hint!: string;
  @ApiProperty() createdAt!: Date;
  @ApiPropertyOptional({ type: Date, nullable: true }) expiresAt!: Date | null;
  @ApiPropertyOptional({ type: Date, nullable: true }) revokedAt!: Date | null;
  @ApiProperty({ enum: ['ACTIVE', 'EXPIRED', 'REVOKED'] }) status!: string;
}

export class CvShareCreatedDto extends CvShareDto {
  @ApiProperty({
    description: 'The public link, `https://atarah.app/{handle}/cv/{token}`. Shown only now.',
  })
  url!: string;
}

export class CvStateDto {
  @ApiProperty({ type: CvFormatInfoDto }) info!: CvFormatInfoDto;
  @ApiProperty({ type: CvConfigDto }) config!: CvConfigDto;
  @ApiProperty({ type: [CvSectionAudienceDto] }) sections!: CvSectionAudienceDto[];
  @ApiProperty({
    type: [CvProjectChoiceDto],
    description: 'Published projects the member can list.',
  })
  projects!: CvProjectChoiceDto[];
  @ApiProperty({ type: CvPreviewDto }) preview!: CvPreviewDto;
  @ApiPropertyOptional({ type: CvRenderDto, nullable: true }) latestRender!: CvRenderDto | null;
  @ApiProperty({ type: [CvShareDto] }) shares!: CvShareDto[];
}

export class CvFormatsDto {
  @ApiProperty({ type: [CvFormatInfoDto] }) formats!: CvFormatInfoDto[];
}
