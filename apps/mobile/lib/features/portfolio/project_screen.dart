import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/routing/routes.dart';
import '../onboarding/onboarding_providers.dart';
import '../profile/profile_providers.dart';
import '../profile/profile_repository.dart';
import 'media_seams.dart';
import 'portfolio_common.dart';
import 'portfolio_providers.dart';

/// One project, media first. With no [handle] it is the signed-in member's own project (drafts included, with
/// Edit and Share); with a handle it is someone's published project as the server allows this viewer to see it.
class ProjectScreen extends ConsumerStatefulWidget {
  const ProjectScreen({
    super.key,
    required this.projectId,
    this.handle,
    this.preview,
  });

  final String projectId;
  final String? handle;
  final PublicProfilePreview? preview;

  @override
  ConsumerState<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends ConsumerState<ProjectScreen> {
  String? _error;

  bool get _own => widget.handle == null;

  AsyncValue<ProjectDto> _watch() => _own
      ? ref.watch(myProjectProvider(widget.projectId))
      : ref.watch(
          creativeProjectProvider(
            widget.handle!,
            widget.projectId,
            widget.preview,
          ),
        );

  void _refresh() => _own
      ? ref.invalidate(myProjectProvider(widget.projectId))
      : ref.invalidate(
          creativeProjectProvider(
            widget.handle!,
            widget.projectId,
            widget.preview,
          ),
        );

  Future<void> _openLink(String url) async {
    final l10n = AppLocalizations.of(context);
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return;
    final choice = await showLeavingAtarahModal(
      context,
      domain: uri.host,
      showTrackOption: false,
    );
    if (choice?.continueToSite != true) return;
    final ok = await ref.read(openLinkProvider)(uri);
    if (!ok && mounted) setState(() => _error = l10n.leavingOpenFailed);
  }

  Future<void> _share(ProjectDto p) async {
    final l10n = AppLocalizations.of(context);
    final link = (await ref.read(myProfileProvider.future))?.shareUrl;
    await ref.read(shareTextProvider)(
      [l10n.pjShareText(p.title), ?link].join('\n'),
    );
  }

  Future<void> _edit() async {
    await context.push(Routes.projectEditPath(widget.projectId));
    if (mounted) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = _watch();
    return Scaffold(
      body: AtPage(
        wash: AtWash.community,
        child: Column(
          children: [
            AtTopBar(
              onBack: () => context.canPop()
                  ? context.pop()
                  : context.go(_own ? Routes.profile : Routes.home),
              actions: [
                if (_own && async.hasValue) ...[
                  AtIconButton(
                    icon: LucideIcons.share2,
                    semanticLabel: l10n.pjShare,
                    onPressed: () => _share(async.requireValue),
                  ),
                  AtIconButton(
                    icon: LucideIcons.pencil,
                    semanticLabel: l10n.pjEdit,
                    onPressed: _edit,
                  ),
                ],
              ],
            ),
            Expanded(
              child: AsyncBody<ProjectDto>(
                value: async,
                onRetry: _refresh,
                notFoundTitle: l10n.pjNotFound,
                builder: _body,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(ProjectDto p) {
    final l10n = AppLocalizations.of(context);
    final image = ref.watch(avatarImageProvider);
    final video = ref.watch(videoViewProvider);
    final audio = ref.watch(audioViewProvider);
    final embed = ref.watch(embedViewProvider);
    final embedded = [
      for (final l in p.links)
        if (l.embedUrl != null) l,
    ];
    final external = [
      for (final l in p.links)
        if (l.embedUrl == null) l,
    ];
    final subtitle = [
      if (p.role != null) p.role!,
      if (p.client != null) p.client!,
      if (p.projectDate != null) monthYear(context, p.projectDate),
    ].join(' · ');

    Widget heading(String t) => Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Semantics(
        header: true,
        child: Text(
          t,
          style: AtTextStyles.cardTitle.copyWith(color: AtColors.ink),
        ),
      ),
    );

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
        if (_own && p.hidden) ...[
          AtInlineBanner(
            message: l10n.pjHiddenNotice(p.hiddenReason ?? ''),
            tone: AtBannerTone.error,
          ),
          const SizedBox(height: 12),
        ],
        if (_own && p.status == ProjectDtoStatus.draft) ...[
          AtInlineBanner(message: l10n.pjDraftNotice, tone: AtBannerTone.info),
          const SizedBox(height: 12),
        ],
        for (final m in p.media) ...[
          _MediaItem(media: m, image: image, video: video, audio: audio),
          const SizedBox(height: 12),
        ],
        for (final l in embedded) ...[
          Semantics(label: l.label, child: embed(context, l.embedUrl!)),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AtTag(
              label: categoryLabel(l10n, p.category.json),
              tone: AtTone.primary,
            ),
            if (p.featured) AtTag(label: l10n.pjFeatured, tone: AtTone.amber),
            if (_own)
              AtTag(
                label: projectVisibilityLabel(l10n, p.visibility.json),
                tone: AtTone.neutral,
              ),
          ],
        ),
        const SizedBox(height: 12),
        Semantics(
          header: true,
          child: Text(
            p.title.isEmpty ? l10n.pjUntitled : p.title,
            style: AtTextStyles.detailTitle.copyWith(color: AtColors.ink),
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AtTextStyles.bodySm.copyWith(color: AtColors.muted),
          ),
        ],
        if (p.description != null) ...[
          const SizedBox(height: 16),
          Text(
            p.description!,
            style: AtTextStyles.body.copyWith(color: AtColors.longForm),
          ),
        ],
        if (p.skills.isNotEmpty) ...[
          heading(l10n.pjSkillsUsed),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in p.skills)
                AtTag(label: s.name, tone: AtTone.neutral),
            ],
          ),
        ],
        if (p.collaborators.isNotEmpty) ...[
          heading(l10n.pjCollaborators),
          AtCard(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (final (i, c) in p.collaborators.indexed)
                  AtListRow(
                    title: c.name,
                    subtitle: [
                      if (c.role != null) c.role!,
                      if (c.status == CollaboratorDtoStatus.pending)
                        l10n.pjCollabPending,
                    ].join(' · '),
                    icon: LucideIcons.user,
                    showChevron: c.handle != null,
                    showDivider: i < p.collaborators.length - 1,
                    onTap: c.handle == null
                        ? null
                        : () => context.push(Routes.creativePath(c.handle!)),
                  ),
              ],
            ),
          ),
        ],
        if (p.outcome != null) ...[
          heading(l10n.pjOutcome),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AtColors.softTile,
              borderRadius: AtRadii.card,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  LucideIcons.trophy,
                  size: 18,
                  color: AtColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    p.outcome!,
                    style: AtTextStyles.body.copyWith(color: AtColors.ink),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (external.isNotEmpty) ...[
          heading(l10n.pjLinks),
          AtCard(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (final (i, l) in external.indexed)
                  AtListRow(
                    title: l.label,
                    subtitle: Uri.tryParse(l.url)?.host,
                    icon: LucideIcons.externalLink,
                    showDivider: i < external.length - 1,
                    onTap: () => _openLink(l.url),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _MediaItem extends StatelessWidget {
  const _MediaItem({
    required this.media,
    required this.image,
    required this.video,
    required this.audio,
  });

  final ProjectMediaDto media;
  final AvatarImageBuilder image;
  final MediaViewBuilder video;
  final MediaViewBuilder audio;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final url = media.url;
    if (media.status != ProjectMediaDtoStatus.ready || url == null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: AtColors.softTile,
            borderRadius: AtRadii.card,
          ),
          child: Center(
            child: Text(
              l10n.pjMediaProcessing,
              style: AtTextStyles.bodySm.copyWith(color: AtColors.muted),
            ),
          ),
        ),
      );
    }
    switch (media.kind) {
      case ProjectMediaDtoKind.video:
        return video(context, url);
      case ProjectMediaDtoKind.audio:
        return audio(context, url);
      default:
        final w = media.width?.toDouble();
        final h = media.height?.toDouble();
        return ClipRRect(
          borderRadius: AtRadii.card,
          child: AspectRatio(
            aspectRatio: w != null && h != null && h > 0
                ? (w / h).clamp(0.6, 2.0)
                : 4 / 3,
            child: Image(
              image: image(media.thumbnailUrl ?? url),
              fit: BoxFit.cover,
              semanticLabel: media.caption ?? l10n.pjImageAlt,
            ),
          ),
        );
    }
  }
}
