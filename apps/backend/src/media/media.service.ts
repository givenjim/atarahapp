import { createHash, randomUUID } from 'node:crypto';
import { InjectQueue } from '@nestjs/bullmq';
import { Injectable, Logger } from '@nestjs/common';
import { type MediaAsset, type MediaKind, Prisma, type StorageBucket } from '@prisma/client';
import { type Queue } from 'bullmq';
import sharp from 'sharp';
import { AuditService } from '../audit/audit.service';
import { ApiException } from '../common/api.exception';
import { ErrorCode } from '../common/error-codes';
import { PrismaService } from '../prisma/prisma.service';
import { type BucketKind, StorageService } from '../storage/storage.service';
import { type RequestUploadDto } from './media.dto';
import {
  ALLOWED_MIME,
  EXTENSION,
  IMAGE_VARIANT_WIDTHS,
  MAX_BYTES,
  MAX_IMAGE_PIXELS,
  SNIFF_BYTES,
  kindOfMime,
  normaliseMime,
  sniffMime,
} from './media.rules';

const UPLOAD_URL_TTL_SECONDS = 15 * 60;
const PRIVATE_DOWNLOAD_TTL_SECONDS = 15 * 60;
const PUBLIC_DOWNLOAD_TTL_SECONDS = 60 * 60;
/** Open upload tickets per member per day; stops one account from filling storage with unfinished uploads. */
const MAX_PENDING_PER_DAY = 50;

const REJECTION = {
  sizeMismatch: 'The file we received is not the size it was announced with.',
  typeMismatch: 'This file is not the type it claims to be.',
  notAllowed: 'This type of file is not supported.',
  unreadable: 'We could not read this image. Try exporting it again as JPEG or PNG.',
  tooLarge: 'This image is too large to process.',
} as const;

const bucketKind = (b: StorageBucket): BucketKind =>
  b === 'PUBLIC' ? 'public' : b === 'PRIVATE' ? 'private' : 'evidence';

export interface MediaView {
  id: string;
  kind: MediaKind;
  bucket: StorageBucket;
  status: MediaAsset['status'];
  mimeType: string;
  sizeBytes: number;
  width: number | null;
  height: number | null;
  rejectionReason: string | null;
  url: string | null;
  variants: Record<string, string> | null;
  createdAt: Date;
}

@Injectable()
export class MediaService {
  private readonly logger = new Logger(MediaService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly storage: StorageService,
    private readonly audit: AuditService,
    @InjectQueue('media') private readonly queue: Queue,
  ) {}

  /** Step 1: validate what the client intends to upload and hand back a signed PUT URL. */
  async requestUpload(ownerId: string, dto: RequestUploadDto) {
    const mime = normaliseMime(dto.mimeType);
    if (kindOfMime(mime) !== dto.kind) {
      throw ApiException.validation(
        `That file type is not accepted for ${dto.kind.toLowerCase()} uploads.`,
        { field: 'mimeType', allowed: ALLOWED_MIME[dto.kind] },
      );
    }
    const max = MAX_BYTES[dto.kind];
    if (dto.sizeBytes > max) {
      throw ApiException.validation(
        `This file is too large. The limit for ${dto.kind.toLowerCase()} files is ${Math.round(max / 1024 / 1024)} MB.`,
        { field: 'sizeBytes', maxBytes: max },
      );
    }
    const pending = await this.prisma.mediaAsset.count({
      where: {
        ownerId,
        status: 'PENDING_UPLOAD',
        createdAt: { gt: new Date(Date.now() - 24 * 3600 * 1000) },
      },
    });
    if (pending >= MAX_PENDING_PER_DAY) {
      throw new ApiException(
        ErrorCode.RATE_LIMITED,
        'You have a lot of unfinished uploads. Finish or wait a little before adding more.',
        429,
      );
    }

    const id = randomUUID();
    const bucket: StorageBucket = dto.visibility === 'PUBLIC' ? 'PUBLIC' : 'PRIVATE';
    const objectKey = `media/${id}/original.${EXTENSION[mime]}`;
    await this.prisma.mediaAsset.create({
      data: {
        id,
        ownerId,
        kind: dto.kind,
        bucket,
        objectKey,
        mimeType: mime,
        sizeBytes: BigInt(dto.sizeBytes),
        status: 'PENDING_UPLOAD',
      },
    });
    const expiresAt = new Date(Date.now() + UPLOAD_URL_TTL_SECONDS * 1000);
    const uploadUrl = await this.storage.signedUploadUrl(bucketKind(bucket), objectKey, {
      contentType: mime,
      contentLength: dto.sizeBytes,
      expiresInSeconds: UPLOAD_URL_TTL_SECONDS,
    });
    return {
      id,
      uploadUrl,
      method: 'PUT' as const,
      headers: { 'Content-Type': mime },
      expiresAt,
    };
  }

