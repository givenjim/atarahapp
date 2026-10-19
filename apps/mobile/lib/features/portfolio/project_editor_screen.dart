import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/providers.dart';
import '../../core/routing/routes.dart';
import '../onboarding/onboarding_providers.dart';
import '../profile/profile_providers.dart';
import 'media_seams.dart';
import 'portfolio_common.dart';
import 'portfolio_providers.dart';
import 'portfolio_repository.dart';

const _maxMedia = 10;
const _maxSkills = 10;
const _maxLinks = 5;
final _https = RegExp(r'^https://[^\s/]+\.[^\s/]+', caseSensitive: false);

UpdateProjectDtoCategory _categoryOf(String json) =>
    UpdateProjectDtoCategory.values.firstWhere(
      (c) => c.json == json,
      orElse: () => UpdateProjectDtoCategory.project,
    );

UpdateProjectDtoVisibility _visibilityOf(String json) =>
    UpdateProjectDtoVisibility.values.firstWhere(
      (c) => c.json == json,
      orElse: () => UpdateProjectDtoVisibility.public,
    );

/// A file in the project: already on the server, or still going up.
class _MediaEntry {
  _MediaEntry.local(this.file) : state = AtMediaTileState.uploading;

  _MediaEntry.remote(ProjectMediaDto m)
    : mediaId = m.id,
      kind = m.kind.json,
      thumbnailUrl = m.thumbnailUrl,
      state = switch (m.status) {
        ProjectMediaDtoStatus.ready => AtMediaTileState.ready,
        ProjectMediaDtoStatus.rejected ||
        ProjectMediaDtoStatus.deleted => AtMediaTileState.failed,
        _ => AtMediaTileState.uploading,
      };

  PickedMedia? file;
  String? mediaId;
  String? kind;
  String? thumbnailUrl;
  AtMediaTileState state;
  double progress = 0;
}

class _LinkRow {
  _LinkRow([String label = '', String url = ''])
    : label = TextEditingController(text: label),
      url = TextEditingController(text: url);

  final TextEditingController label;
  final TextEditingController url;
  String? urlError;

  void dispose() {
    label.dispose();
    url.dispose();
  }
}

enum _SaveState { saved, saving, failed }

