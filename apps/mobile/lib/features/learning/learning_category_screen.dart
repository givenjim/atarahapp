import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/routing/routes.dart';
import '../discover/discover_common.dart';
import 'learning_common.dart';
import 'learning_providers.dart';
import 'learning_repository.dart';

/// The types that have a chip (Article is found through All and search).
const _chipTypes = [
  LearningContentType.course,
  LearningContentType.tutorial,
  LearningContentType.toolkit,
  LearningContentType.webinar,
  LearningContentType.masterclass,
];

/// One Skill Labs category: its group, its title, how many resources it holds, a chip per type and the cards. Pages in
/// as the member scrolls. A type with nothing in it says so and offers every type.
class LearningCategoryScreen extends ConsumerStatefulWidget {
  const LearningCategoryScreen({super.key, required this.slug, this.type});

  final String slug;
  final LearningContentType? type;

  @override
  ConsumerState<LearningCategoryScreen> createState() =>
      _LearningCategoryScreenState();
}

class _LearningCategoryScreenState
    extends ConsumerState<LearningCategoryScreen> {
  static const _pageSize = 20;

  final _scroll = ScrollController();
  late LearningContentType? _type = widget.type;
  final List<LearningCardDto> _items = [];
  CategoryPage? _first;
  int _total = 0;
  int _page = 1;
  bool _loading = true;
  bool _loadingMore = false;
  bool _moreFailed = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 400) _loadMore();
    });
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  bool get _hasMore => _items.length < _total;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await ref
          .read(learningRepositoryProvider)
          .category(widget.slug, type: _type, limit: _pageSize);
      if (!mounted) return;
      setState(() {
        _first = page;
        _items
          ..clear()
          ..addAll(page.items);
        _total = page.total;
        _page = 1;
        _loading = false;
        _moreFailed = false;
      });
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || !_hasMore) return;
    setState(() {
      _loadingMore = true;
      _moreFailed = false;
    });
    try {
      final next = await ref
          .read(learningRepositoryProvider)
          .category(
            widget.slug,
            type: _type,
            page: _page + 1,
            limit: _pageSize,
          );
      if (!mounted) return;
      setState(() {
        _items.addAll(next.items);
        _total = next.total;
        _page += 1;
        _loadingMore = false;
      });
    } on Object {
      if (mounted) {
        setState(() {
          _loadingMore = false;
          _moreFailed = true;
        });
      }
    }
  }

  void _pick(LearningContentType? t) {
    if (t == _type) return;
    setState(() => _type = t);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final category = _first?.category;
    return Scaffold(
      backgroundColor: context.at.background,
      body: AtPage(
        wash: AtWash.learning,
        child: Column(
          children: [
            AtTopBar(
              onBack: () => context.canPop()
                  ? context.pop()
                  : context.go(Routes.learning),
            ),
            if (category != null)
              _Header(category: category, count: _first!.allTotal),
            if (_first != null) _Chips(selected: _type, onPick: _pick),
            Expanded(child: _content(context, l10n, category)),
          ],
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    AppLocalizations l10n,
    LearningCategoryRefDto? category,
  ) {
    if (_loading && _first == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final error = _error;
    if (error != null && _first == null) {
      if (error is ApiFailure && error.statusCode == 404) {
        return AtEmptyState(
          icon: LucideIcons.searchX,
          title: l10n.lnHubEmptyTitle,
          ctaLabel: l10n.lnBackToLabs,
          onCta: () => context.go(Routes.learning),
        );
      }
      return loadFailure(error, _load, l10n);
    }
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_items.isEmpty) {
      final name = category?.name ?? '';
      return _type == null
          ? AtEmptyState(
              icon: LucideIcons.graduationCap,
              title: l10n.lnCategoryEmptyTitle(name),
              body: l10n.lnCategoryEmptyBody,
            )
          : AtEmptyState(
              icon: labTypeIcon(_type),
              title: l10n.lnTypeEmptyTitle(labTypePlural(l10n, _type), name),
              ctaLabel: l10n.lnTypeEmptyCta,
              onCta: () => _pick(null),
            );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AtSpacing.gutter,
          6,
          AtSpacing.gutter,
          32,
        ),
        itemCount: _items.length + (_hasMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: AtSpacing.listGap),
        itemBuilder: (_, i) {
          if (i >= _items.length) {
            return _moreFailed
                ? AtButton(
                    label: l10n.lnLoadMoreFailed,
                    variant: AtButtonVariant.tertiary,
                    onPressed: _loadMore,
                  )
                : const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: CircularProgressIndicator()),
                  );
          }
          return LabTile(lab: _items[i]);
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.category, required this.count});

  final LearningCategoryRefDto category;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AtSpacing.gutter,
        4,
        AtSpacing.gutter,
        10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AtTag(
            label: groupLabel(l10n, category.group),
            tone: groupTone(category.group),
            icon: groupIcon(category.group),
          ),
          const SizedBox(height: 8),
          Semantics(
            header: true,
            child: Text(
              category.name,
              style: AtTextStyles.tabTitle.copyWith(
                color: context.at.ink,
                fontSize: 26,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.lnResourcesCount(count),
            style: AtTextStyles.meta.copyWith(color: context.at.muted),
          ),
        ],
      ),
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips({required this.selected, required this.onPick});

  final LearningContentType? selected;
  final ValueChanged<LearningContentType?> onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AtSpacing.gutter),
        children: [
          AtChip(
            label: l10n.lnTypeAll,
            selected: selected == null,
            onTap: () => onPick(null),
          ),
          for (final t in _chipTypes) ...[
            const SizedBox(width: 8),
            AtChip(
              label: labTypeLabel(l10n, t),
              selected: selected == t,
              onTap: () => onPick(t),
            ),
          ],
        ],
      ),
    );
  }
}
