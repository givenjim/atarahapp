import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/generated/export.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/networking/failures.dart';
import '../../core/routing/routes.dart';
import '../discover/discover_common.dart';
import '../profile/profile_providers.dart';
import 'learning_cache.dart';
import 'learning_common.dart';
import 'learning_providers.dart';
import 'lesson_players.dart';

/// One lesson: its video (or embedded player), the text, a Practice box, a segment per lesson showing how far the
/// member is, and "Mark complete & next". Finishing the last lesson shows the completion screen with the certificate.
class LessonScreen extends ConsumerWidget {
  const LessonScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(lessonProvider(lessonId));
    return Scaffold(
      backgroundColor: context.at.background,
      body: AtPage(
        wash: AtWash.learning,
        child: async.when(
          skipLoadingOnReload: true,
          loading: () => const AtLoadingBody(),
          error: (e, _) => Column(
            children: [
              AtTopBar(onBack: () => _backToLabs(context)),
              Expanded(child: _failure(context, ref, e, l10n)),
            ],
          ),
          data: (loaded) => _Lesson(
            key: ValueKey(lessonId),
            lesson: loaded.value,
            fromCache: loaded.fromCache,
          ),
        ),
      ),
    );
  }

  Widget _failure(
    BuildContext context,
    WidgetRef ref,
    Object e,
    AppLocalizations l10n,
  ) {
    if (isPremiumRequired(e)) return const LabPremiumGate();
    if (e is ApiFailure && e.statusCode == 409) {
      return AtEmptyState(
        icon: LucideIcons.lock,
        title: e.reason == 'LOCKED' ? l10n.lnLessonLockedMessage : e.message,
        ctaLabel: l10n.lnBackToLabs,
        onCta: () => _backToLabs(context),
      );
    }
    if (e is ApiFailure && e.statusCode == 404) {
      return AtEmptyState(
        icon: LucideIcons.searchX,
        title: l10n.lnHubEmptyTitle,
        ctaLabel: l10n.lnBackToLabs,
        onCta: () => _backToLabs(context),
      );
    }
    return loadFailure(e, () => ref.invalidate(lessonProvider(lessonId)), l10n);
  }
}

void _backToLabs(BuildContext context) =>
    context.canPop() ? context.pop() : context.go(Routes.learning);

class _Lesson extends ConsumerStatefulWidget {
  const _Lesson({super.key, required this.lesson, required this.fromCache});

  final LessonDto lesson;
  final bool fromCache;

  @override
  ConsumerState<_Lesson> createState() => _LessonState();
}

class _LessonState extends ConsumerState<_Lesson> {
  late final LearningActions _actions;
  late final LearningCache _cache;
  late final ProgressReporter _reporter;
  Future<LessonVideoDto>? _video;
  bool _busy = false;
  bool _playerFailed = false;
  bool _warnedSave = false;
  ProgressResultDto? _completed;

  LessonDto get l => widget.lesson;

  @override
  void initState() {
    super.initState();
    _actions = ref.read(learningActionsProvider);
    _cache = ref.read(learningCacheProvider);
    _reporter = ProgressReporter(
      startAt: l.progress.lastPositionSeconds.toInt(),
      send: _send,
    );
    if (l.hasVideo && !widget.fromCache) {
      _video = ref.read(learningRepositoryProvider).video(l.id);
    }
  }

  /// Keeps the position on the phone first (so it survives no signal), then tells the server. A failed write is
  /// retried by the next report; the member is told once.
  Future<void> _send(int seconds) async {
    await _cache.savePosition(l.id, seconds);
    try {
      await _actions.reportPosition(l.id, seconds);
    } on Object {
      if (mounted && !_warnedSave) {
        _warnedSave = true;
        showLabNotice(
          context,
          AppLocalizations.of(context).lnSaveProgressFailed,
        );
      }
    }
  }

  Future<Duration> _resumeAt() async {
    final cached = await _cache.position(l.id) ?? 0;
    final server = l.progress.lastPositionSeconds.toInt();
    return Duration(seconds: cached > server ? cached : server);
  }

