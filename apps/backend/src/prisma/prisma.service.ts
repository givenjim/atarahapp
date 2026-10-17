import { Injectable, type OnModuleDestroy, type OnModuleInit } from '@nestjs/common';
import { Prisma, PrismaClient } from '@prisma/client';
import { AppConfigService } from '../config/app-config.service';

export type TxClient = Prisma.TransactionClient;

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  constructor(private readonly config: AppConfigService) {
    super({ datasourceUrl: config.databaseUrl });
  }

  async onModuleInit(): Promise<void> {
    if (!this.config.skipConnect) await this.$connect();
  }

  async onModuleDestroy(): Promise<void> {
    await this.$disconnect();
  }

  /**
   * Run `fn` in one database transaction. Use for any multi-write operation that must be atomic
   * (e.g. payment success + entitlement grant + audit record).
   */
  async transaction<T>(
    fn: (tx: TxClient) => Promise<T>,
    options?: { timeoutMs?: number; isolation?: Prisma.TransactionIsolationLevel },
  ): Promise<T> {
    return this.$transaction(fn, {
      timeout: options?.timeoutMs ?? 10_000,
      isolationLevel: options?.isolation,
    });
  }
}
