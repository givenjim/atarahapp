import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/design_system/design_system.dart';

/// The five-tab shell (Home, Explore, Community, Opportunities, Profile). Each tab keeps its own navigation
/// stack. Detail, creation and settings screens are routed outside the shell, so the tab bar hides on them
/// (the prototype's `NO_TABS` list).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return AtTabShell(
      body: shell,
      selectedIndex: shell.currentIndex,
      // Tapping the current tab returns to its root.
      onSelected: (i) =>
          shell.goBranch(i, initialLocation: i == shell.currentIndex),
    );
  }
}
