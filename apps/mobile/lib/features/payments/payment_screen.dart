import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/networking/failures.dart';
import '../../core/routing/routes.dart';
import '../account/account_common.dart' show SubPage;
import 'payment_models.dart';
import 'payment_widgets.dart';
import 'payments_providers.dart';

/// The payment screen (prototype `pay`). Membership and mentorship open it with
/// `context.push<PaymentOutcome>(Routes.pay, extra: PaymentRequest(...))` and get a [PaymentOutcome] back when the server
/// confirmed the payment, or `null` when the member left.
class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key, required this.request});

  /// The route's `extra`. Null (a deep link, a restored route) shows a way out instead of an empty form.
  final PaymentRequest? request;

  @override
  Widget build(BuildContext context) {
    final req = request;
    return SubPage(
      title: PaymentStrings.screenTitle,
      backTo: Routes.home,
      child: req == null
          ? AtEmptyState(
              icon: LucideIcons.creditCard,
              title: 'Nothing to pay for here',
              body: 'Start from the thing you want to pay for.',
              ctaLabel: 'Go home',
              onCta: () => context.go(Routes.home),
            )
          : PaymentFlow(
              request: req,
              onPaid: (p) => context.canPop()
                  ? context.pop(PaymentOutcome(p))
                  : context.go(Routes.home),
            ),
    );
  }
}

/// The whole payment experience as one widget: pick a method, enter the number, wait for the prompt, see the result.
/// Reused by the payment screen and by any screen that wants the flow inline.
class PaymentFlow extends ConsumerStatefulWidget {
  const PaymentFlow({
    super.key,
    required this.request,
    required this.onPaid,
    this.initialPhone,
  });

  final PaymentRequest request;

  /// Called with the confirmed payment when the member taps Done.
  final ValueChanged<PaymentDto> onPaid;

  /// A number to start with (the member's own, when known).
  final String? initialPhone;

  @override
  ConsumerState<PaymentFlow> createState() => _PaymentFlowState();
}

class _PaymentFlowState extends ConsumerState<PaymentFlow> {
  late final TextEditingController _phone = TextEditingController(
    text: widget.initialPhone ?? '',
  );
  PaymentMethodOptionDtoMethod? _method;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  InitiatePaymentDtoMethod _wire(PaymentMethodOptionDtoMethod m) =>
      m == PaymentMethodOptionDtoMethod.card
      ? InitiatePaymentDtoMethod.card
      : InitiatePaymentDtoMethod.mpesa;

  void _pay(PaymentMethodOptionDtoMethod method) {
    FocusScope.of(context).unfocus();
    ref
        .read(paymentFlowProvider.notifier)
        .start(widget.request, method: _wire(method), phone: _phone.text);
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(paymentFlowProvider);
    final methods = ref.watch(paymentMethodsProvider);
    final amount = widget.request.amountLabel;
    final controller = ref.read(paymentFlowProvider.notifier);

    return switch (flow) {
      PaymentWaiting() => _scroll(
        PaymentWaitingView(
          amountLabel: amount,
          timedOut: flow.timedOut,
          isCard: flow.redirectUrl != null,
          onTryAgain: controller.tryAgain,
          onReopen: flow.redirectUrl == null
              ? null
              : () => ref.read(paymentUrlLauncherProvider)(flow.redirectUrl!),
        ),
      ),
      PaymentDone() => _scroll(
        PaymentSuccessView(
          payment: flow.payment,
          amountLabel: amount,
          onDone: () => widget.onPaid(flow.payment),
        ),
      ),
      PaymentFailedState() => _scroll(
        PaymentFailureView(message: flow.message, onTryAgain: controller.retry),
      ),
      _ => methods.when(
        loading: () => const AtLoadingBody(),
        error: (e, _) => AtErrorState(
          title: PaymentStrings.loadFailedTitle,
          body: e is AppFailure ? e.message : const UnexpectedFailure().message,
          ctaLabel: PaymentStrings.retry,
          onCta: () => ref.invalidate(paymentMethodsProvider),
        ),
        data: (list) => list.isEmpty
            ? const AtEmptyState(
                icon: LucideIcons.creditCard,
                title: PaymentStrings.noMethodsTitle,
                body: PaymentStrings.noMethodsBody,
              )
            : _form(list, flow),
      ),
    };
  }

  Widget _scroll(Widget child) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(
      AtSpacing.gutter,
      8,
      AtSpacing.gutter,
      AtSpacing.gutter,
    ),
    child: child,
  );

  Widget _form(List<PaymentMethodOptionDto> methods, PaymentFlowState flow) {
    // The first method the server offers until the member picks one.
    final selected = _method ?? methods.first.method;
    final submitting = flow is PaymentSubmitting;
    final error = flow is PaymentIdle ? flow.error : null;
    final isMpesa = selected == PaymentMethodOptionDtoMethod.mpesa;
    return _scroll(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PaymentSummaryCard(request: widget.request),
          const SizedBox(height: 20),
          Text(
            PaymentStrings.methodHeading,
            style: AtTextStyles.label.copyWith(color: context.at.ink),
          ),
          const SizedBox(height: 8),
          PaymentMethodPicker(
            methods: methods,
            selected: selected,
            enabled: !submitting,
            onChanged: (m) => setState(() => _method = m),
          ),
          if (isMpesa) ...[
            const SizedBox(height: 8),
            MpesaNumberField(controller: _phone, enabled: !submitting),
          ],
          if (error != null) ...[
            const SizedBox(height: 16),
            AtInlineBanner(message: error),
          ],
          const SizedBox(height: 20),
          AtButton(
            label: PaymentStrings.pay(widget.request.amountLabel),
            loading: submitting,
            onPressed: submitting ? null : () => _pay(selected),
          ),
          const SizedBox(height: 20),
          const PaymentSecureNote(),
        ],
      ),
    );
  }
}
