import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/routing/routes.dart';
import 'discover_common.dart';
import 'discover_providers.dart';

/// Every published article, newest first.
class ArticlesScreen extends ConsumerStatefulWidget {
  const ArticlesScreen({super.key});

  @override
  ConsumerState<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends ConsumerState<ArticlesScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 400) {
        ref.read(articleListProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(articleListProvider);
    return Scaffold(
      backgroundColor: AtColors.white,
      body: SafeArea(
        child: Column(
          children: [
            AtTopBar(
              title: l10n.dcArticles,
              onBack: () =>
                  context.canPop() ? context.pop() : context.go('/home'),
              backSemanticLabel: l10n.back,
            ),
            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => loadFailure(
                  e,
                  () => ref.invalidate(articleListProvider),
                  l10n,
                ),
                data: (page) => page.items.isEmpty
                    ? AtEmptyState(
                        icon: LucideIcons.bookOpen,
                        title: l10n.dcNoArticles,
                        body: l10n.dcNoArticlesBody,
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(articleListProvider);
                          await ref.read(articleListProvider.future);
                        },
                        child: ListView.separated(
                          controller: _scroll,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            AtSpacing.gutter,
                            8,
                            AtSpacing.gutter,
                            32,
                          ),
                          itemCount: page.items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AtSpacing.listGap),
                          itemBuilder: (context, i) => ArticleTile(
                            article: page.items[i],
                            onTap: () => context.push(
                              Routes.articlePath(page.items[i].slug),
                            ),
                          ),
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
