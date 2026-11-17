import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/routing/routes.dart';
import '../account/account_common.dart';
import '../account/account_providers.dart';
import '../discover/discover_common.dart';

/// Membership (read-only in Phase 1): the current plan, what Free and Pro include, the scholarship note and an
/// "Upgrade to Pro" button that opens its "Soon" screen (payments arrive in Phase 2).
class MembershipScreen extends ConsumerWidget {
  const MembershipScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(membershipProvider);
    return SubPage(
      title: l10n.profileMembership,
      child: async.when(
        loading: () => const AtLoadingBody(),
        error: (e, _) =>
            loadFailure(e, () => ref.invalidate(membershipProvider), l10n),
        data: (m) {
          final pro = m.plan == MembershipViewDtoPlan.pro;
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AtSpacing.gutter,
              8,
              AtSpacing.gutter,
              32,
            ),
            children: [
              AtDarkCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.stCurrentPlan,
                      style: AtTextStyles.label.copyWith(
                        color: context.at.white.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pro
                          ? l10n.profileMembershipPro
                          : l10n.profileMembershipFree,
                      style: AtTextStyles.tabTitle.copyWith(
                        color: context.at.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pro
                          ? (m.currentPeriodEnd == null
                                ? l10n.stPlanProBody
                                : l10n.stPlanRenews(
                                    shortDate(
                                      context,
                                      m.currentPeriodEnd!.toLocal(),
                                    ),
                                  ))
                          : l10n.stPlanFreeBody,
                      style: AtTextStyles.bodySm.copyWith(
                        color: context.at.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              GroupLabel(l10n.stWhatsIncluded),
              AtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: context.at.mist,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.stFeature,
                              style: AtTextStyles.label.copyWith(
                                color: context.at.muted,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 56,
                            child: Text(
                              l10n.profileMembershipFree,
                              style: AtTextStyles.label.copyWith(
                                color: context.at.muted,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 56,
                            child: Text(
                              l10n.profileMembershipPro,
                              style: AtTextStyles.label.copyWith(
                                color: context.at.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (final row in m.comparison)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: context.at.divider),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                row.label,
                                style: AtTextStyles.bodySm.copyWith(
                                  color: context.at.ink,
                                ),
                              ),
                            ),
                            SizedBox(width: 56, child: _Mark(on: row.free)),
                            SizedBox(
                              width: 56,
                              child: _Mark(on: row.pro, strong: true),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              AtCard(
                color: context.at.primaryTintFaint,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      LucideIcons.graduationCap,
                      size: 18,
                      color: context.at.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        m.scholarshipNote,
                        style: AtTextStyles.bodySm.copyWith(
                          color: context.at.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!pro) ...[
                const SizedBox(height: 20),
                AtButton(
                  label: m.proPriceLabel.isEmpty
                      ? l10n.stUpgradePlain
                      : l10n.stUpgrade(m.proPriceLabel),
                  onPressed: () => context.push(
                    Routes.soonPath('p2', name: l10n.profileMembership),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.stCancelAnytime,
                  textAlign: TextAlign.center,
                  style: AtTextStyles.metaSm.copyWith(color: context.at.muted),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Mark extends StatelessWidget {
  const _Mark({required this.on, this.strong = false});

  final bool on;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        label: on
            ? AppLocalizations.of(context).stIncluded
            : AppLocalizations.of(context).stNotIncluded,
        child: Icon(
          on ? LucideIcons.check : LucideIcons.minus,
          size: 17,
          color: on
              ? (strong ? context.at.primary : context.at.successStrong)
              : context.at.muted,
        ),
      ),
    );
  }
}
