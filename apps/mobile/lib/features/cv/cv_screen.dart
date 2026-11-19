import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/routing/routes.dart';
import '../onboarding/onboarding_providers.dart';
import '../onboarding/pick_sheet.dart';
import '../profile/profile_providers.dart';
import 'cv_providers.dart';
import 'cv_repository.dart';

/// Section keys as the API writes them.
const _sectionOrder = [
  'BIO',
  'LOCATION',
  'PORTFOLIO',
  'SKILLS',
  'EXPERIENCE',
  'SERVICES',
  'LINKS',
  'CONTACT',
];

String _sectionLabel(AppLocalizations l10n, String key) => switch (key) {
  'BIO' => l10n.secBio,
  'LOCATION' => l10n.secLocation,
  'PORTFOLIO' => l10n.secPortfolio,
  'SKILLS' => l10n.secSkills,
  'EXPERIENCE' => l10n.secExperience,
  'SERVICES' => l10n.secServices,
  'LINKS' => l10n.secLinks,
  'CONTACT' => l10n.secContact,
  _ => key,
};

String _audienceLabel(AppLocalizations l10n, String key) => switch (key) {
  'PUBLIC' => l10n.vsPublic,
  'MEMBERS' => l10n.vsMembers,
  _ => l10n.vsPrivate,
};

String _formatLabel(AppLocalizations l10n, String key) => switch (key) {
  'CV' => l10n.cvFormatCv,
  'BIO' => l10n.cvFormatBio,
  'EPK' => l10n.cvFormatEpk,
  _ => l10n.cvFormatDeck,
};

/// Create your Creative CV, Artist biography, Electronic press kit or Portfolio presentation: pick what goes in, see
/// exactly what the output will contain, download a PDF and share a revocable link.
class CvScreen extends ConsumerStatefulWidget {
  const CvScreen({super.key});

  @override
  ConsumerState<CvScreen> createState() => _CvScreenState();
}

class _CvScreenState extends ConsumerState<CvScreen> {
  int _index = 0;
  bool _saving = false;
  bool _preparing = false;
  bool _sharing = false;
  String? _notice;
  String? _error;

  String get _format => cvFormats[_index];

  void _clear() {
    _notice = null;
    _error = null;
  }

  Future<void> _guarded(Future<void> Function() body, String fallback) async {
    try {
      await body();
    } on AppFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on Object {
      if (mounted) setState(() => _error = fallback);
    }
  }

