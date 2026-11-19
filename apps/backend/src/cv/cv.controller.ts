import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  Param,
  ParseEnumPipe,
  ParseUUIDPipe,
  Post,
  Put,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { CreativeDocumentFormat } from '@prisma/client';
import { type AuthContext } from '../access/access.types';
import { CurrentAuth, RequiresPermission } from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import {
  CreateShareDto,
  CvDownloadDto,
  CvFormatInfoDto,
  CvPreviewDto,
  CvRenderDto,
  CvShareCreatedDto,
  CvShareDto,
  CvStateDto,
  UpdateCvDto,
} from './cv.dto';
import { CvService } from './cv.service';

const perHour = (limit: number) => Throttle({ default: { limit, ttl: 3_600_000 } });
const Format = () => Param('format', new ParseEnumPipe(CreativeDocumentFormat));

/** The member's Creative CV / EPK: choices, preview, PDF builds and share links. Needs `profile.edit` (own profile). */
@ApiTags('Creative CV')
@ApiBearerAuth('access-token')
@RequiresPermission('profile.edit')
@Controller('me/creative-cv')
export class CvController {
  constructor(private readonly cv: CvService) {}

  @ApiEnvelope(CvFormatInfoDto, { isArray: true })
  @Get('formats')
  formats() {
    return this.cv.formats();
  }

  /** Revoke a share link. Registered before the `:format` routes so `shares` is never read as a format. */
  @ApiEnvelope(CvShareDto)
  @Delete('shares/:id')
  revokeShare(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.cv.revokeShare(auth.userId, id);
  }

  @ApiEnvelope(CvRenderDto)
  @Get('renders/:id')
  renderStatus(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.cv.renderStatus(auth.userId, id);
  }

  /** A short-lived signed link to the private PDF. Counts as a download. */
  @ApiEnvelope(CvDownloadDto)
  @perHour(60)
  @HttpCode(200)
  @Post('renders/:id/download')
  download(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.cv.download(auth.userId, id);
  }

  @ApiEnvelope(CvStateDto)
  @Get(':format')
  state(@CurrentAuth() auth: AuthContext, @Format() format: CreativeDocumentFormat) {
    return this.cv.state(auth.userId, format);
  }

  @ApiEnvelope(CvStateDto)
  @Put(':format')
  update(
    @CurrentAuth() auth: AuthContext,
    @Format() format: CreativeDocumentFormat,
    @Body() dto: UpdateCvDto,
  ) {
    return this.cv.update(auth.userId, format, dto);
  }

  @ApiEnvelope(CvPreviewDto)
  @Get(':format/preview')
  preview(@CurrentAuth() auth: AuthContext, @Format() format: CreativeDocumentFormat) {
    return this.cv.preview(auth.userId, format);
  }

  /** Queue a PDF build. Returns the build to poll with `GET renders/:id`. */
  @ApiEnvelope(CvRenderDto)
  @perHour(20)
  @HttpCode(202)
  @Post(':format/generate')
  generate(@CurrentAuth() auth: AuthContext, @Format() format: CreativeDocumentFormat) {
    return this.cv.generate(auth.userId, format);
  }

  @ApiEnvelope(CvShareDto, { isArray: true })
  @Get(':format/shares')
  shares(@CurrentAuth() auth: AuthContext, @Format() format: CreativeDocumentFormat) {
    return this.cv.listShares(auth.userId, format);
  }

  /** Create a public link. The full URL is in this response only; afterwards only a hint is kept. */
  @ApiEnvelope(CvShareCreatedDto)
  @perHour(30)
  @Post(':format/shares')
  createShare(
    @CurrentAuth() auth: AuthContext,
    @Format() format: CreativeDocumentFormat,
    @Body() dto: CreateShareDto,
  ) {
    return this.cv.createShare(auth.userId, format, dto);
  }
}
