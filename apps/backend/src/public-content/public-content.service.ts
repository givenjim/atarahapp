import { Injectable } from '@nestjs/common';
import { ApiException } from '../common/api.exception';
import { FeatureFlagService } from '../feature-flags/feature-flag.service';
import { PrismaService } from '../prisma/prisma.service';

/** Content the apps need before anyone has signed in. */
@Injectable()
export class PublicContentService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly flags: FeatureFlagService,
  ) {}

  async config() {
    return { googleSignIn: await this.flags.isEnabled('google-sign-in') };
  }

  /** Latest published version; before the owner publishes one, the seeded draft is returned and labelled. */
  async legal(type: 'TERMS' | 'PRIVACY') {
    const published = await this.prisma.legalDocument.findFirst({
      where: { type, status: 'PUBLISHED' },
      orderBy: { createdAt: 'desc' },
    });
    const doc =
      published ??
      (await this.prisma.legalDocument.findFirst({
        where: { type },
        orderBy: { createdAt: 'desc' },
      }));
    if (!doc) throw ApiException.notFound('That document is not available yet.');
    return {
      type: doc.type,
      version: doc.version,
      title: doc.title,
      body: doc.body,
      isDraft: doc.status !== 'PUBLISHED',
    };
  }
}
