import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/design_system/gallery/component_gallery.dart';
import '../../features/auth/forgot_screen.dart';
import '../../features/auth/legal_screen.dart';
import '../../features/auth/reset_screen.dart';
import '../../features/auth/signin_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/verify_screen.dart';
import '../../features/auth/welcome_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/shell/future_route_screen.dart';
import '../auth/session_controller.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import 'redirect.dart';
import 'routes.dart';

part 'app_router.g.dart';

/// One tab root. All four unbuilt tabs show the Phase 1 placeholder until their milestone lands.
class _TabRoot {
  const _TabRoot(this.path, this.name);
  final String path;
  final String Function(AppLocalizations) name;
}

/// Detail routes that open the placeholder for now: path, phase, display name.
final List<
  ({String path, String phase, String Function(AppLocalizations) name})
>
_detailRoutes = [
  (path: Routes.creative, phase: 'p1', name: (l) => l.featureCreativeProfile),
  (path: Routes.project, phase: 'p1', name: (l) => l.featureProject),
  (path: Routes.opportunity, phase: 'p1', name: (l) => l.featureOpportunities),
  (path: Routes.course, phase: 'p1', name: (l) => l.featureCourse),
  (path: Routes.lesson, phase: 'p1', name: (l) => l.featureLesson),
  (path: Routes.listing, phase: 'p2', name: (l) => l.featureListing),
  (path: Routes.mentor, phase: 'p2', name: (l) => l.featureMentor),
  (path: Routes.article, phase: 'p1', name: (l) => l.featureArticle),
  (path: Routes.group, phase: 'p1', name: (l) => l.featureGroup),
  (path: Routes.post, phase: 'p1', name: (l) => l.featurePost),
  (
    path: Routes.notifications,
    phase: 'p1',
    name: (l) => l.featureNotifications,
  ),
];

final _tabRoots = [
  _TabRoot(Routes.home, (l) => l.featureHome),
  _TabRoot(Routes.explore, (l) => l.featureExplore),
  _TabRoot(Routes.community, (l) => l.featureCommunity),
  _TabRoot(Routes.opportunities, (l) => l.featureOpportunities),
];

/// Navigation graph: splash -> session check -> welcome / home, the five-tab shell, and the deep-link
/// routes. Redirect logic lives in [computeRedirect].
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final devTools = ref.watch(appConfigProvider).showDevTools;
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionStatusProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  String phaseOf(GoRouterState s) => s.pathParameters['phase'] ?? 'later';

  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) => computeRedirect(
      status: ref.read(sessionStatusProvider),
      uri: state.uri,
      devTools: devTools,
    ),
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.welcome, builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: Routes.signup, builder: (_, _) => const SignUpScreen()),
      GoRoute(path: Routes.signin, builder: (_, _) => const SignInScreen()),
      GoRoute(
        path: Routes.verify,
        builder: (_, state) {
          final q = state.uri.queryParameters;
          final ms = int.tryParse(q['resendAt'] ?? '');
          return VerifyScreen(
            identifier: q['identifier'] ?? '',
            resendAt: ms == null
                ? null
                : DateTime.fromMillisecondsSinceEpoch(ms),
          );
        },
      ),
      GoRoute(
        path: Routes.forgot,
        builder: (_, state) =>
            ForgotScreen(identifier: state.uri.queryParameters['identifier']),
      ),
      GoRoute(
        path: Routes.reset,
        builder: (_, state) => ResetScreen(
          identifier: state.uri.queryParameters['identifier'] ?? '',
          codeJustSent: state.uri.queryParameters['sent'] == '1',
        ),
      ),
      GoRoute(
        path: Routes.legal,
        builder: (_, state) =>
            LegalScreen(type: state.pathParameters['type'] ?? 'TERMS'),
      ),
      // Creative profile setup is built in P1-M2; until then the way in is labelled, and back goes Home.
      GoRoute(
        path: Routes.onboarding,
        builder: (context, _) => FutureRouteScreen(
          phase: 'p1',
          name: AppLocalizations.of(context).onboardingPlaceholderName,
          onBack: () => context.go(Routes.home),
        ),
      ),
      if (devTools)
        GoRoute(
          path: Routes.devGallery,
          builder: (_, _) => const ComponentGalleryScreen(),
        ),
      GoRoute(
        path: Routes.soon,
        builder: (_, state) => FutureRouteScreen(
          phase: phaseOf(state),
          name: state.uri.queryParameters['name'],
        ),
      ),
      for (final d in _detailRoutes)
        GoRoute(
          path: d.path,
          builder: (context, state) => FutureRouteScreen(
            phase: d.phase,
            name: d.name(AppLocalizations.of(context)),
          ),
        ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          for (final tab in _tabRoots)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: tab.path,
                  builder: (context, _) => FutureRouteScreen(
                    phase: 'p1',
                    name: tab.name(AppLocalizations.of(context)),
                    showBack: false,
                  ),
                ),
              ],
            ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
