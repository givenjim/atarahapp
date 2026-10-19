import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Put,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { type AuthContext } from '../access/access.types';
import { CurrentAuth, OptionalAuth, RequiresPermission, Viewer } from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { PublicProfileQueryDto } from './profile.dto';
import {
  AchievementDto,
  AchievementInputDto,
  AddCollaboratorDto,
  CollaborationDto,
  CreateProjectDto,
  ExperienceDto,
  ExperienceInputDto,
  MemberHitDto,
  MemberSearchQueryDto,
  OwnProjectsQueryDto,
  ProjectCardDto,
  ProjectDto,
  PublicProjectsQueryDto,
  ServiceDto,
  ServiceInputDto,
  SetSkillDto,
  SkillEntryDto,
  UpdateAchievementDto,
  UpdateExperienceDto,
  UpdateProjectDto,
  UpdateServiceDto,
} from './portfolio.dto';
import { PortfolioService } from './portfolio.service';

/** A member's own portfolio, skills, experience, achievements and services, and other members' public views. */
@ApiTags('Portfolio')
@ApiBearerAuth('access-token')
@Controller()
export class PortfolioController {
  constructor(private readonly portfolio: PortfolioService) {}

  // ---- projects ----

  @RequiresPermission('profile.view')
  @ApiEnvelope(ProjectCardDto, { isArray: true })
  @Get('me/projects')
  myProjects(@CurrentAuth() auth: AuthContext, @Query() q: OwnProjectsQueryDto) {
    return this.portfolio.listOwnProjects(auth.userId, q);
  }

  @RequiresPermission('profile.edit')
  @Throttle({ default: { limit: 60, ttl: 3_600_000 } })
  @HttpCode(201)
  @ApiEnvelope(ProjectDto, { status: 201 })
  @Post('me/projects')
  createProject(@CurrentAuth() auth: AuthContext, @Body() dto: CreateProjectDto) {
    return this.portfolio.createProject(auth.userId, dto);
  }

  @RequiresPermission('profile.view')
  @ApiEnvelope(ProjectDto)
  @Get('me/projects/:id')
  myProject(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.portfolio.getOwnProject(auth.userId, id);
  }

  @RequiresPermission('profile.edit')
  @Throttle({ default: { limit: 240, ttl: 60_000 } })
  @ApiEnvelope(ProjectDto)
  @Patch('me/projects/:id')
  updateProject(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateProjectDto,
  ) {
    return this.portfolio.updateProject(auth.userId, id, dto);
  }

  @RequiresPermission('profile.edit')
  @HttpCode(200)
  @ApiEnvelope(ProjectDto)
  @Post('me/projects/:id/publish')
  publishProject(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.portfolio.publishProject(auth.userId, id);
  }

  @RequiresPermission('profile.edit')
  @HttpCode(204)
  @Delete('me/projects/:id')
  async deleteProject(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    await this.portfolio.deleteProject(auth.userId, id);
  }

  @RequiresPermission('profile.edit')
  @HttpCode(201)
  @ApiEnvelope(ProjectDto, { status: 201 })
  @Post('me/projects/:id/collaborators')
  addCollaborator(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: AddCollaboratorDto,
  ) {
    return this.portfolio.addCollaborator(auth.userId, id, dto);
  }

  @RequiresPermission('profile.edit')
  @ApiEnvelope(ProjectDto)
  @Delete('me/projects/:id/collaborators/:collaboratorId')
  removeCollaborator(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Param('collaboratorId', ParseUUIDPipe) collaboratorId: string,
  ) {
    return this.portfolio.removeCollaborator(auth.userId, id, collaboratorId);
  }

  @RequiresPermission('profile.view')
  @ApiEnvelope(CollaborationDto, { isArray: true })
  @Get('me/collaborations')
  myCollaborations(@CurrentAuth() auth: AuthContext) {
    return this.portfolio.myCollaborations(auth.userId);
  }

