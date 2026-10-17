import { Global, Module } from '@nestjs/common';
import { config as loadDotenv } from 'dotenv';
import { AppConfigService, ENV_TOKEN } from './app-config.service';
import { parseEnv } from './env.schema';

@Global()
@Module({
  providers: [
    {
      provide: ENV_TOKEN,
      useFactory: () => {
        // .env is optional (CI and containers inject real env vars). Real env always wins.
        loadDotenv({ quiet: true });
        return parseEnv(process.env);
      },
    },
    AppConfigService,
  ],
  exports: [AppConfigService],
})
export class AppConfigModule {}
