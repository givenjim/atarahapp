import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/routing/routes.dart';
import '../onboarding/onboarding_providers.dart';
import '../onboarding/pick_sheet.dart';
import 'profile_labels.dart';
import 'profile_providers.dart';

String _memberSince(BuildContext context, DateTime d) =>
    DateFormat.yMMMM(Localizations.localeOf(context).toString())
        .format(d.toLocal());

/// The Creative Passport: the card, real growth bars, who can see what (changed in place), and the link.
class PassportScreen extends ConsumerStatefulWidget {
  const PassportScreen({super.key});

  @override
  ConsumerState<PassportScreen> createState() => _PassportScreenState();
}

class _PassportScreenState extends ConsumerState<PassportScreen> {
  String? _notice;
  String? _error;

  Future<void> _copy(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    setState(() {
      _error = null;
      _notice = AppLocalizations.of(context).ppLinkCopied;
    });
  }

  Future<void> _chooseAudience(SectionVisibilityDto row) async {
    final l10n = AppLocalizations.of(context);
    final section = SetSectionVisibilityDtoSection.values.firstWhere(
      (s) => s.json == row.section.json,
    );
    final options = [
      SetSectionVisibilityDtoVisibility.public,
      SetSectionVisibilityDtoVisibility.members,
      SetSectionVisibilityDtoVisibility.private,
    ];
    final picked = await showPickSheet(
      context,
      title: l10n.ppChooseAudience(sectionLabel(l10n, row.section)),
      options: [
        for (final v in options)
          PickOption(
            v.json!,
            '${visibilityOptionLabel(l10n, v)} — ${visibilityNote(l10n, v)}',
          ),
      ],
      selectedId: row.visibility.json,
    );
    if (picked == null || picked == row.visibility.json || !mounted) return;
    final visibility = options.firstWhere((v) => v.json == picked);
    setState(() {
      _notice = null;
      _error = null;
    });
    try {
      await ref
          .read(myPassportProvider.notifier)
          .setVisibility(section, visibility);
    } on AppFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on Object {
      if (mounted) setState(() => _error = l10n.ppVisibilityFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final passport = ref.watch(myPassportProvider);

    return Scaffold(
      body: AtPage(
        wash: AtWash.settings,
        child: Column(
          children: [
            AtTopBar(
              title: l10n.ppTitle,
              onBack: () =>
                  context.canPop() ? context.pop() : context.go(Routes.profile),
            ),
            Expanded(
              child: passport.when(
                loading: () => Semantics(
                  label: l10n.loading,
                  liveRegion: true,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AtSpacing.gutter),
                  child: AtErrorState(
                    title: l10n.pfLoadFailed,
                    body: e is AppFailure
                        ? e.message
                        : const UnexpectedFailure().message,
                    ctaLabel: l10n.retry,
                    onCta: () => ref.invalidate(myPassportProvider),
                  ),
                ),
                data: (p) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AtSpacing.gutter,
                    4,
                    AtSpacing.gutter,
                    AtSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_notice != null) ...[
                        AtInlineBanner(
                          message: _notice!,
                          tone: AtBannerTone.success,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (_error != null) ...[
                        AtInlineBanner(message: _error!),
                        const SizedBox(height: 12),
                      ],
                      _PassportCard(passport: p),
                      const SizedBox(height: 22),
                      _Growth(growth: p.growth),
                      const SizedBox(height: 22),
                      _Sections(rows: p.sections, onTap: _chooseAudience),
                      const SizedBox(height: 22),
                      AtButton(
                        label: l10n.ppCopyLink,
                        variant: AtButtonVariant.secondary,
                        icon: LucideIcons.link,
                        onPressed: () => _copy(p.shareUrl),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          p.shareUrl,
                          style: AtTextStyles.meta.copyWith(
                            color: AtColors.muted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AtButton(
                        label: l10n.ppCreateCv,
                        variant: AtButtonVariant.tertiary,
                        icon: LucideIcons.fileText,
                        // CV and EPK creation is a Phase 2 feature.
                        onPressed: () => context.push(
                          Routes.soonPath('p2', name: l10n.ppCreateCv),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PassportCard extends ConsumerWidget {
  const _PassportCard({required this.passport});

  final PassportDto passport;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final url = passport.avatarUrl;
    final line = [
      passport.discipline,
      passport.specialisation,
    ].whereType<String>().join(' · ');
    final place = placeLine(passport.location);
    final percent = passport.completion.percent.round();
    return Semantics(
      container: true,
      label: '${l10n.pfPassportCardTitle} ${passport.passportNumber}',
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: const BoxDecoration(
          color: AtColors.white,
          borderRadius: AtRadii.passport,
          boxShadow: AtShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  l10n.pfPassportCardTitle.toUpperCase(),
                  style: AtTextStyles.metaSm.copyWith(
                    color: AtColors.muted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
                Text(
                  passport.passportNumber.replaceAll('-', ' · '),
                  style: AtTextStyles.metaSm.copyWith(
                    color: AtColors.muted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                AtAvatar(
                  name: passport.displayName,
                  size: 64,
                  shape: AtAvatarShape.rounded,
                  image: url == null
                      ? null
                      : ref.watch(avatarImageProvider)(url),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        passport.displayName,
                        style: AtTextStyles.sectionTitle.copyWith(
                          color: AtColors.ink,
                        ),
                      ),
                      if (line.isNotEmpty)
                        Text(
                          line,
                          style: AtTextStyles.bodySm.copyWith(
                            color: AtColors.body,
                          ),
                        ),
                      if (place != null)
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.mapPin,
                              size: 12,
                              color: AtColors.muted,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                place,
                                style: AtTextStyles.meta.copyWith(
                                  color: AtColors.muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (passport.trust.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in passport.trust)
                    AtTag(label: t, tone: AtTone.success),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(
              l10n.ppMemberSince(_memberSince(context, passport.memberSince)),
              style: AtTextStyles.meta.copyWith(color: AtColors.muted),
            ),
            const SizedBox(height: 14),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  l10n.obCompletion,
                  style: AtTextStyles.meta.copyWith(color: AtColors.body),
                ),
                Text(
                  '$percent%',
                  style: AtTextStyles.meta.copyWith(
                    color: AtColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            AtProgressBar(
              value: percent / 100,
              height: 8,
              semanticLabel: l10n.obCompletion,
            ),
          ],
        ),
      ),
    );
  }
}

class _Growth extends StatelessWidget {
  const _Growth({required this.growth});

  final GrowthDto growth;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n.ppGrowth,
                style: AtTextStyles.sectionTitleSm.copyWith(
                  color: AtColors.ink,
                ),
              ),
            ),
            AtTag(
              label: strengthLabel(l10n, growth.strength),
              tone: switch (growth.strength) {
                GrowthDtoStrength.strong => AtTone.success,
                GrowthDtoStrength.active => AtTone.primary,
                GrowthDtoStrength.growing => AtTone.amber,
                _ => AtTone.neutral,
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        AtCard(
          child: Column(
            children: [
              for (final (i, b) in growth.bars.indexed) ...[
                if (i > 0) const SizedBox(height: 14),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      growthLabel(l10n, b.key),
                      style: AtTextStyles.bodySm.copyWith(color: AtColors.ink),
                    ),
                    Text(
                      '${b.percent.round()}%',
                      style: AtTextStyles.meta.copyWith(color: AtColors.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                AtProgressBar(
                  value: b.percent / 100,
                  semanticLabel: growthLabel(l10n, b.key),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Sections extends StatelessWidget {
  const _Sections({required this.rows, required this.onTap});

  final List<SectionVisibilityDto> rows;
  final ValueChanged<SectionVisibilityDto> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            l10n.ppSections,
            style: AtTextStyles.sectionTitleSm.copyWith(color: AtColors.ink),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.ppSectionsBody,
          style: AtTextStyles.meta.copyWith(color: AtColors.muted),
        ),
        const SizedBox(height: 10),
        AtCard(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (final (i, r) in rows.indexed)
                AtListRow(
                  title: sectionLabel(l10n, r.section),
                  trailing: AtTag(
                    label: visibilityLabel(l10n, r.visibility),
                    tone: switch (r.visibility) {
                      SectionVisibilityDtoVisibility.public => AtTone.success,
                      SectionVisibilityDtoVisibility.members => AtTone.primary,
                      _ => AtTone.neutral,
                    },
                  ),
                  showDivider: i < rows.length - 1,
                  onTap: () => onTap(r),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
