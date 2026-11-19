import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import 'payment_models.dart';

/// Strings for the payment components. They are shared by membership and mentorship, so they live here once.
abstract final class PaymentStrings {
  static const screenTitle = 'Payment';
  static const methodHeading = 'Pay with';
  static const mpesaLabel = 'M-Pesa number';
  static const mpesaHint = '712 345 678';
  static const mpesaHelper =
      "You'll get an M-Pesa prompt to confirm with your PIN.";
  static const secureNote = 'Secure payment processed by Luxaion';
  static const waitingTitle = 'Check your phone';
  static const waitingCardTitle = 'Finish paying in your browser';
  static const waitingCardBody =
      "Complete the payment on the page that opened. We'll update this screen when it is confirmed.";
  static const waitingFooter =
      "We'll update this screen as soon as M-Pesa confirms. Don't close the app.";
  static const timedOutTitle = "We haven't heard from M-Pesa yet";
  static const timedOutBody =
      'If you already entered your PIN, wait a moment: we keep checking. Otherwise tap Try again to get a new prompt.';
  static const tryAgain = 'Try again';
  static const successTitle = 'Payment received';
  static const done = 'Done';
  static const noMethodsTitle = "Payments aren't available yet";
  static const noMethodsBody =
      'Please try again later. You have not been charged.';
  static const loadFailedTitle = "Couldn't load payment options";
  static const retry = 'Try again';

  static String waitingBody(String amount) =>
      'Enter your M-Pesa PIN to pay $amount.';
  static String pay(String amount) => 'Pay $amount';
}

IconData methodIcon(PaymentMethodOptionDtoMethod m) =>
    m == PaymentMethodOptionDtoMethod.card
    ? LucideIcons.creditCard
    : LucideIcons.smartphone;

/// The method radio cards: M-Pesa "Pay with your Safaricom line", Card "Visa or Mastercard". Shows exactly the methods the
/// server offers, so Card is absent while the card provider is not connected.
class PaymentMethodPicker extends StatelessWidget {
  const PaymentMethodPicker({
    super.key,
    required this.methods,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  final List<PaymentMethodOptionDto> methods;
  final PaymentMethodOptionDtoMethod? selected;
  final ValueChanged<PaymentMethodOptionDtoMethod> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final m in methods) ...[
          AtRadioCard(
            title: m.label,
            subtitle: m.description,
            selected: m.method == selected,
            onTap: enabled ? () => onChanged(m.method) : null,
            leading: AtIconTile(
              icon: methodIcon(m.method),
              tone: m.method == PaymentMethodOptionDtoMethod.card
                  ? AtTone.indigo
                  : AtTone.violet,
              size: 40,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

/// The `+254` number field with its helper line. Accepts `0712 345 678`, `712345678` or a pasted `+254712345678`.
class MpesaNumberField extends StatelessWidget {
  const MpesaNumberField({
    super.key,
    required this.controller,
    this.errorText,
    this.enabled = true,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? errorText;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return AtTextField(
      label: PaymentStrings.mpesaLabel,
      hint: PaymentStrings.mpesaHint,
      prefixText: '+254',
      controller: controller,
      enabled: enabled,
      errorText: errorText,
      helperText: PaymentStrings.mpesaHelper,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.telephoneNumberNational],
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
        LengthLimitingTextInputFormatter(16),
      ],
      onChanged: onChanged,
      semanticLabel: PaymentStrings.mpesaLabel,
    );
  }
}

/// "Secure payment processed by Luxaion". "Luxaion" is named only because it is the payment processor.
class PaymentSecureNote extends StatelessWidget {
  const PaymentSecureNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(LucideIcons.lock, size: 14, color: context.at.muted),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            PaymentStrings.secureNote,
            style: AtTextStyles.meta.copyWith(color: context.at.muted),
          ),
        ),
      ],
    );
  }
}

/// What is being bought and for how much, above the method picker.
class PaymentSummaryCard extends StatelessWidget {
  const PaymentSummaryCard({super.key, required this.request});

  final PaymentRequest request;