  /// Saves one change to the choices. The screen keeps the server's answer, which carries the refreshed preview.
  Future<void> _save(
    CvStateDto s, {
    Set<String>? sections,
    Set<String>? restricted,
    List<String>? projectIds,
  }) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _clear();
      _saving = true;
    });
    await _guarded(() async {
      await ref
          .read(cvDocProvider(_format).notifier)
          .save(
            UpdateCvDto(
              sections: [
                for (final k
                    in sections ??
                        s.config.sections.map((e) => e.json!).toSet())
                  UpdateCvDtoSections.fromJson(k),
              ],
              restricted: [
                for (final k
                    in restricted ??
                        s.config.restricted.map((e) => e.json!).toSet())
                  UpdateCvDtoRestricted.fromJson(k),
              ],
              projectIds: projectIds ?? s.config.projectIds,
            ),
          );
    }, l10n.cvSaveFailed);
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _download() async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(cvRepositoryProvider);
    final interval = ref.read(cvPollIntervalProvider);
    setState(() {
      _clear();
      _preparing = true;
    });
    await _guarded(() async {
      var render = await repo.generate(_format);
      for (var i = 0; i < 60; i++) {
        if (render.status == CvRenderDtoStatus.ready ||
            render.status == CvRenderDtoStatus.failed) {
          break;
        }
        await Future<void>.delayed(interval);
        if (!mounted) return;
        render = await repo.renderStatus(render.id);
      }
      if (render.status != CvRenderDtoStatus.ready) {
        if (mounted) setState(() => _error = render.error ?? l10n.cvPdfFailed);
        return;
      }
      final link = await repo.download(render.id);
      final opened = await ref.read(openLinkProvider)(Uri.parse(link.url));
      if (!opened && mounted) setState(() => _error = l10n.cvPdfOpenFailed);
      await ref.read(cvDocProvider(_format).notifier).reload();
    }, l10n.cvPdfFailed);
    if (mounted) setState(() => _preparing = false);
  }

  Future<void> _share(CvStateDto s) async {
    final l10n = AppLocalizations.of(context);
    final picked = await showPickSheet(
      context,
      title: l10n.cvChooseExpiry,
      options: [
        PickOption('0', l10n.cvExpiryNever),
        for (final d in const [7, 30, 90])
          PickOption('$d', l10n.cvExpiryDays(d)),
      ],
    );
    if (picked == null || !mounted) return;
    final days = int.parse(picked);
    setState(() {
      _clear();
      _sharing = true;
    });
    await _guarded(() async {
      final link = await ref
          .read(cvRepositoryProvider)
          .createShare(_format, expiresInDays: days == 0 ? null : days);
      await Clipboard.setData(ClipboardData(text: link.url));
      if (!mounted) return;
      setState(() => _notice = l10n.cvLinkCreated);
      await ref.read(cvDocProvider(_format).notifier).reload();
      await ref.read(shareTextProvider)(
        '${l10n.cvShareText(s.preview.displayName, s.info.label)}\n${link.url}',
      );
    }, l10n.cvSaveFailed);
    if (mounted) setState(() => _sharing = false);
  }

  Future<void> _revoke(CvShareDto link) async {
    final l10n = AppLocalizations.of(context);
    setState(_clear);
    await _guarded(() async {
      await ref.read(cvRepositoryProvider).revokeShare(link.id);
      await ref.read(cvDocProvider(_format).notifier).reload();
      if (mounted) setState(() => _notice = l10n.cvRevoked);
    }, l10n.cvSaveFailed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final doc = ref.watch(cvDocProvider(_format));
    return Scaffold(
      body: AtPage(
        wash: AtWash.settings,
        child: Column(
          children: [
            AtTopBar(
              title: l10n.cvTitle,
              onBack: () =>
                  context.canPop() ? context.pop() : context.go(Routes.profile),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AtSpacing.gutter,
                  4,
                  AtSpacing.gutter,
                  AtSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AtSegmented(
                      labels: [
                        for (final f in cvFormats) _formatLabel(l10n, f),
                      ],
                      selectedIndex: _index,
                      onChanged: (i) => setState(() {
                        _index = i;
                        _clear();
                      }),
                    ),
                    const SizedBox(height: 16),
                    if (_notice != null) ...[
                      AtInlineBanner(
                        message: _notice!,
                        tone: AtBannerTone.success,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_error != null) ...[
                      AtInlineBanner(message: _error!),
                      const SizedBox(height: 12),
                    ],
                    doc.when(
                      // A skeleton list scrolls by itself, so it needs a fixed height inside this scroll view.
                      loading: () =>
                          const SizedBox(height: 420, child: AtLoadingBody()),
                      error: (e, _) => AtErrorState(
                        title: l10n.cvLoadFailed,
                        body: e is AppFailure
                            ? e.message
                            : const UnexpectedFailure().message,
                        ctaLabel: l10n.retry,
                        onCta: () => ref.invalidate(cvDocProvider(_format)),
                      ),
                      data: (s) => _Body(
                        state: s,
                        format: _format,
                        saving: _saving,
                        preparing: _preparing,
                        sharing: _sharing,
                        onSave: (sections, restricted, projects) => _save(
                          s,
                          sections: sections,
                          restricted: restricted,
                          projectIds: projects,
                        ),
                        onDownload: _download,
                        onShare: () => _share(s),
                        onRevoke: _revoke,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// [set] with [key] switched on or off.
Set<String> _with(Set<String> set, String key, bool on) =>
    on ? {...set, key} : ({...set}..remove(key));

typedef _SaveChoices = void Function(
  Set<String>? sections,
  Set<String>? restricted,
  List<String>? projects,
);

class _Body extends ConsumerWidget {
  const _Body({
    required this.state,
    required this.format,
    required this.saving,
    required this.preparing,
    required this.sharing,
    required this.onSave,
    required this.onDownload,
    required this.onShare,
    required this.onRevoke,
  });

  final CvStateDto state;
  final String format;
  final bool saving;
  final bool preparing;
  final bool sharing;
  final _SaveChoices onSave;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final void Function(CvShareDto) onRevoke;

  Set<String> get _sections =>
      state.config.sections.map((e) => e.json!).toSet();
  Set<String> get _restricted =>
      state.config.restricted.map((e) => e.json!).toSet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final info = state.info;
    final audience = {for (final a in state.sections) a.section.json!: a};
    final available = [
      for (final k in _sectionOrder)
        if (audience[k]?.available ?? false) k,
    ];
    final nonPublicProjects = state.projects.any(
      (p) => p.visibility != CvProjectChoiceDtoVisibility.public,
    );
    final withheld = state.preview.withheld
        .map((w) => _sectionLabel(l10n, w.json!))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PreviewCard(preview: state.preview),
        if (withheld.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            l10n.cvWithheld(withheld.join(', ')),
            style: AtTextStyles.meta.copyWith(color: context.at.muted),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AtButton(
                label: l10n.cvShareLink,
                variant: AtButtonVariant.secondary,
                icon: LucideIcons.share2,
                loading: sharing,
                onPressed: onShare,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AtButton(
                label: preparing ? l10n.cvPdfPreparing : l10n.cvDownloadPdf,
                icon: LucideIcons.download,
                loading: preparing,
                onPressed: onDownload,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Semantics(
          header: true,
          child: Text(
            l10n.cvIncludeTitle,
            style: AtTextStyles.sectionTitleSm.copyWith(color: context.at.ink),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.cvIncludeBody(info.label),
          style: AtTextStyles.meta.copyWith(color: context.at.muted),
        ),
        const SizedBox(height: 10),
        AtCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              for (final key in available)
                _SectionRow(
                  label: _sectionLabel(l10n, key),
                  audienceKey: audience[key]!.visibility.json!,
                  included: _sections.contains(key),
                  allowed: _restricted.contains(key),
                  disabled: saving,
                  onIncluded: (v) =>
                      onSave(_with(_sections, key, v), null, null),
                  onAllowed: (v) =>
                      onSave(null, _with(_restricted, key, v), null),
                ),
            ],
          ),
        ),
        if (info.maxProjects > 0 && available.contains('PORTFOLIO')) ...[
          const SizedBox(height: 22),
          Semantics(
            header: true,
            child: Text(
              l10n.cvProjects,
              style: AtTextStyles.sectionTitleSm.copyWith(
                color: context.at.ink,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.cvProjectsLimit(info.maxProjects.round()),
            style: AtTextStyles.meta.copyWith(color: context.at.muted),
          ),
          const SizedBox(height: 10),
          if (state.projects.isEmpty)
            AtEmptyState(icon: LucideIcons.layoutGrid, title: l10n.cvNoProjects)
          else
            AtCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                children: [
                  for (final p in state.projects)
                    _ProjectRow(
                      project: p,
                      selected: state.config.projectIds.contains(p.id),
                      disabled: saving,
                      onChanged: (v) {
                        final next = [...state.config.projectIds];
                        if (v) {
                          if (next.length >= info.maxProjects) return;
                          next.add(p.id);
                        } else {
                          next.remove(p.id);
                        }
                        onSave(null, null, next);
                      },
                    ),
                  if (nonPublicProjects)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 8),
                      child: AtCheckbox(
                        value: _restricted.contains('PORTFOLIO'),
                        label: l10n.cvAllowPrivateProjects,
                        onChanged: saving
                            ? null
                            : (v) => onSave(
                                null,
                                _with(_restricted, 'PORTFOLIO', v),
                                null,
                              ),
                      ),
                    ),
                ],
              ),
            ),
        ],
        const SizedBox(height: 24),
        Semantics(
          header: true,
          child: Text(
            l10n.cvLinksTitle,
            style: AtTextStyles.sectionTitleSm.copyWith(color: context.at.ink),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.cvLinksBody,
          style: AtTextStyles.meta.copyWith(color: context.at.muted),
        ),
        const SizedBox(height: 10),
        if (state.shares.isEmpty)
          Text(
            l10n.cvNoLinks,
            style: AtTextStyles.bodySm.copyWith(color: context.at.muted),
          )
        else
          AtCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(
              children: [
                for (final (i, link) in state.shares.indexed)
                  _ShareRow(
                    link: link,
                    last: i == state.shares.length - 1,
                    onRevoke: () => onRevoke(link),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// The in-app preview card, as the prototype: avatar, name, format subtitle, summary, selected work, skills with
/// verified marks. It shows what the server will put in the output, nothing more.
class _PreviewCard extends ConsumerWidget {
  const _PreviewCard({required this.preview});

  final CvPreviewDto preview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final url = preview.avatarUrl;
    final label = AtTextStyles.metaSm.copyWith(
      color: context.at.muted,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
    );
    final nothing =
        preview.summary == null &&
        preview.work.isEmpty &&
        preview.skills.isEmpty;
    return AtCard(
      semanticLabel: '${preview.displayName}, ${preview.subtitle}',
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AtAvatar(
                name: preview.displayName,
                size: 56,
                image: url == null ? null : ref.watch(avatarImageProvider)(url),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            preview.displayName,
                            style: AtTextStyles.sectionTitle.copyWith(
                              color: context.at.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (preview.identityVerified) ...[
                          const SizedBox(width: 6),
                          const AtVerifiedTick(size: 16),
                        ],
                      ],
                    ),
                    Text(
                      preview.subtitle,
                      style: AtTextStyles.meta.copyWith(
                        color: context.at.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 28, color: context.at.divider),
          if (nothing)
            Text(
              l10n.cvPreviewNothing,
              style: AtTextStyles.bodySm.copyWith(color: context.at.muted),
            ),
          if (preview.summary != null)
            Text(
              preview.summary!,
              style: AtTextStyles.bodySm.copyWith(color: context.at.body),
            ),
          if (preview.work.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(l10n.cvSelectedWork.toUpperCase(), style: label),
            const SizedBox(height: 6),
            for (final w in preview.work)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  [
                    w.title,
                    if (w.role != null) w.role!,
                    if (w.year != null) '${w.year!.round()}',
                  ].join(' · '),
                  style: AtTextStyles.bodySm.copyWith(color: context.at.body),
                ),
              ),
          ],
          if (preview.skills.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(l10n.cvSkills.toUpperCase(), style: label),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final s in preview.skills)
                  Semantics(
                    label: s.verified
                        ? '${s.name}, ${l10n.cvVerifiedSkill}'
                        : s.name,
                    excludeSemantics: true,
                    child: AtTag(
                      label: s.name,
                      tone: s.verified ? AtTone.primary : AtTone.neutral,
                      icon: s.verified ? LucideIcons.check : null,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({
    required this.label,
    required this.audienceKey,
    required this.included,
    required this.allowed,
    required this.disabled,
    required this.onIncluded,
    required this.onAllowed,
  });

  final String label;
  final String audienceKey;
  final bool included;
  final bool allowed;
  final bool disabled;
  final ValueChanged<bool> onIncluded;
  final ValueChanged<bool> onAllowed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isPublic = audienceKey == 'PUBLIC';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      label,
                      style: AtTextStyles.body.copyWith(color: context.at.ink),
                    ),
                    AtTag(
                      label: _audienceLabel(l10n, audienceKey),
                      tone: isPublic ? AtTone.success : AtTone.neutral,
                    ),
                  ],
                ),
              ),
              AtToggle(
                value: included,
                semanticLabel: label,
                onChanged: disabled ? null : onIncluded,
              ),
            ],
          ),
          if (included && !isPublic) ...[
            const SizedBox(height: 6),
            Text(
              l10n.cvNotPublicNote,
              style: AtTextStyles.meta.copyWith(color: context.at.muted),
            ),
            const SizedBox(height: 4),
            AtCheckbox(
              value: allowed,
              label: l10n.cvAllowNonPublic(
                label.toLowerCase(),
                _audienceLabel(l10n, audienceKey).toLowerCase(),
              ),
              onChanged: disabled ? null : onAllowed,
            ),
          ],
        ],
      ),
    );
  }
}

class _ProjectRow extends StatelessWidget {
  const _ProjectRow({
    required this.project,
    required this.selected,
    required this.disabled,
    required this.onChanged,
  });

  final CvProjectChoiceDto project;
  final bool selected;
  final bool disabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isPublic = project.visibility == CvProjectChoiceDtoVisibility.public;
    final meta = [
      if (project.role != null) project.role!,
      if (project.year != null) '${project.year!.round()}',
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: AtCheckbox(
        value: selected,
        onChanged: disabled ? null : onChanged,
        semanticLabel: project.title,
        labelWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.title,
              style: AtTextStyles.body.copyWith(color: context.at.ink),
            ),
            if (meta.isNotEmpty)
              Text(
                meta,
                style: AtTextStyles.meta.copyWith(color: context.at.muted),
              ),
            if (!isPublic)
              Text(
                l10n.cvProjectNotPublic(
                  _audienceLabel(l10n, project.visibility.json!),
                ),
                style: AtTextStyles.meta.copyWith(color: context.at.muted),
              ),
          ],
        ),
      ),
    );
  }
}

class _ShareRow extends StatelessWidget {
  const _ShareRow({
    required this.link,
    required this.last,
    required this.onRevoke,
  });

  final CvShareDto link;
  final bool last;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final active = link.status == CvShareDtoStatus.active;
    final (label, tone) = switch (link.status) {
      CvShareDtoStatus.active => (l10n.cvLinkActive, AtTone.success),
      CvShareDtoStatus.expired => (l10n.cvLinkExpired, AtTone.warning),
      _ => (l10n.cvLinkRevoked, AtTone.neutral),
    };
    final expiry = link.expiresAt == null
        ? l10n.cvLinkNoExpiry
        : l10n.cvLinkExpires(
            DateFormat.yMMMd(Localizations.localeOf(context).toString())
                .format(link.expiresAt!.toLocal()),
          );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(bottom: BorderSide(color: context.at.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      l10n.cvLinkEnding(link.hint),
                      style: AtTextStyles.bodySm.copyWith(
                        color: context.at.ink,
                      ),
                    ),
                    AtTag(label: label, tone: tone),
                  ],
                ),
                Text(
                  expiry,
                  style: AtTextStyles.meta.copyWith(color: context.at.muted),
                ),
              ],
            ),
          ),
          if (active)
            AtButton(
              label: l10n.cvRevoke,
              variant: AtButtonVariant.tertiary,
              size: AtButtonSize.sm,
              fullWidth: false,
              onPressed: onRevoke,
            ),
        ],
      ),
    );
  }
}
