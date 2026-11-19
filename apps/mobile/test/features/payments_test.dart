import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/networking/failures.dart';
import 'package:atarah/features/payments/payment_models.dart';
import 'package:atarah/features/payments/payment_screen.dart';
import 'package:atarah/features/payments/payment_widgets.dart';
import 'package:atarah/features/payments/payments_providers.dart';
import 'package:atarah/features/payments/payments_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_app.dart';

PaymentDto payment({
  String id = 'pay-1',
  PaymentDtoStatus status = PaymentDtoStatus.pending,
  String? failureReason,
  bool timedOut = false,
  String? receipt,
  PaymentActionDto? action,
}) => PaymentDto(
  id: id,
  status: status,
  purpose: PaymentDtoPurpose.other,
  method: PaymentDtoMethod.mpesa,
  amountMinor: 5000,
  currency: 'KES',
  description: 'Sandbox check',
  referenceType: null,
  referenceId: null,
  receiptNumber: receipt,
  failureCode: null,
  failureReason: failureReason,
  refundedMinor: 0,
  createdAt: DateTime.utc(2026, 11, 20),
  completedAt: null,
  expiresAt: null,
  timedOut: timedOut,
  pollAfterSeconds: 3,
  action: action,
);

const mpesa = PaymentMethodOptionDto(
  method: PaymentMethodOptionDtoMethod.mpesa,
  label: 'M-Pesa',
  description: 'Pay with your Safaricom line',
);
const card = PaymentMethodOptionDto(
  method: PaymentMethodOptionDtoMethod.card,
  label: 'Card',
  description: 'Visa or Mastercard',
);

/// Answers like the server: `initiate` starts a payment, `get` returns whatever the test scripted next.
class FakePayments implements PaymentsRepository {
  FakePayments({this.methodList = const [mpesa]});

  List<PaymentMethodOptionDto> methodList;
  final initiateCalls = <Map<String, Object?>>[];
  final polls = <String>[];
  Object? initiateResult;
  final getResults = <Object>[];

  @override
  Future<List<PaymentMethodOptionDto>> methods() async => methodList;

  @override
  Future<PaymentDto> initiate({
    required InitiatePaymentDtoPurpose purpose,
    required InitiatePaymentDtoMethod method,
    required String idempotencyKey,
    String? referenceId,
    String? phone,
    int? sandboxAmountMinor,
  }) async {
    initiateCalls.add({
      'purpose': purpose,
      'method': method,
      'key': idempotencyKey,
      'referenceId': referenceId,
      'phone': phone,
      'sandboxAmountMinor': sandboxAmountMinor,
    });
    final r = initiateResult;
    if (r is Object && r is! PaymentDto) throw r;
    return r as PaymentDto? ??
        payment(
          action: const PaymentActionDto(
            type: PaymentActionDtoType.stkPrompt,
            message: "You'll get an M-Pesa prompt to confirm with your PIN.",
          ),
        );
  }

  @override
  Future<PaymentDto> get(String id) async {
    polls.add(id);
    if (getResults.isEmpty) return payment(id: id);
    final next = getResults.length == 1
        ? getResults.first
        : getResults.removeAt(0);
    if (next is PaymentDto) return next;
    throw next;
  }

  @override
  Future<List<PaymentDto>> list({int page = 1, int limit = 20}) async => [];
}

const _request = PaymentRequest(
  purpose: InitiatePaymentDtoPurpose.other,
  title: 'Atarah Pro · 1 month',
  amountLabel: 'KES 50',
  sandboxAmountMinor: 5000,
);

Future<void> pumpFlow(
  WidgetTester tester,
  FakePayments repo, {
  ValueChanged<PaymentDto>? onPaid,
}) async {
  var n = 0;
  await tester.pumpAt(
    ProviderScope(
      overrides: [
        paymentsRepositoryProvider.overrideWithValue(repo),
        paymentPollDelayProvider.overrideWithValue(
          (_) => const Duration(milliseconds: 20),
        ),
        paymentKeyFactoryProvider.overrideWithValue(() => 'key-${++n}'),
        paymentUrlLauncherProvider.overrideWithValue((_) async => true),
      ],
      child: Scaffold(
        body: PaymentFlow(request: _request, onPaid: onPaid ?? (_) {}),
      ),
    ),
    scaffold: false,
  );
  await tester.pump();
  await tester.pump();
}

/// Disposes the tree so the polling timer is cancelled before the test ends.
Future<void> finish(WidgetTester tester) =>
    tester.pumpWidget(const SizedBox.shrink());

Future<void> enterNumberAndPay(WidgetTester tester, String number) async {
  await tester.enterText(find.byType(TextField), number);
  await tester.tap(find.text('Pay KES 50'));
  await tester.pump();
}

