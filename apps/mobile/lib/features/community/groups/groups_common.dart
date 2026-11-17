import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/api/generated/export.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/networking/failures.dart';
import '../../../core/routing/routes.dart';
import '../../onboarding/onboarding_providers.dart';
import 'groups_providers.dart';

/// "Discipline", "Location", ...
String groupTypeLabel(AppLocalizations l10n, GroupType type) => switch (type) {
  GroupType.discipline => l10n.grpTypeDiscipline,
  GroupType.location => l10n.grpTypeLocation,
  GroupType.interest => l10n.grpTypeInterest,
  GroupType.programme => l10n.grpTypeProgramme,
  GroupType.$unknown => l10n.grpTypeInterest,
};

IconData groupTypeIcon(GroupType type) => switch (type) {
  GroupType.discipline => LucideIcons.palette,
  GroupType.location => LucideIcons.mapPin,
  GroupType.interest => LucideIcons.heart,
  GroupType.programme => LucideIcons.graduationCap,
  GroupType.$unknown => LucideIcons.users,
};

/// Route to a group. [ref] is its id or slug.
String groupPath(String ref) => '/groups/${Uri.encodeComponent(ref)}';

/// "Start a discussion" opens the compose screen with this group preselected (`groupId`, plus `groupName`
/// for its audience row).
void openGroupCompose(BuildContext context, String groupId, String name) =>
    context.push(Routes.composePath(groupId: groupId, groupName: name));

/// The words shown when joining, leaving or posting in a group is refused.
String groupFailureMessage(
  AppLocalizations l10n,
  AppFailure failure, {
  bool leaving = false,
}) {
  if (failure is ApiFailure) {
    if (leaving && failure.code == 'INVALID_STATE') {
      return l10n.grpOwnerCantLeave;
    }
    switch (failure.code) {
      case 'VERIFICATION_REQUIRED':
        return l10n.grpErrVerify;
      case 'RATE_LIMITED':
        return l10n.grpErrRate;
      case 'FORBIDDEN':
        return failure.reason == 'ACCOUNT_RESTRICTED'
            ? l10n.grpErrRestricted
            : l10n.grpErrPrivate;
      case 'RESOURCE_NOT_FOUND':
        return l10n.grpGoneBody;
    }
  }
  return failure.message;
}

/// Joins or leaves with a confirmation on the way out. Shared by the cards and the group screen.
Future<void> toggleGroupMembership(
  BuildContext context,
  WidgetRef ref, {
  required String groupId,
  required String name,
  required bool joined,
  required bool isOwner,
  required num memberCount,
}) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  void say(String text) => messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  if (joined) {
    if (isOwner) {
      say(l10n.grpOwnerCantLeave);
      return;
    }
    final yes = await showAtModal<bool>(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.grpLeaveTitle(name),
            style: AtTextStyles.cardTitle.copyWith(color: ctx.at.ink),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.grpLeaveBody,
            style: AtTextStyles.body.copyWith(color: ctx.at.body),
          ),
          const SizedBox(height: 18),
          AtButton(
            label: l10n.grpLeaveConfirm,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
          const SizedBox(height: 8),
          AtButton(
            label: l10n.grpStay,
            variant: AtButtonVariant.secondary,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
        ],
      ),
    );
    if (yes != true) return;
  }
  try {
    await ref
        .read(groupMembershipProvider.notifier)
        .setJoined(
          groupId: groupId,
          joined: !joined,
          wasJoined: joined,
          memberCount: memberCount,
        );
    say(joined ? l10n.grpLeftToast(name) : l10n.grpJoinedToast(name));
  } on AppFailure catch (e) {
    say(groupFailureMessage(l10n, e, leaving: joined));
  }
}

/// A picture from the network for a cover, or nothing until there is one.
class GroupCover extends ConsumerWidget {
  const GroupCover({super.key, required this.url, required this.type});

  final String? url;
  final GroupType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [context.at.primaryFill, context.at.primaryPressed],
        ),
      ),
      child: Center(
        child: Icon(groupTypeIcon(type), size: 28, color: context.at.white),
      ),
    );
    if (url == null) return fallback;
    return Image(
      image: ref.watch(avatarImageProvider)(url!),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}