  void _toCourse() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.coursePath(l.courseId));
    }
  }

  Future<void> _markComplete() async {
    final l10n = AppLocalizations.of(context);
    if (_busy) return;
    if (widget.fromCache) {
      showLabNotice(context, l10n.lnNeedsConnection);
      return;
    }
    setState(() => _busy = true);
    try {
      final r = await _actions.completeLesson(
        l.id,
        courseId: l.courseId,
        positionSeconds: _reporter.best > 0 ? _reporter.best : null,
      );
      if (!mounted) return;
      if (r.courseCompleted) {
        setState(() => _completed = r);
        return;
      }
      final next = r.nextLessonId ?? l.nextLessonId;
      if (next != null) {
        context.pushReplacement(Routes.lessonPath(next));
      } else {
        _toCourse();
      }
    } on Object catch (e) {
      if (mounted) {
        showLabNotice(
          context,
          e is NetworkFailure ? l10n.lnNeedsConnection : labError(e),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _addToPortfolio() {
    final skill = l.practice?.skill;
    final base = Routes.projectEditPath('new');
    context.push(
      skill == null
          ? base
          : '$base?skillId=${Uri.encodeQueryComponent(skill.id)}'
                '&skillName=${Uri.encodeQueryComponent(skill.name)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final done = _completed;
    if (done != null) {
      return _Completion(
        courseTitle: l.courseTitle,
        certificate: done.certificate,
        onBack: () => context.go(Routes.learning),
      );
    }
    final last = l.nextLessonId == null;
    return Column(
      children: [
        AtTopBar(title: l.courseTitle, onBack: _toCourse),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AtSpacing.gutter,
              4,
              AtSpacing.gutter,
              24,
            ),
            children: [
              if (widget.fromCache) ...[
                AtInlineBanner(
                  tone: AtBannerTone.info,
                  message: l10n.lnSavedCopyBanner,
                ),
                const SizedBox(height: 12),
              ],
              _Segments(done: l.segments, current: l.sequence.toInt() - 1),
              const SizedBox(height: 14),
              Text(
                l10n.lnLessonOf(l.sequence.toInt(), l.lessonCount.toInt()),
                style: AtTextStyles.chip.copyWith(color: context.at.primary),
              ),
              const SizedBox(height: 4),
              Semantics(
                header: true,
                child: Text(
                  l.title,
                  style: AtTextStyles.detailTitle.copyWith(
                    color: context.at.ink,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _player(context, l10n),
              if (l.body.isNotEmpty) ...[
                const SizedBox(height: 8),
                LessonBlocks(blocks: l.body),
              ],
              if (l.practice != null) ...[
                const SizedBox(height: 16),
                _PracticeBox(practice: l.practice!, onAdd: _addToPortfolio),
              ],
              const SizedBox(height: 14),
              AtButton(
                label: l10n.lnLearnNext,
                icon: LucideIcons.sparkles,
                variant: AtButtonVariant.tertiary,
                onPressed: () =>
                    context.push(Routes.soonPath('p3', name: l10n.lnLearnNext)),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(
            AtSpacing.gutter,
            12,
            AtSpacing.gutter,
            12 + MediaQuery.paddingOf(context).bottom,
          ),
          decoration: BoxDecoration(
            color: context.at.surface,
            border: Border(top: BorderSide(color: context.at.divider)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: AtButton(
                  label: l10n.lnAllLessons,
                  variant: AtButtonVariant.secondary,
                  onPressed: _toCourse,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: AtButton(
                  label: last
                      ? l10n.lnMarkCompleteFinish
                      : l10n.lnMarkCompleteNext,
                  trailingIcon: LucideIcons.arrowRight,
                  loading: _busy,
                  onPressed: _markComplete,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _player(BuildContext context, AppLocalizations l10n) {
    if (l.hasVideo) {
      if (widget.fromCache) {
        return AtInlineBanner(
          tone: AtBannerTone.info,
          message: l10n.lnNeedsConnection,
        );
      }
      return FutureBuilder<LessonVideoDto>(
        future: _video,
        builder: (context, snap) {
          if (snap.hasError) {
            final e = snap.error;
            return AtInlineBanner(
              message: e is ApiFailure && e.statusCode == 409
                  ? l10n.lnVideoPreparing
                  : l10n.lnVideoLoadFailed,
            );
          }
          final v = snap.data;
          if (v == null) {
            return const AspectRatio(
              aspectRatio: 16 / 9,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return FutureBuilder<Duration>(
            future: _resumeAt(),
            builder: (context, start) {
              if (!start.hasData) {
                return const AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return ref.watch(lessonVideoBuilderProvider)(
                context,
                LessonVideoArgs(
                  url: v.url,
                  posterUrl: v.posterUrl,
                  startAt: start.data!,
                  onPosition: (s, reason) {
                    // A write may start while the screen is closing; its failure is handled in `_send`.
                    unawaited(
                      _reporter.report(s, reason) ?? Future<void>.value(),
                    );
                  },
                  onFailed: () {
                    if (mounted) setState(() => _playerFailed = true);
                  },
                ),
              );
            },
          );
        },
      );
    }
    final embed = l.embedUrl;
    if (embed != null) {
      if (_playerFailed) {
        return SizedBox(
          height: 300,
          child: AtErrorState(
            variant: AtErrorVariant.external,
            title: l10n.lnEmbedFailedTitle(
              embedServiceName(embed, fallback: l10n.lnVideoSemantic),
            ),
            ctaLabel: l10n.lnBackToCourse,
            onCta: _toCourse,
          ),
        );
      }
      return ref.watch(lessonEmbedBuilderProvider)(
        context,
        url: embed,
        onFailed: () {
          if (mounted) setState(() => _playerFailed = true);
        },
      );
    }
    return const SizedBox.shrink();
  }
}

/// One segment per lesson of the course: filled for finished lessons, outlined for this one, faint for the rest.
class _Segments extends StatelessWidget {
  const _Segments({required this.done, required this.current});

  final List<bool> done;
  final int current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final finished = done.where((d) => d).length;
    return Semantics(
      container: true,
      label: l10n.lnLessonProgressBar(finished, done.length),
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < done.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: AtRadii.pill,
                  color: done[i]
                      ? context.at.primary
                      : i == current
                      ? context.at.primaryLight
                      : context.at.divider,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PracticeBox extends StatelessWidget {
  const _PracticeBox({required this.practice, required this.onAdd});

  final PracticeDto practice;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.at.primaryTintFaint,
        borderRadius: AtRadii.card,
        border: Border.all(color: context.at.secondaryBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(LucideIcons.target, size: 18, color: context.at.primary),
              const SizedBox(width: 8),
              Semantics(
                header: true,
                child: Text(
                  l10n.lnPractice,
                  style: AtTextStyles.chip.copyWith(color: context.at.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            practice.prompt,
            style: AtTextStyles.body.copyWith(color: context.at.longForm),
          ),
          const SizedBox(height: 12),
          AtButton(
            label: l10n.lnAddToPortfolio,
            icon: LucideIcons.plus,
            size: AtButtonSize.md,
            variant: AtButtonVariant.secondary,
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}

/// The celebration after the last lesson: the certificate that was just issued and where to see it.
class _Completion extends ConsumerWidget {
  const _Completion({
    required this.courseTitle,
    required this.certificate,
    required this.onBack,
  });

  final String courseTitle;
  final CertificateDto? certificate;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = certificate;
    return Column(
      children: [
        AtTopBar(onBack: onBack),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AtSpacing.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      gradient: AtGradients.ctaSquare,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Icon(
                      LucideIcons.award,
                      size: 44,
                      color: context.at.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Semantics(
                  header: true,
                  liveRegion: true,
                  child: Text(
                    l10n.lnCompleteTitle,
                    textAlign: TextAlign.center,
                    style: AtTextStyles.detailTitle.copyWith(
                      color: context.at.ink,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.lnCompleteBody(courseTitle),
                  textAlign: TextAlign.center,
                  style: AtTextStyles.body.copyWith(color: context.at.body),
                ),
                if (c != null) ...[
                  const SizedBox(height: 20),
                  AtCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.lnCertificateEarned,
                          style: AtTextStyles.cardTitle.copyWith(
                            color: context.at.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.lnCertificateNumber(c.certificateNumber),
                          style: AtTextStyles.meta.copyWith(
                            color: context.at.muted,
                          ),
                        ),
                        Text(
                          l10n.lnCertificateIssued(
                            shortDate(context, c.issuedAt.toLocal()),
                          ),
                          style: AtTextStyles.meta.copyWith(
                            color: context.at.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                AtButton(
                  label: l10n.lnViewOnPassport,
                  icon: LucideIcons.badgeCheck,
                  onPressed: () => context.push(Routes.achievements),
                ),
                const SizedBox(height: 8),
                AtButton(
                  label: l10n.lnCompleteShare,
                  icon: LucideIcons.share2,
                  variant: AtButtonVariant.secondary,
                  onPressed: () => ref.read(shareTextProvider)(
                    l10n.lnCompleteShareText(courseTitle),
                  ),
                ),
                const SizedBox(height: 4),
                AtButton(
                  label: l10n.lnBackToLabs,
                  variant: AtButtonVariant.tertiary,
                  onPressed: onBack,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
