/** Pure helpers for the Mentorship admin screens (no server imports): labels, messages, money, validation. */

export const APPLICATION_STATUSES = ['PENDING', 'APPROVED', 'REJECTED', 'WITHDRAWN'] as const;
export const MENTOR_STATUSES = ['APPROVED', 'PAUSED', 'REMOVED'] as const;

export const titleCase = (v: string): string =>
  v.charAt(0) + v.slice(1).toLowerCase().replace(/_/g, ' ');

export const statusTone = (status: string): string => {
  switch (status) {
    case 'APPROVED':
      return 'success';
    case 'PENDING':
    case 'PAUSED':
      return 'warning';
    case 'REJECTED':
    case 'REMOVED':
      return 'danger';
    default:
      return '';
  }
};

/** "KES 1,500" from minor units (cents). */
export function formatMoney(minor: number, currency = 'KES'): string {
  const major = minor / 100;
  const text = Number.isInteger(major)
    ? major.toLocaleString('en-KE')
    : major.toLocaleString('en-KE', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  return `${currency} ${text}`;
}

export const MIN_REASON = 3;

/** A reason is needed to reject an application and to pause, resume or remove a mentor. */
export const reasonProblem = (reason: string): string | null =>
  reason.trim().length >= MIN_REASON ? null : 'Say why, in at least a few words.';

export function mentorshipMessage(status: number | undefined, message: string): string {
  if (status === 403) return 'You do not have permission to do that.';
  if (status === 404) return 'That application, mentor or session type no longer exists.';
  if (status === 409) return message || 'That is not possible in the current state.';
  return message;
}
