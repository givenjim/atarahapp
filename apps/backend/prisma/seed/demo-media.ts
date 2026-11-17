import { createHash } from 'node:crypto';
import { existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
import { type Prisma, type PrismaClient } from '@prisma/client';
import { type SupabaseClient } from '@supabase/supabase-js';
import sharp from 'sharp';

/**
 * Placeholder pictures for development (DEC-088). Every place the app shows a picture gets one: profile photos,
 * portfolio projects, article heroes and an inline article image, group covers, Skill Labs covers, opportunity
 * provider logos, community post photos and the link-preview image.
 *
 * The files live in `prisma/seed/media/` (generated offline: Open Peeps portraits, CC0, through DiceBear; artwork and
 * logos drawn for Atarah). Each use gets its own `media_assets` row (owner = the member it belongs to) stored in the
 * public bucket with the same 200/600/1200 px WebP renditions the media worker makes, so the API serves them exactly
 * like real uploads. Only empty slots are filled: a picture someone chose is never replaced. Safe to run again.
 *
 * By default only demo records are touched. `everything: true` (development databases only) also fills empty
 * slots on other records: every profile without a photo, and articles, groups, Skill Labs and providers without a
 * picture. Portfolios and posts are only added for the demo members.
 */

const DIR = join(__dirname, 'media');
const WIDTHS = [200, 600, 1200] as const;

const DEMO_AVATARS: Record<string, string> = {
  'nia@demo.atarah.test': 'nia-wairimu',
  'amani@demo.atarah.test': 'amani-otieno',
  'zuri@demo.atarah.test': 'zuri-mwangi',
  'kiptoo@demo.atarah.test': 'kiptoo-langat',
  'wanjiku@demo.atarah.test': 'wanjiku-njeri',
  'moderator@demo.atarah.test': 'demo-moderator',
  'admin@demo.atarah.test': 'demo-admin',
  'superadmin@demo.atarah.test': 'demo-super-admin',
};
const AVATAR_POOL = Array.from({ length: 12 }, (_, i) => `pool-${String(i + 1).padStart(2, '0')}`);

interface ProjectSeed {
  title: string;
  role: string;
  client: string | null;
  description: string;
  outcome: string | null;
  monthsAgo: number;
  captions: [string, string];
}

/** Three demo projects per demo creative; pictures are `portfolio/<handle>-<project>-<n>.jpg`. */
const PORTFOLIO: Record<string, { file: string; projects: ProjectSeed[] }> = {
  'nia@demo.atarah.test': {
    file: 'nia-wairimu',
    projects: [
      {
        title: 'Kibanda Tales',
        role: 'Director and lead animator',
        client: 'Community health NGO (demo)',
        description: 'A 30-second 2D short about a corner kiosk that becomes the heart of a neighbourhood.',
        outcome: 'Screened at three community events.',
        monthsAgo: 2,
        captions: ['Key frame from the opening shot', 'Colour script'],
      },
      {
        title: 'Matatu Dreams title sequence',
        role: 'Motion designer',
        client: 'Independent film (demo)',
        description: 'Hand-drawn title cards inspired by matatu art and Nairobi signage.',
        outcome: null,
        monthsAgo: 7,
        captions: ['Title card', 'Style frames'],
      },
      {
        title: 'Character sheet: Wanjiru',
        role: 'Character designer',
        client: null,
        description: 'Turnarounds and expressions for an original children’s series pitch.',
        outcome: null,
        monthsAgo: 12,
        captions: ['Turnaround', 'Expressions'],
      },
    ],
  },
  'amani@demo.atarah.test': {
    file: 'amani-otieno',
    projects: [
      {
        title: 'Sauti EP',
        role: 'Producer and mix engineer',
        client: 'Independent artist (demo)',
        description: 'Five-track afro-soul EP recorded between a home studio and a hired live room.',
        outcome: 'Released on all major streaming platforms.',
        monthsAgo: 3,
        captions: ['Session artwork', 'Studio day'],
      },
      {
        title: 'Live session series',
        role: 'Music director',
        client: null,
        description: 'Monthly stripped-back live sessions with emerging Nairobi vocalists.',
        outcome: null,
        monthsAgo: 6,
        captions: ['Session two', 'Behind the desk'],
      },
      {
        title: 'Beat-making workshops',
        role: 'Mentor',
        client: 'Youth arts programme (demo)',
        description: 'Six-week introduction to production for first-time producers.',
        outcome: '24 participants finished a first track.',
        monthsAgo: 10,
        captions: ['Workshop poster', 'Final showcase'],
      },
    ],
  },
  'zuri@demo.atarah.test': {
    file: 'zuri-mwangi',
    projects: [
      {
        title: 'Coastal linocut series',
        role: 'Illustrator and print maker',
        client: null,
        description: 'Eight hand-pulled prints of everyday life along the Mombasa shoreline.',
        outcome: 'Edition of 20 sold out.',
        monthsAgo: 1,
        captions: ['Print three', 'Studio proofs'],
      },
      {
        title: 'Proverbs poster set',
        role: 'Illustrator',
        client: 'Cultural centre (demo)',
        description: 'A set of illustrated posters pairing Swahili proverbs with bold coastal colour.',
        outcome: null,
        monthsAgo: 5,
        captions: ['Poster one', 'Poster two'],
      },
      {
        title: 'Book cover: The Salt Road',
        role: 'Cover illustrator',
        client: 'Small press (demo)',
        description: 'Cover and chapter openers for a debut novel.',
        outcome: null,
        monthsAgo: 9,
        captions: ['Final cover', 'Sketches'],
      },
    ],
  },
  'kiptoo@demo.atarah.test': {
    file: 'kiptoo-langat',
    projects: [
      {
        title: 'Rift Runners',
        role: 'Director and cinematographer',
        client: null,
        description: 'A short documentary following young athletes training in Iten.',
        outcome: 'Official selection at a regional festival (demo).',
        monthsAgo: 4,
        captions: ['Dawn training', 'On the track'],
      },
      {
        title: 'Highland coffee brand film',
        role: 'Director',
        client: 'Coffee cooperative (demo)',
        description: 'A 90-second brand film from cherry to cup.',
        outcome: null,
        monthsAgo: 8,
        captions: ['Harvest', 'Roastery'],
      },
      {
        title: 'Music video: Usiku',
        role: 'Director of photography',
        client: 'Independent artist (demo)',
        description: 'A night-time single-location music video lit with practical lights.',
        outcome: null,
        monthsAgo: 14,
        captions: ['Lighting test', 'Final frame'],
      },
    ],
  },
  'wanjiku@demo.atarah.test': {
    file: 'wanjiku-njeri',
    projects: [
      {
        title: 'Nairobi streets',
        role: 'Photographer',
        client: null,
        description: 'An ongoing street photography series across the CBD and Eastlands.',
        outcome: null,
        monthsAgo: 1,
        captions: ['Moi Avenue', 'Evening rush'],
      },
      {
        title: 'Portraits of makers',
        role: 'Portrait photographer',
        client: 'Craft collective (demo)',
        description: 'Environmental portraits of artisans in their workshops.',
        outcome: 'Used across the collective’s website and catalogue.',
        monthsAgo: 6,
        captions: ['The weaver', 'The carver'],
      },
      {
        title: 'Lamu light',
        role: 'Photographer',
        client: null,
        description: 'Personal travel series on light and architecture in Lamu old town.',
        outcome: null,
        monthsAgo: 11,
        captions: ['Morning', 'Doorways'],
      },
    ],
  },
};

const GROUP_COVERS = ['atarah-community', 'nairobi-creatives', 'animators-of-kenya', 'music-makers', 'atarah-fellows'];

/** Demo posts that get photos, found by the start of their text (see demo-community.ts). */
const POST_PHOTOS: { startsWith: string; files: string[] }[] = [
  { startsWith: 'Just wrapped a 30-second animated short', files: ['animated-short'] },
  { startsWith: 'Nairobi Creatives meet-up', files: ['meetup'] },
  { startsWith: 'Looking for a composer for a short documentary', files: ['documentary'] },
  { startsWith: 'Sharing a few unedited frames', files: ['shoot-1', 'shoot-2', 'shoot-3'] },
];

const slugify = (s: string) =>
  s
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');

/** Stable small number from a string, to spread the pools without randomness. */
const bucketOf = (s: string, n: number) =>
  createHash('sha256').update(s).digest().readUInt32BE(0) % n;

export interface DemoMediaResult {
  avatars: number;
  projects: number;
  articles: number;
  groups: number;
  learning: number;
  providers: number;
  posts: number;
}

export async function seedDemoMedia(
  prisma: PrismaClient,
  supabase: SupabaseClient,
  options: { everything?: boolean } = {},
): Promise<DemoMediaResult> {
  if (!existsSync(DIR)) throw new Error(`Placeholder pictures not found in ${DIR}`);
  const bucket = process.env.ATARAH_STORAGE_BUCKET_PUBLIC;
  if (!bucket) throw new Error('ATARAH_STORAGE_BUCKET_PUBLIC is required to seed pictures');
  await ensurePublicBucket(supabase, bucket);
  const result: DemoMediaResult = {
    avatars: 0,
    projects: 0,
    articles: 0,
    groups: 0,
    learning: 0,
    providers: 0,
    posts: 0,
  };

  /** Upload one picture for one use (a unique key) and return its READY media id. Reuses it if already there. */
  const image = async (file: string, useKey: string, ownerId: string | null): Promise<string> => {
    const base = `media/seed/${useKey}`;
    const objectKey = `${base}/original.jpg`;
    const existing = await prisma.mediaAsset.findUnique({
      where: { bucket_objectKey: { bucket: 'PUBLIC', objectKey } },
    });
    if (existing && existing.status === 'READY' && !existing.deletedAt) return existing.id;

    const bytes = readFileSync(join(DIR, `${file}.jpg`));
    const meta = await sharp(bytes).metadata();
    await put(supabase, bucket, objectKey, bytes, 'image/jpeg');
    const variants: Record<string, string> = {};
    for (const w of WIDTHS) {
      const key = `${base}/w${w}.webp`;
      const data = await sharp(bytes)
        .resize({ width: w, withoutEnlargement: true })
        .webp({ quality: 80 })
        .toBuffer();
      await put(supabase, bucket, key, data, 'image/webp');
      variants[String(w)] = key;
    }
    const data = {
      ownerId,
      kind: 'IMAGE' as const,
      bucket: 'PUBLIC' as const,
      objectKey,
      mimeType: 'image/jpeg',
      sizeBytes: BigInt(bytes.length),
      status: 'READY' as const,
      width: meta.width ?? null,
      height: meta.height ?? null,
      variants,
      checksum: createHash('sha256').update(bytes).digest('hex'),
      deletedAt: null,
    };
    const row = existing
      ? await prisma.mediaAsset.update({ where: { id: existing.id }, data })
      : await prisma.mediaAsset.create({ data });
    return row.id;
  };

  // ---- profile photos ----
  const profiles = await prisma.creativeProfile.findMany({
    where: {
      avatarMediaId: null,
      ...(options.everything ? {} : { user: { email: { in: Object.keys(DEMO_AVATARS) } } }),
    },
    select: { id: true, userId: true, user: { select: { email: true } } },
  });
  for (const p of profiles) {
    const file = (p.user.email && DEMO_AVATARS[p.user.email]) ?? AVATAR_POOL[bucketOf(p.id, AVATAR_POOL.length)]!;
    const id = await image(`avatars/${file}`, `avatar-${p.id}`, p.userId);
    await prisma.creativeProfile.update({ where: { id: p.id }, data: { avatarMediaId: id } });
    result.avatars += 1;
  }

  // ---- portfolio projects ----
  for (const [email, def] of Object.entries(PORTFOLIO)) {
    const profile = await prisma.creativeProfile.findFirst({
      where: { user: { email } },
      select: { id: true, userId: true, primaryDisciplineId: true, _count: { select: { projects: true } } },
    });
    if (!profile || profile._count.projects > 0) continue;
    for (const [i, pr] of def.projects.entries()) {
      const when = new Date();
      when.setUTCMonth(when.getUTCMonth() - pr.monthsAgo, 1);
      const project = await prisma.project.create({
        data: {
          profileId: profile.id,
          title: pr.title,
          role: pr.role,
          client: pr.client,
          description: pr.description,
          outcome: pr.outcome,
          projectDate: when,
          category: 'PROJECT',
          disciplineId: profile.primaryDisciplineId,
          featured: i === 0,
          status: 'PUBLISHED',
          visibility: 'PUBLIC',
          publishedAt: when,
        },
      });
      for (const n of [1, 2] as const) {
        const mediaId = await image(
          `portfolio/${def.file}-${i + 1}-${n}`,
          `project-${project.id}-${n}`,
          profile.userId,
        );
        await prisma.projectMedia.create({
          data: { projectId: project.id, mediaId, sortOrder: n - 1, caption: pr.captions[n - 1] },
        });
      }
      result.projects += 1;
    }
  }

  // ---- articles: hero picture, plus one inline picture in the first article ----
  const articles = await prisma.article.findMany({ where: options.everything ? {} : { isDemo: true } });
  for (const a of articles) {
    const file = existsSync(join(DIR, 'articles', `${a.slug}.jpg`))
      ? `articles/${a.slug}`
      : `learning/generic-${bucketOf(a.id, 3) + 1}`;
    let changed = false;
    const data: Prisma.ArticleUpdateInput = {};
    if (!a.heroMediaId) {
      data.heroMedia = { connect: { id: await image(file, `article-hero-${a.id}`, a.createdById) } };
      changed = true;
    }
    const blocks = Array.isArray(a.body) ? (a.body as Prisma.JsonArray) : [];
    const hasImage = blocks.some((b) => (b as { type?: string } | null)?.type === 'image');
    if (a.slug === 'how-to-price-commissioned-illustration-in-kenya' && !hasImage && blocks.length > 1) {
      const mediaId = await image('articles/inline-studio', `article-inline-${a.id}`, a.createdById);
      const next = [...blocks];
      next.splice(2, 0, { type: 'image', mediaId, caption: 'Work in progress in a Nairobi studio (placeholder)' });
      data.body = next;
      changed = true;
    }
    if (changed) {
      await prisma.article.update({ where: { id: a.id }, data });
      result.articles += 1;
    }
  }

  // ---- group covers ----
  const groups = await prisma.group.findMany({ where: { coverMediaId: null, ...(options.everything ? {} : { isDemo: true }) } });
  for (const g of groups) {
    const file = GROUP_COVERS.includes(g.slug)
      ? g.slug
      : GROUP_COVERS[bucketOf(g.id, GROUP_COVERS.length)]!;
    const id = await image(`groups/${file}`, `group-${g.id}`, g.createdById);
    await prisma.group.update({ where: { id: g.id }, data: { coverMediaId: id } });
    result.groups += 1;
  }

  // ---- Skill Labs covers ----
  const labs = await prisma.learningContent.findMany({
    where: { coverMediaId: null, ...(options.everything ? {} : { isDemo: true }) },
  });
  for (const l of labs) {
    const named = slugify(l.title);
    const file = existsSync(join(DIR, 'learning', `${named}.jpg`))
      ? named
      : `generic-${bucketOf(l.id, 3) + 1}`;
    const id = await image(`learning/${file}`, `learning-${l.id}`, null);
    await prisma.learningContent.update({ where: { id: l.id }, data: { coverMediaId: id } });
    result.learning += 1;
  }

  // ---- opportunity provider logos ----
  const providers = await prisma.opportunityProvider.findMany({
    where: { logoMediaId: null, ...(options.everything ? {} : { isDemo: true }) },
  });
  for (const p of providers) {
    const named = slugify(p.name);
    const file = existsSync(join(DIR, 'providers', `${named}.jpg`))
      ? named
      : `generic-${bucketOf(p.id, 4) + 1}`;
    const id = await image(`providers/${file}`, `provider-${p.id}`, null);
    await prisma.opportunityProvider.update({ where: { id: p.id }, data: { logoMediaId: id } });
    result.providers += 1;
  }

  // ---- community posts ----
  for (const def of POST_PHOTOS) {
    const post = await prisma.post.findFirst({
      where: { isDemo: true, body: { startsWith: def.startsWith }, media: { none: {} } },
    });
    if (!post) continue;
    for (const [i, file] of def.files.entries()) {
      const mediaAssetId = await image(`posts/${file}`, `post-${post.id}-${i}`, post.authorId);
      await prisma.postMedia.create({ data: { postId: post.id, mediaAssetId, sortOrder: i } });
    }
    result.posts += 1;
  }
  // The link preview stores an image address, not a media id: point it at the public object.
  const links = await prisma.postLink.findMany({ where: { image: null, post: { isDemo: true } } });
  if (links.length) {
    await image('posts/link-preview', 'link-preview', null);
    const base = (process.env.ATARAH_SUPABASE_PUBLIC_URL || process.env.ATARAH_SUPABASE_URL || '').replace(/\/$/, '');
    const url = `${base}/storage/v1/object/public/${bucket}/media/seed/link-preview/w1200.webp`;
    await prisma.postLink.updateMany({ where: { id: { in: links.map((l) => l.id) } }, data: { image: url } });
  }

  return result;
}

async function ensurePublicBucket(supabase: SupabaseClient, name: string): Promise<void> {
  const { data, error } = await supabase.storage.listBuckets();
  if (error) throw new Error(`Could not list storage buckets: ${error.message}`);
  if ((data ?? []).some((b) => b.name === name)) return;
  const created = await supabase.storage.createBucket(name, { public: true });
  if (created.error) throw new Error(`Could not create bucket ${name}: ${created.error.message}`);
}

async function put(
  supabase: SupabaseClient,
  bucket: string,
  key: string,
  body: Buffer,
  contentType: string,
): Promise<void> {
  const { error } = await supabase.storage.from(bucket).upload(key, body, { contentType, upsert: true });
  if (error) throw new Error(`Upload of ${key} failed: ${error.message}`);
}
