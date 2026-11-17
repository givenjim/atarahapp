// Loads the Phase 1 volume seed into the scratch database `atarah_perf` (see setup-perf-db.mjs): 10,000 members,
// 50,000 posts, 200,000 comments, 2,000 opportunities, 500 learning items, 100,000 notifications and the rows around
// them (profiles, projects, connections, reactions, groups, trackings, articles, enrolments). Everything is generated
// inside Postgres with generate_series, so it takes about a minute. Counts are parameters:
//
//   node apps/backend/scripts/perf/load-volume.mjs [--members=10000] [--posts=50000] [--comments=200000]
//        [--opportunities=2000] [--learning=500] [--notifications=100000] [--reactions=100000]
//
// Tables that the current schema does not have yet (learning before P1-M10, `notifications.type` before P1-M11) are
// skipped and reported, never faked. The target is always `atarah_perf` on the local Postgres; the script refuses any
// other database name.
import { createRequire } from 'node:module';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const require = createRequire(
  join(dirname(fileURLToPath(import.meta.url)), '..', '..', 'package.json'),
);
const pg = require('pg');

const arg = (name, dflt) => {
  const hit = process.argv.find((a) => a.startsWith(`--${name}=`));
  return hit ? Number(hit.split('=')[1]) : dflt;
};
const N = arg('members', 10_000);
const POSTS = arg('posts', 50_000);
const COMMENTS = arg('comments', 200_000);
const REACTIONS = arg('reactions', 100_000);
const OPPS = arg('opportunities', 2_000);
const LEARNING = arg('learning', 500);
const NOTES = arg('notifications', 100_000);
const PROVIDERS = 100;
const GROUPS = 40;
const ARTICLES = 300;

const url =
  process.env.ATARAH_PERF_URL ?? 'postgresql://supabase_admin:postgres@127.0.0.1:55322/atarah_perf';
if (!/127\.0\.0\.1|localhost/.test(url) || !url.endsWith('/atarah_perf')) {
  throw new Error('Refusing to load volume data anywhere but the local atarah_perf database.');
}
const client = new pg.Client({ connectionString: url });
await client.connect();
const run = async (label, sql, params = []) => {
  const t = Date.now();
  const res = await client.query(sql, params);
  console.log(
    `  ${label.padEnd(34)} ${String(res.rowCount ?? '').padStart(8)} rows  ${((Date.now() - t) / 1000).toFixed(1)}s`,
  );
};
const exists = async (table, column) =>
  (
    await client.query(
      column
        ? "SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name=$1 AND column_name=$2"
        : "SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name=$1",
      column ? [table, column] : [table],
    )
  ).rowCount > 0;

console.log(
  `Loading volume data into atarah_perf: ${N} members, ${POSTS} posts, ${COMMENTS} comments, ${OPPS} opportunities`,
);
await client.query('SET session_replication_role = replica'); // we generate consistent data ourselves; skip triggers and FK checks
await client.query("SET maintenance_work_mem = '256MB'");

