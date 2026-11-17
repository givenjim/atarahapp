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
import 'learning_common.dart';
import 'learning_providers.dart';
import 'lesson_players.dart';

/// One Skill Lab. A course shows its progress, lessons (Done, Current, Locked) and a sticky "Start learning" /
/// "Continue learning"; any other item shows how it opens (in the app, embedded, or outside Atarah) and lets the member
/// mark it started and complete. Premium items the member cannot open show the premium gate instead.
class CourseScreen extends ConsumerWidget {
  const CourseScreen({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(learningDetailProvider(courseId));
    return Scaffold(
      backgroundColor: context.at.background,
      body: AtPage(
        wash: AtWash.learning,
        child: async.when(
          skipLoadingOnReload: true,
          loading: () => const AtLoadingBody(),
          error: (e, _) => Column(
            children: [
              AtTopBar(onBack: () => _back(context)),
              Expanded(
                child: e is ApiFailure && e.statusCode == 404
                    ? AtEmptyState(
                        icon: LucideIcons.searchX,
                        title: l10n.lnHubEmptyTitle,
                        ctaLabel: l10n.lnBackToLabs,
                        onCta: () => context.go(Routes.learning),
                      )
                    : isPremiumRequired(e)
                    ? const LabPremiumGate()
                    : loadFailure(
                        e,
                        () => ref.invalidate(learningDetailProvider(courseId)),
                        l10n,
                      ),
              ),
            ],
          ),
          data: (loaded) =>
              _Detail(detail: loaded.value, fromCache: loaded.fromCache),
        ),
      ),
    );
  }
}

void _back(BuildContext context) =>
    context.canPop() ? context.pop() : context.go(Routes.learning);

class _Detail extends ConsumerStatefulWidget {
  const _Detail({required this.detail, required this.fromCache});

  final LearningDetailDto detail;
  final bool fromCache;

  @override
  ConsumerState<_Detail> createState() => _DetailState();
}

class _DetailState extends ConsumerState<_Detail> {
  bool _busy = false;

  /// An enrolment the server answered PREMIUM_REQUIRED to: the gate takes over.
  bool _gated = false;
  bool _embedFailed = false;
  bool _startedEmbedded = false;

  LearningDetailDto get d => widget.detail;
  bool get _isCourse => d.course != null;

  void _refresh() => ref.invalidate(learningDetailProvider(d.id));

  bool get _saved => ref.read(learningSavesProvider)[d.id] ?? d.saved;

  Future<void> _share() =>
      ref.read(shareTextProvider)('${d.title}\n${d.shareUrl}');

  Future<void> _openLesson(String lessonId) async {
    await context.push(Routes.lessonPath(lessonId));
    if (mounted) _refresh();
  }

