import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/connectivity/connectivity_provider.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/routing/routes.dart';
import '../../shared/widgets/domain_cards.dart';
import '../discover/discover_common.dart';
import '../profile/profile_providers.dart';
import 'my_opportunities_screen.dart' show completeFlow;
import 'opportunities_common.dart';
import 'opportunities_providers.dart';

/// One opportunity: what it is, who offers it, the facts, the check of the member's own profile against its
/// requirements, and the way to apply (which always goes through the "You're leaving Atarah" modal).
class OpportunityScreen extends ConsumerWidget {
  const OpportunityScreen({super.key, required this.opportunityId});

  final String opportunityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = opportunityDetailProvider(opportunityId);
    final async = ref.watch(provider);
    return Scaffold(
      backgroundColor: context.at.background,
      body: async.when(
        skipLoadingOnReload: true,
        loading: () => const AtLoadingBody(),
        error: (e, _) => SafeArea(
          child: Column(
            children: [
              AtTopBar(onBack: () => _back(context)),
              Expanded(
                child: e is ApiFailure && e.statusCode == 404
                    ? AtEmptyState(
                        icon: LucideIcons.searchX,
                        title: l10n.opNotAvailable,
                        ctaLabel: l10n.opExplore,
                        onCta: () => context.go(Routes.opportunities),
                      )
                    : loadFailure(e, () => ref.invalidate(provider), l10n),
              ),
            ],
          ),
        ),
        data: (o) => _Detail(opportunity: o),
      ),
    );
  }
}

void _back(BuildContext context) =>
    context.canPop() ? context.pop() : context.go(Routes.opportunities);

class _Detail extends ConsumerStatefulWidget {
  const _Detail({required this.opportunity});

  final OpportunityDto opportunity;

  @override
  ConsumerState<_Detail> createState() => _DetailState();
}

class _DetailState extends ConsumerState<_Detail> {
  bool _busy = false;

  OpportunityDto get o => widget.opportunity;

  Future<void> _refresh() =>
      ref.read(opportunityDetailProvider(o.id).notifier).refresh();

  Future<void> _share() =>
      ref.read(shareTextProvider)('${o.title}\n${o.shareUrl}');

  bool get _saved => ref.read(opportunitySavesProvider)[o.id] ?? o.saved;

