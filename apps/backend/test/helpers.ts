import { type DynamicModule, type INestApplication, type Type } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { type AccountStatus, type MembershipStatus, type RoleKey } from '@prisma/client';
import { generateSync } from 'otplib';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { configureApp } from '../src/configure-app';
import { PasswordService } from '../src/identity/password.service';
import { DevOutbox } from '../src/messaging/dev-providers';
import { PrismaService } from '../src/prisma/prisma.service';
import { runReferenceSeed } from '../prisma/seed/reference';
import { StorageService } from '../src/storage/storage.service';
import { applyTestEnv } from './test-env';

export const PASSWORD = 'Passw0rd-test-1';

export async function createTestApp(
  extraImports: Array<Type<unknown> | DynamicModule> = [],
  options: { realStorage?: boolean } = {},
): Promise<INestApplication> {
  applyTestEnv();
  let builder = Test.createTestingModule({ imports: [AppModule, ...extraImports] });
  // Most suites do not touch object storage. Suites that do pass `realStorage` and a running S3 server.
  if (!options.realStorage) {
    builder = builder
      .overrideProvider(StorageService)
      .useValue({ onModuleInit: async () => undefined, check: async () => undefined });
  }
  const moduleRef = await builder.compile();
  const app = moduleRef.createNestApplication();
  configureApp(app, { useLogger: false });
  await app.init();
  // Roles, permissions and plans come from the real reference seed.
  await runReferenceSeed(app.get(PrismaService));
  return app;
}

let counter = 0;
export const uniq = (): string => `${Date.now().toString(36)}${(counter++).toString(36)}`;
export const emailFor = (label = 'user'): string => `${label}.${uniq()}@test.atarah.local`;

export interface MakeUserOptions {
  email?: string;
  phone?: string | null;
  password?: string;
  status?: AccountStatus;
  roles?: RoleKey[];
  /** Create a membership with this status on the PRO plan. */
  membership?: { status: MembershipStatus; periodEndInDays: number | null };
  fullName?: string;
}

export async function makeUser(app: INestApplication, opts: MakeUserOptions = {}) {
  const prisma = app.get(PrismaService);
  const password = opts.password ?? PASSWORD;
  const email = opts.email ?? emailFor();
  const user = await prisma.user.create({
    data: {
      fullName: opts.fullName ?? 'Test Person',
      email,
      phone: opts.phone === undefined ? null : opts.phone,
      emailVerifiedAt: new Date(),
      status: opts.status ?? 'ACTIVE',
      credential: { create: { passwordHash: await app.get(PasswordService).hash(password) } },
    },
  });
  for (const key of opts.roles ?? []) {
    const role = await prisma.role.findUniqueOrThrow({ where: { key } });
    await prisma.userRole.create({ data: { userId: user.id, roleId: role.id } });
  }
  if (opts.membership) {
    const plan = await prisma.membershipPlan.findUniqueOrThrow({ where: { key: 'PRO' } });
    await prisma.membership.create({
      data: {
        userId: user.id,
        planId: plan.id,
        source: 'ADMIN_GRANT',
        status: opts.membership.status,
        currentPeriodEnd:
          opts.membership.periodEndInDays === null
            ? null
            : new Date(Date.now() + opts.membership.periodEndInDays * 24 * 3600 * 1000),
      },
    });
  }
  return { user, email, password };
}

export interface AuthBody {
  accessToken: string;
  refreshToken: string;
  accessTokenExpiresAt: string;
  refreshTokenExpiresAt: string;
  user: Record<string, any>;
}

export async function loginMember(
  app: INestApplication,
  email: string,
  password = PASSWORD,
  client: 'ANDROID' | 'IOS' | 'WEB' = 'ANDROID',
): Promise<AuthBody> {
  const res = await request(app.getHttpServer())
    .post('/api/v1/auth/login')
    .send({ identifier: email, password, client, deviceName: `${client} test device` })
    .expect(200);
  return res.body.data as AuthBody;
}

export const bearer = (token: string): [string, string] => ['Authorization', `Bearer ${token}`];

/** Full admin sign-in: password, TOTP enrolment (first time) or code, returns the session and the secret. */
export async function adminSignIn(app: INestApplication, email: string, password = PASSWORD) {
  const prisma = app.get(PrismaService);
  const http = () => request(app.getHttpServer());

  const login = await http().post('/api/v1/admin/auth/login').send({ email, password }).expect(200);
  const { step, challengeToken } = login.body.data as { step: string; challengeToken: string };

  let secret: string | undefined;
  if (step === 'TOTP_ENROLMENT_REQUIRED') {
    const setup = await http()
      .post('/api/v1/admin/auth/totp/setup')
      .send({ challengeToken })
      .expect(200);
    secret = setup.body.data.secret as string;
  } else {
    throw new Error(
      'adminSignIn helper handles first-time enrolment; use signInWithCode for returning admins',
    );
  }
  const verify = await http()
    .post('/api/v1/admin/auth/totp/verify')
    .send({ challengeToken, code: generateSync({ secret }) })
    .expect(200);
  const session = verify.body.data as AuthBody & { recoveryCodes: string[] };
  const user = await prisma.user.findUniqueOrThrow({ where: { email } });
  return { session, secret, userId: user.id };
}

/** Allow the next code to be used: rewinds replay protection so a code from the current step is accepted. */
export async function rewindTotpReplay(app: INestApplication, userId: string): Promise<void> {
  await app
    .get(PrismaService)
    .adminTotp.update({ where: { userId }, data: { lastUsedTimeStep: 1 } });
}

export const outbox = (app: INestApplication): DevOutbox => app.get(DevOutbox);
