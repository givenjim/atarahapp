import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/session_controller.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';

/// Brand splash shown while the stored session is checked. If the check fails (usually offline) it says so
/// and offers a retry instead of leaving the member on a spinner.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final failed = ref.watch(sessionStatusProvider) == SessionStatus.failed;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AtGradients.splash),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Ribbon artwork from the design prototype (placeholder until licensed brand art is supplied).
            Image.asset(
              'assets/images/ribbon.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.28),
              excludeFromSemantics: true,
            ),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AtWordmark(
                        color: AtColors.white,
                        accent: AtColors.violet3,
                        taglineColor: Color.fromRGBO(255, 255, 255, 0.75),
                        size: 34,
                        alignment: CrossAxisAlignment.center,
                      ),
                      const SizedBox(height: 40),
                      if (!failed)
                        Semantics(
                          label: l10n.splashCheckingTitle,
                          liveRegion: true,
                          child: const SizedBox(
                            width: 140,
                            child: ClipRRect(
                              borderRadius: AtRadii.pill,
                              child: LinearProgressIndicator(
                                minHeight: 4,
                                color: AtColors.white,
                                backgroundColor: Color.fromRGBO(
                                  255,
                                  255,
                                  255,
                                  0.25,
                                ),
                              ),
                            ),
                          ),
                        )
                      else ...[
                        Semantics(
                          liveRegion: true,
                          header: true,
                          child: Text(
                            l10n.splashOfflineTitle,
                            textAlign: TextAlign.center,
                            style: AtTextStyles.sectionTitle.copyWith(
                              color: AtColors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.splashOfflineBody,
                          textAlign: TextAlign.center,
                          style: AtTextStyles.bodySm.copyWith(
                            color: const Color.fromRGBO(255, 255, 255, 0.85),
                          ),
                        ),
                        const SizedBox(height: 20),
                        AtButton(
                          label: l10n.retry,
                          variant: AtButtonVariant.secondary,
                          size: AtButtonSize.md,
                          fullWidth: false,
                          onPressed: () => ref
                              .read(sessionControllerProvider.notifier)
                              .retry(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
