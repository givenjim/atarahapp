import { type IncomingMessage, type ServerResponse } from 'node:http';
import { type Params } from 'nestjs-pino';
import { type AppConfigService } from '../config/app-config.service';
import { REQUEST_ID_HEADER, resolveRequestId } from './request-id.middleware';

/**
 * Paths whose values must never reach logs (Master Prompt §7.4: no passwords, tokens, codes,
 * ID numbers or full phone numbers). Bodies are not logged by default; this is defence in depth.
 */
export const LOG_REDACT_PATHS = [
  'req.headers.authorization',
  'req.headers.cookie',
  'req.headers["x-csrf-token"]',
  'res.headers["set-cookie"]',
  '*.password',
  '*.newPassword',
  '*.currentPassword',
  '*.code',
  '*.token',
  '*.accessToken',
  '*.refreshToken',
  '*.idNumber',
  '*.phone',
  '*.secret',
];

export function buildLoggerParams(config: AppConfigService): Params {
  const quiet = config.environment === 'test';
  return {
    pinoHttp: {
      level: quiet ? 'silent' : config.isDeployed ? 'info' : 'debug',
      redact: { paths: LOG_REDACT_PATHS, censor: '[redacted]' },
      genReqId: (req: IncomingMessage, res: ServerResponse) => {
        const id = resolveRequestId(req.headers[REQUEST_ID_HEADER]);
        req.headers[REQUEST_ID_HEADER] = id;
        res.setHeader('X-Request-Id', id);
        return id;
      },
      serializers: {
        // Drop the query string: it can carry tokens or search terms.
        req: (req: { id: string; method: string; url?: string }) => ({
          id: req.id,
          method: req.method,
          url: req.url?.split('?')[0],
        }),
        res: (res: { statusCode: number }) => ({ statusCode: res.statusCode }),
      },
      autoLogging: {
        ignore: (req: IncomingMessage) => req.url?.startsWith('/health') ?? false,
      },
      ...(config.environment === 'dev'
        ? { transport: { target: 'pino-pretty', options: { singleLine: true, colorize: true } } }
        : {}),
    },
  };
}
