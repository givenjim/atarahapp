import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/session_controller.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';

/// Brand splash shown while the stored session is checked. It takes over from the native splash
/// (Midnight with the colour symbol): reversed primary logo at 300 px on the Midnight gradient with the
/// brand ring, and the dark brand status-bar style whatever the member's appearance. If the check fails
/// (usually offline) it says so and offers a retry instead of leaving the member on a spinner.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final failed = ref.watch(sessionStatusProvider) == SessionStatus.failed;
    final white = context.at.white;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AtTheme.overlayStyle(Brightness.dark),
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: AtGradients.splash),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const AtBrandRing(),
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AtLogo(
                          variant: AtLogoVariant.primary,
                          width: 300,
                          style: AtLogoStyle.reversed,
                        ),
                        if (failed) ...[
                          const SizedBox(height: 40),
                          Semantics(
                            liveRegion: true,
                            header: true,
                            child: Text(
                              l10n.splashOfflineTitle,
                              textAlign: TextAlign.center,
                              style: AtTextStyles.sectionTitle.copyWith(
                                color: white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.splashOfflineBody,
                            textAlign: TextAlign.center,
                            style: AtTextStyles.bodySm.copyWith(
                              color: white.withValues(alpha: 0.85),
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
              if (!failed)
                Positioned(
                  bottom: 56,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Semantics(
                      label: l10n.splashCheckingTitle,
                      liveRegion: true,
                      child: SizedBox(
                        width: 120,
                        child: ClipRRect(
                          borderRadius: AtRadii.pill,
                          child: LinearProgressIndicator(
                            minHeight: 4,
                            color: white,
                            backgroundColor: white.withValues(alpha: 0.25),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
