import { Injectable } from '@nestjs/common';
import { type DevicePlatform } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { deviceStartsVerified } from '../access/two-step.policy';
import { type MfaFactorDto, type SecurityDto } from './identity.responses';
import { SessionService } from './session.service';

interface FactorRow {
  id: string;
  factor_type: string;
  status: string;
  friendly_name: string | null;
  created_at: Date;
}

@Injectable()
export class SecurityService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly sessions: SessionService,
  ) {}

  /** What Settings > Security shows: the MFA factors enrolled in Supabase Auth and the session count. */
  async overview(userId: string): Promise<SecurityDto> {
    const rows = await this.prisma.$queryRaw<FactorRow[]>`
      SELECT id::text AS id, factor_type, status, friendly_name, created_at
      FROM public.atarah_auth_list_mfa_factors(${userId}::uuid)`;
    const factors: MfaFactorDto[] = rows.map((r) => ({
      id: r.id,
      type: r.factor_type,
      status: r.status,
      friendlyName: r.friendly_name,
      createdAt: r.created_at,
    }));
    const setting = await this.prisma.twoStepSetting.findUnique({ where: { userId } });
    return {
      factors,
      twoStepEnabled: setting?.enabled === true,
      hasVerifiedFactor: factors.some((f) => f.status === 'verified'),
      activeSessions: await this.sessions.count(userId),
      deviceCount: await this.prisma.userDevice.count({ where: { userId } }),
    };
  }

  /** Records the device the member signed in on and says whether it is new to the account. */
  async registerDevice(
    userId: string,
    sessionId: string,
    device: { deviceHash: string; name: string; platform: DevicePlatform },
    aal: 'aal1' | 'aal2' = 'aal1',
  ): Promise<{ newDevice: boolean; verified: boolean }> {
    const key = { userId_deviceHash: { userId, deviceHash: device.deviceHash } };
    const existing = await this.prisma.userDevice.findUnique({ where: key, select: { id: true } });
    const twoStep = await this.prisma.twoStepSetting.findUnique({
      where: { userId },
      select: { enabled: true },
    });
    // A new device is trusted at once unless two-step is on and this session has not passed the second step.
    const startsVerified = deviceStartsVerified(twoStep?.enabled === true, aal);
    const row = await this.prisma.userDevice.upsert({
      where: key,
      create: {
        userId,
        ...device,
        lastSessionId: sessionId,
        verifiedAt: startsVerified ? new Date() : null,
      },
      update: {
        name: device.name,
        platform: device.platform,
        lastSessionId: sessionId,
        lastSeenAt: new Date(),
        // A known device that just passed the second step becomes trusted.
        ...(aal === 'aal2' ? { verifiedAt: new Date() } : {}),
      },
      select: { verifiedAt: true },
    });
    return { newDevice: existing === null, verified: row.verifiedAt !== null };
  }
}
