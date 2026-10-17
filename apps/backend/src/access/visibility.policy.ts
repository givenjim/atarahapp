import { type Visibility } from '@prisma/client';
import { ApiException } from '../common/api.exception';

export interface ViewerContext {
  /** Undefined for anonymous visitors. */
  viewerId?: string;
  /** True when the viewer is a signed-in, ACTIVE member. */
  isMember: boolean;
  /** True when owner and viewer have an ACCEPTED connection. */
  isConnection?: boolean;
}

/**
 * Ownership and field-level visibility (Master Prompt §7.4). Filtering must happen in the service layer
 * before data leaves the API, including search results, share links, notifications and AI context.
 *
 *  - PUBLIC   anyone, including anonymous visitors
 *  - MEMBERS  signed-in Atarah members (and the owner)
 *  - PRIVATE  the owner only
 */
export function canView(visibility: Visibility, ownerId: string, viewer: ViewerContext): boolean {
  if (viewer.viewerId !== undefined && viewer.viewerId === ownerId) return true;
  switch (visibility) {
    case 'PUBLIC':
      return true;
    case 'MEMBERS':
      return viewer.isMember;
    case 'PRIVATE':
      return false;
  }
}

/** Returns `value` when visible, otherwise `null`. Use per field when shaping API responses. */
export function visibleOrNull<T>(
  value: T,
  visibility: Visibility,
  ownerId: string,
  viewer: ViewerContext,
): T | null {
  return canView(visibility, ownerId, viewer) ? value : null;
}

/** Throws FORBIDDEN unless the actor owns the resource. */
export function assertOwner(ownerId: string, actorId: string): void {
  if (ownerId !== actorId) throw ApiException.forbidden('That belongs to someone else.');
}

/** Nobody can grant themselves a role, verify their own skill, or verify their own opportunity. */
export function assertNotSelf(targetUserId: string, actorId: string, what: string): void {
  if (targetUserId === actorId) {
    throw ApiException.forbidden(`You cannot ${what} yourself.`, { reason: 'SELF_ACTION' });
  }
}
