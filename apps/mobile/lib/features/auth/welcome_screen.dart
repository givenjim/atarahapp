import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers.dart';
import '../../core/routing/routes.dart';

/// First screen for a signed-out member. Create account and Sign in open their Phase 1 placeholders
/// (the real forms land in P1-M1); the developer sign-in exists in the dev flavour only.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key, this.from});

  /// Remembered destination, carried through the sign-in flow.
  final String? from;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final devTools = ref.watch(appConfigProvider).showDevTools;
    final intended = GoRouterState.of(context).uri.queryParameters['from'];

    String withFrom(String path) => intended == null
        ? path
        : '$path?from=${Uri.encodeQueryComponent(intended)}';

    return Scaffold(
      body: AtPage(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AtSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),
              const AtWordmark(size: 26),
              const Spacer(),
              Semantics(
                header: true,
                child: Text(
                  l10n.welcomeHeadline,
                  style: AtTextStyles.tabTitle.copyWith(color: AtColors.ink),
                ),
              ),
              const SizedBox(height: 28),
              AtButton(
                label: l10n.welcomeCreateAccount,
                onPressed: () => context.push(
                  Routes.soonPath('p1', name: l10n.welcomeCreateAccount),
                ),
              ),
              const SizedBox(height: 4),
              AtButton(
                label: l10n.welcomeSignIn,
                variant: AtButtonVariant.secondary,
                onPressed: () => context.push(
                  Routes.soonPath('p1', name: l10n.welcomeSignIn),
                ),
              ),
              if (devTools) ...[
                const SizedBox(height: 4),
                AtButton(
                  label: l10n.devSignInEntry,
                  variant: AtButtonVariant.tertiary,
                  onPressed: () => context.push(withFrom(Routes.devSignIn)),
                ),
              ],
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
