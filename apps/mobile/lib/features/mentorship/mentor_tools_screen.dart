import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/routing/routes.dart';
import '../discover/discover_common.dart';
import 'mentors_list_screen.dart' show MentorshipToggleRow;
import 'mentorship_common.dart';
import 'mentorship_repository.dart';

/// Mentor tools. A member who is not a mentor sees why to become one and the way to apply (or where their
/// application stands); a mentor sees their status and the tools: availability, session types, profile, and
/// booking requests.
class MentorToolsScreen extends ConsumerWidget {
  const MentorToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(myMentorProvider);
    return MentorshipScaffold(
      title: l10n.mnMentorTools,
      body: async.when(
        skipLoadingOnReload: true,
        loading: () => const AtLoadingBody(),
        error: (e, _) => isNotMentor(e)
            ? const _NotMentor()
            : loadFailure(e, () => ref.invalidate(myMentorProvider), l10n),
        data: (m) => _MentorTools(mentor: m),
      ),
    );
  }
}

class _NotMentor extends ConsumerWidget {
  const _NotMentor();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final application = ref.watch(myApplicationProvider).value;
    final status = application?.latest?.status;
    final pending = status == MentorApplicationStatus.pending;
    return ListView(
      padding: mentorshipPadding,
      children: [
        AtEmptyState(
          icon: LucideIcons.graduationCap,
          tone: AtTone.violet,
          title: pending ? l10n.mnStatusPending : l10n.mnBecomeMentor,
          body: pending ? l10n.mnStatusPendingBody : l10n.mnToolsNotMentorBody,
          ctaLabel: pending ? l10n.mnViewApplication : l10n.mnApplyToMentor,
          onCta: () => context.push(Routes.mentorApply),
        ),
      ],
    );
  }
}

class _MentorTools extends ConsumerStatefulWidget {
  const _MentorTools({required this.mentor});

  final MyMentorDto mentor;

  @override
  ConsumerState<_MentorTools> createState() => _MentorToolsState();
}

class _MentorToolsState extends ConsumerState<_MentorTools> {
  bool _busy = false;
  String? _error;

  Future<void> _setPaused(bool paused) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(mentorshipRepositoryProvider).setPaused(paused);
      ref.invalidate(myMentorProvider);
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
    final m = widget.mentor;
    final paused = m.status == MentorStatus.paused;
    final removed = m.status == MentorStatus.removed;
    final staffPaused = paused && m.statusReason != null;
    final next = m.availability.nextAvailableAt;
    return ListView(
      padding: mentorshipPadding,
      children: [
        if (_error != null) ...[
          AtInlineBanner(message: _error!),
          const SizedBox(height: 12),
        ],
        AtCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      m.headline,
                      style: AtTextStyles.cardTitle.copyWith(
                        color: context.at.ink,
                      ),
                    ),
                  ),
                  AtStatusPill(
                    label: removed
                        ? l10n.mnStatusRemoved
                        : paused
                        ? l10n.mnStatusPaused
                        : m.listed
                        ? l10n.mnStatusLive
                        : l10n.mnStatusNotListed,
                    tone: removed
                        ? AtTone.coral
                        : paused || !m.listed
                        ? AtTone.warning
                        : AtTone.success,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                next == null
                    ? l10n.mnNoAvailabilitySet
                    : l10n.mnNextAvailable(formatSlot(context, next)),
                style: AtTextStyles.meta.copyWith(color: context.at.body),
              ),
              if (!m.listed && !paused) ...[
                const SizedBox(height: 6),
                Text(
                  l10n.mnNotListedHelp,
                  style: AtTextStyles.meta.copyWith(color: context.at.body),
                ),
              ],
              if (staffPaused) ...[
                const SizedBox(height: 8),
                AtInlineBanner(
                  message: l10n.mnStaffPaused(m.statusReason!),
                  tone: AtBannerTone.info,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        AtListRow(
          title: l10n.mnRowAvailability,
          subtitle: l10n.mnRowAvailabilityBody,
          icon: LucideIcons.calendarClock,
          onTap: () => context.push(Routes.mentorAvailability),
        ),
        AtListRow(
          title: l10n.mnRowSessions,
          subtitle: l10n.mnRowSessionsBody(
            m.sessionTypes.where((t) => t.active).length,
          ),
          icon: LucideIcons.video,
          tone: AtTone.violet,
          onTap: () => context.push(Routes.mentorSessionTypes),
        ),
        AtListRow(
          title: l10n.mnRowProfile,
          subtitle: l10n.mnRowProfileBody,
          icon: LucideIcons.userPen,
          tone: AtTone.indigo,
          onTap: () => context.push(Routes.mentorProfileEdit),
        ),
        AtListRow(
          title: l10n.mnRowRequests,
          subtitle: l10n.mnRowRequestsBody,
          icon: LucideIcons.inbox,
          tone: AtTone.warning,
          onTap: () => context.push(Routes.mentorRequests),
        ),
        AtListRow(
          title: l10n.mnViewPublic,
          icon: LucideIcons.eye,
          tone: AtTone.neutral,
          onTap: () => context.push(Routes.mentorPath(m.id)),
        ),
        if (!removed && !staffPaused) ...[
          const SizedBox(height: 8),
          MentorshipToggleRow(
            label: l10n.mnPauseProfile,
            value: paused,
            onChanged: _busy ? (_) {} : _setPaused,
          ),
          Text(
            l10n.mnPauseHelp,
            style: AtTextStyles.meta.copyWith(color: context.at.body),
          ),
        ],
      ],
    );
  }
}

/// "Booking requests": newly booked sessions with the mentee, session and time. Bookings are created in P2-M5, so
/// until then the list is a real empty state.
class MentorRequestsScreen extends ConsumerWidget {
  const MentorRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(bookingRequestsProvider);
    return MentorshipScaffold(
      title: l10n.mnRequestsTitle,
      fallbackRoute: Routes.mentorTools,
      body: async.when(
        skipLoadingOnReload: true,
        loading: () => const AtLoadingBody(),
        error: (e, _) =>
            loadFailure(e, () => ref.invalidate(bookingRequestsProvider), l10n),
        data: (items) => items.isEmpty
            ? AtEmptyState(
                icon: LucideIcons.inbox,
                title: l10n.mnRequestsEmpty,
                body: l10n.mnRequestsEmptyBody,
              )
            : ListView(
                padding: mentorshipPadding,
                children: [
                  for (final r in items)
                    AtListRow(
                      title: '${r.menteeName} · ${r.sessionName}',
                      subtitle: formatSlot(context, r.startsAt),
                      icon: LucideIcons.video,
                      showChevron: false,
                      trailing: AtStatusPill(label: r.status),
                    ),
                ],
              ),
      ),
    );
  }
}
