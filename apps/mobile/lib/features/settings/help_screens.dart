import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/routing/routes.dart';
import '../account/account_common.dart';
import '../account/account_providers.dart';
import '../discover/discover_common.dart';
import '../profile/profile_providers.dart' show openLinkProvider;

/// The slug of the article "Safety centre" opens (report, block, mute).
const safetyCentreSlug = 'safety-centre';

/// Help: search, the safety centre, frequently asked questions and a way to reach support.
class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  final _search = TextEditingController();
  String _q = '';
  String? _open;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _chat(HelpContactDto c) async {
    await ref.read(openLinkProvider)(
      Uri(
        scheme: 'mailto',
        path: c.email,
        queryParameters: {'subject': 'Atarah support'},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(helpSearchProvider(_q));
    final contact = ref.watch(helpContactProvider);
    return SubPage(
      title: l10n.settingsHelp,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AtSpacing.gutter,
          8,
          AtSpacing.gutter,
          32,
        ),
        children: [
          AtTextField(
            hint: l10n.stHelpSearch,
            controller: _search,
            prefixIcon: LucideIcons.search,
            textInputAction: TextInputAction.search,
            onSubmitted: (v) => setState(() => _q = v.trim()),
            onChanged: (v) {
              if (v.trim().isEmpty && _q.isNotEmpty) setState(() => _q = '');
            },
          ),
          const SizedBox(height: 14),
          if (_q.isEmpty)
            AtListRow(
              title: l10n.stSafetyCentre,
              subtitle: l10n.stSafetyCentreBody,
              icon: LucideIcons.shieldCheck,
              tone: AtTone.success,
              onTap: () =>
                  context.push(Routes.helpArticlePath(safetyCentreSlug)),
            ),
          async.when(
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 16),
              child: AtSkeleton(height: 120, radius: 16),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.only(top: 16),
              child: loadFailure(
                e,
                () => ref.invalidate(helpSearchProvider(_q)),
                l10n,
              ),
            ),
            data: (r) {
              if (_q.isNotEmpty && r.articles.isEmpty && r.faq.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: AtEmptyState(
                    icon: LucideIcons.searchX,
                    title: l10n.stHelpNoResults,
                    body: l10n.stHelpNoResultsBody,
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (r.articles.isNotEmpty) ...[
                    GroupLabel(l10n.stHelpArticles),
                    AtCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          for (final (i, a) in r.articles.indexed)
                            AtListRow(
                              title: a.title,
                              subtitle: a.summary,
                              showDivider: i < r.articles.length - 1,
                              onTap: () =>
                                  context.push(Routes.helpArticlePath(a.slug)),
                            ),
                        ],
                      ),
                    ),
                  ],
                  if (r.faq.isNotEmpty) ...[
                    GroupLabel(l10n.stFaq),
                    for (final f in r.faq) ...[
                      _FaqTile(
                        faq: f,
                        open: _open == f.id,
                        onTap: () =>
                            setState(() => _open = _open == f.id ? null : f.id),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ],
              );
            },
          ),
          GroupLabel(l10n.stStillNeedHelp),
          contact.when(
            loading: () => const AtSkeleton(height: 70, radius: 16),
            error: (e, _) => AtInlineBanner(
              message: failureMessage(e),
              tone: AtBannerTone.error,
            ),
            data: (c) => AtListRow(
              title: l10n.stChatWithUs,
              subtitle: c.note,
              icon: LucideIcons.messageCircle,
              tone: AtTone.indigo,
              onTap: () => _chat(c),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.faq, required this.open, required this.onTap});

  final FaqDto faq;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AtCard(
      onTap: onTap,
      semanticLabel: faq.question,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  faq.question,
                  style: AtTextStyles.cardTitle.copyWith(color: context.at.ink),
                ),
              ),
              Icon(
                open ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                size: 18,
                color: context.at.muted,
              ),
            ],
          ),
          if (open) ...[
            const SizedBox(height: 8),
            Text(
              faq.answer,
              style: AtTextStyles.bodySm.copyWith(color: context.at.body),
            ),
          ],
        ],
      ),
    );
  }
}

