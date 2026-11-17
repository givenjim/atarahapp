import { ApiException } from '../common/api.exception';
import { decodeCursor, encodeCursor } from '../common/pagination';

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/**
 * Feed cursor: the post's ranking time (its `createdAt` plus the viewer's relevance boost) and its id.
 * Posts are ordered by (rankAt, id) descending, so the cursor is strictly monotonic and pages never overlap.
 * With no boost (group pages, search) rankAt is simply `createdAt`.
 */
export interface FeedCursor {
  /** ISO-8601, millisecond precision, UTC. */
  t: string;
  id: string;
}

export const encodeFeedCursor = (rankAt: Date, id: string): string =>
  encodeCursor({ t: rankAt.toISOString(), id });

export function decodeFeedCursor(cursor: string): FeedCursor {
  const c = decodeCursor<{ t: string; id: string }>(cursor);
  const time = typeof c.t === 'string' ? new Date(c.t) : null;
  if (!time || Number.isNaN(time.getTime()) || typeof c.id !== 'string' || !UUID.test(c.id)) {
    throw ApiException.validation('That page cursor is not valid.', { field: 'cursor' });
  }
  return { t: time.toISOString(), id: c.id.toLowerCase() };
}

/**
 * "Light relevance" (Master Prompt P1-M8): a post's ranking time is its creation time moved forward by a few
 * hours-worth of boost, so relevance nudges recency instead of replacing it. A post from a group the member
 * belongs to can overtake posts up to six hours newer; a same-county or same-discipline author a few hours less.
 */
export const RANK_BOOST_MINUTES = {
  group: 360,
  connection: 120,
  discipline: 180,
  county: 90,
  announcement: 720,
} as const;

export interface RankSignals {
  inGroup: boolean;
  connected: boolean;
  sameDiscipline: boolean;
  sameCounty: boolean;
  announcement: boolean;
}

/** The boost in minutes. The feed query applies the same weights in SQL; this is the readable definition. */
export function rankBoostMinutes(s: RankSignals): number {
  return (
    (s.inGroup ? RANK_BOOST_MINUTES.group : 0) +
    (s.connected ? RANK_BOOST_MINUTES.connection : 0) +
    (s.sameDiscipline ? RANK_BOOST_MINUTES.discipline : 0) +
    (s.sameCounty ? RANK_BOOST_MINUTES.county : 0) +
    (s.announcement ? RANK_BOOST_MINUTES.announcement : 0)
  );
}

export const rankAt = (createdAt: Date, signals: RankSignals): Date =>
  new Date(createdAt.getTime() + rankBoostMinutes(signals) * 60_000);
