import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/providers.dart';
import '../../core/routing/routes.dart';
import '../onboarding/onboarding_providers.dart';
import '../portfolio/creative_tabs.dart';
import 'profile_labels.dart';
import 'profile_providers.dart';
import 'profile_repository.dart';

/// A creative's profile as the caller is allowed to see it. The server filters every field by who is asking,
/// so this screen only draws what arrives and says which parts are hidden. The owner reaches it through
/// "Public view" and can flip between how the public and other members see it.
class CreativeProfileScreen extends ConsumerStatefulWidget {
  const CreativeProfileScreen({
    super.key,
    required this.handle,
    this.preview = false,
  });

  final String handle;

  /// The owner looking at their own profile as others see it.
  final bool preview;

  @override
  ConsumerState<CreativeProfileScreen> createState() =>
      _CreativeProfileScreenState();
}

class _CreativeProfileScreenState extends ConsumerState<CreativeProfileScreen> {
  int _tab = 0;
  PublicProfilePreview _as = PublicProfilePreview.public;
  bool _busy = false;
  String? _error;

  PublicProfilePreview? get _preview => widget.preview ? _as : null;

  void _refresh() => ref.invalidate(creativeProfileProvider);

  Future<void> _act(Future<ConnectionStateDto> Function() action) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      ref.read(analyticsProvider).track('connection_action');
      _refresh();
    } on AppFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on Object {
      if (mounted) setState(() => _error = l10n.cpActionFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmRemove(ConnectionStateDto c) async {
    final l10n = AppLocalizations.of(context);
    final yes = await showAtBottomSheet<bool>(
      context: context,
      title: l10n.cpRemoveConfirmTitle,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AtSpacing.gutter,
          4,
          AtSpacing.gutter,
          20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.cpRemoveConfirmBody,
              style: AtTextStyles.bodySm.copyWith(color: AtColors.body),
            ),
            const SizedBox(height: 16),
            AtButton(
              label: l10n.cpRemoveConnection,
              variant: AtButtonVariant.destructive,
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
            const SizedBox(height: 8),
            AtButton(
              label: l10n.obCropCancel,
              variant: AtButtonVariant.secondary,
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
          ],
        ),
      ),
    );
    if (yes == true && c.id != null) {
      await _act(
        () => ref.read(profileRepositoryProvider).removeConnection(c.id!),
      );
    }
  }

  Future<void> _share(PublicProfileDto p) async {
    final l10n = AppLocalizations.of(context);
    await ref.read(shareTextProvider)(
      '${l10n.cpShareText(p.displayName)}\n${p.shareUrl}',
    );
  }

  Future<void> _openLink(String url) async {
    final l10n = AppLocalizations.of(context);
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return;
    final choice = await showLeavingAtarahModal(
      context,
      domain: uri.host,
      showTrackOption: false,
    );
    if (choice?.continueToSite != true) return;
    final ok = await ref.read(openLinkProvider)(uri);
    if (!ok && mounted) setState(() => _error = l10n.leavingOpenFailed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(creativeProfileProvider(widget.handle, _preview));

    return Scaffold(
      body: AtPage(
        wash: AtWash.community,
        child: Column(
          children: [
            AtTopBar(
              onBack: () =>
                  context.canPop() ? context.pop() : context.go(Routes.home),
              actions: [
                if (async.hasValue)
                  AtIconButton(
                    icon: LucideIcons.share2,
                    semanticLabel: l10n.cpShare,
                    onPressed: () => _share(async.requireValue),
                  ),
              ],
            ),
            Expanded(
              child: async.when(
                loading: () => Semantics(
                  label: l10n.loading,
                  liveRegion: true,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AtSpacing.gutter),
                  child: AtErrorState(
                    title: e is ApiFailure && e.statusCode == 404
                        ? l10n.cpNotFoundTitle
                        : l10n.pfLoadFailed,
                    body: e is AppFailure
                        ? e.message
                        : const UnexpectedFailure().message,
                    ctaLabel: l10n.retry,
                    onCta: _refresh,
                  ),
                ),
                data: (p) => _body(context, p),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, PublicProfileDto p) {
    final l10n = AppLocalizations.of(context);
    final avatar = ref.watch(avatarImageProvider);
    final isOwnerView = widget.preview;
    final place = placeLine(p.location);
    final line = [
      p.discipline?.name,
      p.specialisations.firstOrNull?.name,
    ].whereType<String>().join(' · ');
    final url = p.avatarUrl;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AtSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cover: a brand gradient until members can upload their own (not in this phase).
          SizedBox(
            height: 150,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AtSpacing.gutter,
                    ),
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: AtGradients.cta,
                        borderRadius: AtRadii.panelLg,
                      ),
                      child: Semantics(
                        excludeSemantics: true,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: AtSpacing.gutter + 16,
                  bottom: -40,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AtColors.white, spreadRadius: 4),
                      ],
                    ),
                    child: AtAvatar(
                      name: p.displayName,
                      size: 96,
                      image: url == null ? null : avatar(url),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AtSpacing.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isOwnerView) ...[
                  AtInlineBanner(
                    message: l10n.cpPreviewBanner,
                    tone: AtBannerTone.info,
                  ),
                  const SizedBox(height: 10),
                  AtSegmented(
                    labels: [l10n.cpPreviewPublic, l10n.cpPreviewMembers],
                    selectedIndex: _as == PublicProfilePreview.public ? 0 : 1,
                    onChanged: (i) => setState(
                      () => _as = i == 0
                          ? PublicProfilePreview.public
                          : PublicProfilePreview.members,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // A verified tick appears next to the name only when a real verification exists (none yet).
                Semantics(
                  header: true,
                  child: Text(
                    p.displayName,
                    style: AtTextStyles.detailTitle.copyWith(
                      color: AtColors.ink,
                    ),
                  ),
                ),
                if (p.headline != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    p.headline!,
                    style: AtTextStyles.body.copyWith(color: AtColors.body),
                  ),
                ],
                if (line.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    line,
                    style: AtTextStyles.bodySm.copyWith(color: AtColors.muted),
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (place != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.mapPin,
                            size: 12,
                            color: AtColors.muted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            place,
                            style: AtTextStyles.meta.copyWith(
                              color: AtColors.muted,
                            ),
                          ),
                        ],
                      ),
                    if (p.openToCommissions)
                      AtTag(
                        label: l10n.cpOpenToCommissions,
                        tone: AtTone.success,
                        icon: LucideIcons.briefcase,
                      ),
                    if (p.connectionCount != null)
                      Text(
                        l10n.cpConnectionsCount(p.connectionCount!.round()),
                        style: AtTextStyles.meta.copyWith(
                          color: AtColors.muted,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_error != null) ...[
                  AtInlineBanner(message: _error!),
                  const SizedBox(height: 12),
                ],
                if (!isOwnerView &&
                    p.relation != PublicProfileDtoRelation.owner)
                  _Actions(
                    connection: p.connection,
                    busy: _busy,
                    onConnect: () => _act(
                      () =>
                          ref.read(profileRepositoryProvider).connect(p.handle),
                    ),
                    onAccept: (id) => _act(
                      () => ref.read(profileRepositoryProvider).accept(id),
                    ),
                    onDecline: (id) => _act(
                      () => ref.read(profileRepositoryProvider).decline(id),
                    ),
                    onCancel: (id) => _act(
                      () => ref
                          .read(profileRepositoryProvider)
                          .removeConnection(id),
                    ),
                    onRemove: _confirmRemove,
                    onMessage: () => context.push(
                      // Member-to-member messaging is not in scope (DEC-041).
                      Routes.soonPath('later', name: l10n.cpMessage),
                    ),
                  ),
                const SizedBox(height: 20),
                AtSegmented(
                  labels: [l10n.cpAbout, l10n.cpPortfolio, l10n.cpServices],
                  selectedIndex: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                ),
                const SizedBox(height: 18),
                switch (_tab) {
                  0 => _About(
                    profile: p,
                    preview: _preview,
                    onOpenLink: _openLink,
                  ),
                  1 => CreativePortfolioTab(profile: p, preview: _preview),
                  _ => CreativeServicesTab(profile: p, preview: _preview),
                },
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.connection,
    required this.busy,
    required this.onConnect,
    required this.onAccept,
    required this.onDecline,
    required this.onCancel,
    required this.onRemove,
    required this.onMessage,
  });

  final ConnectionStateDto? connection;
  final bool busy;
  final VoidCallback onConnect;
  final ValueChanged<String> onAccept;
  final ValueChanged<String> onDecline;
  final ValueChanged<String> onCancel;
  final ValueChanged<ConnectionStateDto> onRemove;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = connection;
    final message = AtButton(
      label: l10n.cpMessage,
      variant: AtButtonVariant.secondary,
      size: AtButtonSize.md,
      icon: LucideIcons.messageCircle,
      onPressed: onMessage,
    );

    if (c == null) return const SizedBox.shrink();

    switch (c.state) {
      case ConnectionStateDtoState.pendingReceived:
        return Row(
          children: [
            Expanded(
              child: AtButton(
                label: l10n.cpAccept,
                size: AtButtonSize.md,
                loading: busy,
                onPressed: busy || c.id == null ? null : () => onAccept(c.id!),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AtButton(
                label: l10n.cpDecline,
                variant: AtButtonVariant.secondary,
                size: AtButtonSize.md,
                onPressed: busy || c.id == null ? null : () => onDecline(c.id!),
              ),
            ),
          ],
        );
      case ConnectionStateDtoState.pendingSent:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: AtButton(
                    label: l10n.cpRequestSent,
                    variant: AtButtonVariant.secondary,
                    size: AtButtonSize.md,
                    icon: LucideIcons.clock,
                    onPressed: null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: message),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: AtButton(
                label: l10n.cpCancelRequest,
                variant: AtButtonVariant.tertiary,
                size: AtButtonSize.sm,
                fullWidth: false,
                onPressed: busy || c.id == null ? null : () => onCancel(c.id!),
              ),
            ),
          ],
        );
      case ConnectionStateDtoState.connected:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: AtButton(
                    label: l10n.cpConnected,
                    variant: AtButtonVariant.secondary,
                    size: AtButtonSize.md,
                    icon: LucideIcons.userCheck,
                    onPressed: null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: message),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: AtButton(
                label: l10n.cpRemoveConnection,
                variant: AtButtonVariant.tertiary,
                size: AtButtonSize.sm,
                fullWidth: false,
                onPressed: busy ? null : () => onRemove(c),
              ),
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: AtButton(
                    label: l10n.cpConnect,
                    size: AtButtonSize.md,
                    icon: LucideIcons.userPlus,
                    loading: busy,
                    onPressed: busy || !c.canConnect ? null : onConnect,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: message),
              ],
            ),
            if (!c.canConnect)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  c.reason == 'COOLDOWN'
                      ? l10n.cpAskLater
                      : l10n.cpNotAccepting,
                  style: AtTextStyles.meta.copyWith(color: AtColors.muted),
                ),
              ),
          ],
        );
    }
  }
}

