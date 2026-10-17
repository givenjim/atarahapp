import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/providers.dart';
import '../../core/routing/routes.dart';
import 'onboarding_done_screen.dart';
import 'onboarding_draft.dart';
import 'onboarding_providers.dart';
import 'onboarding_steps.dart';

/// Creative profile setup: seven steps in one frame (back, progress, Skip, CTA). Every step is saved on the
/// server before the next opens, so setup resumes where it stopped even after the app is closed.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  OnboardingDraft? _draft;
  int _index = 0;
  bool _busy = false;
  String? _banner;
  OnboardingCompleteDto? _done;
  bool _leaving = false;

  static const _lastIndex = 6;

  @override
  void dispose() {
    _draft?.dispose();
    super.dispose();
  }

  SaveOnboardingStepDtoStep get _stepName => switch (_index) {
    0 => SaveOnboardingStepDtoStep.intro,
    1 => SaveOnboardingStepDtoStep.discipline,
    2 => SaveOnboardingStepDtoStep.specialisation,
    3 => SaveOnboardingStepDtoStep.skills,
    4 => SaveOnboardingStepDtoStep.location,
    5 => SaveOnboardingStepDtoStep.basics,
    _ => SaveOnboardingStepDtoStep.photo,
  };

  void _back() {
    if (_busy) return;
    if (_index == 0) {
      context.go(Routes.home);
      return;
    }
    setState(() {
      _index--;
      _banner = null;
    });
  }

  /// Checks the step on the device first; null means fine. The server checks again regardless.
  String? _validate(AppLocalizations l10n) {
    final d = _draft!;
    d.fieldErrors.clear();
    switch (_index) {
      case 1:
        if (d.disciplineId == null) {
          d.setError('disciplineId', l10n.obDisciplineRequired);
          return '';
        }
      case 4:
        if (d.countyId == null) {
          d.setError('countyId', l10n.obCountyRequired);
          return '';
        }
      case 5:
        var bad = false;
        if (d.displayName.trim().length < 2) {
          d.setError('displayName', l10n.obDisplayNameError);
          bad = true;
        }
        final handle = d.handle.trim().toLowerCase();
        if (handle.isEmpty) {
          d.setError('handle', l10n.obHandleRequired);
          bad = true;
        } else if (!handlePattern.hasMatch(handle)) {
          d.setError('handle', l10n.obHandleInvalid);
          bad = true;
        } else if (d.handleStatus is HandleUnavailable) {
          bad = true; // the field already shows why
        }
        if (d.bio.trim().length > OnboardingLimits.bio) bad = true;
        if (bad) return '';
    }
    return null;
  }

  SaveOnboardingStepDto _payload({bool skipped = false}) {
    final d = _draft!;
    final step = _stepName;
    if (skipped) return SaveOnboardingStepDto(step: step, skipped: true);
    return switch (_index) {
      1 => SaveOnboardingStepDto(step: step, disciplineId: d.disciplineId),
      2 => SaveOnboardingStepDto(
        step: step,
        specialisationIds: d.specialisationIds.toList(),
      ),
      3 => SaveOnboardingStepDto(
        step: step,
        skillIds: d.skillIds.toList(),
        interestIds: d.interestIds.toList(),
        developmentAreaIds: d.developmentAreaIds.toList(),
      ),
      4 => SaveOnboardingStepDto(
        step: step,
        countryId: d.countryId,
        countyId: d.countyId,
        town: d.town.trim(),
        locationVisibility: d.visibility,
      ),
      5 => SaveOnboardingStepDto(
        step: step,
        displayName: d.displayName.trim(),
        handle: d.handle.trim().toLowerCase(),
        bio: d.bio.trim(),
      ),
      _ => SaveOnboardingStepDto(step: step),
    };
  }

  Future<void> _next({bool skipped = false}) async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    if (!skipped && _validate(l10n) != null) return;
    setState(() {
      _busy = true;
      _banner = null;
    });
    final controller = ref.read(onboardingControllerProvider.notifier);
    try {
      final saved = await controller.saveStep(_payload(skipped: skipped));
      _draft!.syncFrom(saved);
      ref.read(analyticsProvider).track(
        skipped ? 'onboarding_step_skipped' : 'onboarding_step_completed',
        {'step': _stepName.json},
      );
      if (_index == _lastIndex) {
        final done = await controller.complete();
        if (!mounted) return;
        setState(() => _done = done);
      } else {
        if (!mounted) return;
        setState(() => _index++);
      }
    } on ApiFailure catch (e) {
      if (!mounted) return;
      _showFailure(e);
    } on AppFailure catch (e) {
      if (mounted) setState(() => _banner = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// A server complaint about one field appears under that field; anything else goes in a banner.
  void _showFailure(ApiFailure e) {
    final d = _draft!;
    final field = e.details['field'] as String?;
    final fromList = [
      'displayName',
      'handle',
      'bio',
      'countyId',
      'disciplineId',
    ].firstWhere((f) => e.fieldError(f) != null, orElse: () => '');
    if (field != null || fromList.isNotEmpty) {
      final key = field ?? fromList;
      d.setError(key, e.fieldError(key) ?? e.message);
      final suggestions = e.details['suggestions'];
      if (key == 'handle' && suggestions is List) {
        d.update(
          () => d.handleStatus = HandleUnavailable(
            e.details['reason'] == 'RESERVED'
                ? HandleAvailabilityDtoReason.reserved
                : HandleAvailabilityDtoReason.taken,
            suggestions.map((s) => s.toString()).toList(),
          ),
        );
      }
    } else {
      setState(() => _banner = e.message);
    }
  }

  Widget _body() {
    final d = _draft!;
    return switch (_index) {
      0 => const IntroStep(),
      1 => DisciplineStep(draft: d),
      2 => SpecialisationStep(draft: d),
      3 => SkillsStep(draft: d),
      4 => LocationStep(draft: d),
      5 => BasicsStep(draft: d),
      _ => PhotoStep(draft: d),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_done != null) {
      return OnboardingDoneScreen(result: _done!);
    }
    final async = ref.watch(onboardingControllerProvider);
    final state = async.value;

    if (state == null) {
      return Scaffold(
        body: AtPage(
          child: Column(
            children: [
              AtTopBar(onBack: () => context.go(Routes.home)),
              Expanded(
                child: async.hasError
                    ? Padding(
                        padding: const EdgeInsets.all(AtSpacing.gutter),
                        child: AtErrorState(
                          title: l10n.obLoadFailedTitle,
                          body: async.error is AppFailure
                              ? (async.error! as AppFailure).message
                              : const UnexpectedFailure().message,
                          ctaLabel: l10n.retry,
                          onCta: () => ref
                              .read(onboardingControllerProvider.notifier)
                              .retry(),
                        ),
                      )
                    : Semantics(
                        label: l10n.loading,
                        liveRegion: true,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.completed && !_leaving) {
      // Setup is finished (for example a bookmarked link): nothing to do here.
      _leaving = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(Routes.home);
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    if (_draft == null) {
      _draft = OnboardingDraft.from(state);
      final resume = onboardingStepOrder.indexOf(state.step);
      _index = resume < 0 ? 0 : resume;
    }

    final last = _index == _lastIndex;
    final cta = _index == 0
        ? l10n.obGetStarted
        : last
        ? l10n.obFinish
        : l10n.obContinue;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: AtPage(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AtIconButton(
                          icon: LucideIcons.chevronLeft,
                          semanticLabel: l10n.back,
                          onPressed: _busy ? null : _back,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AtProgressBar(
                            value: (_index + 1) / 8,
                            semanticLabel: l10n.obProgressLabel,
                          ),
                        ),
                        if (_index > 0)
                          TextButton(
                            onPressed: _busy
                                ? null
                                : () => _next(skipped: true),
                            child: Text(
                              last ? l10n.obPhotoSkip : l10n.obSkip,
                              style: AtTextStyles.bodySm.copyWith(
                                color: AtColors.muted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 64),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 14, 8, 0),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          _index == 0
                              ? l10n.obGettingStarted
                              : l10n.obStepOf(_index, 6),
                          style: AtTextStyles.meta.copyWith(
                            color: AtColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(22, 6, 22, 20),
                  child: KeyedSubtree(key: ValueKey(_index), child: _body()),
                ),
              ),
              if (_banner != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
                  child: AtInlineBanner(message: _banner!),
                ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 14),
                  child: ListenableBuilder(
                    listenable: _draft!,
                    builder: (context, _) => AtButton(
                      label: cta,
                      loading: _busy,
                      onPressed: _busy || _draft!.uploadingPhoto
                          ? null
                          : () => _next(),
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
