import 'dart:async';

import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/auth/auth_repository.dart';
import 'package:atarah/core/networking/failures.dart';

/// A signed-in member for tests.
MeDto fakeUser({
  String name = 'Test Member',
  String email = 'member@test.atarah.local',
  bool pro = false,
  List<MeDtoRoles> roles = const [],
  MeDtoAppearance appearance = MeDtoAppearance.light,
  MeDtoStatus status = MeDtoStatus.active,
  DateTime? deletionScheduledFor,
}) => MeDto(
  id: '00000000-0000-4000-8000-000000000001',
  fullName: name,
  email: email,
  phone: null,
  emailVerified: true,
  phoneVerified: false,
  status: status,
  timeZone: 'Africa/Nairobi',
  locale: 'en',
  appearance: appearance,
  marketingOptIn: false,
  roles: roles,
  entitlements: const [],
  membership: MembershipSummaryDto(
    plan: pro ? MembershipSummaryDtoPlan.pro : MembershipSummaryDtoPlan.free,
  ),
  createdAt: DateTime.utc(2026, 1, 1),
  deletionScheduledFor: deletionScheduledFor,
);

/// In-memory stand-in for [AuthRepository]. Records calls and can be scripted to fail.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.restored,
    this.restoreFailure,
    this.signInFailure,
    this.registerFailure,
    this.verifyFailure,
    this.resendFailure,
    this.forgotFailure,
    this.resetFailure,
  });

  MeDto? restored;
  AppFailure? restoreFailure;
  AppFailure? signInFailure;
  final List<String> calls = [];

  /// Times the device was registered with the API (kept apart from [calls]).
  int deviceRegistrations = 0;

  /// Push the provider-ended-the-session and Google-returned events into the app.
  // ignore: close_sinks
  final sessionEndedController = StreamController<void>.broadcast();
  // ignore: close_sinks
  final externalSignedInController = StreamController<void>.broadcast();
  MeDto? externalResult;
  MeDto signInResult = fakeUser();

  @override
  Future<MeDto?> restoreSession() async {
    calls.add('restore');
    final failure = restoreFailure;
    if (failure != null) {
      restoreFailure = null; // a retry succeeds
      throw failure;
    }
    return restored;
  }

  @override
  Future<MeDto> signIn({
    required String identifier,
    required String password,
  }) async {
    calls.add('signIn:$identifier');
    final failure = signInFailure;
    if (failure != null) throw failure;
    return signInResult;
  }

  /// Scripted outcomes for the new flows. A null failure means success.
  AppFailure? registerFailure;
  AppFailure? verifyFailure;
  AppFailure? resendFailure;
  AppFailure? forgotFailure;
  AppFailure? resetFailure;
  DateTime? resendAvailableAt;
  MeDto verifyResult = fakeUser();

  @override
  Future<CodeTicket> register({
    required String fullName,
    required String identifier,
    required String password,
  }) async {
    calls.add('register:$identifier');
    final f = registerFailure;
    if (f != null) throw f;
    return CodeTicket(
      destination: identifier,
      resendAvailableAt:
          resendAvailableAt ?? DateTime.now().add(const Duration(seconds: 42)),
    );
  }

  @override
  Future<MeDto> verify({
    required String identifier,
    required String code,
  }) async {
    calls.add('verify:$identifier:$code');
    final f = verifyFailure;
    if (f != null) throw f;
    return verifyResult;
  }

  @override
  Future<DateTime?> resendCode(String identifier) async {
    calls.add('resend:$identifier');
    final f = resendFailure;
    if (f != null) throw f;
    return DateTime.now().add(const Duration(seconds: 60));
  }

  @override
  Future<void> requestPasswordReset(String identifier) async {
    calls.add('forgot:$identifier');
    final f = forgotFailure;
    if (f != null) throw f;
  }

  @override
  Future<MeDto> resetPassword({
    required String identifier,
    required String code,
    required String newPassword,
  }) async {
    calls.add('reset:$identifier:$code');
    final f = resetFailure;
    if (f != null) throw f;
    return signInResult;
  }

  @override
  Stream<void> get sessionEnded => sessionEndedController.stream;

  @override
  Stream<void> get externalSignedIn => externalSignedInController.stream;

  @override
  Future<void> startGoogleSignIn() async => calls.add('google');

  @override
  Future<MeDto> enterWithExistingSession() async =>
      externalResult ?? signInResult;

  @override
  Future<void> registerDevice() async => deviceRegistrations++;

  @override
  Future<void> signOut() async => calls.add('signOut');

  @override
  Future<void> clearLocalSession() async => calls.add('clear');
}
