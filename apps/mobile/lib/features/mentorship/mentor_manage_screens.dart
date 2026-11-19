import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/routing/routes.dart';
import '../discover/discover_common.dart';
import 'mentor_apply_screen.dart' show mentorZoneChoices;
import 'mentors_list_screen.dart' show MentorshipToggleRow;
import 'mentorship_common.dart';
import 'mentorship_repository.dart';
import 'session_type_sheet.dart';

// ---- weekly availability -------------------------------------------------------------------------------------

/// A day in the editor: whether it is on, and its one range (minutes after midnight).
class _Day {
  bool on = false;
  int start = 9 * 60;
  int end = 17 * 60;
}

/// Weekly availability: Monday to Sunday toggles with a time range each, the zone the times are in, and days off
/// (exceptions for specific dates).
class MentorAvailabilityScreen extends ConsumerStatefulWidget {
  const MentorAvailabilityScreen({super.key});

  @override
  ConsumerState<MentorAvailabilityScreen> createState() =>
      _MentorAvailabilityScreenState();
}

class _MentorAvailabilityScreenState
    extends ConsumerState<MentorAvailabilityScreen> {
  final List<_Day> _days = List.generate(7, (_) => _Day());
  bool _seeded = false;
  String _zone = 'Africa/Nairobi';
  bool _busy = false;
  String? _error;
  String? _saved;

  void _seed(MyMentorDto m) {
    if (_seeded) return;
    _seeded = true;
    _zone = m.timeZone;
    for (final r in m.availability.weekly) {
      final d = _days[r.weekday.toInt() - 1];
      // The editor shows one range per day; the first range seeds it.
      if (!d.on) {
        d.on = true;
        d.start = r.startMinute.toInt();
        d.end = r.endMinute.toInt();
      }
    }
  }

  Future<void> _pick(_Day d, bool start) async {
    final l10n = AppLocalizations.of(context);
    final initial = start ? d.start : d.end;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial ~/ 60 % 24, minute: initial % 60),
      helpText: start ? l10n.mnFrom : l10n.mnTo,
    );
    if (t == null || !mounted) return;
    setState(() {
      final minute = t.hour * 60 + t.minute;
      if (start) {
        d.start = minute;
      } else {
        // Midnight as an end time means the end of the day.
        d.end = minute == 0 ? 1440 : minute;
      }
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    for (final d in _days) {
      if (d.on && d.start >= d.end) {
        setState(() => _error = l10n.mnEndAfterStart);
        return;
      }
    }
    setState(() {
      _busy = true;
      _error = null;
      _saved = null;
    });
    try {
      await ref.read(mentorshipRepositoryProvider).setWeekly([
        for (final (i, d) in _days.indexed)
          if (d.on)
            WeeklyRangeDto(
              weekday: i + 1,
              startMinute: d.start,
              endMinute: d.end,
            ),
      ], timeZone: _zone);
      ref.invalidate(myMentorProvider);
      ref.invalidate(mentorshipHomeProvider);
      if (mounted) setState(() => _saved = l10n.mnSaved);
    } on Object catch (e) {
      if (mounted) setState(() => _error = failureMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addDayOff() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;
    try {
      await ref
          .read(mentorshipRepositoryProvider)
          .addException(DateFormat('yyyy-MM-dd').format(picked));
      ref.invalidate(myMentorProvider);
    } on Object catch (e) {
      if (mounted) setState(() => _error = failureMessage(e));
    }
  }

  Future<void> _removeDayOff(String id) async {
    try {
      await ref.read(mentorshipRepositoryProvider).removeException(id);
      ref.invalidate(myMentorProvider);
    } on Object catch (e) {
      if (mounted) setState(() => _error = failureMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(myMentorProvider);
    final locale = Localizations.localeOf(context).toString();
    // Monday 2 Nov 2026 is a Monday: used only to get localised weekday names.
    final dayNames = [
      for (var i = 0; i < 7; i++)
        DateFormat('EEEE', locale).format(DateTime(2026, 11, 2 + i)),
    ];
    return MentorshipScaffold(
      title: l10n.mnAvailTitle,
      fallbackRoute: Routes.mentorTools,
      body: async.when(
        loading: () => const AtLoadingBody(),
        error: (e, _) =>
            loadFailure(e, () => ref.invalidate(myMentorProvider), l10n),
        data: (m) {
          _seed(m);
          return ListView(
            padding: mentorshipPadding,
            children: [
              Text(
                l10n.mnAvailIntro,
                style: AtTextStyles.body.copyWith(color: context.at.body),
              ),
              const SizedBox(height: 12),
              if (_error != null) ...[
                AtInlineBanner(message: _error!),
                const SizedBox(height: 12),
              ],
              if (_saved != null) ...[
                AtInlineBanner(message: _saved!, tone: AtBannerTone.success),
                const SizedBox(height: 12),
              ],
              AtSectionHeader(title: l10n.mnFieldTimeZone, compact: true),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final z in {...mentorZoneChoices, _zone})
                    AtChip(
                      label: z.split('/').last.replaceAll('_', ' '),
                      selected: _zone == z,
                      onTap: () => setState(() => _zone = z),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              for (final (i, d) in _days.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Column(
                    children: [
                      MentorshipToggleRow(
                        label: dayNames[i],
                        value: d.on,
                        onChanged: (v) => setState(() => d.on = v),
                      ),
                      if (d.on)
                        Row(
                          children: [
                            Expanded(
                              child: AtButton(
                                label:
                                    '${l10n.mnFrom} ${formatMinute(d.start)}',
                                variant: AtButtonVariant.secondary,
                                size: AtButtonSize.md,
                                onPressed: () => _pick(d, true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AtButton(
                                label:
                                    '${l10n.mnTo} ${formatMinute(d.end == 1440 ? 0 : d.end)}',
                                variant: AtButtonVariant.secondary,
                                size: AtButtonSize.md,
                                onPressed: () => _pick(d, false),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              AtButton(
                label: l10n.mnSaveAvailability,
                loading: _busy,
                onPressed: _busy ? null : _save,
              ),
              const SizedBox(height: 24),
              AtSectionHeader(
                title: l10n.mnDaysOff,
                compact: true,
                trailing: AtButton(
                  label: l10n.mnAdd,
                  size: AtButtonSize.sm,
                  fullWidth: false,
                  variant: AtButtonVariant.tertiary,
                  onPressed: _addDayOff,
                ),
              ),
              if (m.availability.exceptions.isEmpty)
                Text(
                  l10n.mnNoDaysOff,
                  style: AtTextStyles.meta.copyWith(color: context.at.body),
                )
              else
                for (final e in m.availability.exceptions)
                  AtListRow(
                    title: DateFormat.yMMMEd(locale)
                        .format(DateTime.parse(e.date)),
                    subtitle: e.reason,
                    icon: LucideIcons.calendarOff,
                    tone: AtTone.coral,
                    showChevron: false,
                    trailing: IconButton(
                      icon: const Icon(LucideIcons.x),
                      tooltip: l10n.mnRemove,
                      onPressed: () => _removeDayOff(e.id),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

// ---- session types -------------------------------------------------------------------------------------------

/// Session types: create, edit and switch off, each with a price and duration.
class MentorSessionTypesScreen extends ConsumerStatefulWidget {
  const MentorSessionTypesScreen({super.key});

  @override
  ConsumerState<MentorSessionTypesScreen> createState() =>
      _MentorSessionTypesScreenState();
}

class _MentorSessionTypesScreenState
    extends ConsumerState<MentorSessionTypesScreen> {
  String? _error;

  Future<void> _guard(Future<void> Function() call) async {
    try {
      setState(() => _error = null);
      await call();
      ref.invalidate(myMentorProvider);
      ref.invalidate(mentorshipHomeProvider);
    } on Object catch (e) {
      if (mounted) setState(() => _error = failureMessage(e));
    }
  }

  Future<void> _create() async {
    final f = await showSessionTypeSheet(context);
    if (f == null) return;
    await _guard(
      () => ref.read(mentorshipRepositoryProvider).createSessionType(f),
    );
  }

  Future<void> _edit(SessionTypeDto t) async {
    final f = await showSessionTypeSheet(
      context,
      initial: SessionTypeFieldsDto(
        name: t.name,
        description: t.description,
        durationMinutes: t.durationMinutes,
        priceMinor: t.priceMinor,
        sessionCount: t.sessionCount,
      ),
    );
    if (f == null) return;
    await _guard(
      () => ref
          .read(mentorshipRepositoryProvider)
          .updateSessionType(
            t.id,
            UpdateSessionTypeDto(
              name: f.name,
              description: f.description,
              durationMinutes: f.durationMinutes,
              priceMinor: f.priceMinor,
              sessionCount: f.sessionCount,
            ),
          ),
    );
  }

  Future<void> _toggle(SessionTypeDto t, bool on) => _guard(
    () => ref
        .read(mentorshipRepositoryProvider)
        .updateSessionType(t.id, UpdateSessionTypeDto(active: on)),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(myMentorProvider);
    return MentorshipScaffold(
      title: l10n.mnRowSessions,
      fallbackRoute: Routes.mentorTools,
      body: async.when(
        skipLoadingOnReload: true,
        loading: () => const AtLoadingBody(),
        error: (e, _) =>
            loadFailure(e, () => ref.invalidate(myMentorProvider), l10n),
        data: (m) => ListView(
          padding: mentorshipPadding,
          children: [
            if (_error != null) ...[
              AtInlineBanner(message: _error!),
              const SizedBox(height: 12),
            ],
            if (m.sessionTypes.isEmpty)
              AtEmptyState(
                icon: LucideIcons.video,
                title: l10n.mnNoSessionTypes,
                body: l10n.mnNoSessionTypesBody,
              ),
            for (final t in m.sessionTypes)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AtCard(
                  onTap: t.disabledByStaff ? null : () => _edit(t),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              t.name,
                              style: AtTextStyles.cardTitle.copyWith(
                                color: context.at.ink,
                              ),
                            ),
                          ),
                          Text(
                            formatMoney(t.priceMinor, t.currency),
                            style: AtTextStyles.chip.copyWith(
                              color: context.at.ink,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        [
                          l10n.mnSessionMeta(t.durationMinutes.toInt()),
                          if (t.sessionCount > 1)
                            l10n.mnProgrammeSessions(t.sessionCount.toInt()),
                        ].join(' · '),
                        style: AtTextStyles.meta.copyWith(
                          color: context.at.body,
                        ),
                      ),
                      if (t.disabledByStaff)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: AtStatusPill(
                            label: l10n.mnStaffOff,
                            tone: AtTone.coral,
                          ),
                        )
                      else
                        MentorshipToggleRow(
                          label: t.active ? l10n.mnOn : l10n.mnOff,
                          value: t.active,
                          onChanged: (v) => _toggle(t, v),
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            AtButton(
              label: l10n.mnNewSessionType,
              icon: LucideIcons.plus,
              onPressed: _create,
            ),
          ],
        ),
      ),
    );
  }
}

// ---- profile -------------------------------------------------------------------------------------------------

/// Edit the public mentor profile: headline, about, years, expertise, meeting link and time zone.
class MentorProfileEditScreen extends ConsumerStatefulWidget {
  const MentorProfileEditScreen({super.key});

  @override
  ConsumerState<MentorProfileEditScreen> createState() =>
      _MentorProfileEditScreenState();
}

class _MentorProfileEditScreenState
    extends ConsumerState<MentorProfileEditScreen> {
  final _headline = TextEditingController();
  final _bio = TextEditingController();
  final _years = TextEditingController();
  final _link = TextEditingController();
  final _tag = TextEditingController();
  bool _seeded = false;
  List<String> _tags = [];
  String _zone = 'Africa/Nairobi';
  bool _busy = false;
  String? _error;
  String? _saved;

  @override
  void dispose() {
    for (final c in [_headline, _bio, _years, _link, _tag]) {
      c.dispose();
    }
    super.dispose();
  }

  void _seed(MyMentorDto m) {
    if (_seeded) return;
    _seeded = true;
    _headline.text = m.headline;
    _bio.text = m.bio;
    _years.text = m.yearsExperience.toInt().toString();
    _link.text = m.videoCallLink ?? '';
    _tags = [...m.expertiseTags];
    _zone = m.timeZone;
  }

  void _addTag() {
    final t = _tag.text.trim();
    if (t.length < 2 || _tags.length >= 12) return;
    if (!_tags.any((x) => x.toLowerCase() == t.toLowerCase())) {
      setState(() => _tags = [..._tags, t]);
    }
    _tag.clear();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final years = int.tryParse(_years.text.trim());
    final link = _link.text.trim();
    String? error;
    if (_headline.text.trim().length < 4) {
      error = l10n.mnErrHeadline;
    } else if (_bio.text.trim().length < 40) {
      error = l10n.mnErrStatement;
    } else if (years == null || years < 0 || years > 80) {
      error = l10n.mnErrYears;
    } else if (link.isNotEmpty && !link.startsWith('https://')) {
      error = l10n.mnErrLink;
    }
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _saved = null;
    });
    try {
      await ref
          .read(mentorshipRepositoryProvider)
          .updateProfile(
            UpdateMentorProfileDto(
              headline: _headline.text.trim(),
              bio: _bio.text.trim(),
              yearsExperience: years!,
              expertiseTags: _tags,
              timeZone: _zone,
              videoCallLink: link.isEmpty ? null : link,
            ),
          );
      ref.invalidate(myMentorProvider);
      ref.invalidate(mentorshipHomeProvider);
      if (mounted) setState(() => _saved = l10n.mnSaved);
    } on Object catch (e) {
      if (mounted) setState(() => _error = failureMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(myMentorProvider);
    return MentorshipScaffold(
      title: l10n.mnRowProfile,
      fallbackRoute: Routes.mentorTools,
      body: async.when(
        loading: () => const AtLoadingBody(),
        error: (e, _) =>
            loadFailure(e, () => ref.invalidate(myMentorProvider), l10n),
        data: (m) {
          _seed(m);
          return ListView(
            padding: mentorshipPadding,
            children: [
              if (_error != null) ...[
                AtInlineBanner(message: _error!),
                const SizedBox(height: 12),
              ],
              if (_saved != null) ...[
                AtInlineBanner(message: _saved!, tone: AtBannerTone.success),
                const SizedBox(height: 12),
              ],
              AtTextField(
                label: l10n.mnFieldHeadline,
                controller: _headline,
                maxLength: 140,
              ),
              const SizedBox(height: 12),
              AtTextField(
                label: l10n.mnAbout,
                controller: _bio,
                minLines: 4,
                maxLines: 8,
                maxLength: 3000,
              ),
              const SizedBox(height: 12),
              AtTextField(
                label: l10n.mnFieldYears,
                controller: _years,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              AtTextField(
                label: l10n.mnVideoLink,
                helperText: l10n.mnVideoLinkHelp,
                controller: _link,
                keyboardType: TextInputType.url,
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
                onSubmitted: (_) => _addTag(),
                suffix: IconButton(
                  icon: const Icon(LucideIcons.plus),
                  tooltip: l10n.mnAddTag,
                  onPressed: _addTag,
                ),
              ),
              const SizedBox(height: 16),
              AtSectionHeader(title: l10n.mnFieldTimeZone, compact: true),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final z in {...mentorZoneChoices, _zone})
                    AtChip(
                      label: z.split('/').last.replaceAll('_', ' '),
                      selected: _zone == z,
                      onTap: () => setState(() => _zone = z),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              AtButton(
                label: l10n.mnSave,
                loading: _busy,
                onPressed: _busy ? null : _save,
              ),
            ],
          );
        },
      ),
    );
  }
}
