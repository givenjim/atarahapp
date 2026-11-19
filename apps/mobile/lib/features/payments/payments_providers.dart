import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/generated/export.dart';
import '../../core/networking/failures.dart';
import '../../core/providers.dart';
import 'payment_models.dart';
import 'payments_repository.dart';

final paymentsRepositoryProvider = Provider<PaymentsRepository>(
  (ref) => PaymentsRepository(api: ref.watch(apiClientProvider)),
);

/// The methods the member may pick. Reloaded each time the payment screen opens.
final paymentMethodsProvider =
    FutureProvider.autoDispose<List<PaymentMethodOptionDto>>(
      (ref) => ref.watch(paymentsRepositoryProvider).methods(),
    );

/// A fresh key per attempt. Replaced in tests.
final paymentKeyFactoryProvider = Provider<String Function()>((ref) {
  final random = Random.secure();
  return () {
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  };
});

/// How long to wait before asking the server again. The server suggests it (`pollAfterSeconds`); tests shorten it.
final paymentPollDelayProvider = Provider<Duration Function(PaymentDto)>(
  (ref) =>
      (p) => Duration(seconds: p.pollAfterSeconds.toInt().clamp(1, 30)),
);

/// Opens the card provider's page. Replaced in tests.
final paymentUrlLauncherProvider = Provider<Future<bool> Function(String url)>(
  (ref) =>
      (url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
);

final paymentFlowProvider =
    NotifierProvider.autoDispose<PaymentFlowController, PaymentFlowState>(
      PaymentFlowController.new,
    );

/// Runs one payment from "Pay" to a final answer. It starts the payment, then polls the server until the server reports
/// a final status. It never infers success itself: a lost connection or a slow phone leaves the screen waiting.
class PaymentFlowController extends Notifier<PaymentFlowState> {
  Timer? _timer;
  PaymentRequest? _request;
  InitiatePaymentDtoMethod? _method;
  String? _phone;
  var _generation = 0;

  @override
  PaymentFlowState build() {
    ref.onDispose(() {
      _timer?.cancel();
      _generation++;
    });
    return const PaymentIdle();
  }

  PaymentsRepository get _repo => ref.read(paymentsRepositoryProvider);

  /// Starts the payment. [phone] is any Kenyan format; it is checked here and again by the server.
  Future<void> start(
    PaymentRequest request, {
    required InitiatePaymentDtoMethod method,
    String? phone,
  }) async {
    if (state is PaymentSubmitting || state is PaymentWaiting) return;
    String? number;
    if (method == InitiatePaymentDtoMethod.mpesa) {
      number = normalizeKenyanNumber(phone ?? '');
      if (number == null) {
        state = const PaymentIdle(
          error: 'Enter a Safaricom number like 0712 345 678.',
        );
        return;
      }
    }
    _request = request;
    _method = method;
    _phone = phone;
    final run = ++_generation;
    state = const PaymentSubmitting();
    try {
      final payment = await _repo.initiate(
        purpose: request.purpose,
        method: method,
        referenceId: request.referenceId,
        phone: number,
        sandboxAmountMinor: request.sandboxAmountMinor,
        idempotencyKey: ref.read(paymentKeyFactoryProvider)(),
      );
      if (run != _generation) return;
      await _apply(payment, run);
      final redirect = payment.action?.url;
      if (redirect != null && state is PaymentWaiting) {
        state = PaymentWaiting(payment, redirectUrl: redirect);
        await ref.read(paymentUrlLauncherProvider)(redirect);
      }
    } on ApiFailure catch (e) {
      if (run != _generation) return;
      final existing = e.details['paymentId'];
      if (e.code == 'CONFLICT' && existing is String) {
        // A payment for this purchase is already waiting: rejoin it instead of sending a second prompt.
        await _rejoin(existing, run);
        return;
      }
      state = PaymentIdle(error: e.message);
    } on AppFailure catch (e) {
      if (run != _generation) return;
      state = PaymentIdle(error: e.message);
    }
  }

  Future<void> _rejoin(String paymentId, int run) async {
    try {
      final payment = await _repo.get(paymentId);
      if (run != _generation) return;
      await _apply(payment, run);
    } on AppFailure catch (e) {
      if (run != _generation) return;
      state = PaymentIdle(error: e.message);
    }
  }

  /// Applies what the server says. Final statuses end the flow; open ones keep polling.
  Future<void> _apply(PaymentDto p, int run) async {
    switch (p.status) {
      case PaymentDtoStatus.succeeded ||
          PaymentDtoStatus.refunded ||
          PaymentDtoStatus.partiallyRefunded:
        _timer?.cancel();
        state = PaymentDone(p);
      case PaymentDtoStatus.failed || PaymentDtoStatus.cancelled:
        _timer?.cancel();
        state = PaymentFailedState(
          p.failureReason ??
              'The payment did not go through. Please try again.',
          payment: p,
        );
      case PaymentDtoStatus.initiated ||
          PaymentDtoStatus.pending ||
          PaymentDtoStatus.$unknown:
        state = PaymentWaiting(p);
        _schedule(p, run);
    }
  }

  void _schedule(PaymentDto p, int run) {
    _timer?.cancel();
    _timer = Timer(
      ref.read(paymentPollDelayProvider)(p),
      () => _poll(p.id, run),
    );
  }

  Future<void> _poll(String id, int run) async {
    if (run != _generation) return;
    final current = state;
    if (current is! PaymentWaiting) return;
    state = PaymentWaiting(
      current.payment,
      redirectUrl: current.redirectUrl,
      checking: true,
    );
    try {
      final p = await _repo.get(id);
      if (run != _generation) return;
      await _apply(p, run);
      final next = state;
      if (next is PaymentWaiting && current.redirectUrl != null) {
        state = PaymentWaiting(next.payment, redirectUrl: current.redirectUrl);
      }
    } on AppFailure {
      if (run != _generation) return;
      // A dropped connection says nothing about the payment: keep waiting and ask again.
      state = PaymentWaiting(current.payment, redirectUrl: current.redirectUrl);
      _schedule(current.payment, run);
    }
  }

  /// "Try again" after a failure or a timeout: back to the form, nothing sent yet.
  void retry() {
    _timer?.cancel();
    _generation++;
    state = const PaymentIdle();
  }

  /// Sends a fresh attempt for the same purchase with the same method and number.
  Future<void> tryAgain() async {
    final request = _request;
    final method = _method;
    if (request == null || method == null) {
      retry();
      return;
    }
    retry();
    await start(request, method: method, phone: _phone);
  }
}
