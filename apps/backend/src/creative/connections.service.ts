import { Injectable } from '@nestjs/common';
import { type Connection, Prisma } from '@prisma/client';
import { ApiException } from '../common/api.exception';
import { pageMeta, toSkipTake } from '../common/pagination';
import { MediaService } from '../media/media.service';
import { NotificationsService } from '../notifications/notifications.service';
import { PrismaService } from '../prisma/prisma.service';
import { type ConnectionsQueryDto } from './profile.dto';

/** After a request is declined the requester cannot ask the same member again for this long. */
export const DECLINE_COOLDOWN_DAYS = 30;
const DAY_MS = 24 * 3600 * 1000;

export type ConnectionState = 'NONE' | 'PENDING_SENT' | 'PENDING_RECEIVED' | 'CONNECTED';

export interface ConnectionView {
  id: string | null;
  state: ConnectionState;
  canConnect: boolean;
  reason: 'NOT_ACCEPTING' | 'COOLDOWN' | null;
}

const isUnique = (err: unknown) =>
  err instanceof Prisma.PrismaClientKnownRequestError && err.code === 'P2002';

/** Members who can be connected with: active accounts that finished setup. */
const CONNECTABLE_USER = {
  status: 'ACTIVE',
  deletedAt: null,
  creativeProfile: { is: { onboardingCompletedAt: { not: null } } },
} satisfies Prisma.UserWhereInput;

