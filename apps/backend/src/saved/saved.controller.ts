import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  Param,
  ParseEnumPipe,
  ParseUUIDPipe,
  Put,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiParam, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { type AuthContext } from '../access/access.types';
import { CurrentAuth, RequiresPermission } from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { Paged } from '../common/response-envelope.interceptor';
import {
  SAVED_KINDS,
  SavedCountsDto,
  SavedItemDto,
  SavedQueryDto,
  type SavedKind,
  SaveBodyDto,
} from './saved.dto';
import { SavedService } from './saved.service';

enum SavedKindParam {
  ARTICLE = 'ARTICLE',
  POST = 'POST',
  LEARNING = 'LEARNING',
  CREATIVE = 'CREATIVE',
  OPPORTUNITY = 'OPPORTUNITY',
  LISTING = 'LISTING',
  MENTOR = 'MENTOR',
}

/** What the member saved, of every kind, and the one pair of routes every save button uses. */
@ApiTags('Saved')
@ApiBearerAuth('access-token')
@RequiresPermission('saved.manage.own')
@Controller('me/saved')
export class SavedController {
  constructor(private readonly saved: SavedService) {}

  @ApiEnvelope(SavedItemDto, { isArray: true })
  @Get()
  async list(@CurrentAuth() auth: AuthContext, @Query() q: SavedQueryDto) {
    const { items, meta } = await this.saved.list(auth.userId, q);
    return new Paged(items, meta);
  }

  @ApiEnvelope(SavedCountsDto)
  @Get('counts')
  counts(@CurrentAuth() auth: AuthContext) {
    return this.saved.counts(auth.userId);
  }

  /** Idempotent. LISTING and MENTOR answer 400 with `details.soon = P2` until Phase 2. */
  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @HttpCode(204)
  @ApiParam({ name: 'type', enum: SAVED_KINDS })
  @Put(':type/:id')
  async save(
    @CurrentAuth() auth: AuthContext,
    @Param('type', new ParseEnumPipe(SavedKindParam)) type: SavedKind,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: SaveBodyDto,
  ) {
    await this.saved.add(auth.userId, type, id, dto.collection);
  }

  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @HttpCode(204)
  @ApiParam({ name: 'type', enum: SAVED_KINDS })
  @Delete(':type/:id')
  async unsave(
    @CurrentAuth() auth: AuthContext,
    @Param('type', new ParseEnumPipe(SavedKindParam)) type: SavedKind,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    await this.saved.remove(auth.userId, type, id);
  }
}
