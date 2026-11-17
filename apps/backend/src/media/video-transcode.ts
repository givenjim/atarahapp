import { spawn } from 'node:child_process';
import { mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { type BucketKind, StorageService } from '../storage/storage.service';

/** ffmpeg arguments for the two outputs of a lesson video: a 720p H.264/AAC MP4 and a poster frame. */
export function transcodeArgs(input: string, outMp4: string, outPoster: string) {
  // Height is capped at 720 and never enlarged; width follows (rounded to an even number for H.264).
  const scale = "scale=-2:'min(720,ih)'";
  return {
    mp4: [
      '-y', '-i', input,
      '-vf', scale,
      '-c:v', 'libx264', '-preset', 'veryfast', '-crf', '23', '-pix_fmt', 'yuv420p',
      '-c:a', 'aac', '-b:a', '128k',
      '-movflags', '+faststart',
      outMp4,
    ],
    poster: ['-y', '-ss', '1', '-i', input, '-frames:v', '1', '-vf', scale, '-q:v', '3', outPoster],
    posterFromStart: ['-y', '-i', input, '-frames:v', '1', '-vf', scale, '-q:v', '3', outPoster],
    probe: ['-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', input],
  };
}

const run = (bin: string, args: string[], timeoutMs: number) =>
  new Promise<{ code: number; stdout: string; stderr: string }>((resolve, reject) => {
    const child = spawn(bin, args, { stdio: ['ignore', 'pipe', 'pipe'] });
    let stdout = '';
    let stderr = '';
    const timer = setTimeout(() => child.kill('SIGKILL'), timeoutMs);
    child.stdout.on('data', (d: Buffer) => (stdout += d.toString()));
    child.stderr.on('data', (d: Buffer) => (stderr = (stderr + d.toString()).slice(-4000)));
    child.on('error', (e) => {
      clearTimeout(timer);
      reject(e);
    });
    child.on('close', (code) => {
      clearTimeout(timer);
      resolve({ code: code ?? -1, stdout, stderr });
    });
  });

/**
 * Lesson video renditions (P1-M10). A READY video upload keeps working as it is (progressive MP4 through a signed URL);
 * this job adds a 720p H.264 MP4 and a poster frame and records them in the asset's `variants`. It needs ffmpeg and
 * ffprobe on the PATH (or `ATARAH_FFMPEG_PATH` / `ATARAH_FFPROBE_PATH`). Without them it logs once and leaves the
 * original in place: playback still works, it is just not re-encoded.
 */
@Injectable()
export class VideoTranscoder {
  private readonly log = new Logger(VideoTranscoder.name);
  private readonly ffmpeg = process.env.ATARAH_FFMPEG_PATH || 'ffmpeg';
  private readonly ffprobe = process.env.ATARAH_FFPROBE_PATH || 'ffprobe';

  constructor(
    private readonly prisma: PrismaService,
    private readonly storage: StorageService,
  ) {}

  async transcode(assetId: string): Promise<{ status: 'done' | 'skipped' | 'unreadable' }> {
    const asset = await this.prisma.mediaAsset.findUnique({ where: { id: assetId } });
    if (!asset || asset.kind !== 'VIDEO' || asset.status !== 'READY' || asset.deletedAt) return { status: 'skipped' };
    const existing = (asset.variants as Record<string, string> | null) ?? {};
    if (existing.mp4) return { status: 'done' };

    const bucket: BucketKind = asset.bucket === 'PUBLIC' ? 'public' : asset.bucket === 'PRIVATE' ? 'private' : 'evidence';
    const dir = await mkdtemp(path.join(tmpdir(), 'atarah-video-'));
    try {
      const input = path.join(dir, 'in');
      const outMp4 = path.join(dir, 'out.mp4');
      const outPoster = path.join(dir, 'poster.jpg');
      await writeFile(input, await this.storage.read(bucket, asset.objectKey));
      const args = transcodeArgs(input, outMp4, outPoster);

      let duration: number | null = null;
      try {
        const probed = await run(this.ffprobe, args.probe, 30_000);
        const secs = Number.parseFloat(probed.stdout.trim());
        if (probed.code === 0 && Number.isFinite(secs)) duration = Math.round(secs);
      } catch (e) {
        if ((e as NodeJS.ErrnoException).code === 'ENOENT') return this.missing();
        throw e;
      }

      let encoded;
      try {
        encoded = await run(this.ffmpeg, args.mp4, 20 * 60_000);
      } catch (e) {
        if ((e as NodeJS.ErrnoException).code === 'ENOENT') return this.missing();
        throw e;
      }
      if (encoded.code !== 0) {
        this.log.warn(`ffmpeg could not read video ${assetId}: ${encoded.stderr.slice(-300)}`);
        return { status: 'unreadable' };
      }
      let poster = await run(this.ffmpeg, args.poster, 60_000);
      // A clip shorter than a second has no frame at 1 s: take the first one instead.
      if (poster.code !== 0) poster = await run(this.ffmpeg, args.posterFromStart, 60_000);

      const mp4Key = `media/${asset.id}/720p.mp4`;
      await this.storage.write(bucket, mp4Key, await readFile(outMp4), 'video/mp4');
      const variants: Record<string, string> = { ...existing, mp4: mp4Key };
      if (poster.code === 0) {
        const posterKey = `media/${asset.id}/poster.jpg`;
        await this.storage.write(bucket, posterKey, await readFile(outPoster), 'image/jpeg');
        variants.poster = posterKey;
      }
      await this.prisma.mediaAsset.update({
        where: { id: asset.id },
        data: { variants, ...(duration !== null ? { durationSeconds: duration } : {}) },
      });
      return { status: 'done' };
    } finally {
      await rm(dir, { recursive: true, force: true });
    }
  }

  private missing(): { status: 'skipped' } {
    this.log.warn('ffmpeg is not installed: lesson videos play as uploaded (not re-encoded to 720p).');
    return { status: 'skipped' };
  }
}
