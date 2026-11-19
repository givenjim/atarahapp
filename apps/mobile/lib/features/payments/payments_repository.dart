import '../../core/api/generated/export.dart';
import '../../core/networking/failures.dart';

/// Talks to `/payments`. The app never decides whether a payment succeeded: it asks the server, which only believes the
/// payment provider.
class PaymentsRepository {
  PaymentsRepository({required this._api});

  final AtarahApiClient _api;

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on Object catch (e) {
      throw mapError(e);
    }
  }

  /// The methods the member may pick. Card is absent until the owner connects a card provider.
  Future<List<PaymentMethodOptionDto>> methods() =>
      _guard(() async => (await _api.payments.methods()).data.methods);

  /// Starts a payment. [idempotencyKey] makes a retried request return the same payment instead of a second prompt.
  /// The amount is not sent: the server prices the purchase.
  Future<PaymentDto> initiate({
    required InitiatePaymentDtoPurpose purpose,
    required InitiatePaymentDtoMethod method,
    required String idempotencyKey,
    String? referenceId,
    String? phone,
    int? sandboxAmountMinor,
  }) => _guard(
    () async => (await _api.payments.initiate(
      idempotencyKey: idempotencyKey,
      body: InitiatePaymentDto(
        purpose: purpose,
        method: method,
        referenceId: referenceId,
        phone: phone,
        sandboxAmountMinor: sandboxAmountMinor,
      ),
    )).data,
  );

  Future<PaymentDto> get(String id) =>
      _guard(() async => (await _api.payments.getApiV1PaymentsId(id: id)).data);

  /// The member's payments, newest first (receipts).
  Future<List<PaymentDto>> list({int page = 1, int limit = 20}) => _guard(
    () async => (await _api.payments.list(page: page, limit: limit)).data,
  );
}
