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
import '../discover/discover_common.dart';
import 'community_common.dart';
import 'community_providers.dart';
import 'community_safety.dart';
import 'post_card.dart';
import 'post_menu.dart';

/// A discussion: the full post, its replies (one level of nesting, with timestamps), and a reply bar fixed
/// to the bottom. The overflow menu saves, mutes, blocks the author or reports.
class PostScreen extends ConsumerStatefulWidget {
  const PostScreen({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends ConsumerState<PostScreen> {
  static const _maxReply = 2000;

  final _reply = TextEditingController();
  final _focus = FocusNode();
  final _scroll = ScrollController();
  bool _sending = false;

  /// The top-level comment a reply goes under, and the name shown in "Replying to".
  ({String parentId, String name})? _replyTo;

  @override
  void initState() {
    super.initState();
    _reply.addListener(() => setState(() {}));
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 400) {
        ref.read(threadProvider(widget.postId).notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _reply.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.community);
    }
  }

  void _startReply(String parentId, String name) {
    setState(() => _replyTo = (parentId: parentId, name: name));
    _focus.requestFocus();
  }

  Future<void> _send() async {
    final text = _reply.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ref
          .read(threadProvider(widget.postId).notifier)
          .reply(text, parentCommentId: _replyTo?.parentId);
      if (!mounted) return;
      _reply.clear();
      setState(() {
        _replyTo = null;
        _sending = false;
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      showCommunityError(context, e);
    }
  }

  Future<void> _commentMenu({
    required String id,
    required String body,
    required bool mine,
  }) async {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(threadProvider(widget.postId).notifier);
    final choice = await showAtBottomSheet<String>(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mine) ...[
            AtListRow(
              title: l10n.cfdMenuEdit,
              icon: LucideIcons.pencil,
              showChevron: false,
              onTap: () => Navigator.of(ctx).pop('edit'),
            ),
            AtListRow(
              title: l10n.cfdMenuDelete,
              icon: LucideIcons.trash2,
              destructive: true,
              showChevron: false,
              onTap: () => Navigator.of(ctx).pop('delete'),
            ),
          ] else
            AtListRow(
              title: l10n.cfdMenuReport,
              icon: LucideIcons.flag,
              destructive: true,
              showChevron: false,
              onTap: () => Navigator.of(ctx).pop('report'),
            ),
        ],
      ),
    );
    if (choice == null || !mounted) return;
    switch (choice) {
      case 'edit':
        await showEditTextSheet(
          context,
          title: l10n.cfdEditReplyTitle,
          initial: body,
          maxLength: _maxReply,
          onSave: (text) => notifier.editComment(id, text),
        );
      case 'delete':
        final yes = await showConfirmSheet(
          context,
          title: l10n.cfdDeleteReplyTitle,
          body: l10n.cfdDeleteReplyBody,
          confirmLabel: l10n.cfdDelete,
        );
        if (!yes || !mounted) return;
        try {
          await notifier.deleteComment(id);
        } on Object catch (e) {
          if (mounted) showCommunityError(context, e);
        }
      case 'report':
        await showReportFlow(
          context,
          targetType: ReportTargetType.comment,
          targetId: id,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final thread = ref.watch(threadProvider(widget.postId));
    final overrides = ref.watch(postOverridesProvider);
    final loaded = thread.value;

    // A post deleted from the feed (or from here) is gone: leave.
    if (overrides.removed.contains(widget.postId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _leave();
      });
    }

    return Scaffold(
      backgroundColor: context.at.background,
      body: AtPage(
        wash: AtWash.community,
        child: Column(
          children: [
            AtTopBar(
              title: l10n.featurePost,
              onBack: _leave,
              actions: [
                if (loaded != null)
                  AtIconButton(
                    icon: LucideIcons.ellipsis,
                    semanticLabel: l10n.moreOptions,
                    onPressed: () async {
                      final outcome = await showPostMenu(
                        context,
                        overrides.resolve(loaded.post),
                      );
                      if (outcome != PostMenuOutcome.none && mounted) _leave();
                    },
                  ),
              ],
            ),
            Expanded(
              child: thread.when(
                loading: () => ListView(
                  padding: const EdgeInsets.all(AtSpacing.gutter),
                  children: const [
                    AtSkeleton(height: 190, radius: 18),
                    SizedBox(height: 16),
                    AtSkeleton(height: 72, radius: 16),
                    SizedBox(height: 10),
                    AtSkeleton(height: 72, radius: 16),
                  ],
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AtSpacing.gutter),
                  child: e is ApiFailure && e.code == 'RESOURCE_NOT_FOUND'
                      ? AtEmptyState(
                          icon: LucideIcons.messageCircleOff,
                          title: l10n.cfdPostGone,
                          body: l10n.cfdPostGoneBody,
                          ctaLabel: l10n.back,
                          onCta: _leave,
                        )
                      : loadFailure(
                          e,
                          () => ref.invalidate(threadProvider(widget.postId)),
                          l10n,
                        ),
                ),
                data: (state) => _Thread(
                  state: state,
                  controller: _scroll,
                  onReply: _startReply,
                  onComment: _commentMenu,
                  onPostReply: () => _focus.requestFocus(),
                  onPostRemoved: _leave,
                  onRetryMore: () => ref
                      .read(threadProvider(widget.postId).notifier)
                      .loadMore(),
                  onRefresh: () async {
                    ref.read(postOverridesProvider.notifier).clear();
                    ref.invalidate(threadProvider(widget.postId));
                    await ref.read(threadProvider(widget.postId).future);
                  },
                ),
              ),
            ),
            if (loaded != null)
              _ReplyBar(
                controller: _reply,
                focus: _focus,
                replyingTo: _replyTo?.name,
                sending: _sending,
                maxLength: _maxReply,
                onCancel: () => setState(() => _replyTo = null),
                onSend: _send,
              ),
          ],
        ),
      ),
    );
  }
}

