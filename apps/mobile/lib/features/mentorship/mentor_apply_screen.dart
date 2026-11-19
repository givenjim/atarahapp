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
import '../onboarding/onboarding_providers.dart';
import 'mentorship_common.dart';
import 'mentorship_repository.dart';
import 'session_type_sheet.dart';

/// Time zones offered on the form: where Atarah's members are. The list is the control's own choices, not data.
const mentorZoneChoices = [
  'Africa/Nairobi',
  'Africa/Kampala',
  'Africa/Dar_es_Salaam',
  'Africa/Lagos',
  'Africa/Johannesburg',
  'Europe/London',
  'America/New_York',
];

/// "Apply to mentor": shows where an existing application stands, or the form prefilled from the member's
/// Creative Passport (statement, expertise, credentials) with proposed sessions, prices and evidence links.
class MentorApplyScreen extends ConsumerWidget {
  const MentorApplyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mine = ref.watch(myApplicationProvider);
    return MentorshipScaffold(
      title: l10n.mnApplyTitle,
      body: mine.when(
        skipLoadingOnReload: true,
        loading: () => const AtLoadingBody(),
        error: (e, _) =>
            loadFailure(e, () => ref.invalidate(myApplicationProvider), l10n),
        data: (state) =>
            state.canApply ? const _ApplyForm() : _Status(state: state),
      ),
    );
  }
}

class _Status extends ConsumerStatefulWidget {
  const _Status({required this.state});

  final MyApplicationDto state;

  @override
  ConsumerState<_Status> createState() => _StatusState();
}

class _StatusState extends ConsumerState<_Status> {
  bool _busy = false;
  String? _error;

  Future<void> _withdraw() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(mentorshipRepositoryProvider).withdraw();
      ref.invalidate(myApplicationProvider);
      ref.invalidate(mentorshipHomeProvider);
    } on Object catch (e) {
      if (mounted) setState(() => _error = failureMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final latest = widget.state.latest;
    final pending = latest?.status == MentorApplicationStatus.pending;
    final approved = latest?.status == MentorApplicationStatus.approved;
    final rejected = latest?.status == MentorApplicationStatus.rejected;
    return ListView(
      padding: mentorshipPadding,
      children: [
        if (_error != null) ...[
          AtInlineBanner(message: _error!),
          const SizedBox(height: 12),
        ],
        AtEmptyState(
          icon: pending
              ? LucideIcons.hourglass
              : approved
              ? LucideIcons.badgeCheck
              : LucideIcons.circleAlert,
          title: pending
              ? l10n.mnStatusPending
              : approved
              ? l10n.mnStatusApproved
              : rejected
              ? l10n.mnStatusRejected
              : l10n.mnCannotApply,
          body: pending
              ? l10n.mnStatusPendingBody
              : widget.state.cannotApplyReason ??
                    (rejected ? l10n.mnStatusRejectedBody : null),
          tone: approved ? AtTone.success : AtTone.primary,
          ctaLabel: approved ? l10n.mnMentorTools : null,
          onCta: approved ? () => context.go(Routes.mentorTools) : null,
        ),
        if (rejected && latest?.reviewerNotes != null) ...[
          const SizedBox(height: 12),
          AtInlineBanner(
            message: latest!.reviewerNotes!,
            tone: AtBannerTone.info,
          ),
        ],
        if (pending) ...[
          const SizedBox(height: 16),
          AtButton(
            label: l10n.mnWithdraw,
            variant: AtButtonVariant.secondary,
            loading: _busy,
            onPressed: _busy ? null : _withdraw,
          ),
        ],
      ],
    );
  }
}

class _ApplyForm extends ConsumerStatefulWidget {
  const _ApplyForm();

  @override
  ConsumerState<_ApplyForm> createState() => _ApplyFormState();
}