// Clear what an earlier run loaded (only rows flagged as perf data).
await client.query("DELETE FROM notifications WHERE title LIKE 'Perf %'");
await client.query(
  'DELETE FROM reactions WHERE "postId" IN (SELECT id FROM posts WHERE "isDemo" AND body LIKE \'Perf post%\')',
);
await client.query('DELETE FROM comments WHERE "isDemo" AND body LIKE \'Perf comment%\'');
await client.query('DELETE FROM posts WHERE "isDemo" AND body LIKE \'Perf post%\'');
await client.query(
  'DELETE FROM opportunity_trackings WHERE "opportunityId" IN (SELECT id FROM opportunities WHERE slug LIKE \'perf-opp-%\')',
);
await client.query("DELETE FROM opportunities WHERE slug LIKE 'perf-opp-%'");
await client.query("DELETE FROM opportunity_providers WHERE name LIKE 'Perf provider %'");
await client.query(
  'DELETE FROM group_memberships WHERE "groupId" IN (SELECT id FROM groups WHERE slug LIKE \'perf-group-%\')',
);
await client.query("DELETE FROM groups WHERE slug LIKE 'perf-group-%'");
await client.query(
  'DELETE FROM connections WHERE "requesterId" IN (SELECT id FROM users WHERE email LIKE \'perf.%@perf.atarah.test\')',
);
await client.query(
  'DELETE FROM projects WHERE "profileId" IN (SELECT id FROM creative_profiles WHERE handle LIKE \'perf_%\')',
);
await client.query(
  'DELETE FROM creative_skills WHERE "profileId" IN (SELECT id FROM creative_profiles WHERE handle LIKE \'perf_%\')',
);
await client.query(
  'DELETE FROM creative_disciplines WHERE "profileId" IN (SELECT id FROM creative_profiles WHERE handle LIKE \'perf_%\')',
);
await client.query("DELETE FROM creative_profiles WHERE handle LIKE 'perf_%'");
await client.query("DELETE FROM articles WHERE slug LIKE 'perf-article-%'");
await client.query("DELETE FROM users WHERE email LIKE 'perf.%@perf.atarah.test'");
await client.query("DELETE FROM auth.users WHERE email LIKE 'perf.%@perf.atarah.test'");

await client.query('DROP TABLE IF EXISTS pu, pg_d, pg_c, pg_s, pg_g, pg_p, pg_o');
await client.query(
  'CREATE TEMP TABLE pu AS SELECT n, gen_random_uuid() AS id FROM generate_series(1, $1::int) n',
  [N],
);
await client.query('CREATE INDEX ON pu (n)');
await client.query(
  'CREATE TEMP TABLE pg_d AS SELECT row_number() OVER (ORDER BY "sortOrder", id) AS rn, id FROM disciplines',
);
await client.query(
  'CREATE TEMP TABLE pg_c AS SELECT row_number() OVER (ORDER BY "sortOrder", id) AS rn, id, "countryId" FROM counties',
);
await client.query(
  'CREATE TEMP TABLE pg_s AS SELECT row_number() OVER (ORDER BY "sortOrder", id) AS rn, id FROM skills',
);
await client.query(
  'CREATE TEMP TABLE pg_g AS SELECT n, gen_random_uuid() AS id FROM generate_series(1, $1::int) n',
  [GROUPS],
);
await client.query(
  'CREATE TEMP TABLE pg_p AS SELECT n, gen_random_uuid() AS id FROM generate_series(1, $1::int) n',
  [POSTS],
);
await client.query(
  'CREATE TEMP TABLE pg_o AS SELECT n, gen_random_uuid() AS id FROM generate_series(1, $1::int) n',
  [OPPS],
);
await client.query('CREATE INDEX ON pg_p (n)');
await client.query('CREATE INDEX ON pg_o (n)');
const counts = (
  await client.query(
    'SELECT (SELECT count(*) FROM pg_d) d, (SELECT count(*) FROM pg_c) c, (SELECT count(*) FROM pg_s) s',
  )
).rows[0];
if (!Number(counts.d) || !Number(counts.c) || !Number(counts.s))
  throw new Error('Reference data is missing: run setup-perf-db.mjs first');
const D = Number(counts.d),
  C = Number(counts.c),
  S = Number(counts.s);

