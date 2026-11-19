import { execFile } from 'node:child_process';
import { existsSync } from 'node:fs';
import { mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { Injectable, Logger } from '@nestjs/common';
import { AppConfigService } from '../config/app-config.service';

/** Where a Chromium-family browser usually lives. The configured path (`ATARAH_PDF_BROWSER_PATH`) always wins. */
const CANDIDATES = [
  'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
  'C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe',
  'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe',
  'C:\\Program Files\\Microsoft\\Edge\\Application\\msedge.exe',
  '/usr/bin/chromium',
  '/usr/bin/chromium-browser',
  '/usr/bin/google-chrome',
  '/usr/bin/google-chrome-stable',
  '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
];

/** Raised when no browser binary is available: the render job fails with this message and the member is told. */
export class PdfRendererUnavailableError extends Error {
  constructor() {
    super(
      'PDF rendering is not available on this server: no Chromium-family browser was found. Set ATARAH_PDF_BROWSER_PATH to its executable.',
    );
  }
}

/**
 * HTML to an A4 PDF with a headless Chromium-family browser, run as a child process (no extra dependency): the
 * templates set the page size and margins with CSS `@page`. The executable is `ATARAH_PDF_BROWSER_PATH`, or the first
 * common install location that exists. The document carries a CSP that forbids every network fetch.
 */
@Injectable()
export class PdfRenderer {
  private readonly log = new Logger(PdfRenderer.name);

  constructor(private readonly config: AppConfigService) {}

  /** The browser that would be used, or null when there is none. */
  executable(): string | null {
    const configured = this.config.pdfBrowserPath;
    if (configured) return existsSync(configured) ? configured : null;
    return CANDIDATES.find((p) => existsSync(p)) ?? null;
  }

  isAvailable(): boolean {
    return this.executable() !== null;
  }

  async render(html: string, timeoutMs = 60_000): Promise<Buffer> {
    const exe = this.executable();
    if (!exe) throw new PdfRendererUnavailableError();
    const dir = await mkdtemp(join(tmpdir(), 'atarah-cv-'));
    try {
      const input = join(dir, 'document.html');
      const output = join(dir, 'document.pdf');
      await writeFile(input, html, 'utf8');
      const args = [
        '--headless=new',
        '--disable-gpu',
        '--disable-extensions',
        '--no-first-run',
        '--no-pdf-header-footer',
        `--user-data-dir=${join(dir, 'profile')}`,
        `--print-to-pdf=${output}`,
        // A container usually runs as root, where Chromium refuses to start with its sandbox on.
        ...(process.platform === 'linux' && process.getuid?.() === 0 ? ['--no-sandbox'] : []),
        pathToFileURL(input).href,
      ];
      await new Promise<void>((resolve, reject) => {
        execFile(exe, args, { timeout: timeoutMs, windowsHide: true }, (err, _out, stderr) => {
          if (err) {
            this.log.warn(`Browser exited with an error: ${String(stderr).slice(0, 300)}`);
            reject(err);
          } else resolve();
        });
      });
      const pdf = await readFile(output);
      if (pdf.length < 100 || pdf.subarray(0, 5).toString('latin1') !== '%PDF-') {
        throw new Error('The renderer did not produce a PDF');
      }
      return pdf;
    } finally {
      await rm(dir, { recursive: true, force: true }).catch(() => undefined);
    }
  }
}
