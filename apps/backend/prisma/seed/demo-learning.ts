import {
  type ContentDelivery,
  type ContentSource,
  type LearningAccess,
  type LearningContentType,
  type PrismaClient,
  type PublicationStatus,
  type SkillLevel,
} from '@prisma/client';

/**
 * Demo Skill Labs (development only): courses with in-app text lessons, plus single items of every type and source
 * (tutorial, toolkit, webinar, masterclass, article; Atarah, partner and external; native, embedded and external link).
 * Everything is flagged `isDemo`. The lessons are written for the demo; the providers and links are invented, and the
 * embedded player examples are drafts because a demo has no real video to embed. Safe to run again: it does nothing when
 * demo learning content exists.
 */

type Block =
  | { type: 'paragraph' | 'heading'; text: string }
  | { type: 'callout'; title: string | null; text: string }
  | { type: 'quote'; text: string; attribution: string | null };

interface LessonSeed {
  title: string;
  minutes: number;
  body: Block[];
  practice?: string;
  practiceSkill?: string;
}

interface CourseSeed {
  title: string;
  category: string;
  summary: string;
  level: SkillLevel;
  access?: LearningAccess;
  featured?: boolean;
  provider: string;
  source: ContentSource;
  disciplines?: string[];
  skills?: string[];
  learn: string[];
  forWho: string;
  lessons: LessonSeed[];
  daysAgo: number;
}

interface ItemSeed {
  title: string;
  type: LearningContentType;
  category: string;
  summary: string;
  level: SkillLevel;
  minutes: number;
  source: ContentSource;
  delivery: ContentDelivery;
  provider: string;
  url?: string;
  embed?: string;
  status?: PublicationStatus;
  featured?: boolean;
  access?: LearningAccess;
  disciplines?: string[];
  learn?: string[];
  forWho?: string;
  daysAgo: number;
}

const p = (text: string): Block => ({ type: 'paragraph', text });
const h = (text: string): Block => ({ type: 'heading', text });
const tip = (title: string, text: string): Block => ({ type: 'callout', title, text });

