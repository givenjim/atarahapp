import { lookup as dnsLookup } from 'node:dns/promises';
import http from 'node:http';
import https from 'node:https';
import { isIP } from 'node:net';
import { Injectable } from '@nestjs/common';

/**
 * Server-side fetching of a member-supplied web address (link previews). Anything that can reach an internal
 * service is refused: the address is checked before connecting, after DNS resolution, and again on every
 * redirect, and the connection goes to the address that was checked (no second lookup that could be rebound).
 */

export class UnsafeUrlError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'UnsafeUrlError';
  }
}

/** True for loopback, private, link-local, carrier-grade NAT, multicast, reserved and unspecified addresses. */
export function isPrivateAddress(address: string): boolean {
  const ip = address.replace(/^\[|\]$/g, '').split('%')[0]!;
  const kind = isIP(ip);
  if (kind === 4) return isPrivateV4(ip);
  if (kind === 6) {
    const lower = ip.toLowerCase();
    // IPv4-mapped (::ffff:a.b.c.d) and IPv4-compatible forms: judge the embedded v4 address.
    const mapped = lower.match(/^(?:::ffff:|::)(\d+\.\d+\.\d+\.\d+)$/);
    if (mapped) return isPrivateV4(mapped[1]!);
    const hexMapped = lower.match(/^::ffff:([0-9a-f]{1,4}):([0-9a-f]{1,4})$/);
    if (hexMapped) {
      const hi = parseInt(hexMapped[1]!, 16);
      const lo = parseInt(hexMapped[2]!, 16);
      return isPrivateV4(`${hi >> 8}.${hi & 255}.${lo >> 8}.${lo & 255}`);
    }
    if (lower === '::' || lower === '::1') return true;
    const first = parseInt(lower.split(':')[0] || '0', 16);
    return (
      (first & 0xfe00) === 0xfc00 || // fc00::/7 unique local
      (first & 0xffc0) === 0xfe80 || // fe80::/10 link-local
      (first & 0xffc0) === 0xfec0 || // fec0::/10 site-local (deprecated)
      (first & 0xff00) === 0xff00 || // ff00::/8 multicast
      lower.startsWith('2001:db8') || // documentation
      lower.startsWith('64:ff9b') // NAT64
    );
  }
  return true; // not an address at all: never connect to it
}

function isPrivateV4(ip: string): boolean {
  const [a, b] = ip.split('.').map(Number) as [number, number];
  return (
    a === 0 ||
    a === 10 ||
    a === 127 ||
    (a === 100 && b >= 64 && b <= 127) ||
    (a === 169 && b === 254) ||
    (a === 172 && b >= 16 && b <= 31) ||
    (a === 192 && b === 0) ||
    (a === 192 && b === 168) ||
    (a === 198 && (b === 18 || b === 19)) ||
    a >= 224
  );
}

/** Syntax-level check of a URL before any network call. */
export function assertFetchableUrl(raw: string): URL {
  let url: URL;
  try {
    url = new URL(raw);
  } catch {
    throw new UnsafeUrlError('Not a valid URL.');
  }
  if (url.protocol !== 'http:' && url.protocol !== 'https:')
    throw new UnsafeUrlError('Only http and https.');
  if (url.username || url.password) throw new UnsafeUrlError('No credentials in URLs.');
  const host = url.hostname.replace(/^\[|\]$/g, '');
  if (/^(localhost|.*\.localhost|.*\.local|.*\.internal)$/i.test(host)) {
    throw new UnsafeUrlError('Internal host names are not allowed.');
  }
  if (isIP(host) && isPrivateAddress(host))
    throw new UnsafeUrlError('Private addresses are not allowed.');
  return url;
}

export interface SafeFetchResult {
  url: string;
  status: number;
  contentType: string;
  body: string;
}

export interface SafeFetchOptions {
  maxBytes?: number;
  timeoutMs?: number;
  maxRedirects?: number;
}

export type ResolveHost = (host: string) => Promise<string[]>;

export const defaultResolve: ResolveHost = async (host) =>
  (await dnsLookup(host, { all: true, verbatim: true })).map((r) => r.address);

@Injectable()
export class SafeFetcher {
  /** Replaceable in tests; production always uses real DNS. */
  resolve: ResolveHost = defaultResolve;

  async fetchHtml(raw: string, opts: SafeFetchOptions = {}): Promise<SafeFetchResult> {
    const maxBytes = opts.maxBytes ?? 512 * 1024;
    const timeoutMs = opts.timeoutMs ?? 5_000;
    let current = assertFetchableUrl(raw);
    for (let hop = 0; hop <= (opts.maxRedirects ?? 3); hop += 1) {
      const res = await this.once(current, maxBytes, timeoutMs);
      if (res.status >= 300 && res.status < 400 && res.location) {
        current = assertFetchableUrl(new URL(res.location, current).href);
        continue;
      }
      return {
        url: current.href,
        status: res.status,
        contentType: res.contentType,
        body: res.body,
      };
    }
    throw new UnsafeUrlError('Too many redirects.');
  }