  @RequiresPermission('profile.edit')
  @HttpCode(200)
  @ApiEnvelope(CollaborationDto)
  @Post('me/collaborations/:id/accept')
  acceptCollaboration(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.portfolio.acceptCollaboration(auth.userId, id);
  }

  @RequiresPermission('profile.edit')
  @HttpCode(204)
  @Delete('me/collaborations/:id')
  async leaveCollaboration(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    await this.portfolio.leaveCollaboration(auth.userId, id);
  }

  @RequiresPermission('profile.view')
  @Throttle({ default: { limit: 60, ttl: 60_000 } })
  @ApiEnvelope(MemberHitDto, { isArray: true })
  @Get('members/search')
  searchMembers(@CurrentAuth() auth: AuthContext, @Query() q: MemberSearchQueryDto) {
    return this.portfolio.searchMembers(auth.userId, q.q, q.limit);
  }

  // ---- skills ----

  @RequiresPermission('profile.view')
  @ApiEnvelope(SkillEntryDto, { isArray: true })
  @Get('me/skills')
  mySkills(@CurrentAuth() auth: AuthContext) {
    return this.portfolio.mySkills(auth.userId);
  }

  @RequiresPermission('profile.edit')
  @ApiEnvelope(SkillEntryDto)
  @Put('me/skills/:skillId')
  setSkill(
    @CurrentAuth() auth: AuthContext,
    @Param('skillId', ParseUUIDPipe) skillId: string,
    @Body() dto: SetSkillDto,
  ) {
    return this.portfolio.setSkill(auth.userId, skillId, dto.level);
  }

  @RequiresPermission('profile.edit')
  @HttpCode(204)
  @Delete('me/skills/:skillId')
  async removeSkill(
    @CurrentAuth() auth: AuthContext,
    @Param('skillId', ParseUUIDPipe) skillId: string,
  ) {
    await this.portfolio.removeSkill(auth.userId, skillId);
  }

  // ---- experience ----

  @RequiresPermission('profile.view')
  @ApiEnvelope(ExperienceDto, { isArray: true })
  @Get('me/experience')
  myExperience(@CurrentAuth() auth: AuthContext) {
    return this.portfolio.myExperience(auth.userId);
  }

  @RequiresPermission('profile.edit')
  @HttpCode(201)
  @ApiEnvelope(ExperienceDto, { status: 201 })
  @Post('me/experience')
  addExperience(@CurrentAuth() auth: AuthContext, @Body() dto: ExperienceInputDto) {
    return this.portfolio.addExperience(auth.userId, dto);
  }

  @RequiresPermission('profile.edit')
  @ApiEnvelope(ExperienceDto)
  @Patch('me/experience/:id')
  updateExperience(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateExperienceDto,
  ) {
    return this.portfolio.updateExperience(auth.userId, id, dto);
  }

  @RequiresPermission('profile.edit')
  @HttpCode(204)
  @Delete('me/experience/:id')
  async deleteExperience(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    await this.portfolio.deleteExperience(auth.userId, id);
  }

  // ---- achievements ----

  @RequiresPermission('profile.view')
  @ApiEnvelope(AchievementDto, { isArray: true })
  @Get('me/achievements')
  myAchievements(@CurrentAuth() auth: AuthContext) {
    return this.portfolio.myAchievements(auth.userId);
  }

  @RequiresPermission('profile.edit')
  @HttpCode(201)
  @ApiEnvelope(AchievementDto, { status: 201 })
  @Post('me/achievements')
  addAchievement(@CurrentAuth() auth: AuthContext, @Body() dto: AchievementInputDto) {
    return this.portfolio.addAchievement(auth.userId, dto);
  }

  @RequiresPermission('profile.edit')
  @ApiEnvelope(AchievementDto)
  @Patch('me/achievements/:id')
  updateAchievement(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateAchievementDto,
  ) {
    return this.portfolio.updateAchievement(auth.userId, id, dto);
  }

