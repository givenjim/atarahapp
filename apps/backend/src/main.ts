import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { Logger } from 'nestjs-pino';
import { AppModule } from './app.module';
import { AppConfigService } from './config/app-config.service';
import { configureApp, setupSwagger } from './configure-app';

async function bootstrap(): Promise<void> {
  const app = await NestFactory.create(AppModule, { bufferLogs: true });
  configureApp(app);
  setupSwagger(app);

  const config = app.get(AppConfigService);
  await app.listen(config.port, '0.0.0.0');
  app.get(Logger).log(`Atarah API listening on :${config.port} (${config.environment})`);
}

bootstrap().catch((err: unknown) => {
  // Config validation errors land here and must be readable.
  console.error(err instanceof Error ? err.message : err);
  process.exit(1);
});