  /**
   * Link health (P1-M9): the status a web address answers with, following redirects with the same checks as
   * `fetchHtml` (private addresses are refused before connecting, after DNS, and on every hop). Sends HEAD and falls
   * back to GET when a server refuses HEAD; never reads a body.
   */
  async probe(
    raw: string,
    opts: { timeoutMs?: number; maxRedirects?: number } = {},
  ): Promise<{ status: number; url: string }> {
    const timeoutMs = opts.timeoutMs ?? 8_000;
    let current = assertFetchableUrl(raw);
    for (let hop = 0; hop <= (opts.maxRedirects ?? 5); hop += 1) {
      let res = await this.statusOnce(current, 'HEAD', timeoutMs);
      if (res.status >= 400) res = await this.statusOnce(current, 'GET', timeoutMs);
      if (res.status >= 300 && res.status < 400 && res.location) {
        current = assertFetchableUrl(new URL(res.location, current).href);
        continue;
      }
      return { status: res.status, url: current.href };
    }
    throw new UnsafeUrlError('Too many redirects.');
  }

  private async statusOnce(url: URL, method: 'HEAD' | 'GET', timeoutMs: number) {
    const host = url.hostname.replace(/^\[|\]$/g, '');
    const addresses = isIP(host) ? [host] : await this.resolve(host);
    if (addresses.length === 0 || addresses.some(isPrivateAddress)) {
      throw new UnsafeUrlError('That address resolves to a private network.');
    }
    const address = addresses[0]!;
    const lib = url.protocol === 'https:' ? https : http;
    return new Promise<{ status: number; location: string | null }>((resolve, reject) => {
      const req = lib.request(
        url,
        {
          method,
          timeout: timeoutMs,
          headers: {
            'User-Agent':
              'AtarahLinkCheck/1.0 (+https://atarah.app; weekly check, contact hello@atarah.app)',
            Accept: '*/*',
          },
          lookup: (_h, _o, cb) => cb(null, address, isIP(address)),
        } as https.RequestOptions,
        (res) => {
          const location = typeof res.headers.location === 'string' ? res.headers.location : null;
          const status = res.statusCode ?? 0;
          res.destroy();
          resolve({ status, location });
        },
      );
      req.on('timeout', () => req.destroy(new Error('Timed out.')));
      req.on('error', reject);
      req.end();
    });
  }

  private async once(url: URL, maxBytes: number, timeoutMs: number) {
    const host = url.hostname.replace(/^\[|\]$/g, '');
    const addresses = isIP(host) ? [host] : await this.resolve(host);
    if (addresses.length === 0 || addresses.some(isPrivateAddress)) {
      throw new UnsafeUrlError('That address resolves to a private network.');
    }
    const address = addresses[0]!;
    const lib = url.protocol === 'https:' ? https : http;
    return new Promise<{
      status: number;
      contentType: string;
      location: string | null;
      body: string;
    }>((resolve, reject) => {
      const req = lib.request(
        url,
        {
          method: 'GET',
          timeout: timeoutMs,
          headers: {
            'User-Agent': 'AtarahLinkPreview/1.0 (+https://atarah.app)',
            Accept: 'text/html,application/xhtml+xml',
          },
          // Connect to the address that was checked, never to a second lookup.
          lookup: (_h, _o, cb) => cb(null, address, isIP(address)),
        } as https.RequestOptions,
        (res) => {
          const type = String(res.headers['content-type'] ?? '');
          const status = res.statusCode ?? 0;
          const location = typeof res.headers.location === 'string' ? res.headers.location : null;
          if (status >= 300 && status < 400) {
            res.resume();
            resolve({ status, contentType: type, location, body: '' });
            return;
          }
          if (!/^(text\/html|application\/xhtml\+xml)/i.test(type)) {
            res.resume();
            reject(new UnsafeUrlError('Not a web page.'));
            return;
          }
          const chunks: Buffer[] = [];
          let size = 0;
          res.on('data', (c: Buffer) => {
            size += c.length;
            if (size > maxBytes) {
              // Enough to read the head of the page; stop downloading.
              chunks.push(c.subarray(0, c.length - (size - maxBytes)));
              res.destroy();
              return;
            }
            chunks.push(c);
          });
          const done = () =>
            resolve({
              status,
              contentType: type,
              location: null,
              body: Buffer.concat(chunks).toString('utf8'),
            });
          res.on('end', done);
          res.on('close', done);
          res.on('error', reject);
        },
      );
      req.on('timeout', () => req.destroy(new Error('Timed out.')));
      req.on('error', reject);
      req.end();
    });
  }
}