  Future<void> _apply() async {
    final l10n = AppLocalizations.of(context);
    final email = o.applicationMethod == ApplicationMethod.email;
    final uri = email
        ? (o.applicationEmail == null
              ? null
              : Uri(scheme: 'mailto', path: o.applicationEmail))
        : Uri.tryParse(o.applicationUrl ?? '');
    if (uri == null) return;
    final choice = await showLeavingAtarahModal(
      context,
      domain: o.applicationDomain ?? uri.host,
    );
    if (choice == null || !choice.continueToSite || !mounted) return;
    setState(() => _busy = true);
    try {
      final ok = await ref.read(openLinkProvider)(uri);
      if (!mounted) return;
      if (!ok) {
        showOpportunityNotice(context, l10n.leavingOpenFailed);
        return;
      }
      // Only after the browser really opened, and only if the box stayed ticked.
      if (choice.trackAsApplied) {
        await ref
            .read(opportunityActionsProvider)
            .track(o.id, OpportunityTrackingStatus.applied);
      }
    } on Object catch (e) {
      if (mounted) showOpportunityNotice(context, opportunityError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _fix(String path) async {
    await context.push(path);
    // Back from fixing something: ask again without the server's cache.
    if (mounted) await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final saved = ref.watch(opportunitySavesProvider)[o.id] ?? o.saved;
    final applied = o.tracking?.status == OpportunityTrackingStatus.applied;
    final email = o.applicationMethod == ApplicationMethod.email;
    final canApply =
        !o.closed &&
        (email ? o.applicationEmail != null : o.applicationUrl != null);
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                _Hero(
                  type: o.type,
                  onBack: () => _back(context),
                  onShare: _share,
                ),
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.at.background,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(
                      AtSpacing.gutter,
                      22,
                      AtSpacing.gutter,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            AtTag(
                              label: opportunityTypeLabel(l10n, o.type),
                              tone: AtTone.violet,
                            ),
                            OpportunityTrustTag(trust: o.trust),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Semantics(
                          header: true,
                          child: Text(
                            o.title,
                            style: AtTextStyles.detailTitle.copyWith(
                              color: context.at.ink,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ProviderRow(opportunity: o),
                        const SizedBox(height: 18),
                        _Facts(opportunity: o),
                        if (o.closed) ...[
                          const SizedBox(height: 16),
                          AtInlineBanner(
                            message: l10n.opClosedNotice,
                            tone: AtBannerTone.info,
                          ),
                        ],
                        const SizedBox(height: 16),
                        _GapCard(gap: o.profileGap, onFix: _fix),
                        const SizedBox(height: 14),
                        _HelpRow(),
                        if (o.about.trim().isNotEmpty)
                          _TextSection(
                            title: l10n.opAbout,
                            paragraphs: o.about
                                .split(RegExp(r'\n\s*\n'))
                                .where((p) => p.trim().isNotEmpty)
                                .toList(),
                          ),
                        if (o.requirements.isNotEmpty)
                          _BulletSection(
                            title: l10n.opRequirements,
                            items: o.requirements,
                          ),
                        if (o.benefits.isNotEmpty)
                          _BulletSection(
                            title: l10n.opBenefits,
                            items: o.benefits,
                          ),
                        if (applied) ...[
                          const SizedBox(height: 22),
                          AtButton(
                            label: l10n.opMarkCompleted,
                            variant: AtButtonVariant.secondary,
                            onPressed: () => completeFlow(context, ref, o.id),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _BottomBar(
          title: o.title,
          saved: saved,
          onSave: () => toggleSave(context, ref, o.id, _saved),
          cta: canApply
              ? AtButton(
                  label: ref.watch(isOfflineProvider)
                      ? l10n.stOfflineNeedsConnection
                      : email
                      ? l10n.opApplyEmail
                      : l10n.opApplyWebsite,
                  trailingIcon: LucideIcons.arrowUpRight,
                  loading: _busy,
                  // Applying leaves Atarah for another site, so it needs a connection.
                  onPressed: ref.read(isOfflineProvider) ? null : _apply,
                )
              : null,
        ),
      ],
    );
  }
}

/// A calm gradient with the kind's icon: Atarah has no photo for an opportunity, and a stock one would say
/// more than it knows.
class _Hero extends StatelessWidget {
  const _Hero({
    required this.type,
    required this.onBack,
    required this.onShare,
  });

  final OpportunityType type;
  final VoidCallback onBack;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      height: 220,
      decoration: BoxDecoration(gradient: context.at.darkCardGradient),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Icon(
                  opportunityTypeIcon(type),
                  size: 72,
                  color: context.at.white.withValues(alpha: 0.28),
                ),
              ),
            ),
            Positioned(
              left: AtSpacing.topBarH,
              top: AtSpacing.topBarV,
              child: AtIconButton(
                icon: LucideIcons.chevronLeft,
                semanticLabel: l10n.back,
                onPressed: onBack,
              ),
            ),
            Positioned(
              right: AtSpacing.topBarH,
              top: AtSpacing.topBarV,
              child: AtIconButton(
                icon: LucideIcons.share2,
                semanticLabel: l10n.opShare,
                onPressed: onShare,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderRow extends StatelessWidget {
  const _ProviderRow({required this.opportunity});

  final OpportunityDto opportunity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = opportunity.provider;
    final initials = p.name
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(3)
        .map((w) => w[0].toUpperCase())
        .join();
    final monogram = Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.at.ink,
        borderRadius: AtRadii.tile,
      ),
      child: Text(
        initials,
        style: AtTextStyles.chipSm.copyWith(color: context.at.surface),
      ),
    );
    return Row(
      children: [
        // The provider's logo when it has one; its initials otherwise (and if the logo fails to load).
        if (p.logoUrl == null)
          monogram
        else
          ClipRRect(
            borderRadius: AtRadii.tile,
            child: Image.network(
              p.logoUrl!,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
              errorBuilder: (_, _, _) => monogram,
            ),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AtTextStyles.cardTitle.copyWith(
                        color: context.at.ink,
                      ),
                    ),
                  ),
                  if (p.verified) ...[
                    const SizedBox(width: 6),
                    const AtVerifiedTick(size: 14),
                  ],
                ],
              ),
              Text(
                trustLabel(l10n, opportunity.trust),
                style: AtTextStyles.metaSm.copyWith(color: context.at.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Facts extends StatelessWidget {
  const _Facts({required this.opportunity});

  final OpportunityDto opportunity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final o = opportunity;
    final urgency = detailUrgencyOf(o.urgency);
    final email = o.applicationMethod == ApplicationMethod.email;
    final tiles = <(IconData, String, String, AtTone)>[
      (
        LucideIcons.calendar,
        l10n.opFactDeadline,
        deadlineText(
          context,
          deadlineAt: o.deadlineAt,
          daysLeft: o.daysLeft,
          closed: o.closed,
        ),
        urgency == DeadlineUrgency.none ? AtTone.coral : urgencyTone(urgency),
      ),
      (
        LucideIcons.wallet,
        l10n.opFactValue,
        o.valueLabel ?? l10n.opNotStated,
        AtTone.primary,
      ),
      (
        LucideIcons.mapPin,
        l10n.opFactLocation,
        o.locationLabel ?? l10n.opNotStated,
        AtTone.violet,
      ),
      (
        LucideIcons.externalLink,
        l10n.opFactApplication,
        email ? l10n.opApplicationEmail : l10n.opApplicationExternal,
        AtTone.warning,
      ),
    ];
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        // About 110 at normal text (the old 1.55 ratio); taller as the text grows.
        mainAxisExtent: atScaledExtent(context, 110),
      ),
      children: [
        for (final (icon, label, value, tone) in tiles)
          Semantics(
            container: true,
            label: '$label: $value',
            excludeSemantics: true,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: tone.colorsOf(context).bg,
                borderRadius: AtRadii.tileLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18, color: tone.colorsOf(context).fg),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: AtTextStyles.metaSm.copyWith(
                      color: context.at.muted,
                    ),
                  ),
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AtTextStyles.chip.copyWith(
                      color: context.at.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// The member's own profile against the listing's structured requirements. Computed by the server from the
/// member's real profile; the app only shows it and links to where each gap can be closed.
class _GapCard extends StatelessWidget {
  const _GapCard({required this.gap, required this.onFix});

  final ProfileGapDto gap;
  final Future<void> Function(String path) onFix;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final missing = gap.blockingMissingCount > 0
        ? gap.blockingMissingCount.toInt()
        : gap.missingCount.toInt();
    final (title, body) = switch (gap.verdict) {
      ProfileGapDtoVerdict.missing => (
        l10n.opGapMissing(missing),
        l10n.opGapMissingBody,
      ),
      ProfileGapDtoVerdict.ready => (l10n.opGapReady, l10n.opGapReadyBody),
      ProfileGapDtoVerdict.unchecked => (
        l10n.opGapUnchecked,
        l10n.opGapUncheckedBody,
      ),
      _ => (l10n.opGapNoRules, l10n.opGapNoRulesBody),
    };
    final total = gap.rules.length;
    final met = gap.metCount.toInt();
    return AtDarkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (total > 0) ...[
                AtProgressRing(
                  value: met / total,
                  size: 60,
                  strokeWidth: 6,
                  label: '$met/$total',
                  onDark: true,
                  semanticLabel: l10n.opGapProgress(met, total),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: AtTextStyles.cardTitle.copyWith(
                          color: context.at.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      body,
                      style: AtTextStyles.metaSm.copyWith(
                        color: context.at.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: 14),
            for (final r in gap.rules) ...[
              _RuleRow(rule: r, onFix: onFix),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.rule, required this.onFix});

  final RuleResultDto rule;
  final Future<void> Function(String path) onFix;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (icon, color) = switch (rule.state) {
      RuleResultDtoState.met => (
        LucideIcons.circleCheck,
        context.at.successIcon,
      ),
      RuleResultDtoState.missing => (
        LucideIcons.circleDashed,
        context.at.white.withValues(alpha: 0.85),
      ),
      _ => (
        LucideIcons.circleQuestionMark,
        context.at.white.withValues(alpha: 0.6),
      ),
    };
    final fix = rule.fix;
    final detail = rule.state == RuleResultDtoState.unknown
        ? (rule.detail ?? l10n.opGapCannotCheck)
        : rule.detail;
    final actionLabel = rule.state == RuleResultDtoState.missing
        ? l10n.opGapAdd
        : fix?.label;
    return Semantics(
      container: true,
      label: [
        rule.label,
        ?detail,
        if (rule.state == RuleResultDtoState.met) l10n.opGapReady,
      ].join('. '),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: context.at.white.withValues(alpha: 0.08),
          borderRadius: AtRadii.tile,
        ),
        child: Row(
          children: [
            Icon(icon, size: 17, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rule.label,
                    style: AtTextStyles.bodySm.copyWith(
                      color: context.at.white,
                    ),
                  ),
                  if (detail != null)
                    Text(
                      detail,
                      style: AtTextStyles.metaSm.copyWith(
                        color: context.at.white.withValues(alpha: 0.7),
                      ),
                    ),
                ],
              ),
            ),
            if (fix != null &&
                actionLabel != null &&
                rule.state != RuleResultDtoState.met)
              Semantics(
                button: true,
                label: '$actionLabel: ${rule.label}',
                excludeSemantics: true,
                onTap: () => onFix(fix.path),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onFix(fix.path),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: AtSizes.touchTarget,
                      minWidth: 48,
                    ),
                    child: Center(
                      child: Text(
                        actionLabel,
                        style: AtTextStyles.chip.copyWith(
                          color: context.at.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

/// "Help me understand this": the AI summary arrives in Phase 3.
class _HelpRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    void open() => context.push(Routes.soonPath('p3', name: l10n.opHelpTitle));
    return AtCard(
      onTap: open,
      semanticLabel: '${l10n.opHelpTitle}. ${l10n.opHelpBody}',
      child: Row(
        children: [
          const AtIconTile(icon: LucideIcons.sparkles, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.opHelpTitle,
                  style: AtTextStyles.cardTitle.copyWith(color: context.at.ink),
                ),
                Text(
                  l10n.opHelpBody,
                  style: AtTextStyles.metaSm.copyWith(color: context.at.muted),
                ),
              ],
            ),
          ),
          Icon(LucideIcons.chevronRight, size: 18, color: context.at.muted),
        ],
      ),
    );
  }
}

class _TextSection extends StatelessWidget {
  const _TextSection({required this.title, required this.paragraphs});

  final String title;
  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 22),
      AtSectionHeader(title: title, compact: true),
      const SizedBox(height: 8),
      for (final p in paragraphs) ...[
        Text(
          p.trim(),
          style: AtTextStyles.body.copyWith(color: context.at.body),
        ),
        const SizedBox(height: 8),
      ],
    ],
  );
}

class _BulletSection extends StatelessWidget {
  const _BulletSection({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 22),
      AtSectionHeader(title: title, compact: true),
      const SizedBox(height: 8),
      for (final t in items)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 9, right: 10),
                decoration: BoxDecoration(
                  color: context.at.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  t,
                  style: AtTextStyles.body.copyWith(color: context.at.body),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.title,
    required this.saved,
    required this.onSave,
    required this.cta,
  });

  final String title;
  final bool saved;
  final VoidCallback onSave;
  final Widget? cta;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.at.surface,
        border: Border(top: BorderSide(color: context.at.cardBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AtSpacing.gutter,
            12,
            AtSpacing.gutter,
            12,
          ),
          child: Row(
            children: [
              Semantics(
                button: true,
                toggled: saved,
                label: saved ? l10n.unsaveItem(title) : l10n.saveItem(title),
                excludeSemantics: true,
                onTap: onSave,
                child: GestureDetector(
                  onTap: onSave,
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: saved
                          ? context.at.primaryTint
                          : context.at.surface,
                      border: Border.all(
                        color: context.at.secondaryBorder,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      LucideIcons.bookmark,
                      size: 20,
                      fill: saved ? 1 : 0,
                      color: context.at.primary,
                    ),
                  ),
                ),
              ),
              if (cta != null) ...[
                const SizedBox(width: 10),
                Expanded(child: cta!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
