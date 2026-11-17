import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  Param,
  ParseEnumPipe,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { LegalDocumentType } from '@prisma/client';
import { type AuthContext } from '../access/access.types';
import {
  ClientIp,
  CurrentAuth,
  OptionalAuth,
  RequestIdParam,
  RequiresPermission,
  RequiresRecentAuth,
} from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { Paged } from '../common/response-envelope.interceptor';
import {
  AdminFaqDto,
  AdminHelpArticleDto,
  AdminLegalDto,
  AdminListQueryDto,
  FaqDto,
  FaqFieldsDto,
  HelpArticleDto,
  HelpArticleFieldsDto,
  HelpContactDto,
  HelpQueryDto,
  HelpResultDto,
  LegalFullDto,
  LegalSummaryDto,
  NewLegalVersionDto,
  PublishLegalDto,
  UpdateFaqDto,
  UpdateHelpArticleDto,
  UpdateLegalDraftDto,
} from './help.dto';
import { AdminHelpService, HelpService } from './help.service';

const perMinute = (limit: number) => Throttle({ default: { limit, ttl: 60_000 } });

/** Help centre and legal documents. Readable signed out too (the legal text is needed at sign-up). */
@ApiTags('Help')
@ApiBearerAuth('access-token')
@Controller()
export class HelpController {
  constructor(private readonly help: HelpService) {}

  @OptionalAuth()
  @perMinute(60)
  @ApiEnvelope(HelpResultDto)
  @Get('help')
  search(@Query() q: HelpQueryDto) {
    return this.help.search(q.q);
  }

  @OptionalAuth()
  @perMinute(60)
  @ApiEnvelope(HelpArticleDto)
  @Get('help/articles/:slug')
  article(@Param('slug') slug: string) {
    return this.help.article(slug.slice(0, 120));
  }

  @OptionalAuth()
  @perMinute(60)
  @ApiEnvelope(FaqDto, { isArray: true })
  @Get('help/faq')
  faq() {
    return this.help.faq();
  }

  @OptionalAuth()
  @ApiEnvelope(HelpContactDto)
  @Get('help/contact')
  contact() {
    return this.help.contact();
  }

  @OptionalAuth()
  @perMinute(60)
  @ApiEnvelope(LegalSummaryDto, { isArray: true })
  @Get('legal')
  legalList() {
    return this.help.legalList();
  }

  @OptionalAuth()
  @perMinute(60)
  @ApiEnvelope(LegalFullDto)
  @Get('legal/documents/:type')
  legalDocument(@Param('type', new ParseEnumPipe(LegalDocumentType)) type: LegalDocumentType) {
    return this.help.legalDocument(type);
  }
}

/** Help articles, FAQ and legal documents for staff. */
@ApiTags('Admin help')
@ApiBearerAuth('access-token')
@Controller('admin')
export class AdminHelpController {
  constructor(private readonly admin: AdminHelpService) {}

  // ---- help articles ----

  @RequiresPermission('admin.access', 'help.manage')
  @ApiEnvelope(AdminHelpArticleDto, { isArray: true })
  @Get('help-articles')
  async listArticles(@Query() q: AdminListQueryDto) {
    const { items, meta } = await this.admin.listArticles(q);
    return new Paged(items, meta);
  }

  @RequiresPermission('admin.access', 'help.manage')
  @ApiEnvelope(AdminHelpArticleDto)
  @Get('help-articles/:id')
  getArticle(@Param('id', ParseUUIDPipe) id: string) {
    return this.admin.getArticle(id);
  }

  @RequiresPermission('admin.access', 'help.manage')
  @ApiEnvelope(AdminHelpArticleDto, { status: 201 })
  @Post('help-articles')
  createArticle(
    @CurrentAuth() auth: AuthContext,
    @Body() dto: HelpArticleFieldsDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.createArticle({ userId: auth.userId, ip, requestId }, dto);
  }

  @RequiresPermission('admin.access', 'help.manage')
  @ApiEnvelope(AdminHelpArticleDto)
  @Patch('help-articles/:id')
  updateArticle(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateHelpArticleDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.updateArticle({ userId: auth.userId, ip, requestId }, id, dto);
  }

  @RequiresPermission('admin.access', 'help.manage')
  @HttpCode(204)
  @Delete('help-articles/:id')
  async deleteArticle(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    await this.admin.deleteArticle({ userId: auth.userId, ip, requestId }, id);
  }

  // ---- FAQ ----

  @RequiresPermission('admin.access', 'help.manage')
  @ApiEnvelope(AdminFaqDto, { isArray: true })
  @Get('faq')
  async listFaq(@Query() q: AdminListQueryDto) {
    const { items, meta } = await this.admin.listFaq(q);
    return new Paged(items, meta);
  }

  @RequiresPermission('admin.access', 'help.manage')
  @ApiEnvelope(AdminFaqDto, { status: 201 })
  @Post('faq')
  createFaq(
    @CurrentAuth() auth: AuthContext,
    @Body() dto: FaqFieldsDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.createFaq({ userId: auth.userId, ip, requestId }, dto);
  }

  @RequiresPermission('admin.access', 'help.manage')
  @ApiEnvelope(AdminFaqDto)
  @Patch('faq/:id')
  updateFaq(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateFaqDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.updateFaq({ userId: auth.userId, ip, requestId }, id, dto);
  }

  @RequiresPermission('admin.access', 'help.manage')
  @HttpCode(204)
  @Delete('faq/:id')
  async deleteFaq(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    await this.admin.deleteFaq({ userId: auth.userId, ip, requestId }, id);
  }

  // ---- legal documents ----

  @RequiresPermission('admin.access', 'legal.manage')
  @ApiEnvelope(AdminLegalDto, { isArray: true })
  @Get('legal-documents')
  listLegal(@Query('type') type?: string) {
    const parsed =
      type && (Object.values(LegalDocumentType) as string[]).includes(type)
        ? (type as LegalDocumentType)
        : undefined;
    return this.admin.listLegal(parsed);
  }

  @RequiresPermission('admin.access', 'legal.manage')
  @ApiEnvelope(AdminLegalDto, { status: 201 })
  @Post('legal-documents')
  newVersion(
    @CurrentAuth() auth: AuthContext,
    @Body() dto: NewLegalVersionDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.newLegalVersion({ userId: auth.userId, ip, requestId }, dto);
  }

  @RequiresPermission('admin.access', 'legal.manage')
  @ApiEnvelope(AdminLegalDto)
  @Patch('legal-documents/:id')
  updateDraft(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateLegalDraftDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.updateLegalDraft({ userId: auth.userId, ip, requestId }, id, dto);
  }

  /** Publishing a legal document changes what every member agrees to, so it needs a fresh authenticator check. */
  @RequiresPermission('admin.access', 'legal.manage')
  @RequiresRecentAuth()
  @HttpCode(200)
  @ApiEnvelope(AdminLegalDto)
  @Post('legal-documents/:id/publish')
  publish(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: PublishLegalDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.publishLegal({ userId: auth.userId, ip, requestId }, id, dto.effectiveAt);
  }
}
