import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsDateString,
  IsEmail,
  IsEnum,
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';
import {
  VerificationBadgeEndReason,
  VerificationEvidenceType,
  VerificationReferenceStatus,
  VerificationStatus,
  VerificationSubjectType,
} from '@prisma/client';
import { PageQueryDto } from '../common/pagination';

const STATUS = { enum: VerificationStatus, enumName: 'VerificationStatus' } as const;
const SUBJECT = { enum: VerificationSubjectType, enumName: 'VerificationSubjectType' } as const;
const EVIDENCE = { enum: VerificationEvidenceType, enumName: 'VerificationEvidenceType' } as const;
const REF_STATUS = {
  enum: VerificationReferenceStatus,
  enumName: 'VerificationReferenceStatus',
} as const;

// ---- member ----

export class RequirementStateDto {
  @ApiProperty() key!: string;
  @ApiProperty() label!: string;
  @ApiProperty() description!: string;
  @ApiProperty({ description: 'How many items are needed.' }) minCount!: number;
  @ApiProperty({ description: 'How many are attached (capped at minCount).' }) count!: number;
  @ApiProperty() met!: boolean;
}

export class EvidenceItemDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty(EVIDENCE) type!: VerificationEvidenceType;
  @ApiPropertyOptional({ nullable: true, type: String }) label!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String, format: 'uuid' }) projectId!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String }) projectTitle!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String }) url!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String, format: 'uuid' }) referenceId!: string | null;
  @ApiProperty({
    nullable: true,
    type: String,
    description: 'For uploaded files: PENDING_UPLOAD, UPLOADED, PROCESSING, READY, REJECTED. Never a download address.',
  })
  fileStatus!: string | null;
  @ApiProperty({ description: 'The file was deleted under the retention rule.' }) purged!: boolean;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
}

export class ReferenceItemDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() name!: string;
  @ApiProperty({ description: 'Masked, for example "ab***@gmail.com".' }) emailMasked!: string;
  @ApiProperty() relationship!: string;
  @ApiProperty(REF_STATUS) status!: VerificationReferenceStatus;
  @ApiPropertyOptional({ nullable: true, type: String, format: 'date-time' }) sentAt!: Date | null;
}

export class TimelineStepDto {
  @ApiProperty({ enum: ['SUBMITTED', 'UNDER_REVIEW', 'DECISION'] }) key!: string;
  @ApiProperty() label!: string;
  @ApiProperty({ enum: ['done', 'current', 'upcoming'] }) state!: string;
  @ApiPropertyOptional({ nullable: true, type: String, format: 'date-time' }) at!: Date | null;
}

export class CaseViewDto {
  @ApiPropertyOptional({ nullable: true, type: String, format: 'uuid', description: 'Null until a draft is started.' })
  id!: string | null;
  @ApiProperty(SUBJECT) subjectType!: VerificationSubjectType;
  @ApiProperty({ format: 'uuid' }) subjectId!: string;
  @ApiProperty(STATUS) status!: VerificationStatus;
  @ApiProperty({ description: 'The member holds the Pro entitlement needed to submit.' }) entitled!: boolean;
  @ApiProperty({ description: 'The member may start a new application now.' }) canStart!: boolean;
  @ApiProperty({ description: 'Evidence can be added or removed now.' }) canEdit!: boolean;
  @ApiProperty({ description: 'Every requirement is met and the case can be submitted.' }) canSubmit!: boolean;
  @ApiProperty({ description: 'A reviewer asked for more information; add it and submit again.' }) needsInfo!: boolean;
  @ApiPropertyOptional({ nullable: true, type: String }) moreInfoNote!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String, description: 'Feedback from the reviewer after a rejection or revocation.' })
  feedback!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String, format: 'date-time' }) submittedAt!: Date | null;
  @ApiPropertyOptional({ nullable: true, type: String, format: 'date-time' }) decidedAt!: Date | null;
  @ApiPropertyOptional({ nullable: true, type: String, format: 'date-time' }) expiresAt!: Date | null;
  @ApiProperty({ description: 'The reviewer service level, in working days, from platform settings.' }) slaWorkingDays!: number;
  @ApiPropertyOptional({ nullable: true, type: String, format: 'date-time' }) slaDueAt!: Date | null;
  @ApiProperty({ type: [RequirementStateDto] }) requirements!: RequirementStateDto[];
  @ApiProperty({ type: [EvidenceItemDto] }) evidence!: EvidenceItemDto[];
  @ApiProperty({ type: [ReferenceItemDto] }) references!: ReferenceItemDto[];
  @ApiProperty({ type: [TimelineStepDto] }) timeline!: TimelineStepDto[];
}