/// One help article.
class HelpArticleScreen extends ConsumerWidget {
  const HelpArticleScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(helpArticleProvider(slug));
    return SubPage(
      title: async.value?.title ?? l10n.settingsHelp,
      backTo: Routes.help,
      child: async.when(
        loading: () => const AtLoadingBody(),
        error: (e, _) => loadFailure(
          e,
          () => ref.invalidate(helpArticleProvider(slug)),
          l10n,
        ),
        data: (a) => ListView(
          padding: const EdgeInsets.fromLTRB(
            AtSpacing.gutter,
            8,
            AtSpacing.gutter,
            32,
          ),
          children: [
            Text(
              a.summary,
              style: AtTextStyles.body.copyWith(color: context.at.body),
            ),
            const SizedBox(height: 16),
            for (final b in a.blocks) _Block(block: b),
          ],
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.block});

  final HelpBlockDto block;

  @override
  Widget build(BuildContext context) {
    final text = block.text ?? '';
    switch (block.type) {
      case HelpBlockDtoType.heading:
        return Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: Semantics(
            header: true,
            child: Text(
              text,
              style: AtTextStyles.sectionTitleSm.copyWith(
                color: context.at.ink,
              ),
            ),
          ),
        );
      case HelpBlockDtoType.callout:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: AtCard(
            color: context.at.primaryTintFaint,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (block.title != null)
                  Text(
                    block.title!,
                    style: AtTextStyles.cardTitle.copyWith(
                      color: context.at.ink,
                    ),
                  ),
                Text(
                  text,
                  style: AtTextStyles.bodySm.copyWith(color: context.at.body),
                ),
              ],
            ),
          ),
        );
      case HelpBlockDtoType.quote:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '“$text”${block.attribution == null ? '' : ' — ${block.attribution}'}',
            style: AtTextStyles.body.copyWith(
              color: context.at.body,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      default:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            text,
            style: AtTextStyles.body.copyWith(color: context.at.body),
          ),
        );
    }
  }
}

// ---- legal ------------------------------------------------------------------------------------------------------

String legalTitle(AppLocalizations l10n, LegalSummaryDto d) => d.title;

/// The legal documents: each with its version, and a "DRAFT" label while it is still pending legal review.
class LegalListScreen extends ConsumerWidget {
  const LegalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(legalListProvider);
    return SubPage(
      title: l10n.settingsLegal,
      child: async.when(
        loading: () => const AtLoadingBody(),
        error: (e, _) =>
            loadFailure(e, () => ref.invalidate(legalListProvider), l10n),
        data: (docs) {
          if (docs.isEmpty) {
            return AtEmptyState(
              icon: LucideIcons.fileText,
              title: l10n.stLegalEmpty,
              body: l10n.stLegalEmptyBody,
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AtSpacing.gutter,
              8,
              AtSpacing.gutter,
              32,
            ),
            children: [
              for (final d in docs) ...[
                AtCard(
                  onTap: () =>
                      context.push(Routes.legalDocumentPath(d.type.json!)),
                  semanticLabel: d.title,
                  child: Row(
                    children: [
                      const AtIconTile(
                        icon: LucideIcons.fileText,
                        tone: AtTone.neutral,
                        size: 40,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.title,
                              style: AtTextStyles.cardTitle.copyWith(
                                color: context.at.ink,
                              ),
                            ),
                            Text(
                              [
                                l10n.stVersion(d.version),
                                if (d.effectiveAt != null)
                                  shortDate(context, d.effectiveAt!.toLocal()),
                              ].join(' · '),
                              style: AtTextStyles.metaSm.copyWith(
                                color: context.at.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (d.isDraft)
                        AtStatusPill(label: l10n.stDraft, tone: AtTone.warning),
                    ],
                  ),
                ),
                const SizedBox(height: AtSpacing.listGap),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// One legal document's text. A draft says so at the top.
class LegalDocumentScreen extends ConsumerWidget {
  const LegalDocumentScreen({super.key, required this.type});

  final String type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(legalDocumentProvider(type));
    return SubPage(
      title: async.value?.title ?? l10n.settingsLegal,
      backTo: Routes.legalList,
      child: async.when(
        loading: () => const AtLoadingBody(),
        error: (e, _) => loadFailure(
          e,
          () => ref.invalidate(legalDocumentProvider(type)),
          l10n,
        ),
        data: (d) => ListView(
          padding: const EdgeInsets.fromLTRB(
            AtSpacing.gutter,
            8,
            AtSpacing.gutter,
            32,
          ),
          children: [
            if (d.isDraft)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: AtInlineBanner(
                  message: d.draftLabel ?? l10n.stDraftPending,
                  tone: AtBannerTone.info,
                ),
              ),
            for (final para in d.body.split(RegExp(r'\n{2,}')))
              if (para.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    para.trim(),
                    style: AtTextStyles.body.copyWith(color: context.at.body),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