class _Thread extends ConsumerWidget {
  const _Thread({
    required this.state,
    required this.controller,
    required this.onReply,
    required this.onComment,
    required this.onPostReply,
    required this.onPostRemoved,
    required this.onRetryMore,
    required this.onRefresh,
  });

  final ThreadState state;
  final ScrollController controller;
  final void Function(String parentId, String name) onReply;
  final Future<void> Function({
    required String id,
    required String body,
    required bool mine,
  })
  onComment;
  final VoidCallback onPostReply;
  final VoidCallback onPostRemoved;
  final VoidCallback onRetryMore;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final post = ref.watch(postOverridesProvider).resolve(state.post);
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AtSpacing.gutter,
          8,
          AtSpacing.gutter,
          24,
        ),
        children: [
          CommunityPostCard(
            post: state.post,
            detail: true,
            onReply: onPostReply,
            onRemoved: onPostRemoved,
          ),
          const SizedBox(height: 18),
          Semantics(
            header: true,
            child: Text(
              l10n.cfdReplyCount(post.replyCount.toInt()),
              style: AtTextStyles.cardTitle.copyWith(color: context.at.ink),
            ),
          ),
          const SizedBox(height: 12),
          if (state.comments.isEmpty)
            AtEmptyState(
              icon: LucideIcons.messageCircle,
              title: l10n.cfdNoReplies,
              body: l10n.cfdNoRepliesBody,
            ),
          for (final c in state.comments) ...[
            _CommentTile(
              id: c.id,
              author: c.author,
              body: c.body,
              createdAt: c.createdAt,
              edited: c.editedAt != null,
              mine: c.isMine,
              onReply: () => onReply(c.id, c.author.displayName),
              onMore: () => onComment(id: c.id, body: c.body, mine: c.isMine),
            ),
            for (final r in c.replies)
              Padding(
                padding: const EdgeInsets.only(left: 44, top: 8),
                child: _CommentTile(
                  id: r.id,
                  author: r.author,
                  body: r.body,
                  createdAt: r.createdAt,
                  edited: r.editedAt != null,
                  mine: r.isMine,
                  small: true,
                  onReply: () => onReply(c.id, r.author.displayName),
                  onMore: () =>
                      onComment(id: r.id, body: r.body, mine: r.isMine),
                ),
              ),
            const SizedBox(height: 12),
          ],
          if (state.loadingMore)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.moreFailed)
            AtButton(
              label: l10n.retry,
              variant: AtButtonVariant.tertiary,
              onPressed: onRetryMore,
            )
          else if (state.hasMore)
            AtButton(
              label: l10n.cfdMoreReplies,
              variant: AtButtonVariant.tertiary,
              onPressed: onRetryMore,
            ),
        ],
      ),
    );
  }
}

