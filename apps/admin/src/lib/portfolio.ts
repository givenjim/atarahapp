/** Pure helpers for the portfolio moderation screen (no server imports, so client code and tests can use them). */

export const HIDE_REASON_MIN = 5;
export const HIDE_REASON_MAX = 300;

/** Returns a plain-language problem with the reason, or null when it is acceptable. */
export function validateHideReason(reason: string): string | null {
  const len = reason.trim().length;
  if (len < HIDE_REASON_MIN) return `Give a reason of at least ${HIDE_REASON_MIN} characters.`;
  if (len > HIDE_REASON_MAX) return `Keep the reason to ${HIDE_REASON_MAX} characters or fewer.`;
  return null;
}

/** Only http(s) links are rendered as links; anything else is shown as plain text. */
export const isWebUrl = (url: string): boolean => /^https?:\/\//i.test(url.trim());

/** Friendly message for the API's answer to a hide / restore request. */
export function moderationMessage(status: number | undefined, fallback: string, hiding: boolean) {
  if (status === 409) {
    return hiding
      ? 'This project is already hidden. Refresh the page to see its current state.'
      : 'This project is not hidden, so there is nothing to restore. Refresh the page.';
  }
  if (status === 404) return 'This project no longer exists or is no longer published.';
  return fallback;
}