const COURSES: CourseSeed[] = [
  {
    title: 'Build a Portfolio That Gets You Hired',
    category: 'portfolio-building',
    summary: 'Choose, present and write up your best work so a client understands it in thirty seconds.',
    level: 'BEGINNER',
    featured: true,
    provider: 'Atarah Studio',
    source: 'ATARAH',
    disciplines: ['Visual Art', 'Design', 'Photography', 'Animation', 'Film / Video'],
    skills: ['Storyboarding', 'Colour'],
    learn: [
      'Pick the three projects that show the work you want more of',
      'Write a project description a client can skim',
      'Show results, not just pictures',
      'Keep your portfolio fresh with a ten-minute monthly habit',
    ],
    forWho: 'Creatives with a few finished projects who are not sure what to show or how to explain it.',
    daysAgo: 14,
    lessons: [
      {
        title: 'What a portfolio is for',
        minutes: 6,
        body: [
          h('A portfolio answers one question'),
          p('A client opens your portfolio with one question in mind: can this person do what I need? Everything you show should help them answer yes quickly.'),
          p('That means a portfolio is not an archive of everything you have ever made. It is a short, chosen selection that says: this is the work I want more of.'),
          tip('Rule of thumb', 'Three strong projects beat twelve mixed ones. If you hesitate over a piece, leave it out.'),
        ],
        practice: 'List every project you could show. Circle the three that look most like the work you want next.',
      },
      {
        title: 'Choosing your three projects',
        minutes: 8,
        body: [
          h('Choose for the client, not for yourself'),
          p('We are often proudest of the work that was hardest to make. Clients care about the work that is closest to their own problem.'),
          p('For each project ask: would someone hiring for my ideal job understand why I made this and what I did? If the answer is unclear, the project needs a better description, or it does not belong yet.'),
          tip('Mix it up', 'Show range inside one direction: for example a poster, a book cover and a motion piece for the same style of client.'),
        ],
        practice: 'Pick your three projects and add each to your Atarah portfolio with a cover image.',
        practiceSkill: 'Colour',
      },
      {
        title: 'Writing about your work',
        minutes: 9,
        body: [
          h('Four short lines for every project'),
          p('The brief: what was the problem? Your role: what exactly did you do? The process: one or two decisions that shaped the result. The outcome: what changed because of it.'),
          p('Use numbers where you honestly have them: views, sales, people reached, days saved. Where you do not, say what the client or audience did with the work.'),
          { type: 'quote', text: 'If you cannot explain it in four lines, you do not understand it well enough to sell it yet.', attribution: 'A working art director' },
        ],
        practice: 'Write your four lines for your strongest project and paste them into its description.',
      },
      {
        title: 'Showing results',
        minutes: 7,
        body: [
          h('Evidence beats adjectives'),
          p('Words like creative, passionate and innovative say nothing a client can check. A screenshot of a published piece, a quote from a happy client or a before-and-after does.'),
          p('Ask past clients for one sentence you can quote. Most say yes if you make it easy: send them a draft they can edit.'),
        ],
        practice: 'Ask one past client for a one-sentence reference and add it to the project.',
      },
      {
        title: 'Keeping it fresh',
        minutes: 5,
        body: [
          h('Ten minutes a month'),
          p('Set a monthly reminder. Add anything new, retire the weakest piece, and re-read your descriptions. A portfolio that changes tells clients you are working.'),
          tip('Next step', 'When you finish this course your certificate is added to your Passport. Share your portfolio link with one person this week.'),
        ],
      },
    ],
  },
  {
    title: 'Pricing Your Creative Work',
    category: 'financial-literacy',
    summary: 'Work out what to charge, quote confidently and say no to work that does not pay.',
    level: 'INTERMEDIATE',
    featured: true,
    provider: 'Atarah Studio',
    source: 'ATARAH',
    skills: ['Client management'],
    learn: [
      'Find your minimum day rate from your real costs',
      'Quote by project, by day or by value, and know when to use each',
      'Handle "can you do it cheaper?" without losing the client',
    ],
    forWho: 'Freelancers and studio owners who guess at prices and want a method.',
    daysAgo: 9,
    lessons: [
      {
        title: 'Know your minimum',
        minutes: 8,
        body: [
          h('Start with what you need'),
          p('Add up what you need to earn in a month: living costs, tax, software, equipment replacement, unpaid time. Divide by the days you can realistically bill, usually fewer than twelve a month.'),
          tip('Be honest about billable days', 'Admin, chasing payments and finding clients are real work you are not paid for directly. Plan for them.'),
        ],
        practice: 'Write down your monthly number and the number of billable days. Divide them.',
      },
      {
        title: 'Three ways to quote',
        minutes: 7,
        body: [
          h('By day, by project, by value'),
          p('A day rate suits work with unclear scope. A project fee suits work you can define. A value-based price suits work that makes the client money, such as a campaign or a product launch.'),
        ],
      },
      {
        title: 'Saying the number',
        minutes: 6,
        body: [
          h('Say it, then stop talking'),
          p('State your price clearly and then be quiet. Explaining or apologising signals that the number is negotiable.'),
          p('If a client says it is too much, ask what budget they had in mind. You can reduce the scope; try not to reduce the rate.'),
        ],
        practice: 'Practise saying your day rate out loud, once, without a follow-up sentence.',
      },
      {
        title: 'Contracts and deposits',
        minutes: 8,
        body: [
          h('Protect yourself in writing'),
          p('Ask for a deposit before you start, usually thirty to fifty percent, and write down what is included, how many rounds of changes you offer and when the final payment is due.'),
          tip('A short email counts', 'You do not need a long contract. A clear email that the client replies to with yes is a record you can point to.'),
        ],
      },
    ],
  },
  {
    title: 'Grant Writing for Creatives',
    category: 'career-development',
    summary: 'Read a call properly, plan a budget and write a proposal that panels remember.',
    level: 'INTERMEDIATE',
    access: 'PREMIUM_CONTENT',
    provider: 'Atarah Studio',
    source: 'ATARAH',
    learn: [
      'Decide whether a call is worth your time in ten minutes',
      'Write a one-page project plan',
      'Build a budget a panel believes',
    ],
    forWho: 'Creatives applying for funds, residencies or fellowships for the first time.',
    daysAgo: 20,
    lessons: [
      {
        title: 'Read the call twice',
        minutes: 7,
        body: [
          h('Eligibility first'),
          p('Check who can apply, what the money can be spent on and the deadline before you write a word. Many strong proposals fail on a rule the applicant missed.'),
        ],
      },
      {
        title: 'The one-page plan',
        minutes: 9,
        body: [
          h('Say what, why now, and how'),
          p('A one-page plan has four parts: what you will make, why it matters now, how you will do it and what it will cost. Write this before the application form and copy from it.'),
        ],
        practice: 'Draft your one-page plan for a project you would like funded.',
      },
      {
        title: 'Budgets panels believe',
        minutes: 8,
        body: [
          h('Round numbers look invented'),
          p('List real costs with real quantities: three days of studio hire at a named rate, not a round amount. Include your own time as a line, and keep a small contingency.'),
        ],
      },
    ],
  },
];

