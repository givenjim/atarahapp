import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { OpportunityCardDto, TrackingStateDto } from '../opportunities/opportunities.dto';
import { PageQueryDto } from '../common/pagination';

export const RESUME_KINDS = ['LESSON', 'OPPORTUNITY_GAP', 'DRAFT_PROJECT'] as const;

/** One "Pick up where you left off" card. Built from the member's own unfinished work. */
export class ResumeCardDto {
  @ApiProperty({ enum: RESUME_KINDS }) kind!: (typeof RESUME_KINDS)[number];
  @ApiProperty() title!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) subtitle!: string | null;
  @ApiPropertyOptional({
    type: Number,
    nullable: true,
    description: '0 to 100 where progress makes sense.',
  })
  progressPercent!: number | null;
  @ApiProperty({ description: 'The in-app path that opens it.' }) path!: string;
  @ApiProperty({ type: String, format: 'date-time' }) updatedAt!: Date;
}

export class ActivityCountsDto {
  @ApiProperty({ description: 'Saved items of every kind.' }) saved!: number;
  @ApiProperty({ description: 'Tracked opportunities that are in progress, applied or completed.' })
  applications!: number;
  @ApiProperty() unreadNotifications!: number;
  @ApiProperty({ description: 'Courses started and not finished.' }) learningInProgress!: number;
  @ApiProperty({ description: 'Published projects.' }) portfolio!: number;
  @ApiProperty({ description: 'Connection requests waiting for an answer.' })
  pendingConnections!: number;
}

export class ActivityDto {
  @ApiProperty({ type: [ResumeCardDto] }) resume!: ResumeCardDto[];
  @ApiProperty({ type: ActivityCountsDto }) counts!: ActivityCountsDto;
}

export class ApplicationsQueryDto extends PageQueryDto {}

export class ApplicationItemDto {
  @ApiProperty({ type: OpportunityCardDto }) opportunity!: OpportunityCardDto;
  @ApiProperty({ type: TrackingStateDto }) tracking!: TrackingStateDto;
  @ApiProperty({ enum: ['IN_PROGRESS', 'APPLIED', 'COMPLETED'] }) status!: string;
  @ApiProperty({ description: 'Ready to show under the title: "Applied 12 Oct", "Awarded".' })
  metaLine!: string;
}
