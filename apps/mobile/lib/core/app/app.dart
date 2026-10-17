import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../connectivity/connectivity_provider.dart';
import '../design_system/design_system.dart';
import '../l10n/app_localizations.dart';
import '../routing/app_router.dart';

/// Root widget: theme, localisation, router, and the global offline banner.
class AtarahApp extends ConsumerWidget {
  const AtarahApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    // While the first connectivity reading is pending, assume online (no flash of a banner).
    final offline = ref.watch(isOnlineProvider).value == false;

    return MaterialApp.router(
      title: 'Atarah',
      debugShowCheckedModeBanner: false,
      theme: AtTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, child) => Column(
        children: [
          if (offline) const SafeArea(bottom: false, child: AtOfflineBanner()),
          Expanded(child: child ?? const SizedBox.shrink()),
        ],
      ),
    );
  }
}
