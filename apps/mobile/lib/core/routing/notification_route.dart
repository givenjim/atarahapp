import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where a notification (in-app, or a push the member tapped) takes them.
///
/// The server only sends in-app paths (`/opportunities/{id}`), but a notification is data from outside the screen it
/// opens, so the path is checked here as well: a single leading slash, no scheme or host, and one of the screens the
/// app has. Anything else answers null and the caller stays where it is (the notifications list).
String? resolveNotificationRoute(String? deepLink) {
  if (deepLink == null) return null;
  final raw = deepLink.trim();
  if (!RegExp(r'^/(?!/)[^\s\\]*$').hasMatch(raw)) return null;
  final uri = Uri.tryParse(raw);
  if (uri == null || uri.hasScheme || uri.hasAuthority) return null;
  final first = uri.pathSegments.isEmpty ? '' : uri.pathSegments.first;
  return _known.contains(first) ? raw : null;
}

/// The first path segment of every screen a notification may open.
const _known = {
  'home',
  'explore',
  'community',
  'opportunities',
  'learning',
  'profile',
  'passport',
  'portfolio',
  'projects',
  'skills',
  'experience',
  'achievements',
  'services',
  'creatives',
  'connections',
  'posts',
  'groups',
  'articles',
  'notifications',
  'saved',
  'activity',
  'applications',
  'settings',
};

/// Taps on push notifications. The native side (Firebase Cloud Messaging) is not configured in this build, so the
/// default source never emits; the app listens to whatever source is provided and routes through
/// [resolveNotificationRoute], so wiring FCM later is one class, not a change to the screens.
abstract interface class PushTapSource {
  /// Deep links of notifications the member tapped while the app was running.
  Stream<String> get taps;

  /// The deep link of the notification that launched the app, if one did.
  Future<String?> initialTap();
}

class NoPushTapSource implements PushTapSource {
  const NoPushTapSource();

  @override
  Stream<String> get taps => const Stream.empty();

  @override
  Future<String?> initialTap() async => null;
}

final pushTapSourceProvider = Provider<PushTapSource>(
  (ref) => const NoPushTapSource(),
);
