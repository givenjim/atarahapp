import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { type AuthContext } from '../access/access.types';
import { ApiException } from '../common/api.exception';
import { MediaService, type MediaView } from '../media/media.service';
import { NotificationsService } from '../notifications/notifications.service';
import { PrismaService } from '../prisma/prisma.service';
import { MAX_SKILLS } from './creative.dto';
import { CreativeProfileService } from './creative-profile.service';
import { embedUrlFor } from './embed';
import {
  type AddCollaboratorDto,
  type AchievementInputDto,
  type CreateProjectDto,
  type ExperienceInputDto,
  MAX_ACHIEVEMENTS,
  MAX_COLLABORATORS,
  MAX_EXPERIENCES,
  MAX_PROJECT_MEDIA,
  MAX_PROJECTS,
  MAX_SERVICES,
  type OwnProjectsQueryDto,
  type PublicProjectsQueryDto,
  type ServiceInputDto,
  type UpdateAchievementDto,
  type UpdateExperienceDto,
  type UpdateProjectDto,
  type UpdateServiceDto,
} from './portfolio.dto';
import { ProfileService } from './profile.service';
import { visibilitiesFor } from './sections';

export const PROJECT_INCLUDE = {
  discipline: { select: { id: true, name: true, icon: true } },
  skills: { include: { skill: true } },
  media: { orderBy: { sortOrder: 'asc' } },
  links: { orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }] },
  collaborators: {
    orderBy: { createdAt: 'asc' },
    include: {
      user: {
        select: {
          creativeProfile: { select: { displayName: true, handle: true, avatarMediaId: true } },
        },
      },
    },
  },
} satisfies Prisma.ProjectInclude;

export type ProjectRow = Prisma.ProjectGetPayload<{ include: typeof PROJECT_INCLUDE }>;

const MAX_FEATURED = 3;
const PROJECT_MEDIA_KINDS = ['IMAGE', 'VIDEO', 'AUDIO'] as const;
const MIN_TITLE = 2;
const MIN_DESCRIPTION_WITHOUT_MEDIA = 20;

const day = (d: Date | null): string | null => (d ? d.toISOString().slice(0, 10) : null);

/** Parses `YYYY-MM-DD`. Empty string means "clear it" and gives null. */
function parseDate(value: string, field: string): Date | null {
  const v = value.trim();
  if (v === '') return null;
  if (!/^\d{4}-\d{2}-\d{2}$/.test(v)) {
    throw ApiException.validation('Enter the date as year-month-day.', { field });
  }
  const d = new Date(`${v}T00:00:00.000Z`);
  if (Number.isNaN(d.getTime()) || d.toISOString().slice(0, 10) !== v) {
    throw ApiException.validation('That date does not exist.', { field });
  }
  return d;
}

function cleanText(value: string | undefined): string | null | undefined {
  if (value === undefined) return undefined;
  const v = value.trim().replace(/[ \t]+/g, ' ');
  return v === '' ? null : v;
}

function httpsUrl(value: string, field: string): string {
  const url = value.trim();
  if (!/^https:\/\/[^\s]+$/i.test(url)) {
    throw ApiException.validation('Links must start with https://', { field });
  }
  return url;
}

const shillingsToCents = (v: number | null | undefined) =>
  v === null || v === undefined ? null : v * 100;
const centsToShillings = (v: number | null) => (v === null ? null : Math.round(v / 100));

