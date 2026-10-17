import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/auth/auth_repository.dart';
import 'package:atarah/core/networking/failures.dart';

/// A signed-in member for tests.
MeDto fakeUser({
  String name = 'Test Member',
  String email = 'member@test.atarah.local',
  bool pro = false,
}) => MeDto(
  id: '00000000-0000-4000-8000-000000000001',
  fullName: name,
  email: email,
  phone: null,
  emailVerified: true,
  phoneVerified: false,
  status: MeDtoStatus.active,
  timeZone: 'Africa/Nairobi',
  locale: 'en',
  roles: const [],
  entitlements: const [],
  membership: MembershipSummaryDto(
    plan: pro ? MembershipSummaryDtoPlan.pro : MembershipSummaryDtoPlan.free,
  ),
  createdAt: DateTime.utc(2026, 1, 1),
);

/// In-memory stand-in for [AuthRepository]. Records calls and can be scripted to fail.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.restored, this.restoreFailure, this.signInFailure});

  MeDto? restored;
  AppFailure? restoreFailure;
  AppFailure? signInFailure;
  final List<String> calls = [];
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

  @override
  Future<void> signOut() async => calls.add('signOut');

  @override
  Future<void> clearLocalSession() async => calls.add('clear');
}
