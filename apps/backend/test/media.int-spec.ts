import { type INestApplication, Module } from '@nestjs/common';
import { GenericContainer, type StartedTestContainer, Wait } from 'testcontainers';
import sharp from 'sharp';
import request from 'supertest';
import { MediaModule } from '../src/media/media.module';
import { MediaProcessor } from '../src/media/media.processor';
import { PrismaService } from '../src/prisma/prisma.service';
import { StorageService } from '../src/storage/storage.service';
import { bearer, createTestApp, emailFor, loginMember, makeUser } from './helpers';

// Runs the real worker processor against the real queue (Redis) and a real S3-compatible server.
@Module({ imports: [MediaModule], providers: [MediaProcessor] })
class MediaWorkerModule {}

const S3_KEY = 'atarah_test_s3';
const S3_SECRET = 'atarah_test_s3_secret';

describe('Media pipeline (real S3, real queue)', () => {
  let s3: StartedTestContainer;
  let app: INestApplication;
  let prisma: PrismaService;
  let storage: StorageService;
  let owner: { token: string; id: string };
  let other: { token: string };
  const http = () => request(app.getHttpServer());

  beforeAll(async () => {
    s3 = await new GenericContainer('zenko/cloudserver:latest')
      .withEnvironment({
        SCALITY_ACCESS_KEY_ID: S3_KEY,
        SCALITY_SECRET_ACCESS_KEY: S3_SECRET,
        S3BACKEND: 'mem',
        REMOTE_MANAGEMENT_DISABLE: '1',
      })
      .withExposedPorts(8000)
      .withWaitStrategy(Wait.forListeningPorts())
      .start();
    process.env.ATARAH_TEST_S3_ENDPOINT = `http://${s3.getHost()}:${s3.getMappedPort(8000)}`;
    process.env.ATARAH_TEST_S3_ACCESS_KEY = S3_KEY;
    process.env.ATARAH_TEST_S3_SECRET_KEY = S3_SECRET;

    app = await createTestApp([MediaWorkerModule], { realStorage: true });
    prisma = app.get(PrismaService);
    storage = app.get(StorageService);
    // The server may need a moment after the port opens.
    for (let i = 0; ; i++) {
      try {
        await storage.ensureBuckets();
        break;
      } catch (err) {
        if (i >= 30) throw err;
        await new Promise((r) => setTimeout(r, 1000));
      }
    }

    const a = await makeUser(app, { email: emailFor('owner') });
    const b = await makeUser(app, { email: emailFor('other') });
    owner = { token: (await loginMember(app, a.email)).accessToken, id: a.user.id };
    other = { token: (await loginMember(app, b.email)).accessToken };
  }, 180_000);

  afterAll(async () => {
    await app?.close();
    await s3?.stop();
  });

  /** The full client flow: request ticket, PUT the bytes to storage, confirm. */
  async function upload(
    bytes: Buffer,
    declaredMime: string,
    kind: 'IMAGE' | 'VIDEO' | 'AUDIO' | 'DOCUMENT' = 'IMAGE',
    visibility: 'PUBLIC' | 'PRIVATE' = 'PUBLIC',
  ) {
    const ticket = await http()
      .post('/api/v1/media/uploads')
      .set(...bearer(owner.token))
      .send({ kind, mimeType: declaredMime, sizeBytes: bytes.length, visibility })
      .expect(201);
    const { id, uploadUrl, headers } = ticket.body.data as {
      id: string;
      uploadUrl: string;
      headers: Record<string, string>;
    };
    const put = await fetch(uploadUrl, { method: 'PUT', headers, body: new Uint8Array(bytes) });
    expect(put.status).toBe(200);
    const done = await http()
      .post(`/api/v1/media/${id}/complete`)
      .set(...bearer(owner.token))
      .expect(200);
    return { id, afterComplete: done.body.data as { status: string } };
  }

  /** Wait for the worker to finish validating the asset. */
  async function settled(id: string) {
    for (let i = 0; i < 60; i++) {
      const res = await http()
        .get(`/api/v1/media/${id}`)
        .set(...bearer(owner.token))
        .expect(200);
      const status = res.body.data.status as string;
      if (status === 'READY' || status === 'REJECTED') return res.body.data;
      await new Promise((r) => setTimeout(r, 500));
    }
    throw new Error(`Media ${id} did not settle`);
  }

  const photo = (w = 1600, h = 1000) =>
    sharp({ create: { width: w, height: h, channels: 3, background: '#5b45f0' } });

  it('turns a photo into a READY asset: EXIF stripped, 200/600/1200 variants, signed downloads', async () => {
    const withExif = await photo()
      .withExif({ IFD0: { Copyright: 'SECRET-EXIF-MARKER', Artist: 'Private Person' } })
      .jpeg()
      .toBuffer();
    expect((await sharp(withExif).metadata()).exif).toBeDefined();

    const { id, afterComplete } = await upload(withExif, 'image/jpeg');
    expect(['UPLOADED', 'PROCESSING', 'READY']).toContain(afterComplete.status);

    const asset = await settled(id);
    expect(asset).toMatchObject({
      status: 'READY',
      kind: 'IMAGE',
      mimeType: 'image/jpeg',
      width: 1600,
      height: 1000,
      rejectionReason: null,
    });
    expect(Object.keys(asset.variants)).toEqual(['200', '600', '1200']);

    // The stored original has no metadata left, and the bytes really changed.
    const original = Buffer.from(await (await fetch(asset.url)).arrayBuffer());
    expect((await sharp(original).metadata()).exif).toBeUndefined();
    expect(original.toString('latin1')).not.toContain('SECRET-EXIF-MARKER');

    for (const [w, url] of Object.entries(asset.variants as Record<string, string>)) {
      const res = await fetch(url);
      expect(res.status).toBe(200);
      expect(res.headers.get('content-type')).toBe('image/webp');
      const meta = await sharp(Buffer.from(await res.arrayBuffer())).metadata();
      expect(meta.width).toBeLessThanOrEqual(Number(w));
      expect(meta.exif).toBeUndefined();
    }
    expect(
      (
        await sharp(
          Buffer.from(await (await fetch(asset.variants['200'])).arrayBuffer()),
        ).metadata()
      ).width,
    ).toBe(200);

    // The object key alone is not a download link: buckets are private, access needs a signature.
    const row = await prisma.mediaAsset.findUniqueOrThrow({ where: { id } });
    const bare = `${process.env.ATARAH_TEST_S3_ENDPOINT}/${storage.bucketName('public')}/${row.objectKey}`;
    expect((await fetch(bare)).status).toBeGreaterThanOrEqual(400);
    expect(row.checksum).toMatch(/^[0-9a-f]{64}$/);
  });

  it('rejects a script disguised as a JPEG and removes the object', async () => {
    const script = Buffer.from('<?php system($_GET["cmd"]); ?> pretend this is a photo');
    const { id } = await upload(script, 'image/jpeg');
    const asset = await settled(id);
    expect(asset.status).toBe('REJECTED');
    expect(asset.rejectionReason).toMatch(/not supported/i);
    expect(asset.url).toBeNull();
    const row = await prisma.mediaAsset.findUniqueOrThrow({ where: { id } });
    expect(await storage.head('public', row.objectKey)).toBeNull();
    const audit = await prisma.auditLog.findFirst({
      where: { action: 'media.reject', entityId: id },
    });
    expect(audit).not.toBeNull();
  });

  it('rejects a real PNG that was declared as a JPEG', async () => {
    const png = await photo(300, 200).png().toBuffer();
    const { id } = await upload(png, 'image/jpeg');
    const asset = await settled(id);
    expect(asset.status).toBe('REJECTED');
    expect(asset.rejectionReason).toMatch(/not the type it claims/i);
  });

  it('rejects an image whose header is valid but whose data is corrupt', async () => {
    const good = await photo(400, 300).jpeg().toBuffer();
    const corrupt = Buffer.concat([good.subarray(0, 200), Buffer.alloc(2000, 7)]);
    const { id } = await upload(corrupt, 'image/jpeg');
    const asset = await settled(id);
    expect(asset.status).toBe('REJECTED');
    expect(asset.rejectionReason).toMatch(/could not read this image/i);
  });

  it('rejects a decompression bomb (too many pixels)', async () => {
    const bomb = await photo(9000, 6000).png({ compressionLevel: 9 }).toBuffer();
    expect(bomb.length).toBeLessThan(10 * 1024 * 1024);
    const { id } = await upload(bomb, 'image/png');
    const asset = await settled(id);
    expect(asset.status).toBe('REJECTED');
    expect(asset.rejectionReason).toMatch(/too large/i);
  }, 60_000);

  it('accepts a PDF as a private document without variants', async () => {
    const pdf = Buffer.from(
      '%PDF-1.4\n1 0 obj\n<< /Type /Catalog >>\nendobj\ntrailer\n<< /Root 1 0 R >>\n%%EOF\n',
    );
    const { id } = await upload(pdf, 'application/pdf', 'DOCUMENT', 'PRIVATE');
    const asset = await settled(id);
    expect(asset).toMatchObject({ status: 'READY', bucket: 'PRIVATE', variants: null });
    expect(
      Buffer.from(await (await fetch(asset.url)).arrayBuffer())
        .subarray(0, 5)
        .toString(),
    ).toBe('%PDF-');
  });

  it('refuses unsupported or mismatched declarations before any upload', async () => {
    const ask = (body: Record<string, unknown>) =>
      http()
        .post('/api/v1/media/uploads')
        .set(...bearer(owner.token))
        .send({ visibility: 'PRIVATE', ...body });
    await ask({ kind: 'IMAGE', mimeType: 'image/svg+xml', sizeBytes: 1000 }).expect(400);
    await ask({ kind: 'IMAGE', mimeType: 'application/pdf', sizeBytes: 1000 }).expect(400);
    await ask({ kind: 'IMAGE', mimeType: 'image/jpeg', sizeBytes: 10 * 1024 * 1024 + 1 }).expect(
      400,
    );
    await ask({
      kind: 'DOCUMENT',
      mimeType: 'application/pdf',
      sizeBytes: 11 * 1024 * 1024,
    }).expect(400);
    await ask({ kind: 'IMAGE', mimeType: 'image/jpeg', sizeBytes: 0 }).expect(400);
    await ask({
      kind: 'IMAGE',
      mimeType: 'image/jpeg',
      sizeBytes: 100,
      visibility: 'EVIDENCE',
    }).expect(400);
    await http().post('/api/v1/media/uploads').send({}).expect(401);
  });

  it('refuses a storage upload that does not match the announced size or type', async () => {
    const bytes = await photo(200, 200).jpeg().toBuffer();
    const ticket = await http()
      .post('/api/v1/media/uploads')
      .set(...bearer(owner.token))
      .send({
        kind: 'IMAGE',
        mimeType: 'image/jpeg',
        sizeBytes: bytes.length,
        visibility: 'PUBLIC',
      })
      .expect(201);
    const { uploadUrl } = ticket.body.data as { uploadUrl: string };
    const wrongSize = await fetch(uploadUrl, {
      method: 'PUT',
      headers: { 'Content-Type': 'image/jpeg' },
      body: new Uint8Array(Buffer.concat([bytes, Buffer.alloc(50)])),
    });
    expect(wrongSize.status).toBeGreaterThanOrEqual(400);
    const wrongType = await fetch(uploadUrl, {
      method: 'PUT',
      headers: { 'Content-Type': 'text/html' },
      body: new Uint8Array(bytes),
    });
    expect(wrongType.status).toBeGreaterThanOrEqual(400);
  });

  it('confirming before uploading is an invalid state, and confirming twice is harmless', async () => {
    const bytes = await photo(100, 100).jpeg().toBuffer();
    const ticket = await http()
      .post('/api/v1/media/uploads')
      .set(...bearer(owner.token))
      .send({
        kind: 'IMAGE',
        mimeType: 'image/jpeg',
        sizeBytes: bytes.length,
        visibility: 'PUBLIC',
      })
      .expect(201);
    const { id, uploadUrl, headers } = ticket.body.data as {
      id: string;
      uploadUrl: string;
      headers: Record<string, string>;
    };
    const early = await http()
      .post(`/api/v1/media/${id}/complete`)
      .set(...bearer(owner.token))
      .expect(409);
    expect(early.body.error.code).toBe('INVALID_STATE');

    await fetch(uploadUrl, { method: 'PUT', headers, body: new Uint8Array(bytes) });
    await http()
      .post(`/api/v1/media/${id}/complete`)
      .set(...bearer(owner.token))
      .expect(200);
    await http()
      .post(`/api/v1/media/${id}/complete`)
      .set(...bearer(owner.token))
      .expect(200);
    expect((await settled(id)).status).toBe('READY');
  });

  it('keeps files private to their owner and lets the owner delete them', async () => {
    const { id } = await upload(await photo(120, 120).jpeg().toBuffer(), 'image/jpeg');
    await settled(id);

    await http()
      .get(`/api/v1/media/${id}`)
      .set(...bearer(other.token))
      .expect(404);
    await http()
      .post(`/api/v1/media/${id}/complete`)
      .set(...bearer(other.token))
      .expect(404);
    await http()
      .delete(`/api/v1/media/${id}`)
      .set(...bearer(other.token))
      .expect(404);
    await http().get(`/api/v1/media/${id}`).expect(401);
    await http()
      .get('/api/v1/media/not-a-uuid')
      .set(...bearer(owner.token))
      .expect(400);

    const row = await prisma.mediaAsset.findUniqueOrThrow({ where: { id } });
    expect(row.ownerId).toBe(owner.id);
    expect(await storage.head('public', row.objectKey)).not.toBeNull();

    await http()
      .delete(`/api/v1/media/${id}`)
      .set(...bearer(owner.token))
      .expect(204);
    await http()
      .get(`/api/v1/media/${id}`)
      .set(...bearer(owner.token))
      .expect(404);
    expect(await storage.head('public', row.objectKey)).toBeNull();
  });
});
