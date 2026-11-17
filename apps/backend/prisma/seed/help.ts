import { type PrismaClient } from '@prisma/client';

/**
 * Help centre content: the Safety centre article and the starter FAQ. This is product copy (not legal text), so it
 * ships in every environment. Create-if-missing only: staff edit it in the console and re-seeding never overwrites.
 */

interface Block {
  type: 'paragraph' | 'heading' | 'callout';
  text: string;
  title?: string;
}

const SAFETY_BODY: Block[] = [
  {
    type: 'paragraph',
    text: 'Atarah is a community of working creatives. These tools keep it respectful and safe, and you are always in control of what you see.',
  },
  { type: 'heading', text: 'Report something' },
  {
    type: 'paragraph',
    text: 'Open the menu on a post, comment, group or profile and choose Report. Pick the closest reason and add a note if it helps. A moderator reviews every report. We tell you only that we took action or did not find a breach of the Community Guidelines, never who decided or why.',
  },
  { type: 'heading', text: 'Block someone' },
  {
    type: 'paragraph',
    text: 'Blocking hides your content from them and theirs from you, in both directions. They cannot send you connection requests, comment on your posts or find you in search. They are not told that you blocked them. You can review and unblock people under Community, People, Blocked.',
  },
  { type: 'heading', text: 'Mute a person or a conversation' },
  {
    type: 'paragraph',
    text: 'Muting is quieter than blocking. Their posts stop appearing in your feed, but nothing changes for them. You can mute a single post thread too.',
  },
  {
    type: 'callout',
    title: 'In danger or being threatened?',
    text: 'Report it as Harassment and, if you are in immediate danger, contact your local emergency number first. Our team treats threats as urgent.',
  },
];

const FAQ: Array<[string, string]> = [
  [
    'How is my Creative Passport used?',
    'It powers your public profile, recommendations and applications. You choose what is public in Privacy.',
  ],
  [
    'Does Atarah process external applications?',
    'No. When an opportunity is external we tell you before you leave, and you apply on the provider’s site.',
  ],
  [
    'How do I become a mentor?',
    'Mentors arrive with Atarah Pro in a later release. When mentor applications open, apply from your profile and every application is reviewed.',
  ],
  [
    'Can I change who sees my contact details?',
    'Yes. Open Settings, then Privacy & visibility, and choose Public, Members only or Private for contact details, location, portfolio, experience and activity.',
  ],
  [
    'How do I delete my account?',
    'Open Settings, then Delete account, type DELETE and confirm. Your profile disappears at once and your data is removed after 30 days. Sign in during those 30 days to restore your account.',
  ],
  [
    'How do I download my data?',
    'Open Settings, then Privacy & visibility, and choose Download my data. We email a link that works for 7 days.',
  ],
];

export async function seedHelp(prisma: PrismaClient): Promise<number> {
  let created = 0;
  if ((await prisma.helpArticle.count({ where: { slug: 'safety-centre' } })) === 0) {
    await prisma.helpArticle.create({
      data: {
        slug: 'safety-centre',
        title: 'Safety centre',
        summary: 'Report, block and mute.',
        body: SAFETY_BODY as unknown as object,
        sortOrder: 1,
        published: true,
      },
    });
    created += 1;
  }
  if ((await prisma.faqEntry.count()) === 0) {
    await prisma.faqEntry.createMany({
      data: FAQ.map(([question, answer], i) => ({
        question,
        answer,
        sortOrder: i + 1,
        published: true,
      })),
    });
    created += FAQ.length;
  }
  return created;
}
