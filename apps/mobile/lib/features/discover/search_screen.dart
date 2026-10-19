import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/providers.dart';
import 'discover_common.dart';
import 'discover_providers.dart';
import 'discover_repository.dart';

const _minChars = 2;
const _debounce = Duration(milliseconds: 350);

/// Search: a focused field, recent searches while it is empty, then results grouped by kind with counts.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  late final DiscoverRepository _repo = ref.read(discoverRepositoryProvider);
  Timer? _timer;

  String _query = '';
  SearchKind? _kind;
  bool _loading = false;
  Object? _error;
  List<SearchGroupDto>? _groups;
  // The "all" view's counts, kept while one kind is open so the tabs always show them.
  Map<String, int> _counts = {};
  int _token = 0;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 300) _loadMore();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _changed(String raw) {
    _timer?.cancel();
    final q = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    setState(() {
      _query = q;
      _kind = null;
      if (q.length < _minChars) {
        _groups = null;
        _error = null;
        _loading = false;
        _counts = {};
        _token++;
      }
    });
    if (q.length >= _minChars) _timer = Timer(_debounce, _run);
  }

  Future<void> _run() async {
    final q = _query;
    final kind = _kind;
    final token = ++_token;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final groups = await _repo.search(q, kind: kind);
      if (!mounted || token != _token) return;
      setState(() {
        _groups = groups;
        if (kind == null) {
          _counts = {
            for (final g in groups) g.type.json ?? '': g.count.toInt(),
          };
        }
        _loading = false;
      });
    } on Object catch (e) {
      if (!mounted || token != _token) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    final kind = _kind;
    final groups = _groups;
    if (kind == null || groups == null || groups.isEmpty || _loadingMore) {
      return;
    }
    final g = groups.first;
    if (g.items.length >= g.count) return;
    _loadingMore = true;
    final token = _token;
    try {
      final page = g.items.length ~/ 20 + 1;
      final next = await _repo.search(_query, kind: kind, page: page);
      if (!mounted || token != _token || next.isEmpty) return;
      setState(() {
        _groups = [
          SearchGroupDto(
            type: g.type,
            count: next.first.count,
            items: [...g.items, ...next.first.items],
          ),
        ];
      });
    } on Object {
      // Scrolling again tries again.
    } finally {
      _loadingMore = false;
    }
  }

  void _pick(SearchKind? kind) {
    setState(() => _kind = kind);
    _run();
  }

  /// Remembers what was searched for, then opens the result.
  Future<void> _open(String path) async {
    unawaited(_remember());
    if (!mounted) return;
    await context.push(path);
  }

  Future<void> _remember() async {
    if (_query.length < _minChars) return;
    try {
      await _repo.recordSearch(_query);
      ref.invalidate(recentSearchesProvider);
      ref.read(analyticsProvider).track('search_submitted', {
        'kind': _kind?.name ?? 'all',
      });
    } on Object {
      // A search that could not be remembered still worked.
    }
  }

  void _useRecent(String q) {
    _controller.text = q;
    _controller.selection = TextSelection.collapsed(offset: q.length);
    _changed(q);
    _timer?.cancel();
    _run();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final searching = _query.length >= _minChars;
    return Scaffold(
      backgroundColor: AtColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, AtSpacing.gutter, 8),
              child: Row(
                children: [
                  AtIconButton(
                    icon: LucideIcons.arrowLeft,
                    semanticLabel: l10n.back,
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AtTextField(
                      key: const ValueKey('search-field'),
                      controller: _controller,
                      hint: l10n.dcSearchHint,
                      autofocus: true,
                      prefixIcon: LucideIcons.search,
                      textInputAction: TextInputAction.search,
                      onChanged: _changed,
                      onSubmitted: (_) {
                        _timer?.cancel();
                        if (searching) _run();
                      },
                      suffix: _controller.text.isEmpty
                          ? null
                          : GestureDetector(
                              onTap: () {
                                _controller.clear();
                                _changed('');
                              },
                              child: Semantics(
                                button: true,
                                label: l10n.dcClearSearch,
                                excludeSemantics: true,
                                child: const Icon(
                                  LucideIcons.x,
                                  size: 18,
                                  color: AtColors.muted,
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            if (searching) _Tabs(counts: _counts, kind: _kind, onPick: _pick),
            Expanded(
              child: searching
                  ? _results(l10n)
                  : _Recent(onPick: _useRecent, shortQuery: _query.isNotEmpty),
            ),
          ],
        ),
      ),
    );
  }

  Widget _results(AppLocalizations l10n) {
    if (_error != null) return loadFailure(_error!, _run, l10n);
    final groups = _groups;
    if (groups == null || (_loading && groups.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }
    final total = groups.fold<int>(0, (n, g) => n + g.count.toInt());
    if (total == 0) {
      return AtEmptyState(
        icon: LucideIcons.searchX,
        title: l10n.dcNoResults(_query),
        body: l10n.dcNoResultsBody,
      );
    }
    return ListView(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(
        AtSpacing.gutter,
        8,
        AtSpacing.gutter,
        32,
      ),
      children: [
        for (final g in groups)
          if (g.items.isNotEmpty) ...[
            AtSectionHeader(
              title: _groupTitle(l10n, g.type),
              compact: true,
              onSeeAll: _kind == null && g.count > g.items.length
                  ? () => _pick(_kindOf(g.type))
                  : null,
              seeAllLabel: l10n.dcSeeAllCount(g.count.toInt()),
            ),
            const SizedBox(height: 8),
            for (final hit in g.items) ...[
              _HitRow(hit: hit, onTap: () => _open(hit.path)),
              const SizedBox(height: AtSpacing.listGap),
            ],
            const SizedBox(height: AtSpacing.sectionGap),
          ],
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

String _groupTitle(AppLocalizations l10n, SearchGroupDtoType t) => switch (t) {
  SearchGroupDtoType.articles => l10n.dcArticles,
  _ => l10n.dcCreatives,
};

SearchKind? _kindOf(SearchGroupDtoType t) => switch (t) {
  SearchGroupDtoType.creatives => SearchKind.creatives,
  SearchGroupDtoType.articles => SearchKind.articles,
  _ => null,
};

class _Tabs extends StatelessWidget {
  const _Tabs({required this.counts, required this.kind, required this.onPick});

  final Map<String, int> counts;
  final SearchKind? kind;
  final ValueChanged<SearchKind?> onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final all = counts.values.fold<int>(0, (a, b) => a + b);
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AtSpacing.gutter),
        children: [
          AtChip(
            label: l10n.dcAllCount(all),
            selected: kind == null,
            onTap: () => onPick(null),
          ),
          const SizedBox(width: 8),
          AtChip(
            label: l10n.dcCreativesTab(counts['creatives'] ?? 0),
            selected: kind == SearchKind.creatives,
            onTap: () => onPick(SearchKind.creatives),
          ),
          const SizedBox(width: 8),
          AtChip(
            label: l10n.dcArticlesTab(counts['articles'] ?? 0),
            selected: kind == SearchKind.articles,
            onTap: () => onPick(SearchKind.articles),
          ),
        ],
      ),
    );
  }
}

class _HitRow extends StatelessWidget {
  const _HitRow({required this.hit, required this.onTap});

  final SearchHitDto hit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final person = hit.type == SearchHitDtoType.creatives;
    return Semantics(
      button: true,
      label: [
        hit.title,
        if (hit.verified) l10n.dcVerified,
        ?hit.subtitle,
      ].join(', '),
      excludeSemantics: true,
      onTap: onTap,
      child: AtCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Portrait(
              name: hit.title,
              url: hit.imageUrl,
              size: 48,
              rounded: !person,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          hit.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AtTextStyles.chip.copyWith(
                            color: AtColors.ink,
                          ),
                        ),
                      ),
                      if (hit.verified) ...[
                        const SizedBox(width: 6),
                        const AtVerifiedTick(size: 14),
                      ],
                    ],
                  ),
                  if (hit.subtitle != null)
                    Text(
                      hit.subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AtTextStyles.metaSm.copyWith(
                        color: AtColors.muted,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Recent extends ConsumerWidget {
  const _Recent({required this.onPick, required this.shortQuery});

  final ValueChanged<String> onPick;
  final bool shortQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final recent = ref.watch(recentSearchesProvider).value ?? const [];
    final repo = ref.read(discoverRepositoryProvider);

    Future<void> run(Future<void> Function() action) async {
      try {
        await action();
      } on AppFailure {
        // Leave the list as it is; it refreshes below either way.
      }
      ref.invalidate(recentSearchesProvider);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AtSpacing.gutter,
        8,
        AtSpacing.gutter,
        32,
      ),
      children: [
        if (shortQuery)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              l10n.dcSearchTooShort,
              style: AtTextStyles.bodySm.copyWith(color: AtColors.muted),
            ),
          ),
        if (recent.isNotEmpty) ...[
          AtSectionHeader(
            title: l10n.dcRecent,
            compact: true,
            onSeeAll: () => run(repo.clearRecentSearches),
            seeAllLabel: l10n.dcClearAll,
          ),
          const SizedBox(height: 4),
          for (final r in recent)
            _RecentRow(
              query: r.query,
              onTap: () => onPick(r.query),
              onRemove: () => run(() => repo.removeRecentSearch(r.id)),
            ),
        ] else if (!shortQuery)
          AtEmptyState(
            icon: LucideIcons.search,
            title: l10n.dcSearchEmptyTitle,
            body: l10n.dcSearchEmptyBody,
          ),
      ],
    );
  }
}

/// One remembered search: tap the words to search again, or the cross to forget it. They are separate targets so
/// each can be reached with a screen reader.
class _RecentRow extends StatelessWidget {
  const _RecentRow({
    required this.query,
    required this.onTap,
    required this.onRemove,
  });

  final String query;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            label: query,
            excludeSemantics: true,
            onTap: onTap,
            child: InkWell(
              onTap: onTap,
              borderRadius: AtRadii.input,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.history,
                      size: 18,
                      color: AtColors.muted,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        query,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AtTextStyles.body.copyWith(color: AtColors.ink),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AtIconButton(
          icon: LucideIcons.x,
          semanticLabel: l10n.dcRemoveRecent(query),
          variant: AtIconButtonVariant.floating,
          onPressed: onRemove,
        ),
      ],
    );
  }
}
