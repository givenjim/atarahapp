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

/// The Mentorship hub (`mentorship`): what it is, the member's next session (Pro, from P2-M5), how it works, who
/// it is for, the top mentors, "Find a mentor", and the way in to Mentor tools or the application.
class MentorshipHubScreen extends ConsumerWidget {
  const MentorshipHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(mentorshipHomeProvider);
    return Scaffold(
      backgroundColor: context.at.background,
      body: AtPage(
        wash: AtWash.community,
        child: Column(
          children: [
            AtTopBar(
              onBack: () =>
                  context.canPop() ? context.pop() : context.go(Routes.explore),
            ),
            Expanded(
              child: async.when(
                skipLoadingOnReload: true,
                loading: () => const AtLoadingBody(),
                error: (e, _) => loadFailure(
                  e,
                  () => ref.invalidate(mentorshipHomeProvider),
                  l10n,
                ),
                data: (home) => RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(mentorshipHomeProvider);
                    await ref.read(mentorshipHomeProvider.future);
                  },
                  child: _HubBody(home: home),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HubBody extends StatelessWidget {
  const _HubBody({required this.home});

  final MentorshipHomeDto home;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final next = home.nextSession;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: mentorshipPadding,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  l10n.mnHubTitle,
                  style: AtTextStyles.tabTitle.copyWith(
                    color: context.at.ink,
                    fontSize: 28,
                  ),
                ),
              ),
            ),
            if (!home.canBook) const AtProPill(),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.mnHubIntro,
          style: AtTextStyles.body.copyWith(color: context.at.body),
        ),
        if (next != null) ...[
          const SizedBox(height: 16),
          AtDarkCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.mnNextSession,
                  style: AtTextStyles.meta.copyWith(color: context.at.white),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.mnNextSessionWith(next.sessionName, next.mentorName),
                  style: AtTextStyles.cardTitle.copyWith(
                    color: context.at.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatSlot(context, next.startsAt),
                  style: AtTextStyles.meta.copyWith(color: context.at.white),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        AtSectionHeader(title: l10n.mnHowTitle, compact: true),
        const SizedBox(height: 8),
        _Step(
          index: 1,
          title: l10n.mnHow1,
          body: l10n.mnHow1Body,
          icon: LucideIcons.search,
        ),
        _Step(
          index: 2,
          title: l10n.mnHow2,
          body: l10n.mnHow2Body,
          icon: LucideIcons.listChecks,
        ),
        _Step(
          index: 3,
          title: l10n.mnHow3,
          body: l10n.mnHow3Body,
          icon: LucideIcons.video,
        ),
        const SizedBox(height: 16),
        AtSectionHeader(title: l10n.mnWhoTitle, compact: true),
        const SizedBox(height: 8),
        for (final line in [l10n.mnWho1, l10n.mnWho2, l10n.mnWho3])
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.check, size: 16, color: context.at.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    line,
                    style: AtTextStyles.body.copyWith(color: context.at.ink),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        AtSectionHeader(
          title: l10n.mnTopMentors,
          compact: true,
          onSeeAll: () => context.push(Routes.mentorDirectory),
        ),
        const SizedBox(height: 8),
        if (home.topMentors.isEmpty)
          AtEmptyState(
            icon: LucideIcons.users,
            title: l10n.mnNoMentorsYet,
            body: l10n.mnNoMentorsYetBody,
          )
        else
          SizedBox(
            height: 232,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: home.topMentors.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) =>
                  MentorCard(mentor: home.topMentors[i], width: 280),
            ),
          ),
        const SizedBox(height: 20),
        AtButton(
          label: l10n.mnFindMentor,
          icon: LucideIcons.search,
          onPressed: () => context.push(Routes.mentorDirectory),
        ),
        const SizedBox(height: 12),
        AtCard(
          onTap: () => context.push(
            home.isMentor ? Routes.mentorTools : Routes.mentorApply,
          ),
          child: Row(
            children: [
              const AtIconTile(
                icon: LucideIcons.graduationCap,
                tone: AtTone.violet,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      home.isMentor ? l10n.mnMentorTools : l10n.mnBecomeMentor,
                      style: AtTextStyles.cardTitle.copyWith(
                        color: context.at.ink,
                      ),
                    ),
                    Text(
                      home.isMentor
                          ? l10n.mnMentorToolsBody
                          : l10n.mnBecomeMentorBody,
                      style: AtTextStyles.meta.copyWith(color: context.at.body),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, color: context.at.body),
            ],
          ),
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.index,
    required this.title,
    required this.body,
    required this.icon,
  });

  final int index;
  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AtIconTile(icon: icon, tone: AtTone.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$index. $title',
                style: AtTextStyles.cardTitle.copyWith(color: context.at.ink),
              ),
              Text(
                body,
                style: AtTextStyles.meta.copyWith(color: context.at.body),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
