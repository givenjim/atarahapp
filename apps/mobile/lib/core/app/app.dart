import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/discover/unread_notifications.dart';
import '../appearance/appearance_controller.dart';
import '../connectivity/connectivity_provider.dart';
import '../design_system/design_system.dart';
import '../l10n/app_localizations.dart';
import '../routing/app_router.dart';
import '../routing/notification_route.dart';

/// Sends the member to what a tapped push notification is about. The tap source is a seam (no Firebase in this
/// build); a launch notification is handled once, and every tap goes through [resolveNotificationRoute] so an
/// unknown or unsafe target is ignored rather than opened.
final pushTapRouterProvider = Provider<void>((ref) {
  final source = ref.watch(pushTapSourceProvider);
  final router = ref.watch(appRouterProvider);
  void open(String? link) {
    final route = resolveNotificationRoute(link);
    if (route != null) router.push(route);
  }

  final sub = source.taps.listen(open);
  ref.onDispose(sub.cancel);
  source.initialTap().then(open, onError: (Object _) {});
});

/// Root widget: theme, localisation, router, and the global offline banner.
class AtarahApp extends ConsumerWidget {
  const AtarahApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    // Keeps the notifications channel open for as long as the member is signed in.
    ref.watch(unreadNotificationsProvider);
    ref.watch(pushTapRouterProvider);
    // While the first connectivity reading is pending, assume online (no flash of a banner).
    final offline = ref.watch(isOnlineProvider).value == false;

    final appearance = ref.watch(appearanceControllerProvider);

    return MaterialApp.router(
      title: 'Atarah',
      debugShowCheckedModeBanner: false,
      theme: AtTheme.light,
      darkTheme: AtTheme.dark,
      themeMode: appearance == AtAppearance.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      // Status and navigation bars follow the appearance (screens with their own app bar or region override).
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: AtTheme.overlayStyle(appearance.brightness),
        child: Column(
          children: [
            if (offline)
              const SafeArea(bottom: false, child: AtOfflineBanner()),
            Expanded(child: child ?? const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
