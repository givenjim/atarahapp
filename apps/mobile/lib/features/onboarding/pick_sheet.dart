import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';

class PickOption {
  const PickOption(this.id, this.label);

  final String id;
  final String label;
}

/// A tappable field that looks like the prototype's select (label above, value with a chevron).
class PickerField extends StatelessWidget {
  const PickerField({
    super.key,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
    this.errorText,
  });

  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback? onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AtTextStyles.label.copyWith(color: AtColors.ink)),
        const SizedBox(height: 7),
        Semantics(
          button: true,
          label: '$label, ${hasValue ? value : placeholder}',
          excludeSemantics: true,
          onTap: onTap,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 52),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AtColors.inputFill,
                borderRadius: AtRadii.input,
                border: Border.all(
                  color: errorText == null
                      ? AtColors.inputBorder
                      : AtColors.pinkFg,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      hasValue ? value! : placeholder,
                      style: AtTextStyles.bodyLg.copyWith(
                        color: hasValue ? AtColors.ink : AtColors.faint,
                      ),
                    ),
                  ),
                  const Icon(
                    LucideIcons.chevronDown,
                    size: 18,
                    color: AtColors.muted,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Semantics(
              liveRegion: true,
              child: Text(
                errorText!,
                style: AtTextStyles.meta.copyWith(color: AtColors.pinkStrong),
              ),
            ),
          ),
      ],
    );
  }
}

/// Bottom sheet list. Returns the chosen id, or null when dismissed. Long lists get a search box.
Future<String?> showPickSheet(
  BuildContext context, {
  required String title,
  required List<PickOption> options,
  String? selectedId,
  bool searchable = false,
}) {
  return showAtBottomSheet<String>(
    context: context,
    title: title,
    builder: (_) => PickSheetBody(
      options: options,
      selectedId: selectedId,
      searchable: searchable,
    ),
  );
}

class PickSheetBody extends StatefulWidget {
  const PickSheetBody({
    super.key,
    required this.options,
    required this.selectedId,
    required this.searchable,
  });

  final List<PickOption> options;
  final String? selectedId;
  final bool searchable;

  @override
  State<PickSheetBody> createState() => _PickSheetBodyState();
}

class _PickSheetBodyState extends State<PickSheetBody> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final q = _query.trim().toLowerCase();
    final shown = q.isEmpty
        ? widget.options
        : widget.options
              .where((o) => o.label.toLowerCase().contains(q))
              .toList();
    final height = MediaQuery.sizeOf(context).height * 0.55;
    return SizedBox(
      height: height,
      child: Column(
        children: [
          if (widget.searchable)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AtSpacing.gutter,
                4,
                AtSpacing.gutter,
                8,
              ),
              child: AtTextField(
                hint: l10n.obSearch,
                semanticLabel: l10n.obSearch,
                prefixIcon: LucideIcons.search,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
          Expanded(
            child: shown.isEmpty
                ? Center(
                    child: Text(
                      l10n.obNoResults,
                      style: AtTextStyles.bodySm.copyWith(
                        color: AtColors.muted,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: shown.length,
                    itemBuilder: (context, i) {
                      final o = shown[i];
                      final selected = o.id == widget.selectedId;
                      return Semantics(
                        button: true,
                        selected: selected,
                        label: o.label,
                        excludeSemantics: true,
                        onTap: () => Navigator.of(context).pop(o.id),
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(o.id),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 52),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AtSpacing.gutter,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    o.label,
                                    style: AtTextStyles.bodyLg.copyWith(
                                      color: AtColors.ink,
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (selected)
                                  const Icon(
                                    LucideIcons.check,
                                    size: 18,
                                    color: AtColors.primary,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
