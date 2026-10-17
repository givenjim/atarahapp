import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsEnum, IsInt, IsString, Max, MaxLength, Min } from 'class-validator';

export const MEDIA_KINDS = ['IMAGE', 'VIDEO', 'AUDIO', 'DOCUMENT'] as const;
export const MEDIA_VISIBILITY = ['PUBLIC', 'PRIVATE'] as const;

export class RequestUploadDto {
  @ApiProperty({ enum: MEDIA_KINDS })
  @IsEnum(MEDIA_KINDS)
  kind!: (typeof MEDIA_KINDS)[number];

  @ApiProperty({ example: 'image/jpeg', description: 'Must be an allowed type for the kind.' })
  @IsString()
  @MaxLength(100)
  mimeType!: string;

  @ApiProperty({ description: 'Exact size in bytes. The upload URL only accepts this length.' })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(200 * 1024 * 1024)
  sizeBytes!: number;

  @ApiProperty({
    enum: MEDIA_VISIBILITY,
    description: 'PUBLIC for files shown on public profiles; PRIVATE otherwise.',
  })
  @IsEnum(MEDIA_VISIBILITY)
  visibility!: (typeof MEDIA_VISIBILITY)[number];
}

export class UploadTicketDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ description: 'Signed URL. PUT the file bytes here with the headers below.' })
  uploadUrl!: string;
  @ApiProperty({ enum: ['PUT'] }) method!: 'PUT';
  @ApiProperty({ type: 'object', additionalProperties: { type: 'string' } })
  headers!: Record<string, string>;
  @ApiProperty({ type: String, format: 'date-time' }) expiresAt!: Date;
}

export class MediaAssetDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ enum: MEDIA_KINDS }) kind!: string;
  @ApiProperty({ enum: ['PUBLIC', 'PRIVATE', 'EVIDENCE'] }) bucket!: string;
  @ApiProperty({
    enum: ['PENDING_UPLOAD', 'UPLOADED', 'PROCESSING', 'READY', 'REJECTED', 'DELETED'],
  })
  status!: string;
  @ApiProperty() mimeType!: string;
  @ApiProperty() sizeBytes!: number;
  @ApiPropertyOptional({ nullable: true, type: Number }) width!: number | null;
  @ApiPropertyOptional({ nullable: true, type: Number }) height!: number | null;
  @ApiPropertyOptional({ nullable: true, type: String, description: 'Why the file was refused.' })
  rejectionReason!: string | null;
  @ApiPropertyOptional({
    nullable: true,
    type: String,
    description: 'Short-lived signed download URL. Present only when the file is READY.',
  })
  url!: string | null;
  @ApiPropertyOptional({
    nullable: true,
    type: 'object',
    additionalProperties: { type: 'string' },
    description: 'Image renditions by width (200, 600, 1200) as signed URLs.',
  })
  variants!: Record<string, string> | null;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
}