export class VerificationOverviewDto {
  @ApiProperty({ type: CaseViewDto }) creative!: CaseViewDto;
  @ApiProperty({ description: 'The member holds the Pro entitlement for Verified Creative.' }) creativeEntitled!: boolean;
  @ApiProperty({ description: 'The member holds the Pro entitlement for skill verification.' }) skillEntitled!: boolean;
  @ApiProperty({ type: Number }) slaWorkingDays!: number;
}

export class UploadEvidenceFileDto {
  @ApiProperty({ enum: ['IMAGE', 'DOCUMENT'] })
  @IsIn(['IMAGE', 'DOCUMENT'])
  kind!: 'IMAGE' | 'DOCUMENT';

  @ApiProperty({ example: 'image/jpeg' })
  @IsString()
  @MaxLength(100)
  mimeType!: string;

  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(25 * 1024 * 1024)
  sizeBytes!: number;
}

export class AddEvidenceDto {
  @ApiProperty({ enum: ['GOVERNMENT_ID', 'PORTFOLIO_PROJECT', 'DOCUMENT', 'LINK'], description: 'References have their own route.' })
  @IsIn(['GOVERNMENT_ID', 'PORTFOLIO_PROJECT', 'DOCUMENT', 'LINK'])
  type!: 'GOVERNMENT_ID' | 'PORTFOLIO_PROJECT' | 'DOCUMENT' | 'LINK';

  @ApiPropertyOptional({ format: 'uuid', description: 'GOVERNMENT_ID and DOCUMENT: the id from the evidence upload.' })
  @IsOptional()
  @IsUUID()
  mediaAssetId?: string;

  @ApiPropertyOptional({ format: 'uuid', description: 'PORTFOLIO_PROJECT: one of your own projects.' })
  @IsOptional()
  @IsUUID()
  projectId?: string;

