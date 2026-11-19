import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/routing/routes.dart';
import '../discover/discover_common.dart';
import '../profile/profile_providers.dart';
import 'marketplace_common.dart';
import 'marketplace_providers.dart';

/// `listing`: media carousel, save and share, category, title, "From KES x", seller card, what's included, the
/// delivery and location tiles, who it is for, portfolio examples, reviews, and a bottom bar with "Request booking".
/// There is no checkout, escrow or payment here: the note under the button says so.
class ListingScreen extends ConsumerStatefulWidget {
  const ListingScreen({super.key, required this.listingId});

  final String listingId;

  @override
  ConsumerState<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends ConsumerState<ListingScreen> {
  int _page = 0;

  void _back() =>
      context.canPop() ? context.pop() : context.go(Routes.marketplace);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = listingDetailProvider(widget.listingId);
    final async = ref.watch(provider);
    return Scaffold(
      backgroundColor: context.at.background,
      body: async.when(
        skipLoadingOnReload: true,
        loading: () => const AtLoadingBody(),
        error: (e, _) => SafeArea(
          child: Column(
            children: [
              AtTopBar(onBack: _back),
              Expanded(
                child: e is ApiFailure && e.statusCode == 404
                    ? AtEmptyState(
                        icon: LucideIcons.searchX,
                        title: l10n.mkNotAvailable,
                        body: l10n.mkNotAvailableBody,
                        ctaLabel: l10n.mkBackToMarket,
                        onCta: () => context.go(Routes.marketplace),
                      )
                    : loadFailure(e, () => ref.invalidate(provider), l10n),
              ),
            ],
          ),
        ),
        data: (l) => _content(context, l10n, l),
      ),
    );
  }

