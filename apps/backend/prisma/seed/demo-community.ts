import { type PostAudience, type PostType, type PrismaClient } from '@prisma/client';

/**
 * Demo community (development only): groups, posts of every type and audience, comments, reactions and
 * connections between the demo members. Everything is flagged `isDemo`. No blocks are created, so a fresh demo
 * database shows the full feed to every demo account. Safe to run again: it does nothing when demo groups exist.
 */

const HANDLES: Record<
  string,
  { handle: string; headline: string; discipline: string; county: string }
> = {
  'nia@demo.atarah.test': {
    handle: 'nia_wairimu',
    headline: 'Animator and storyteller',
    discipline: 'Animation',
    county: 'NBI',
  },
  'amani@demo.atarah.test': {
    handle: 'amani_otieno',
    headline: 'Music producer and mentor',
    discipline: 'Music',
    county: 'NBI',
  },
  'zuri@demo.atarah.test': {
    handle: 'zuri_mwangi',
    headline: 'Illustrator and print maker',
    discipline: 'Visual Art',
    county: 'MSA',
  },
  'kiptoo@demo.atarah.test': {
    handle: 'kiptoo_langat',
    headline: 'Filmmaker',
    discipline: 'Film',
    county: 'ELD',
  },
  'wanjiku@demo.atarah.test': {
    handle: 'wanjiku_njeri',
    headline: 'Photographer',
    discipline: 'Photography',
    county: 'NBI',
  },
};

const hoursAgo = (h: number) => new Date(Date.now() - h * 3_600_000);

/** Demo members need a finished profile (handle, discipline, county) to appear in People to meet. */
async function ensureProfiles(prisma: PrismaClient): Promise<void> {
  for (const [email, p] of Object.entries(HANDLES)) {
    const user = await prisma.user.findUnique({ where: { email } });
    if (!user || (await prisma.creativeProfile.findUnique({ where: { userId: user.id } })))
      continue;
    const [discipline, county] = await Promise.all([
      prisma.discipline.findFirst({
        where: { name: { contains: p.discipline, mode: 'insensitive' } },
      }),
      prisma.county.findFirst({ where: { code: p.county } }),
    ]);
    const fallback =
      discipline ?? (await prisma.discipline.findFirst({ orderBy: { sortOrder: 'asc' } }));
    const profile = await prisma.creativeProfile.create({
      data: {
        userId: user.id,
        handle: p.handle,
        displayName: user.fullName,
        headline: p.headline,
        bio: 'Demo profile for development.',
        primaryDisciplineId: fallback?.id ?? null,
        countyId: county?.id ?? null,
        onboardingStep: 'DONE',
        onboardingCompletedAt: new Date(),
        completionPercent: 40,
        openToCommissions: email.startsWith('zuri') || email.startsWith('kiptoo'),
      },
    });
    if (fallback) {
      await prisma.creativeDiscipline.create({
        data: { profileId: profile.id, disciplineId: fallback.id, isPrimary: true },
      });
    }
    if (county) {
      const counter = await prisma.passportCounter.upsert({
        where: { countyCode: county.code },
        create: { countyCode: county.code, lastValue: 1 },
        update: { lastValue: { increment: 1 } },
      });
      await prisma.creativePassport.create({
        data: {
          profileId: profile.id,
          passportNumber: `ATR-${county.code}-${String(counter.lastValue).padStart(4, '0')}`,
          countyCode: county.code,
          sequence: counter.lastValue,
        },
      });
    }
  }
}

