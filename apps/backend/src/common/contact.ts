import { ApiException } from './api.exception';

export type Identifier = { kind: 'email'; value: string } | { kind: 'phone'; value: string };

const EMAIL = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;
const E164 = /^\+[1-9][0-9]{7,14}$/;

/** Normalise a phone number to E.164. Kenyan local formats default to +254. Returns null if unusable. */
export function normalisePhone(raw: string, defaultCallingCode = '+254'): string | null {
  const cleaned = raw.trim().replace(/[\s().-]/g, '');
  let candidate: string;
  if (cleaned.startsWith('+')) candidate = cleaned;
  else if (cleaned.startsWith('00')) candidate = `+${cleaned.slice(2)}`;
  else if (cleaned.startsWith(defaultCallingCode.slice(1))) candidate = `+${cleaned}`;
  else if (cleaned.startsWith('0')) candidate = `${defaultCallingCode}${cleaned.slice(1)}`;
  else if (/^[17][0-9]{8}$/.test(cleaned)) candidate = `${defaultCallingCode}${cleaned}`;
  else return null;
  return E164.test(candidate) ? candidate : null;
}

/** "Email or phone number" (Sign up / Sign in). Email is lower-cased; phone becomes E.164. */
export function parseIdentifier(raw: string): Identifier {
  const value = raw.trim();
  if (value.includes('@')) {
    if (!EMAIL.test(value)) throw invalid('Enter a valid email address.');
    return { kind: 'email', value: value.toLowerCase() };
  }
  const phone = normalisePhone(value);
  if (!phone) throw invalid('Enter a valid email address or phone number.');
  return { kind: 'phone', value: phone };
}

function invalid(message: string): ApiException {
  return ApiException.validation(message, {
    fields: [{ field: 'identifier', messages: [message] }],
  });
}

/** `n***@gmail.com`, `+254 7** *** *21`. Safe to show back to the user and to log. */
export function maskIdentifier(id: Identifier): string {
  if (id.kind === 'email') {
    const [local = '', domain = ''] = id.value.split('@');
    return `${local.slice(0, 1)}***@${domain}`;
  }
  return `${id.value.slice(0, 4)}*****${id.value.slice(-2)}`;
}
