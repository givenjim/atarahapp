import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/routing/routes.dart';
import '../../shared/widgets/domain_cards.dart';
import '../discover/discover_common.dart';
import 'opportunities_providers.dart';

/// "Grant", "Internship": one opportunity's kind.
String opportunityTypeLabel(AppLocalizations l10n, OpportunityType t) =>
    switch (t) {
      OpportunityType.grant => l10n.opTypeGrant,
      OpportunityType.funding => l10n.opTypeFunding,
      OpportunityType.job => l10n.opTypeJob,
      OpportunityType.internship => l10n.opTypeInternship,
      OpportunityType.gig => l10n.opTypeGig,
      OpportunityType.competition => l10n.opTypeCompetition,
      OpportunityType.festival => l10n.opTypeFestival,
      OpportunityType.partnership => l10n.opTypePartnership,
      OpportunityType.fellowship => l10n.opTypeFellowship,
      OpportunityType.residency => l10n.opTypeResidency,
      OpportunityType.programme => l10n.opTypeProgramme,
      OpportunityType.$unknown => l10n.featureOpportunities,
    };

/// "Grants", "Jobs": a category's name (also the title of its list).
String opportunityCategoryLabel(AppLocalizations l10n, OpportunityType? t) =>
    switch (t) {
      null => l10n.opCatAll,
      OpportunityType.grant => l10n.opCatGrants,
      OpportunityType.funding => l10n.opCatFunding,
      OpportunityType.job => l10n.opCatJobs,
      OpportunityType.internship => l10n.opCatInternships,
      OpportunityType.gig => l10n.opCatGigs,
      OpportunityType.competition => l10n.opCatCompetitions,
      OpportunityType.festival => l10n.opCatFestivals,
      OpportunityType.partnership => l10n.opCatPartnerships,
      OpportunityType.fellowship => l10n.opCatFellowships,
      OpportunityType.residency => l10n.opCatResidencies,
      OpportunityType.programme => l10n.opCatProgrammes,
      OpportunityType.$unknown => l10n.opCatAll,
    };

IconData opportunityTypeIcon(OpportunityType? t) => switch (t) {
  null => LucideIcons.layoutGrid,
  OpportunityType.grant => LucideIcons.handCoins,
  OpportunityType.funding => LucideIcons.wallet,
  OpportunityType.job => LucideIcons.briefcase,
  OpportunityType.internship => LucideIcons.graduationCap,
  OpportunityType.gig => LucideIcons.zap,
  OpportunityType.competition => LucideIcons.trophy,
  OpportunityType.festival => LucideIcons.ticket,
  OpportunityType.partnership => LucideIcons.handshake,
  OpportunityType.fellowship => LucideIcons.award,
  OpportunityType.residency => LucideIcons.house,
  OpportunityType.programme => LucideIcons.calendarRange,
  OpportunityType.$unknown => LucideIcons.briefcase,
};

OpportunityTrustLevel trustLevelOf(OpportunityTrust t) => switch (t) {
  OpportunityTrust.verified => OpportunityTrustLevel.verified,
  OpportunityTrust.sourceConfirmed => OpportunityTrustLevel.sourceConfirmed,
  _ => OpportunityTrustLevel.externalSource,
};

/// "Verified by Atarah" only for VERIFIED; the other two levels say exactly what they are.
String trustLabel(AppLocalizations l10n, OpportunityTrust t) => switch (t) {
  OpportunityTrust.verified => l10n.verifiedByAtarah,
  OpportunityTrust.sourceConfirmed => l10n.sourceConfirmed,
  _ => l10n.externalSource,
};

IconData trustIcon(OpportunityTrust t) => switch (t) {
  OpportunityTrust.verified => LucideIcons.badgeCheck,
  OpportunityTrust.sourceConfirmed => LucideIcons.shieldCheck,
  _ => LucideIcons.globe,
};

/// Coral at 7 days or fewer, Tangerine at 8 to 14 (the server decides; the app only colours).
DeadlineUrgency urgencyOf(OpportunityCardDtoUrgency? u) => switch (u) {
  OpportunityCardDtoUrgency.urgent => DeadlineUrgency.closing,
  OpportunityCardDtoUrgency.soon => DeadlineUrgency.soon,
  _ => DeadlineUrgency.none,
};

