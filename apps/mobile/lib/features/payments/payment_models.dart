import '../../core/api/generated/export.dart';

/// What to pay for. Membership (P2-M2) and mentorship (P2-M5) build one of these and push [Routes.pay] with it as `extra`.
/// The amount is only shown here: the server prices the purchase from [purpose] and [referenceId].
class PaymentRequest {
  const PaymentRequest({
    required this.purpose,
    required this.title,
    required this.amountLabel,
    this.referenceId,
    this.subtitle,
    this.sandboxAmountMinor,
  });

  final InitiatePaymentDtoPurpose purpose;

  /// What is being bought, such as "Atarah Pro · 1 month".
  final String title;

  /// The price as the member reads it, such as "KES 1,200".
  final String amountLabel;
  final String? subtitle;

  /// The booking or order being paid for. Null for purposes that need none.
  final String? referenceId;

  /// Only for the development "sandbox check" purpose (`other`), where the client picks a small amount.
  final int? sandboxAmountMinor;
}

/// The result [Routes.pay] pops with when the payment succeeded. Anything else (back, failure) pops `null`.
class PaymentOutcome {
  const PaymentOutcome(this.payment);
  final PaymentDto payment;
}

/// Where the payment screen is. Only the server moves a payment to success; [PaymentDone] is shown only for a payment the
/// server reported as SUCCEEDED.
sealed class PaymentFlowState {
  const PaymentFlowState();
}

/// Choosing a method and entering the number.
class PaymentIdle extends PaymentFlowState {
  const PaymentIdle({this.error});

  /// Shown above the form after a failed attempt.
  final String? error;
}

/// The request to start the payment is in flight.
class PaymentSubmitting extends PaymentFlowState {
  const PaymentSubmitting();
}

/// The prompt is on the member's phone (or the browser page is open). The screen polls the server.
class PaymentWaiting extends PaymentFlowState {
  const PaymentWaiting(this.payment, {this.redirectUrl, this.checking = false});

  final PaymentDto payment;

  /// Card: the page to finish the payment on.
  final String? redirectUrl;

  /// A poll is in flight (used by tests and for a subtle spinner; the screen already shows progress).
  final bool checking;

  /// The time limit passed. The screen offers "Try again" while the server keeps checking.
  bool get timedOut => payment.timedOut;
}

/// The server confirmed the payment.
class PaymentDone extends PaymentFlowState {
  const PaymentDone(this.payment);
  final PaymentDto payment;
}

/// The server said the payment did not go through. [message] says what to do next.
class PaymentFailedState extends PaymentFlowState {
  const PaymentFailedState(this.message, {this.payment});
  final String message;
  final PaymentDto? payment;
}

/// `07XX XXX XXX`, `+2547XX XXX XXX` or `7XX XXX XXX` as `+2547XXXXXXXX`. Null when it is not a Safaricom number.
String? normalizeKenyanNumber(String input) {
  var digits = input.replaceAll(RegExp(r'[\s\-()]'), '');
  if (digits.startsWith('+254')) {
    digits = digits.substring(4);
  } else if (digits.startsWith('254')) {
    digits = digits.substring(3);
  } else if (digits.startsWith('0')) {
    digits = digits.substring(1);
  }
  return RegExp(r'^[17]\d{8}$').hasMatch(digits) ? '+254$digits' : null;
}
