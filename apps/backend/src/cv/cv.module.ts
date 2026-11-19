import { Module } from '@nestjs/common';
import { MediaModule } from '../media/media.module';
import { AnalyticsModule } from '../analytics/analytics.module';
import { CvPublicController } from './cv-public.controller';
import { CvController } from './cv.controller';
import { CvService } from './cv.service';
import { CvSourceService, DbVerifiedMarksReader, VERIFIED_MARKS_READER } from './cv-source.service';
import { PdfRenderer } from './pdf-renderer';

/** Creative CV / EPK and sharing (P2-M7). P2-M6 provides `VERIFIED_MARKS_READER` from `VerificationBadge` later. */
@Module({
  imports: [MediaModule, AnalyticsModule],
  controllers: [CvController, CvPublicController],
  providers: [
    CvService,
    CvSourceService,
    PdfRenderer,
    { provide: VERIFIED_MARKS_READER, useClass: DbVerifiedMarksReader },
  ],
  exports: [CvService],
})
export class CvModule {}