await run(
  'auth.users',
  `INSERT INTO auth.users (id, aud, role, email, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data)
  SELECT id, 'authenticated', 'authenticated', 'perf.' || n || '@perf.atarah.test', now(), now() - (n % 90) * interval '1 day', now(), '{}'::jsonb, '{}'::jsonb FROM pu`,
);
await run(
  'users',
  `INSERT INTO users (id, email, "emailVerifiedAt", "fullName", status, "lastLoginAt", "isDemo", "createdAt", "updatedAt")
  SELECT id, 'perf.' || n || '@perf.atarah.test', now(), 'Perf Member ' || n, 'ACTIVE',
         CASE WHEN n % 5 < 2 THEN now() - (n % 30) * interval '1 day' ELSE NULL END, true, now() - (n % 90) * interval '1 day', now() FROM pu`,
);
await run(
  'creative_profiles',
  `INSERT INTO creative_profiles (id, "userId", handle, "displayName", headline, bio, "primaryDisciplineId", "countryId", "countyId",
    "onboardingStep", "onboardingCompletedAt", "completionPercent", "createdAt", "updatedAt")
  SELECT gen_random_uuid(), pu.id, 'perf_' || pu.n, 'Perf Member ' || pu.n, 'Creative number ' || pu.n || ' in Kenya',
         'Bio of member ' || pu.n || ' who makes things.', d.id, c."countryId", c.id, 'DONE', now() - (pu.n % 90) * interval '1 day', 40 + (pu.n % 61),
         now() - (pu.n % 90) * interval '1 day', now()
  FROM pu JOIN pg_d d ON d.rn = 1 + (pu.n % $1::int) JOIN pg_c c ON c.rn = 1 + ((pu.n * 7) % $2::int)`,
  [D, C],
);
await run(
  'creative_disciplines',
  `INSERT INTO creative_disciplines ("profileId", "disciplineId", "isPrimary")
  SELECT cp.id, cp."primaryDisciplineId", true FROM creative_profiles cp WHERE cp.handle LIKE 'perf_%'`,
);
await run(
  'creative_skills',
  `INSERT INTO creative_skills ("profileId", "skillId", level, source)
  SELECT cp.id, s.id, 'INTERMEDIATE', 'SELF_DECLARED' FROM creative_profiles cp JOIN pu ON pu.id = cp."userId" CROSS JOIN generate_series(0, 1) k
  JOIN pg_s s ON s.rn = 1 + ((pu.n + k) % $1::int) WHERE cp.handle LIKE 'perf_%' ON CONFLICT DO NOTHING`,
  [S],
);
await run(
  'connections',
  `INSERT INTO connections (id, "requesterId", "addresseeId", status, "createdAt", "updatedAt")
  SELECT DISTINCT ON (LEAST(a.n, b.n), GREATEST(a.n, b.n)) gen_random_uuid(), a.id, b.id, (CASE WHEN a.n % 5 = 0 THEN 'PENDING' ELSE 'ACCEPTED' END)::"ConnectionStatus", now(), now()
  FROM pu a CROSS JOIN generate_series(1, 3) k JOIN pu b ON b.n = 1 + ((a.n * (1000 + k * 37) + k) % $1::int) WHERE a.n <> b.n ON CONFLICT DO NOTHING`,
  [N],
);
await run(
  'projects',
  `INSERT INTO projects (id, "profileId", title, role, category, "disciplineId", description, status, visibility, "publishedAt", "createdAt", "updatedAt")
  SELECT gen_random_uuid(), cp.id, 'Perf project ' || k || ' of ' || pu.n, 'Lead', 'PROJECT', cp."primaryDisciplineId",
         'A perf project description long enough to count as real work.', 'PUBLISHED', 'PUBLIC', now() - ((pu.n + k) % 60) * interval '1 day', now(), now()
  FROM creative_profiles cp JOIN pu ON pu.id = cp."userId", generate_series(1, 3) k WHERE cp.handle LIKE 'perf_%'`,
);
await run(
  'groups',
  `INSERT INTO groups (id, slug, type, name, description, visibility, "memberCount", "isDemo", "createdAt", "updatedAt")
  SELECT id, 'perf-group-' || n, (ARRAY['DISCIPLINE','LOCATION','INTEREST','PROGRAMME'])[1 + n % 4]::"GroupType", 'Perf group ' || n, 'A group for volume tests.', 'OPEN', 0, true, now(), now() FROM pg_g`,
);
await run(
  'group_memberships',
  `INSERT INTO group_memberships (id, "groupId", "userId", role, "createdAt", "updatedAt")
  SELECT gen_random_uuid(), g.id, pu.id, 'MEMBER', now(), now() FROM pu CROSS JOIN generate_series(0, 1) k JOIN pg_g g ON g.n = 1 + ((pu.n + k) % $1::int) ON CONFLICT DO NOTHING`,
  [GROUPS],
);
await run(
  'group member counts',
  `UPDATE groups g SET "memberCount" = m.c FROM (SELECT "groupId", count(*)::int c FROM group_memberships GROUP BY 1) m WHERE m."groupId" = g.id AND g.slug LIKE 'perf-group-%'`,
);
await run(
  'posts',
  `INSERT INTO posts (id, "authorId", type, body, audience, "groupId", status, "isDemo", "createdAt", "updatedAt")
  SELECT p.id, pu.id, (ARRAY['UPDATE','QUESTION','DISCUSSION','COLLABORATION'])[1 + p.n % 4]::"PostType",
         'Perf post ' || p.n || ': ' || (ARRAY['animation','music','fashion','film','photography','writing','design','dance','acting','poetry','sculpture','weaving','mural','beadwork','podcast','storyboard','colour','lighting','editing','mixing','mastering','tailoring','costume','portrait','landscape','documentary','festival','residency','grant','commission','workshop','mentor','portfolio','pricing','contract','invoice','copyright','exhibition','rehearsal','recording','studio','gallery','market','collaboration','feedback','critique','budget','casting','script','soundtrack','kiswahili','sheng','nairobi','mombasa','kisumu','nakuru','eldoret','lamu','kilifi','machakos'])[1 + (p.n * 7) % 60] || ' ' || (ARRAY['animation','music','fashion','film','photography','writing','design','dance','acting','poetry','sculpture','weaving','mural','beadwork','podcast','storyboard','colour','lighting','editing','mixing','mastering','tailoring','costume','portrait','landscape','documentary','festival','residency','grant','commission','workshop','mentor','portfolio','pricing','contract','invoice','copyright','exhibition','rehearsal','recording','studio','gallery','market','collaboration','feedback','critique','budget','casting','script','soundtrack','kiswahili','sheng','nairobi','mombasa','kisumu','nakuru','eldoret','lamu','kilifi','machakos'])[1 + (p.n * 13 + 5) % 60] || ' from member ' || pu.n,
         CASE WHEN p.n % 20 < 11 THEN 'MEMBERS' WHEN p.n % 20 < 16 THEN 'PUBLIC' WHEN p.n % 20 < 18 THEN 'CONNECTIONS' ELSE 'GROUP' END::"PostAudience",
         CASE WHEN p.n % 20 >= 18 THEN g.id END, 'VISIBLE', true,
         now() - (p.n % 90) * interval '1 day' - (p.n % 1440) * interval '1 minute', now()
  FROM pg_p p JOIN pu ON pu.n = 1 + ((p.n * 17) % $1::int) LEFT JOIN pg_g g ON g.n = 1 + (p.n % $2::int)`,
  [N, GROUPS],
);
await run(
  'comments',
  `INSERT INTO comments (id, "postId", "authorId", body, status, "isDemo", "createdAt", "updatedAt")
  SELECT gen_random_uuid(), p.id, pu.id, 'Perf comment ' || k, 'VISIBLE', true, now() - (k % 60) * interval '1 hour', now()
  FROM generate_series(1, $1::int) k JOIN pg_p p ON p.n = 1 + (k % $2::int) JOIN pu ON pu.n = 1 + ((k * 31) % $3::int)`,
  [COMMENTS, POSTS, N],
);
await run(
  'reactions',
  `INSERT INTO reactions (id, "postId", "userId", "createdAt")
  SELECT gen_random_uuid(), p.id, pu.id, now() FROM generate_series(1, $1::int) k JOIN pg_p p ON p.n = 1 + (k % $2::int)
  JOIN pu ON pu.n = 1 + ((k * 37 + k / $2::int) % $3::int) ON CONFLICT DO NOTHING`,
  [REACTIONS, POSTS, N],
);
await run(
  'post counters',
  `UPDATE posts p SET "reactionCount" = COALESCE(r.c, 0), "replyCount" = COALESCE(c.c, 0)
  FROM (SELECT id FROM posts WHERE "isDemo" AND body LIKE 'Perf post%') x
  LEFT JOIN (SELECT "postId", count(*)::int c FROM reactions GROUP BY 1) r ON r."postId" = x.id
  LEFT JOIN (SELECT "postId", count(*)::int c FROM comments WHERE body LIKE 'Perf comment%' GROUP BY 1) c ON c."postId" = x.id WHERE p.id = x.id`,
);

