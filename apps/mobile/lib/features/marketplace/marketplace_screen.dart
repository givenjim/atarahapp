import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/routing/routes.dart';
import '../discover/discover_common.dart';
import 'marketplace_common.dart';
import 'marketplace_providers.dart';

/// `market`: a "My listings" pill for sellers, search, Services / Products / Sellers, the featured carousel, the
/// category grid, popular sellers, and the "Start selling" promo for members who are not sellers yet.
class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  int _segment = 0; // 0 services, 1 products, 2 sellers

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(marketplaceHomeProvider);
    return Scaffold(
      backgroundColor: context.at.background,
      body: AtPage(
        child: Column(
          children: [
            AtTopBar(
              onBack: () =>
                  context.canPop() ? context.pop() : context.go(Routes.explore),
              actions: [
                AtIconButton(
                  icon: LucideIcons.messagesSquare,
                  semanticLabel: l10n.mkMyRequests,
                  onPressed: () => context.push(Routes.enquiries),
                ),
              ],
            ),
            Expanded(
              child: async.when(
                skipLoadingOnReload: true,
                loading: () => const AtLoadingBody(),
                error: (e, _) => loadFailure(
                  e,
                  () => ref.invalidate(marketplaceHomeProvider),
                  l10n,
                ),
                data: (home) => RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(marketplaceHomeProvider);
                    await ref.read(marketplaceHomeProvider.future);
                  },
                  child: _body(context, l10n, home),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    AppLocalizations l10n,
    MarketplaceHomeDto home,
  ) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AtSpacing.gutter),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.mkTitle,
                        style: AtTextStyles.tabTitle.copyWith(
                          color: context.at.ink,
                          fontSize: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.mkSubtitle,
                      style: AtTextStyles.body.copyWith(color: context.at.body),
                    ),
                  ],
                ),
              ),
              if (home.isSeller)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: AtChip(
                    label: l10n.mkMyListings,
                    kind: AtChipKind.selectable,
                    selected: true,
                    icon: LucideIcons.store,
                    onTap: () => context.push(Routes.myListings),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AtSpacing.gutter),
          child: _SearchEntry(
            hint: l10n.mkSearchHint,
            onTap: () => context.push(Routes.search),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AtSpacing.gutter),
          child: AtSegmented(
            labels: [l10n.mkSegServices, l10n.mkSegProducts, l10n.mkSegSellers],
            selectedIndex: _segment,
            onChanged: (i) {
              if (i == 2) {
                setState(() => _segment = 2);
              } else {
                // Services and Products open the browse list for that kind.
                context.push(
                  Routes.marketplaceBrowsePath(
                    type: i == 0 ? 'SERVICE' : 'PRODUCT',
                  ),
                );
              }
            },
          ),
        ),
        const SizedBox(height: 8),
        if (_segment == 2)
          _SellersList()
        else ...[
          if (home.featured.isNotEmpty) ...[
            AtSectionHeader(title: l10n.mkFeatured),
            SizedBox(
              height: 270,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AtSpacing.gutter,
                ),
                itemCount: home.featured.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) => SizedBox(
                  width: 220,
                  child: MarketplaceListingCard(listing: home.featured[i]),
                ),
              ),
            ),
          ],
          if (home.categories.isNotEmpty) ...[
            AtSectionHeader(
              title: l10n.mkCategories,
              onSeeAll: () => context.push(Routes.marketplaceBrowsePath()),
              seeAllLabel: l10n.mkSeeAll,
            ),
            _CategoryGrid(categories: home.categories),
          ],
          if (home.popularSellers.isNotEmpty) ...[
            AtSectionHeader(
              title: l10n.mkPopularSellers,
              onSeeAll: () => setState(() => _segment = 2),
              seeAllLabel: l10n.mkSeeAll,
            ),
            for (final s in home.popularSellers.take(4))
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AtSpacing.gutter,
                  0,
                  AtSpacing.gutter,
                  10,
                ),
                child: SellerRow(
                  seller: s,
                  onTap: () => context.push(Routes.sellerPath(s.id)),
                ),
              ),
          ],
          if (home.recent.isNotEmpty) ...[
            AtSectionHeader(
              title: l10n.mkRecent,
              onSeeAll: () => context.push(Routes.marketplaceBrowsePath()),
              seeAllLabel: l10n.mkSeeAll,
            ),
            ListingGrid(items: home.recent),
          ],
          if (home.featured.isEmpty && home.recent.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: AtEmptyState(
                icon: LucideIcons.store,
                title: l10n.mkNothingTitle,
                body: l10n.mkNothingBody,
              ),
            ),
          if (!home.isSeller)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AtSpacing.gutter,
                12,
                AtSpacing.gutter,
                0,
              ),
              child: AtDarkCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.mkStartSellingTitle,
                      style: AtTextStyles.sectionTitleSm.copyWith(
                        color: context.at.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.mkStartSellingBody,
                      style: AtTextStyles.bodySm.copyWith(
                        color: context.at.white,
                      ),
                    ),
                    const SizedBox(height: 14),
                    AtButton(
                      label: l10n.mkStartSellingCta,
                      variant: AtButtonVariant.secondary,
                      onPressed: () => context.push(Routes.listingNew),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _SearchEntry extends StatelessWidget {
  const _SearchEntry({required this.hint, required this.onTap});

  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: hint,
    excludeSemantics: true,
    onTap: onTap,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: context.at.inputFill,
          borderRadius: AtRadii.input,
          border: Border.all(color: context.at.inputBorder),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.search, size: 18, color: context.at.muted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AtTextStyles.body.copyWith(color: context.at.faint),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.categories});

  final List<CategoryDto> categories;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AtSpacing.gutter),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final c in categories)
            SizedBox(
              width:
                  (MediaQuery.sizeOf(context).width -
                      AtSpacing.gutter * 2 -
                      10 * 3) /
                  4,
              child: Semantics(
                button: true,
                label: '${c.name}, ${l10n.mkCategoryCount(c.count.toInt())}',
                excludeSemantics: true,
                child: GestureDetector(
                  onTap: () => context.push(
                    Routes.marketplaceBrowsePath(
                      categoryId: c.id,
                      categoryName: c.name,
                    ),
                  ),
                  child: Column(
                    children: [
                      AtIconTile(
                        icon: categoryIcon(c.icon),
                        tone: toneOf(c.tone),
                        size: 56,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        c.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AtTextStyles.chipSm.copyWith(
                          color: context.at.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SellersList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(popularSellersProvider(null));
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) =>
          loadFailure(e, () => ref.invalidate(popularSellersProvider), l10n),
      data: (page) => page.items.isEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 24),
              child: AtEmptyState(
                icon: LucideIcons.users,
                title: l10n.mkNothingTitle,
                body: l10n.mkNothingBody,
              ),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(
                AtSpacing.gutter,
                8,
                AtSpacing.gutter,
                0,
              ),
              child: Column(
                children: [
                  for (final s in page.items) ...[
                    SellerRow(
                      seller: s,
                      onTap: () => context.push(Routes.sellerPath(s.id)),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
    );
  }
}