@Injectable()
export class ConnectionsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly notifications: NotificationsService,
    private readonly media: MediaService,
  ) {}

  private pair(a: string, b: string): Prisma.ConnectionWhereInput {
    return {
      OR: [
        { requesterId: a, addresseeId: b },
        { requesterId: b, addresseeId: a },
      ],
    };
  }

  async between(a: string, b: string): Promise<Connection | null> {
    return this.prisma.connection.findFirst({ where: this.pair(a, b) });
  }

  async areConnected(a: string, b: string): Promise<boolean> {
    return (
      (await this.prisma.connection.count({ where: { ...this.pair(a, b), status: 'ACCEPTED' } })) >
      0
    );
  }

  /** What the viewer sees on the other member's profile. */
  viewOf(
    viewerId: string,
    row: Connection | null,
    target: { acceptConnections: boolean },
    now = new Date(),
  ): ConnectionView {
    if (row?.status === 'ACCEPTED') {
      return { id: row.id, state: 'CONNECTED', canConnect: false, reason: null };
    }
    if (row?.status === 'PENDING') {
      const sent = row.requesterId === viewerId;
      return {
        id: row.id,
        state: sent ? 'PENDING_SENT' : 'PENDING_RECEIVED',
        canConnect: false,
        reason: null,
      };
    }
    if (!target.acceptConnections) {
      return { id: row?.id ?? null, state: 'NONE', canConnect: false, reason: 'NOT_ACCEPTING' };
    }
    if (row?.status === 'DECLINED' && row.requesterId === viewerId && row.respondedAt) {
      const until = row.respondedAt.getTime() + DECLINE_COOLDOWN_DAYS * DAY_MS;
      if (now.getTime() < until) {
        return { id: row.id, state: 'NONE', canConnect: false, reason: 'COOLDOWN' };
      }
    }
    return { id: row?.id ?? null, state: 'NONE', canConnect: true, reason: null };
  }

  async connect(viewerId: string, handle: string): Promise<ConnectionView> {
    const target = await this.prisma.creativeProfile.findFirst({
      where: { handle: handle.toLowerCase(), user: CONNECTABLE_USER },
      include: { user: { select: { id: true } } },
    });
    if (!target) throw ApiException.notFound('We could not find that creative.');
    if (target.userId === viewerId) {
      throw ApiException.invalidState('You cannot connect with yourself.');
    }
    const me = await this.prisma.creativeProfile.findUnique({
      where: { userId: viewerId },
      select: { handle: true, displayName: true, onboardingCompletedAt: true },
    });
    if (!me?.onboardingCompletedAt) {
      throw ApiException.invalidState('Finish setting up your profile to connect with people.');
    }

    const existing = await this.between(viewerId, target.userId);
    const current = this.viewOf(viewerId, existing, target);
    if (current.state === 'CONNECTED' || current.state === 'PENDING_SENT') return current; // idempotent
    if (current.state === 'PENDING_RECEIVED') {
      // They already asked us: asking back means yes.
      return this.respond(viewerId, existing!.id, 'accept');
    }
    if (!current.canConnect) {
      throw current.reason === 'COOLDOWN'
        ? ApiException.conflict(
            `You can send another request after ${DECLINE_COOLDOWN_DAYS} days from the last answer.`,
            { reason: 'COOLDOWN' },
          )
        : ApiException.invalidState('This member is not accepting connection requests.', {
            reason: 'NOT_ACCEPTING',
          });
    }

    let row: Connection;
    try {
      row = existing
        ? await this.prisma.connection.update({
            where: { id: existing.id },
            data: {
              requesterId: viewerId,
              addresseeId: target.userId,
              status: 'PENDING',
              respondedAt: null,
            },
          })
        : await this.prisma.connection.create({
            data: { requesterId: viewerId, addresseeId: target.userId },
          });
    } catch (err) {
      if (!isUnique(err)) throw err;
      // Both members pressed Connect at the same moment: the other request won, so answer it.
      const raced = await this.between(viewerId, target.userId);
      if (raced?.status === 'PENDING' && raced.requesterId !== viewerId) {
        return this.respond(viewerId, raced.id, 'accept');
      }
      return this.viewOf(viewerId, raced, target);
    }
    await this.tell(target.userId, {
      title: 'New connection request',
      body: `${me.displayName} wants to connect with you.`,
      deepLink: me.handle ? `/creatives/${me.handle}` : undefined,
    });
    return this.viewOf(viewerId, row, target);
  }

  async respond(userId: string, id: string, action: 'accept' | 'decline'): Promise<ConnectionView> {
    const row = await this.prisma.connection.findUnique({ where: { id } });
    // Same answer for "not yours" and "does not exist".
    if (!row || row.addresseeId !== userId) {
      throw ApiException.notFound('We could not find that request.');
    }
    if (row.status !== 'PENDING') {
      throw ApiException.invalidState('That request has already been answered.');
    }
    const { count } = await this.prisma.connection.updateMany({
      where: { id, status: 'PENDING', addresseeId: userId },
      data: { status: action === 'accept' ? 'ACCEPTED' : 'DECLINED', respondedAt: new Date() },
    });
    if (count !== 1) throw ApiException.invalidState('That request has already been answered.');
    const updated = await this.prisma.connection.findUniqueOrThrow({ where: { id } });
    if (action === 'accept') {
      const me = await this.prisma.creativeProfile.findUnique({
        where: { userId },
        select: { handle: true, displayName: true },
      });
      await this.tell(row.requesterId, {
        title: 'Connection accepted',
        body: `${me?.displayName ?? 'A creative'} accepted your request.`,
        deepLink: me?.handle ? `/creatives/${me.handle}` : undefined,
      });
    }
    return this.viewOf(userId, updated, { acceptConnections: true });
  }

  /** Cancel a request you sent, or end a connection (either side). */
  async remove(userId: string, id: string): Promise<ConnectionView> {
    const row = await this.prisma.connection.findUnique({ where: { id } });
    if (!row || (row.requesterId !== userId && row.addresseeId !== userId)) {
      throw ApiException.notFound('We could not find that connection.');
    }
    if (row.status === 'PENDING' && row.requesterId !== userId) {
      throw ApiException.invalidState('Decline the request instead.');
    }
    if (row.status !== 'PENDING' && row.status !== 'ACCEPTED') {
      throw ApiException.invalidState('There is no connection to remove.');
    }
    const updated = await this.prisma.connection.update({
      where: { id },
      data: { status: 'REMOVED', respondedAt: new Date() },
    });
    return this.viewOf(userId, updated, { acceptConnections: true });
  }

  async list(userId: string, q: ConnectionsQueryDto) {
    const page = { page: Math.max(1, q.page), limit: Math.min(100, Math.max(1, q.limit)) };
    const where: Prisma.ConnectionWhereInput =
      q.listState === 'PENDING_RECEIVED'
        ? { addresseeId: userId, status: 'PENDING', requester: CONNECTABLE_USER }
        : q.listState === 'PENDING_SENT'
          ? { requesterId: userId, status: 'PENDING', addressee: CONNECTABLE_USER }
          : {
              status: 'ACCEPTED',
              OR: [
                { requesterId: userId, addressee: CONNECTABLE_USER },
                { addresseeId: userId, requester: CONNECTABLE_USER },
              ],
            };
    const include = {
      requester: {
        select: { id: true, creativeProfile: { include: { primaryDiscipline: true } } },
      },
      addressee: {
        select: { id: true, creativeProfile: { include: { primaryDiscipline: true } } },
      },
    } satisfies Prisma.ConnectionInclude;
    const [rows, total] = await this.prisma.$transaction([
      this.prisma.connection.findMany({
        where,
        include,
        orderBy: [{ updatedAt: 'desc' }, { id: 'asc' }],
        ...toSkipTake(page),
      }),
      this.prisma.connection.count({ where }),
    ]);
    const items = await Promise.all(
      rows.map(async (r) => {
        const other = r.requesterId === userId ? r.addressee : r.requester;
        const p = other.creativeProfile!;
        return {
          id: r.id,
          state: q.listState,
          since: r.respondedAt ?? r.createdAt,
          person: {
            handle: p.handle ?? '',
            displayName: p.displayName,
            avatarUrl: await this.media.imageUrl(p.avatarMediaId, 200),
            headline: p.headline,
            discipline: p.primaryDiscipline?.name ?? null,
          },
        };
      }),
    );
    return { items, meta: pageMeta(page, total) };
  }

  async countAccepted(userId: string): Promise<number> {
    return this.prisma.connection.count({
      where: {
        status: 'ACCEPTED',
        OR: [
          { requesterId: userId, addressee: CONNECTABLE_USER },
          { addresseeId: userId, requester: CONNECTABLE_USER },
        ],
      },
    });
  }

  async countPendingReceived(userId: string): Promise<number> {
    return this.prisma.connection.count({
      where: { addresseeId: userId, status: 'PENDING', requester: CONNECTABLE_USER },
    });
  }

  private async tell(
    userId: string,
    n: { title: string; body: string; deepLink?: string },
  ): Promise<void> {
    // A notification problem must never undo the connection.
    await this.notifications
      .notify({ userId, category: 'COMMUNITY', title: n.title, body: n.body, deepLink: n.deepLink })
      .catch(() => undefined);
  }
}
