import 'dart:async';

import 'package:atarah/core/auth/auth_gateway.dart';
import 'package:atarah/core/auth/identifier.dart';

/// Scriptable stand-in for Supabase Auth. Records every call; any method fails once with the exception
/// queued for it in [failures].
class FakeAuthGateway implements AuthGateway {
  final List<String> calls = [];
  final Map<String, AuthGatewayException> failures = {};
  bool session = false;
  bool accountExists = false;
  Map<String, Object?>? lastMetadata;
  String? token = 'tok';
  String? refreshResult = 'tok-new';

  // ignore: close_sinks
  final signedOutController = StreamController<void>.broadcast();
  // ignore: close_sinks
  final externalController = StreamController<void>.broadcast();

  void _call(String name, [String detail = '']) {
    calls.add(detail.isEmpty ? name : '$name:$detail');
    final f = failures.remove(name);
    if (f != null) throw f;
  }

  @override
  bool get hasSession => session;

  @override
  String? get accessToken => token;

  @override
  Stream<void> get signedOut => signedOutController.stream;

  @override
  Stream<void> get externalSignedIn => externalController.stream;

  @override
  Future<bool> signUp({
    required ParsedIdentifier identifier,
    required String password,
    required Map<String, Object?> metadata,
  }) async {
    lastMetadata = metadata;
    _call('signUp', identifier.value);
    return accountExists;
  }

  @override
  Future<void> verifySignupCode({
    required ParsedIdentifier identifier,
    required String code,
  }) async {
    _call('verifySignup', '${identifier.value}:$code');
    session = true;
  }

  @override
  Future<void> resendSignupCode(ParsedIdentifier identifier) async =>
      _call('resend', identifier.value);

  @override
  Future<void> signInWithPassword({
    required ParsedIdentifier identifier,
    required String password,
  }) async {
    _call('signIn', identifier.value);
    session = true;
  }

  @override
  Future<void> sendRecoveryCode(ParsedIdentifier identifier) async =>
      _call('sendRecovery', identifier.value);

  @override
  Future<void> verifyRecoveryCode({
    required ParsedIdentifier identifier,
    required String code,
  }) async {
    _call('verifyRecovery', '${identifier.value}:$code');
    session = true;
  }

  @override
  Future<void> updatePassword(String newPassword) async =>
      _call('updatePassword');

  @override
  Future<void> signOutOthers() async => _call('signOutOthers');

  @override
  Future<void> signOut() async {
    calls.add('signOut');
    session = false;
  }

  @override
  Future<String?> refreshSession() async {
    calls.add('refresh');
    return refreshResult;
  }

  @override
  Future<void> signInWithGoogle() async => _call('google');
}
