import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../tokens.g.dart';
import 'at_tap_target.dart';

/// 52-high text field with the Atarah focus ring (`#7b6cf6` plus a 4px `#efecff` halo) and an error state.
/// Supports a leading prefix such as "+254", "KES" or "atarah.app/".
class AtTextField extends StatefulWidget {
  const AtTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.prefixText,
    this.prefixIcon,
    this.suffix,
    this.errorText,
    this.helperText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLength,
    this.showCounter = false,
    this.minLines = 1,
    this.maxLines = 1,
    this.inputFormatters,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    this.semanticLabel,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? prefixText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final String? errorText;
  final String? helperText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final int? maxLength;

  /// Show "n / max" under the field (e.g. the 160-character bio).
  final bool showCounter;
  final int minLines;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? semanticLabel;

  @override
  State<AtTextField> createState() => _AtTextFieldState();
}

class _AtTextFieldState extends State<AtTextField> {
  late final FocusNode _focus = widget.focusNode ?? FocusNode();
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
    _controller.addListener(_onText);
  }

  void _onFocus() => setState(() => _focused = _focus.hasFocus);
  void _onText() {
    if (widget.showCounter) setState(() {});
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _controller.removeListener(_onText);
    if (widget.focusNode == null) _focus.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final multiline = widget.maxLines > 1;
    final borderColor = hasError
        ? AtColors.pinkFg
        : _focused
        ? AtColors.primaryLight
        : AtColors.inputBorder;

    final field = AnimatedContainer(
      duration: atDuration(context, AtMotion.fast),
      // Exactly 52 high for one line; multi-line fields grow from a 52 minimum.
      height: multiline ? null : AtSizes.input,
      constraints: multiline
          ? const BoxConstraints(minHeight: AtSizes.input)
          : null,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: multiline ? 14 : 0,
      ),
      decoration: BoxDecoration(
        color: widget.enabled ? AtColors.inputFill : AtColors.softTile,
        borderRadius: AtRadii.input,
        border: Border.all(
          color: borderColor,
          width: _focused || hasError ? 1.5 : 1,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: hasError ? AtColors.pinkBg : AtColors.focusRing,
                  spreadRadius: 4,
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: multiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          if (widget.prefixIcon != null) ...[
            Icon(widget.prefixIcon, size: 18, color: AtColors.muted),
            const SizedBox(width: 10),
          ],
          if (widget.prefixText != null) ...[
            // Loose flex (flex 0 would be non-flexible): at very large text sizes the prefix shrinks with an
            // ellipsis instead of overflowing.
            Flexible(
              child: Text(
                widget.prefixText!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AtTextStyles.body.copyWith(
                  color: AtColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              minLines: widget.minLines,
              maxLines: widget.obscureText ? 1 : widget.maxLines,
              maxLength: widget.maxLength,
              inputFormatters: widget.inputFormatters,
              autofillHints: widget.autofillHints,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              cursorColor: AtColors.primary,
              textAlignVertical: TextAlignVertical.center,
              style: AtTextStyles.body.copyWith(color: AtColors.ink),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                counterText: '',
                hintText: widget.hint,
                hintStyle: AtTextStyles.body.copyWith(color: AtColors.muted),
                // The editable node itself is the full field height, so it is a proper tap target.
                constraints: BoxConstraints(
                  minHeight: multiline ? AtSizes.input - 28 : AtSizes.input - 2,
                  maxHeight: multiline ? double.infinity : AtSizes.input - 2,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (widget.suffix != null) ...[
            const SizedBox(width: 8),
            widget.suffix!,
          ],
        ],
      ),
    );

    final below = <Widget>[];
    if (hasError) {
      below.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                LucideIcons.circleAlert,
                size: 14,
                color: AtColors.pinkStrong,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                widget.errorText!,
                style: AtTextStyles.meta.copyWith(color: AtColors.pinkStrong),
              ),
            ),
          ],
        ),
      );
    } else if (widget.helperText != null) {
      below.add(
        Text(
          widget.helperText!,
          style: AtTextStyles.meta.copyWith(color: AtColors.muted),
        ),
      );
    }
    if (widget.showCounter && widget.maxLength != null) {
      below.add(
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${_controller.text.characters.length} / ${widget.maxLength}',
            style: AtTextStyles.meta.copyWith(color: AtColors.muted),
          ),
        ),
      );
    }

    return Semantics(
      textField: true,
      label: widget.semanticLabel ?? widget.label,
      hint: widget.hint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: AtTextStyles.chip.copyWith(color: AtColors.ink),
            ),
            const SizedBox(height: 8),
          ],
          field,
          for (final w in below) ...[const SizedBox(height: 6), w],
        ],
      ),
    );
  }
}

/// How strong a password looks (Atarah's rule: "Strong — 8+ characters with a number").
enum AtPasswordStrength { empty, weak, ok, strong }