  /** Step 3: the client says it finished uploading. We check the object is there, then queue validation. */
  async complete(ownerId: string, id: string): Promise<MediaView> {
    const asset = await this.owned(ownerId, id);
    if (asset.status !== 'PENDING_UPLOAD') return this.view(asset);

    const head = await this.storage.head(bucketKind(asset.bucket), asset.objectKey);
    if (!head) {
      throw ApiException.invalidState(
        'We have not received the file yet. Upload it, then confirm.',
      );
    }
    if (head.contentLength !== Number(asset.sizeBytes)) {
      await this.reject(asset, REJECTION.sizeMismatch, 'size_mismatch');
      throw ApiException.invalidState(REJECTION.sizeMismatch);
    }
    const updated = await this.prisma.mediaAsset.update({
      where: { id },
      data: { status: 'UPLOADED' },
    });
    await this.queue.add('process', { assetId: id }, { jobId: `process-${id}` });
    return this.view(updated);
  }

  async get(ownerId: string, id: string): Promise<MediaView> {
    return this.view(await this.owned(ownerId, id));
  }

  /**
   * Signed URL for one rendition (200, 600 or 1200 px) of a READY image, for rendering someone's picture.
   * The caller has already decided the viewer may see it; this does no ownership check.
   */
  async imageUrl(id: string | null, width: 200 | 600 | 1200 = 600): Promise<string | null> {
    if (!id) return null;
    const asset = await this.prisma.mediaAsset.findFirst({
      where: { id, status: 'READY', kind: 'IMAGE', deletedAt: null },
    });
    if (!asset) return null;
    const ttl =
      asset.bucket === 'PUBLIC' ? PUBLIC_DOWNLOAD_TTL_SECONDS : PRIVATE_DOWNLOAD_TTL_SECONDS;
    const key =
      (asset.variants as Record<string, string> | null)?.[String(width)] ?? asset.objectKey;
    return this.storage.signedDownloadUrl(bucketKind(asset.bucket), key, ttl);
  }

  /**
   * Views of several assets for rendering inside content the caller has already decided the viewer may see
   * (a project's files). Does no ownership check; assets that are deleted are left out.
   */
  async viewMany(ids: string[]): Promise<Map<string, MediaView>> {
    if (ids.length === 0) return new Map();
    const assets = await this.prisma.mediaAsset.findMany({
      where: { id: { in: ids }, deletedAt: null },
    });
    const views = await Promise.all(assets.map((a) => this.view(a)));
    return new Map(views.map((v) => [v.id, v]));
  }

  async remove(ownerId: string, id: string): Promise<void> {
    const asset = await this.owned(ownerId, id);
    await this.prisma.mediaAsset.update({
      where: { id },
      data: { status: 'DELETED', deletedAt: new Date() },
    });
    await this.deleteObjects(asset);
  }

  /**
   * Validation job. Sniffs the real type from the bytes, rejects anything that is not what it claims, strips
   * metadata (EXIF, including GPS) from images, and writes 200/600/1200 px renditions. Infrastructure errors
   * are rethrown so BullMQ retries; content problems reject the asset for good.
   */
  async process(assetId: string): Promise<void> {
    const asset = await this.prisma.mediaAsset.findUnique({ where: { id: assetId } });
    if (!asset || (asset.status !== 'UPLOADED' && asset.status !== 'PROCESSING')) return;
    await this.prisma.mediaAsset.update({ where: { id: assetId }, data: { status: 'PROCESSING' } });

    const bucket = bucketKind(asset.bucket);
    const head = await this.storage.head(bucket, asset.objectKey);
    if (!head) throw new Error(`Uploaded object missing for media ${assetId}`);
    if (head.contentLength > MAX_BYTES[asset.kind]) {
      return this.reject(asset, REJECTION.sizeMismatch, 'too_large');
    }

    const sniffed = sniffMime(await this.storage.read(bucket, asset.objectKey, SNIFF_BYTES));
    if (!sniffed) return this.reject(asset, REJECTION.notAllowed, 'unrecognised');
    if (kindOfMime(sniffed) !== asset.kind || !ALLOWED_MIME[asset.kind].includes(sniffed)) {
      return this.reject(asset, REJECTION.notAllowed, 'not_allowed');
    }
    if (sniffed !== asset.mimeType) {
      return this.reject(
        asset,
        REJECTION.typeMismatch,
        `declared_${asset.mimeType}_sniffed_${sniffed}`,
      );
    }

    if (asset.kind !== 'IMAGE') {
      await this.prisma.mediaAsset.update({
        where: { id: assetId },
        data: { status: 'READY', mimeType: sniffed },
      });
      return;
    }
    await this.processImage(asset, sniffed);
  }

