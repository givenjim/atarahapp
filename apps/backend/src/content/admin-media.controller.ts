import { Body, Controller, HttpCode, Param, ParseUUIDPipe, Post } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { type AuthContext } from '../access/access.types';
import { CurrentAuth, RequiresPermission } from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { MediaAssetDto, RequestUploadDto, UploadTicketDto } from '../media/media.dto';
import { MediaService } from '../media/media.service';

/** Uploads for editors (article hero and body images). Members use `/media`; staff need `media.manage` here. */
@ApiTags('Admin Content')
@ApiBearerAuth('access-token')
@RequiresPermission('admin.access', 'media.manage')
@Controller('admin/media')
export class AdminMediaController {
  constructor(private readonly media: MediaService) {}

  @Throttle({ default: { limit: 60, ttl: 60_000 } })
  @HttpCode(201)
  @ApiEnvelope(UploadTicketDto, { status: 201 })
  @Post('uploads')
  requestUpload(@CurrentAuth() auth: AuthContext, @Body() dto: RequestUploadDto) {
    return this.media.requestUpload(auth.userId, dto);
  }

  @HttpCode(200)
  @ApiEnvelope(MediaAssetDto)
  @Post(':id/complete')
  complete(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.media.complete(auth.userId, id);
  }
}
