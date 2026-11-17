import { execFileSync } from 'node:child_process';
import path from 'node:path';
import { type INestApplication } from '@nestjs/common';
import { type RealtimeChannel } from '@supabase/supabase-js';
import { PrismaService } from '../src/prisma/prisma.service';
import { anonClient, createTestApp, loginMember, makeUser } from './helpers';

const REPO_ROOT = path.resolve(__dirname, '..', '..', '..');

describe('Supabase platform posture (RLS, anon key, Realtime)', () => {
  let app: INestApplication;
  let prisma: PrismaService;

  beforeAll(async () => {
    app = await createTestApp();
    prisma = app.get(PrismaService);
  });
  afterAll(async () => {
    await app.close();
  });

  it('passes scripts/check-rls.sql: RLS everywhere, one allow-listed policy, anon has no grants', () => {
    const out = execFileSync('node', ['scripts/check-rls.mjs'], {
      cwd: REPO_ROOT,
      env: process.env,
      encoding: 'utf8',
    });
    expect(out).toMatch(/check-rls: OK/);
  });

  it('every table in the public schema has RLS enabled', async () => {
    const rows = await prisma.$queryRaw<Array<{ tablename: string; rowsecurity: boolean }>>`
      SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public'`;
    expect(rows.length).toBeGreaterThan(40);
    expect(rows.filter((r) => !r.rowsecurity)).toEqual([]);
  });

  describe('the anon (publishable) key cannot read or write any application table', () => {
    it('is refused on every table, for reads and writes', async () => {
      const tables = await prisma.$queryRaw<Array<{ tablename: string }>>`
        SELECT t.tablename FROM pg_tables t
        JOIN pg_class c ON c.relname = t.tablename AND c.relnamespace = 'public'::regnamespace
        WHERE t.schemaname = 'public' AND NOT c.relispartition
        ORDER BY t.tablename`;
      // Monthly partitions of analytics_events are children: PostgREST does not expose them at all (PGRST205), so the
      // partitioned parent is what is tested here; the RLS-enabled check above still covers every partition.
      const anon = anonClient();
      for (const { tablename } of tables) {
        const read = await anon.from(tablename).select('*').limit(1);
        expect([tablename, read.error === null && (read.data?.length ?? 0) > 0]).toEqual([
          tablename,
          false,
        ]);
        expect([tablename, read.error?.code]).toEqual([tablename, '42501']); // permission denied
        const write = await anon.from(tablename).insert({});
        expect([tablename, write.error === null]).toEqual([tablename, false]);
      }
    });

    it('cannot call the backend-only functions, or read the auth schema through the API', async () => {
      const anon = anonClient();
      const fn = await anon.rpc('atarah_auth_count_sessions', {
        p_user: '00000000-0000-4000-8000-000000000001',
      });
      expect(fn.error).not.toBeNull();
      const authSchema = await anon
        .schema('auth' as never)
        .from('users' as never)
        .select('*');
      expect(authSchema.error).not.toBeNull();
    });
  });

  describe('a signed-in member holds no data privileges either, except their own notifications', () => {
    it('reads nothing from users, profiles or connections, and sees only their own notifications', async () => {
      const a = await makeUser(app);
      const b = await makeUser(app);
      const sa = await loginMember(app, a.email);
      await prisma.notification.create({
        data: { userId: a.user.id, category: 'SYSTEM', title: 'For A', body: 'a' },
      });
      await prisma.notification.create({
        data: { userId: b.user.id, category: 'SYSTEM', title: 'For B', body: 'b' },
      });

      for (const table of [
        'users',
        'creative_profiles',
        'connections',
        'memberships',
        'audit_logs',
      ]) {
        const res = await sa.client.from(table).select('*').limit(1);
        expect([table, res.error?.code]).toEqual([table, '42501']);
      }

      const own = await sa.client.from('notifications').select('title');
      expect(own.error).toBeNull();
      expect(own.data).toEqual([{ title: 'For A' }]);

      const write = await sa.client
        .from('notifications')
        .update({ title: 'hacked' })
        .eq('userId', a.user.id);
      expect(write.error).not.toBeNull();
      const del = await sa.client.from('notifications').delete().eq('userId', a.user.id);
      expect(del.error).not.toBeNull();
    });
  });

  describe('Realtime', () => {
    it('delivers a member their own new notifications, and nobody else’s', async () => {
      const a = await makeUser(app);
      const b = await makeUser(app);
      const sa = await loginMember(app, a.email);
      await sa.client.realtime.setAuth(sa.accessToken);

      const received: string[] = [];
      let channel: RealtimeChannel | undefined;
      await new Promise<void>((resolve, reject) => {
        const timer = setTimeout(
          () => reject(new Error('Realtime channel did not subscribe')),
          15_000,
        );
        channel = sa.client
          .channel(`notifications-${a.user.id}`)
          .on(
            'postgres_changes',
            { event: 'INSERT', schema: 'public', table: 'notifications' },
            (payload) => received.push((payload.new as { title: string }).title),
          )
          .subscribe((status) => {
            if (status === 'SUBSCRIBED') {
              clearTimeout(timer);
              resolve();
            }
            if (status === 'CHANNEL_ERROR' || status === 'TIMED_OUT') {
              clearTimeout(timer);
              reject(new Error(`Realtime status ${status}`));
            }
          });
      });

      // The Realtime tenant restarts when idle and reports SUBSCRIBED slightly before its change stream is ready,
      // so keep inserting for A (and one for B up front) until the first event arrives.
      await prisma.notification.create({
        data: { userId: b.user.id, category: 'SYSTEM', title: 'For B', body: 'b' },
      });
      for (let i = 0; i < 30 && received.length === 0; i++) {
        await prisma.notification.create({
          data: { userId: a.user.id, category: 'SYSTEM', title: `For A ${i}`, body: 'a' },
        });
        await new Promise((r) => setTimeout(r, 1000));
      }
      await sa.client.removeChannel(channel!);
      await sa.client.realtime.disconnect();
      expect(received.length).toBeGreaterThan(0);
      expect(received.every((t) => t.startsWith('For A'))).toBe(true); // never 'For B'
    });
  });
});
