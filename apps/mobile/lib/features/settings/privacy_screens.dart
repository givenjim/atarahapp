import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart' hide Visibility;
import '../../core/api/generated/export.dart' as api show Visibility;
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../account/account_common.dart';
import '../account/account_providers.dart';
import '../discover/discover_common.dart';
import '../profile/profile_providers.dart' show openLinkProvider;

const _visibilities = [
  api.Visibility.public,
  api.Visibility.members,
  api.Visibility.private,
];

/// Privacy & visibility: one segmented control per part of the profile. A change applies at once, everywhere the
/// profile is shown (the server holds the setting; nothing is cached on the device), and goes back if it fails.
class PrivacyScreen extends ConsumerStatefulWidget {
  const PrivacyScreen({super.key});

  @override
  ConsumerState<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends ConsumerState<PrivacyScreen> {
  /// Choices made on this screen that the server has not confirmed yet.
  final Map<PrivacyField, api.Visibility> _pending = {};
  final Set<PrivacyField> _failed = {};

  String _label(AppLocalizations l10n, PrivacyField f, String fallback) =>
      switch (f) {
        PrivacyField.contact => l10n.stPrivContact,
        PrivacyField.location => l10n.stPrivLocation,
        PrivacyField.portfolio => l10n.stPrivPortfolio,
        PrivacyField.experience => l10n.stPrivExperience,
        PrivacyField.activity => l10n.stPrivActivity,
        _ => fallback,
      };

  Future<void> _set(PrivacyField f, api.Visibility v) async {
    setState(() {
      _pending[f] = v;
      _failed.remove(f);
    });
    try {
      await ref.read(accountRepositoryProvider).setPrivacy(f, v);
      ref.invalidate(privacyProvider);
      await ref.read(privacyProvider.future);
      if (mounted) setState(() => _pending.remove(f));
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _pending.remove(f);
        _failed.add(f);
      });
      showNotice(context, failureMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(privacyProvider);
    return SubPage(
      title: l10n.settingsPrivacy,
      child: async.when(
        skipLoadingOnReload: true,
        loading: () => const AtLoadingBody(),
        error: (e, _) =>
            loadFailure(e, () => ref.invalidate(privacyProvider), l10n),
        data: (p) => ListView(
          padding: const EdgeInsets.fromLTRB(
            AtSpacing.gutter,
            8,
            AtSpacing.gutter,
            32,
          ),
          children: [
            Text(
              l10n.stPrivacyIntro,
              style: AtTextStyles.bodySm.copyWith(color: context.at.body),
            ),
            const SizedBox(height: 14),
            for (final f in p.fields) ...[
              AtCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _label(l10n, f.field, f.label),
                      style: AtTextStyles.cardTitle.copyWith(
                        color: context.at.ink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AtSegmented(
                      labels: [
                        l10n.stVisPublic,
                        l10n.stVisMembers,
                        l10n.stVisPrivate,
                      ],
                      selectedIndex: _visibilities.indexOf(
                        _pending[f.field] ?? f.visibility,
                      ),
                      onChanged: (i) => _set(f.field, _visibilities[i]),
                    ),
                    if (_failed.contains(f.field))
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          l10n.stPrivNotSaved,
                          style: AtTextStyles.metaSm.copyWith(
                            color: context.at.coralStrong,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AtSpacing.listGap),
            ],
            GroupLabel(l10n.stYourData),
            const _ExportCard(),
          ],
        ),
      ),
    );
  }
}

/// Export my data: one request a day. Shows where the latest one stands and, when it is ready, the link.
class _ExportCard extends ConsumerStatefulWidget {
  const _ExportCard();

  @override
  ConsumerState<_ExportCard> createState() => _ExportCardState();
}

class _ExportCardState extends ConsumerState<_ExportCard> {
  bool _busy = false;

  Future<void> _request() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(accountRepositoryProvider).requestExport();
      ref.invalidate(exportStateProvider);
      if (mounted) showNotice(context, l10n.stExportRequested);
    } on Object catch (e) {
      if (mounted) showNotice(context, failureMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(exportStateProvider);
    return AtCard(
      child: async.when(
        loading: () => const AtSkeleton(height: 60, radius: 12),
        error: (e, _) => Text(
          failureMessage(e),
          style: AtTextStyles.bodySm.copyWith(color: context.at.coralStrong),
        ),
        data: (s) {
          final (status, tone) = switch (s.status) {
            ExportStateDtoStatus.queued || ExportStateDtoStatus.processing => (
              l10n.stExportPreparing,
              AtTone.warning,
            ),
            ExportStateDtoStatus.ready => (l10n.stExportReady, AtTone.success),
            ExportStateDtoStatus.failed => (l10n.stExportFailed, AtTone.coral),
            ExportStateDtoStatus.expired => (
              l10n.stExportExpired,
              AtTone.neutral,
            ),
            _ => (null, AtTone.neutral),
          };
          final wait =
              s.nextAllowedAt != null &&
              s.nextAllowedAt!.isAfter(DateTime.now());
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const AtIconTile(
                    icon: LucideIcons.download,
                    tone: AtTone.indigo,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.stExportTitle,
                      style: AtTextStyles.cardTitle.copyWith(
                        color: context.at.ink,
                      ),
                    ),
                  ),
                  if (status != null) AtStatusPill(label: status, tone: tone),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.stExportBody,
                style: AtTextStyles.bodySm.copyWith(color: context.at.body),
              ),
              const SizedBox(height: 12),
              if (s.status == ExportStateDtoStatus.ready &&
                  s.downloadUrl != null)
                AtButton(
                  label: l10n.stExportDownload,
                  icon: LucideIcons.download,
                  onPressed: () =>
                      ref.read(openLinkProvider)(Uri.parse(s.downloadUrl!)),
                )
              else
                AtButton(
                  label: l10n.stExportRequest,
                  variant: AtButtonVariant.secondary,
                  loading: _busy,
                  onPressed:
                      wait ||
                          _busy ||
                          s.status == ExportStateDtoStatus.queued ||
                          s.status == ExportStateDtoStatus.processing
                      ? null
                      : _request,
                ),
              if (wait)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    l10n.stExportNext(
                      shortDate(context, s.nextAllowedAt!.toLocal()),
                    ),
                    style: AtTextStyles.metaSm.copyWith(
                      color: context.at.muted,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ---- notification settings --------------------------------------------------------------------------------------

const _settingCats = [
  PreferenceDtoCategory.opportunities,
  PreferenceDtoCategory.community,
  PreferenceDtoCategory.learning,
  PreferenceDtoCategory.mentorship,
  PreferenceDtoCategory.profile,
  PreferenceDtoCategory.marketplace,
  PreferenceDtoCategory.system,
];

/// Notification settings: a category by push and email grid. Each switch saves as it is flipped. Security notices
/// are always sent, whatever is chosen here (the page says so).
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  List<PreferenceDto>? _local;

  (String, String) _name(AppLocalizations l10n, PreferenceDtoCategory c) =>
      switch (c) {
        PreferenceDtoCategory.opportunities => (
          l10n.ntCatOpportunities,
          l10n.stNotifOpportunitiesDesc,
        ),
        PreferenceDtoCategory.community => (
          l10n.ntCatCommunity,
          l10n.stNotifCommunityDesc,
        ),
        PreferenceDtoCategory.learning => (
          l10n.ntCatLearning,
          l10n.stNotifLearningDesc,
        ),
        PreferenceDtoCategory.mentorship => (
          l10n.ntCatMentorship,
          l10n.stNotifMentorshipDesc,
        ),
        PreferenceDtoCategory.profile => (
          l10n.ntCatProfile,
          l10n.stNotifProfileDesc,
        ),
        PreferenceDtoCategory.marketplace => (
          l10n.ntCatMarketplace,
          l10n.stNotifMarketplaceDesc,
        ),
        _ => (l10n.ntCatSystem, l10n.stNotifSystemDesc),
      };

  Future<void> _flip(PreferenceDto p, {bool? push, bool? email}) async {
    final before = _local!;
    final next = PreferenceDto(
      category: p.category,
      pushEnabled: push ?? p.pushEnabled,
      emailEnabled: email ?? p.emailEnabled,
    );
    setState(() {
      _local = [for (final x in before) x.category == p.category ? next : x];
    });
    try {
      await ref.read(notificationsRepositoryProvider).updatePreferences([next]);
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _local = before);
      showNotice(context, failureMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(notificationPreferencesProvider);
    return SubPage(
      title: l10n.settingsNotifications,
      child: async.when(
        skipLoadingOnReload: true,
        loading: () => const AtLoadingBody(),
        error: (e, _) => loadFailure(
          e,
          () => ref.invalidate(notificationPreferencesProvider),
          l10n,
        ),
        data: (loaded) {
          _local ??= loaded;
          final byCat = {for (final p in _local!) p.category: p};
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AtSpacing.gutter,
              8,
              AtSpacing.gutter,
              32,
            ),
            children: [
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
                              l10n.stNotifCategory,
                              style: AtTextStyles.label.copyWith(
                                color: context.at.muted,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 64,
                            child: Text(
                              l10n.stNotifPush,
                              style: AtTextStyles.label.copyWith(
                                color: context.at.muted,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 64,
                            child: Text(
                              l10n.stNotifEmail,
                              style: AtTextStyles.label.copyWith(
                                color: context.at.muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (final c in _settingCats)
                      if (byCat[c] case final p?)
                        _PrefRow(
                          name: _name(l10n, c).$1,
                          description: _name(l10n, c).$2,
                          preference: p,
                          onPush: (v) => _flip(p, push: v),
                          onEmail: (v) => _flip(p, email: v),
                        ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.stNotifSecurityNote,
                style: AtTextStyles.metaSm.copyWith(color: context.at.muted),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PrefRow extends StatelessWidget {
  const _PrefRow({
    required this.name,
    required this.description,
    required this.preference,
    required this.onPush,
    required this.onEmail,
  });

  final String name;
  final String description;
  final PreferenceDto preference;
  final ValueChanged<bool> onPush;
  final ValueChanged<bool> onEmail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.at.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AtTextStyles.cardTitle.copyWith(color: context.at.ink),
                ),
                Text(
                  description,
                  style: AtTextStyles.metaSm.copyWith(color: context.at.muted),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 64,
            child: Align(
              alignment: Alignment.centerLeft,
              child: AtToggle(
                value: preference.pushEnabled,
                onChanged: onPush,
                semanticLabel: l10n.stNotifPushFor(name),
              ),
            ),
          ),
          SizedBox(
            width: 64,
            child: Align(
              alignment: Alignment.centerLeft,
              child: AtToggle(
                value: preference.emailEnabled,
                onChanged: onEmail,
                semanticLabel: l10n.stNotifEmailFor(name),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
