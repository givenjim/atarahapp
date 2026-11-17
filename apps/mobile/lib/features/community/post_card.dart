import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../shared/widgets/domain_cards.dart';
import '../onboarding/onboarding_providers.dart';
import '../portfolio/portfolio_providers.dart';
import '../profile/profile_providers.dart';
import 'community_common.dart';
import 'community_providers.dart';
import 'post_menu.dart';

/// One post in a list or at the top of a thread: the shared [PostCard] with the post's media and link preview,
/// an optimistic like (rolled back if the server says no), save, share and the overflow menu. Whatever the
/// member has just changed (liked, saved, edited) is read from [postOverridesProvider], so the feed and the
/// thread always agree.
class CommunityPostCard extends ConsumerWidget {
  const CommunityPostCard({
    super.key,
    required this.post,
    this.onOpen,
    this.onReply,
    this.detail = false,
    this.onRemoved,
  });

  final PostViewDto post;

  /// Opens the discussion. Null on the thread itself.
  final VoidCallback? onOpen;

  /// The reply button. In the feed it opens the thread.
  final VoidCallback? onReply;

  /// The full post: nothing is cut short and videos play in place.
  final bool detail;

  /// Called after the member deletes the post or blocks its author from the menu.
  final VoidCallback? onRemoved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final p = ref.watch(postOverridesProvider).resolve(post);
    final now = ref.watch(communityClockProvider)();
    final system = p.isStaffAnnouncement || p.type == PostType.announcement;
    final media = _PostExtras(post: p, detail: detail);

    return PostCard(
      authorName: system ? l10n.cfdAuthorTeam : p.author.displayName,
      authorSystem: system,
      authorVerified: p.author.verified,
      authorImageUrl: system ? null : p.author.avatarUrl,
      metaLine: authorMeta(
        l10n,
        headline: system ? null : p.author.headline,
        createdAt: p.createdAt,
        now: now,
        edited: p.editedAt != null,
      ),
      typeLabel: postTypeLabel(l10n, p.type),
      typeTone: postTypeTone(p.type),
      body: p.body,
      bodyMaxLines: detail ? null : 8,
      likeCount: p.reactionCount.toInt(),
      replyCount: p.replyCount.toInt(),
      liked: p.viewer.reacted,
      saved: p.viewer.saved,
      mediaSlot: media.isEmpty ? null : media,
      onTap: onOpen,
      onReply: onReply ?? onOpen,
      onLike: () => _like(context, ref, p),
      onSave: () => _save(context, ref, p),
      onShare: () => _share(ref, p, l10n),
      onMore: () async {
        final outcome = await showPostMenu(context, p);
        if (outcome != PostMenuOutcome.none) onRemoved?.call();
      },
    );
  }

  Future<void> _like(BuildContext context, WidgetRef ref, PostViewDto p) async {
    try {
      await ref.read(postActionsProvider).toggleLike(p);
    } on Object catch (e) {
      if (context.mounted) showCommunityError(context, e);
    }
  }

  Future<void> _save(BuildContext context, WidgetRef ref, PostViewDto p) async {
    final l10n = AppLocalizations.of(context);
    final saving = !p.viewer.saved;
    try {
      await ref.read(postActionsProvider).toggleSave(p);
      if (context.mounted) {
        showCommunityNotice(
          context,
          saving ? l10n.cfdSavedPost : l10n.cfdUnsavedPost,
        );
      }
    } on Object catch (e) {
      if (context.mounted) showCommunityError(context, e);
    }
  }

  Future<void> _share(
    WidgetRef ref,
    PostViewDto p,
    AppLocalizations l10n,
  ) async {
    final excerpt = p.body.length > 140
        ? '${p.body.substring(0, 140).trimRight()}…'
        : p.body;
    await ref.read(shareTextProvider)(
      l10n.cfdShareText(p.author.displayName, excerpt, postShareUrl(p.id)),
    );
  }
}

/// Photos, videos and the link preview under a post's words.
class _PostExtras extends ConsumerWidget {
  const _PostExtras({required this.post, required this.detail});

  final PostViewDto post;
  final bool detail;