/// Add or edit a project. Everything is saved as a draft while the member types ("Save draft" also works by
/// hand), and nothing is public until they publish. [projectId] is `new` for a project that does not exist yet:
/// the draft is created on the first change, so opening and leaving leaves nothing behind.
class ProjectEditorScreen extends ConsumerStatefulWidget {
  const ProjectEditorScreen({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<ProjectEditorScreen> createState() =>
      _ProjectEditorScreenState();
}

class _ProjectEditorScreenState extends ConsumerState<ProjectEditorScreen> {
  static const _debounce = Duration(milliseconds: 900);

  late final PortfolioRepository _repo;
  String? _id;
  bool _loading = true;
  String? _loadError;

  final _title = TextEditingController();
  final _role = TextEditingController();
  final _client = TextEditingController();
  final _description = TextEditingController();
  final _outcome = TextEditingController();
  String? _date;
  String _category = 'PROJECT';
  String _visibility = 'PUBLIC';
  bool _featured = false;
  bool _published = false;
  List<TaxonomyItemDto> _skills = [];
  List<CollaboratorDto> _collaborators = [];
  final List<_LinkRow> _links = [];
  final List<_MediaEntry> _media = [];

  Timer? _timer;
  Future<void>? _saving;
  bool _again = false;
  _SaveState _saveState = _SaveState.saved;
  String? _banner;
  String? _titleError;
  bool _busy = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    // Held here because `ref` cannot be used once the screen is being disposed, and the last save runs then.
    _repo = ref.read(portfolioRepositoryProvider);
    if (widget.projectId == 'new') {
      _loading = false;
    } else {
      _id = widget.projectId;
      _load();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    // Whatever is still waiting is written now, so a quick "back" never loses the last edit.
    if (_id != null && _saveState != _SaveState.saved) {
      unawaited(_flushDetached());
    }
    for (final c in [_title, _role, _client, _description, _outcome]) {
      c.dispose();
    }
    for (final l in _links) {
      l.dispose();
    }
    super.dispose();
  }

  Future<void> _flushDetached() async {
    try {
      await _repo.updateProject(_id!, _body());
    } on Object {
      // Nothing to show: the screen is gone. The draft keeps the last successful save.
    }
  }

  Future<void> _load() async {
    try {
      final p = await _repo.myProject(widget.projectId);
      if (_disposed) return;
      setState(() {
        _title.text = p.title;
        _role.text = p.role ?? '';
        _client.text = p.client ?? '';
        _description.text = p.description ?? '';
        _outcome.text = p.outcome ?? '';
        _date = p.projectDate;
        _category = p.category.json ?? 'PROJECT';
        _visibility = p.visibility.json ?? 'PUBLIC';
        _featured = p.featured;
        _published = p.status == ProjectDtoStatus.published;
        _skills = [...p.skills];
        _collaborators = [...p.collaborators];
        _media.addAll(p.media.map(_MediaEntry.remote));
        for (final l in p.links) {
          _links.add(_LinkRow(l.label, l.url));
        }
        _loading = false;
      });
    } on AppFailure catch (e) {
      if (!_disposed) {
        setState(() {
          _loading = false;
          _loadError = e.message;
        });
      }
    }
  }

  // ---- saving ----

  UpdateProjectDto _body() => UpdateProjectDto(
    title: _title.text.trim(),
    role: _role.text.trim(),
    client: _client.text.trim(),
    projectDate: _date ?? '',
    category: _categoryOf(_category),
    description: _description.text.trim(),
    outcome: _outcome.text.trim(),
    featured: _featured,
    visibility: _visibilityOf(_visibility),
    mediaIds: [
      for (final m in _media)
        if (m.mediaId != null && m.state != AtMediaTileState.failed) m.mediaId!,
    ],
    skillIds: [for (final s in _skills) s.id],
    links: [
      for (final l in _links)
        if (l.label.text.trim().isNotEmpty &&
            _https.hasMatch(l.url.text.trim()))
          ProfileLinkInputDto(
            label: l.label.text.trim(),
            url: l.url.text.trim(),
          ),
    ],
  );

  /// Something changed: save soon.
  void _touch() {
    if (_disposed) return;
    setState(() => _saveState = _SaveState.saving);
    _timer?.cancel();
    _timer = Timer(_debounce, _save);
  }

  Future<String> _ensureId() async {
    final id = _id;
    if (id != null) return id;
    final created = await _repo.createProject(title: _title.text.trim());
    _id = created.id;
    return created.id;
  }

  /// Writes the whole form. Calls that arrive while a save is running are folded into one more save after it.
  Future<void> _save() async {
    if (_saving != null) {
      _again = true;
      return _saving;
    }
    final run = _run();
    _saving = run;
    try {
      await run;
    } finally {
      _saving = null;
    }
    if (_again && !_disposed) {
      _again = false;
      await _save();
    }
  }

  Future<void> _run() async {
    if (_disposed) return;
    setState(() => _saveState = _SaveState.saving);
    try {
      final id = await _ensureId();
      final saved = await _repo.updateProject(id, _body());
      if (_disposed) return;
      setState(() {
        _saveState = _SaveState.saved;
        _published = saved.status == ProjectDtoStatus.published;
        _collaborators = [...saved.collaborators];
        _titleError = null;
        _banner = null;
      });
    } on ApiFailure catch (e) {
      if (_disposed) return;
      setState(() {
        _saveState = _SaveState.failed;
        _titleError = e.fieldError('title');
        _banner = e.message;
      });
    } on AppFailure catch (e) {
      if (_disposed) return;
      setState(() {
        _saveState = _SaveState.failed;
        _banner = e.message;
      });
    }
  }

  /// Saves right now (cancelling the wait) and returns whether the draft is safely on the server.
  Future<bool> _flush() async {
    _timer?.cancel();
    if (_saveState == _SaveState.saved && _id != null && _saving == null) {
      return true;
    }
    await _save();
    return _saveState == _SaveState.saved;
  }

  // ---- files ----

  Future<void> _addMedia() async {
    final l10n = AppLocalizations.of(context);
    final kind = await showAtBottomSheet<MediaPickKind>(
      context: context,
      title: l10n.pjAddFiles,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AtListRow(
            title: l10n.pjPickPhotos,
            icon: LucideIcons.image,
            onTap: () => Navigator.of(ctx).pop(MediaPickKind.photos),
          ),
          AtListRow(
            title: l10n.pjPickVideo,
            icon: LucideIcons.video,
            onTap: () => Navigator.of(ctx).pop(MediaPickKind.video),
          ),
          AtListRow(
            title: l10n.pjPickAudio,
            icon: LucideIcons.music,
            onTap: () => Navigator.of(ctx).pop(MediaPickKind.audio),
          ),
        ],
      ),
    );
    if (kind == null || !mounted) return;
    try {
      final picked = await ref
          .read(mediaPickerProvider)
          .pick(kind, limit: _maxMedia - _media.length);
      if (!mounted) return;
      for (final f in picked) {
        final entry = _MediaEntry.local(f);
        setState(() => _media.add(entry));
        unawaited(_upload(entry));
      }
    } on Object {
      if (mounted) setState(() => _banner = l10n.pjPickFailed);
    }
  }