  private async processImage(asset: MediaAsset, mime: string): Promise<void> {
    const bucket = bucketKind(asset.bucket);
    const original = await this.storage.read(bucket, asset.objectKey);
    const open = () =>
      sharp(original, { limitInputPixels: MAX_IMAGE_PIXELS, failOn: 'error' }).rotate();

    let clean: Buffer;
    let width: number;
    let height: number;
    try {
      // sharp drops all metadata (EXIF, GPS, ICC comments) unless asked to keep it; re-encoding applies the
      // orientation first so the picture still looks right.
      const encoded =
        mime === 'image/png'
          ? open().png({ compressionLevel: 9 })
          : mime === 'image/webp'
            ? open().webp({ quality: 90 })
            : open().jpeg({ quality: 90, progressive: true });
      const out = await encoded.toBuffer({ resolveWithObject: true });
      clean = out.data;
      width = out.info.width;
      height = out.info.height;
    } catch (err) {
      const tooBig = /pixel limit/i.test((err as Error).message);
      return this.reject(
        asset,
        tooBig ? REJECTION.tooLarge : REJECTION.unreadable,
        'decode_failed',
      );
    }

    await this.storage.write(bucket, asset.objectKey, clean, mime);
    const variants: Record<string, string> = {};
    for (const w of IMAGE_VARIANT_WIDTHS) {
      const key = `media/${asset.id}/w${w}.webp`;
      const data = await sharp(clean)
        .resize({ width: w, withoutEnlargement: true })
        .webp({ quality: 80 })
        .toBuffer();
      await this.storage.write(bucket, key, data, 'image/webp');
      variants[String(w)] = key;
    }
    await this.prisma.mediaAsset.update({
      where: { id: asset.id },
      data: {
        status: 'READY',
        mimeType: mime,
        sizeBytes: BigInt(clean.length),
        width,
        height,
        variants,
        checksum: createHash('sha256').update(clean).digest('hex'),
      },
    });
  }

  private async reject(asset: MediaAsset, message: string, code: string): Promise<void> {
    await this.prisma.mediaAsset.update({
      where: { id: asset.id },
      data: { status: 'REJECTED', rejectionReason: message },
    });
    await this.deleteObjects(asset);
    await this.audit.record({
      actorType: 'SYSTEM',
      action: 'media.reject',
      entityType: 'media_asset',
      entityId: asset.id,
      after: { code, kind: asset.kind },
    });
    this.logger.warn(`Rejected media ${asset.id}: ${code}`);
  }

  private async deleteObjects(asset: MediaAsset): Promise<void> {
    const bucket = bucketKind(asset.bucket);
    const keys = [
      asset.objectKey,
      ...Object.values((asset.variants as Record<string, string> | null) ?? {}),
    ];
    for (const key of keys) {
      await this.storage.remove(bucket, key).catch((err: Error) => {
        this.logger.warn(`Could not delete ${key}: ${err.message}`);
      });
    }
  }

  private async owned(ownerId: string, id: string): Promise<MediaAsset> {
    const asset = await this.prisma.mediaAsset.findFirst({
      where: { id, ownerId, deletedAt: null },
    });
    // The same answer for "not yours" and "does not exist": ids are never confirmed to other members.
    if (!asset) throw ApiException.notFound('We could not find that file.');
    return asset;
  }

  private async view(asset: MediaAsset): Promise<MediaView> {
    const ready = asset.status === 'READY';
    const bucket = bucketKind(asset.bucket);
    const ttl =
      asset.bucket === 'PUBLIC' ? PUBLIC_DOWNLOAD_TTL_SECONDS : PRIVATE_DOWNLOAD_TTL_SECONDS;
    const stored = (asset.variants as Prisma.JsonObject | null) ?? null;
    let variants: Record<string, string> | null = null;
    if (ready && stored) {
      variants = {};
      for (const [w, key] of Object.entries(stored)) {
        variants[w] = await this.storage.signedDownloadUrl(bucket, String(key), ttl);
      }
    }
    return {
      id: asset.id,
      kind: asset.kind,
      bucket: asset.bucket,
      status: asset.status,
      mimeType: asset.mimeType,
      sizeBytes: Number(asset.sizeBytes),
      width: asset.width,
      height: asset.height,
      rejectionReason: asset.rejectionReason,
      url: ready ? await this.storage.signedDownloadUrl(bucket, asset.objectKey, ttl) : null,
      variants,
      createdAt: asset.createdAt,
    };
  }
}