  Widget _content(BuildContext context, AppLocalizations l10n, ListingDto l) {
    final saved = ref.watch(listingSavesProvider)[l.id] ?? l.saved;
    final sent = l.openEnquiryId != null;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _Carousel(
                media: l.media,
                onPage: (i) => setState(() => _page = i),
                page: _page,
                top: Row(
                  children: [
                    AtIconButton(
                      icon: LucideIcons.chevronLeft,
                      semanticLabel: l10n.back,
                      onPressed: _back,
                    ),
                    const Spacer(),
                    AtIconButton(
                      icon: LucideIcons.share2,
                      semanticLabel: l10n.mkShare,
                      onPressed: () => ref.read(shareTextProvider)(
                        '${l.title}\n${l.shareUrl}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!l.isOwner)
                      AtIconButton(
                        icon: saved
                            ? LucideIcons.bookmarkCheck
                            : LucideIcons.bookmark,
                        semanticLabel: saved
                            ? l10n.mkUnsaveListing
                            : l10n.mkSaveListing,
                        onPressed: () async {
                          final ok = await ref
                              .read(listingSavesProvider.notifier)
                              .toggle(l.id, saved);
                          if (!ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.mkSaveFailed)),
                            );
                          }
                        },
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AtSpacing.gutter,
                  16,
                  AtSpacing.gutter,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      children: [
                        AtTag(label: l.categoryName, tone: AtTone.primary),
                        if (l.status != ListingStatus.published)
                          AtTag(
                            label: listingStatusLook(l10n, l.status).label,
                            tone: listingStatusLook(l10n, l.status).tone,
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Semantics(
                      header: true,
                      child: Text(
                        l.title,
                        style: AtTextStyles.detailTitle.copyWith(
                          color: context.at.ink,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l.fromLabel ?? l.priceLabel,
                      style: AtTextStyles.sectionTitle.copyWith(
                        color: context.at.primary,
                      ),
                    ),
                    if (l.ratingAverage != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          RatingLabel(rating: l.ratingAverage!),
                          const SizedBox(width: 6),
                          Text(
                            l10n.mkReviewCount(l.ratingCount.toInt()),
                            style: AtTextStyles.meta.copyWith(
                              color: context.at.muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (l.status == ListingStatus.rejected &&
                        l.rejectionReason != null) ...[
                      const SizedBox(height: 12),
                      AtInlineBanner(
                        message: l10n.mkReasonLine(l.rejectionReason!),
                        tone: AtBannerTone.error,
                      ),
                    ],
                    const SizedBox(height: 16),
                    SellerRow(
                      seller: l.seller,
                      onTap: () => context.push(Routes.sellerPath(l.seller.id)),
                    ),
                    if (l.description.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        l.description,
                        style: AtTextStyles.body.copyWith(
                          color: context.at.body,
                        ),
                      ),
                    ],
                    if (l.includedItems.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _Heading(l10n.mkWhatsIncluded),
                      for (final item in l.includedItems)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                LucideIcons.check,
                                size: 18,
                                color: context.at.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item,
                                  style: AtTextStyles.body.copyWith(
                                    color: context.at.ink,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (l.deliveryDays != null)
                          Expanded(
                            child: _Tile(
                              icon: LucideIcons.clock,
                              label: l10n.mkDelivery,
                              value: l10n.mkDeliveryDays(
                                l.deliveryDays!.toInt(),
                              ),
                            ),
                          ),
                        if (l.deliveryDays != null) const SizedBox(width: 12),
                        Expanded(
                          child: _Tile(
                            icon: LucideIcons.mapPin,
                            label: l10n.mkLocation,
                            value: l.locationLabel,
                          ),
                        ),
                      ],
                    ),
                    if (l.audienceText != null) ...[
                      const SizedBox(height: 20),
                      _Heading(l10n.mkWhoFor),
                      Text(
                        l.audienceText!,
                        style: AtTextStyles.body.copyWith(
                          color: context.at.body,
                        ),
                      ),
                    ],
                    if (l.portfolio.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _Heading(l10n.mkPortfolioExamples),
                      SizedBox(
                        height: 150,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: l.portfolio.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (_, i) {
                            final p = l.portfolio[i];
                            return SizedBox(
                              width: 180,
                              child: AtCard(
                                padding: EdgeInsets.zero,
                                onTap: () => context.push('/projects/${p.id}'),
                                semanticLabel: p.title,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(18),
                                      ),
                                      child: AspectRatio(
                                        aspectRatio: 1.6,
                                        child: p.coverUrl == null
                                            ? ColoredBox(
                                                color: context.at.softTile,
                                              )
                                            : Image.network(
                                                p.coverUrl!,
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        p.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AtTextStyles.chip.copyWith(
                                          color: context.at.ink,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    _Heading(l10n.mkReviews),
                    if (l.reviews.isEmpty)
                      Text(
                        l10n.mkNoReviews,
                        style: AtTextStyles.body.copyWith(
                          color: context.at.muted,
                        ),
                      )
                    else
                      for (final r in l.reviews) _Review(review: r),
                    if (!l.isOwner) ...[
                      const SizedBox(height: 16),
                      AtButton(
                        label: l10n.mkReport,
                        variant: AtButtonVariant.tertiary,
                        icon: LucideIcons.flag,
                        onPressed: () => _report(context, l),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        _BottomBar(
          listing: l,
          sent: sent,
          onRequest: () => _request(context, l),
          onOpen: () => context.push(Routes.enquiryPath(l.openEnquiryId!)),
          onEdit: () => context.push(Routes.listingEditPath(l.id)),
        ),
      ],
    );
  }

  Future<void> _request(BuildContext context, ListingDto l) async {
    final sentId = await showAtBottomSheet<String>(
      context: context,
      title: AppLocalizations.of(context).mkRequestTitle,
      builder: (_) => _RequestSheet(listing: l),
    );
    if (sentId != null) ref.invalidate(listingDetailProvider(l.id));
  }

  Future<void> _report(BuildContext context, ListingDto l) async {
    final l10n = AppLocalizations.of(context);
    final done = await showAtBottomSheet<bool>(
      context: context,
      title: l10n.mkReportTitle,
      builder: (_) => _ReportSheet(listingId: l.id),
    );
    if (done == true && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.mkReportThanks)));
    }
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Semantics(
      header: true,
      child: Text(
        text,
        style: AtTextStyles.sectionTitleSm.copyWith(color: context.at.ink),
      ),
    ),
  );
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => AtCard(
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: context.at.primary),
        const SizedBox(height: 8),
        Text(
          label,
          style: AtTextStyles.metaSm.copyWith(color: context.at.muted),
        ),
        Text(
          value,
          style: AtTextStyles.cardTitle.copyWith(color: context.at.ink),
        ),
      ],
    ),
  );
}

class _Review extends StatelessWidget {
  const _Review({required this.review});

  final ListingReviewDto review;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AtAvatar(
          name: review.reviewerName,
          size: 36,
          image: review.reviewerAvatarUrl == null
              ? null
              : NetworkImage(review.reviewerAvatarUrl!),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      review.reviewerName,
                      overflow: TextOverflow.ellipsis,
                      style: AtTextStyles.chip.copyWith(color: context.at.ink),
                    ),
                  ),
                  const SizedBox(width: 8),
                  RatingLabel(rating: review.rating),
                ],
              ),
              if (review.body != null)
                Text(
                  review.body!,
                  style: AtTextStyles.bodySm.copyWith(color: context.at.body),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Carousel extends StatelessWidget {
  const _Carousel({
    required this.media,
    required this.page,
    required this.onPage,
    required this.top,
  });

  final List<ListingMediaDto> media;
  final int page;
  final ValueChanged<int> onPage;
  final Widget top;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1.25,
          child: media.isEmpty
              ? ColoredBox(
                  color: context.at.softTile,
                  child: Center(
                    child: Icon(LucideIcons.image, color: context.at.faint),
                  ),
                )
              : PageView.builder(
                  itemCount: media.length,
                  onPageChanged: onPage,
                  itemBuilder: (_, i) => media[i].url == null
                      ? ColoredBox(color: context.at.softTile)
                      : Image.network(media[i].url!, fit: BoxFit.cover),
                ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AtSpacing.topBarH,
                vertical: AtSpacing.topBarV,
              ),
              child: top,
            ),
          ),
        ),
        if (media.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < media.length; i++)
                  Container(
                    width: i == page ? 18 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i == page ? context.at.white : context.at.faint,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.listing,
    required this.sent,
    required this.onRequest,
    required this.onOpen,
    required this.onEdit,
  });

  final ListingDto listing;
  final bool sent;
  final VoidCallback onRequest;
  final VoidCallback onOpen;
  final VoidCallback onEdit;

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (listing.isOwner)
                AtButton(label: l10n.mkEditListing, onPressed: onEdit)
              else if (listing.status != ListingStatus.published)
                const SizedBox.shrink()
              else
                Row(
                  children: [
                    if (sent) ...[
                      AtIconButton(
                        icon: LucideIcons.messageSquare,
                        semanticLabel: l10n.mkMessageSeller,
                        onPressed: onOpen,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: AtButton(
                        label: sent
                            ? l10n.mkRequestSent
                            : l10n.mkRequestBooking,
                        variant: sent
                            ? AtButtonVariant.secondary
                            : AtButtonVariant.primary,
                        onPressed: sent ? onOpen : onRequest,
                      ),
                    ),
                  ],
                ),
              if (!listing.isOwner &&
                  listing.status == ListingStatus.published) ...[
                const SizedBox(height: 8),
                Text(
                  listing.requestNote,
                  textAlign: TextAlign.center,
                  style: AtTextStyles.meta.copyWith(color: context.at.muted),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestSheet extends ConsumerStatefulWidget {
  const _RequestSheet({required this.listing});

  final ListingDto listing;

  @override
  ConsumerState<_RequestSheet> createState() => _RequestSheetState();
}

class _RequestSheetState extends ConsumerState<_RequestSheet> {
  final _message = TextEditingController();
  final _budget = TextEditingController();
  final _timing = TextEditingController();
  bool _busy = false;
  String? _messageError;
  String? _banner;

  @override
  void dispose() {
    _message.dispose();
    _budget.dispose();
    _timing.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context);
    if (_message.text.trim().length < 10) {
      setState(() => _messageError = l10n.mkRequestError);
      return;
    }
    setState(() {
      _busy = true;
      _messageError = null;
      _banner = null;
    });
    try {
      final thread = await ref
          .read(marketplaceRepositoryProvider)
          .requestBooking(
            widget.listing.id,
            message: _message.text.trim(),
            budget: int.tryParse(_budget.text.trim()),
            timing: _timing.text.trim().isEmpty ? null : _timing.text.trim(),
          );
      if (mounted) Navigator.of(context).pop(thread.id);
    } on ApiFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _messageError = e.fieldError('message');
        _banner = _messageError == null ? e.message : null;
      });
    } on AppFailure catch (e) {
      if (mounted) setState(() => _banner = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_banner != null) ...[
          AtInlineBanner(message: _banner!, tone: AtBannerTone.error),
          const SizedBox(height: 12),
        ],
        AtTextField(
          label: l10n.mkRequestNeed,
          hint: l10n.mkRequestNeedHint,
          controller: _message,
          minLines: 3,
          maxLines: 6,
          maxLength: 2000,
          errorText: _messageError,
        ),
        const SizedBox(height: 12),
        AtTextField(
          label: l10n.mkRequestBudget,
          prefixText: 'KES ',
          controller: _budget,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 9,
        ),
        const SizedBox(height: 12),
        AtTextField(
          label: l10n.mkRequestTiming,
          controller: _timing,
          maxLength: 120,
        ),
        const SizedBox(height: 8),
        Text(
          widget.listing.requestNote,
          style: AtTextStyles.meta.copyWith(color: context.at.muted),
        ),
        const SizedBox(height: 16),
        AtButton(label: l10n.mkRequestSend, loading: _busy, onPressed: _send),
      ],
    );
  }
}

class _ReportSheet extends ConsumerStatefulWidget {
  const _ReportSheet({required this.listingId});

  final String listingId;

  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  ReportReason? _reason;
  final _note = TextEditingController();
  bool _busy = false;
  String? _banner;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  String _label(AppLocalizations l10n, ReportReason r) => switch (r) {
    ReportReason.inappropriate => l10n.mkReasonInappropriate,
    ReportReason.harassment => l10n.mkReasonHarassment,
    ReportReason.scam => l10n.mkReasonScam,
    ReportReason.misleading => l10n.mkReasonMisleading,
    ReportReason.impersonation => l10n.mkReasonImpersonation,
    ReportReason.ipInfringement => l10n.mkReasonIp,
    _ => l10n.mkReasonOther,
  };

  Future<void> _send() async {
    final reason = _reason;
    if (reason == null) return;
    setState(() {
      _busy = true;
      _banner = null;
    });
    try {
      await ref
          .read(marketplaceRepositoryProvider)
          .report(
            widget.listingId,
            reason,
            _note.text.trim().isEmpty ? null : _note.text.trim(),
          );
      if (mounted) Navigator.of(context).pop(true);
    } on AppFailure catch (e) {
      if (mounted) setState(() => _banner = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_banner != null) ...[
          AtInlineBanner(message: _banner!, tone: AtBannerTone.error),
          const SizedBox(height: 12),
        ],
        for (final r in ReportReason.values.where(
          (r) => r != ReportReason.$unknown,
        ))
          AtRadioCard(
            title: _label(l10n, r),
            selected: _reason == r,
            onTap: () => setState(() => _reason = r),
          ),
        const SizedBox(height: 8),
        AtTextField(
          label: l10n.mkReportNote,
          controller: _note,
          minLines: 2,
          maxLines: 4,
          maxLength: 500,
        ),
        const SizedBox(height: 16),
        AtButton(
          label: l10n.mkReportSend,
          loading: _busy,
          onPressed: _reason == null ? null : _send,
        ),
      ],
    );
  }
}
