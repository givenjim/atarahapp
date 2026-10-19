import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../onboarding/onboarding_providers.dart';

/// Shown when something that loads fails: the typed failure's own words, and a way to try again.
Widget loadFailure(Object e, VoidCallback retry, AppLocalizations l10n) =>
    AtErrorState(
      title: l10n.dcLoadFailed,
      body: e is AppFailure ? e.message : const UnexpectedFailure().message,
      ctaLabel: l10n.retry,
      onCta: retry,
    );

String shortDate(BuildContext context, DateTime d) =>
    DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(d);

/// "Atarah Editorial", or who it came from.
String sourceLabelOf(
  AppLocalizations l10n,
  String sourceJson,
  String? sourceLabel,
) => switch (sourceJson) {
  'PARTNER' => sourceLabel ?? l10n.dcSourcePartner,
  'EXTERNAL' => sourceLabel ?? l10n.dcSourceExternal,
  _ => l10n.dcSourceAtarah,
};

String readTime(AppLocalizations l10n, num minutes) =>
    l10n.dcReadMinutes(minutes.toInt());

/// A picture from the network, or the person's initials until there is one.
class Portrait extends ConsumerWidget {
  const Portrait({
    super.key,
    required this.name,
    required this.url,
    this.size = 48,
    this.rounded = false,
  });

  final String name;
  final String? url;
  final double size;
  final bool rounded;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AtAvatar(
    name: name,
    size: size,
    shape: rounded ? AtAvatarShape.rounded : AtAvatarShape.circle,
    image: url == null ? null : ref.watch(avatarImageProvider)(url!),
  );
}

/// One creative in a list: 96 px picture, name and tick, what they do, a few skills and where they are.
class CreativeCard extends StatelessWidget {
  const CreativeCard({super.key, required this.creative, required this.onTap});

  final CreativeCardDto creative;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = creative;
    final role = c.headline ?? c.discipline?.name;
    return Semantics(
      button: true,
      label: [
        c.displayName,
        if (c.verified) l10n.dcVerified,
        ?role,
        if (c.location != null) c.location!,
        if (c.openToCommissions) l10n.dcOpenToCommissions,
      ].join(', '),
      excludeSemantics: true,
      onTap: onTap,
      child: AtCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: AtRadii.card,
              child: Portrait(
                name: c.displayName,
                url: c.avatarUrl,
                size: 96,
                rounded: true,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          c.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AtTextStyles.cardTitle.copyWith(
                            color: AtColors.ink,
                          ),
                        ),
                      ),
                      if (c.verified) ...[
                        const SizedBox(width: 6),
                        const AtVerifiedTick(),
                      ],
                    ],
                  ),
                  if (role != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      role,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AtTextStyles.bodySm.copyWith(color: AtColors.body),
                    ),
                  ],
                  if (c.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final t in c.tags.take(2))
                          AtTag(label: t, tone: AtTone.primary),
                      ],
                    ),
                  ],
                  if (c.location != null || c.openToCommissions) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (c.location != null) ...[
                          const Icon(
                            LucideIcons.mapPin,
                            size: 13,
                            color: AtColors.muted,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              c.location!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AtTextStyles.metaSm.copyWith(
                                color: AtColors.muted,
                              ),
                            ),
                          ),
                        ],
                        if (c.location != null && c.openToCommissions)
                          const SizedBox(width: 10),
                        if (c.openToCommissions)
                          Text(
                            l10n.dcOpenToCommissions,
                            style: AtTextStyles.metaSm.copyWith(
                              color: AtColors.successStrong,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A person suggested on Home: picture, name, what they do and why they are suggested.
class CreativeMiniCard extends StatelessWidget {
  const CreativeMiniCard({
    super.key,
    required this.creative,
    required this.onTap,
  });

  final CreativeCardDto creative;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = creative;
    return SizedBox(
      width: 168,
      child: Semantics(
        button: true,
        label: [
          c.displayName,
          if (c.verified) l10n.dcVerified,
          ?c.discipline?.name,
          ?c.reason,
        ].join(', '),
        excludeSemantics: true,
        onTap: onTap,
        child: AtCard(
          onTap: onTap,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Portrait(name: c.displayName, url: c.avatarUrl, size: 56),
              const SizedBox(height: 10),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      c.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AtTextStyles.chip.copyWith(color: AtColors.ink),
                    ),
                  ),
                  if (c.verified) ...[
                    const SizedBox(width: 4),
                    const AtVerifiedTick(size: 14),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                c.discipline?.name ?? c.headline ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AtTextStyles.metaSm.copyWith(color: AtColors.body),
              ),
              if (c.reason != null) ...[
                const SizedBox(height: 6),
                Text(
                  c.reason!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AtTextStyles.metaSm.copyWith(color: AtColors.primary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// An article in a list: picture, source, title and who wrote it.
class ArticleTile extends ConsumerWidget {
  const ArticleTile({
    super.key,
    required this.article,
    required this.onTap,
    this.large = false,
  });

  final ArticleCardDto article;
  final VoidCallback onTap;

  /// Picture across the top instead of at the side.
  final bool large;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final a = article;
    final image = a.heroUrl == null
        ? null
        : ref.watch(avatarImageProvider)(a.heroUrl!);
    final picture = ClipRRect(
      borderRadius: AtRadii.card,
      child: SizedBox(
        width: large ? double.infinity : 92,
        height: large ? 150 : 92,
        child: ColoredBox(
          color: AtColors.softTile,
          child: image != null
              ? Image(
                  image: image,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                )
              : const Icon(LucideIcons.bookOpen, color: AtColors.muted),
        ),
      ),
    );
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sourceLabelOf(l10n, a.source.json ?? 'ATARAH', a.sourceLabel),
          style: AtTextStyles.metaSm.copyWith(color: AtColors.primary),
        ),
        const SizedBox(height: 4),
        Text(
          a.title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: AtTextStyles.cardTitle.copyWith(color: AtColors.ink),
        ),
        const SizedBox(height: 4),
        Text(
          '${a.authorName} · ${readTime(l10n, a.readMinutes)}',
          style: AtTextStyles.metaSm.copyWith(color: AtColors.muted),
        ),
      ],
    );
    return Semantics(
      button: true,
      label: '${a.title}, ${a.authorName}, ${readTime(l10n, a.readMinutes)}',
      excludeSemantics: true,
      onTap: onTap,
      child: AtCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        child: large
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [picture, const SizedBox(height: 12), text],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  picture,
                  const SizedBox(width: 12),
                  Expanded(child: text),
                ],
              ),
      ),
    );
  }
}