  Future<void> _upload(_MediaEntry e) async {
    final file = e.file;
    if (file == null) return;
    setState(() {
      e.state = AtMediaTileState.uploading;
      e.progress = 0;
    });
    try {
      final id = await _repo.uploadMedia(
        file,
        onProgress: (p) {
          if (!_disposed) setState(() => e.progress = p);
        },
      );
      if (_disposed) return;
      setState(() {
        e.mediaId = id;
        e.state = AtMediaTileState.ready;
      });
      _touch();
    } on AppFailure catch (err) {
      if (!_disposed) {
        setState(() {
          e.state = AtMediaTileState.failed;
          _banner = err.message;
        });
      }
    } on Object {
      if (!_disposed) {
        setState(() {
          e.state = AtMediaTileState.failed;
          _banner = const UnexpectedFailure().message;
        });
      }
    }
  }

  void _removeMedia(_MediaEntry e) {
    setState(() => _media.remove(e));
    _touch();
  }

  // ---- skills, collaborators, links ----

  Future<void> _addSkill() async {
    final l10n = AppLocalizations.of(context);
    final picked = await showAtBottomSheet<TaxonomyItemDto>(
      context: context,
      title: l10n.pjAddSkill,
      builder: (_) => _SkillPicker(taken: {for (final s in _skills) s.id}),
    );
    if (picked == null || !mounted) return;
    setState(() => _skills = [..._skills, picked]);
    _touch();
  }

  Future<void> _addCollaborator() async {
    final l10n = AppLocalizations.of(context);
    final ok = await _flush();
    if (!ok || !mounted) {
      if (mounted && _banner == null) {
        setState(() => _banner = l10n.pjSaveFirst);
      }
      return;
    }
    final updated = await showAtBottomSheet<ProjectDto>(
      context: context,
      title: l10n.pjAddCollaborator,
      builder: (_) => _CollaboratorSheet(projectId: _id!),
    );
    if (updated != null && mounted) {
      setState(() => _collaborators = [...updated.collaborators]);
    }
  }

  Future<void> _removeCollaborator(CollaboratorDto c) async {
    try {
      final updated = await _repo.removeCollaborator(_id!, c.id);
      if (mounted) {
        setState(() => _collaborators = [...updated.collaborators]);
      }
    } on AppFailure catch (e) {
      if (mounted) setState(() => _banner = e.message);
    }
  }

  void _addLink() {
    setState(() => _links.add(_LinkRow()));
  }

  void _removeLink(_LinkRow row) {
    setState(() => _links.remove(row));
    // The field is still on screen for this frame: free it after.
    WidgetsBinding.instance.addPostFrameCallback((_) => row.dispose());
    _touch();
  }

  bool _checkLinks(AppLocalizations l10n) {
    var ok = true;
    for (final l in _links) {
      final url = l.url.text.trim();
      l.urlError = url.isEmpty || !_https.hasMatch(url)
          ? l10n.pjLinkError
          : null;
      if (l.urlError != null) ok = false;
    }
    return ok;
  }

  // ---- actions ----

  Future<void> _saveDraft() async {
    final l10n = AppLocalizations.of(context);
    final ok = await _flush();
    if (!mounted) return;
    if (ok) {
      ref.invalidate(myProjectsProvider);
      setState(() => _banner = null);
      ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();
      if (context.canPop()) context.pop();
    } else {
      setState(() => _banner ??= l10n.pjSaveFailed);
    }
  }