await run(
  'opportunity_providers',
  `INSERT INTO opportunity_providers (id, name, type, "verificationStatus", "isDemo", "createdAt", "updatedAt")
  SELECT gen_random_uuid(), 'Perf provider ' || n, (ARRAY['GOVERNMENT','NGO','CORPORATE','FESTIVAL','STUDIO','EDUCATION','OTHER'])[1 + n % 7]::"OpportunityProviderType",
         CASE WHEN n % 3 = 0 THEN 'VERIFIED' ELSE 'NOT_SUBMITTED' END::"VerificationStatus", true, now(), now() FROM generate_series(1, $1::int) n`,
  [PROVIDERS],
);
await run(
  'opportunities',
  `INSERT INTO opportunities (id, "providerId", slug, type, title, summary, about, requirements, benefits, "deadlineAt", "countyId", "countryId", "workMode",
    "applicationUrl", "applicationDomain", trust, status, "featuredUntil", "publishedAt", "isDemo", "createdAt", "updatedAt")
  SELECT o.id, (SELECT id FROM opportunity_providers WHERE name = 'Perf provider ' || (1 + o.n % $2::int)), 'perf-opp-' || o.n,
         (ARRAY['GRANT','FUNDING','JOB','INTERNSHIP','GIG','COMPETITION','FESTIVAL','PARTNERSHIP','FELLOWSHIP','RESIDENCY','PROGRAMME'])[1 + o.n % 11]::"OpportunityType",
         'Perf opportunity ' || o.n || ' for creatives', 'A summary of opportunity ' || o.n || ' for volume testing.', 'About text.', '["Be Kenyan"]'::jsonb, '["Pay"]'::jsonb,
         now() + ((o.n % 125) - 5) * interval '1 day', c.id, c."countryId", (ARRAY['ONSITE','REMOTE','HYBRID'])[1 + o.n % 3]::"WorkMode",
         'https://perf.example.org/apply/' || o.n, 'perf.example.org', (ARRAY['VERIFIED','SOURCE_CONFIRMED','EXTERNAL_SOURCE'])[1 + o.n % 3]::"OpportunityTrust",
         CASE WHEN o.n % 20 < 17 THEN 'PUBLISHED' WHEN o.n % 20 = 17 THEN 'DRAFT' WHEN o.n % 20 = 18 THEN 'EXPIRED' ELSE 'CLOSED' END::"OpportunityStatus",
         CASE WHEN o.n % 100 = 0 THEN now() + interval '10 days' END, now() - (o.n % 60) * interval '1 day', true, now(), now()
  FROM pg_o o JOIN pg_c c ON c.rn = 1 + (o.n % $1::int)`,
  [C, PROVIDERS],
);
await run(
  'opportunity_disciplines',
  `INSERT INTO opportunity_disciplines ("opportunityId", "disciplineId")
  SELECT o.id, d.id FROM pg_o o JOIN pg_d d ON d.rn = 1 + (o.n % $1::int) WHERE o.n % 3 <> 0`,
  [D],
);
await run(
  'opportunity_trackings',
  `INSERT INTO opportunity_trackings (id, "userId", "opportunityId", status, "savedAt", "createdAt", "updatedAt")
  SELECT gen_random_uuid(), pu.id, o.id, (ARRAY['SAVED','SAVED','IN_PROGRESS','APPLIED'])[1 + k % 4]::"OpportunityTrackingStatus", now(), now(), now()
  FROM generate_series(1, 20000) k JOIN pu ON pu.n = 1 + ((k * 13) % $1::int) JOIN pg_o o ON o.n = 1 + (k % $2::int) ON CONFLICT DO NOTHING`,
  [N, OPPS],
);
await run(
  'provider counts',
  `UPDATE opportunity_providers p SET "opportunitiesCount" = c.n FROM (SELECT "providerId", count(*)::int n FROM opportunities WHERE status = 'PUBLISHED' GROUP BY 1) c WHERE c."providerId" = p.id AND p.name LIKE 'Perf provider %'`,
);