  @override
  Widget build(BuildContext context) {
    return AtCard(
      semanticLabel:
          '${request.title}, ${request.amountLabel}'
          '${request.subtitle == null ? '' : ', ${request.subtitle}'}',
      labelReplacesContent: true,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.title,
                  style: AtTextStyles.cardTitle.copyWith(color: context.at.ink),
                ),
                if (request.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    request.subtitle!,
                    style: AtTextStyles.meta.copyWith(color: context.at.muted),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            request.amountLabel,
            style: AtTextStyles.sectionTitleSm.copyWith(color: context.at.ink),
          ),
        ],
      ),
    );
  }
}

/// The waiting state while the prompt is open. The screen polls the server; [onTryAgain] appears once the time limit has
/// passed, and the server keeps checking in the meantime.
class PaymentWaitingView extends StatelessWidget {
  const PaymentWaitingView({
    super.key,
    required this.amountLabel,
    required this.timedOut,
    required this.onTryAgain,
    this.isCard = false,
    this.onReopen,
  });

  final String amountLabel;
  final bool timedOut;
  final VoidCallback onTryAgain;
  final bool isCard;

  /// Card: opens the payment page again.
  final VoidCallback? onReopen;

  @override
  Widget build(BuildContext context) {
    final title = timedOut
        ? PaymentStrings.timedOutTitle
        : (isCard
              ? PaymentStrings.waitingCardTitle
              : PaymentStrings.waitingTitle);
    final body = timedOut
        ? PaymentStrings.timedOutBody
        : (isCard
              ? PaymentStrings.waitingCardBody
              : PaymentStrings.waitingBody(amountLabel));
    return Semantics(
      liveRegion: true,
      container: true,
      child: Column(
        children: [
          const SizedBox(height: 24),
          if (!timedOut)
            const SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(strokeWidth: 3.2),
            )
          else
            const AtIconTile(
              icon: LucideIcons.clock,
              tone: AtTone.amber,
              size: 56,
            ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AtTextStyles.sectionTitle.copyWith(color: context.at.ink),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: AtTextStyles.body.copyWith(color: context.at.muted),
          ),
          if (!timedOut && !isCard) ...[
            const SizedBox(height: 16),
            Text(
              PaymentStrings.waitingFooter,
              textAlign: TextAlign.center,
              style: AtTextStyles.meta.copyWith(color: context.at.muted),
            ),
          ],
          if (isCard && onReopen != null) ...[
            const SizedBox(height: 16),
            AtButton(
              label: 'Open payment page',
              variant: AtButtonVariant.secondary,
              onPressed: onReopen,
            ),
          ],
          if (timedOut) ...[
            const SizedBox(height: 20),
            AtButton(label: PaymentStrings.tryAgain, onPressed: onTryAgain),
          ],
        ],
      ),
    );
  }
}

/// The payment went through.
class PaymentSuccessView extends StatelessWidget {
  const PaymentSuccessView({
    super.key,
    required this.payment,
    required this.amountLabel,
    required this.onDone,
  });

  final PaymentDto payment;
  final String amountLabel;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final receipt = payment.receiptNumber;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Column(
        children: [
          const SizedBox(height: 24),
          const AtIconTile(
            icon: LucideIcons.circleCheck,
            tone: AtTone.success,
            size: 64,
          ),
          const SizedBox(height: 20),
          Text(
            PaymentStrings.successTitle,
            style: AtTextStyles.sectionTitle.copyWith(color: context.at.ink),
          ),
          const SizedBox(height: 8),
          Text(
            receipt == null
                ? amountLabel
                : '$amountLabel · M-Pesa receipt $receipt',
            textAlign: TextAlign.center,
            style: AtTextStyles.body.copyWith(color: context.at.muted),
          ),
          const SizedBox(height: 24),
          AtButton(label: PaymentStrings.done, onPressed: onDone),
        ],
      ),
    );
  }
}

/// The payment did not go through. [message] comes from the server and says what to do next.
class PaymentFailureView extends StatelessWidget {
  const PaymentFailureView({
    super.key,
    required this.message,
    required this.onTryAgain,
  });

  final String message;
  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        AtInlineBanner(message: message),
        const SizedBox(height: 20),
        AtButton(label: PaymentStrings.tryAgain, onPressed: onTryAgain),
      ],
    );
  }
}