  Future<void> _primary() async {
    final l10n = AppLocalizations.of(context);
    final course = d.course;
    if (course == null || _busy) return;
    if (course.enrolled) {
      final next = course.nextLessonId ?? course.lessons.firstOrNull?.id;
      if (next != null) await _openLesson(next);
      return;
    }
    setState(() => _busy = true);
    try {
      final e = await ref.read(learningActionsProvider).enrol(d.id);
      final next = e.nextLessonId ?? course.lessons.firstOrNull?.id;
      if (mounted && next != null) await _openLesson(next);
    } on Object catch (err) {
      if (!mounted) return;
      if (isPremiumRequired(err)) {
        setState(() => _gated = true);
      } else {
        showLabNotice(
          context,
          err is NetworkFailure ? l10n.lnNeedsConnection : labError(err),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openExternal() async {
    final l10n = AppLocalizations.of(context);
    final uri = Uri.tryParse(d.externalUrl ?? '');
    if (uri == null || _busy) return;
    final domain = d.externalDomain ?? uri.host;
    final choice = await showLeavingAtarahModal(
      context,
      domain: domain,
      showTrackOption: false,
      body: l10n.lnLeavingBody(domain),
    );
    if (choice == null || !choice.continueToSite || !mounted) return;
    setState(() => _busy = true);
    try {
      final ok = await ref.read(openLinkProvider)(uri);
      if (!mounted) return;
      if (!ok) {
        showLabNotice(context, l10n.leavingOpenFailed);
        return;
      }
      // Only after the browser really opened does it count as started.
      await ref.read(learningActionsProvider).start(d.id);
    } on Object catch (e) {
      if (mounted) showLabNotice(context, labError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _complete() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(learningActionsProvider).completeItem(d.id);
    } on Object catch (e) {
      if (mounted) showLabNotice(context, labError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// An embedded single item counts as started once its player is on screen.
  void _markEmbeddedStarted() {
    if (_startedEmbedded || d.itemProgress != null) return;
    _startedEmbedded = true;
    Future.microtask(() async {
      try {
        await ref.read(learningActionsProvider).start(d.id);
      } on Object {
        // Starting is a nicety; the player still works.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final saved = ref.watch(learningSavesProvider)[d.id] ?? d.saved;
    if (_gated || d.premiumLocked) {
      return Column(
        children: [
          AtTopBar(onBack: () => _back(context)),
          const Expanded(child: LabPremiumGate()),
        ],
      );
    }
    final course = d.course;
    final percent = course?.percent.toInt() ?? 0;
    return Column(
      children: [
        AtTopBar(
          onBack: () => _back(context),
          actions: [
            AtIconButton(
              icon: saved ? LucideIcons.bookmarkCheck : LucideIcons.bookmark,
              semanticLabel: saved ? l10n.lnUnsaveLab : l10n.lnSaveLab,
              variant: AtIconButtonVariant.glass,
              onPressed: () => toggleLabSave(context, ref, d.id, _saved),
            ),
            AtIconButton(
              icon: LucideIcons.share2,
              semanticLabel: l10n.lnShareLab,
              variant: AtIconButtonVariant.glass,
              onPressed: _share,
            ),
          ],
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _refresh();
              await ref.read(learningDetailProvider(d.id).future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AtSpacing.gutter,
                0,
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
                _Hero(detail: d),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    AtTag(
                      label: labSourceLabel(l10n, d.source, d.type),
                      tone: labSourceTone(d.source),
                    ),
                    AtTag(
                      label: labDeliveryLabel(l10n, d.delivery),
                      icon: d.delivery == ContentDelivery.native
                          ? LucideIcons.layers
                          : d.delivery == ContentDelivery.embedded
                          ? LucideIcons.play
                          : LucideIcons.externalLink,
                    ),
                    AtTag(
                      label: labTypeLabel(l10n, d.type),
                      icon: labTypeIcon(d.type),
                    ),
                    if (d.access == LearningAccess.premiumContent)
                      AtTag(
                        label: l10n.lnPremiumBadge,
                        tone: AtTone.amber,
                        icon: LucideIcons.crown,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Semantics(
                  header: true,
                  child: Text(
                    d.title,
                    style: AtTextStyles.detailTitle.copyWith(
                      color: context.at.ink,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _facts(l10n),
                  style: AtTextStyles.meta.copyWith(color: context.at.muted),
                ),
                const SizedBox(height: 12),
                Text(
                  d.summary,
                  style: AtTextStyles.body.copyWith(color: context.at.longForm),
                ),
                if (d.linkStatus == LearningDetailDtoLinkStatus.broken) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 280,
                    child: AtErrorState(
                      variant: AtErrorVariant.invalidLink,
                      ctaLabel: l10n.lnFindSimilar,
                      onCta: () => context.push(
                        Routes.learningCategoryPath(d.category.slug),
                      ),
                    ),
                  ),
                ] else if (d.delivery == ContentDelivery.embedded &&
                    !_isCourse &&
                    d.embedUrl != null) ...[
                  const SizedBox(height: 16),
                  _embedded(context, l10n),
                ],
                if (course != null && course.enrolled) ...[
                  const SizedBox(height: 18),
                  _ProgressBox(
                    done: course.completedLessons.toInt(),
                    total: course.lessonCount.toInt(),
                    percent: percent,
                  ),
                ],
                if (course?.certificate != null) ...[
                  const SizedBox(height: 14),
                  _CertificateCard(certificate: course!.certificate!),
                ],
                if (d.whatYouLearn.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _Heading(l10n.lnWhatYoullLearn),
                  for (final w in d.whatYouLearn) _Bullet(text: w),
                ],
                if ((d.whoItsFor ?? '').isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _Heading(l10n.lnWhoItsFor),
                  Text(
                    d.whoItsFor!,
                    style: AtTextStyles.body.copyWith(
                      color: context.at.longForm,
                    ),
                  ),
                ],
                if (course != null && course.lessons.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _Heading(l10n.lnLessons),
                  for (final l in course.lessons)
                    _LessonRow(
                      lesson: l,
                      onTap: l.state == LessonSummaryDtoState.locked
                          ? null
                          : () => course.enrolled
                                ? _openLesson(l.id)
                                : _primary(),
                    ),
                ],
                if (d.instructorName != null || d.providerName != null) ...[
                  const SizedBox(height: 20),
                  _ProviderRow(
                    label: d.instructorName != null
                        ? l10n.lnTaughtBy
                        : l10n.lnFrom,
                    name: d.instructorName ?? d.providerName!,
                    provider: d.instructorName == null ? null : d.providerName,
                  ),
                ],
              ],
            ),
          ),
        ),
        _Cta(
          detail: d,
          busy: _busy,
          fromCache: widget.fromCache,
          onPrimary: _primary,
          onExternal: _openExternal,
          onComplete: _complete,
        ),
      ],
    );
  }

  String _facts(AppLocalizations l10n) => [
    labLevelLabel(l10n, d.level),
    if (d.course != null) l10n.lnLessonCount(d.course!.lessonCount.toInt()),
    if (d.durationMinutes > 0) labDuration(l10n, d.durationMinutes),
  ].join(' · ');

  Widget _embedded(BuildContext context, AppLocalizations l10n) {
    if (_embedFailed) {
      return SizedBox(
        height: 280,
        child: AtErrorState(
          variant: AtErrorVariant.external,
          title: l10n.lnEmbedFailedTitle(
            embedServiceName(d.embedUrl!, fallback: l10n.lnTypeAll),
          ),
          ctaLabel: l10n.retry,
          onCta: () => setState(() => _embedFailed = false),
        ),
      );
    }
    _markEmbeddedStarted();
    return ref.watch(lessonEmbedBuilderProvider)(
      context,
      url: d.embedUrl!,
      onFailed: () {
        if (mounted) setState(() => _embedFailed = true);
      },
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.detail});

  final LearningDetailDto detail;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: AtRadii.card,
    child: LabCover(
      url: detail.coverUrl,
      type: detail.type,
      size: double.infinity,
      height: 168,
      radius: AtRadii.card,
    ),
  );
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Semantics(
      header: true,
      child: Text(
        text,
        style: AtTextStyles.sectionTitleSm.copyWith(color: context.at.ink),
      ),
    ),
  );
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Icon(LucideIcons.check, size: 16, color: context.at.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AtTextStyles.body.copyWith(color: context.at.longForm),
          ),
        ),
      ],
    ),
  );
}

class _ProgressBox extends StatelessWidget {
  const _ProgressBox({
    required this.done,
    required this.total,
    required this.percent,
  });

  final int done;
  final int total;
  final int percent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AtCard(
      semanticLabel:
          '${l10n.lnYourProgress}: ${l10n.lnProgressOf(done, total)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.lnYourProgress,
                  style: AtTextStyles.cardTitle.copyWith(color: context.at.ink),
                ),
              ),
              Text(
                l10n.lnProgressOf(done, total),
                style: AtTextStyles.chip.copyWith(color: context.at.primary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AtProgressBar(
            value: percent / 100,
            semanticLabel: l10n.lnPercentComplete(percent),
          ),
        ],
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  const _CertificateCard({required this.certificate});

  final CertificateDto certificate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tone = AtTone.success.colorsOf(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: tone.bg, borderRadius: AtRadii.card),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.award, size: 28, color: tone.fg),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.lnCertificateEarned,
                  style: AtTextStyles.cardTitle.copyWith(color: tone.strong),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.lnCertificateNumber(certificate.certificateNumber),
                  style: AtTextStyles.meta.copyWith(color: tone.strong),
                ),
                Text(
                  l10n.lnCertificateIssued(
                    shortDate(context, certificate.issuedAt.toLocal()),
                  ),
                  style: AtTextStyles.meta.copyWith(color: tone.strong),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => context.push(Routes.achievements),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 44),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.lnViewOnPassport,
                        style: AtTextStyles.chip.copyWith(
                          color: tone.strong,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({required this.lesson, required this.onTap});

  final LessonSummaryDto lesson;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = lesson.state;
    final (icon, color, stateLabel) = switch (state) {
      LessonSummaryDtoState.done => (
        LucideIcons.circleCheck,
        context.at.successIcon,
        l10n.lnLessonDone,
      ),
      LessonSummaryDtoState.current => (
        LucideIcons.circlePlay,
        context.at.primary,
        l10n.lnLessonCurrent,
      ),
      LessonSummaryDtoState.locked => (
        LucideIcons.lock,
        context.at.muted,
        l10n.lnLessonLocked,
      ),
      _ => (LucideIcons.circle, context.at.muted, ''),
    };
    final current = state == LessonSummaryDtoState.current;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        button: onTap != null,
        enabled: onTap != null,
        label: l10n.lnLessonRow(
          lesson.sequence.toInt(),
          lesson.title,
          lesson.durationMinutes.toInt(),
          stateLabel,
        ),
        excludeSemantics: true,
        onTap: onTap,
        child: AtCard(
          onTap: onTap,
          color: current ? context.at.primaryTintFaint : null,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: AtTextStyles.cardTitle.copyWith(
                        color: state == LessonSummaryDtoState.locked
                            ? context.at.muted
                            : context.at.ink,
                      ),
                    ),
                    Text(
                      l10n.lnLessonMinutes(lesson.durationMinutes.toInt()),
                      style: AtTextStyles.metaSm.copyWith(
                        color: context.at.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (stateLabel.isNotEmpty)
                Text(
                  stateLabel,
                  style: AtTextStyles.chipSm.copyWith(color: color),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderRow extends StatelessWidget {
  const _ProviderRow({
    required this.label,
    required this.name,
    required this.provider,
  });

  final String label;
  final String name;
  final String? provider;

  @override
  Widget build(BuildContext context) => AtCard(
    child: Row(
      children: [
        Portrait(name: name, url: null, size: 44, rounded: false),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AtTextStyles.metaSm.copyWith(color: context.at.muted),
              ),
              Text(
                name,
                style: AtTextStyles.cardTitle.copyWith(color: context.at.ink),
              ),
              if (provider != null)
                Text(
                  provider!,
                  style: AtTextStyles.meta.copyWith(color: context.at.muted),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// The sticky button. Courses: Start, Continue or Review. External items: Open resource (and Mark complete once
/// started). Embedded items: Mark complete.
class _Cta extends StatelessWidget {
  const _Cta({
    required this.detail,
    required this.busy,
    required this.fromCache,
    required this.onPrimary,
    required this.onExternal,
    required this.onComplete,
  });

  final LearningDetailDto detail;
  final bool busy;
  final bool fromCache;
  final VoidCallback onPrimary;
  final VoidCallback onExternal;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final d = detail;
    final course = d.course;
    final broken = d.linkStatus == LearningDetailDtoLinkStatus.broken;
    final item = d.itemProgress;
    final itemDone = item?.status == LessonProgressStatus.completed;

    Widget button;
    if (course != null) {
      final done = course.certificate != null || course.percent >= 100;
      button = AtButton(
        label: done
            ? l10n.lnReviewCourse
            : course.enrolled
            ? l10n.lnContinueLearning
            : l10n.lnStartLearning,
        icon: course.enrolled ? LucideIcons.play : LucideIcons.graduationCap,
        loading: busy,
        // Starting needs the network; continuing a saved lesson does not.
        onPressed: fromCache && !course.enrolled ? null : onPrimary,
      );
    } else if (broken) {
      return const SizedBox.shrink();
    } else if (d.delivery == ContentDelivery.embedded) {
      button = AtButton(
        label: itemDone ? l10n.lnCompletedItem : l10n.lnMarkComplete,
        icon: LucideIcons.circleCheck,
        loading: busy,
        onPressed: itemDone || fromCache ? null : onComplete,
      );
    } else {
      button = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AtButton(
            label: l10n.lnOpenResource,
            trailingIcon: LucideIcons.externalLink,
            loading: busy,
            onPressed: fromCache ? null : onExternal,
          ),
          if (item != null) ...[
            const SizedBox(height: 8),
            AtButton(
              label: itemDone ? l10n.lnCompletedItem : l10n.lnMarkComplete,
              icon: LucideIcons.circleCheck,
              variant: AtButtonVariant.secondary,
              onPressed: itemDone || fromCache ? null : onComplete,
            ),
          ],
        ],
      );
    }
    return Container(
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
      child: button,
    );
  }
}