const author = (
  await client.query("SELECT id FROM users WHERE email LIKE 'perf.%@perf.atarah.test' LIMIT 1")
).rows[0].id;
await run(
  'articles',
  `INSERT INTO articles (id, slug, title, summary, body, "authorName", source, "readMinutes", status, "publishedAt", tags, "createdById", "isDemo", "createdAt", "updatedAt")
  SELECT gen_random_uuid(), 'perf-article-' || n, 'Perf article ' || n || ' on pricing and portfolios', 'A summary of article ' || n, '[]'::jsonb, 'Perf Editor', 'ATARAH', 3, 'PUBLISHED',
         now() - (n % 120) * interval '1 day', ARRAY['animation','music','portfolio'], $2::uuid, true, now(), now() FROM generate_series(1, $1::int) n`,
  [ARTICLES, author],
);

if (await exists('notifications', 'type')) {
  await run(
    'notifications',
    `INSERT INTO notifications (id, "userId", category, type, title, body, "deepLink", "readAt", "createdAt", "updatedAt")
    SELECT gen_random_uuid(), pu.id, (ARRAY['OPPORTUNITIES','COMMUNITY','LEARNING','PROFILE','SYSTEM'])[1 + k % 5]::"NotificationCategory", 'generic', 'Perf notification ' || k, 'Body ' || k,
           '/home', CASE WHEN k % 3 = 0 THEN NULL ELSE now() - (k % 20) * interval '1 hour' END, now() - (k % 170) * interval '1 day' - (k % 1440) * interval '1 minute', now()
    FROM generate_series(1, $1::int) k JOIN pu ON pu.n = 1 + ((k * 11) % $2::int)`,
    [NOTES, N],
  );
} else {
  await run(
    'notifications',
    `INSERT INTO notifications (id, "userId", category, title, body, "deepLink", "readAt", "createdAt", "updatedAt")
    SELECT gen_random_uuid(), pu.id, (ARRAY['OPPORTUNITIES','COMMUNITY','LEARNING','PROFILE','SYSTEM'])[1 + k % 5]::"NotificationCategory", 'Perf notification ' || k, 'Body ' || k,
           '/home', CASE WHEN k % 3 = 0 THEN NULL ELSE now() - (k % 20) * interval '1 hour' END, now() - (k % 170) * interval '1 day' - (k % 1440) * interval '1 minute', now()
    FROM generate_series(1, $1::int) k JOIN pu ON pu.n = 1 + ((k * 11) % $2::int)`,
    [NOTES, N],
  );
}