  bool get isEmpty => post.media.isEmpty && post.link == null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = post.media;
    final videos = media.where((m) => m.kind == PostMediaKind.video).toList();
    final images = media.where((m) => m.kind != PostMediaKind.video).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (images.isNotEmpty)
          _ImageGrid(images: images, author: post.author.displayName),
        for (final v in videos) ...[
          if (images.isNotEmpty || v != videos.first) const SizedBox(height: 8),
          _VideoTile(video: v, playHere: detail),
        ],
        if (post.link != null) ...[
          if (media.isNotEmpty) const SizedBox(height: 8),
          _LinkPreview(link: post.link!),
        ],
      ],
    );
  }
}

class _Thumb extends ConsumerWidget {
  const _Thumb({required this.url, required this.label});

  final String? url;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ColoredBox(
    color: context.at.softTile,
    child: url == null
        ? Center(child: Icon(LucideIcons.image, color: context.at.muted))
        : Image(
            image: ref.watch(avatarImageProvider)(url!),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            semanticLabel: label,
            errorBuilder: (_, _, _) =>
                Center(child: Icon(LucideIcons.image, color: context.at.muted)),
          ),
  );
}

class _ImageGrid extends StatelessWidget {
  const _ImageGrid({required this.images, required this.author});

  final List<PostMediaItemDto> images;
  final String author;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String? url(PostMediaItemDto m) => m.url ?? m.thumbUrl;
    final label = l10n.cfdPhotoOf(author);
    if (images.length == 1) {
      return ClipRRect(
        borderRadius: AtRadii.card,
        child: AspectRatio(
          aspectRatio: 1.6,
          child: _Thumb(url: url(images.first), label: label),
        ),
      );
    }
    final extra = images.length - 2;
    return ClipRRect(
      borderRadius: AtRadii.card,
      child: SizedBox(
        height: 150,
        child: Row(
          children: [
            Expanded(
              child: _Thumb(url: url(images[0]), label: label),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _Thumb(url: url(images[1]), label: label),
                  if (extra > 0)
                    ColoredBox(
                      color: context.at.scrimSheet,
                      child: Center(
                        child: Text(
                          '+$extra',
                          style: AtTextStyles.sectionTitle.copyWith(
                            color: context.at.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoTile extends ConsumerWidget {
  const _VideoTile({required this.video, required this.playHere});

  final PostMediaItemDto video;
  final bool playHere;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final url = video.url;
    if (playHere && url != null) {
      return ref.watch(videoViewProvider)(context, url);
    }
    return ClipRRect(
      borderRadius: AtRadii.card,
      child: AspectRatio(
        aspectRatio: 1.6,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _Thumb(url: video.thumbUrl, label: l10n.cfdVideo),
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.at.scrimSheet,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(LucideIcons.play, color: context.at.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkPreview extends ConsumerWidget {
  const _LinkPreview({required this.link});

  final PostLinkPreviewDto link;

  String get _host {
    final host = Uri.tryParse(link.url)?.host ?? link.url;
    return host.startsWith('www.') ? host.substring(4) : host;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final title = link.title ?? link.siteName ?? _host;
    final open = Uri.tryParse(link.url);
    return Semantics(
      button: true,
      label: l10n.cfdOpenLink(title),
      excludeSemantics: true,
      onTap: open == null ? null : () => ref.read(openLinkProvider)(open),
      child: GestureDetector(
        onTap: open == null ? null : () => ref.read(openLinkProvider)(open),
        child: Container(
          decoration: BoxDecoration(
            color: context.at.softTile,
            borderRadius: AtRadii.card,
            border: Border.all(color: context.at.cardBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              if (link.image != null)
                SizedBox(
                  width: 84,
                  height: 84,
                  child: _Thumb(url: link.image, label: title),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        link.siteName ?? _host,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AtTextStyles.metaSm.copyWith(
                          color: context.at.muted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AtTextStyles.chip.copyWith(
                          color: context.at.ink,
                        ),
                      ),
                      if (link.description != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          link.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AtTextStyles.metaSm.copyWith(
                            color: context.at.body,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  LucideIcons.externalLink,
                  size: 16,
                  color: context.at.faint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
