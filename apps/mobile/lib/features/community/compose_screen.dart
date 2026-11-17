import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/auth/session_controller.dart';
import '../../core/connectivity/connectivity_provider.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/routing/routes.dart';
import '../portfolio/media_seams.dart';
import '../portfolio/portfolio_providers.dart';
import '../portfolio/portfolio_repository.dart';
import 'community_common.dart';
import 'community_providers.dart';
import 'compose_draft.dart';

/// One photo or video on its way up.
class _Attachment {
  _Attachment(this.file) : state = AtMediaTileState.uploading;

  final PickedMedia file;
  String? mediaId;
  AtMediaTileState state;
  double progress = 0;
}

/// The composer: type, words (up to 5,000), photos and videos, a link, and who can see it. What the member
/// types is kept on the phone as a draft until it is posted.
class ComposeScreen extends ConsumerStatefulWidget {
  const ComposeScreen({super.key, this.groupId, this.groupName});

  /// Post into this group (from a group's own "write" button).
  final String? groupId;
  final String? groupName;

  @override
  ConsumerState<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends ConsumerState<ComposeScreen> {
  static const _maxBody = 5000;
  static const _maxMedia = 10;
  static const _autosave = Duration(milliseconds: 500);

  final _body = TextEditingController();
  final _bodyFocus = FocusNode();
  final List<_Attachment> _media = [];

  PostType _type = PostType.update;
  PostAudience _audience = PostAudience.members;
  String? _groupId;
  String? _groupName;
  String? _link;

  bool _posting = false;
  bool _disposed = false;
  String? _error;
  Timer? _timer;

  // Kept so the last edit can still be saved while the screen is closing.
  late final ComposeDraftStore _store = ref.read(composeDraftStoreProvider);
  late final String? _userId = ref.read(sessionControllerProvider).value?.id;

  @override
  void initState() {
    super.initState();
    if (widget.groupId != null) {
      _audience = PostAudience.group;
      _groupId = widget.groupId;
      _groupName = widget.groupName;
    }
    _body.addListener(_touch);
    unawaited(_restore());
  }

  @override
  void dispose() {
    _disposed = true;
    if (_timer?.isActive ?? false) {
      _timer!.cancel();
      _saveDraft();
    }
    _body.dispose();
    _bodyFocus.dispose();
    super.dispose();
  }

  // ---- the draft ----

  ComposeDraft get _draft => ComposeDraft(
    type: _type.json ?? 'UPDATE',
    body: _body.text,
    audience: _audience.json ?? 'MEMBERS',
    groupId: _groupId,
    groupName: _groupName,
    linkUrl: _link,
  );

  Future<void> _restore() async {
    final id = _userId;
    if (id == null) return;
    final draft = await _store.load(id);
    if (draft == null || _disposed || !mounted) return;
    setState(() {
      _body.removeListener(_touch);
      _body.text = draft.body;
      _body.addListener(_touch);
      _type = PostType.fromJson(draft.type);
      if (_type == PostType.$unknown ||
          (_type == PostType.announcement && !ref.read(canAnnounceProvider))) {
        _type = PostType.update;
      }
      _link = draft.linkUrl;
      // A group the composer was opened for wins over where the draft was going.
      if (widget.groupId == null) {
        _audience = PostAudience.fromJson(draft.audience);
        if (_audience == PostAudience.$unknown) {
          _audience = PostAudience.members;
        }
        _groupId = draft.groupId;
        _groupName = draft.groupName;
        if (_audience == PostAudience.group && _groupId == null) {
          _audience = PostAudience.members;
        }
      }
    });
  }

  void _touch() {
    _timer?.cancel();
    _timer = Timer(_autosave, _saveDraft);
    if (mounted) setState(() {});
  }

  void _saveDraft() {
    final id = _userId;
    if (id != null) unawaited(_store.save(id, _draft));
  }

  // ---- files and link ----

  Future<void> _pick(MediaPickKind kind) async {
    final l10n = AppLocalizations.of(context);
    final room = _maxMedia - _media.length;
    if (room <= 0) {
      showCommunityNotice(context, l10n.cfdMediaFull);
      return;
    }
    try {
      final picked = await ref
          .read(mediaPickerProvider)
          .pick(kind, limit: room);
      if (!mounted) return;
      for (final f in picked.take(room)) {
        final a = _Attachment(f);
        setState(() => _media.add(a));
        unawaited(_upload(a));
      }
    } on Object {
      if (mounted) setState(() => _error = l10n.cfdPickFailed);
    }
  }

  Future<void> _upload(_Attachment a) async {
    setState(() {
      a.state = AtMediaTileState.uploading;
      a.progress = 0;
    });
    try {
      final id = await ref
          .read(portfolioRepositoryProvider)
          .uploadMedia(
            a.file,
            onProgress: (p) {
              if (!_disposed) setState(() => a.progress = p);
            },
          );
      if (_disposed) return;
      setState(() {
        a.mediaId = id;
        a.state = AtMediaTileState.ready;
      });
    } on Object catch (e) {
      if (_disposed) return;
      setState(() {
        a.state = AtMediaTileState.failed;
        _error = e is AppFailure
            ? e.message
            : const UnexpectedFailure().message;
      });
    }
  }

  Future<void> _addLink() async {
    final url = await showAtBottomSheet<String>(
      context: context,
      title: AppLocalizations.of(context).cfdLinkTitle,
      builder: (_) => _LinkSheet(initial: _link),
    );
    if (url == null || !mounted) return;
    setState(() => _link = url.isEmpty ? null : url);
    _touch();
  }

  // ---- audience ----

  Future<void> _chooseAudience() async {
    final picked = await showAtBottomSheet<_AudienceChoice>(
      context: context,
      title: AppLocalizations.of(context).cfdAudience,
      builder: (_) => _AudienceSheet(
        audience: _audience,
        groupId: _groupId,
        // Posting from a group's page keeps the group; the rest of the choices stay open.
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _audience = picked.audience;
      _groupId = picked.groupId;
      _groupName = picked.groupName;
    });
    _touch();
  }

  String _audienceLabel(AppLocalizations l10n) => switch (_audience) {
    PostAudience.public => l10n.cfdAudPublic,
    PostAudience.connections => l10n.cfdAudConnections,
    PostAudience.group => _groupName ?? l10n.cfdAudGroupBody,
    _ => l10n.cfdAudMembers,
  };

  // ---- posting ----

  String? _validate(AppLocalizations l10n) {
    final text = _body.text.trim();
    if (text.length > _maxBody) return l10n.cfdTooLong(_maxBody);
    if (_media.any((m) => m.state != AtMediaTileState.ready)) {
      return l10n.cfdUploadsPending;
    }
    if (text.isEmpty && _media.isEmpty && _link == null) {
      return l10n.cfdNeedsContent;
    }
    return null;
  }

  Future<void> _post() async {
    final l10n = AppLocalizations.of(context);
    final problem = _validate(l10n);
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    final text = _body.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _posting = true;
      _error = null;
    });
    try {
      await ref
          .read(communityRepositoryProvider)
          .createPost(
            CreatePostDto(
              type: _type,
              body: text.isEmpty ? null : text,
              audience: _audience,
              groupId: _audience == PostAudience.group ? _groupId : null,
              mediaIds: _media.isEmpty
                  ? null
                  : [for (final m in _media) m.mediaId!],
              linkUrl: _link,
            ),
          );
      _timer?.cancel();
      final id = _userId;
      if (id != null) await _store.clear(id);
      // Fresh feeds will show the new post at the top.
      ref.read(postOverridesProvider.notifier).clear();
      ref.invalidate(feedProvider);
      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(Routes.community);
      }
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.cfdPostedToast)));
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _posting = false;
        _error = communityErrorMessage(l10n, e);
      });
    }
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.community);
    }
  }

  // ---- view ----

  (String, IconData) _typeChip(
    AppLocalizations l10n,
    PostType t,
  ) => switch (t) {
    PostType.update => (l10n.cfdChipUpdate, LucideIcons.sparkles),
    PostType.question => (l10n.cfdTypeQuestion, LucideIcons.circleQuestionMark),
    PostType.discussion => (l10n.cfdTypeDiscussion, LucideIcons.messagesSquare),
    PostType.collaboration => (
      l10n.cfdTypeCollaboration,
      LucideIcons.handshake,
    ),
    PostType.announcement => (l10n.cfdTypeAnnouncement, LucideIcons.megaphone),
    PostType.$unknown => (l10n.cfdChipUpdate, LucideIcons.sparkles),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = ref.watch(sessionControllerProvider).value?.fullName ?? '';
    final canAnnounce = ref.watch(canAnnounceProvider);
    final types = [
      PostType.update,
      PostType.question,
      PostType.discussion,
      PostType.collaboration,
      if (canAnnounce) PostType.announcement,
    ];
    final length = _body.text.characters.length;
    final tooLong = length > _maxBody;

    return Scaffold(
      backgroundColor: context.at.background,
      body: AtPage(
        child: Column(
          children: [
            AtTopBar(
              title: l10n.cfdComposeTitle,
              onBack: _close,
              backSemanticLabel: l10n.close,
              actions: [
                AtButton(
                  label: l10n.cfdPost,
                  size: AtButtonSize.sm,
                  fullWidth: false,
                  loading: _posting,
                  semanticLabel: ref.watch(isOfflineProvider)
                      ? '${l10n.cfdPost}. ${l10n.stOfflineNeedsConnection}'
                      : null,
                  // Posting needs the server: disabled (and announced) while offline.
                  onPressed: _posting || ref.watch(isOfflineProvider)
                      ? null
                      : _post,
                ),
              ],
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AtSpacing.gutter,
                  0,
                  AtSpacing.gutter,
                  8,
                ),
                child: AtInlineBanner(
                  message: _error!,
                  tone: AtBannerTone.error,
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AtSpacing.gutter,
                  8,
                  AtSpacing.gutter,
                  32,
                ),
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in types)
                        AtChip(
                          label: _typeChip(l10n, t).$1,
                          icon: _typeChip(l10n, t).$2,
                          selected: _type == t,
                          onTap: _posting
                              ? null
                              : () {
                                  setState(() => _type = t);
                                  _touch();
                                },
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AtAvatar(name: name, size: 42),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _body,
                          focusNode: _bodyFocus,
                          enabled: !_posting,
                          minLines: 6,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.sentences,
                          style: AtTextStyles.body.copyWith(
                            color: context.at.ink,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration.collapsed(
                            hintText: l10n.cfdBodyHint,
                            hintStyle: AtTextStyles.body.copyWith(
                              color: context.at.faint,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_media.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final m in _media)
                          AtMediaTile(
                            image: m.file.isImage
                                ? FileImage(File(m.file.path))
                                : null,
                            icon: m.file.isVideo
                                ? LucideIcons.video
                                : LucideIcons.image,
                            state: m.state,
                            progress: m.progress,
                            semanticLabel: m.file.name,
                            onRemove: _posting
                                ? null
                                : () => setState(() => _media.remove(m)),
                            onRetry: () => _upload(m),
                          ),
                      ],
                    ),
                  ],
                  if (_link != null) ...[
                    const SizedBox(height: 12),
                    _LinkChip(
                      url: _link!,
                      onRemove: _posting
                          ? null
                          : () {
                              setState(() => _link = null);
                              _touch();
                            },
                    ),
                  ],
                  const SizedBox(height: 22),
                  AtCard(
                    onTap: _posting ? null : _chooseAudience,
                    color: context.at.softTile,
                    shadow: false,
                    border: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    semanticLabel:
                        '${l10n.cfdAudience}: ${_audienceLabel(l10n)}',
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.cfdAudience,
                                style: AtTextStyles.metaSm.copyWith(
                                  color: context.at.muted,
                                ),
                              ),
                              Text(
                                _audienceLabel(l10n),
                                style: AtTextStyles.cardTitle.copyWith(
                                  color: context.at.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          LucideIcons.chevronRight,
                          size: 18,
                          color: context.at.faint,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: context.at.surface,
                border: Border(top: BorderSide(color: context.at.divider)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AtSpacing.gutter,
                    10,
                    AtSpacing.gutter,
                    10,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          _AttachButton(
                            icon: LucideIcons.image,
                            label: l10n.cfdAttachPhoto,
                            tone: AtTone.primary,
                            onTap: _posting
                                ? null
                                : () => _pick(MediaPickKind.photos),
                          ),
                          const SizedBox(width: 10),
                          _AttachButton(
                            icon: LucideIcons.video,
                            label: l10n.cfdAttachVideo,
                            tone: AtTone.coral,
                            onTap: _posting
                                ? null
                                : () => _pick(MediaPickKind.video),
                          ),
                          const SizedBox(width: 10),
                          _AttachButton(
                            icon: LucideIcons.link,
                            label: l10n.cfdAttachLink,
                            tone: AtTone.violet,
                            onTap: _posting ? null : _addLink,
                          ),
                          const SizedBox(width: 10),
                          _AttachButton(
                            icon: LucideIcons.briefcase,
                            label: l10n.cfdAttachOpportunity,
                            tone: AtTone.warning,
                            // Attaching an opportunity arrives with Opportunities (P1-M9).
                            onTap: () => context.push(
                              Routes.soonPath(
                                'p1',
                                name: l10n.cfdAttachOpportunity,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  LucideIcons.cloudCheck,
                                  size: 14,
                                  color: context.at.muted,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    l10n.cfdDraftSaved,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AtTextStyles.metaSm.copyWith(
                                      color: context.at.muted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.cfdCharCount(length, _maxBody),
                            style: AtTextStyles.metaSm.copyWith(
                              color: tooLong
                                  ? context.at.coralStrong
                                  : context.at.muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachButton extends StatelessWidget {
  const _AttachButton({
    required this.icon,
    required this.label,
    required this.tone,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final AtTone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = tone.colorsOf(context);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Material(
          color: c.bg,
          borderRadius: AtRadii.backButton,
          child: InkWell(
            borderRadius: AtRadii.backButton,
            onTap: onTap,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(icon, size: 20, color: c.fg),
            ),
          ),
        ),
      ),
    );
  }
}

class _LinkChip extends StatelessWidget {
  const _LinkChip({required this.url, required this.onRemove});

  final String url;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.at.softTile,
        borderRadius: AtRadii.card,
        border: Border.all(color: context.at.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
        child: Row(
          children: [
            Icon(LucideIcons.link, size: 16, color: context.at.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                url,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AtTextStyles.bodySm.copyWith(color: context.at.ink),
              ),
            ),
            AtTapTarget(
              onTap: onRemove,
              semanticLabel: l10n.cfdLinkRemove,
              borderRadius: AtRadii.pill,
              child: Icon(LucideIcons.x, size: 18, color: context.at.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkSheet extends StatefulWidget {
  const _LinkSheet({this.initial});

  final String? initial;

  @override
  State<_LinkSheet> createState() => _LinkSheetState();
}

class _LinkSheetState extends State<_LinkSheet> {
  late final _controller = TextEditingController(text: widget.initial ?? '');
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final text = _controller.text.trim();
    final uri = Uri.tryParse(text);
    final ok =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.contains('.');
    if (!ok) {
      setState(() => _error = AppLocalizations.of(context).cfdLinkInvalid);
      return;
    }
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AtTextField(
          controller: _controller,
          hint: l10n.cfdLinkHint,
          helperText: l10n.cfdLinkNote,
          errorText: _error,
          keyboardType: TextInputType.url,
          autofocus: true,
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          onSubmitted: (_) => _add(),
        ),
        const SizedBox(height: 16),
        AtButton(label: l10n.cfdLinkAdd, onPressed: _add),
        if (widget.initial != null) ...[
          const SizedBox(height: 8),
          AtButton(
            label: l10n.cfdLinkRemove,
            variant: AtButtonVariant.tertiary,
            onPressed: () => Navigator.of(context).pop(''),
          ),
        ],
      ],
    );
  }
}

class _AudienceChoice {
  const _AudienceChoice(this.audience, {this.groupId, this.groupName});

  final PostAudience audience;
  final String? groupId;
  final String? groupName;
}

class _AudienceSheet extends ConsumerWidget {
  const _AudienceSheet({required this.audience, required this.groupId});

  final PostAudience audience;
  final String? groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final groups = ref.watch(myGroupsProvider);
    Widget option(
      String title,
      String body,
      IconData icon,
      _AudienceChoice choice,
      bool selected,
    ) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AtRadioCard(
        title: title,
        subtitle: body,
        selected: selected,
        leading: Icon(icon, size: 20, color: context.at.primary),
        onTap: () => Navigator.of(context).pop(choice),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        option(
          l10n.cfdAudMembers,
          l10n.cfdAudMembersBody,
          LucideIcons.users,
          const _AudienceChoice(PostAudience.members),
          audience == PostAudience.members,
        ),
        option(
          l10n.cfdAudPublic,
          l10n.cfdAudPublicBody,
          LucideIcons.globe,
          const _AudienceChoice(PostAudience.public),
          audience == PostAudience.public,
        ),
        option(
          l10n.cfdAudConnections,
          l10n.cfdAudConnectionsBody,
          LucideIcons.userCheck,
          const _AudienceChoice(PostAudience.connections),
          audience == PostAudience.connections,
        ),
        groups.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Padding(
            padding: const EdgeInsets.only(top: 4),
            child: AtInlineBanner(
              message: l10n.cfdAudGroupsFailed,
              tone: AtBannerTone.error,
              action: AtButton(
                label: l10n.retry,
                variant: AtButtonVariant.tertiary,
                size: AtButtonSize.sm,
                fullWidth: false,
                onPressed: () => ref.invalidate(myGroupsProvider),
              ),
            ),
          ),
          data: (list) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (list.isNotEmpty) ...[
                const SizedBox(height: 8),
                Semantics(
                  header: true,
                  child: Text(
                    l10n.cfdAudGroups,
                    style: AtTextStyles.cardTitle.copyWith(
                      color: context.at.ink,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              for (final g in list)
                option(
                  g.name,
                  l10n.cfdAudGroupBody,
                  LucideIcons.usersRound,
                  _AudienceChoice(
                    PostAudience.group,
                    groupId: g.id,
                    groupName: g.name,
                  ),
                  audience == PostAudience.group && groupId == g.id,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
