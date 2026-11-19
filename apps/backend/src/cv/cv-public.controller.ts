import { Controller, Get, Header, Param, Res } from '@nestjs/common';
import { ApiExcludeController } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import type { Response } from 'express';
import { Public } from '../access/decorators';
import { CvService } from './cv.service';

/**
 * The public page behind a share link, served at `/{handle}/cv/{token}` (outside the `/api/v1` prefix, see
 * `configure-app.ts`) until the web app renders it in P3-M4. Server-rendered HTML; every refusal is the same 404 page.
 */
@ApiExcludeController()
@Public()
@Controller()
export class CvPublicController {
  constructor(private readonly cv: CvService) {}

  @Throttle({ default: { limit: 60, ttl: 60_000 } })
  @Header('Cache-Control', 'no-store')
  @Header('X-Robots-Tag', 'noindex, nofollow')
  @Header('Referrer-Policy', 'no-referrer')
  @Get(':handle/cv/:token')
  async page(
    @Param('handle') handle: string,
    @Param('token') token: string,
    @Res() res: Response,
  ): Promise<void> {
    const html = await this.cv.publicPage(handle, token);
    res
      .status(html ? 200 : 404)
      .type('html')
      .send(html ?? CvService.notFoundHtml());
  }
}
