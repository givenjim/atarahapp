import { Controller, Get, Param, ParseEnumPipe } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { Public } from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { LegalDocumentDto, PublicConfigDto } from './public-content.dto';
import { PublicContentService } from './public-content.service';

enum PublicLegalType {
  TERMS = 'TERMS',
  PRIVACY = 'PRIVACY',
}

@ApiTags('Public')
@Public()
@Controller()
export class PublicContentController {
  constructor(private readonly content: PublicContentService) {}

  @ApiEnvelope(PublicConfigDto)
  @Get('config/public')
  config() {
    return this.content.config();
  }

  @ApiEnvelope(LegalDocumentDto)
  @Get('legal/:type')
  legal(@Param('type', new ParseEnumPipe(PublicLegalType)) type: PublicLegalType) {
    return this.content.legal(type);
  }
}
