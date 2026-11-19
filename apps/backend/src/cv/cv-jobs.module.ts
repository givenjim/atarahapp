import { Module } from '@nestjs/common';
import { AnalyticsService } from '../analytics/analytics.service';
import { MediaModule } from '../media/media.module';
import { CvService } from './cv.service';
import { CvSourceService, DbVerifiedMarksReader, VERIFIED_MARKS_READER } from './cv-source.service';
import { PdfRenderer } from './pdf-renderer';

/** Worker side of P2-M7: the PDF build job. The processor is registered by the worker module. */
@Module({
  imports: [MediaModule],
  providers: [
    CvService,
    CvSourceService,
    PdfRenderer,
    AnalyticsService,
    { provide: VERIFIED_MARKS_READER, useClass: DbVerifiedMarksReader },
  ],
  exports: [CvService],
})
export class CvJobsModule {}