void main() {
  group('normalizeKenyanNumber', () {
    test('accepts the common formats', () {
      expect(normalizeKenyanNumber('0712 345 678'), '+254712345678');
      expect(normalizeKenyanNumber('712345678'), '+254712345678');
      expect(normalizeKenyanNumber('+254 712 345 678'), '+254712345678');
      expect(normalizeKenyanNumber('254112345678'), '+254112345678');
    });
    test('rejects anything else', () {
      expect(normalizeKenyanNumber(''), isNull);
      expect(normalizeKenyanNumber('12345'), isNull);
      expect(normalizeKenyanNumber('0212345678'), isNull);
      expect(normalizeKenyanNumber('+255712345678'), isNull);
    });
  });

  group('components', () {
    testWidgets('method cards show both methods and report the pick', (
      tester,
    ) async {
      PaymentMethodOptionDtoMethod? picked;
      await tester.pumpAt(
        PaymentMethodPicker(
          methods: const [mpesa, card],
          selected: PaymentMethodOptionDtoMethod.mpesa,
          onChanged: (m) => picked = m,
        ),
      );
      expect(find.text('Pay with your Safaricom line'), findsOneWidget);
      expect(find.text('Visa or Mastercard'), findsOneWidget);
      await tester.tap(find.text('Card'));
      expect(picked, PaymentMethodOptionDtoMethod.card);
    });

    testWidgets('the number field has the +254 prefix and the PIN helper', (
      tester,
    ) async {
      await tester.pumpAt(
        MpesaNumberField(controller: TextEditingController()),
      );
      expect(find.text('+254'), findsOneWidget);
      expect(
        find.text("You'll get an M-Pesa prompt to confirm with your PIN."),
        findsOneWidget,
      );
    });

    testWidgets('the secure note names the processor', (tester) async {
      await tester.pumpAt(const PaymentSecureNote());
      expect(find.text('Secure payment processed by Luxaion'), findsOneWidget);
    });
  });

  group('payment flow', () {
    testWidgets('shows only the methods the server offers (Card hidden)', (
      tester,
    ) async {
      await pumpFlow(tester, FakePayments());
      expect(find.text('M-Pesa'), findsOneWidget);
      expect(find.text('Card'), findsNothing);
      expect(find.text('Atarah Pro · 1 month'), findsOneWidget);
      expect(find.text('Secure payment processed by Luxaion'), findsOneWidget);
      await finish(tester);
    });

    testWidgets(
      'Card can be picked when the server offers it, and needs no number',
      (tester) async {
        await pumpFlow(tester, FakePayments(methodList: const [mpesa, card]));
        expect(find.byType(TextField), findsOneWidget);
        await tester.tap(find.text('Card'));
        await tester.pump();
        expect(find.byType(TextField), findsNothing);
        await finish(tester);
      },
    );

    testWidgets('an empty method list says payments are not available yet', (
      tester,
    ) async {
      await pumpFlow(tester, FakePayments(methodList: const []));
      expect(find.text("Payments aren't available yet"), findsOneWidget);
      await finish(tester);
    });

    testWidgets('a bad number is refused before anything is sent', (
      tester,
    ) async {
      final repo = FakePayments();
      await pumpFlow(tester, repo);
      await enterNumberAndPay(tester, '12345');
      expect(
        find.text('Enter a Safaricom number like 0712 345 678.'),
        findsOneWidget,
      );
      expect(repo.initiateCalls, isEmpty);
      await finish(tester);
    });

    testWidgets(
      'starts the payment, waits, and shows success only when the server says so',
      (tester) async {
        final repo = FakePayments();
        PaymentDto? paid;
        await pumpFlow(tester, repo, onPaid: (p) => paid = p);
        await enterNumberAndPay(tester, '0712 345 678');
        await tester.pump();

        expect(
          repo.initiateCalls.single,
          containsPair('phone', '+254712345678'),
        );
        expect(
          repo.initiateCalls.single,
          containsPair('purpose', InitiatePaymentDtoPurpose.other),
        );
        expect(repo.initiateCalls.single, containsPair('key', 'key-1'));
        expect(find.text('Check your phone'), findsOneWidget);
        expect(
          find.text('Enter your M-Pesa PIN to pay KES 50.'),
          findsOneWidget,
        );

        // The server still says PENDING: the app keeps waiting and never decides for itself.
        await tester.pump(const Duration(milliseconds: 60));
        expect(repo.polls, isNotEmpty);
        expect(find.text('Check your phone'), findsOneWidget);
        expect(find.text('Payment received'), findsNothing);

        repo.getResults.add(
          payment(status: PaymentDtoStatus.succeeded, receipt: 'QGH7XYZ123'),
        );
        await tester.pump(const Duration(milliseconds: 60));
        await tester.pump();
        expect(find.text('Payment received'), findsOneWidget);
        expect(find.textContaining('QGH7XYZ123'), findsOneWidget);
        await tester.tap(find.text('Done'));
        expect(paid?.id, 'pay-1');
        await finish(tester);
      },
    );

    testWidgets(
      'a failure shows what to do and Try again returns to the form',
      (tester) async {
        final repo = FakePayments()
          ..getResults.add(
            payment(
              status: PaymentDtoStatus.cancelled,
              failureReason: 'You cancelled the M-Pesa prompt. Try again when you are ready.',
            ),
          );
        await pumpFlow(tester, repo);
        await enterNumberAndPay(tester, '0712345678');
        await tester.pump(const Duration(milliseconds: 60));
        await tester.pump();
        expect(
          find.text(
            'You cancelled the M-Pesa prompt. Try again when you are ready.',
          ),
          findsOneWidget,
        );
        await tester.tap(find.text('Try again'));
        await tester.pump();
        expect(find.text('Pay KES 50'), findsOneWidget);
        await finish(tester);
      },
    );

    testWidgets('a refused start shows the server message and keeps the form', (
      tester,
    ) async {
      final repo = FakePayments()
        ..initiateResult = const ApiFailure(
          code: 'PAYMENT_ERROR',
          message: 'We could not reach M-Pesa just now and you have not been charged.',
          statusCode: 502,
        );
      await pumpFlow(tester, repo);
      await enterNumberAndPay(tester, '0712345678');
      await tester.pump();
      expect(
        find.text(
          'We could not reach M-Pesa just now and you have not been charged.',
        ),
        findsOneWidget,
      );
      expect(find.text('Pay KES 50'), findsOneWidget);
      await finish(tester);
    });

    testWidgets(
      'timeout offers Try again, which sends a fresh attempt with a new key',
      (tester) async {
        final repo = FakePayments()..getResults.add(payment(timedOut: true));
        await pumpFlow(tester, repo);
        await enterNumberAndPay(tester, '0712345678');
        await tester.pump(const Duration(milliseconds: 60));
        await tester.pump();
        expect(find.text("We haven't heard from M-Pesa yet"), findsOneWidget);

        await tester.tap(find.text('Try again'));
        await tester.pump();
        await tester.pump();
        expect(repo.initiateCalls, hasLength(2));
        expect(repo.initiateCalls.last, containsPair('phone', '+254712345678'));
        expect(
          repo.initiateCalls[0]['key'],
          isNot(repo.initiateCalls[1]['key']),
        );
        await finish(tester);
      },
    );

    testWidgets(
      'a dropped connection while waiting does not fail the payment',
      (tester) async {
        final repo = FakePayments()
          ..getResults.addAll([const NetworkFailure(), const NetworkFailure()]);
        await pumpFlow(tester, repo);
        await enterNumberAndPay(tester, '0712345678');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump();
        expect(find.text('Check your phone'), findsOneWidget);
        expect(find.text('Try again'), findsNothing);
        await finish(tester);
      },
    );

    testWidgets(
      'an open payment for the same purchase is rejoined, not duplicated',
      (tester) async {
        final repo = FakePayments()
          ..initiateResult = const ApiFailure(
            code: 'CONFLICT',
            message:
                'A payment for this is already waiting for your confirmation.',
            statusCode: 409,
            details: {'paymentId': 'pay-open'},
          );
        await pumpFlow(tester, repo);
        await enterNumberAndPay(tester, '0712345678');
        await tester.pump();
        await tester.pump();
        expect(find.text('Check your phone'), findsOneWidget);
        expect(repo.polls, contains('pay-open'));
        await finish(tester);
      },
    );

    testWidgets('card: opens the provider page and waits for the server', (
      tester,
    ) async {
      final opened = <String>[];
      final repo = FakePayments(methodList: const [mpesa, card])
        ..initiateResult = payment(
          action: const PaymentActionDto(
            type: PaymentActionDtoType.redirect,
            url: 'https://pay.example.test/checkout/abc',
          ),
        );
      var n = 0;
      await tester.pumpAt(
        ProviderScope(
          overrides: [
            paymentsRepositoryProvider.overrideWithValue(repo),
            paymentPollDelayProvider.overrideWithValue(
              (_) => const Duration(milliseconds: 20),
            ),
            paymentKeyFactoryProvider.overrideWithValue(() => 'k-${++n}'),
            paymentUrlLauncherProvider.overrideWithValue((u) async {
              opened.add(u);
              return true;
            }),
          ],
          child: Scaffold(
            body: PaymentFlow(request: _request, onPaid: (_) {}),
          ),
        ),
        scaffold: false,
      );
      await tester.pump();
      await tester.pump();
      await tester.tap(find.text('Card'));
      await tester.pump();
      await tester.tap(find.text('Pay KES 50'));
      await tester.pump();
      await tester.pump();
      expect(opened, ['https://pay.example.test/checkout/abc']);
      expect(find.text('Finish paying in your browser'), findsOneWidget);
      expect(find.text('Open payment page'), findsOneWidget);
      await finish(tester);
    });
  });

  testWidgets('the payment screen without a request offers a way out', (
    tester,
  ) async {
    await tester.pumpAt(
      const ProviderScope(child: PaymentScreen(request: null)),
      scaffold: false,
    );
    expect(find.text('Nothing to pay for here'), findsOneWidget);
  });
}
