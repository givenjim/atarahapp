import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/routing/routes.dart';
import '../onboarding/onboarding_providers.dart';
import '../profile/profile_providers.dart';
import 'portfolio_common.dart';
import 'portfolio_providers.dart';

IconData categoryIcon(String? json) => switch (json) {
  'MEDIA' => LucideIcons.clapperboard,
  'PUBLICATION' => LucideIcons.bookOpen,
  'PERFORMANCE' => LucideIcons.drama,
  _ => LucideIcons.layoutGrid,
};

/// One project in a grid: cover (or a category icon when it has no picture), title, role and date.
class ProjectTile extends ConsumerWidget {
  const ProjectTile({
    super.key,
    required this.project,
    required this.onTap,
    this.hero = false,
  });

  final ProjectCardDto project;
  final VoidCallback onTap;
  final bool hero;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final p = project;
    final image = p.coverUrl == null
        ? null
        : ref.watch(avatarImageProvider)(p.coverUrl!);
    final isDraft = p.status == ProjectCardDtoStatus.draft;
    final subtitle = [
      if (p.role != null) p.role!,
      if (p.projectDate != null) monthYear(context, p.projectDate),
    ].join(' · ');
    return Semantics(
      button: true,
      label: [
        p.title.isEmpty ? l10n.pjUntitled : p.title,
        if (isDraft) l10n.pjDraft,
        if (p.hidden) l10n.pjHidden,
        if (p.featured) l10n.pjFeatured,
        subtitle,
      ].where((s) => s.isNotEmpty).join(', '),
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: hero ? 16 / 9 : 1,
              child: ClipRRect(
                borderRadius: AtRadii.card,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(
                      color: AtColors.softTile,
                      child: image != null
                          ? Image(
                              image: image,
                              fit: BoxFit.cover,
                              excludeFromSemantics: true,
                            )
                          : Icon(
                              categoryIcon(p.category.json),
                              size: 32,
                              color: AtColors.muted,
                            ),
                    ),
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Wrap(
                        spacing: 4,
                        children: [
                          if (isDraft)
                            AtTag(label: l10n.pjDraft, tone: AtTone.warning),
                          if (p.hidden)
                            AtTag(label: l10n.pjHidden, tone: AtTone.pink),
                          if (p.featured && !isDraft)
                            const Icon(
                              LucideIcons.star,
                              size: 16,
                              color: AtColors.white,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              p.title.isEmpty ? l10n.pjUntitled : p.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AtTextStyles.cardTitle.copyWith(color: AtColors.ink),
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AtTextStyles.meta.copyWith(color: AtColors.muted),
              ),
          ],
        ),
      ),
    );
  }
}

/// A two-column grid of tiles that wraps without a fixed height, so large text never overflows.
class ProjectGrid extends StatelessWidget {
  const ProjectGrid({super.key, required this.projects, required this.onOpen});

  final List<ProjectCardDto> projects;
  final ValueChanged<ProjectCardDto> onOpen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const gap = 12.0;
        final w = (c.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: 16,
          children: [
            for (final p in projects)
              SizedBox(
                width: w,
                child: ProjectTile(project: p, onTap: () => onOpen(p)),
              ),
          ],
        );
      },
    );
  }
}