  @RequiresPermission('profile.edit')
  @HttpCode(204)
  @Delete('me/achievements/:id')
  async deleteAchievement(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    await this.portfolio.deleteAchievement(auth.userId, id);
  }

  // ---- services ----

  @RequiresPermission('profile.view')
  @ApiEnvelope(ServiceDto, { isArray: true })
  @Get('me/services')
  myServices(@CurrentAuth() auth: AuthContext) {
    return this.portfolio.myServices(auth.userId);
  }

  @RequiresPermission('profile.edit')
  @HttpCode(201)
  @ApiEnvelope(ServiceDto, { status: 201 })
  @Post('me/services')
  addService(@CurrentAuth() auth: AuthContext, @Body() dto: ServiceInputDto) {
    return this.portfolio.addService(auth.userId, dto);
  }

  @RequiresPermission('profile.edit')
  @ApiEnvelope(ServiceDto)
  @Patch('me/services/:id')
  updateService(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateServiceDto,
  ) {
    return this.portfolio.updateService(auth.userId, id, dto);
  }

  @RequiresPermission('profile.edit')
  @HttpCode(204)
  @Delete('me/services/:id')
  async deleteService(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    await this.portfolio.deleteService(auth.userId, id);
  }

  // ---- someone else's portfolio: works signed out; what comes back depends on who is asking ----

  @OptionalAuth()
  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiEnvelope(ProjectCardDto, { isArray: true })
  @Get('creatives/:handle/projects')
  creativeProjects(
    @Param('handle') handle: string,
    @Query() q: PublicProjectsQueryDto,
    @Viewer() viewer?: AuthContext,
  ) {
    return this.portfolio.listPublicProjects(handle.slice(0, 64), viewer, q);
  }

  @OptionalAuth()
  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiEnvelope(ProjectDto)
  @Get('creatives/:handle/projects/:id')
  creativeProject(
    @Param('handle') handle: string,
    @Param('id', ParseUUIDPipe) id: string,
    @Query() q: PublicProfileQueryDto,
    @Viewer() viewer?: AuthContext,
  ) {
    return this.portfolio.getPublicProject(handle.slice(0, 64), id, viewer, q.previewAs);
  }

  @OptionalAuth()
  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiEnvelope(SkillEntryDto, { isArray: true })
  @Get('creatives/:handle/skills')
  creativeSkills(
    @Param('handle') handle: string,
    @Query() q: PublicProfileQueryDto,
    @Viewer() viewer?: AuthContext,
  ) {
    return this.portfolio.publicSkills(handle.slice(0, 64), viewer, q.previewAs);
  }

  @OptionalAuth()
  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiEnvelope(ExperienceDto, { isArray: true })
  @Get('creatives/:handle/experience')
  creativeExperience(
    @Param('handle') handle: string,
    @Query() q: PublicProfileQueryDto,
    @Viewer() viewer?: AuthContext,
  ) {
    return this.portfolio.publicExperience(handle.slice(0, 64), viewer, q.previewAs);
  }

  @OptionalAuth()
  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiEnvelope(AchievementDto, { isArray: true })
  @Get('creatives/:handle/achievements')
  creativeAchievements(
    @Param('handle') handle: string,
    @Query() q: PublicProfileQueryDto,
    @Viewer() viewer?: AuthContext,
  ) {
    return this.portfolio.publicAchievements(handle.slice(0, 64), viewer, q.previewAs);
  }

  @OptionalAuth()
  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiEnvelope(ServiceDto, { isArray: true })
  @Get('creatives/:handle/services')
  creativeServices(
    @Param('handle') handle: string,
    @Query() q: PublicProfileQueryDto,
    @Viewer() viewer?: AuthContext,
  ) {
    return this.portfolio.publicServices(handle.slice(0, 64), viewer, q.previewAs);
  }
}