  @ApiPropertyOptional({ description: 'LINK: an https address.' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  url?: string;

  @ApiPropertyOptional({ description: 'A short label, for example the name of a certificate.' })
  @IsOptional()
  @IsString()
  @MaxLength(120)
  label?: string;
}

export class AddReferenceDto {
  @ApiProperty()
  @IsString()
  @MinLength(2)
  @MaxLength(120)
  name!: string;

  @ApiProperty()
  @IsEmail()
  @MaxLength(254)
  email!: string;

  @ApiProperty({ example: 'Client' })
  @IsString()
  @MinLength(2)
  @MaxLength(80)
  relationship!: string;
}

export class SubmitResultDto {
  @ApiProperty({ type: CaseViewDto }) case!: CaseViewDto;
}

// ---- public reference response ----

export class ReferenceRequestDto {
  @ApiProperty() refereeName!: string;
  @ApiProperty({ description: 'The applicant, by display name only.' }) applicantName!: string;
  @ApiProperty() relationship!: string;
  @ApiProperty({ enum: ['VERIFIED_CREATIVE', 'SKILL'] }) about!: string;
  @ApiPropertyOptional({ nullable: true, type: String, description: 'The skill, when the request is about one.' }) skillName!: string | null;
  @ApiProperty(REF_STATUS) status!: VerificationReferenceStatus;
}

export class RespondReferenceDto {
  @ApiProperty({ description: 'True when the referee confirms they know the applicant in the stated relationship.' })
  confirm!: boolean;

  @ApiPropertyOptional({ description: 'A sentence or two about the work. Seen by the reviewer only.' })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  comment?: string;
}

// ---- reviewer workspace ----

export class AdminCaseQueryDto extends PageQueryDto {
  @ApiPropertyOptional(SUBJECT) @IsOptional() @IsEnum(VerificationSubjectType) type?: VerificationSubjectType;
  @ApiPropertyOptional(STATUS) @IsOptional() @IsEnum(VerificationStatus) status?: VerificationStatus;
  @ApiPropertyOptional({ enum: ['any', 'mine', 'unassigned'], default: 'any' })
  @IsOptional()
  @IsIn(['any', 'mine', 'unassigned'])
  assigned?: 'any' | 'mine' | 'unassigned';
  @ApiPropertyOptional({ description: 'Only cases past their service-level date.' })
  @IsOptional()
  @Type(() => Boolean)
  overdue?: boolean;
}

export class AdminCaseRowDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty(SUBJECT) subjectType!: VerificationSubjectType;
  @ApiProperty(STATUS) status!: VerificationStatus;
  @ApiProperty() applicantName!: string;
  @ApiPropertyOptional({ nullable: true, type: String }) applicantHandle!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String }) subjectLabel!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String, format: 'date-time' }) submittedAt!: Date | null;
  @ApiProperty({ description: 'Hours since submission (0 for a draft).' }) ageHours!: number;
  @ApiPropertyOptional({ nullable: true, type: String, format: 'date-time' }) slaDueAt!: Date | null;
  @ApiProperty() overdue!: boolean;
  @ApiPropertyOptional({ nullable: true, type: String, format: 'uuid' }) reviewerId!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String }) reviewerName!: string | null;
  @ApiProperty({ description: 'The caller is the applicant, so cannot review this case.' }) isOwnCase!: boolean;
  @ApiProperty({ description: 'The caller is the assigned reviewer.' }) assignedToMe!: boolean;
  @ApiPropertyOptional({ nullable: true, type: String, format: 'date-time' }) expiresAt!: Date | null;
}

export class AdminCaseCountDto {
  @ApiProperty(SUBJECT) subjectType!: VerificationSubjectType;
  @ApiProperty() waiting!: number;
  @ApiProperty() underReview!: number;
  @ApiProperty() overdue!: number;
  @ApiPropertyOptional({ nullable: true, type: Number, description: 'Age in hours of the oldest waiting case.' }) oldestHours!: number | null;
}

export class AdminSummaryDto {
  @ApiProperty() slaWorkingDays!: number;
  @ApiProperty({ type: [AdminCaseCountDto] }) byType!: AdminCaseCountDto[];
  @ApiProperty({ description: 'Verified badges that expire within 30 days.' }) expiringSoon!: number;
}

export class AdminEvidenceDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty(EVIDENCE) type!: VerificationEvidenceType;
  @ApiPropertyOptional({ nullable: true, type: String }) label!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String }) url!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String, format: 'uuid' }) projectId!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String }) projectTitle!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String }) projectRole!: string | null;
  @ApiProperty({ description: 'The evidence is a stored file the assigned reviewer can open.' }) isFile!: boolean;
  @ApiPropertyOptional({ nullable: true, type: String }) mimeType!: string | null;
  @ApiProperty() purged!: boolean;
  @ApiPropertyOptional({ nullable: true, type: String, format: 'date-time' }) purgeAfter!: Date | null;
}

export class AdminReferenceDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() name!: string;
  @ApiProperty({ description: 'Masked.' }) emailMasked!: string;
  @ApiProperty() relationship!: string;
  @ApiProperty(REF_STATUS) status!: VerificationReferenceStatus;
  @ApiPropertyOptional({ nullable: true, type: String }) comment!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String, format: 'date-time' }) respondedAt!: Date | null;
}

