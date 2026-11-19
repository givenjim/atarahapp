import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/routing/routes.dart';
import '../discover/discover_common.dart';
import 'mentorship_common.dart';
import 'mentorship_repository.dart';

/// One mentor: hero, stats, bio, expertise, "Choose a session" radio cards, credentials. Discovery is open to
/// every member; the bottom button is "Book session" for Pro members (the booking flow arrives in P2-M5, so it
/// opens the "Soon" screen until then) and "Unlock mentorship with Pro" for Free members, who get the premium
/// gate. The server decides which one (`booking` in the response), not the app.
class MentorScreen extends ConsumerStatefulWidget {
  const MentorScreen({super.key, required this.mentorId});

  final String mentorId;

  @override
  ConsumerState<MentorScreen> createState() => _MentorScreenState();
}

class _MentorScreenState extends ConsumerState<MentorScreen> {
  String? _sessionId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(mentorDetailProvider(widget.mentorId));
    return async.when(
      skipLoadingOnReload: true,
      loading: () => const MentorshipScaffold(
        title: '',
        fallbackRoute: Routes.mentorDirectory,
        body: AtLoadingBody(),
      ),
      error: (e, _) => MentorshipScaffold(
        title: '',
        fallbackRoute: Routes.mentorDirectory,
        body: loadFailure(
          e,
          () => ref.invalidate(mentorDetailProvider(widget.mentorId)),
          l10n,
        ),
      ),
      data: (m) {
        final selected = m.sessionTypes
            .where(
              (t) => t.id == (_sessionId ?? m.sessionTypes.firstOrNull?.id),
            )
            .firstOrNull;
        return MentorshipScaffold(
          title: '',
          fallbackRoute: Routes.mentorDirectory,
          body: ListView(
            padding: mentorshipPadding,
            children: [
              _Hero(mentor: m),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AtStatTile(
                      value: m.ratingCount > 0
                          ? m.ratingAverage.toStringAsFixed(1)
                          : '—',
                      label: l10n.mnStatRating(m.ratingCount.toInt()),
                      icon: LucideIcons.star,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AtStatTile(
                      value: '${m.sessionsCount.toInt()}',
                      label: l10n.mnStatSessions,
                      icon: LucideIcons.video,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AtStatTile(
                      value: m.timeZone.split('/').last.replaceAll('_', ' '),
                      label: l10n.mnStatTimeZone,
                      icon: LucideIcons.globe,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AtSectionHeader(title: l10n.mnAbout, compact: true),
              const SizedBox(height: 6),
              Text(
                m.bio,
                style: AtTextStyles.body.copyWith(color: context.at.ink),
              ),
              if (m.expertiseTags.isNotEmpty) ...[
                const SizedBox(height: 16),
                AtSectionHeader(title: l10n.mnExpertise, compact: true),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in m.expertiseTags)
                      AtTag(label: t, tone: AtTone.violet),
                    for (final d in m.disciplines)
                      AtTag(label: d.name, tone: AtTone.primary),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              AtSectionHeader(title: l10n.mnChooseSession, compact: true),
              const SizedBox(height: 8),
              if (m.sessionTypes.isEmpty)
                Text(
                  l10n.mnNoSessions,
                  style: AtTextStyles.body.copyWith(color: context.at.body),
                )
              else
                for (final t in m.sessionTypes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AtRadioCard(
                      title: t.name,
                      subtitle: [
                        l10n.mnSessionMeta(t.durationMinutes.toInt()),
                        if (t.sessionCount > 1)
                          l10n.mnProgrammeSessions(t.sessionCount.toInt()),
                        if (t.description != null) t.description!,
                      ].join(' · '),
                      selected: t.id == selected?.id,
                      onTap: () => setState(() => _sessionId = t.id),
                      trailing: Text(
                        formatMoney(t.priceMinor, t.currency),
                        style: AtTextStyles.chip.copyWith(
                          color: context.at.ink,
                        ),
                      ),
                    ),
                  ),
              if (m.credentials.isNotEmpty) ...[
                const SizedBox(height: 12),
                AtSectionHeader(title: l10n.mnCredentials, compact: true),
                const SizedBox(height: 6),
                for (final c in m.credentials)
                  AtListRow(
                    title: c.title,
                    subtitle: [
                      ?c.issuer,
                      if (c.year != null) '${c.year}',
                    ].join(' · '),
                    icon: LucideIcons.award,
                    showChevron: false,
                  ),
              ],
            ],
          ),
          bottom: m.booking.isSelf
              ? MentorshipBottomBar(
                  child: Text(
                    l10n.mnOwnProfile,
                    textAlign: TextAlign.center,
                    style: AtTextStyles.meta.copyWith(color: context.at.body),
                  ),
                )
              : MentorshipBottomBar(
                  child: m.booking.allowed
                      ? AtButton(
                          label: selected == null
                              ? l10n.mnBookSessionPlain
                              : l10n.mnBookSession(
                                  formatMoney(
                                    selected.priceMinor,
                                    selected.currency,
                                  ),
                                ),
                          onPressed: selected == null
                              ? null
                              // The booking flow (`book`) is P2-M5; until then this opens the "Soon" screen.
                              : () => context.push(
                                  Routes.soonPath(
                                    'p2',
                                    name: l10n.mnBookingName,
                                  ),
                                ),
                        )
                      : AtButton(
                          label: l10n.mnUnlockPro,
                          icon: LucideIcons.lock,
                          onPressed: () =>
                              context.push(Routes.mentorPremiumPath(m.id)),
                        ),
                ),
        );
      },
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.mentor});

  final MentorDetailDto mentor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Portrait(name: mentor.displayName, url: mentor.avatarUrl, size: 96),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Semantics(
                header: true,
                child: Text(
                  mentor.displayName,
                  textAlign: TextAlign.center,
                  style: AtTextStyles.tabTitle.copyWith(
                    color: context.at.ink,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            if (mentor.verified) ...[
              const SizedBox(width: 6),
              const AtVerifiedTick(size: 20),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          mentor.headline,
          textAlign: TextAlign.center,
          style: AtTextStyles.body.copyWith(color: context.at.body),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.mnYears(mentor.yearsExperience.toInt()),
          style: AtTextStyles.meta.copyWith(color: context.at.body),
        ),
      ],
    );
  }
}

/// The premium gate for mentorship, opened from "Unlock mentorship with Pro".
class MentorPremiumScreen extends StatelessWidget {
  const MentorPremiumScreen({super.key, required this.mentorId});

  final String mentorId;

  @override
  Widget build(BuildContext context) => MentorshipScaffold(
    title: '',
    fallbackRoute: Routes.mentorPath(mentorId),
    body: const MentorshipPremiumGate(),
  );
}
