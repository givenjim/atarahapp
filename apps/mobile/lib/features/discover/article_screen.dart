import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/providers.dart';
import '../onboarding/onboarding_providers.dart';
import '../profile/profile_providers.dart';
import 'discover_common.dart';
import 'discover_providers.dart';

/// One article: source, title, byline, picture and the body as blocks, with save and share.
class ArticleScreen extends ConsumerStatefulWidget {
  const ArticleScreen({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends ConsumerState<ArticleScreen> {
  // What the member chose on this screen; null until they tap, so the server's answer is shown until then.
  bool? _saved;
  bool _saving = false;

  Future<void> _toggle(ArticleDto a) async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    final now = !(_saved ?? a.saved);
    setState(() {
      _saved = now;
      _saving = true;
    });
    final repo = ref.read(discoverRepositoryProvider);
    try {
      if (now) {
        await repo.saveArticle(a.id);
        ref.read(analyticsProvider).track('article_saved', {'slug': a.slug});
      } else {
        await repo.unsaveArticle(a.id);
      }
      if (mounted) setState(() => _saving = false);
    } on AppFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _saved = !now;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message.isEmpty ? l10n.dcSaveFailed : e.message),
        ),
      );
    }
  }

  Future<void> _share(ArticleDto a) async {
    ref.read(analyticsProvider).track('article_shared', {'slug': a.slug});
    await ref.read(shareTextProvider)('${a.title}\n${a.shareUrl}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(articleProvider(widget.slug));
    return Scaffold(
      backgroundColor: AtColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
              child: Row(
                children: [
                  AtIconButton(
                    icon: LucideIcons.arrowLeft,
                    semanticLabel: l10n.back,
                    onPressed: () =>
                        context.canPop() ? context.pop() : context.go('/home'),
                  ),
                  const Spacer(),
                  if (async.value case final a?) ...[
                    AtIconButton(
                      icon: LucideIcons.share2,
                      semanticLabel: l10n.dcShare,
                      onPressed: () => _share(a),
                    ),
                    const SizedBox(width: 8),
                    AtIconButton(
                      icon: (_saved ?? a.saved)
                          ? LucideIcons.bookmarkCheck
                          : LucideIcons.bookmark,
                      semanticLabel: (_saved ?? a.saved)
                          ? l10n.dcUnsave
                          : l10n.dcSave,
                      onPressed: () => _toggle(a),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => e is ApiFailure && e.statusCode == 404
                    ? AtEmptyState(
                        icon: LucideIcons.fileX,
                        title: l10n.dcArticleGone,
                        body: l10n.dcArticleGoneBody,
                      )
                    : loadFailure(
                        e,
                        () => ref.invalidate(articleProvider(widget.slug)),
                        l10n,
                      ),
                data: (a) => _Body(article: a),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.article});

  final ArticleDto article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final a = article;
    final hero = a.heroUrl == null
        ? null
        : ref.watch(avatarImageProvider)(a.heroUrl!);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AtSpacing.gutter,
        8,
        AtSpacing.gutter,
        40,
      ),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: AtTag(
            label: sourceLabelOf(
              l10n,
              a.source.json ?? 'ATARAH',
              a.sourceLabel,
            ),
            tone: AtTone.primary,
            icon: a.source == ArticleDtoSource.valueExternal
                ? LucideIcons.externalLink
                : null,
          ),
        ),
        const SizedBox(height: 12),
        Semantics(
          header: true,
          child: Text(
            a.title,
            style: AtTextStyles.detailTitle.copyWith(color: AtColors.ink),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${a.authorName} · ${readTime(l10n, a.readMinutes)} · ${shortDate(context, a.publishedAt)}',
          style: AtTextStyles.meta.copyWith(color: AtColors.muted),
        ),
        if (hero != null) ...[
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: AtRadii.cardLg,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image(
                image: hero,
                fit: BoxFit.cover,
                semanticLabel: a.title,
              ),
            ),
          ),
        ],
        const SizedBox(height: 18),
        for (final b in a.blocks) _Block(block: b),
      ],
    );
  }
}

class _Block extends ConsumerWidget {
  const _Block({required this.block});

  final ArticleBlockDto block;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final b = block;
    switch (b.type) {
      case ArticleBlockDtoType.heading:
        return Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 8),
          child: Semantics(
            header: true,
            child: Text(
              b.text ?? '',
              style: AtTextStyles.sectionTitle.copyWith(color: AtColors.ink),
            ),
          ),
        );
      case ArticleBlockDtoType.callout:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AtColors.tint3,
              borderRadius: AtRadii.card,
              border: Border.all(color: AtColors.secondaryBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.title ?? l10n.dcRuleOfThumb,
                  style: AtTextStyles.chip.copyWith(color: AtColors.primary),
                ),
                const SizedBox(height: 6),
                Text(
                  b.text ?? '',
                  style: AtTextStyles.body.copyWith(color: AtColors.longForm),
                ),
              ],
            ),
          ),
        );
      case ArticleBlockDtoType.quote:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Container(
            padding: const EdgeInsets.only(left: 14),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: AtColors.primaryLight, width: 3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.text ?? '',
                  style: AtTextStyles.bodyLg.copyWith(
                    color: AtColors.ink,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (b.attribution != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    b.attribution!,
                    style: AtTextStyles.metaSm.copyWith(color: AtColors.muted),
                  ),
                ],
              ],
            ),
          ),
        );
      case ArticleBlockDtoType.image:
        final url = b.imageUrl;
        // An image that is not ready yet is left out rather than drawn as a hole.
        if (url == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: AtRadii.card,
                child: Image(
                  image: ref.watch(avatarImageProvider)(url),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  semanticLabel: b.caption ?? '',
                ),
              ),
              if (b.caption != null) ...[
                const SizedBox(height: 6),
                Text(
                  b.caption!,
                  style: AtTextStyles.metaSm.copyWith(color: AtColors.muted),
                ),
              ],
            ],
          ),
        );
      case ArticleBlockDtoType.paragraph:
      case ArticleBlockDtoType.$unknown:
        if ((b.text ?? '').isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            b.text!,
            style: AtTextStyles.bodyLg.copyWith(
              color: AtColors.longForm,
              height: 1.6,
            ),
          ),
        );
    }
  }
}