const ITEMS: ItemSeed[] = [
  {
    title: 'Creative Business Starter Kit',
    type: 'TOOLKIT',
    category: 'entrepreneurship',
    summary: 'Templates for quotes, invoices and a simple client agreement you can adapt.',
    level: 'BEGINNER',
    minutes: 20,
    source: 'PARTNER',
    delivery: 'EXTERNAL_LINK',
    provider: 'Creative Economy Kenya (demo)',
    url: 'https://example.org/',
    learn: ['Send a professional quote', 'Invoice with the right details', 'Agree scope in writing'],
    forWho: 'New freelancers.',
    featured: true,
    daysAgo: 6,
  },
  {
    title: 'Branding for One-Person Studios',
    type: 'WEBINAR',
    category: 'branding',
    summary: 'A recorded session on building a simple, consistent brand when you are the whole team.',
    level: 'BEGINNER',
    minutes: 55,
    source: 'EXTERNAL',
    delivery: 'EXTERNAL_LINK',
    provider: 'Open Studio Sessions (demo)',
    url: 'https://example.org/',
    daysAgo: 11,
  },
  {
    title: 'Know Your Rights: Copyright Basics',
    type: 'ARTICLE',
    category: 'legal-awareness',
    summary: 'Who owns your work, what a licence is and the three clauses to look for before you sign.',
    level: 'BEGINNER',
    minutes: 10,
    source: 'PARTNER',
    delivery: 'EXTERNAL_LINK',
    provider: 'Kenya Copyright Awareness Group (demo)',
    url: 'https://example.org/',
    daysAgo: 4,
  },
  {
    title: 'Sound Design for Short Films',
    type: 'MASTERCLASS',
    category: 'production',
    summary: 'A masterclass on building a soundscape from location recordings. (Draft: needs a real embed.)',
    level: 'ADVANCED',
    minutes: 40,
    source: 'PARTNER',
    delivery: 'EMBEDDED',
    provider: 'Lakeside Film Collective (demo)',
    embed: 'https://player.vimeo.com/video/123456789',
    status: 'DRAFT',
    daysAgo: 2,
  },
  {
    title: 'Colour Grading Quick Start',
    type: 'TUTORIAL',
    category: 'visual-arts',
    summary: 'A short walkthrough of a first grade: balance, contrast and a simple look. (Draft: needs a real embed.)',
    level: 'BEGINNER',
    minutes: 18,
    source: 'ATARAH',
    delivery: 'EMBEDDED',
    provider: 'Atarah Studio',
    embed: 'https://www.youtube.com/watch?v=abcDEF12345',
    status: 'DRAFT',
    daysAgo: 1,
  },
];

