import 'dart:async';

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
import '../portfolio/portfolio_common.dart' show confirmSheet;
import 'enquiry_screens.dart';
import 'marketplace_common.dart';
import 'marketplace_providers.dart';

/// `my_listings`: live, new interest and views in 30 days; the member's listings with status pills and an
/// overflow menu; and the buyer interest list with "Reply".
class MyListingsScreen extends ConsumerStatefulWidget {
  const MyListingsScreen({super.key});

  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen> {
  void _refresh() {
    ref.invalidate(myListingsProvider);
    ref.invalidate(enquiriesProvider);
    ref.invalidate(marketplaceHomeProvider);
  }

  Future<void> _act(Future<void> Function() call, {String? done}) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await call();
      _refresh();
      if (done != null) messenger.showSnackBar(SnackBar(content: Text(done)));
    } on AppFailure catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _menu(ListingCardDto l) async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(marketplaceRepositoryProvider);
    final status = l.status;
    final choice = await showAtBottomSheet<String>(
      context: context,
      title: l.title,
      builder: (ctx) => Column(
        children: [
          if (status == ListingStatus.published)
            AtListRow(
              title: l10n.mkMenuView,
              icon: LucideIcons.eye,
              onTap: () => Navigator.of(ctx).pop('view'),
            ),
          if (status != ListingStatus.suspended)
            AtListRow(
              title: l10n.mkMenuEdit,
              icon: LucideIcons.pencil,
              onTap: () => Navigator.of(ctx).pop('edit'),
            ),
          if (status == ListingStatus.published)
            AtListRow(
              title: l10n.mkMenuPause,
              icon: LucideIcons.pause,
              onTap: () => Navigator.of(ctx).pop('pause'),
            ),
          if (status == ListingStatus.underReview)
            AtListRow(
              title: l10n.mkMenuWithdraw,
              icon: LucideIcons.undo2,
              onTap: () => Navigator.of(ctx).pop('withdraw'),
            ),
          if (status == ListingStatus.archived)
            AtListRow(
              title: l10n.mkMenuRestore,
              icon: LucideIcons.rotateCcw,
              onTap: () => Navigator.of(ctx).pop('restore'),
            ),
          if (status == ListingStatus.draft)
            AtListRow(
              title: l10n.mkMenuDelete,
              icon: LucideIcons.trash2,
              destructive: true,
              onTap: () => Navigator.of(ctx).pop('delete'),
            ),
        ],
      ),
    );
    if (!mounted || choice == null) return;
    switch (choice) {
      case 'view':
        unawaited(context.push(Routes.listingPath(l.id)));
      case 'edit':
        await context.push(Routes.listingEditPath(l.id));
        _refresh();
      case 'pause':
        final ok = await confirmSheet(
          context,
          title: l10n.mkPauseTitle,
          body: l10n.mkPauseBody,
          actionLabel: l10n.mkPause,
        );
        if (ok) await _act(() => repo.archive(l.id));
      case 'withdraw':
        await _act(() => repo.withdraw(l.id));
      case 'restore':
        await _act(() => repo.restore(l.id));
      case 'delete':
        final ok = await confirmSheet(
          context,
          title: l10n.mkDeleteTitle,
          body: l10n.mkDeleteBody,
          actionLabel: l10n.mkMenuDelete,
        );
        if (ok) await _act(() => repo.remove(l.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(myListingsProvider);
    final interest = ref.watch(enquiriesProvider(AsEnum.seller));
    return Scaffold(
      backgroundColor: context.at.background,
      body: AtPage(
        child: Column(
          children: [
            AtTopBar(
              title: l10n.mkMyListingsTitle,
              onBack: () => context.canPop()
                  ? context.pop()
                  : context.go(Routes.marketplace),
              actions: [
                AtIconButton(
                  icon: LucideIcons.plus,
                  semanticLabel: l10n.mkNewListing,
                  onPressed: () async {
                    await context.push(Routes.listingNew);
                    _refresh();
                  },
                ),
              ],
            ),
            Expanded(
              child: async.when(
                skipLoadingOnReload: true,
                loading: () => const AtLoadingBody(),
                error: (e, _) => loadFailure(
                  e,
                  () => ref.invalidate(myListingsProvider),
                  l10n,
                ),
                data: (mine) => !mine.isSeller
                    ? AtEmptyState(
                        icon: LucideIcons.store,
                        title: l10n.mkNotSellerTitle,
                        body: l10n.mkNotSellerBody,
                        ctaLabel: l10n.mkStartSellingCta,
                        onCta: () async {
                          await context.push(Routes.listingNew);
                          _refresh();
                        },
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          _refresh();
                          await ref.read(myListingsProvider.future);
                        },
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            AtSpacing.gutter,
                            0,
                            AtSpacing.gutter,
                            32,
                          ),
                          children: [
                            if (mine.sellerStatus ==
                                SellerStatus.suspended) ...[
                              AtInlineBanner(
                                message: l10n.mkSuspendedBanner,
                                tone: AtBannerTone.error,
                              ),
                              const SizedBox(height: 12),
                            ],
                            Row(
                              children: [
                                _Stat(l10n.mkStatLive, '${mine.stats.live}'),
                                const SizedBox(width: 10),
                                _Stat(
                                  l10n.mkStatInterest,
                                  '${mine.stats.newInterest}',
                                ),
                                const SizedBox(width: 10),
                                _Stat(
                                  l10n.mkStatViews,
                                  '${mine.stats.views30d}',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            for (final l in mine.listings) ...[
                              _ListingRow(
                                listing: l,
                                onMenu: () => _menu(l),
                                onTap: () async {
                                  if (l.status == ListingStatus.published) {
                                    unawaited(
                                      context.push(Routes.listingPath(l.id)),
                                    );
                                  } else {
                                    await context.push(
                                      Routes.listingEditPath(l.id),
                                    );
                                    _refresh();
                                  }
                                },
                              ),
                              const SizedBox(height: 10),
                            ],
                            AtSectionHeader(title: l10n.mkInterestTitle),
                            interest.when(
                              loading: () => const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              error: (e, _) => loadFailure(
                                e,
                                () => ref.invalidate(enquiriesProvider),
                                l10n,
                              ),
                              data: (page) => page.items.isEmpty
                                  ? Text(
                                      l10n.mkInterestEmpty,
                                      style: AtTextStyles.body.copyWith(
                                        color: context.at.muted,
                                      ),
                                    )
                                  : Column(
                                      children: [
                                        for (final e in page.items) ...[
                                          EnquiryRow(enquiry: e),
                                          const SizedBox(height: 10),
                                        ],
                                      ],
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

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: AtCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Text(
            value,
            style: AtTextStyles.sectionTitle.copyWith(color: context.at.ink),
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
}

class _ListingRow extends StatelessWidget {
  const _ListingRow({
    required this.listing,
    required this.onMenu,
    required this.onTap,
  });

  final ListingCardDto listing;
  final VoidCallback onMenu;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final look = listingStatusLook(l10n, listing.status);
    return AtCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      semanticLabel: '${listing.title}, ${look.label}',
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 64,
              height: 64,
              child: listing.coverUrl == null
                  ? ColoredBox(
                      color: context.at.softTile,
                      child: Icon(LucideIcons.image, color: context.at.faint),
                    )
                  : Image.network(listing.coverUrl!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AtTextStyles.cardTitle.copyWith(color: context.at.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  listing.priceLabel,
                  style: AtTextStyles.meta.copyWith(color: context.at.primary),
                ),
                const SizedBox(height: 6),
                AtStatusPill(label: look.label, tone: look.tone),
              ],
            ),
          ),
          AtIconButton(
            icon: LucideIcons.ellipsisVertical,
            semanticLabel: l10n.mkMenuMore,
            onPressed: onMenu,
          ),
        ],
      ),
    );
  }
}
