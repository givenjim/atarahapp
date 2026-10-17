/**
 * Writes the OpenAPI document to packages/api-contracts/openapi.json.
 * Does not open database or Redis connections (ATARAH_SKIP_CONNECT), so it runs in any environment.
 */
import 'reflect-metadata';
import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';

process.env.ATARAH_SKIP_CONNECT = '1';

async function main(): Promise<void> {
  const { NestFactory } = await import('@nestjs/core');
  const { AppModule } = await import('../src/app.module');
  const { buildOpenApiDocument, configureApp } = await import('../src/configure-app');

  const app = await NestFactory.create(AppModule, { logger: false });
  configureApp(app, { useLogger: false });
  await app.init();

  const doc = buildOpenApiDocument(app);
  const out = resolve(__dirname, '../../../packages/api-contracts/openapi.json');
  mkdirSync(dirname(out), { recursive: true });
  writeFileSync(out, JSON.stringify(doc, null, 2) + '\n', 'utf8');
  console.log(`OpenAPI written to ${out} (${Object.keys(doc.paths).length} paths)`);
  await app.close();
}

main().catch((err: unknown) => {
  console.error(err);
  process.exit(1);
});
