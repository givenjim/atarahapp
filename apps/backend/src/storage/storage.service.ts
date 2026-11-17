import { Injectable, Logger, type OnModuleInit } from '@nestjs/common';
import { AppConfigService } from '../config/app-config.service';
import { SupabaseAdminService } from '../supabase/supabase-admin.service';

export type BucketKind = 'public' | 'private' | 'evidence';

const BUCKET_KINDS = ['public', 'private', 'evidence'] as const;

/**
 * File storage on Supabase Storage (Master Prompt 5.7, rule 5). All buckets are private except `public-media`.
 * Clients upload and download straight to storage through signed URLs that only this service can issue, after
 * the calling module has made its authorisation check. Storage RLS denies every direct client access.
 *
 * Supabase signed upload URLs do not bind the content type or length, so the media module verifies size and
 * sniffs the real type after upload and rejects anything that does not match (see MediaService.complete).
 */
@Injectable()
export class StorageService implements OnModuleInit {
  private readonly logger = new Logger(StorageService.name);

  constructor(
    private readonly config: AppConfigService,
    private readonly supabase: SupabaseAdminService,
  ) {}

  bucketName(kind: BucketKind): string {
    return this.config.storage.buckets[kind];
  }

  /** Create the three buckets if missing. Skipped in production, where migrations provision them. */
  async onModuleInit(): Promise<void> {
    if (this.config.skipConnect || this.config.isProduction) return;
    try {
      await this.ensureBuckets();
    } catch (err) {
      // Storage being down must not stop the API booting; /health/ready reports it.
      this.logger.warn(`Could not ensure buckets: ${(err as Error).message}`);
    }
  }

  async ensureBuckets(): Promise<void> {
    const { data, error } = await this.supabase.storage.listBuckets();
    if (error) throw new Error(error.message);
    const existing = new Set((data ?? []).map((b) => b.name));
    for (const kind of BUCKET_KINDS) {
      const name = this.bucketName(kind);
      if (existing.has(name)) continue;
      const created = await this.supabase.storage.createBucket(name, { public: kind === 'public' });
      if (created.error) throw new Error(created.error.message);
      this.logger.log(`Created bucket ${name}`);
    }
  }

  /** Readiness probe: every bucket must exist and be reachable. */
  async check(): Promise<void> {
    const { data, error } = await this.supabase.storage.listBuckets();
    if (error) throw new Error(error.message);
    const existing = new Set((data ?? []).map((b) => b.name));
    for (const kind of BUCKET_KINDS) {
      if (!existing.has(this.bucketName(kind)))
        throw new Error(`Bucket ${this.bucketName(kind)} missing`);
    }
  }

  /** Signed URL a client uses to PUT one object (valid for Supabase's fixed two hours). */
  async signedUploadUrl(
    kind: BucketKind,
    key: string,
    _opts: { contentType: string; contentLength: number; expiresInSeconds: number },
  ): Promise<string> {
    const { data, error } = await this.supabase.storage
      .from(this.bucketName(kind))
      .createSignedUploadUrl(key, { upsert: true });
    if (error || !data) throw new Error(error?.message ?? 'Could not sign the upload URL');
    return this.forClients(data.signedUrl);
  }

  async signedDownloadUrl(
    kind: BucketKind,
    key: string,
    expiresInSeconds: number,
  ): Promise<string> {
    const url = await this.internalDownloadUrl(kind, key, expiresInSeconds);
    if (!url) throw new Error(`Object not found: ${key}`);
    return this.forClients(url);
  }

  /** Size and type of an object, or null when it does not exist. */
  async head(
    kind: BucketKind,
    key: string,
  ): Promise<{ contentLength: number; contentType: string | undefined } | null> {
    const url = await this.internalDownloadUrl(kind, key, 60);
    if (!url) return null;
    const res = await fetch(url, { method: 'HEAD' });
    if (res.status === 404 || res.status === 400) return null;
    if (!res.ok) throw new Error(`Storage HEAD failed: ${res.status}`);
    return {
      contentLength: Number(res.headers.get('content-length') ?? 0),
      contentType: res.headers.get('content-type') ?? undefined,
    };
  }

  /** Read an object, or only its first `rangeBytes` bytes (enough to sniff the file type of large media). */
  async read(kind: BucketKind, key: string, rangeBytes?: number): Promise<Buffer> {
    const url = await this.internalDownloadUrl(kind, key, 60);
    if (!url) throw new Error(`Object not found: ${key}`);
    const res = await fetch(
      url,
      rangeBytes ? { headers: { Range: `bytes=0-${rangeBytes - 1}` } } : {},
    );
    if (!res.ok && res.status !== 206) throw new Error(`Storage read failed: ${res.status}`);
    return Buffer.from(await res.arrayBuffer());
  }

  async write(kind: BucketKind, key: string, body: Buffer, contentType: string): Promise<void> {
    const { error } = await this.supabase.storage
      .from(this.bucketName(kind))
      .upload(key, body, { contentType, upsert: true });
    if (error) throw new Error(error.message);
  }

  async remove(kind: BucketKind, key: string): Promise<void> {
    const { error } = await this.supabase.storage.from(this.bucketName(kind)).remove([key]);
    if (error) throw new Error(error.message);
  }

  /** A signed download URL on the address the backend itself uses. Null when the object does not exist. */
  private async internalDownloadUrl(
    kind: BucketKind,
    key: string,
    expiresInSeconds: number,
  ): Promise<string | null> {
    const { data, error } = await this.supabase.storage
      .from(this.bucketName(kind))
      .createSignedUrl(key, expiresInSeconds);
    if (error || !data) return null;
    return data.signedUrl;
  }

  /** Clients may reach Supabase on a different address than the backend (the Android emulator uses 10.0.2.2). */
  private forClients(url: string): string {
    const { url: internal, publicUrl } = this.config.supabase;
    return internal === publicUrl ? url : url.replace(internal, publicUrl);
  }
}
