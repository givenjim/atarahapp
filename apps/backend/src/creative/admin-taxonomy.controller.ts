import {
  Body,
  Controller,
  Get,
  HttpCode,
  Param,
  ParseEnumPipe,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiParam, ApiTags } from '@nestjs/swagger';
import { type AuthContext } from '../access/access.types';
import { ClientIp, CurrentAuth, RequestIdParam, RequiresPermission } from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { Paged } from '../common/response-envelope.interceptor';
import { AdminTaxonomyService } from './admin-taxonomy.service';
import {
  AdminSuggestionDto,
  AdminSuggestionsQueryDto,
  AdminTaxonomyItemDto,
  AdminTaxonomyQueryDto,
  ApproveSuggestionDto,
  CreateTaxonomyItemDto,
  MergeSuggestionDto,
  RejectSuggestionDto,
  ReorderTaxonomyDto,
  TAXONOMY_KINDS,
  type TaxonomyKind,
  UpdateTaxonomyItemDto,
} from './creative.dto';

const KIND_PARAM = ApiParam({ name: 'kind', enum: TAXONOMY_KINDS });
const kindPipe = new ParseEnumPipe(TAXONOMY_KINDS);

@ApiTags('Admin Taxonomy')
@ApiBearerAuth('access-token')
@RequiresPermission('admin.access', 'taxonomy.manage')
@Controller('admin')
export class AdminTaxonomyController {
  constructor(private readonly taxonomy: AdminTaxonomyService) {}

  @KIND_PARAM
  @ApiEnvelope(AdminTaxonomyItemDto, { isArray: true })
  @Get('taxonomy/:kind')
  listTaxonomy(@Param('kind', kindPipe) kind: TaxonomyKind, @Query() q: AdminTaxonomyQueryDto) {
    return this.taxonomy.list(kind, q);
  }

  @KIND_PARAM
  @HttpCode(201)
  @ApiEnvelope(AdminTaxonomyItemDto, { status: 201 })
  @Post('taxonomy/:kind')
  createTaxonomy(
    @CurrentAuth() auth: AuthContext,
    @Param('kind', kindPipe) kind: TaxonomyKind,
    @Body() dto: CreateTaxonomyItemDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.taxonomy.create({ userId: auth.userId, ip, requestId }, kind, dto);
  }

  // Declared before `:id` so "reorder" is not read as an id.
  @KIND_PARAM
  @HttpCode(200)
  @ApiEnvelope(AdminTaxonomyItemDto, { isArray: true })
  @Post('taxonomy/:kind/reorder')
  reorderTaxonomy(
    @CurrentAuth() auth: AuthContext,
    @Param('kind', kindPipe) kind: TaxonomyKind,
    @Body() dto: ReorderTaxonomyDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.taxonomy.reorder({ userId: auth.userId, ip, requestId }, kind, dto.ids);
  }

  @KIND_PARAM
  @ApiEnvelope(AdminTaxonomyItemDto)
  @Patch('taxonomy/:kind/:id')
  updateTaxonomy(
    @CurrentAuth() auth: AuthContext,
    @Param('kind', kindPipe) kind: TaxonomyKind,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateTaxonomyItemDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.taxonomy.update({ userId: auth.userId, ip, requestId }, kind, id, dto);
  }

  @ApiEnvelope(AdminSuggestionDto, { isArray: true })
  @Get('specialisation-suggestions')
  async listSuggestions(@Query() q: AdminSuggestionsQueryDto) {
    const { items, meta } = await this.taxonomy.listSuggestions(q);
    return new Paged(items, meta);
  }

  @HttpCode(200)
  @ApiEnvelope(AdminSuggestionDto)
  @Post('specialisation-suggestions/:id/approve')
  approveSuggestion(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ApproveSuggestionDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.taxonomy.approve({ userId: auth.userId, ip, requestId }, id, dto.name);
  }

  @HttpCode(200)
  @ApiEnvelope(AdminSuggestionDto)
  @Post('specialisation-suggestions/:id/merge')
  mergeSuggestion(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: MergeSuggestionDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.taxonomy.merge({ userId: auth.userId, ip, requestId }, id, dto.specialisationId);
  }

  @HttpCode(200)
  @ApiEnvelope(AdminSuggestionDto)
  @Post('specialisation-suggestions/:id/reject')
  rejectSuggestion(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: RejectSuggestionDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.taxonomy.reject({ userId: auth.userId, ip, requestId }, id, dto.note);
  }
}
