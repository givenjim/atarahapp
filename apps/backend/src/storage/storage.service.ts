import {
  CreateBucketCommand,
  DeleteObjectCommand,
  GetObjectCommand,
  HeadBucketCommand,
  HeadObjectCommand,
  PutObjectCommand,
  S3Client,
  type S3ClientConfig,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { Injectable, Logger, type OnModuleInit } from '@nestjs/common';
import { AppConfigService } from '../config/app-config.service';

export type BucketKind = 'public' | 'private' | 'evidence';

/**
 * Thin S3 abstraction. The app talks only to the S3 API (path-style), so MinIO, AWS S3 or any
 * compatible service works. Clients upload and download straight to storage through short-lived signed URLs.
 */
@Injectable()
export class StorageService implements OnModuleInit {
  private readonly logger = new Logger(StorageService.name);
  readonly client: S3Client;

  constructor(private readonly config: AppConfigService) {
    const s3 = config.s3;
    const options: S3ClientConfig = {
      endpoint: s3.endpoint,
      region: s3.region,
      forcePathStyle: true,
      credentials: { accessKeyId: s3.accessKey, secretAccessKey: s3.secretKey },
    };
    this.client = new S3Client(options);
  }

  bucketName(kind: BucketKind): string {
    return this.config.s3.buckets[kind];
  }

  /** Create the three buckets if missing. Skipped in production, where buckets are provisioned by IaC. */
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
    for (const kind of ['public', 'private', 'evidence'] as const) {
      const Bucket = this.bucketName(kind);
      try {
        await this.client.send(new HeadBucketCommand({ Bucket }));
      } catch {
        await this.client.send(new CreateBucketCommand({ Bucket }));
        this.logger.log(`Created bucket ${Bucket}`);
      }
    }
  }

  /** Readiness probe: every bucket must be reachable. */
  async check(): Promise<void> {
    for (const kind of ['public', 'private', 'evidence'] as const) {
      await this.client.send(new HeadBucketCommand({ Bucket: this.bucketName(kind) }));
    }
  }

  /** Signed URL a client uses to PUT one object. Type and exact length are part of the signature. */
  signedUploadUrl(
    kind: BucketKind,
    key: string,
    opts: { contentType: string; contentLength: number; expiresInSeconds: number },
  ): Promise<string> {
    return getSignedUrl(
      this.client,
      new PutObjectCommand({
        Bucket: this.bucketName(kind),
        Key: key,
        ContentType: opts.contentType,
        ContentLength: opts.contentLength,
      }),
      // Content-Type must be signed, otherwise a client could store the object as text/html.
      { expiresIn: opts.expiresInSeconds, signableHeaders: new Set(['content-type']) },
    );
  }

  signedDownloadUrl(kind: BucketKind, key: string, expiresInSeconds: number): Promise<string> {
    return getSignedUrl(
      this.client,
      new GetObjectCommand({ Bucket: this.bucketName(kind), Key: key }),
      { expiresIn: expiresInSeconds },
    );
  }

  /** Size and type of an object, or null when it does not exist. */
  async head(
    kind: BucketKind,
    key: string,
  ): Promise<{ contentLength: number; contentType: string | undefined } | null> {
    try {
      const res = await this.client.send(
        new HeadObjectCommand({ Bucket: this.bucketName(kind), Key: key }),
      );
      return { contentLength: res.ContentLength ?? 0, contentType: res.ContentType };
    } catch (err) {
      const name = (err as { name?: string }).name;
      if (name === 'NotFound' || name === 'NoSuchKey') return null;
      throw err;
    }
  }

  /** Read an object, or only its first `rangeBytes` bytes (enough to sniff the file type of large media). */
  async read(kind: BucketKind, key: string, rangeBytes?: number): Promise<Buffer> {
    const res = await this.client.send(
      new GetObjectCommand({
        Bucket: this.bucketName(kind),
        Key: key,
        ...(rangeBytes ? { Range: `bytes=0-${rangeBytes - 1}` } : {}),
      }),
    );
    return Buffer.from(await res.Body!.transformToByteArray());
  }

  async write(kind: BucketKind, key: string, body: Buffer, contentType: string): Promise<void> {
    await this.client.send(
      new PutObjectCommand({
        Bucket: this.bucketName(kind),
        Key: key,
        Body: body,
        ContentType: contentType,
      }),
    );
  }

  async remove(kind: BucketKind, key: string): Promise<void> {
    await this.client.send(new DeleteObjectCommand({ Bucket: this.bucketName(kind), Key: key }));
  }
}