class _CommentTile extends ConsumerWidget {
  const _CommentTile({
    required this.id,
    required this.author,
    required this.body,
    required this.createdAt,
    required this.edited,
    required this.mine,
    required this.onReply,
    required this.onMore,
    this.small = false,
  });

  final String id;
  final PostAuthorDto author;
  final String body;
  final DateTime createdAt;
  final bool edited;
  final bool mine;
  final bool small;
  final VoidCallback onReply;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final now = ref.watch(communityClockProvider)();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Portrait(
          name: author.displayName,
          url: author.avatarUrl,
          size: small ? 28 : 34,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 4, 6),
            decoration: BoxDecoration(
              color: context.at.softTile,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        author.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AtTextStyles.chip.copyWith(
                          color: context.at.ink,
                        ),
                      ),
                    ),
                    if (author.verified) ...[
                      const SizedBox(width: 4),
                      const AtVerifiedTick(size: 14),
                    ],
                    const SizedBox(width: 8),
                    Text(
                      authorMeta(
                        l10n,
                        headline: null,
                        createdAt: createdAt,
                        now: now,
                        edited: edited,
                      ),
                      style: AtTextStyles.metaSm.copyWith(
                        color: context.at.muted,
                      ),
                    ),
                    const Spacer(),
                    AtTapTarget(
                      onTap: onMore,
                      semanticLabel: l10n.moreOptions,
                      borderRadius: AtRadii.pill,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          LucideIcons.ellipsis,
                          size: 18,
                          color: context.at.muted,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(
                    body,
                    style: AtTextStyles.bodySm.copyWith(
                      color: context.at.longForm,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                AtTapTarget(
                  onTap: onReply,
                  semanticLabel: l10n.cfdReply,
                  borderRadius: AtRadii.pill,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 6,
                    ),
                    child: Text(
                      l10n.cfdReply,
                      style: AtTextStyles.metaSm.copyWith(
                        color: context.at.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// The reply bar fixed to the bottom of the thread.
class _ReplyBar extends ConsumerWidget {
  const _ReplyBar({
    required this.controller,
    required this.focus,
    required this.replyingTo,
    required this.sending,
    required this.maxLength,
    required this.onCancel,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final String? replyingTo;
  final bool sending;
  final int maxLength;
  final VoidCallback onCancel;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final name = ref.watch(sessionControllerProvider).value?.fullName ?? '';
    final canSend = controller.text.trim().isNotEmpty && !sending;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.at.surface,
        border: Border(top: BorderSide(color: context.at.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (replyingTo != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.cfdReplyingTo(replyingTo!),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AtTextStyles.metaSm.copyWith(
                            color: context.at.muted,
                          ),
                        ),
                      ),
                      AtTapTarget(
                        onTap: onCancel,
                        semanticLabel: l10n.cfdCancelReply,
                        borderRadius: AtRadii.pill,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            LucideIcons.x,
                            size: 16,
                            color: context.at.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  AtAvatar(name: name, size: 36),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focus,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: maxLength,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      style: AtTextStyles.body.copyWith(color: context.at.ink),
                      decoration: InputDecoration(
                        hintText: l10n.cfdReplyHint,
                        hintStyle: AtTextStyles.body.copyWith(
                          color: context.at.faint,
                        ),
                        counterText: '',
                        filled: true,
                        fillColor: context.at.inputFill,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          // 23.2 of text + 26 = 49.2, so the field is a 48 dp tap target.
                          vertical: 13,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: AtRadii.pill,
                          borderSide: BorderSide(color: context.at.inputBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AtRadii.pill,
                          borderSide: BorderSide(color: context.at.inputBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AtRadii.pill,
                          borderSide: BorderSide(
                            color: context.at.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  AtIconButton(
                    icon: LucideIcons.send,
                    semanticLabel: l10n.cfdSendReply,
                    variant: AtIconButtonVariant.gradient,
                    onPressed: canSend ? onSend : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
