import { type INestApplication } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule, type OpenAPIObject } from '@nestjs/swagger';
import { Logger } from 'nestjs-pino';
import helmet from 'helmet';
import { AllExceptionsFilter } from './common/http-exception.filter';
import { requestIdMiddleware } from './common/request-id.middleware';
import { ResponseEnvelopeInterceptor } from './common/response-envelope.interceptor';
import { createValidationPipe } from './common/validation.pipe';
import { AppConfigService } from './config/app-config.service';

export const API_PREFIX = 'api/v1';

/** Applied identically by main.ts and by integration tests so tests exercise the real pipeline. */
export function configureApp(app: INestApplication, options: { useLogger?: boolean } = {}): void {
  const config = app.get(AppConfigService);

  if (options.useLogger !== false) app.useLogger(app.get(Logger));

  app.use(requestIdMiddleware);
  app.use(helmet());
  app.enableCors({
    origin: config.corsOrigins,
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: [
      'Content-Type',
      'Authorization',
      'Idempotency-Key',
      'X-Request-Id',
      'X-CSRF-Token',
    ],
    exposedHeaders: ['X-Request-Id', 'Retry-After'],
    maxAge: 600,
  });

  // Health probes live outside the versioned prefix.
  app.setGlobalPrefix(API_PREFIX, { exclude: ['health/live', 'health/ready'] });
  app.useGlobalPipes(createValidationPipe());
  app.useGlobalFilters(new AllExceptionsFilter());
  app.useGlobalInterceptors(new ResponseEnvelopeInterceptor());
  app.enableShutdownHooks();
}

export function buildOpenApiDocument(app: INestApplication): OpenAPIObject {
  const builder = new DocumentBuilder()
    .setTitle('Atarah API')
    .setDescription('Atarah — Create · Connect · Grow. Versioned REST API (Luxaion Creatives).')
    .setVersion('1.0')
    .addServer('/')
    .addBearerAuth({ type: 'http', scheme: 'bearer', bearerFormat: 'JWT' }, 'access-token')
    .build();
  // Operation ids are the plain method names so generated clients read login(), not authControllerLogin().
  return SwaggerModule.createDocument(app, builder, {
    operationIdFactory: (_controllerKey: string, methodKey: string) => methodKey,
  });
}

/** Swagger UI at /api/docs, in non-production environments only. */
export function setupSwagger(app: INestApplication): void {
  const config = app.get(AppConfigService);
  if (config.isProduction) return;
  SwaggerModule.setup('api/docs', app, buildOpenApiDocument(app), {
    jsonDocumentUrl: 'api/docs/openapi.json',
  });
}
