import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/routing/routes.dart';
import '../../shared/widgets/domain_cards.dart';
import 'marketplace_providers.dart';

/// A listing's status as the seller reads it, with the tone of its pill.
({String label, AtTone tone}) listingStatusLook(
  AppLocalizations l10n,
  ListingStatus s,
) => switch (s) {
  ListingStatus.draft => (label: l10n.mkStatusDraft, tone: AtTone.neutral),
  ListingStatus.underReview => (
    label: l10n.mkStatusUnderReview,
    tone: AtTone.warning,
  ),
  ListingStatus.published => (
    label: l10n.mkStatusPublished,
    tone: AtTone.success,
  ),
  ListingStatus.rejected => (label: l10n.mkStatusRejected, tone: AtTone.coral),
  ListingStatus.suspended => (
    label: l10n.mkStatusSuspended,
    tone: AtTone.coral,
  ),
  ListingStatus.archived => (
    label: l10n.mkStatusArchived,
    tone: AtTone.neutral,
  ),
  ListingStatus.$unknown => (label: s.name, tone: AtTone.neutral),
};

String sortLabel(AppLocalizations l10n, ListingSort s) => switch (s) {
  ListingSort.recommended => l10n.mkSortRecommended,
  ListingSort.priceLow => l10n.mkSortPriceLow,
  ListingSort.priceHigh => l10n.mkSortPriceHigh,
  ListingSort.rating => l10n.mkSortRating,
  ListingSort.newest => l10n.mkSortNewest,
  ListingSort.$unknown => s.name,
};

/// Lucide icon for a category's icon name; falls back to a tag.
IconData categoryIcon(String name) => switch (name) {
  'camera' => LucideIcons.camera,
  'aperture' => LucideIcons.aperture,
  'music' => LucideIcons.music,
  'pen-tool' => LucideIcons.penTool,
  'clapperboard' => LucideIcons.clapperboard,
  'shirt' => LucideIcons.shirt,
  'pen-line' => LucideIcons.penLine,
  'ticket' => LucideIcons.ticket,
  'palette' => LucideIcons.palette,
  _ => LucideIcons.tag,
};

AtTone toneOf(String tone) => switch (tone) {
  'violet' => AtTone.violet,
  'pink' => AtTone.coral,
  'orange' => AtTone.warning,
  'green' => AtTone.success,
  'blue' => AtTone.primary,
  'purple' => AtTone.indigo,
  'amber' => AtTone.amber,
  _ => AtTone.primary,
};

/// One listing as a card, with its save heart wired to the server.
class MarketplaceListingCard extends ConsumerWidget {
  const MarketplaceListingCard({super.key, required this.listing});

  final ListingCardDto listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final saved = ref.watch(listingSavesProvider)[listing.id] ?? listing.saved;
    return ListingCard(
      title: listing.title,
      sellerName: listing.seller.displayName,
      priceLabel: listing.fromLabel ?? listing.priceLabel,
      imageUrl: listing.coverUrl,
      rating: listing.ratingAverage?.toDouble(),
      categoryLabel: listing.categoryName,
      saved: saved,
      onSave: () async {
        final ok = await ref
            .read(listingSavesProvider.notifier)
            .toggle(listing.id, saved);
        if (!ok && context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.mkSaveFailed)));
        }
      },
      onTap: () => context.push(Routes.listingPath(listing.id)),
    );
  }
}

/// Two columns of listing cards, built from rows so they scroll inside a parent list.
class ListingGrid extends StatelessWidget {
  const ListingGrid({super.key, required this.items});

  final List<ListingCardDto> items;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: MarketplaceListingCard(listing: items[i])),
            const SizedBox(width: 12),
            Expanded(
              child: i + 1 < items.length
                  ? MarketplaceListingCard(listing: items[i + 1])
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
      rows.add(const SizedBox(height: 12));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AtSpacing.gutter),
      child: Column(children: rows),
    );
  }
}

/// A seller as a row: picture, name, headline and rating.
class SellerRow extends StatelessWidget {
  const SellerRow({super.key, required this.seller, required this.onTap});

  final SellerCardDto seller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AtCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      semanticLabel: seller.displayName,
      child: Row(
        children: [
          SellerAvatar(seller: seller, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        seller.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AtTextStyles.cardTitle.copyWith(
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AtTextStyles.meta.copyWith(color: context.at.muted),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (seller.ratingAverage != null) ...[
            Icon(LucideIcons.star, size: 14, color: context.at.star),
            const SizedBox(width: 3),
            Text(
              seller.ratingAverage!.toStringAsFixed(1),
              style: AtTextStyles.metaSm.copyWith(color: context.at.ink),
            ),
          ] else
            Text(
              l10n.mkNewSeller,
              style: AtTextStyles.metaSm.copyWith(color: context.at.muted),
            ),
        ],
      ),
    );
  }
}

class SellerAvatar extends StatelessWidget {
  const SellerAvatar({super.key, required this.seller, this.size = 48});

  final SellerCardDto seller;
  final double size;

  @override
  Widget build(BuildContext context) => AtAvatar(
    name: seller.displayName,
    size: size,
    image: seller.avatarUrl == null ? null : NetworkImage(seller.avatarUrl!),
  );
}

/// Stars for a rating, as text with one star: "4.5".
class RatingLabel extends StatelessWidget {
  const RatingLabel({super.key, required this.rating});

  final num rating;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(LucideIcons.star, size: 14, color: context.at.star),
      const SizedBox(width: 3),
      Text(
        rating.toStringAsFixed(1),
        style: AtTextStyles.metaSm.copyWith(color: context.at.ink),
      ),
    ],
  );
}

/// A tile-and-label header used by the marketplace screens.
class MkTopBar extends StatelessWidget {
  const MkTopBar({super.key, required this.title, this.actions = const []});

  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => AtTopBar(
    title: title,
    onBack: () => context.canPop() ? context.pop() : context.go(Routes.explore),
    actions: actions,
  );
}
