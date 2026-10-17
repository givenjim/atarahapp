import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  Param,
  ParseUUIDPipe,
  Post,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { type AuthContext } from '../access/access.types';
import { CurrentAuth, RequiresPermission } from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { MediaAssetDto, RequestUploadDto, UploadTicketDto } from './media.dto';
import { MediaService } from './media.service';

/**
 * Uploads never pass through the API: the client PUTs the bytes to a signed storage URL, then confirms.
 * Files are validated by a background job before they become READY.
 */
@ApiTags('Media')
@ApiBearerAuth('access-token')
@RequiresPermission('profile.edit')
@Controller('media')
export class MediaController {
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

  @ApiEnvelope(MediaAssetDto)
  @Get(':id')
  get(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.media.get(auth.userId, id);
  }

  @HttpCode(204)
  @Delete(':id')
  async remove(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    await this.media.remove(auth.userId, id);
  }
}
