import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show FactorStatus, FactorType, SupabaseClient;

/// True once the API has answered `403 TWO_STEP_REQUIRED`: this device is not yet trusted for an account that turned
/// on two-step verification, so the member must complete the second step before anything else loads.
class TwoStepRequired extends Notifier<bool> {
  @override
  bool build() => false;

  void require() => state = true;

  void clear() => state = false;
}

final twoStepRequiredProvider = NotifierProvider<TwoStepRequired, bool>(
  TwoStepRequired.new,
);

/// One second-step challenge: which factor, the challenge the provider opened and where the code went.
class TwoStepChallenge {
  const TwoStepChallenge({
    required this.factorId,
    required this.challengeId,
    required this.phone,
  });

  final String factorId;
  final String challengeId;

  /// The code arrives by SMS (otherwise it comes from an authenticator app).
  final bool phone;
}

/// The member has two-step on but no factor the app can use (for example the factor was removed elsewhere).
class NoSecondFactorException implements Exception {
  const NoSecondFactorException();
}

/// Completes the second step through Supabase Auth's MFA (the session becomes AAL2). Tests use a fake.
abstract interface class TwoStepVerifier {
  /// Opens a challenge on the member's verified factor. For a phone factor this sends the SMS.
  Future<TwoStepChallenge> start();

  /// Checks the code. Throws the provider's error when it is wrong or expired.
  Future<void> complete(TwoStepChallenge challenge, String code);
}

class SupabaseTwoStepVerifier implements TwoStepVerifier {
  SupabaseTwoStepVerifier(this._client);

  final SupabaseClient _client;

  @override
  Future<TwoStepChallenge> start() async {
    final factors = await _client.auth.mfa.listFactors();
    final usable = factors.all
        .where((f) => f.status == FactorStatus.verified)
        .toList();
    if (usable.isEmpty) throw const NoSecondFactorException();
    // A phone factor first: it is the one the Master Prompt specifies ("SMS code when signing in on a new device").
    final factor = usable.firstWhere(
      (f) => f.factorType == FactorType.phone,
      orElse: () => usable.first,
    );
    final challenge = await _client.auth.mfa.challenge(factorId: factor.id);
    return TwoStepChallenge(
      factorId: factor.id,
      challengeId: challenge.id,
      phone: factor.factorType == FactorType.phone,
    );
  }

  @override
  Future<void> complete(TwoStepChallenge challenge, String code) async {
    await _client.auth.mfa.verify(
      factorId: challenge.factorId,
      challengeId: challenge.challengeId,
      code: code,
    );
  }
}