class _ApplyFormState extends ConsumerState<_ApplyForm> {
  final _headline = TextEditingController();
  final _years = TextEditingController();
  final _statement = TextEditingController();
  final _tag = TextEditingController();
  final _link = TextEditingController();
  bool _seeded = false;
  List<String> _tags = [];
  List<String> _disciplineIds = [];
  List<CredentialDto> _credentials = [];
  List<SessionTypeFieldsDto> _sessions = [];
  List<String> _links = [];
  String _zone = 'Africa/Nairobi';
  bool _terms = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_headline, _years, _statement, _tag, _link]) {
      c.dispose();
    }
    super.dispose();
  }

  void _seed(ApplicationPrefillDto p) {
    if (_seeded) return;
    _seeded = true;
    _headline.text = p.headline;
    _years.text = p.yearsExperience.toInt().toString();
    _statement.text = p.statement;
    _tags = [...p.expertiseTags];
    _disciplineIds = [...p.disciplineIds];
    _credentials = [
      for (final c in p.credentials)
        CredentialDto(title: c.title, issuer: c.issuer, year: c.year),
    ];
    _zone = mentorZoneChoices.contains(p.timeZone)
        ? p.timeZone
        : mentorZoneChoices.first;
  }

  void _addTag() {
    final t = _tag.text.trim();
    if (t.length < 2 || _tags.length >= 12) return;
    if (!_tags.any((x) => x.toLowerCase() == t.toLowerCase())) {
      setState(() => _tags = [..._tags, t]);
    }
    _tag.clear();
  }

  void _addLink() {
    final l = _link.text.trim();
    if (!l.startsWith('https://') || _links.length >= 5) {
      setState(() => _error = AppLocalizations.of(context).mnErrLink);
      return;
    }
    setState(() {
      _links = [..._links, l];
      _error = null;
    });
    _link.clear();
  }

  Future<void> _addCredential() async {
    final l10n = AppLocalizations.of(context);
    final title = TextEditingController();
    final issuer = TextEditingController();
    final ok = await showAtBottomSheet<bool>(
      context: context,
      title: l10n.mnAddCredential,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          AtSpacing.gutter,
          0,
          AtSpacing.gutter,
          24 + MediaQuery.viewInsetsOf(ctx).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AtTextField(label: l10n.mnCredTitle, controller: title),
            const SizedBox(height: 12),
            AtTextField(label: l10n.mnCredIssuer, controller: issuer),
            const SizedBox(height: 16),
            AtButton(
              label: l10n.mnSave,
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
        ),
      ),
    );
    if (ok == true && title.text.trim().length >= 2 && mounted) {
      setState(
        () => _credentials = [
          ..._credentials,
          CredentialDto(
            title: title.text.trim(),
            issuer: issuer.text.trim().isEmpty ? null : issuer.text.trim(),
          ),
        ],
      );
    }
    title.dispose();
    issuer.dispose();
  }

  Future<void> _addSession() async {
    final s = await showSessionTypeSheet(context);
    if (s != null && mounted && _sessions.length < 8) {
      setState(() => _sessions = [..._sessions, s]);
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final years = int.tryParse(_years.text.trim());
    String? error;
    if (_headline.text.trim().length < 4) {
      error = l10n.mnErrHeadline;
    } else if (years == null || years < 0 || years > 80) {
      error = l10n.mnErrYears;
    } else if (_statement.text.trim().length < 40) {
      error = l10n.mnErrStatement;
    } else if (_sessions.isEmpty) {
      error = l10n.mnErrNoSessions;
    } else if (!_terms) {
      error = l10n.mnErrTerms;
    }
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(mentorshipRepositoryProvider)
          .apply(
            ApplyMentorDto(
              headline: _headline.text.trim(),
              yearsExperience: years!,
              expertiseTags: _tags,
              disciplineIds: _disciplineIds,
              credentials: _credentials,
              timeZone: _zone,
              statement: _statement.text.trim(),
              evidenceLinks: _links,
              proposedSessionTypes: [
                for (final s in _sessions)
                  ProposedSessionTypeDto(
                    name: s.name,
                    description: s.description,
                    durationMinutes: s.durationMinutes,
                    priceMinor: s.priceMinor,
                    sessionCount: s.sessionCount,
                  ),
              ],
              acceptTerms: true,
            ),
          );
      ref.invalidate(myApplicationProvider);
      ref.invalidate(mentorshipHomeProvider);
    } on Object catch (e) {
      if (mounted) {
        setState(
          () => _error = e is ApiFailure && e.code == 'VALIDATION_ERROR'
              ? e.message
              : failureMessage(e),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prefill = ref.watch(applicationPrefillProvider);
    final disciplines = ref.watch(disciplinesProvider).value ?? const [];
    return prefill.when(
      loading: () => const AtLoadingBody(),
      error: (e, _) => loadFailure(
        e,
        () => ref.invalidate(applicationPrefillProvider),
        l10n,
      ),
      data: (p) {
        _seed(p);
        if (!p.profileReady) {
          return AtEmptyState(
            icon: LucideIcons.userRound,
            title: l10n.mnProfileFirst,
            body: l10n.mnProfileFirstBody,
            ctaLabel: l10n.mnOpenPassport,
            onCta: () => context.push(Routes.passport),
          );
        }
        return ListView(
          padding: mentorshipPadding,
          children: [
            Text(
              l10n.mnApplyIntro,
              style: AtTextStyles.body.copyWith(color: context.at.body),
            ),
            const SizedBox(height: 16),
            if (_error != null) ...[
              AtInlineBanner(message: _error!),
              const SizedBox(height: 12),
            ],
            AtTextField(
              label: l10n.mnFieldHeadline,
              controller: _headline,
              maxLength: 140,
            ),
            const SizedBox(height: 12),
            AtTextField(
              label: l10n.mnFieldYears,
              controller: _years,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            AtTextField(
              label: l10n.mnFieldStatement,
              helperText: l10n.mnStatementHelp,
              controller: _statement,
              minLines: 4,
              maxLines: 8,
              maxLength: 3000,
            ),
            const SizedBox(height: 16),
            AtSectionHeader(title: l10n.mnExpertise, compact: true),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in _tags)
                  AtChip(
                    label: t,
                    kind: AtChipKind.removable,
                    onRemove: () => setState(
                      () => _tags = _tags.where((x) => x != t).toList(),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            AtTextField(
              hint: l10n.mnAddTagHint,
              controller: _tag,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _addTag(),
              suffix: IconButton(
                icon: const Icon(LucideIcons.plus),
                tooltip: l10n.mnAddTag,
                onPressed: _addTag,
              ),
            ),
            const SizedBox(height: 16),
            AtSectionHeader(title: l10n.mnDiscipline, compact: true),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final d in disciplines)
                  AtChip(
                    label: d.name,
                    selected: _disciplineIds.contains(d.id),
                    onTap: () => setState(() {
                      _disciplineIds = _disciplineIds.contains(d.id)
                          ? _disciplineIds.where((x) => x != d.id).toList()
                          : _disciplineIds.length < 6
                          ? [..._disciplineIds, d.id]
                          : _disciplineIds;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            AtSectionHeader(
              title: l10n.mnCredentials,
              compact: true,
              trailing: AtButton(
                label: l10n.mnAdd,
                size: AtButtonSize.sm,
                fullWidth: false,
                variant: AtButtonVariant.tertiary,
                onPressed: _addCredential,
              ),
            ),
            for (final c in _credentials)
              AtListRow(
                title: c.title,
                subtitle: c.issuer,
                icon: LucideIcons.award,
                showChevron: false,
                trailing: IconButton(
                  icon: const Icon(LucideIcons.x),
                  tooltip: l10n.mnRemove,
                  onPressed: () => setState(
                    () => _credentials = _credentials
                        .where((x) => x != c)
                        .toList(),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            AtSectionHeader(
              title: l10n.mnSessionsTitle,
              compact: true,
              trailing: AtButton(
                label: l10n.mnAdd,
                size: AtButtonSize.sm,
                fullWidth: false,
                variant: AtButtonVariant.tertiary,
                onPressed: _addSession,
              ),
            ),
            for (final s in _sessions)
              AtListRow(
                title: s.name,
                subtitle:
                    '${l10n.mnSessionMeta(s.durationMinutes.toInt())} · ${formatMoney(s.priceMinor, 'KES')}',
                icon: LucideIcons.video,
                showChevron: false,
                trailing: IconButton(
                  icon: const Icon(LucideIcons.x),
                  tooltip: l10n.mnRemove,
                  onPressed: () => setState(
                    () => _sessions = _sessions.where((x) => x != s).toList(),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            AtSectionHeader(title: l10n.mnEvidenceTitle, compact: true),
            const SizedBox(height: 4),
            Text(
              l10n.mnEvidenceHelp,
              style: AtTextStyles.meta.copyWith(color: context.at.body),
            ),
            for (final l in _links)
              AtListRow(
                title: l,
                icon: LucideIcons.link,
                showChevron: false,
                trailing: IconButton(
                  icon: const Icon(LucideIcons.x),
                  tooltip: l10n.mnRemove,
                  onPressed: () => setState(
                    () => _links = _links.where((x) => x != l).toList(),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            AtTextField(
              hint: 'https://',
              controller: _link,
              keyboardType: TextInputType.url,
              onSubmitted: (_) => _addLink(),
              suffix: IconButton(
                icon: const Icon(LucideIcons.plus),
                tooltip: l10n.mnAdd,
                onPressed: _addLink,
              ),
            ),
            const SizedBox(height: 16),
            AtSectionHeader(title: l10n.mnFieldTimeZone, compact: true),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final z in mentorZoneChoices)
                  AtChip(
                    label: z.split('/').last.replaceAll('_', ' '),
                    selected: _zone == z,
                    onTap: () => setState(() => _zone = z),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            AtCheckbox(
              value: _terms,
              onChanged: (v) => setState(() => _terms = v),
              label: l10n.mnTerms,
            ),
            const SizedBox(height: 16),
            AtButton(
              label: l10n.mnSubmitApplication,
              loading: _busy,
              onPressed: _busy ? null : _submit,
            ),
          ],
        );
      },
    );
  }
}
