import '../auth/session_controller.dart';
import 'routes.dart';

/// Only same-app, absolute paths are honoured as a post-sign-in destination (no open redirects).
String? safeDestination(String? from) {
  if (from == null || from.isEmpty) return null;
  if (!from.startsWith('/') || from.startsWith('//')) return null;
  final path = Uri.tryParse(from)?.path;
  if (path == null) return null;
  if (Routes.authScreens.contains(path)) return null;
  return from;
}

String _withFrom(String target, Uri current) {
  final intended = current.toString();
  // Do not carry a pointless destination (the auth screens themselves) forward.
  if (safeDestination(intended) == null) return target;
  return '$target?from=${Uri.encodeQueryComponent(intended)}';
}

/// The router's redirect rules, as a pure function so every branch is unit-tested.
///
///  * While the stored session is being checked (or the check failed, e.g. offline) everything shows the
///    splash. The intended destination is remembered in `?from=`.
///  * Signed out: only public routes are reachable; anything else goes to welcome, remembering where the
///    member was headed ("sign in, then return to the intended destination").
///  * Signed in: the auth screens are skipped; the member goes to the remembered destination or home.
String? computeRedirect({
  required SessionStatus status,
  required Uri uri,
  required bool devTools,
}) {
  final path = uri.path;
  final from = uri.queryParameters['from'];

  switch (status) {
    case SessionStatus.checking:
    case SessionStatus.failed:
      if (path == Routes.splash) return null;
      return _withFrom(Routes.splash, uri);

    case SessionStatus.signedOut:
      if (path == Routes.splash) {
        final dest = safeDestination(from);
        return dest == null
            ? Routes.welcome
            : '${Routes.welcome}?from=${Uri.encodeQueryComponent(dest)}';
      }
      if (Routes.isPublic(path, devTools: devTools)) return null;
      return _withFrom(Routes.welcome, uri);

    case SessionStatus.signedIn:
      if (Routes.authScreens.contains(path)) {
        return safeDestination(from) ?? Routes.home;
      }
      return null;
  }
}