if (await exists('learning_contents')) {
  await client.query('DROP TABLE IF EXISTS pg_l');
  await client.query(
    'CREATE TEMP TABLE pg_l AS SELECT n, gen_random_uuid() AS id FROM generate_series(1, $1::int) n',
    [LEARNING],
  );
  await client.query(
    'DELETE FROM enrolments WHERE "courseId" IN (SELECT id FROM learning_contents WHERE slug LIKE \'perf-learn-%\')',
  );
  await client.query(
    'DELETE FROM lessons WHERE "courseId" IN (SELECT id FROM learning_contents WHERE slug LIKE \'perf-learn-%\')',
  );
  await client.query(
    'DELETE FROM courses WHERE "contentId" IN (SELECT id FROM learning_contents WHERE slug LIKE \'perf-learn-%\')',
  );
  await client.query("DELETE FROM learning_contents WHERE slug LIKE 'perf-learn-%'");
  await run(
    'learning_contents',
    `INSERT INTO learning_contents (id, slug, type, title, summary, "categoryId", level, "durationMinutes", source, delivery, status, "publishedAt", featured, "isDemo", "createdAt", "updatedAt")
    SELECT l.id, 'perf-learn-' || l.n, (ARRAY['COURSE','COURSE','TUTORIAL','TOOLKIT','WEBINAR','MASTERCLASS'])[1 + l.n % 6]::"LearningContentType", 'Perf learning item ' || l.n, 'Summary ' || l.n,
           (SELECT id FROM learning_categories ORDER BY "sortOrder", id OFFSET (l.n % 15) LIMIT 1), 'BEGINNER', 30 + l.n % 90, 'ATARAH', 'NATIVE', 'PUBLISHED', now() - (l.n % 60) * interval '1 day', l.n % 50 = 0, true, now(), now()
    FROM pg_l l`,
  );
  await run(
    'courses',
    `INSERT INTO courses ("contentId", "lessonCount", "totalMinutes", sequential) SELECT id, 6, 180, true FROM learning_contents WHERE slug LIKE 'perf-learn-%' AND type = 'COURSE'`,
  );
  await run(
    'lessons',
    `INSERT INTO lessons (id, "courseId", sequence, title, "durationMinutes", body, "createdAt", "updatedAt")
    SELECT gen_random_uuid(), c."contentId", s, 'Lesson ' || s, 30, '[]'::jsonb, now(), now() FROM courses c JOIN learning_contents lc ON lc.id = c."contentId", generate_series(1, 6) s WHERE lc.slug LIKE 'perf-learn-%'`,
  );
  await run(
    'enrolments',
    `INSERT INTO enrolments (id, "userId", "courseId", "enrolledAt", "completedAt")
    SELECT gen_random_uuid(), pu.id, c."contentId", now() - (k % 30) * interval '1 day', CASE WHEN k % 4 = 0 THEN now() END
    FROM generate_series(1, 5000) k JOIN pu ON pu.n = 1 + ((k * 23) % $1::int)
    JOIN (SELECT "contentId", row_number() OVER () rn FROM courses c2 JOIN learning_contents l2 ON l2.id = c2."contentId" WHERE l2.slug LIKE 'perf-learn-%') c ON c.rn = 1 + (k % (SELECT count(*) FROM courses c3 JOIN learning_contents l3 ON l3.id = c3."contentId" WHERE l3.slug LIKE 'perf-learn-%')) ON CONFLICT DO NOTHING`,
    [N],
  );
} else {
  console.log('  learning tables not present: skipped (load again after P1-M10 is installed)');
}

await client.query('SET session_replication_role = DEFAULT');
await run('ANALYZE', 'ANALYZE');
const total = (
  await client.query(`SELECT
  (SELECT count(*) FROM users) users, (SELECT count(*) FROM posts) posts, (SELECT count(*) FROM comments) comments, (SELECT count(*) FROM opportunities) opportunities,
  (SELECT count(*) FROM notifications) notifications, (SELECT count(*) FROM reactions) reactions, (SELECT count(*) FROM connections) connections, (SELECT count(*) FROM projects) projects`)
).rows[0];
console.log('Totals in atarah_perf:', JSON.stringify(total));
await client.end();