/// Score 0..4 shown by the 4-segment meter, and its [AtPasswordStrength].
({int score, AtPasswordStrength level}) evaluatePassword(String p) {
  if (p.isEmpty) return (score: 0, level: AtPasswordStrength.empty);
  final longEnough = p.length >= 8;
  final hasDigit = RegExp(r'\d').hasMatch(p);
  final mixedCase =
      RegExp(r'[a-z]').hasMatch(p) && RegExp(r'[A-Z]').hasMatch(p);
  final extra = RegExp(r'[^A-Za-z0-9]').hasMatch(p) || p.length >= 12;
  final score =
      (longEnough ? 1 : 0) +
      (hasDigit ? 1 : 0) +
      (longEnough && mixedCase ? 1 : 0) +
      (longEnough && extra ? 1 : 0);
  final level = longEnough && hasDigit
      ? AtPasswordStrength.strong
      : (longEnough || hasDigit)
      ? AtPasswordStrength.ok
      : AtPasswordStrength.weak;
  return (score: score.clamp(1, 4), level: level);
}

/// Four-segment strength meter with its message. Colour is never the only indicator: the text states the level.
class AtPasswordStrengthMeter extends StatelessWidget {
  const AtPasswordStrengthMeter({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final e = evaluatePassword(password);
    if (e.level == AtPasswordStrength.empty) return const SizedBox.shrink();
    final color = switch (e.level) {
      AtPasswordStrength.weak => AtColors.pinkFg,
      AtPasswordStrength.ok => AtColors.warningFg,
      _ => AtColors.successFg,
    };
    final text = switch (e.level) {
      AtPasswordStrength.weak => l10n.passwordStrengthWeak,
      AtPasswordStrength.ok => l10n.passwordStrengthOk,
      _ => l10n.passwordStrengthStrong,
    };
    final textColor = switch (e.level) {
      AtPasswordStrength.weak => AtColors.pinkStrong,
      AtPasswordStrength.ok => AtColors.warningStrong,
      _ => AtColors.successStrong,
    };
    return Semantics(
      liveRegion: true,
      label: text,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < 4; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: i < e.score ? color : AtColors.progressTrack,
                      borderRadius: AtRadii.pill,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(text, style: AtTextStyles.meta.copyWith(color: textColor)),
        ],
      ),
    );
  }
}

/// Password field with show/hide and the strength meter.
class AtPasswordField extends StatefulWidget {
  const AtPasswordField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.errorText,
    this.showStrength = false,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? errorText;
  final bool showStrength;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AtPasswordField> createState() => _AtPasswordFieldState();
}

class _AtPasswordFieldState extends State<AtPasswordField> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  bool _visible = false;
  String _value = '';

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AtTextField(
          label: widget.label,
          hint: widget.hint,
          controller: _controller,
          obscureText: !_visible,
          errorText: widget.errorText,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: widget.textInputAction,
          autofillHints: const [AutofillHints.password],
          onSubmitted: widget.onSubmitted,
          onChanged: (v) {
            setState(() => _value = v);
            widget.onChanged?.call(v);
          },
          suffix: AtTapTarget(
            semanticLabel: _visible ? l10n.hidePassword : l10n.showPassword,
            onTap: () => setState(() => _visible = !_visible),
            child: Icon(
              _visible ? LucideIcons.eyeOff : LucideIcons.eye,
              size: 18,
              color: AtColors.muted,
            ),
          ),
        ),
        if (widget.showStrength) ...[
          const SizedBox(height: 10),
          AtPasswordStrengthMeter(password: _value),
        ],
      ],
    );
  }
}

/// Six boxes for a one-time code. One hidden field captures typing and paste; the boxes mirror it.
class AtCodeInput extends StatefulWidget {
  const AtCodeInput({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.hasError = false,
    this.autofocus = false,
    this.controller,
  });

  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool hasError;
  final bool autofocus;
  final TextEditingController? controller;

  @override
  State<AtCodeInput> createState() => _AtCodeInputState();
}

