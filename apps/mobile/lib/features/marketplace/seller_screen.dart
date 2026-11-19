import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/routing/routes.dart';
import '../discover/discover_common.dart';
import 'marketplace_common.dart';
import 'marketplace_providers.dart';

/// `seller`: header, stats (rating, completed, reply time), trust lines only when the server sends real ones, and
/// the seller's live services and products.
class SellerScreen extends ConsumerWidget {
  const SellerScreen({super.key, required this.sellerId});

  final String sellerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = sellerProfileProvider(sellerId);
    final async = ref.watch(provider);
    void back() =>
        context.canPop() ? context.pop() : context.go(Routes.marketplace);
    return Scaffold(
      backgroundColor: context.at.background,
      body: AtPage(
        child: Column(
          children: [
            AtTopBar(title: l10n.mkSellerTitle, onBack: back),
            Expanded(
              child: async.when(
                skipLoadingOnReload: true,
                loading: () => const AtLoadingBody(),
                error: (e, _) => e is ApiFailure && e.statusCode == 404
                    ? AtEmptyState(
                        icon: LucideIcons.searchX,
                        title: l10n.mkNotAvailable,
                        ctaLabel: l10n.mkBackToMarket,
                        onCta: () => context.go(Routes.marketplace),
                      )
                    : loadFailure(e, () => ref.invalidate(provider), l10n),
                data: (s) => RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(provider);
                    await ref.read(provider.future);
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 32),
                    children: [
                      _Header(seller: s),
                      const SizedBox(height: 16),
                      _Stats(seller: s),
                      if (s.trustLines.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AtSpacing.gutter,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final line in s.trustLines)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      const AtVerifiedTick(),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          line,
                                          style: AtTextStyles.bodySm.copyWith(
                                            color: context.at.ink,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                      if (s.bio != null) ...[
                        AtSectionHeader(title: l10n.mkSellerAbout),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AtSpacing.gutter,
                          ),
                          child: Text(
                            s.bio!,
                            style: AtTextStyles.body.copyWith(
                              color: context.at.body,
                            ),
                          ),
                        ),
                      ],
                      if (s.hasProfile && s.handle != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AtSpacing.gutter,
                            12,
                            AtSpacing.gutter,
                            0,
                          ),
                          child: AtButton(
                            label: l10n.mkViewProfile,
                            variant: AtButtonVariant.secondary,
                            onPressed: () =>
                                context.push(Routes.creativePath(s.handle!)),
                          ),
                        ),
                      AtSectionHeader(title: l10n.mkSellerListings),
                      if (s.listings.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AtSpacing.gutter,
                          ),
                          child: Text(
                            l10n.mkSellerNoListings,
                            style: AtTextStyles.body.copyWith(
                              color: context.at.muted,
                            ),
                          ),
                        )
                      else
                        ListingGrid(items: s.listings),
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

class _Header extends StatelessWidget {
  const _Header({required this.seller});

  final SellerProfileDto seller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AtSpacing.gutter),
      child: Column(
        children: [
          AtAvatar(
            name: seller.displayName,
            size: 84,
            image: seller.avatarUrl == null
                ? null
                : NetworkImage(seller.avatarUrl!),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  seller.displayName,
                  textAlign: TextAlign.center,
                  style: AtTextStyles.sectionTitle.copyWith(
                    color: context.at.ink,
                  ),
                ),
              ),
              if (seller.verified) ...[
                const SizedBox(width: 6),
                const AtVerifiedTick(),
              ],
            ],
          ),
          if (seller.headline != null)
            Text(
              seller.headline!,
              textAlign: TextAlign.center,
              style: AtTextStyles.body.copyWith(color: context.at.body),
            ),
          const SizedBox(height: 4),
          Text(
            [
              if (seller.location != null) seller.location!,
              l10n.mkMemberSince(
                MaterialLocalizations.of(context)
                    .formatMediumDate(seller.memberSince),
              ),
            ].join(' · '),
            textAlign: TextAlign.center,
            style: AtTextStyles.meta.copyWith(color: context.at.muted),
          ),
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.seller});

  final SellerProfileDto seller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget stat(String label, String value) => Expanded(
      child: AtCard(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: AtTextStyles.cardTitle.copyWith(color: context.at.ink),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AtTextStyles.metaSm.copyWith(color: context.at.muted),
            ),
          ],
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AtSpacing.gutter),
      child: Row(
        children: [
          stat(
            l10n.mkStatRating,
            seller.ratingAverage == null
                ? l10n.mkNewSeller
                : '${seller.ratingAverage!.toStringAsFixed(1)} (${seller.ratingCount})',
          ),
          const SizedBox(width: 10),
          stat(l10n.mkStatCompleted, '${seller.completedCount}'),
          const SizedBox(width: 10),
          stat(l10n.mkStatReply, seller.replyLabel ?? '—'),
        ],
      ),
    );
  }
}
