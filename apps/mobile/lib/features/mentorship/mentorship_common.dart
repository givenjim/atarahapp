import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/routing/routes.dart';
import '../discover/discover_common.dart';

/// "KES 1,500": a price in minor units (cents) for display. Whole amounts drop the decimals.
String formatMoney(num minor, String currency) {
  final major = minor / 100;
  final f = major == major.roundToDouble()
      ? NumberFormat.decimalPattern()
      : NumberFormat('#,##0.00');
  return '$currency ${f.format(major)}';
}

/// "Tue 24 Nov, 14:30 EAT": a UTC instant in the member's own time zone, with the zone's label.
String formatSlot(BuildContext context, DateTime at) {
  final local = at.toLocal();
  final locale = Localizations.localeOf(context).toString();
  final day = DateFormat('EEE d MMM', locale).format(local);
  final time = DateFormat('HH:mm', locale).format(local);
  return '$day, $time ${local.timeZoneName}';
}

/// Minutes after midnight as "08:30".
String formatMinute(int minute) =>
    '${(minute ~/ 60).toString().padLeft(2, '0')}:${(minute % 60).toString().padLeft(2, '0')}';

String failureMessage(Object e) =>
    e is AppFailure ? e.message : const UnexpectedFailure().message;

/// Whether an error means "this member is not a mentor" (the tools answer 403 or 404 to everyone else).
bool isNotMentor(Object e) =>
    e is ApiFailure && (e.statusCode == 403 || e.statusCode == 404);

/// One mentor in a list or carousel: picture, name and tick, what they do, tags, next availability, rating, price.
class MentorCard extends StatelessWidget {
  const MentorCard({super.key, required this.mentor, this.width});

  final MentorCardDto mentor;

  /// Fixed width for carousels; null fills the list.
  final double? width;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final m = mentor;
    final next = m.nextAvailableAt;
    final card = AtCard(
      onTap: () => context.push(Routes.mentorPath(m.id)),
      semanticLabel: '${m.displayName}, ${m.headline}',
      labelReplacesContent: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Portrait(name: m.displayName, url: m.avatarUrl, size: 56),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            m.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AtTextStyles.cardTitle.copyWith(
                              color: context.at.ink,
                            ),
                          ),
                        ),
                        if (m.verified) ...[
                          const SizedBox(width: 4),
                          const AtVerifiedTick(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      m.headline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AtTextStyles.meta.copyWith(color: context.at.body),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (m.expertiseTags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final t in m.expertiseTags.take(3))
                  AtTag(label: t, tone: AtTone.violet),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(LucideIcons.calendarClock, size: 15, color: context.at.body),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  next == null
                      ? l10n.mnNoAvailability
                      : l10n.mnNextAvailable(formatSlot(context, next)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AtTextStyles.meta.copyWith(color: context.at.body),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(LucideIcons.star, size: 15, color: context.at.body),
              const SizedBox(width: 6),
              Text(
                m.ratingCount > 0
                    ? l10n.mnRatingLine(
                        m.ratingAverage.toStringAsFixed(1),
                        m.ratingCount.toInt(),
                      )
                    : l10n.mnNewMentor,
                style: AtTextStyles.meta.copyWith(color: context.at.body),
              ),
              const Spacer(),
              if (m.fromPriceMinor != null)
                Text(
                  l10n.mnFromPrice(formatMoney(m.fromPriceMinor!, m.currency)),
                  style: AtTextStyles.chip.copyWith(color: context.at.ink),
                ),
            ],
          ),
        ],
      ),
    );
    return width == null ? card : SizedBox(width: width, child: card);
  }
}

/// The lock screen for booking: the shared gate with mentorship wording. The price comes from the membership
/// settings once those are readable (P2-M2); until then the button just says "See Pro". "See Pro" opens the
/// membership screen, which exists; the dedicated premium route replaces it when P2-M2 ships.
class MentorshipPremiumGate extends StatelessWidget {
  const MentorshipPremiumGate({super.key, this.priceLabel = ''});

  final String priceLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AtPremiumGate(
      feature: l10n.mnGateFeature,
      whatItDoes: l10n.mnGateWhat,
      whyItMatters: l10n.mnGateWhy,
      howToGet: l10n.mnGateHow,
      priceLabel: priceLabel,
      onSeePro: () => context.push(Routes.membership),
    );
  }
}

/// A screen scaffold shared by the mentorship screens: top bar with back, a title, and the body.
class MentorshipScaffold extends StatelessWidget {
  const MentorshipScaffold({
    super.key,
    required this.title,
    required this.body,
    this.fallbackRoute = Routes.mentorship,
    this.actions = const [],
    this.bottom,
  });

  final String title;
  final Widget body;
  final String fallbackRoute;
  final List<Widget> actions;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.at.background,
    body: AtPage(
      wash: AtWash.community,
      child: Column(
        children: [
          AtTopBar(
            title: title,
            onBack: () =>
                context.canPop() ? context.pop() : context.go(fallbackRoute),
            actions: actions,
          ),
          Expanded(child: body),
          ?bottom,
        ],
      ),
    ),
  );
}

/// A bottom action bar with one primary button.
class MentorshipBottomBar extends StatelessWidget {
  const MentorshipBottomBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(
      AtSpacing.gutter,
      12,
      AtSpacing.gutter,
      12 + MediaQuery.paddingOf(context).bottom,
    ),
    decoration: BoxDecoration(
      color: context.at.surface,
      border: Border(top: BorderSide(color: context.at.cardBorder)),
    ),
    child: child,
  );
}

/// Scrolling page padding used by every mentorship screen.
const mentorshipPadding = EdgeInsets.fromLTRB(
  AtSpacing.gutter,
  8,
  AtSpacing.gutter,
  32,
);

/// Parses "1500" or "1,500.50" as minor units (cents). Null when it is not a non-negative number.
int? parseMajorToMinor(String text) {
  final cleaned = text.replaceAll(',', '').trim();
  final v = double.tryParse(cleaned);
  if (v == null || v < 0) return null;
  return (v * 100).round();
}

/// Minor units as the text a price field starts with ("1500" or "1500.5").
String minorToMajorText(num minor) {
  final major = minor / 100;
  return major == major.roundToDouble()
      ? major.toInt().toString()
      : major.toStringAsFixed(2);
}