export async function seedDemoLearning(prisma: PrismaClient): Promise<void> {
  if ((await prisma.learningContent.count({ where: { isDemo: true } })) > 0) return;
  const admin = await prisma.user.findUnique({ where: { email: 'admin@demo.atarah.test' } });
  const cats = new Map((await prisma.learningCategory.findMany()).map((c) => [c.slug, c.id]));
  const disciplines = new Map((await prisma.discipline.findMany()).map((d) => [d.name, d.id]));
  const skills = new Map((await prisma.skill.findMany()).map((s) => [s.name, s.id]));
  const day = 86_400_000;
  const now = Date.now();
  const slug = (t: string) => t.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '').slice(0, 60);

  for (const c of COURSES) {
    const categoryId = cats.get(c.category);
    if (!categoryId) continue;
    const total = c.lessons.reduce((n, l) => n + l.minutes, 0);
    const content = await prisma.learningContent.create({
      data: {
        slug: `${slug(c.title)}-demo`,
        type: 'COURSE',
        title: c.title,
        summary: c.summary,
        categoryId,
        level: c.level,
        durationMinutes: total,
        source: c.source,
        delivery: 'NATIVE',
        providerName: c.provider,
        access: c.access ?? 'FREE',
        featured: c.featured ?? false,
        status: 'PUBLISHED',
        publishedAt: new Date(now - c.daysAgo * day),
        whatYouLearn: c.learn,
        whoItsFor: c.forWho,
        createdById: admin?.id ?? null,
        isDemo: true,
      },
    });
    await prisma.course.create({
      data: { contentId: content.id, lessonCount: c.lessons.length, totalMinutes: total, sequential: true },
    });
    for (const [i, l] of c.lessons.entries()) {
      await prisma.lesson.create({
        data: {
          courseId: content.id,
          sequence: i + 1,
          title: l.title,
          durationMinutes: l.minutes,
          body: l.body,
          practicePrompt: l.practice ?? null,
          practiceSkillId: l.practiceSkill ? (skills.get(l.practiceSkill) ?? null) : null,
        },
      });
    }
    const dIds = (c.disciplines ?? []).flatMap((n) => (disciplines.has(n) ? [disciplines.get(n)!] : []));
    if (dIds.length > 0) {
      await prisma.learningContentDiscipline.createMany({
        data: dIds.map((disciplineId) => ({ contentId: content.id, disciplineId })),
      });
    }
    const sIds = (c.skills ?? []).flatMap((n) => (skills.has(n) ? [skills.get(n)!] : []));
    if (sIds.length > 0) {
      await prisma.learningContentSkill.createMany({
        data: sIds.map((skillId) => ({ contentId: content.id, skillId })),
      });
    }
  }

  for (const i of ITEMS) {
    const categoryId = cats.get(i.category);
    if (!categoryId) continue;
    const status = i.status ?? 'PUBLISHED';
    const content = await prisma.learningContent.create({
      data: {
        slug: `${slug(i.title)}-demo`,
        type: i.type,
        title: i.title,
        summary: i.summary,
        categoryId,
        level: i.level,
        durationMinutes: i.minutes,
        source: i.source,
        delivery: i.delivery,
        providerName: i.provider,
        externalUrl: i.url ?? null,
        embedUrl: i.embed ?? null,
        access: i.access ?? 'FREE',
        featured: i.featured ?? false,
        status,
        publishedAt: status === 'PUBLISHED' ? new Date(now - i.daysAgo * day) : null,
        whatYouLearn: i.learn ?? [],
        whoItsFor: i.forWho ?? null,
        createdById: admin?.id ?? null,
        isDemo: true,
      },
    });
    const dIds = (i.disciplines ?? []).flatMap((n) => (disciplines.has(n) ? [disciplines.get(n)!] : []));
    if (dIds.length > 0) {
      await prisma.learningContentDiscipline.createMany({
        data: dIds.map((disciplineId) => ({ contentId: content.id, disciplineId })),
      });
    }
  }
}
