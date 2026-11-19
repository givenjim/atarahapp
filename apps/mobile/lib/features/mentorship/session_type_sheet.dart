import 'package:flutter/material.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import 'mentorship_common.dart';

/// Opens the session type form. Answers the values the mentor entered (null if dismissed). Used by the application
/// (proposed sessions) and by Mentor tools (create and edit).
Future<SessionTypeFieldsDto?> showSessionTypeSheet(
  BuildContext context, {
  SessionTypeFieldsDto? initial,
}) => showAtBottomSheet<SessionTypeFieldsDto>(
  context: context,
  title: initial == null
      ? AppLocalizations.of(context).mnNewSessionType
      : AppLocalizations.of(context).mnEditSessionType,
  builder: (_) => _SessionTypeForm(initial: initial),
);

class _SessionTypeForm extends StatefulWidget {
  const _SessionTypeForm({this.initial});

  final SessionTypeFieldsDto? initial;

  @override
  State<_SessionTypeForm> createState() => _SessionTypeFormState();
}

class _SessionTypeFormState extends State<_SessionTypeForm> {
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _description = TextEditingController(
    text: widget.initial?.description,
  );
  late final _duration = TextEditingController(
    text: widget.initial?.durationMinutes.toInt().toString() ?? '45',
  );
  late final _price = TextEditingController(
    text: widget.initial == null
        ? ''
        : minorToMajorText(widget.initial!.priceMinor),
  );
  late final _count = TextEditingController(
    text: (widget.initial?.sessionCount ?? 1).toInt().toString(),
  );
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _duration.dispose();
    _price.dispose();
    _count.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    final minutes = int.tryParse(_duration.text.trim());
    final price = parseMajorToMinor(_price.text);
    final count = int.tryParse(_count.text.trim()) ?? 1;
    String? error;
    if (name.length < 2) {
      error = l10n.mnErrName;
    } else if (minutes == null || minutes < 15 || minutes > 480) {
      error = l10n.mnErrDuration;
    } else if (price == null) {
      error = l10n.mnErrPrice;
    } else if (count < 1 || count > 24) {
      error = l10n.mnErrCount;
    }
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    final description = _description.text.trim();
    Navigator.of(context).pop(
      SessionTypeFieldsDto(
        name: name,
        description: description.isEmpty ? null : description,
        durationMinutes: minutes!,
        priceMinor: price!,
        sessionCount: count,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AtSpacing.gutter,
        0,
        AtSpacing.gutter,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null) ...[
            AtInlineBanner(message: _error!),
            const SizedBox(height: 12),
          ],
          AtTextField(
            label: l10n.mnSessionName,
            controller: _name,
            maxLength: 80,
          ),
          const SizedBox(height: 12),
          AtTextField(
            label: l10n.mnSessionDescription,
            controller: _description,
            minLines: 2,
            maxLines: 4,
            maxLength: 500,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AtTextField(
                  label: l10n.mnDurationMinutes,
                  controller: _duration,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AtTextField(
                  label: l10n.mnPriceKes,
                  controller: _price,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AtTextField(
            label: l10n.mnSessionCount,
            helperText: l10n.mnSessionCountHelp,
            controller: _count,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          AtButton(label: l10n.mnSave, onPressed: _submit),
        ],
      ),
    );
  }
}