DeadlineUrgency detailUrgencyOf(OpportunityDtoUrgency? u) => switch (u) {
  OpportunityDtoUrgency.urgent => DeadlineUrgency.closing,
  OpportunityDtoUrgency.soon => DeadlineUrgency.soon,
  _ => DeadlineUrgency.none,
};

AtTone urgencyTone(DeadlineUrgency u) => switch (u) {
  DeadlineUrgency.closing => AtTone.coral,
  DeadlineUrgency.soon => AtTone.warning,
  DeadlineUrgency.none => AtTone.neutral,
};

/// "4 days left" inside the closing-soon window, the date after it, "Rolling deadline" with none.
String deadlineText(
  BuildContext context, {
  required DateTime? deadlineAt,
  required num? daysLeft,
  required bool closed,
}) {
  final l10n = AppLocalizations.of(context);
  if (closed) return l10n.opClosed;
  if (deadlineAt == null) return l10n.opRolling;
  if (daysLeft != null && daysLeft <= 14) {
    return l10n.opDaysLeft(daysLeft.toInt());
  }
  return shortDate(context, deadlineAt.toLocal());
}

String opportunityError(Object e) =>
    e is AppFailure ? e.message : const UnexpectedFailure().message;

void showOpportunityNotice(BuildContext context, String message) {
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

String outcomeLabel(AppLocalizations l10n, OpportunityOutcome o) => switch (o) {
  OpportunityOutcome.awarded => l10n.opOutcomeAwarded,
  OpportunityOutcome.notSelected => l10n.opOutcomeNotSelected,
  OpportunityOutcome.withdrawn => l10n.opOutcomeWithdrawn,
  _ => l10n.opOutcomeUnknown,
};

/// An opportunity in any list: the shared card, with a bookmark that flips at once and flips back (with the
/// server's words) when saving fails.
class OpportunityTile extends ConsumerWidget {
  const OpportunityTile({
    super.key,
    required this.opportunity,
    this.trackingLabel,
    this.footer,
  });

  final OpportunityCardDto opportunity;

  /// Replaces the status pill (My opportunities says where the member is with each one).
  final String? trackingLabel;
  final Widget? footer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final o = opportunity;
    final saved = ref.watch(opportunitySavesProvider)[o.id] ?? o.saved;
    final card = OpportunityCard(
      title: o.title,
      providerName: o.provider.name,
      providerLogoUrl: o.provider.logoUrl,
      typeLabel: opportunityTypeLabel(l10n, o.type),
      trust: trustLevelOf(o.trust),
      deadlineLabel: deadlineText(
        context,
        deadlineAt: o.deadlineAt,
        daysLeft: o.daysLeft,
        closed: o.closed,
      ),
      urgency: urgencyOf(o.urgency),
      valueLabel: o.valueLabel,
      locationLabel: o.locationLabel,
      saved: saved,
      trackingLabel: trackingLabel,
      onTap: () => context.push(Routes.opportunityPath(o.id)),
      onSave: () => toggleSave(context, ref, o.id, saved),
    );
    if (footer == null) return card;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [card, const SizedBox(height: 8), footer!],
    );
  }
}

/// Flips a bookmark; a refusal rolls it back and says why.
Future<void> toggleSave(
  BuildContext context,
  WidgetRef ref,
  String id,
  bool currentlySaved,
) async {
  try {
    await ref
        .read(opportunitySavesProvider.notifier)
        .toggle(id, currentlySaved: currentlySaved);
  } on Object catch (e) {
    if (context.mounted) showOpportunityNotice(context, opportunityError(e));
  }
}

/// The trust badge as a tag: "Verified by Atarah" only when Atarah verified it.
class OpportunityTrustTag extends StatelessWidget {
  const OpportunityTrustTag({super.key, required this.trust});

  final OpportunityTrust trust;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AtTag(
      label: trustLabel(l10n, trust),
      tone: trust == OpportunityTrust.externalSource
          ? AtTone.neutral
          : AtTone.primary,
      icon: trustIcon(trust),
    );
  }
}
