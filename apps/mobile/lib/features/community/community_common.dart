import 'package:flutter/material.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';

/// A copy of [p] with some fields changed. The generated DTOs have no `copyWith`.
PostViewDto copyPost(
  PostViewDto p, {
  String? body,
  DateTime? editedAt,
  num? reactionCount,
  num? replyCount,
  bool? reacted,
  bool? saved,
  bool? muted,
}) => PostViewDto(
  id: p.id,
  type: p.type,
  body: body ?? p.body,
  audience: p.audience,
  group: p.group,
  author: p.author,
  media: p.media,
  link: p.link,
  reactionCount: reactionCount ?? p.reactionCount,
  replyCount: replyCount ?? p.replyCount,
  isStaffAnnouncement: p.isStaffAnnouncement,
  status: p.status,
  viewer: PostViewerDto(
    reacted: reacted ?? p.viewer.reacted,
    saved: saved ?? p.viewer.saved,
    muted: muted ?? p.viewer.muted,
    isAuthor: p.viewer.isAuthor,
  ),
  createdAt: p.createdAt,
  editedAt: editedAt ?? p.editedAt,
);

/// A reply as the top-level comment shape (the update endpoint answers with a comment).
ReplyViewDto replyOf(CommentViewDto c) => ReplyViewDto(
  id: c.id,
  postId: c.postId,
  parentCommentId: c.parentCommentId ?? '',
  body: c.body,
  author: c.author,
  isMine: c.isMine,
  createdAt: c.createdAt,
  editedAt: c.editedAt,
);

CommentViewDto copyComment(
  CommentViewDto c, {
  String? body,
  DateTime? editedAt,
  List<ReplyViewDto>? replies,
}) => CommentViewDto(
  id: c.id,
  postId: c.postId,
  parentCommentId: c.parentCommentId,
  body: body ?? c.body,
  author: c.author,
  isMine: c.isMine,
  createdAt: c.createdAt,
  editedAt: editedAt ?? c.editedAt,
  replies: replies ?? c.replies,
);

/// Pill label for a post type.
String postTypeLabel(AppLocalizations l10n, PostType t) => switch (t) {
  PostType.update => l10n.cfdTypeUpdate,
  PostType.question => l10n.cfdTypeQuestion,
  PostType.discussion => l10n.cfdTypeDiscussion,
  PostType.collaboration => l10n.cfdTypeCollaboration,
  PostType.announcement => l10n.cfdTypeAnnouncement,
  PostType.$unknown => l10n.cfdTypeUpdate,
};

/// Pill colours by type (Master Prompt 8.2): update violet, discussion indigo, question coral,
/// announcement tangerine. Collaboration is not in the table; it takes the success pair.
AtTone postTypeTone(PostType t) => switch (t) {
  PostType.update => AtTone.violet,
  PostType.question => AtTone.coral,
  PostType.discussion => AtTone.primary,
  PostType.collaboration => AtTone.success,
  PostType.announcement => AtTone.warning,
  PostType.$unknown => AtTone.neutral,
};

/// "now", "5m", "3h", "2d", or a short date for anything older than a week.
String relativeTime(AppLocalizations l10n, DateTime then, DateTime now) {
  final d = now.difference(then);
  if (d.inMinutes < 1) return l10n.cfdNow;
  if (d.inMinutes < 60) return l10n.cfdMinutes(d.inMinutes);
  if (d.inHours < 24) return l10n.cfdHours(d.inHours);
  if (d.inDays < 7) return l10n.cfdDays(d.inDays);
  final local = then.toLocal();
  return '${local.day}/${local.month}/${local.year}';
}

/// The line under an author's name: what they do, then when.
String authorMeta(
  AppLocalizations l10n, {
  required String? headline,
  required DateTime createdAt,
  required DateTime now,
  bool edited = false,
}) => [
  if (headline != null && headline.isNotEmpty) headline,
  relativeTime(l10n, createdAt, now),
  if (edited) l10n.cfdEdited,
].join(' · ');

/// The address a shared post opens (the same address works as a deep link).
String postShareUrl(String id) => 'https://atarah.app/posts/$id';

/// A member-facing sentence for something that went wrong in the community. Knows the codes the community
/// endpoints answer with; everything else falls back to the failure's own safe message.
String communityErrorMessage(AppLocalizations l10n, Object error) {
  if (error is! AppFailure) return const UnexpectedFailure().message;
  if (error is! ApiFailure) return error.message;
  switch (error.code) {
    case 'VERIFICATION_REQUIRED':
      return l10n.cfdErrVerification;
    case 'FORBIDDEN':
      return switch (error.reason) {
        'ACCOUNT_RESTRICTED' => l10n.cfdErrRestricted,
        'NOT_A_MEMBER' => l10n.cfdErrNotMember,
        _ => error.message,
      };
    case 'RESOURCE_NOT_FOUND':
      return l10n.cfdErrNotFound;
    case 'RATE_LIMITED':
      return l10n.cfdErrRateLimited;
    default:
      return error.message.isEmpty
          ? const UnexpectedFailure().message
          : error.message;
  }
}

/// Shows a failure as a snackbar, in the member's words.
void showCommunityError(BuildContext context, Object error) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          communityErrorMessage(AppLocalizations.of(context), error),
        ),
      ),
    );
}

void showCommunityNotice(BuildContext context, String message) {
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
