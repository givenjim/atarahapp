import { Injectable } from '@nestjs/common';
import { ApiException } from '../common/api.exception';
import { PrismaService } from '../prisma/prisma.service';
import { type SessionViewDto } from './identity.responses';

interface SessionRow {
  id: string;
  updated_at: Date | null;
  created_at: Date | null;
}

/**
 * Active sessions are Supabase Auth sessions (`auth.sessions`). The backend role may read them and delete them;
 * deleting a session row revokes its refresh tokens, so the device is signed out at its next refresh and
 * `SupabaseAuthGuard` refuses its access token immediately.
 */
@Injectable()
export class SessionService {
  constructor(private readonly prisma: PrismaService) {}

  async list(userId: string, currentSessionId: string): Promise<SessionViewDto[]> {
    const rows = await this.prisma.$queryRaw<SessionRow[]>`
      SELECT id::text AS id, created_at, updated_at FROM public.atarah_auth_list_sessions(${userId}::uuid)`;
    const devices = await this.prisma.userDevice.findMany({
      where: { userId, lastSessionId: { in: rows.map((r) => r.id) } },
      select: { lastSessionId: true, name: true, platform: true },
    });
    const byId = new Map(devices.map((d) => [d.lastSessionId, d]));
    return rows.map((r) => {
      const device = byId.get(r.id);
      return {
        id: r.id,
        client: device?.platform ?? 'UNKNOWN',
        deviceName: device?.name ?? null,
        approxLocation: null,
        lastActiveAt: r.updated_at ?? r.created_at ?? new Date(0),
        current: r.id === currentSessionId,
      };
    });
  }

  async revokeOwn(userId: string, sessionId: string): Promise<void> {
    const [row] = await this.prisma.$queryRaw<Array<{ n: number }>>`
      SELECT public.atarah_auth_delete_session(${sessionId}::uuid, ${userId}::uuid) AS n`;
    if (!row || row.n === 0) throw ApiException.notFound('That session does not exist.');
  }

  /** Signs the account out everywhere, optionally keeping one session (password change, new device checks). */
  async revokeAllForUser(userId: string, exceptSessionId?: string): Promise<number> {
    const [row] = await this.prisma.$queryRaw<Array<{ n: number }>>`
      SELECT public.atarah_auth_delete_user_sessions(${userId}::uuid, ${exceptSessionId ?? null}::uuid) AS n`;
    return row?.n ?? 0;
  }

  async count(userId: string): Promise<number> {
    const [row] = await this.prisma.$queryRaw<Array<{ n: number }>>`
      SELECT public.atarah_auth_count_sessions(${userId}::uuid) AS n`;
    return row?.n ?? 0;
  }
}
