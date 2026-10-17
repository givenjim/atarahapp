import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers.dart';
import '../../core/routing/routes.dart';

final legalDocumentProvider = FutureProvider.autoDispose
    .family<LegalDocumentDto, String>(
      (ref, type) => ref.watch(contentRepositoryProvider).legalDocument(type),
    );

/// Read-only Terms or Privacy text. Until the owner publishes reviewed text it shows the seeded draft and says so.
class LegalScreen extends ConsumerWidget {
  const LegalScreen({super.key, required this.type});

  /// `TERMS` or `PRIVACY`.
  final String type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final doc = ref.watch(legalDocumentProvider(type));
    final fallbackTitle = type == 'PRIVACY'
        ? l10n.legalPrivacyTitle
        : l10n.legalTermsTitle;

    return Scaffold(
      body: AtPage(
        child: Column(
          children: [
            AtTopBar(
              title: doc.value?.title ?? fallbackTitle,
              onBack: () =>
                  context.canPop() ? context.pop() : context.go(Routes.welcome),
            ),
            Expanded(
              child: doc.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => AtErrorState(
                  title: l10n.legalUnavailable,
                  ctaLabel: l10n.retry,
                  onCta: () => ref.invalidate(legalDocumentProvider(type)),
                ),
                data: (d) => SingleChildScrollView(
                  padding: const EdgeInsets.all(AtSpacing.gutter),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (d.isDraft) ...[
                        AtInlineBanner(
                          message: l10n.legalDraftBanner,
                          tone: AtBannerTone.info,
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        d.body,
                        style: AtTextStyles.body.copyWith(
                          color: AtColors.longForm,
                        ),
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