export class AdminEventDto {
  @ApiProperty() action!: string;
  @ApiPropertyOptional({ nullable: true, type: String }) actorName!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String }) note!: string | null;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
}

export class AdminPriorCaseDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty(SUBJECT) subjectType!: VerificationSubjectType;
  @ApiProperty(STATUS) status!: VerificationStatus;
  @ApiPropertyOptional({ nullable: true, type: String, format: 'date-time' }) decidedAt!: Date | null;
  @ApiPropertyOptional({ nullable: true, type: String }) feedback!: string | null;
}

export class AdminCaseDetailDto extends AdminCaseRowDto {
  @ApiProperty({ type: [RequirementStateDto] }) requirements!: RequirementStateDto[];
  @ApiProperty({ type: [AdminEvidenceDto] }) evidence!: AdminEvidenceDto[];
  @ApiProperty({ type: [AdminReferenceDto] }) references!: AdminReferenceDto[];
  @ApiProperty({ type: [AdminEventDto] }) events!: AdminEventDto[];
  @ApiProperty({ type: [AdminPriorCaseDto] }) previousDecisions!: AdminPriorCaseDto[];
  @ApiPropertyOptional({ nullable: true, type: String }) decisionNotes!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String }) feedback!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String }) moreInfoNote!: string | null;
  @ApiProperty({ description: 'The caller may open files: they are the assigned reviewer and not the applicant.' }) canViewEvidence!: boolean;
  @ApiProperty({ description: 'The caller may approve, reject or ask for more information.' }) canDecide!: boolean;
  @ApiPropertyOptional({ nullable: true, type: String }) applicantMemberSince!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String }) applicantHeadline!: string | null;
  @ApiProperty({ description: 'Whether a confirmed reference exists (needed to approve a Verified Creative).' }) hasConfirmedReference!: boolean;
}

export class EvidenceAccessDto {
  @ApiProperty({ description: 'Signed address that stops working after expiresAt.' }) url!: string;
  @ApiProperty({ type: String, format: 'date-time' }) expiresAt!: Date;
  @ApiProperty({ description: 'Overlay this on the evidence. Images also have it burned in.' }) watermark!: string;
  @ApiProperty() mimeType!: string;
}

export class ApproveCaseDto {
  @ApiPropertyOptional({ description: 'Reviewer-only notes.' })
  @IsOptional()
  @IsString()
  @MaxLength(2000)
  notes?: string;

  @ApiPropertyOptional({ type: String, format: 'date-time', description: 'When the badge expires. Default: the platform setting; at most 24 months.' })
  @IsOptional()
  @IsDateString()
  expiresAt?: string;
}

export class RejectCaseDto {
  @ApiProperty({ description: 'Feedback the applicant will read.' })
  @IsString()
  @MinLength(10)
  @MaxLength(1000)
  feedback!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(2000)
  notes?: string;
}

export class RequestInfoDto {
  @ApiProperty({ description: 'What the applicant should add.' })
  @IsString()
  @MinLength(10)
  @MaxLength(1000)
  message!: string;
}

export class RevokeCaseDto {
  @ApiProperty({ description: 'The reason. The applicant will read it.' })
  @IsString()
  @MinLength(10)
  @MaxLength(1000)
  reason!: string;
}

export class BadgeDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty(SUBJECT) subjectType!: VerificationSubjectType;
  @ApiProperty({ format: 'uuid' }) subjectId!: string;
  @ApiProperty({ type: String, format: 'date-time' }) grantedAt!: Date;
  @ApiPropertyOptional({ nullable: true, type: String, format: 'date-time' }) expiresAt!: Date | null;
  @ApiPropertyOptional({ enum: VerificationBadgeEndReason, nullable: true }) endReason!: VerificationBadgeEndReason | null;
}
