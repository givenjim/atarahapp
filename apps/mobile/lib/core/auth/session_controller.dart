import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api/generated/export.dart';
import '../providers.dart';
import 'auth_repository.dart';

part 'session_controller.g.dart';

/// The signed-in member, or null when signed out. Starts by restoring a stored session.
/// `AsyncLoading` means "checking", and `AsyncError` means the check failed (usually offline).
@Riverpod(keepAlive: true)
class SessionController extends _$SessionController {
  @override
  Future<MeDto?> build() async {
    final repo = ref.watch(authRepositoryProvider);
    // The provider ended the session (refresh failed, revoked elsewhere): back to signed out.
    final ended = repo.sessionEnded.listen((_) {
      if (state.value != null) state = const AsyncData(null);
    });
    // Google sign-in comes back through the deep link, not through a form.
    final external = repo.externalSignedIn.listen((_) => _enterExternal());
    ref.onDispose(() {
      unawaited(ended.cancel());
      unawaited(external.cancel());
    });
    final user = await repo.restoreSession();
    if (user != null) _afterSignIn();
    return user;
  }

  /// Records this device with the API. Never blocks or fails the sign-in.
  void _afterSignIn() =>
      unawaited(ref.read(authRepositoryProvider).registerDevice());

  Future<void> _enterExternal() async {
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .enterWithExistingSession();
      ref.read(analyticsProvider).track('sign_in');
      state = AsyncData(user);
      _afterSignIn();
    } on Object {
      // The account was refused; the repository has already signed the device out.
    }
  }

  /// Opens Google sign-in. The member is signed in when the browser returns to the app.
  Future<void> signInWithGoogle() =>
      ref.read(authRepositoryProvider).startGoogleSignIn();

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
    _afterSignIn();
  }

  /// Creates the account and sends the first code. Returns when the member may ask for another.
  Future<CodeTicket> register({
    required String fullName,
    required String identifier,
    required String password,
  }) async {
    final ticket = await ref
        .read(authRepositoryProvider)
        .register(
          fullName: fullName,
          identifier: identifier,
          password: password,
        );
    ref.read(analyticsProvider).track('user_registered');
    return ticket;
  }

  /// A correct code signs the member in; the router then leaves the auth screens.
  Future<void> verify({
    required String identifier,
    required String code,
  }) async {
    final user = await ref
        .read(authRepositoryProvider)
        .verify(identifier: identifier, code: code);
    ref.read(analyticsProvider).track('verification_completed');
    state = AsyncData(user);
    _afterSignIn();
  }

  Future<DateTime?> resendCode(String identifier) =>
      ref.read(authRepositoryProvider).resendCode(identifier);

  Future<void> requestPasswordReset(String identifier) =>
      ref.read(authRepositoryProvider).requestPasswordReset(identifier);

  /// Checks the code and sets the new password. The code signs this device in, and the account's other
  /// sessions are ended.
  Future<void> resetPasswordAndSignIn({
    required String identifier,
    required String code,
    required String newPassword,
  }) async {
    final user = await ref
        .read(authRepositoryProvider)
        .resetPassword(
          identifier: identifier,
          code: code,
          newPassword: newPassword,
        );
    ref.read(analyticsProvider).track('sign_in');
    state = AsyncData(user);
    _afterSignIn();
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData(null);
  }

  /// The server ended the session (the API refused a refreshed token, or the refresh failed).
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