export async function seedDemoCommunity(
  prisma: PrismaClient,
): Promise<{ groups: number; posts: number }> {
  if ((await prisma.group.count({ where: { isDemo: true } })) > 0) return { groups: 0, posts: 0 };
  await ensureProfiles(prisma);

  const byEmail = async (email: string) => prisma.user.findUnique({ where: { email } });
  const [admin, moderator, nia, amani, zuri, kiptoo, wanjiku] = await Promise.all(
    [
      'admin@demo.atarah.test',
      'moderator@demo.atarah.test',
      'nia@demo.atarah.test',
      'amani@demo.atarah.test',
      'zuri@demo.atarah.test',
      'kiptoo@demo.atarah.test',
      'wanjiku@demo.atarah.test',
    ].map(byEmail),
  );
  if (!admin || !moderator || !nia || !amani || !zuri || !kiptoo || !wanjiku)
    return { groups: 0, posts: 0 };

  const nairobi = await prisma.county.findFirst({ where: { code: 'NBI' } });
  const animation = await prisma.discipline.findFirst({
    where: { name: { contains: 'Animation', mode: 'insensitive' } },
  });
  const music = await prisma.discipline.findFirst({
    where: { name: { contains: 'Music', mode: 'insensitive' } },
  });

  const groupDefs = [
    {
      slug: 'atarah-community',
      name: 'Atarah Community',
      type: 'INTEREST' as const,
      description:
        'The official home of Kenya’s creative community: introductions, questions and news.',
      isOfficial: true,
      members: [nia, amani, zuri, kiptoo, wanjiku],
    },
    {
      slug: 'nairobi-creatives',
      name: 'Nairobi Creatives',
      type: 'LOCATION' as const,
      description: 'Meet-ups, studios and collaborations around Nairobi.',
      isOfficial: true,
      countyId: nairobi?.id,
      members: [nia, amani, wanjiku],
    },
    {
      slug: 'animators-of-kenya',
      name: 'Animators of Kenya',
      type: 'DISCIPLINE' as const,
      description: 'Share work in progress, tools and gigs for animators.',
      isOfficial: true,
      disciplineId: animation?.id,
      members: [nia, zuri],
    },
    {
      slug: 'music-makers',
      name: 'Music Makers',
      type: 'DISCIPLINE' as const,
      description: 'Producers, singers and engineers swapping tips and sessions.',
      isOfficial: false,
      disciplineId: music?.id,
      members: [amani, kiptoo],
    },
    {
      slug: 'atarah-fellows',
      name: 'Atarah Fellows',
      type: 'PROGRAMME' as const,
      description: 'For members of Atarah programmes.',
      isOfficial: true,
      members: [nia, amani],
    },
  ];

  const groups = new Map<string, string>();
  for (const g of groupDefs) {
    const created = await prisma.group.create({
      data: {
        slug: g.slug,
        name: g.name,
        type: g.type,
        description: g.description,
        isOfficial: g.isOfficial,
        countyId: g.countyId ?? null,
        disciplineId: g.disciplineId ?? null,
        createdById: admin.id,
        isDemo: true,
      },
    });
    groups.set(g.slug, created.id);
    await prisma.groupMembership.create({
      data: { groupId: created.id, userId: admin.id, role: 'OWNER' },
    });
    if (g.slug === 'atarah-community' || g.slug === 'nairobi-creatives') {
      await prisma.groupMembership.create({
        data: { groupId: created.id, userId: moderator.id, role: 'MODERATOR' },
      });
    }
    for (const m of g.members) {
      await prisma.groupMembership.create({ data: { groupId: created.id, userId: m.id } });
    }
  }
  const community = groups.get('atarah-community')!;
  const nairobiGroup = groups.get('nairobi-creatives')!;
  const animators = groups.get('animators-of-kenya')!;
  const musicGroup = groups.get('music-makers')!;

  interface PostDef {
    key: string;
    author: string;
    type: PostType;
    audience: PostAudience;
    group?: string;
    body: string;
    hours: number;
    announcement?: boolean;
  }
  const defs: PostDef[] = [
    {
      key: 'welcome',
      author: admin.id,
      type: 'ANNOUNCEMENT',
      audience: 'MEMBERS',
      body: 'Welcome to the Atarah community. Introduce yourself, ask questions and keep to the Community Guidelines.',
      hours: 70,
      announcement: true,
    },
    {
      key: 'group-announcement',
      author: admin.id,
      type: 'ANNOUNCEMENT',
      audience: 'GROUP',
      group: nairobiGroup,
      body: 'Nairobi Creatives meet-up is on the last Saturday of the month. Details in the group.',
      hours: 48,
      announcement: true,
    },
    {
      key: 'update',
      author: nia.id,
      type: 'UPDATE',
      audience: 'PUBLIC',
      body: 'Just wrapped a 30-second animated short for a local NGO. Grateful for everyone who gave feedback on the storyboard.',
      hours: 30,
    },
    {
      key: 'question',
      author: zuri.id,
      type: 'QUESTION',
      audience: 'MEMBERS',
      body: 'How do you price a licence for illustration that will appear on packaging? Looking for a fair starting point.',
      hours: 26,
    },
    {
      key: 'discussion',
      author: amani.id,
      type: 'DISCUSSION',
      audience: 'GROUP',
      group: musicGroup,
      body: 'Do you record vocals at home or book a studio? What made you choose one over the other?',
      hours: 20,
    },
    {
      key: 'collab',
      author: kiptoo.id,
      type: 'COLLABORATION',
      audience: 'MEMBERS',
      body: 'Looking for a composer for a short documentary shot in Eldoret. Small budget, great story.',
      hours: 14,
    },
    {
      key: 'connections-only',
      author: wanjiku.id,
      type: 'UPDATE',
      audience: 'CONNECTIONS',
      body: 'Sharing a few unedited frames from this weekend’s shoot with the people I work with most.',
      hours: 8,
    },
    {
      key: 'animators',
      author: nia.id,
      type: 'DISCUSSION',
      audience: 'GROUP',
      group: animators,
      body: 'Which tools are you using for 2D character rigs right now? Free options welcome.',
      hours: 5,
    },
    {
      key: 'community-intro',
      author: wanjiku.id,
      type: 'UPDATE',
      audience: 'GROUP',
      group: community,
      body: 'Hello everyone, I am a photographer based in Nairobi. Happy to swap feedback on portfolios.',
      hours: 2,
    },
  ];

  const postIds = new Map<string, string>();
  for (const d of defs) {
    const post = await prisma.post.create({
      data: {
        authorId: d.author,
        type: d.type,
        audience: d.audience,
        groupId: d.group ?? null,
        body: d.body,
        isStaffAnnouncement: d.announcement ?? false,
        isDemo: true,
        createdAt: hoursAgo(d.hours),
      },
    });
    postIds.set(d.key, post.id);
  }
  // A link post whose preview was "fetched": no network is used by the seed.
  const linkPost = await prisma.post.create({
    data: {
      authorId: amani.id,
      type: 'UPDATE',
      audience: 'MEMBERS',
      body: 'Useful read on royalties for independent musicians.',
      isDemo: true,
      createdAt: hoursAgo(11),
    },
  });
  await prisma.postLink.create({
    data: {
      postId: linkPost.id,
      url: 'https://example.com/royalties-for-independent-musicians',
      title: 'Royalties for independent musicians',
      description: 'A plain-language guide to how royalties are collected and paid.',
      siteName: 'example.com',
      fetchedAt: new Date(),
    },
  });
  postIds.set('link', linkPost.id);

  // The group announcement is pinned on the group page.
  await prisma.groupPin.create({
    data: {
      groupId: nairobiGroup,
      postId: postIds.get('group-announcement')!,
      pinnedById: admin.id,
    },
  });

  // Comments, with one reply level.
  const c1 = await prisma.comment.create({
    data: {
      postId: postIds.get('question')!,
      authorId: amani.id,
      body: 'Start from usage and duration, then add a margin for revisions. Packaging usually earns a higher fee than editorial.',
      isDemo: true,
      createdAt: hoursAgo(24),
    },
  });
  await prisma.comment.create({
    data: {
      postId: postIds.get('question')!,
      authorId: zuri.id,
      parentCommentId: c1.id,
      body: 'That helps a lot, thank you. I will quote by usage.',
      isDemo: true,
      createdAt: hoursAgo(23),
    },
  });
  await prisma.comment.create({
    data: {
      postId: postIds.get('update')!,
      authorId: wanjiku.id,
      body: 'Congratulations Nia! Would love to see a behind-the-scenes post.',
      isDemo: true,
      createdAt: hoursAgo(28),
    },
  });
  await prisma.comment.create({
    data: {
      postId: postIds.get('discussion')!,
      authorId: kiptoo.id,
      body: 'Home for demos, studio for anything that ships.',
      isDemo: true,
      createdAt: hoursAgo(18),
    },
  });

  // Reactions.
  const likes: Array<[string, string[]]> = [
    ['update', [amani.id, zuri.id, kiptoo.id, wanjiku.id]],
    ['question', [nia.id, amani.id]],
    ['welcome', [nia.id, amani.id, zuri.id]],
    ['collab', [nia.id]],
  ];
  for (const [key, users] of likes) {
    await prisma.reaction.createMany({
      data: users.map((userId) => ({ postId: postIds.get(key)!, userId })),
      skipDuplicates: true,
    });
  }

  // Connections: two accepted, one pending request.
  const accepted = (a: string, b: string) =>
    prisma.connection.create({
      data: { requesterId: a, addresseeId: b, status: 'ACCEPTED', respondedAt: hoursAgo(72) },
    });
  await accepted(nia.id, amani.id);
  await accepted(kiptoo.id, wanjiku.id);
  await accepted(wanjiku.id, nia.id);
  await prisma.connection.create({ data: { requesterId: zuri.id, addresseeId: nia.id } });

  // Counters, computed from the rows just created.
  await prisma.$executeRaw`UPDATE posts p SET "reactionCount" = (SELECT count(*) FROM reactions r WHERE r."postId" = p.id)::int,
    "replyCount" = (SELECT count(*) FROM comments c WHERE c."postId" = p.id AND c.status::text = 'VISIBLE' AND c."deletedAt" IS NULL)::int
    WHERE p."isDemo"`;
  await prisma.$executeRaw`UPDATE groups g SET "memberCount" = (SELECT count(*) FROM group_memberships m WHERE m."groupId" = g.id)::int
    WHERE g."isDemo"`;

  return { groups: groupDefs.length, posts: defs.length + 1 };
}