class _About extends StatelessWidget {
  const _About({
    required this.profile,
    required this.preview,
    required this.onOpenLink,
  });

  final PublicProfileDto profile;
  final PublicProfilePreview? preview;
  final ValueChanged<String> onOpenLink;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = profile;
    Widget heading(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        header: true,
        child: Text(
          t,
          style: AtTextStyles.cardTitle.copyWith(color: AtColors.ink),
        ),
      ),
    );
    final hidden = [
      for (final s in p.lockedSections)
        if (s != PublicProfileDtoLockedSections.portfolio &&
            s != PublicProfileDtoLockedSections.services)
          s,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (p.bio != null)
          Text(
            p.bio!,
            style: AtTextStyles.body.copyWith(color: AtColors.longForm),
          )
        else if (p.visibleSections.contains(
          PublicProfileDtoVisibleSections.bio,
        ))
          Text(
            l10n.cpNoBio,
            style: AtTextStyles.bodySm.copyWith(color: AtColors.muted),
          ),
        if (p.specialisations.isNotEmpty) ...[
          const SizedBox(height: 20),
          heading(l10n.cpSpecialisationsHeading),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in p.specialisations)
                AtTag(label: s.name, tone: AtTone.primary),
            ],
          ),
        ],
        if (p.skills != null && p.skills!.isNotEmpty) ...[
          const SizedBox(height: 20),
          heading(l10n.cpSkillsHeading),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in p.skills!)
                AtTag(label: s.name, tone: AtTone.neutral),
            ],
          ),
        ],
        CreativeExperienceSection(profile: p, preview: preview),
        if (p.links != null && p.links!.isNotEmpty) ...[
          const SizedBox(height: 20),
          heading(l10n.cpLinksHeading),
          AtCard(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (final (i, l) in p.links!.indexed)
                  AtListRow(
                    title: l.label,
                    subtitle: Uri.tryParse(l.url)?.host,
                    icon: LucideIcons.externalLink,
                    showDivider: i < p.links!.length - 1,
                    onTap: () => onOpenLink(l.url),
                  ),
              ],
            ),
          ),
        ],
        if (p.contact != null &&
            (p.contact!.email != null || p.contact!.phone != null)) ...[
          const SizedBox(height: 20),
          heading(l10n.cpContactHeading),
          AtCard(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                if (p.contact!.email != null)
                  AtListRow(
                    title: p.contact!.email!,
                    icon: LucideIcons.mail,
                    showChevron: false,
                    showDivider: p.contact!.phone != null,
                  ),
                if (p.contact!.phone != null)
                  AtListRow(
                    title: p.contact!.phone!,
                    icon: LucideIcons.phone,
                    showChevron: false,
                  ),
              ],
            ),
          ),
        ],
        for (final s in hidden) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(LucideIcons.lock, size: 14, color: AtColors.muted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.cpHidden(publicSectionLabel(l10n, s)),
                  style: AtTextStyles.meta.copyWith(color: AtColors.muted),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 20),
        Text(
          l10n.cpMemberSince(
            DateFormat.yMMMM(Localizations.localeOf(context).toString())
                .format(p.memberSince.toLocal()),
          ),
          style: AtTextStyles.meta.copyWith(color: AtColors.muted),
        ),
      ],
    );
  }
}
