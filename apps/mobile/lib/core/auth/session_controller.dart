import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api/generated/export.dart';
import '../providers.dart';

part 'session_controller.g.dart';

/// The signed-in member, or null when signed out. Starts by restoring a stored session.
/// `AsyncLoading` means "checking", and `AsyncError` means the check failed (usually offline).
@Riverpod(keepAlive: true)
class SessionController extends _$SessionController {
  @override
  Future<MeDto?> build() => ref.watch(authRepositoryProvider).restoreSession();

  /// Throws the typed failure (`ApiFailure`, `NetworkFailure`) so the sign-in form can show it.
  Future<void> signIn({
    required String identifier,
    required String password,
  }) async {
    final user = await ref
        .read(authRepositoryProvider)
        .signIn(identifier: identifier, password: password);
    ref.read(analyticsProvider).track('sign_in');
    state = AsyncData(user);
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData(null);
  }

  /// The server ended the session (refresh failed, token reuse, idle timeout).
  void expire() {
    unawaited(ref.read(authRepositoryProvider).clearLocalSession());
    state = const AsyncData(null);
  }

  /// Re-run the startup check (the "Try again" button after an offline launch).
  void retry() => ref.invalidateSelf();
}

enum SessionStatus { checking, failed, signedOut, signedIn }

/// Coarse status for the router.
@Riverpod(keepAlive: true)
SessionStatus sessionStatus(Ref ref) {
  final session = ref.watch(sessionControllerProvider);
  if (session.isLoading && !session.hasValue) return SessionStatus.checking;
  if (session.hasError && !session.hasValue) return SessionStatus.failed;
  return session.value == null
      ? SessionStatus.signedOut
      : SessionStatus.signedIn;
}
