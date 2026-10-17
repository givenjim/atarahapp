import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/notices/app_notice.dart';

/// The five-tab shell (Home, Explore, Community, Opportunities, Profile). Each tab keeps its own navigation
/// stack. Detail, creation and settings screens are routed outside the shell, so the tab bar hides on them
/// (the prototype's `NO_TABS` list). It also shows one-time notices queued before navigation, such as
/// "Password updated. You were signed out of your other devices." as a banner at the top, so it never covers
/// the tab bar.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Also fires for a notice queued before this shell existed (sign-in completes, then the notice is set).
    ref.listenManual<String?>(appNoticeProvider, fireImmediately: true, (
      _,
      message,
    ) {
      if (message == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _show(message);
        ref.read(appNoticeProvider.notifier).clear();
      });
    });
  }

  void _show(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(
        MaterialBanner(
          backgroundColor: AtColors.successBg,
          leading: const Icon(
            LucideIcons.circleCheck,
            color: AtColors.successStrong,
          ),
          content: Text(
            message,
            style: AtTextStyles.bodySm.copyWith(color: AtColors.successStrong),
          ),
          actions: [
            TextButton(
              onPressed: messenger.hideCurrentMaterialBanner,
              child: Text(AppLocalizations.of(context).close),
            ),
          ],
        ),
      );
    // A notice informs; it should not linger. The close button dismisses it sooner.
    _hideTimer?.cancel();
    _hideTimer = Timer(
      const Duration(seconds: 8),
      messenger.hideCurrentMaterialBanner,
    );
  }

  @override
  Widget build(BuildContext context) {
    final shell = widget.shell;
    return AtTabShell(
      body: shell,
      selectedIndex: shell.currentIndex,
      // Tapping the current tab returns to its root.
      onSelected: (i) =>
          shell.goBranch(i, initialLocation: i == shell.currentIndex),
    );
  }
}