  Future<void> _preview() async {
    final ok = await _flush();
    if (ok && mounted && _id != null) {
      await context.push(Routes.projectPath(_id!));
    }
  }

  Future<void> _publish() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _banner = null;
      _titleError = _title.text.trim().length < 2 ? l10n.pjTitleError : null;
    });
    if (_titleError != null || !_checkLinks(l10n)) {
      setState(() {});
      return;
    }
    setState(() => _busy = true);
    try {
      if (!await _flush()) return;
      if (!_published) {
        await _repo.publishProject(_id!);
        ref.read(analyticsProvider).track('project_published');
      }
      ref.invalidate(myProjectsProvider);
      ref.invalidate(myProfileProvider);
      ref.invalidate(myProjectProvider(_id!));
      if (!mounted) return;
      if (context.canPop()) context.pop();
    } on ApiFailure catch (e) {
      if (mounted) {
        setState(() {
          _titleError = e.fieldError('title');
          _banner = e.message;
        });
      }
    } on AppFailure catch (e) {
      if (mounted) setState(() => _banner = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final ok = await confirmSheet(
      context,
      title: l10n.pjDeleteTitle,
      body: l10n.pjDeleteBody,
      actionLabel: l10n.pjDelete,
    );
    if (!ok || !mounted || _id == null) return;
    setState(() => _busy = true);
    try {
      _timer?.cancel();
      await _repo.deleteProject(_id!);
      // Nothing left to save: stop the exit save from recreating a request for a deleted project.
      _saveState = _SaveState.saved;
      ref.invalidate(myProjectsProvider);
      ref.invalidate(myProfileProvider);
      if (mounted && context.canPop()) context.pop();
    } on AppFailure catch (e) {
      if (mounted) setState(() => _banner = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Saves what is waiting, then goes back. Stays put (showing the problem) when the save did not work.
  Future<void> _leave() async {
    final ok = await _flush();
    if (ok && mounted && context.canPop()) context.pop();
  }

  // ---- view ----

  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(top: 22, bottom: 8),
    child: Semantics(
      header: true,
      child: Text(
        text,
        style: AtTextStyles.cardTitle.copyWith(color: AtColors.ink),
      ),
    ),
  );

  String _statusText(AppLocalizations l10n) => switch (_saveState) {
    _SaveState.saved => l10n.pjSaved,
    _SaveState.saving => l10n.pjSaving,
    _SaveState.failed => l10n.pjSaveFailed,
  };

  ImageProvider? _imageFor(_MediaEntry e) {
    final file = e.file;
    if (file != null && file.isImage) return FileImage(File(file.path));
    final url = e.thumbnailUrl;
    if (url != null) return ref.watch(avatarImageProvider)(url);
    return null;
  }

  IconData _iconFor(_MediaEntry e) {
    final kind = e.file == null
        ? e.kind
        : e.file!.isVideo
        ? 'VIDEO'
        : e.file!.isAudio
        ? 'AUDIO'
        : 'IMAGE';
    return switch (kind) {
      'VIDEO' => LucideIcons.video,
      'AUDIO' => LucideIcons.music,
      _ => LucideIcons.image,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: _saveState == _SaveState.saved || _id == null && !_dirtyNew,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_leave());
      },
      child: PortfolioScaffold(
        title: widget.projectId == 'new' && _id == null
            ? l10n.pjAddTitle
            : l10n.pjEditTitle,
        onBack: () => unawaited(_leave()),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
            ? Padding(
                padding: const EdgeInsets.all(AtSpacing.gutter),
                child: AtErrorState(
                  title: l10n.pfLoadFailed,
                  body: _loadError!,
                  ctaLabel: l10n.retry,
                  onCta: () {
                    setState(() {
                      _loading = true;
                      _loadError = null;
                    });
                    _load();
                  },
                ),
              )
            : _form(l10n),
      ),
    );
  }

  /// A brand-new project that the member has started filling in (so leaving needs a save).
  bool get _dirtyNew =>
      _title.text.isNotEmpty ||
      _description.text.isNotEmpty ||
      _media.isNotEmpty;

  Widget _form(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AtSpacing.gutter,
        4,
        AtSpacing.gutter,
        AtSpacing.xl,
      ),
      children: [
        Text(
          l10n.pjIntro,
          style: AtTextStyles.bodySm.copyWith(color: AtColors.muted),
        ),
        const SizedBox(height: 8),
        Semantics(
          liveRegion: true,
          child: Text(
            _statusText(l10n),
            style: AtTextStyles.meta.copyWith(
              color: _saveState == _SaveState.failed
                  ? AtColors.pinkStrong
                  : AtColors.muted,
            ),
          ),
        ),
        if (_banner != null) ...[
          const SizedBox(height: 12),
          AtInlineBanner(message: _banner!, tone: AtBannerTone.error),
        ],
        _heading(l10n.pjFilesHeading),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final e in _media)
              AtMediaTile(
                image: _imageFor(e),
                icon: _iconFor(e),
                state: e.state,
                progress: e.progress,
                semanticLabel: l10n.pjFileAlt,
                onRemove: () => _removeMedia(e),
                onRetry: e.file == null ? null : () => _upload(e),
              ),
          ],
        ),
        if (_media.length < _maxMedia) ...[
          const SizedBox(height: 12),
          AtUploadZone(
            label: l10n.pjAddFiles,
            hint: l10n.pjFilesHint(_maxMedia),
            height: 96,
            onTap: _addMedia,
          ),
        ],
        const SizedBox(height: 20),
        AtTextField(
          key: const ValueKey('pjTitleLabel'),
          label: l10n.pjTitleLabel,
          controller: _title,
          maxLength: 120,
          errorText: _titleError,
          onChanged: (_) => _touch(),
        ),
        const SizedBox(height: 12),
        AtTextField(
          key: const ValueKey('pjRoleLabel'),
          label: l10n.pjRoleLabel,
          controller: _role,
          maxLength: 80,
          onChanged: (_) => _touch(),
        ),
        const SizedBox(height: 12),
        AtTextField(
          key: const ValueKey('pjClientLabel'),
          label: l10n.pjClientLabel,
          controller: _client,
          maxLength: 80,
          onChanged: (_) => _touch(),
        ),
        const SizedBox(height: 12),
        DateField(
          key: const ValueKey('pjDateLabel'),
          label: l10n.pjDateLabel,
          value: _date,
          onChanged: (v) {
            setState(() => _date = v);
            _touch();
          },
        ),
        _heading(l10n.pjCategoryHeading),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in projectCategories)
              AtChip(
                label: categoryLabel(l10n, c),
                selected: _category == c,
                onTap: () {
                  setState(() => _category = c);
                  _touch();
                },
              ),
          ],
        ),
        const SizedBox(height: 16),
        AtTextField(
          key: const ValueKey('pjDescriptionLabel'),
          label: l10n.pjDescriptionLabel,
          controller: _description,
          minLines: 4,
          maxLines: 8,
          maxLength: 2000,
          showCounter: true,
          onChanged: (_) => _touch(),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AtButton(
            label: l10n.pjHelpDescribe,
            variant: AtButtonVariant.tertiary,
            size: AtButtonSize.sm,
            icon: LucideIcons.sparkles,
            // The assistant arrives with the AI phase; until then it opens its labelled screen.
            onPressed: () =>
                context.push(Routes.soonPath('p3', name: l10n.pjHelpDescribe)),
          ),
        ),
        const SizedBox(height: 12),
        AtTextField(
          key: const ValueKey('pjOutcomeLabel'),
          label: l10n.pjOutcomeLabel,
          hint: l10n.pjOutcomeHint,
          controller: _outcome,
          minLines: 2,
          maxLines: 4,
          maxLength: 500,
          onChanged: (_) => _touch(),
        ),
        _heading(l10n.pjSkillsHeading),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in _skills)
              AtChip(
                label: s.name,
                kind: AtChipKind.removable,
                removeSemanticLabel: l10n.pjRemoveNamed(s.name),
                onRemove: () {
                  setState(
                    () => _skills = [
                      for (final x in _skills)
                        if (x.id != s.id) x,
                    ],
                  );
                  _touch();
                },
              ),
            if (_skills.length < _maxSkills)
              AtChip(
                label: l10n.pjAddSkill,
                icon: LucideIcons.plus,
                onTap: _addSkill,
              ),
          ],
        ),
        _heading(l10n.pjCollaborators),
        if (_collaborators.isNotEmpty)
          AtCard(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (final (i, c) in _collaborators.indexed)
                  AtListRow(
                    title: c.name,
                    subtitle: [
                      if (c.role != null) c.role!,
                      if (c.status == CollaboratorDtoStatus.pending)
                        l10n.pjCollabPending,
                    ].join(' · '),
                    icon: LucideIcons.user,
                    showChevron: false,
                    showDivider: i < _collaborators.length - 1,
                    trailing: AtIconButton(
                      icon: LucideIcons.x,
                      semanticLabel: l10n.pjRemoveNamed(c.name),
                      onPressed: () => _removeCollaborator(c),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AtChip(
            label: l10n.pjAddCollaborator,
            icon: LucideIcons.userPlus,
            onTap: _addCollaborator,
          ),
        ),
        _heading(l10n.pjLinks),
        for (final row in _links)
          Padding(
            key: ObjectKey(row),
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: AtTextField(
                    key: const ValueKey('pjLinkLabel'),
                    label: l10n.pjLinkLabel,
                    controller: row.label,
                    maxLength: 30,
                    onChanged: (_) => _touch(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: AtTextField(
                    key: const ValueKey('pjLinkUrl'),
                    label: l10n.pjLinkUrl,
                    hint: 'https://',
                    controller: row.url,
                    keyboardType: TextInputType.url,
                    errorText: row.urlError,
                    onChanged: (_) {
                      if (row.urlError != null) {
                        setState(() => row.urlError = null);
                      }
                      _touch();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 22),
                  child: AtIconButton(
                    icon: LucideIcons.trash2,
                    semanticLabel: l10n.pjRemoveLink,
                    onPressed: () => _removeLink(row),
                  ),
                ),
              ],
            ),
          ),
        if (_links.length < _maxLinks)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AtChip(
              label: l10n.pjAddLink,
              icon: LucideIcons.plus,
              onTap: _addLink,
            ),
          ),
        _heading(l10n.pjVisibilityHeading),
        AtSegmented(
          labels: [
            for (final v in projectVisibilities)
              projectVisibilityLabel(l10n, v),
          ],
          selectedIndex: projectVisibilities.indexOf(_visibility),
          onChanged: (i) {
            setState(() => _visibility = projectVisibilities[i]);
            _touch();
          },
        ),
        const SizedBox(height: 4),
        Text(
          l10n.pjVisibilityNote,
          style: AtTextStyles.meta.copyWith(color: AtColors.muted),
        ),
        const SizedBox(height: 8),
        ToggleRow(
          label: l10n.pjFeaturedToggle,
          value: _featured,
          onChanged: (v) {
            setState(() => _featured = v);
            _touch();
          },
        ),
        const SizedBox(height: 20),
        AtButton(
          label: _published ? l10n.pjSaveChanges : l10n.pjPublish,
          loading: _busy,
          onPressed: _busy ? null : _publish,
        ),
        if (!_published) ...[
          const SizedBox(height: 8),
          AtButton(
            label: l10n.pjSaveDraft,
            variant: AtButtonVariant.secondary,
            onPressed: _busy ? null : _saveDraft,
          ),
        ],
        const SizedBox(height: 8),
        AtButton(
          label: l10n.pjPreview,
          variant: AtButtonVariant.tertiary,
          icon: LucideIcons.eye,
          onPressed: _busy ? null : _preview,
        ),
        if (_id != null) ...[
          const SizedBox(height: 8),
          AtButton(
            label: l10n.pjDelete,
            variant: AtButtonVariant.destructive,
            onPressed: _busy ? null : _delete,
          ),
        ],
      ],
    );
  }
}

