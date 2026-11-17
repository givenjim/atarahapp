import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../theme.dart';
import 'surfaces.dart';

/// The member's appearance choice. Matches the backend `appearance` preference (`LIGHT` | `DARK`).
enum AtAppearance {
  light,
  dark;

  AtAppearance get toggled => this == light ? dark : light;

  Brightness get brightness =>
      this == light ? Brightness.light : Brightness.dark;
}

/// Settings row for the appearance: sun or moon icon, the current value as subtitle,
/// tapping switches to the other appearance. State lives with the caller ([value] and
/// [onChanged]); it holds none of its own.
class AtAppearanceToggle extends StatelessWidget {
  const AtAppearanceToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.showDivider = false,
  });

  final AtAppearance value;
  final ValueChanged<AtAppearance> onChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = value == AtAppearance.light
        ? l10n.appearanceLight
        : l10n.appearanceDark;
    return AtListRow(
      title: l10n.appearanceLabel,
      subtitle: current,
      icon: value == AtAppearance.light ? LucideIcons.sun : LucideIcons.moon,
      tone: AtTone.primary,
      showChevron: false,
      showDivider: showDivider,
      onTap: () => onChanged(value.toggled),
    );
  }
}
