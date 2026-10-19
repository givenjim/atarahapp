import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/auth/session_controller.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/routing/routes.dart';
import '../onboarding/onboarding_providers.dart';
import 'edit_profile_sheet.dart';
import 'profile_labels.dart';
import 'profile_providers.dart';

/// Profile tab: the member's own profile with the completion ring, the Passport card and the next best step,
/// the lists that lead into their identity, and Sign out. Everything comes from the API.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _signingOut = false;
  String? _notice;

  Future<void> _signOut() async {
    setState(() => _signingOut = true);
    try {
      await ref.read(sessionControllerProvider.notifier).signOut();
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  void _soon(String phase, String name) =>
      context.push(Routes.soonPath(phase, name: name));

  Future<void> _edit(OwnProfileDto profile) async {
    final saved = await showEditProfileSheet(context, profile);
    if (saved == true && mounted) {
      setState(() => _notice = AppLocalizations.of(context).epSaved);
    }
  }

  /// Where the "next best step" leads. Projects, skills and experience have their own screens now; changing the
  /// photo, discipline, specialisation or location after setup is not built yet, so those open their labelled
  /// placeholder.
  VoidCallback _nextAction(OwnProfileDto profile, CompletionItemDto item) {
    switch (item.key) {
      case 'bio':
      case 'headline':
        return () => _edit(profile);
      case 'contact':
        return () => context.push(Routes.passport);
      case 'project':
        return () => context.push(Routes.projectEditPath('new'));
      case 'skills':
        return () => context.push(Routes.skills);
      case 'experience':
        return () => context.push(Routes.experience);
      default:
        return () => _soon('p1', item.label);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(sessionControllerProvider).value;
    final profile = ref.watch(myProfileProvider);
    final avatarBuilder = ref.watch(avatarImageProvider);
    final isPro = user?.membership.plan.name.toLowerCase() == 'pro';
    final roles = user?.roles.map((r) => r.json).toSet() ?? const <String?>{};
    final tools = [
      if (roles.contains('MENTOR')) l10n.pfMentorTools,
      if (roles.contains('SELLER')) l10n.pfSellerTools,
    ];

    return AtPage(
      wash: AtWash.settings,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AtSpacing.gutter,
          AtSpacing.gutter,
          AtSpacing.gutter,
          AtSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n.tabProfile,
                style: AtTextStyles.tabTitle.copyWith(color: AtColors.ink),
              ),
            ),
            const SizedBox(height: 16),
            if (_notice != null) ...[
              AtInlineBanner(message: _notice!, tone: AtBannerTone.success),
              const SizedBox(height: 12),
            ],
            profile.when(
              loading: () => const _HeaderSkeleton(),
              error: (e, _) => _LoadError(
                error: e,
                onRetry: () => ref.read(myProfileProvider.notifier).refresh(),
                fallbackName: user?.fullName,
              ),
              data: (p) => p == null
                  ? const SizedBox.shrink()
                  : _Loaded(
                      profile: p,
                      avatarBuilder: avatarBuilder,
                      onEdit: () => _edit(p),
                      onNext: p.completion.next.isEmpty
                          ? null
                          : _nextAction(p, p.completion.next.first),
                      onSoon: _soon,
                    ),
            ),
            if (tools.isNotEmpty) ...[
              const SizedBox(height: 20),
              _SectionTitle(l10n.pfYourTools),
              const SizedBox(height: 8),
              AtCard(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    for (final (i, name) in tools.indexed)
                      AtListRow(
                        title: name,
                        icon: LucideIcons.wrench,
                        tone: AtTone.success,
                        showDivider: i < tools.length - 1,
                        onTap: () => _soon('p2', name),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            _SectionTitle(l10n.pfMyIdentity),
            const SizedBox(height: 8),
            AtCard(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  AtListRow(
                    title: l10n.pfPortfolio,
                    icon: LucideIcons.layoutGrid,
                    showDivider: true,
                    onTap: () => context.push(Routes.portfolio),
                  ),
                  AtListRow(
                    title: l10n.pfSkills,
                    icon: LucideIcons.sparkles,
                    tone: AtTone.success,
                    trailing: _Count(profile.value?.counts.skills),
                    showDivider: true,
                    onTap: () => context.push(Routes.skills),
                  ),
                  AtListRow(
                    title: l10n.pfExperience,
                    icon: LucideIcons.briefcase,
                    tone: AtTone.warning,
                    showDivider: true,
                    onTap: () => context.push(Routes.experience),
                  ),
                  AtListRow(
                    title: l10n.pfAchievements,
                    icon: LucideIcons.award,
                    tone: AtTone.amber,
                    showDivider: true,
                    onTap: () => context.push(Routes.achievements),
                  ),
                  AtListRow(
                    title: l10n.pfServices,
                    icon: LucideIcons.handshake,
                    tone: AtTone.pink,
                    showDivider: true,
                    onTap: () => context.push(Routes.services),
                  ),
                  AtListRow(
                    title: l10n.pfConnections,
                    icon: LucideIcons.users,
                    tone: AtTone.info,
                    trailing: _Count(
                      profile.value?.counts.connections,
                      waiting: profile.value?.counts.pendingRequests,
                    ),
                    // Lists and suggestions arrive with the community milestone.
                    onTap: () => _soon('p1', l10n.pfConnections),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AtCard(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  AtListRow(
                    title: l10n.profileActivity,
                    icon: LucideIcons.activity,
                    tone: AtTone.warning,
                    showDivider: true,
                    onTap: () => _soon('p1', l10n.profileActivity),
                  ),
                  AtListRow(
                    title: l10n.pfSaved,
                    icon: LucideIcons.bookmark,
                    tone: AtTone.purple,
                    showDivider: true,
                    onTap: () => _soon('p1', l10n.pfSaved),
                  ),
                  AtListRow(
                    title: l10n.profileMembership,
                    icon: LucideIcons.crown,
                    tone: AtTone.amber,
                    trailing: AtTag(
                      label: isPro
                          ? l10n.profileMembershipPro
                          : l10n.profileMembershipFree,
                      tone: isPro ? AtTone.amber : AtTone.neutral,
                    ),
                    showDivider: true,
                    // Membership upgrade is a Phase 2 feature.
                    onTap: () => _soon('p2', l10n.profileMembership),
                  ),
                  AtListRow(
                    title: l10n.profileSettings,
                    icon: LucideIcons.settings,
                    tone: AtTone.purple,
                    onTap: () => _soon('p1', l10n.profileSettings),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AtButton(
              label: l10n.signOut,
              variant: AtButtonVariant.destructive,
              loading: _signingOut,
              icon: LucideIcons.logOut,
              onPressed: _signOut,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      text,
      style: AtTextStyles.sectionTitleSm.copyWith(color: AtColors.ink),
    ),
  );
}

class _Count extends StatelessWidget {
  const _Count(this.count, {this.waiting});

  final num? count;
  final num? waiting;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (count == null) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if ((waiting ?? 0) > 0) ...[
          AtTag(
            label: l10n.pfPendingRequests(waiting!.round()),
            tone: AtTone.pink,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          l10n.pfCount(count!.round()),
          style: AtTextStyles.bodySm.copyWith(color: AtColors.muted),
        ),
      ],
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();

  @override
  Widget build(BuildContext context) => const AtCard(
    child: Row(
      children: [
        AtSkeleton.circle(size: 88),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AtSkeleton(width: 160, height: 18),
              SizedBox(height: 8),
              AtSkeleton(width: 120),
            ],
          ),
        ),
      ],
    ),
  );
}

class _LoadError extends StatelessWidget {
  const _LoadError({
    required this.error,
    required this.onRetry,
    this.fallbackName,
  });

  final Object error;
  final VoidCallback onRetry;
  final String? fallbackName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final message = error is AppFailure
        ? (error as AppFailure).message
        : const UnexpectedFailure().message;
    return AtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (fallbackName != null)
            Text(
              fallbackName!,
              style: AtTextStyles.sectionTitle.copyWith(color: AtColors.ink),
            ),
          const SizedBox(height: 8),
          Semantics(
            header: true,
            child: Text(
              l10n.pfLoadFailed,
              style: AtTextStyles.cardTitle.copyWith(color: AtColors.ink),
            ),
          ),
          const SizedBox(height: 8),
          AtInlineBanner(message: message),
          const SizedBox(height: 8),
          AtButton(
            label: l10n.retry,
            variant: AtButtonVariant.secondary,
            size: AtButtonSize.sm,
            fullWidth: false,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({
    required this.profile,
    required this.avatarBuilder,
    required this.onEdit,
    required this.onNext,
    required this.onSoon,
  });

  final OwnProfileDto profile;
  final AvatarImageBuilder avatarBuilder;
  final VoidCallback onEdit;
  final VoidCallback? onNext;
  final void Function(String phase, String name) onSoon;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final percent = profile.completion.percent.round();
    final place = placeLine(profile.location);
    final next = profile.completion.next.firstOrNull;
    final url = profile.avatarUrl;
    final handle = profile.handle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AtCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  AtAvatar(
                    name: profile.displayName,
                    size: 96,
                    progress: percent / 100,
                    image: url == null ? null : avatarBuilder(url),
                    semanticLabel: l10n.pfCompletionPercent(percent),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // A verified tick appears here only when a real verification exists (none yet).
                        Text(
                          profile.displayName,
                          style: AtTextStyles.sectionTitle.copyWith(
                            color: AtColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (profile.headline != null)
                          Text(
                            profile.headline!,
                            style: AtTextStyles.bodySm.copyWith(
                              color: AtColors.body,
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: onEdit,
                            child: Text(
                              l10n.pfAddHeadline,
                              style: AtTextStyles.bodySm.copyWith(
                                color: AtColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.mapPin,
                              size: 12,
                              color: AtColors.muted,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                place ?? l10n.pfLocationNotSet,
                                style: AtTextStyles.meta.copyWith(
                                  color: AtColors.muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AtButton(
                      label: l10n.pfPublicView,
                      variant: AtButtonVariant.secondary,
                      size: AtButtonSize.md,
                      icon: LucideIcons.eye,
                      onPressed: handle == null
                          ? null
                          : () => context.push(
                              Routes.creativePath(handle, preview: true),
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AtButton(
                      label: l10n.pfEditProfile,
                      variant: AtButtonVariant.secondary,
                      size: AtButtonSize.md,
                      icon: LucideIcons.pencil,
                      onPressed: onEdit,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: AtButton(
                  label: l10n.pfImproveBio,
                  variant: AtButtonVariant.tertiary,
                  size: AtButtonSize.sm,
                  fullWidth: false,
                  icon: LucideIcons.sparkles,
                  // The writing assistant is a Phase 3 feature.
                  onPressed: () => onSoon('p3', l10n.pfImproveBio),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AtDarkCard(
          onTap: () => context.push(Routes.passport),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text(
                    l10n.pfPassportCardTitle.toUpperCase(),
                    style: AtTextStyles.metaSm.copyWith(
                      color: AtColors.violet3,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                  Text(
                    profile.passport?.passportNumber.replaceAll('-', ' · ') ??
                        '',
                    style: AtTextStyles.metaSm.copyWith(
                      color: AtColors.violet3,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text(
                    l10n.pfCompletionPercent(percent),
                    style: AtTextStyles.sectionTitle.copyWith(
                      color: AtColors.white,
                    ),
                  ),
                  const Icon(
                    LucideIcons.chevronRight,
                    size: 20,
                    color: AtColors.violet3,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AtProgressBar(
                value: percent / 100,
                color: AtColors.white,
                semanticLabel: l10n.pfCompletionPercent(percent),
              ),
              const SizedBox(height: 14),
              if (next != null && onNext != null)
                AtButton(
                  label: next.label,
                  variant: AtButtonVariant.secondary,
                  size: AtButtonSize.md,
                  icon: LucideIcons.arrowRight,
                  semanticLabel: '${l10n.pfNextBestAction}: ${next.label}',
                  onPressed: onNext,
                )
              else
                Text(
                  l10n.pfAllDone,
                  style: AtTextStyles.bodySm.copyWith(color: AtColors.white),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