/// Searches the skill list and returns the chosen one.
class _SkillPicker extends ConsumerStatefulWidget {
  const _SkillPicker({required this.taken});

  final Set<String> taken;

  @override
  ConsumerState<_SkillPicker> createState() => _SkillPickerState();
}

class _SkillPickerState extends ConsumerState<_SkillPicker> {
  final _search = TextEditingController();
  List<TaxonomyItemDto>? _choices;
  String? _error;

  @override
  void initState() {
    super.initState();
    ref
        .read(portfolioRepositoryProvider)
        .skillChoices()
        .then((list) {
          if (mounted) setState(() => _choices = list);
        })
        .catchError((Object e) {
          if (mounted) {
            setState(() => _error = e is AppFailure ? e.message : null);
          }
        });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final q = _search.text.trim().toLowerCase();
    final shown = [
      for (final c in _choices ?? const <TaxonomyItemDto>[])
        if (!widget.taken.contains(c.id) &&
            (q.isEmpty || c.name.toLowerCase().contains(q)))
          c,
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error != null) ...[
          AtInlineBanner(message: _error!, tone: AtBannerTone.error),
          const SizedBox(height: 12),
        ],
        AtTextField(
          key: const ValueKey('skSearchLabel'),
          label: l10n.skSearchLabel,
          controller: _search,
          prefixIcon: LucideIcons.search,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        if (_choices == null && _error == null)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (shown.isEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              l10n.skNoMatches,
              style: AtTextStyles.bodySm.copyWith(color: AtColors.muted),
            ),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final c in shown.take(60))
                  AtListRow(
                    title: c.name,
                    showChevron: false,
                    onTap: () => Navigator.of(context).pop(c),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Tag a member (they must accept) or someone who is not on Atarah (shown at once).
class _CollaboratorSheet extends ConsumerStatefulWidget {
  const _CollaboratorSheet({required this.projectId});

  final String projectId;

  @override
  ConsumerState<_CollaboratorSheet> createState() => _CollaboratorSheetState();
}

class _CollaboratorSheetState extends ConsumerState<_CollaboratorSheet> {
  final _search = TextEditingController();
  final _name = TextEditingController();
  final _role = TextEditingController();
  int _mode = 0;
  Timer? _timer;
  List<MemberHitDto> _hits = const [];
  bool _searching = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _timer?.cancel();
    _search.dispose();
    _name.dispose();
    _role.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    _timer?.cancel();
    if (q.trim().length < 2) {
      setState(() => _hits = const []);
      return;
    }
    _timer = Timer(const Duration(milliseconds: 350), () async {
      setState(() => _searching = true);
      try {
        final hits = await ref
            .read(portfolioRepositoryProvider)
            .searchMembers(q.trim());
        if (mounted) setState(() => _hits = hits);
      } on AppFailure catch (e) {
        if (mounted) setState(() => _error = e.message);
      } finally {
        if (mounted) setState(() => _searching = false);
      }
    });
  }

  Future<void> _add({String? userId, String? name}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final role = _role.text.trim();
      final updated = await ref
          .read(portfolioRepositoryProvider)
          .addCollaborator(
            widget.projectId,
            AddCollaboratorDto(
              userId: userId,
              name: name,
              role: role.isEmpty ? null : role,
            ),
          );
      if (mounted) Navigator.of(context).pop(updated);
    } on AppFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AtSegmented(
          labels: [l10n.pjCollabMember, l10n.pjCollabName],
          selectedIndex: _mode,
          onChanged: (i) => setState(() => _mode = i),
        ),
        const SizedBox(height: 12),
        if (_error != null) ...[
          AtInlineBanner(message: _error!, tone: AtBannerTone.error),
          const SizedBox(height: 12),
        ],
        AtTextField(label: l10n.pjCollabRole, controller: _role, maxLength: 60),
        const SizedBox(height: 12),
        if (_mode == 0) ...[
          AtTextField(
            key: const ValueKey('pjCollabSearch'),
            label: l10n.pjCollabSearch,
            controller: _search,
            prefixIcon: LucideIcons.search,
            onChanged: _onSearch,
          ),
          const SizedBox(height: 8),
          if (_searching)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_hits.isEmpty && _search.text.trim().length >= 2)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                l10n.pjCollabNoMembers,
                style: AtTextStyles.bodySm.copyWith(color: AtColors.muted),
              ),
            )
          else
            for (final h in _hits)
              AtListRow(
                title: h.displayName,
                subtitle: [
                  h.discipline,
                  '@${h.handle}',
                ].whereType<String>().join(' · '),
                icon: LucideIcons.user,
                showChevron: false,
                onTap: _busy ? null : () => _add(userId: h.userId),
              ),
        ] else ...[
          AtTextField(
            key: const ValueKey('pjCollabNameLabel'),
            label: l10n.pjCollabNameLabel,
            controller: _name,
            maxLength: 60,
          ),
          const SizedBox(height: 16),
          AtButton(
            label: l10n.pjCollabAddName,
            loading: _busy,
            onPressed: _name.text.trim().length < 2 && !_busy
                ? () => setState(() => _error = l10n.pjCollabNameError)
                : () => _add(name: _name.text.trim()),
          ),
        ],
      ],
    );
  }
}
