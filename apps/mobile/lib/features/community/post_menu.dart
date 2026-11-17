import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import 'community_common.dart';
import 'community_providers.dart';
import 'community_safety.dart';

/// What the menu did to the post, so the screen can leave it (deleted) or hide the author (blocked).
enum PostMenuOutcome { none, deleted, blocked }

enum _Item { save, mute, block, report, edit, delete }

/// The overflow menu of a post: save, mute, block the author and report for other people's posts; edit and
/// delete for the member's own. Staff announcements cannot be blocked.
Future<PostMenuOutcome> showPostMenu(
  BuildContext context,
  PostViewDto post,
) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final l10n = AppLocalizations.of(context);
  final mine = post.viewer.isAuthor;
  final system = post.isStaffAnnouncement || post.type == PostType.announcement;
  final picked = await showAtBottomSheet<_Item>(
    context: context,
    builder: (ctx) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AtListRow(
          title: post.viewer.saved ? l10n.cfdMenuUnsave : l10n.cfdMenuSave,
          icon: post.viewer.saved
              ? LucideIcons.bookmarkCheck
              : LucideIcons.bookmark,
          showChevron: false,
          onTap: () => Navigator.of(ctx).pop(_Item.save),
        ),
        AtListRow(
          title: post.viewer.muted ? l10n.cfdMenuUnmute : l10n.cfdMenuMute,
          icon: post.viewer.muted ? LucideIcons.bell : LucideIcons.bellOff,
          showChevron: false,
          onTap: () => Navigator.of(ctx).pop(_Item.mute),
        ),
        if (mine) ...[
          AtListRow(
            title: l10n.cfdMenuEdit,
            icon: LucideIcons.pencil,
            showChevron: false,
            onTap: () => Navigator.of(ctx).pop(_Item.edit),
          ),
          AtListRow(
            title: l10n.cfdMenuDelete,
            icon: LucideIcons.trash2,
            destructive: true,
            showChevron: false,
            onTap: () => Navigator.of(ctx).pop(_Item.delete),
          ),
        ] else ...[
          if (!system)
            AtListRow(
              title: l10n.cfdMenuBlock,
              icon: LucideIcons.userX,
              showChevron: false,
              onTap: () => Navigator.of(ctx).pop(_Item.block),
            ),
          AtListRow(
            title: l10n.cfdMenuReport,
            icon: LucideIcons.flag,
            destructive: true,
            showChevron: false,
            onTap: () => Navigator.of(ctx).pop(_Item.report),
          ),
        ],
      ],
    ),
  );
  if (picked == null || !context.mounted) return PostMenuOutcome.none;

  final actions = container.read(postActionsProvider);
  switch (picked) {
    case _Item.save:
      try {
        await actions.toggleSave(post);
        if (context.mounted) {
          showCommunityNotice(
            context,
            post.viewer.saved ? l10n.cfdUnsavedPost : l10n.cfdSavedPost,
          );
        }
      } on Object catch (e) {
        if (context.mounted) showCommunityError(context, e);
      }
    case _Item.mute:
      try {
        await actions.toggleMute(post);
        if (context.mounted) {
          showCommunityNotice(
            context,
            post.viewer.muted ? l10n.cfdUnmuted : l10n.cfdMuted,
          );
        }
      } on Object catch (e) {
        if (context.mounted) showCommunityError(context, e);
      }
    case _Item.edit:
      await showEditTextSheet(
        context,
        title: l10n.cfdEditPostTitle,
        initial: post.body,
        maxLength: 5000,
        onSave: (text) => actions.editPost(post, text),
      );
    case _Item.delete:
      final yes = await showConfirmSheet(
        context,
        title: l10n.cfdDeletePostTitle,
        body: l10n.cfdDeletePostBody,
        confirmLabel: l10n.cfdDelete,
      );
      if (!yes || !context.mounted) return PostMenuOutcome.none;
      try {
        await actions.deletePost(post);
        return PostMenuOutcome.deleted;
      } on Object catch (e) {
        if (context.mounted) showCommunityError(context, e);
      }
    case _Item.block:
      final blocked = await showBlockFlow(
        context,
        userId: post.author.id,
        name: post.author.displayName,
      );
      if (blocked) return PostMenuOutcome.blocked;
    case _Item.report:
      await showReportFlow(
        context,
        targetType: ReportTargetType.post,
        targetId: post.id,
      );
  }
  return PostMenuOutcome.none;
}