/// The member's own portfolio: filter chips, featured hero, grid, drafts, and invitations to be tagged.
class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  /// 'ALL', 'FEATURED' or a category json.
  String _filter = 'ALL';
  String? _error;
  final Set<String> _busy = {};

  void _refresh() {
    ref.invalidate(myProjectsProvider);
    ref.invalidate(myCollaborationsProvider);
  }

  Future<void> _answer(CollaborationDto c, {required bool accept}) async {
    setState(() {
      _busy.add(c.id);
      _error = null;
    });
    final repo = ref.read(portfolioRepositoryProvider);
    try {
      if (accept) {
        await repo.acceptCollaboration(c.id);
      } else {
        await repo.leaveCollaboration(c.id);
      }
      ref.invalidate(myCollaborationsProvider);
    } on AppFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy.remove(c.id));
    }
  }

  Future<void> _open(ProjectCardDto p) async {
    if (p.status == ProjectCardDtoStatus.draft) {
      await context.push(Routes.projectEditPath(p.id));
    } else {
      await context.push(Routes.projectPath(p.id));
    }
    if (mounted) _refresh();
  }

  Future<void> _add() async {
    await context.push(Routes.projectEditPath('new'));
    if (mounted) {
      _refresh();
      ref.invalidate(myProfileProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final projects = ref.watch(myProjectsProvider);
    final invites = ref.watch(myCollaborationsProvider);
    final pending = [
      for (final c in invites.value ?? const <CollaborationDto>[])
        if (c.status == CollaborationDtoStatus.pending) c,
    ];

    return PortfolioScaffold(
      title: l10n.pfPortfolio,
      addLabel: l10n.pjAdd,
      onBack: () =>
          context.canPop() ? context.pop() : context.go(Routes.profile),
      onAdd: _add,
      body: AsyncBody<List<ProjectCardDto>>(
        value: projects,
        onRetry: _refresh,
        builder: (all) {
          final published = [
            for (final p in all)
              if (p.status == ProjectCardDtoStatus.published) p,
          ];
          final drafts = [
            for (final p in all)
              if (p.status == ProjectCardDtoStatus.draft) p,
          ];
          final shown = [
            for (final p in published)
              if (_filter == 'ALL' ||
                  (_filter == 'FEATURED' && p.featured) ||
                  p.category.json == _filter)
                p,
          ];
          final hero = _filter == 'ALL' || _filter == 'FEATURED'
              ? shown.where((p) => p.featured).firstOrNull
              : null;
          final grid = [
            for (final p in shown)
              if (p.id != hero?.id) p,
          ];
          final chips = <(String, String)>[
            ('ALL', l10n.pjAll),
            ('FEATURED', l10n.pjFeatured),
            ('PROJECT', l10n.pjCatProjects),
            ('MEDIA', l10n.pjCatMediaPlural),
            ('PUBLICATION', l10n.pjCatPublications),
            ('PERFORMANCE', l10n.pjCatPerformances),
          ];

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AtSpacing.gutter,
              4,
              AtSpacing.gutter,
              AtSpacing.xl,
            ),
            children: [
              if (_error != null) ...[
                AtInlineBanner(message: _error!, tone: AtBannerTone.error),
                const SizedBox(height: 12),
              ],
              for (final c in pending) ...[
                _InviteCard(
                  invite: c,
                  busy: _busy.contains(c.id),
                  onAccept: () => _answer(c, accept: true),
                  onDecline: () => _answer(c, accept: false),
                ),
                const SizedBox(height: 12),
              ],
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final (key, label) in chips) ...[
                      AtChip(
                        label: label,
                        selected: _filter == key,
                        onTap: () => setState(() => _filter = key),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (hero != null) ...[
                ProjectTile(
                  project: hero,
                  hero: true,
                  onTap: () => _open(hero),
                ),
                const SizedBox(height: 16),
              ],
              if (grid.isNotEmpty)
                ProjectGrid(projects: grid, onOpen: _open)
              else if (hero == null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    published.isEmpty
                        ? l10n.pjEmptyBody
                        : l10n.pjNothingInFilter,
                    style: AtTextStyles.bodySm.copyWith(color: AtColors.muted),
                  ),
                ),
              const SizedBox(height: 16),
              AtUploadZone(
                label: l10n.pjAddZone,
                icon: LucideIcons.plus,
                height: 96,
                onTap: _add,
              ),
              if (drafts.isNotEmpty) ...[
                const SizedBox(height: 24),
                Semantics(
                  header: true,
                  child: Text(
                    l10n.pjDrafts,
                    style: AtTextStyles.sectionTitleSm.copyWith(
                      color: AtColors.ink,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ProjectGrid(projects: drafts, onOpen: _open),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _InviteCard extends StatelessWidget {
  const _InviteCard({
    required this.invite,
    required this.busy,
    required this.onAccept,
    required this.onDecline,
  });

  final CollaborationDto invite;
  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AtCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.pjInviteTitle(invite.ownerName, invite.projectTitle),
            style: AtTextStyles.cardTitle.copyWith(color: AtColors.ink),
          ),
          if (invite.role != null) ...[
            const SizedBox(height: 4),
            Text(
              l10n.pjInviteRole(invite.role!),
              style: AtTextStyles.meta.copyWith(color: AtColors.muted),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AtButton(
                  label: l10n.pjInviteAccept,
                  size: AtButtonSize.md,
                  loading: busy,
                  onPressed: onAccept,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AtButton(
                  label: l10n.pjInviteDecline,
                  size: AtButtonSize.md,
                  variant: AtButtonVariant.secondary,
                  onPressed: busy ? null : onDecline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
