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
import 'marketplace_providers.dart';

String enquiryStatusLabel(AppLocalizations l10n, EnquiryStatus s) =>
    switch (s) {
      EnquiryStatus.valueNew => l10n.mkStatusNew,
      EnquiryStatus.replied => l10n.mkStatusReplied,
      EnquiryStatus.closed => l10n.mkStatusClosed,
      _ => s.name,
    };

/// One request in a list: the listing, the other person, the state and whether there is something new.
class EnquiryRow extends StatelessWidget {
  const EnquiryRow({super.key, required this.enquiry});

  final EnquiryDto enquiry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AtCard(
      onTap: () => context.push(Routes.enquiryPath(enquiry.id)),
      padding: const EdgeInsets.all(14),
      semanticLabel:
          '${enquiry.counterpart.displayName}, ${enquiry.listingTitle}',
      child: Row(
        children: [
          AtAvatar(
            name: enquiry.counterpart.displayName,
            size: 44,
            image: enquiry.counterpart.avatarUrl == null
                ? null
                : NetworkImage(enquiry.counterpart.avatarUrl!),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  enquiry.counterpart.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AtTextStyles.cardTitle.copyWith(color: context.at.ink),
                ),
                Text(
                  enquiry.listingTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AtTextStyles.meta.copyWith(color: context.at.muted),
                ),
                const SizedBox(height: 4),
                Text(
                  enquiry.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AtTextStyles.bodySm.copyWith(color: context.at.body),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (enquiry.role == EnquiryDtoRole.seller &&
                  enquiry.status == EnquiryStatus.valueNew)
                AtTag(label: l10n.mkReply, tone: AtTone.primary, solid: true)
              else if (enquiry.unread)
                AtTag(label: l10n.mkUnread, tone: AtTone.primary, solid: true),
              const SizedBox(height: 4),
              AtStatusPill(
                label: enquiryStatusLabel(l10n, enquiry.status),
                tone: switch (enquiry.status) {
                  EnquiryStatus.closed => AtTone.neutral,
                  EnquiryStatus.replied => AtTone.success,
                  _ => AtTone.warning,
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The member's requests: ones they sent and, for sellers, ones on their listings.
class EnquiriesScreen extends ConsumerStatefulWidget {
  const EnquiriesScreen({super.key, this.initialReceived = false});

  final bool initialReceived;

  @override
  ConsumerState<EnquiriesScreen> createState() => _EnquiriesScreenState();
}

class _EnquiriesScreenState extends ConsumerState<EnquiriesScreen> {
  late int _tab = widget.initialReceived ? 1 : 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final side = _tab == 0 ? AsEnum.buyer : AsEnum.seller;
    final async = ref.watch(enquiriesProvider(side));
    return Scaffold(
      backgroundColor: context.at.background,
      body: AtPage(
        child: Column(
          children: [
            AtTopBar(
              title: l10n.mkRequestsTitle,
              onBack: () => context.canPop()
                  ? context.pop()
                  : context.go(Routes.marketplace),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AtSpacing.gutter),
              child: AtSegmented(
                labels: [l10n.mkTabSent, l10n.mkTabReceived],
                selectedIndex: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: async.when(
                skipLoadingOnReload: true,
                loading: () => const AtLoadingBody(),
                error: (e, _) => loadFailure(
                  e,
                  () => ref.invalidate(enquiriesProvider(side)),
                  l10n,
                ),
                data: (page) => page.items.isEmpty
                    ? AtEmptyState(
                        icon: LucideIcons.messagesSquare,
                        title: l10n.mkRequestsEmpty,
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(enquiriesProvider(side));
                          await ref.read(enquiriesProvider(side).future);
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AtSpacing.gutter,
                            0,
                            AtSpacing.gutter,
                            32,
                          ),
                          itemCount: page.items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) =>
                              EnquiryRow(enquiry: page.items[i]),
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

/// A request and its thread: the listing, what was asked, the messages, a reply box, "Mark as done" and, for the
/// person who asked, a review once it is closed. Only the two people involved can open it.
class EnquiryScreen extends ConsumerStatefulWidget {
  const EnquiryScreen({super.key, required this.enquiryId});

  final String enquiryId;

  @override
  ConsumerState<EnquiryScreen> createState() => _EnquiryScreenState();
}

class _EnquiryScreenState extends ConsumerState<EnquiryScreen> {
  final _text = TextEditingController();
  bool _busy = false;
  String? _banner;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _refreshLists() {
    ref.invalidate(enquiriesProvider);
    ref.invalidate(myListingsProvider);
    ref.invalidate(enquiryThreadProvider(widget.enquiryId));
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _banner = null;
    });
    try {
      await action();
      _refreshLists();
    } on AppFailure catch (e) {
      if (mounted) setState(() => _banner = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _send() async {
    final body = _text.text.trim();
    if (body.isEmpty) return;
    await _run(() async {
      await ref
          .read(marketplaceRepositoryProvider)
          .send(widget.enquiryId, body);
      _text.clear();
    });
  }

  Future<void> _close() async {
    final l10n = AppLocalizations.of(context);
    final ok = await confirmSheet(
      context,
      title: l10n.mkCloseTitle,
      body: l10n.mkCloseBody,
      actionLabel: l10n.mkClose,
    );
    if (!ok || !mounted) return;
    await _run(
      () => ref.read(marketplaceRepositoryProvider).close(widget.enquiryId),
    );
  }

  Future<void> _review() async {
    final l10n = AppLocalizations.of(context);
    final done = await showAtBottomSheet<bool>(
      context: context,
      title: l10n.mkReviewTitle,
      builder: (_) => _ReviewSheet(enquiryId: widget.enquiryId),
    );
    if (done == true) _refreshLists();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = enquiryThreadProvider(widget.enquiryId);
    final async = ref.watch(provider);
    return Scaffold(
      backgroundColor: context.at.background,
      body: AtPage(
        child: Column(
          children: [
            AtTopBar(
              title: l10n.mkThreadTitle,
              onBack: () => context.canPop()
                  ? context.pop()
                  : context.go(Routes.enquiries),
            ),
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
                data: (t) => _thread(context, l10n, t),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thread(
    BuildContext context,
    AppLocalizations l10n,
    EnquiryThreadDto t,
  ) {
    final closed = t.status == EnquiryStatus.closed;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AtSpacing.gutter,
              0,
              AtSpacing.gutter,
              16,
            ),
            children: [
              AtCard(
                onTap: () => context.push(Routes.listingPath(t.listingId)),
                padding: const EdgeInsets.all(14),
                semanticLabel: t.listingTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.listingTitle,
                            style: AtTextStyles.cardTitle.copyWith(
                              color: context.at.ink,
                            ),
                          ),
                        ),
                        AtStatusPill(
                          label: enquiryStatusLabel(l10n, t.status),
                          tone: closed
                              ? AtTone.neutral
                              : t.status == EnquiryStatus.replied
                              ? AtTone.success
                              : AtTone.warning,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.counterpart.displayName,
                      style: AtTextStyles.meta.copyWith(
                        color: context.at.muted,
                      ),
                    ),
                    if (t.budget != null)
                      Text(
                        l10n.mkBudgetLine(t.budget!.toInt().toString()),
                        style: AtTextStyles.meta.copyWith(
                          color: context.at.body,
                        ),
                      ),
                    if (t.preferredTiming != null)
                      Text(
                        l10n.mkTimingLine(t.preferredTiming!),
                        style: AtTextStyles.meta.copyWith(
                          color: context.at.body,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_banner != null) ...[
                AtInlineBanner(message: _banner!, tone: AtBannerTone.error),
                const SizedBox(height: 12),
              ],
              for (final m in t.messages) _Bubble(message: m),
              if (t.canClose && !closed)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: AtButton(
                    label: l10n.mkClose,
                    variant: AtButtonVariant.secondary,
                    onPressed: _busy ? null : _close,
                  ),
                ),
              if (t.canReview)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: AtButton(
                    label: l10n.mkLeaveReview,
                    icon: LucideIcons.star,
                    onPressed: _review,
                  ),
                ),
              if (t.reviewed)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    l10n.mkReviewed,
                    textAlign: TextAlign.center,
                    style: AtTextStyles.meta.copyWith(color: context.at.muted),
                  ),
                ),
            ],
          ),
        ),
        if (!closed)
          DecoratedBox(
            decoration: BoxDecoration(
              color: context.at.surface,
              border: Border(top: BorderSide(color: context.at.cardBorder)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AtSpacing.gutter,
                  10,
                  AtSpacing.gutter,
                  10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: AtTextField(
                        label: l10n.mkMessageHint,
                        controller: _text,
                        minLines: 1,
                        maxLines: 4,
                        maxLength: 2000,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AtIconButton(
                      icon: LucideIcons.send,
                      semanticLabel: l10n.mkSend,
                      onPressed: _busy ? null : _send,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final EnquiryMessageDto message;

  @override
  Widget build(BuildContext context) {
    final mine = message.fromMe;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        decoration: BoxDecoration(
          color: mine ? context.at.primaryFill : context.at.surface,
          borderRadius: BorderRadius.circular(16),
          border: mine ? null : Border.all(color: context.at.cardBorder),
        ),
        child: Text(
          message.body,
          style: AtTextStyles.body.copyWith(
            color: mine ? context.at.white : context.at.ink,
          ),
        ),
      ),
    );
  }
}

class _ReviewSheet extends ConsumerStatefulWidget {
  const _ReviewSheet({required this.enquiryId});

  final String enquiryId;

  @override
  ConsumerState<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends ConsumerState<_ReviewSheet> {
  int _rating = 0;
  final _body = TextEditingController();
  bool _busy = false;
  String? _banner;

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() {
      _busy = true;
      _banner = null;
    });
    try {
      await ref
          .read(marketplaceRepositoryProvider)
          .review(
            widget.enquiryId,
            _rating,
            _body.text.trim().isEmpty ? null : _body.text.trim(),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 1; i <= 5; i++)
              AtTapTarget(
                semanticLabel: '$i',
                onTap: () => setState(() => _rating = i),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    LucideIcons.star,
                    size: 32,
                    color: i <= _rating ? context.at.star : context.at.faint,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        AtTextField(
          label: l10n.mkReviewHint,
          controller: _body,
          minLines: 2,
          maxLines: 4,
          maxLength: 1000,
        ),
        const SizedBox(height: 16),
        AtButton(
          label: l10n.mkReviewSend,
          loading: _busy,
          onPressed: _rating == 0 ? null : _send,
        ),
      ],
    );
  }
}