class _AtCodeInputState extends State<AtCodeInput> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _changed(String v) {
    setState(() {});
    widget.onChanged?.call(v);
    if (v.length == widget.length) widget.onCompleted?.call(v);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = _controller.text;
    return Semantics(
      textField: true,
      label: l10n.codeDigit(
        text.length.clamp(0, widget.length - 1) + 1,
        widget.length,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _focus.requestFocus(),
        child: Stack(
          children: [
            Row(
              children: [
                for (var i = 0; i < widget.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: _box(i, text)),
                ],
              ],
            ),
            // Invisible, full-size field: handles keyboard, paste and the one-time-code autofill.
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  autofocus: widget.autofocus,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  maxLength: widget.length,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  enableInteractiveSelection: false,
                  onChanged: _changed,
                  decoration: const InputDecoration(counterText: ''),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _box(int i, String text) {
    final filled = i < text.length;
    final active =
        _focus.hasFocus && i == text.length.clamp(0, widget.length - 1);
    final color = widget.hasError
        ? AtColors.pinkFg
        : active
        ? AtColors.primaryLight
        : filled
        ? AtColors.secondaryBorder
        : AtColors.inputBorder;
    return AspectRatio(
      aspectRatio: 0.82,
      child: Container(
        decoration: BoxDecoration(
          color: filled ? AtColors.tint3 : AtColors.inputFill,
          borderRadius: AtRadii.input,
          border: Border.all(
            color: color,
            width: active || widget.hasError ? 1.5 : 1,
          ),
          boxShadow: active
              ? const [BoxShadow(color: AtColors.focusRing, spreadRadius: 3)]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          filled ? text[i] : '',
          style: AtTextStyles.sectionTitle.copyWith(color: AtColors.ink),
        ),
      ),
    );
  }
}

/// 22×22 checkbox with an optional tappable label.
class AtCheckbox extends StatelessWidget {
  const AtCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.labelWidget,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final Widget? labelWidget;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final box = AnimatedContainer(
      duration: atDuration(context, AtMotion.fast),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: value ? AtColors.primary : AtColors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: value ? AtColors.primary : AtColors.secondaryBorder,
          width: 1.5,
        ),
      ),
      child: value
          ? const Icon(LucideIcons.check, size: 14, color: AtColors.white)
          : null,
    );
    return Semantics(
      checked: value,
      enabled: onChanged != null,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: InkWell(
        borderRadius: AtRadii.input,
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AtSizes.touchTarget),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                child: box,
              ),
              if (label != null || labelWidget != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child:
                      labelWidget ??
                      Text(
                        label!,
                        style: AtTextStyles.bodySm.copyWith(
                          color: AtColors.body,
                        ),
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 48×28 toggle.
class AtToggle extends StatelessWidget {
  const AtToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final duration = atDuration(context, AtMotion.base);
    return Semantics(
      toggled: value,
      enabled: onChanged != null,
      label: semanticLabel,
      excludeSemantics: true,
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: AtSizes.touchTarget,
            minHeight: AtSizes.touchTarget,
          ),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: AnimatedContainer(
              duration: duration,
              width: AtSizes.toggleWidth,
              height: AtSizes.toggleHeight,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: value ? AtColors.primary : AtColors.toggleOff,
                borderRadius: AtRadii.pill,
              ),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AtColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(21, 19, 61, 0.2),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A selectable card with a radio dot (visibility choices, session types, payment methods).
class AtRadioCard extends StatelessWidget {
  const AtRadioCard({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.leading,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: [title, ?subtitle].join(', '),
      excludeSemantics: true,
      onTap: onTap,
      child: AnimatedContainer(
        duration: atDuration(context, AtMotion.fast),
        decoration: BoxDecoration(
          color: selected ? AtColors.tint3 : AtColors.white,
          borderRadius: AtRadii.cardLg,
          border: Border.all(
            color: selected ? AtColors.primaryLight : AtColors.cardBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: AtRadii.cardLg,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 64),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AtTextStyles.cardTitle.copyWith(
                              color: AtColors.ink,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              style: AtTextStyles.meta.copyWith(
                                color: AtColors.muted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 8),
                      trailing!,
                    ],
                    const SizedBox(width: 10),
                    _RadioDot(selected: selected),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
    width: 22,
    height: 22,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: AtColors.white,
      border: Border.all(
        color: selected ? AtColors.primary : AtColors.secondaryBorder,
        width: selected ? 6.5 : 1.5,
      ),
    ),
  );
}

/// Pill segmented control (All / Closing soon / Applied / Completed). Each segment is a 48px-high tap
/// target; the selected pill inside it is 40 high.
class AtSegmented extends StatelessWidget {
  const AtSegmented({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AtColors.segmentedTrack,
        borderRadius: AtRadii.pill,
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == selectedIndex,
                label: labels[i],
                excludeSemantics: true,
                onTap: () => onChanged(i),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(i),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: AtSizes.touchTarget,
                    ),
                    child: Center(
                      child: AnimatedContainer(
                        duration: atDuration(context, AtMotion.fast),
                        constraints: const BoxConstraints(minHeight: 40),
                        margin: const EdgeInsets.all(4),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: i == selectedIndex
                              ? AtColors.white
                              : Colors.transparent,
                          borderRadius: AtRadii.pill,
                          boxShadow: i == selectedIndex ? AtShadows.card : null,
                        ),
                        child: Text(
                          labels[i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AtTextStyles.chip.copyWith(
                            color: i == selectedIndex
                                ? AtColors.primary
                                : AtColors.muted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