@Injectable()
export class PortfolioService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly media: MediaService,
    private readonly profiles: CreativeProfileService,
    private readonly profile: ProfileService,
    private readonly notifications: NotificationsService,
  ) {}

  // ---- shared ----------------------------------------------------------------------------------------------

  private async profileIdOf(userId: string): Promise<string> {
    return (await this.profiles.ensureProfile(userId)).id;
  }

  private async refresh(profileId: string) {
    await this.profiles.refreshCompletion(profileId);
  }

  // ---- projects: own ---------------------------------------------------------------------------------------

  private async ownProjectRow(userId: string, id: string): Promise<ProjectRow> {
    const row = await this.prisma.project.findFirst({
      where: { id, deletedAt: null, profile: { userId } },
      include: PROJECT_INCLUDE,
    });
    // The same answer for "not yours" and "does not exist".
    if (!row) throw ApiException.notFound('We could not find that project.');
    return row;
  }

  async listOwnProjects(userId: string, q: OwnProjectsQueryDto) {
    const profileId = await this.profileIdOf(userId);
    const rows = await this.prisma.project.findMany({
      where: {
        profileId,
        deletedAt: null,
        ...(q.listFilter === 'DRAFTS' ? { status: 'DRAFT' } : {}),
        ...(q.listFilter === 'PUBLISHED' ? { status: 'PUBLISHED' } : {}),
      },
      include: PROJECT_INCLUDE,
      orderBy: [{ updatedAt: 'desc' }],
      take: MAX_PROJECTS,
    });
    return this.cards(rows);
  }

  async createProject(userId: string, dto: CreateProjectDto) {
    const profileId = await this.profileIdOf(userId);
    const count = await this.prisma.project.count({ where: { profileId, deletedAt: null } });
    if (count >= MAX_PROJECTS) {
      throw ApiException.invalidState(`You can keep up to ${MAX_PROJECTS} projects.`);
    }
    const row = await this.prisma.project.create({
      data: { profileId, title: (cleanText(dto.title) ?? '').slice(0, 120) },
      include: PROJECT_INCLUDE,
    });
    return this.detail(row, true);
  }

  async getOwnProject(userId: string, id: string) {
    return this.detail(await this.ownProjectRow(userId, id), true);
  }

  async updateProject(userId: string, id: string, dto: UpdateProjectDto) {
    const row = await this.ownProjectRow(userId, id);
    const data: Prisma.ProjectUpdateInput = {};

    if (dto.title !== undefined) data.title = (cleanText(dto.title) ?? '').slice(0, 120);
    if (dto.role !== undefined) data.role = cleanText(dto.role) ?? null;
    if (dto.client !== undefined) data.client = cleanText(dto.client) ?? null;
    if (dto.description !== undefined) data.description = dto.description.trim() || null;
    if (dto.outcome !== undefined) data.outcome = dto.outcome.trim() || null;
    if (dto.projectDate !== undefined) data.projectDate = parseDate(dto.projectDate, 'projectDate');
    if (dto.category !== undefined) data.category = dto.category;
    if (dto.visibility !== undefined) data.visibility = dto.visibility;
    if (dto.disciplineId !== undefined) {
      if (dto.disciplineId === null) data.discipline = { disconnect: true };
      else {
        const found = await this.prisma.discipline.findFirst({
          where: { id: dto.disciplineId, isActive: true },
          select: { id: true },
        });
        if (!found)
          throw ApiException.validation('Pick a discipline from the list.', {
            field: 'disciplineId',
          });
        data.discipline = { connect: { id: found.id } };
      }
    }
    if (dto.featured !== undefined) {
      if (dto.featured && !row.featured) {
        const featured = await this.prisma.project.count({
          where: { profileId: row.profileId, featured: true, deletedAt: null, id: { not: id } },
        });
        if (featured >= MAX_FEATURED) {
          throw ApiException.invalidState(`You can feature up to ${MAX_FEATURED} projects.`);
        }
      }
      data.featured = dto.featured;
    }

    const mediaIds = dto.mediaIds ? [...new Set(dto.mediaIds)] : undefined;
    if (mediaIds) await this.assertUsableMedia(userId, mediaIds);
    const skillIds = dto.skillIds ? [...new Set(dto.skillIds)] : undefined;
    if (skillIds) await this.assertSkills(skillIds);
    const links = dto.links ? this.cleanLinks(dto.links) : undefined;

    // A published project stays complete: edits cannot leave it without a title or anything to show.
    if (row.status === 'PUBLISHED') {
      const title = (data.title as string | undefined) ?? row.title;
      const description =
        data.description === undefined ? row.description : (data.description as string | null);
      const mediaCount = mediaIds ? mediaIds.length : row.media.length;
      this.assertPublishable(title, description, mediaCount);
    }

    await this.prisma.transaction(async (tx) => {
      if (Object.keys(data).length) await tx.project.update({ where: { id }, data });
      if (mediaIds) {
        await tx.projectMedia.deleteMany({ where: { projectId: id } });
        await tx.projectMedia.createMany({
          data: mediaIds.map((mediaId, i) => ({ projectId: id, mediaId, sortOrder: i })),
        });
      }
      if (skillIds) {
        await tx.projectSkill.deleteMany({ where: { projectId: id } });
        await tx.projectSkill.createMany({
          data: skillIds.map((skillId) => ({ projectId: id, skillId })),
        });
      }
      if (links) {
        await tx.projectLink.deleteMany({ where: { projectId: id } });
        await tx.projectLink.createMany({
          data: links.map((l, i) => ({ projectId: id, label: l.label, url: l.url, sortOrder: i })),
        });
      }
    });
    return this.getOwnProject(userId, id);
  }

  async publishProject(userId: string, id: string) {
    const row = await this.ownProjectRow(userId, id);
    this.assertPublishable(row.title, row.description, row.media.length);
    const views = await this.media.viewMany(row.media.map((m) => m.mediaId));
    const pending = row.media.filter((m) => views.get(m.mediaId)?.status !== 'READY');
    if (pending.length > 0) {
      throw ApiException.invalidState(
        'Some files are still uploading or were refused. Wait for them, or remove them, then publish.',
      );
    }
    if (row.status !== 'PUBLISHED') {
      await this.prisma.project.update({
        where: { id },
        data: { status: 'PUBLISHED', publishedAt: row.publishedAt ?? new Date() },
      });
      await this.refresh(row.profileId);
    }
    return this.getOwnProject(userId, id);
  }

  async deleteProject(userId: string, id: string): Promise<void> {
    const row = await this.ownProjectRow(userId, id);
    await this.prisma.project.update({
      where: { id },
      data: { deletedAt: new Date(), featured: false },
    });
    await this.refresh(row.profileId);
  }

  private assertPublishable(title: string, description: string | null, mediaCount: number) {
    if (title.trim().length < MIN_TITLE) {
      throw ApiException.validation('Give your project a title before you publish it.', {
        field: 'title',
      });
    }
    if (mediaCount === 0 && (description?.trim().length ?? 0) < MIN_DESCRIPTION_WITHOUT_MEDIA) {
      throw ApiException.validation(
        'Add at least one file, or describe the project, before you publish it.',
        { field: 'mediaIds' },
      );
    }
  }

  private async assertUsableMedia(userId: string, ids: string[]) {
    if (ids.length > MAX_PROJECT_MEDIA) {
      throw ApiException.validation(`Add up to ${MAX_PROJECT_MEDIA} files to a project.`, {
        field: 'mediaIds',
      });
    }
    if (ids.length === 0) return;
    const assets = await this.prisma.mediaAsset.findMany({
      where: { id: { in: ids }, ownerId: userId, deletedAt: null },
      select: { id: true, kind: true, bucket: true, status: true },
    });
    // Same answer for "not yours" and "does not exist".
    if (assets.length !== ids.length) {
      throw ApiException.validation('One of those files could not be found.', {
        field: 'mediaIds',
      });
    }
    for (const a of assets) {
      if (!(PROJECT_MEDIA_KINDS as readonly string[]).includes(a.kind)) {
        throw ApiException.validation('Projects take images, video and audio.', {
          field: 'mediaIds',
        });
      }
      if (a.bucket !== 'PUBLIC') {
        throw ApiException.validation('That file was uploaded as private.', { field: 'mediaIds' });
      }
      if (a.status === 'REJECTED') {
        throw ApiException.validation(
          'One of those files was refused. Remove it and try another.',
          {
            field: 'mediaIds',
          },
        );
      }
    }
  }

  private async assertSkills(ids: string[]) {
    if (ids.length === 0) return;
    const found = await this.prisma.skill.count({ where: { id: { in: ids }, isActive: true } });
    if (found !== ids.length) {
      throw ApiException.validation('Pick skills from the list.', { field: 'skillIds' });
    }
  }

  private cleanLinks(input: Array<{ label: string; url: string }>) {
    const seen = new Set<string>();
    const out: Array<{ label: string; url: string }> = [];
    for (const l of input) {
      const url = httpsUrl(l.url, 'links');
      const key = url.toLowerCase();
      if (seen.has(key)) continue;
      seen.add(key);
      out.push({ label: l.label.trim(), url });
    }
    return out;
  }

  // ---- projects: public ------------------------------------------------------------------------------------

  private async visibleProjectWhere(
    handle: string,
    viewer: AuthContext | undefined,
    preview: 'PUBLIC' | 'MEMBERS' | undefined,
  ) {
    const { p, relation, see } = await this.profile.audience(handle, viewer, preview);
    // A hidden section looks like an empty profile page, not like a locked door: same 404 as a missing one.
    if (!see('PORTFOLIO')) throw ApiException.notFound('We could not find that portfolio.');
    const where: Prisma.ProjectWhereInput = {
      profileId: p.id,
      status: 'PUBLISHED',
      deletedAt: null,
      hiddenAt: null,
      visibility: { in: visibilitiesFor(relation) },
    };
    return { where, relation };
  }

  async listPublicProjects(
    handle: string,
    viewer: AuthContext | undefined,
    q: PublicProjectsQueryDto,
  ) {
    const { where } = await this.visibleProjectWhere(handle, viewer, q.previewAs);
    const rows = await this.prisma.project.findMany({
      where: {
        ...where,
        ...(q.category ? { category: q.category } : {}),
        ...(q.featuredOnly ? { featured: true } : {}),
      },
      include: PROJECT_INCLUDE,
      orderBy: [
        { featured: 'desc' },
        { projectDate: { sort: 'desc', nulls: 'last' } },
        { publishedAt: 'desc' },
      ],
      take: MAX_PROJECTS,
    });
    return this.cards(rows);
  }

  async getPublicProject(
    handle: string,
    id: string,
    viewer: AuthContext | undefined,
    previewAs?: 'PUBLIC' | 'MEMBERS',
  ) {
    const { where } = await this.visibleProjectWhere(handle, viewer, previewAs);
    const row = await this.prisma.project.findFirst({
      where: { ...where, id },
      include: PROJECT_INCLUDE,
    });
    if (!row) throw ApiException.notFound('We could not find that project.');
    return this.detail(row, false);
  }

  // ---- project views ---------------------------------------------------------------------------------------

  private async mediaFor(rows: ProjectRow[]) {
    return this.media.viewMany([...new Set(rows.flatMap((r) => r.media.map((m) => m.mediaId)))]);
  }

  private coverOf(row: ProjectRow, views: Map<string, MediaView>): string | null {
    for (const m of row.media) {
      const v = views.get(m.mediaId);
      if (v?.status === 'READY' && v.kind === 'IMAGE') return v.variants?.['600'] ?? v.url;
    }
    return null;
  }

  private card(row: ProjectRow, views: Map<string, MediaView>) {
    return {
      id: row.id,
      title: row.title,
      role: row.role,
      category: row.category,
      projectDate: day(row.projectDate),
      featured: row.featured,
      status: row.status,
      visibility: row.visibility,
      coverUrl: this.coverOf(row, views),
      mediaCount: row.media.length,
      hidden: row.hiddenAt !== null,
      updatedAt: row.updatedAt,
    };
  }

  async cards(rows: ProjectRow[]) {
    const views = await this.mediaFor(rows);
    return rows.map((r) => this.card(r, views));
  }

  /** The owner sees drafts' unfinished files and the moderation reason; everyone else sees finished things only. */
  async detail(row: ProjectRow, asOwner: boolean) {
    const views = await this.mediaFor([row]);
    const media = row.media
      .map((m) => ({ m, v: views.get(m.mediaId) }))
      .filter(({ v }) => v && (asOwner || v.status === 'READY'))
      .map(({ m, v }) => ({
        id: m.mediaId,
        kind: v!.kind,
        mimeType: v!.mimeType,
        status: v!.status,
        url: v!.url,
        thumbnailUrl: v!.kind === 'IMAGE' ? (v!.variants?.['600'] ?? v!.url) : null,
        width: v!.width,
        height: v!.height,
        caption: m.caption,
      }));

    const collaborators = await Promise.all(
      row.collaborators
        .filter((c) => (asOwner ? c.status !== 'REMOVED' : c.status === 'ACCEPTED'))
        .map(async (c) => {
          const cp = c.user?.creativeProfile ?? null;
          return {
            id: c.id,
            name: cp?.displayName ?? c.name ?? 'Collaborator',
            role: c.role,
            status: c.status,
            handle: cp?.handle ?? null,
            avatarUrl: cp ? await this.media.imageUrl(cp.avatarMediaId, 200) : null,
          };
        }),
    );

    return {
      ...this.card(row, views),
      client: row.client,
      description: row.description,
      outcome: row.outcome,
      discipline: row.discipline,
      skills: row.skills
        .map((s) => ({ id: s.skill.id, slug: s.skill.slug, name: s.skill.name }))
        .sort((a, b) => a.name.localeCompare(b.name)),
      media,
      links: row.links.map((l) => ({
        id: l.id,
        label: l.label,
        url: l.url,
        embedUrl: embedUrlFor(l.url),
      })),
      collaborators,
      hiddenReason: asOwner ? row.hiddenReason : null,
      publishedAt: row.publishedAt,
    };
  }

  // ---- collaborators ---------------------------------------------------------------------------------------

  async addCollaborator(userId: string, projectId: string, dto: AddCollaboratorDto) {
    const row = await this.ownProjectRow(userId, projectId);
    const name = cleanText(dto.name);
    if ((dto.userId ? 1 : 0) + (name ? 1 : 0) !== 1) {
      throw ApiException.validation('Choose a member, or type a name. Not both.', {
        field: 'userId',
      });
    }
    const active = row.collaborators.filter((c) => c.status !== 'REMOVED');
    if (active.length >= MAX_COLLABORATORS) {
      throw ApiException.invalidState(`You can tag up to ${MAX_COLLABORATORS} collaborators.`);
    }
    const role = cleanText(dto.role) ?? null;

    if (name) {
      await this.prisma.projectCollaborator.create({
        data: { projectId, name, role, status: 'ACCEPTED' },
      });
      return this.getOwnProject(userId, projectId);
    }

    if (dto.userId === userId) {
      throw ApiException.validation('You are already on your own project.', { field: 'userId' });
    }
    const member = await this.prisma.user.findFirst({
      where: {
        id: dto.userId,
        status: 'ACTIVE',
        deletedAt: null,
        creativeProfile: { is: { onboardingCompletedAt: { not: null } } },
      },
      select: { id: true },
    });
    if (!member) throw ApiException.notFound('We could not find that member.');

    const existing = row.collaborators.find((c) => c.userId === member.id);
    if (existing && existing.status !== 'REMOVED') {
      throw ApiException.conflict('That member is already tagged on this project.');
    }
    if (existing) {
      await this.prisma.projectCollaborator.update({
        where: { id: existing.id },
        data: { status: 'PENDING', role },
      });
    } else {
      await this.prisma.projectCollaborator.create({
        data: { projectId, userId: member.id, role, status: 'PENDING' },
      });
    }

    const owner = await this.prisma.creativeProfile.findUnique({
      where: { id: row.profileId },
      select: { displayName: true },
    });
    // A notification failing must never undo the tag.
    await this.notifications
      .notify({
        userId: member.id,
        category: 'PROFILE',
        title: 'You were tagged on a project',
        body: `${owner?.displayName ?? 'A member'} tagged you on “${row.title || 'a project'}”. Accept to show it on the project.`,
        deepLink: '/portfolio',
      })
      .catch(() => undefined);
    return this.getOwnProject(userId, projectId);
  }

  async removeCollaborator(userId: string, projectId: string, collaboratorId: string) {
    const row = await this.ownProjectRow(userId, projectId);
    const c = row.collaborators.find((x) => x.id === collaboratorId);
    if (!c) throw ApiException.notFound('We could not find that collaborator.');
    if (c.userId) {
      await this.prisma.projectCollaborator.update({
        where: { id: c.id },
        data: { status: 'REMOVED' },
      });
    } else {
      await this.prisma.projectCollaborator.delete({ where: { id: c.id } });
    }
    return this.getOwnProject(userId, projectId);
  }

  async myCollaborations(userId: string) {
    const rows = await this.prisma.projectCollaborator.findMany({
      where: {
        userId,
        status: { in: ['PENDING', 'ACCEPTED'] },
        project: { deletedAt: null },
      },
      include: {
        project: {
          select: {
            id: true,
            title: true,
            profile: { select: { displayName: true, handle: true } },
          },
        },
      },
      orderBy: [{ status: 'asc' }, { createdAt: 'desc' }],
      take: 100,
    });
    return rows.map((c) => ({
      id: c.id,
      status: c.status,
      role: c.role,
      projectId: c.project.id,
      projectTitle: c.project.title || 'Untitled project',
      ownerName: c.project.profile.displayName,
      ownerHandle: c.project.profile.handle,
    }));
  }

  private async ownCollaboration(userId: string, id: string) {
    const c = await this.prisma.projectCollaborator.findFirst({
      where: { id, userId, project: { deletedAt: null } },
    });
    if (!c) throw ApiException.notFound('We could not find that invitation.');
    return c;
  }

  async acceptCollaboration(userId: string, id: string) {
    const c = await this.ownCollaboration(userId, id);
    if (c.status === 'REMOVED') {
      throw ApiException.invalidState('You are no longer tagged on that project.');
    }
    if (c.status === 'PENDING') {
      await this.prisma.projectCollaborator.update({ where: { id }, data: { status: 'ACCEPTED' } });
    }
    return (await this.myCollaborations(userId)).find((x) => x.id === id)!;
  }

  /** Decline an invitation, or take yourself off a project. */
  async leaveCollaboration(userId: string, id: string): Promise<void> {
    const c = await this.ownCollaboration(userId, id);
    if (c.status !== 'REMOVED') {
      await this.prisma.projectCollaborator.update({ where: { id }, data: { status: 'REMOVED' } });
    }
  }

  /** A light member search for tagging. Real discovery arrives with Explore (P1-M5). */
  async searchMembers(userId: string, q: string, limit: number) {
    const term = q.trim();
    if (term.length < 2) return [];
    const rows = await this.prisma.creativeProfile.findMany({
      where: {
        userId: { not: userId },
        handle: { not: null },
        onboardingCompletedAt: { not: null },
        user: { status: 'ACTIVE', deletedAt: null },
        OR: [
          { displayName: { contains: term, mode: 'insensitive' } },
          { handle: { contains: term.replace(/^@/, ''), mode: 'insensitive' } },
        ],
      },
      select: {
        userId: true,
        displayName: true,
        handle: true,
        avatarMediaId: true,
        primaryDiscipline: { select: { name: true } },
      },
      orderBy: { displayName: 'asc' },
      take: limit,
    });
    return Promise.all(
      rows.map(async (r) => ({
        userId: r.userId,
        displayName: r.displayName,
        handle: r.handle!,
        avatarUrl: await this.media.imageUrl(r.avatarMediaId, 200),
        discipline: r.primaryDiscipline?.name ?? null,
      })),
    );
  }

  // ---- skills ----------------------------------------------------------------------------------------------

  private skillEntry(
    row: {
      level: string | null;
      source: string;
      skill: { id: string; slug: string; name: string };
    },
    projectCount: number,
  ) {
    return {
      id: row.skill.id,
      slug: row.skill.slug,
      name: row.skill.name,
      level: row.level,
      source: row.source,
      projectCount,
    };
  }

  private async skillRows(profileId: string, onlyPublished: boolean) {
    const rows = await this.prisma.creativeSkill.findMany({
      where: { profileId },
      include: { skill: true },
    });
    const counts = await this.prisma.projectSkill.groupBy({
      by: ['skillId'],
      where: {
        skillId: { in: rows.map((r) => r.skillId) },
        project: {
          profileId,
          deletedAt: null,
          hiddenAt: null,
          ...(onlyPublished ? { status: 'PUBLISHED' } : {}),
        },
      },
      _count: { skillId: true },
    });
    const by = new Map(counts.map((c) => [c.skillId, c._count.skillId]));
    return rows
      .map((r) => this.skillEntry(r, by.get(r.skillId) ?? 0))
      .sort((a, b) => a.name.localeCompare(b.name));
  }

  async mySkills(userId: string) {
    return this.skillRows(await this.profileIdOf(userId), true);
  }

  async setSkill(
    userId: string,
    skillId: string,
    level: 'BEGINNER' | 'INTERMEDIATE' | 'ADVANCED' | 'EXPERT',
  ) {
    const profileId = await this.profileIdOf(userId);
    const skill = await this.prisma.skill.findFirst({
      where: { id: skillId, isActive: true },
      select: { id: true },
    });
    if (!skill) throw ApiException.notFound('We could not find that skill.');
    const existing = await this.prisma.creativeSkill.findUnique({
      where: { profileId_skillId: { profileId, skillId } },
    });
    if (!existing) {
      const count = await this.prisma.creativeSkill.count({ where: { profileId } });
      if (count >= MAX_SKILLS) {
        throw ApiException.invalidState(`You can list up to ${MAX_SKILLS} skills.`);
      }
      await this.prisma.creativeSkill.create({ data: { profileId, skillId, level } });
    } else {
      await this.prisma.creativeSkill.update({
        where: { profileId_skillId: { profileId, skillId } },
        data: { level },
      });
    }
    await this.refresh(profileId);
    return (await this.skillRows(profileId, true)).find((s) => s.id === skillId)!;
  }

  async removeSkill(userId: string, skillId: string): Promise<void> {
    const profileId = await this.profileIdOf(userId);
    const existing = await this.prisma.creativeSkill.findUnique({
      where: { profileId_skillId: { profileId, skillId } },
    });
    if (!existing) throw ApiException.notFound('That skill is not on your profile.');
    if (existing.source === 'VERIFIED') {
      throw ApiException.invalidState('A verified skill cannot be removed here.');
    }
    await this.prisma.creativeSkill.delete({
      where: { profileId_skillId: { profileId, skillId } },
    });
    await this.refresh(profileId);
  }

  async publicSkills(
    handle: string,
    viewer: AuthContext | undefined,
    previewAs?: 'PUBLIC' | 'MEMBERS',
  ) {
    const { p, see } = await this.profile.audience(handle, viewer, previewAs);
    if (!see('SKILLS')) throw ApiException.notFound('We could not find those skills.');
    return this.skillRows(p.id, true);
  }

  // ---- experience ------------------------------------------------------------------------------------------

  private experienceView(e: {
    id: string;
    title: string;
    organisation: string;
    location: string | null;
    startDate: Date;
    endDate: Date | null;
    current: boolean;
    description: string | null;
  }) {
    return {
      id: e.id,
      title: e.title,
      organisation: e.organisation,
      location: e.location,
      startDate: day(e.startDate)!,
      endDate: day(e.endDate),
      current: e.current,
      description: e.description,
    };
  }

  private experienceOrder = [{ current: 'desc' }, { startDate: 'desc' }] as const;

  async myExperience(userId: string) {
    const rows = await this.prisma.experience.findMany({
      where: { profileId: await this.profileIdOf(userId) },
      orderBy: [...this.experienceOrder],
      take: MAX_EXPERIENCES,
    });
    return rows.map((r) => this.experienceView(r));
  }

  private checkExperienceDates(start: Date, end: Date | null, current: boolean) {
    if (current && end) {
      throw ApiException.validation('Remove the end date, or untick "I work here now".', {
        field: 'endDate',
      });
    }
    if (!current && !end) {
      throw ApiException.validation('Add an end date, or tick "I work here now".', {
        field: 'endDate',
      });
    }
    if (end && end < start) {
      throw ApiException.validation('The end date cannot be before the start date.', {
        field: 'endDate',
      });
    }
  }

  async addExperience(userId: string, dto: ExperienceInputDto) {
    const profileId = await this.profileIdOf(userId);
    if ((await this.prisma.experience.count({ where: { profileId } })) >= MAX_EXPERIENCES) {
      throw ApiException.invalidState(`You can list up to ${MAX_EXPERIENCES} experiences.`);
    }
    const start = parseDate(dto.startDate, 'startDate')!;
    const end = dto.endDate ? parseDate(dto.endDate, 'endDate') : null;
    this.checkExperienceDates(start, end, dto.current);
    const row = await this.prisma.experience.create({
      data: {
        profileId,
        title: cleanText(dto.title)!,
        organisation: cleanText(dto.organisation)!,
        location: cleanText(dto.location) ?? null,
        startDate: start,
        endDate: end,
        current: dto.current,
        description: dto.description?.trim() || null,
      },
    });
    await this.refresh(profileId);
    return this.experienceView(row);
  }

  async updateExperience(userId: string, id: string, dto: UpdateExperienceDto) {
    const profileId = await this.profileIdOf(userId);
    const row = await this.prisma.experience.findFirst({ where: { id, profileId } });
    if (!row) throw ApiException.notFound('We could not find that experience.');
    const start =
      dto.startDate !== undefined ? parseDate(dto.startDate, 'startDate')! : row.startDate;
    const current = dto.current ?? row.current;
    const end =
      dto.endDate !== undefined ? parseDate(dto.endDate, 'endDate') : current ? null : row.endDate;
    this.checkExperienceDates(start, end, current);
    const updated = await this.prisma.experience.update({
      where: { id },
      data: {
        ...(dto.title !== undefined ? { title: cleanText(dto.title)! } : {}),
        ...(dto.organisation !== undefined ? { organisation: cleanText(dto.organisation)! } : {}),
        ...(dto.location !== undefined ? { location: cleanText(dto.location) ?? null } : {}),
        ...(dto.description !== undefined ? { description: dto.description.trim() || null } : {}),
        startDate: start,
        endDate: end,
        current,
      },
    });
    return this.experienceView(updated);
  }

  async deleteExperience(userId: string, id: string): Promise<void> {
    const profileId = await this.profileIdOf(userId);
    const { count } = await this.prisma.experience.deleteMany({ where: { id, profileId } });
    if (count === 0) throw ApiException.notFound('We could not find that experience.');
    await this.refresh(profileId);
  }

  async publicExperience(
    handle: string,
    viewer: AuthContext | undefined,
    previewAs?: 'PUBLIC' | 'MEMBERS',
  ) {
    const { p, see } = await this.profile.audience(handle, viewer, previewAs);
    if (!see('EXPERIENCE')) throw ApiException.notFound('We could not find that experience.');
    const rows = await this.prisma.experience.findMany({
      where: { profileId: p.id },
      orderBy: [...this.experienceOrder],
      take: MAX_EXPERIENCES,
    });
    return rows.map((r) => this.experienceView(r));
  }

  // ---- achievements ----------------------------------------------------------------------------------------

  private achievementView(a: {
    id: string;
    type: string;
    title: string;
    issuer: string | null;
    achievedOn: Date | null;
    description: string | null;
    url: string | null;
    source: string;
  }) {
    return {
      id: a.id,
      type: a.type,
      title: a.title,
      issuer: a.issuer,
      achievedOn: day(a.achievedOn),
      description: a.description,
      url: a.url,
      source: a.source,
    };
  }

  private achievementOrder = [
    { achievedOn: { sort: 'desc', nulls: 'last' } },
    { createdAt: 'desc' },
  ] as const;

  async myAchievements(userId: string) {
    const rows = await this.prisma.achievement.findMany({
      where: { profileId: await this.profileIdOf(userId) },
      orderBy: [...this.achievementOrder],
      take: MAX_ACHIEVEMENTS,
    });
    return rows.map((r) => this.achievementView(r));
  }

  async addAchievement(userId: string, dto: AchievementInputDto) {
    const profileId = await this.profileIdOf(userId);
    if ((await this.prisma.achievement.count({ where: { profileId } })) >= MAX_ACHIEVEMENTS) {
      throw ApiException.invalidState(`You can list up to ${MAX_ACHIEVEMENTS} achievements.`);
    }
    const row = await this.prisma.achievement.create({
      data: {
        profileId,
        type: dto.type,
        title: cleanText(dto.title)!,
        issuer: cleanText(dto.issuer) ?? null,
        achievedOn: dto.achievedOn ? parseDate(dto.achievedOn, 'achievedOn') : null,
        description: dto.description?.trim() || null,
        url: dto.url?.trim() ? httpsUrl(dto.url, 'url') : null,
        source: 'MANUAL',
      },
    });
    return this.achievementView(row);
  }

  private async manualAchievement(userId: string, id: string) {
    const profileId = await this.profileIdOf(userId);
    const row = await this.prisma.achievement.findFirst({ where: { id, profileId } });
    if (!row) throw ApiException.notFound('We could not find that achievement.');
    if (row.source === 'SYSTEM') {
      throw ApiException.invalidState('Atarah added this one, so it cannot be changed here.');
    }
    return row;
  }

  async updateAchievement(userId: string, id: string, dto: UpdateAchievementDto) {
    await this.manualAchievement(userId, id);
    const row = await this.prisma.achievement.update({
      where: { id },
      data: {
        ...(dto.type !== undefined ? { type: dto.type } : {}),
        ...(dto.title !== undefined ? { title: cleanText(dto.title)! } : {}),
        ...(dto.issuer !== undefined ? { issuer: cleanText(dto.issuer) ?? null } : {}),
        ...(dto.achievedOn !== undefined
          ? { achievedOn: parseDate(dto.achievedOn, 'achievedOn') }
          : {}),
        ...(dto.description !== undefined ? { description: dto.description.trim() || null } : {}),
        ...(dto.url !== undefined ? { url: dto.url.trim() ? httpsUrl(dto.url, 'url') : null } : {}),
      },
    });
    return this.achievementView(row);
  }

  async deleteAchievement(userId: string, id: string): Promise<void> {
    await this.manualAchievement(userId, id);
    await this.prisma.achievement.delete({ where: { id } });
  }

  async publicAchievements(
    handle: string,
    viewer: AuthContext | undefined,
    previewAs?: 'PUBLIC' | 'MEMBERS',
  ) {
    const { p, see } = await this.profile.audience(handle, viewer, previewAs);
    // Achievements share the Experience section's audience.
    if (!see('EXPERIENCE')) throw ApiException.notFound('We could not find those achievements.');
    const rows = await this.prisma.achievement.findMany({
      where: { profileId: p.id },
      orderBy: [...this.achievementOrder],
      take: MAX_ACHIEVEMENTS,
    });
    return rows.map((r) => this.achievementView(r));
  }

  // ---- services --------------------------------------------------------------------------------------------

  private serviceView(s: {
    id: string;
    title: string;
    description: string | null;
    priceType: string;
    priceMin: number | null;
    priceMax: number | null;
    status: string;
  }) {
    return {
      id: s.id,
      title: s.title,
      description: s.description,
      priceType: s.priceType,
      priceMin: centsToShillings(s.priceMin),
      priceMax: centsToShillings(s.priceMax),
      status: s.status,
    };
  }

  private checkPrice(
    type: 'FIXED' | 'RANGE' | 'ON_REQUEST',
    min: number | null,
    max: number | null,
  ) {
    if (type === 'ON_REQUEST') return { min: null, max: null };
    if (min === null) {
      throw ApiException.validation('Enter a price.', { field: 'priceMin' });
    }
    if (type === 'FIXED') return { min, max: null };
    if (max === null || max < min) {
      throw ApiException.validation('The highest price must be at least the lowest price.', {
        field: 'priceMax',
      });
    }
    return { min, max };
  }

  async myServices(userId: string) {
    const rows = await this.prisma.profileService.findMany({
      where: { profileId: await this.profileIdOf(userId) },
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
      take: MAX_SERVICES,
    });
    return rows.map((r) => this.serviceView(r));
  }

  async addService(userId: string, dto: ServiceInputDto) {
    const profileId = await this.profileIdOf(userId);
    if ((await this.prisma.profileService.count({ where: { profileId } })) >= MAX_SERVICES) {
      throw ApiException.invalidState(`You can list up to ${MAX_SERVICES} services.`);
    }
    const price = this.checkPrice(dto.priceType, dto.priceMin ?? null, dto.priceMax ?? null);
    const last = await this.prisma.profileService.aggregate({
      where: { profileId },
      _max: { sortOrder: true },
    });
    const row = await this.prisma.profileService.create({
      data: {
        profileId,
        title: cleanText(dto.title)!,
        description: dto.description?.trim() || null,
        priceType: dto.priceType,
        priceMin: shillingsToCents(price.min),
        priceMax: shillingsToCents(price.max),
        sortOrder: (last._max.sortOrder ?? -1) + 1,
      },
    });
    return this.serviceView(row);
  }

  async updateService(userId: string, id: string, dto: UpdateServiceDto) {
    const profileId = await this.profileIdOf(userId);
    const row = await this.prisma.profileService.findFirst({ where: { id, profileId } });
    if (!row) throw ApiException.notFound('We could not find that service.');
    const type = dto.priceType ?? row.priceType;
    const price = this.checkPrice(
      type,
      dto.priceMin !== undefined ? dto.priceMin : centsToShillings(row.priceMin),
      dto.priceMax !== undefined ? dto.priceMax : centsToShillings(row.priceMax),
    );
    const updated = await this.prisma.profileService.update({
      where: { id },
      data: {
        ...(dto.title !== undefined ? { title: cleanText(dto.title)! } : {}),
        ...(dto.description !== undefined ? { description: dto.description.trim() || null } : {}),
        priceType: type,
        priceMin: shillingsToCents(price.min),
        priceMax: shillingsToCents(price.max),
      },
    });
    return this.serviceView(updated);
  }

  async deleteService(userId: string, id: string): Promise<void> {
    const profileId = await this.profileIdOf(userId);
    const { count } = await this.prisma.profileService.deleteMany({ where: { id, profileId } });
    if (count === 0) throw ApiException.notFound('We could not find that service.');
  }

  async publicServices(
    handle: string,
    viewer: AuthContext | undefined,
    previewAs?: 'PUBLIC' | 'MEMBERS',
  ) {
    const { p, see } = await this.profile.audience(handle, viewer, previewAs);
    if (!see('SERVICES')) throw ApiException.notFound('We could not find those services.');
    const rows = await this.prisma.profileService.findMany({
      where: { profileId: p.id },
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
      take: MAX_SERVICES,
    });
    return rows.map((r) => this.serviceView(r));
  }
}
