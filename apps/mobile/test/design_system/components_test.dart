import 'package:atarah/core/design_system/design_system.dart';
import 'package:atarah/shared/widgets/domain_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../support/pump_app.dart';

/// Painted height of the button's visual (the decorated container), not its 48px tap target.
double visualHeight(WidgetTester t, String label) {
  final box = find
      .ancestor(of: find.text(label), matching: find.byType(AnimatedContainer))
      .first;
  return t.getSize(box).height;
}

void main() {
  group('AtButton', () {
    testWidgets('heights follow the spec: 54 / 48 / 34', (t) async {
      await t.pumpAt(
        Column(
          children: [
            AtButton(label: 'Large', onPressed: () {}),
            AtButton(label: 'Medium', size: AtButtonSize.md, onPressed: () {}),
            AtButton(
              label: 'Small',
              size: AtButtonSize.sm,
              fullWidth: false,
              onPressed: () {},
            ),
          ],
        ),
      );
      expect(visualHeight(t, 'Large'), 54);
      expect(visualHeight(t, 'Medium'), 48);
      expect(visualHeight(t, 'Small'), 34);
    });

    testWidgets('small buttons still have a 48px tap target', (t) async {
      await t.pumpAt(
        AtButton(
          label: 'Small',
          size: AtButtonSize.sm,
          fullWidth: false,
          onPressed: () {},
        ),
      );
      expect(
        t.getSize(find.bySemanticsLabel('Small')).height,
        greaterThanOrEqualTo(48),
      );
    });

    testWidgets(
      'taps call onPressed; disabled and loading buttons ignore taps',
      (t) async {
        var taps = 0;
        await t.pumpAt(
          Column(
            children: [
              AtButton(label: 'Go', onPressed: () => taps++),
              const AtButton(label: 'Off', onPressed: null),
              AtButton(
                label: 'Busy',
                onPressed: () => taps += 100,
                loading: true,
              ),
            ],
          ),
        );
        await t.tap(find.text('Go'));
        await t.tap(find.text('Off'), warnIfMissed: false);
        await t.tap(
          find.byType(CircularProgressIndicator),
          warnIfMissed: false,
        );
        expect(taps, 1);
      },
    );

    testWidgets('loading hides the label behind a spinner and announces busy', (
      t,
    ) async {
      final handle = t.ensureSemantics();
      await t.pumpAt(AtButton(label: 'Save', onPressed: () {}, loading: true));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Save'), findsNothing);
      expect(t.getSemantics(find.bySemanticsLabel('Save')).value, 'busy');
      handle.dispose();
    });

    testWidgets('variants render distinct styles', (t) async {
      await t.pumpAt(
        Column(
          children: [
            AtButton(label: 'P', onPressed: () {}),
            AtButton(
              label: 'S',
              variant: AtButtonVariant.secondary,
              onPressed: () {},
            ),
            AtButton(
              label: 'T',
              variant: AtButtonVariant.tertiary,
              onPressed: () {},
            ),
            AtButton(
              label: 'D',
              variant: AtButtonVariant.destructive,
              onPressed: () {},
            ),
          ],
        ),
      );
      BoxDecoration deco(String l) =>
          (t.widget<AnimatedContainer>(
                find
                    .ancestor(
                      of: find.text(l),
                      matching: find.byType(AnimatedContainer),
                    )
                    .first,
              )).decoration!
              as BoxDecoration;
      expect(deco('P').gradient, AtGradients.cta);
      expect(deco('S').border, isNotNull);
      expect(deco('T').color, isNull);
      expect(deco('D').color, AtColors.pinkBg);
    });
  });

  group('AtIconButton', () {
    testWidgets(
      'back button is 44×44 with a 48px target and a semantic label',
      (t) async {
        var taps = 0;
        await t.pumpAt(
          AtIconButton(
            icon: LucideIcons.chevronLeft,
            semanticLabel: 'Back',
            onPressed: () => taps++,
          ),
        );
        expect(
          t.getSize(find.bySemanticsLabel('Back')).width,
          greaterThanOrEqualTo(48),
        );
        await t.tap(find.byIcon(LucideIcons.chevronLeft));
        expect(taps, 1);
      },
    );

    testWidgets('shows a count badge capped at 99+ and a plain dot', (t) async {
      await t.pumpAt(
        Row(
          children: [
            AtIconButton(
              icon: LucideIcons.bell,
              semanticLabel: 'Notifications',
              onPressed: () {},
              badge: 120,
            ),
            AtIconButton(
              icon: LucideIcons.slidersHorizontal,
              semanticLabel: 'Filters',
              onPressed: () {},
              showDot: true,
            ),
          ],
        ),
      );
      expect(find.text('99+'), findsOneWidget);
    });
  });

  group('chips, tags and verification', () {
    testWidgets(
      'selectable chip shows a check when selected; removable chip removes',
      (t) async {
        var removed = 0;
        await t.pumpAt(
          Column(
            children: [
              AtChip(label: 'Animation', selected: true, onTap: () {}),
              AtChip(label: 'Music', onTap: () {}),
              AtChip(
                label: 'Photo',
                kind: AtChipKind.removable,
                onRemove: () => removed++,
              ),
            ],
          ),
        );
        expect(find.byIcon(LucideIcons.check), findsOneWidget);
        await t.tap(find.byIcon(LucideIcons.x));
        expect(removed, 1);
      },
    );

    testWidgets(
      'chip hit area is at least 48 high while the visible chip is 36',
      (t) async {
        await t.pumpAt(AtChip(label: 'Nairobi', onTap: () {}));
        expect(
          t.getSize(find.bySemanticsLabel('Nairobi')).height,
          greaterThanOrEqualTo(48),
        );
        final visible = t.getSize(
          find
              .ancestor(
                of: find.text('Nairobi'),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );
        expect(visible.height, 36);
      },
    );

    testWidgets('verification badge uses the canonical labels', (t) async {
      await t.pumpAt(
        Column(
          children: [
            for (final v in AtVerification.values)
              AtVerificationBadge(status: v),
          ],
        ),
      );
      for (final label in [
        'Verified by Atarah',
        'Under review',
        'Self-declared',
        'Not verified',
        'Verification expired',
        'Verification revoked',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('verified tick is labelled for screen readers', (t) async {
      await t.pumpAt(const AtVerifiedTick());
      expect(find.bySemanticsLabel('Verified'), findsOneWidget);
    });

    testWidgets('status pill and tag render their text', (t) async {
      await t.pumpAt(
        const Column(
          children: [
            AtStatusPill(label: 'In progress', tone: AtTone.warning),
            AtTag(label: 'Grant'),
          ],
        ),
      );
      expect(find.text('In progress'), findsOneWidget);
      expect(find.text('Grant'), findsOneWidget);
    });
  });

  group('avatar and progress', () {
    testWidgets(
      'avatar falls back to initials and the ring shows the percentage',
      (t) async {
        await t.pumpAt(
          const Column(
            children: [
              AtAvatar(name: 'Sample Creative'),
              AtAvatar(name: 'Sample Creative', size: 72, progress: 0.72),
              AtAvatar(name: 'Single'),
            ],
          ),
        );
        expect(find.text('SC'), findsNWidgets(2));
        expect(find.text('S'), findsOneWidget);
        expect(find.text('72%'), findsOneWidget);
      },
    );

    testWidgets('progress bar clamps and exposes its value', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpAt(
        const Column(
          children: [
            AtProgressBar(value: 1.7, semanticLabel: 'Course progress'),
            AtProgressRing(value: 0.64),
          ],
        ),
      );
      expect(
        t.getSemantics(find.bySemanticsLabel('Course progress')).value,
        '100%',
      );
      expect(find.text('64%'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('stepper reports its position', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpAt(
        const AtStepper(steps: 6, current: 3, semanticLabel: 'Step'),
      );
      expect(t.getSemantics(find.bySemanticsLabel('Step')).value, '3 / 6');
      handle.dispose();
    });
  });

  group('layout components', () {
    testWidgets('section header: See all is announced with its section', (
      t,
    ) async {
      var seen = 0;
      await t.pumpAt(
        AtSectionHeader(title: 'Recommended for you', onSeeAll: () => seen++),
      );
      await t.tap(find.text('See all'));
      expect(seen, 1);
      expect(
        find.bySemanticsLabel('See all: Recommended for you'),
        findsOneWidget,
      );
    });

    testWidgets('top bar back button calls onBack', (t) async {
      var back = 0;
      await t.pumpAt(
        AtTopBar(title: 'Settings', onBack: () => back++),
        scaffold: false,
      );
      await t.tap(find.bySemanticsLabel('Back'));
      expect(back, 1);
    });

    testWidgets('list row is tappable and reads title and subtitle together', (
      t,
    ) async {
      var taps = 0;
      await t.pumpAt(
        AtListRow(
          title: 'Account',
          subtitle: 'Email, phone',
          icon: LucideIcons.user,
          onTap: () => taps++,
        ),
      );
      await t.tap(find.text('Account'));
      expect(taps, 1);
      expect(find.bySemanticsLabel('Account, Email, phone'), findsOneWidget);
    });

    testWidgets('destructive row uses the destructive colour', (t) async {
      await t.pumpAt(
        AtListRow(title: 'Delete account', destructive: true, onTap: () {}),
      );
      expect(
        t.widget<Text>(find.text('Delete account')).style!.color,
        AtColors.pinkStrong,
      );
    });

    testWidgets('timeline renders each state', (t) async {
      await t.pumpAt(
        const AtTimeline(
          items: [
            AtTimelineItem(title: 'One', state: AtTimelineState.done),
            AtTimelineItem(title: 'Two', state: AtTimelineState.current),
            AtTimelineItem(title: 'Three'),
          ],
        ),
      );
      expect(find.text('One'), findsOneWidget);
      expect(find.byIcon(LucideIcons.check), findsOneWidget);
      expect(find.byIcon(LucideIcons.play), findsOneWidget);
    });
  });

  group('overlays', () {
    testWidgets(
      'leaving-Atarah modal names the domain and defaults to tracking',
      (t) async {
        LeavingAtarahChoice? result;
        await t.pumpAt(
          AtLeavingAtarahModal(
            domain: 'example.org',
            onResult: (r) => result = r,
          ),
        );
        expect(find.textContaining('example.org'), findsOneWidget);
        expect(
          find.textContaining("doesn't receive or process"),
          findsOneWidget,
        );
        await t.tap(find.text('Continue to website'));
        expect(result!.continueToSite, isTrue);
        expect(result!.trackAsApplied, isTrue);
      },
    );

    testWidgets('unticking track means the application is not recorded', (
      t,
    ) async {
      LeavingAtarahChoice? result;
      await t.pumpAt(
        AtLeavingAtarahModal(
          domain: 'example.org',
          onResult: (r) => result = r,
        ),
      );
      await t.tap(find.text('Track this as applied in Activity'));
      await t.pump();
      await t.tap(find.text('Continue to website'));
      expect(result!.trackAsApplied, isFalse);
    });

    testWidgets('Stay on Atarah returns without continuing or tracking', (
      t,
    ) async {
      LeavingAtarahChoice? result;
      await t.pumpAt(
        AtLeavingAtarahModal(
          domain: 'example.org',
          onResult: (r) => result = r,
        ),
      );
      await t.tap(find.text('Stay on Atarah'));
      expect(result!.continueToSite, isFalse);
      expect(result!.trackAsApplied, isFalse);
    });

    testWidgets(
      'AI sheet labels output, shows the disclaimer, and applies only on Apply',
      (t) async {
        var applied = 0, discarded = 0;
        await t.pumpAt(
          AtAiSheet(
            title: 'Improve my bio',
            onApply: () => applied++,
            onDiscard: () => discarded++,
            child: const Text('Suggestion'),
          ),
        );
        expect(find.text('AI-assisted'), findsOneWidget);
        expect(find.textContaining('Check facts and names'), findsOneWidget);
        expect(applied, 0);
        await t.tap(find.text('Discard'));
        expect((applied, discarded), (0, 1));
        await t.tap(find.text('Apply'));
        expect((applied, discarded), (1, 1));
      },
    );

    testWidgets('AI sheet in test mode says so', (t) async {
      await t.pumpAt(
        AtAiSheet(
          title: 'Help',
          testMode: true,
          onApply: () {},
          onDiscard: () {},
          child: const SizedBox(),
        ),
      );
      expect(find.text('AI preview (test mode)'), findsOneWidget);
      expect(find.text('AI-assisted'), findsNothing);
    });

    testWidgets('bottom sheet and modal open and close', (t) async {
      await t.pumpAt(
        Builder(
          builder: (context) => Column(
            children: [
              AtButton(
                label: 'Sheet',
                onPressed: () => showAtBottomSheet<void>(
                  context: context,
                  title: 'Filters',
                  builder: (_) => const Text('Sheet body'),
                ),
              ),
              AtButton(
                label: 'Modal',
                onPressed: () => showAtModal<void>(
                  context: context,
                  builder: (_) => const Text('Modal body'),
                ),
              ),
            ],
          ),
        ),
      );
      await t.tap(find.text('Sheet'));
      await t.pumpAndSettle();
      expect(find.text('Sheet body'), findsOneWidget);
      expect(find.text('Filters'), findsOneWidget);
      await t.tapAt(const Offset(10, 10));
      await t.pumpAndSettle();
      expect(find.text('Sheet body'), findsNothing);
      await t.tap(find.text('Modal'));
      await t.pumpAndSettle();
      expect(find.text('Modal body'), findsOneWidget);
    });
  });

  group('state components', () {
    testWidgets('empty state offers a next action', (t) async {
      var taps = 0;
      await t.pumpAt(
        SizedBox(
          height: 400,
          child: AtEmptyState(
            icon: LucideIcons.bookmark,
            title: 'Nothing saved',
            ctaLabel: 'Explore',
            onCta: () => taps++,
          ),
        ),
      );
      await t.tap(find.text('Explore'));
      expect(taps, 1);
    });

    testWidgets(
      'error variants say who failed: Atarah, an external site, or a dead link',
      (t) async {
        await t.pumpAt(
          SizedBox(height: 400, child: AtErrorState(onCta: () {})),
        );
        expect(find.text('Something went wrong on our side'), findsOneWidget);
        expect(find.text('Try again'), findsOneWidget);
        await t.pumpAt(
          SizedBox(
            height: 400,
            child: AtErrorState(variant: AtErrorVariant.external, onCta: () {}),
          ),
        );
        expect(find.textContaining("isn't responding"), findsOneWidget);
        expect(
          find.textContaining('Atarah is working normally'),
          findsOneWidget,
        );
        await t.pumpAt(
          SizedBox(
            height: 400,
            child: AtErrorState(
              variant: AtErrorVariant.invalidLink,
              onCta: () {},
            ),
          ),
        );
        expect(find.text('This link no longer works'), findsOneWidget);
      },
    );

    testWidgets('offline banner uses the exact copy', (t) async {
      await t.pumpAt(const AtOfflineBanner());
      expect(
        find.text("You're offline. Saved content is still available."),
        findsOneWidget,
      );
    });

    testWidgets(
      'skeleton has a loading label and stops animating under reduce motion',
      (t) async {
        final handle = t.ensureSemantics();
        await t.pumpWidget(
          atApp(const AtSkeleton(width: 100), disableAnimations: true),
        );
        await t.pump(const Duration(seconds: 3));
        expect(find.bySemanticsLabel('Loading'), findsOneWidget);
        expect(t.binding.hasScheduledFrame, isFalse);
        handle.dispose();
      },
    );

    testWidgets(
      'premium gate explains the feature and shows the price from the caller',
      (t) async {
        var pro = 0, scholarship = 0;
        await t.pumpAt(
          SizedBox(
            height: 800,
            child: AtPremiumGate(
              feature: 'Mentorship',
              whatItDoes: 'Book sessions.',
              whyItMatters: 'Guidance helps.',
              howToGet: 'Upgrade.',
              priceLabel: 'KES 1,200/month',
              onSeePro: () => pro++,
              onCheckScholarship: () => scholarship++,
            ),
          ),
        );
        expect(find.text('Mentorship is part of Pro'), findsOneWidget);
        expect(find.text('What it does'), findsOneWidget);
        expect(find.text('Why it matters'), findsOneWidget);
        expect(find.text('How to get it'), findsOneWidget);
        await t.tap(find.text('See Pro · KES 1,200/month'));
        await t.tap(find.text('Check scholarship eligibility'));
        expect((pro, scholarship), (1, 1));
      },
    );

    testWidgets('future screen labels the phase and goes back', (t) async {
      var back = 0;
      for (final (phase, label) in [
        (AtFuturePhase.p1, 'Soon · P1'),
        (AtFuturePhase.p2, 'Soon · P2'),
        (AtFuturePhase.p3, 'Soon · P3'),
        (AtFuturePhase.later, 'Soon · Later'),
      ]) {
        await t.pumpAt(
          AtFutureScreen(
            phase: phase,
            featureName: 'Marketplace',
            onBack: () => back++,
          ),
          scaffold: false,
        );
        expect(find.text(label), findsOneWidget, reason: label);
        expect(find.text('Marketplace'), findsOneWidget);
      }
      await t.tap(find.text('Go back'));
      expect(back, 1);
    });
  });

  group('tab shell', () {
    testWidgets('has the five tabs in the prototype order and reports taps', (
      t,
    ) async {
      int? selected;
      await t.pumpAt(
        AtTabShell(
          body: const SizedBox(),
          selectedIndex: 0,
          onSelected: (i) => selected = i,
        ),
        scaffold: false,
      );
      final labels = [
        'Home',
        'Explore',
        'Community',
        'Opportunities',
        'Profile',
      ];
      for (final l in labels) {
        expect(find.text(l), findsOneWidget);
      }
      for (final icon in [
        LucideIcons.house,
        LucideIcons.compass,
        LucideIcons.users,
        LucideIcons.briefcase,
        LucideIcons.user,
      ]) {
        expect(find.byIcon(icon), findsOneWidget);
      }
      await t.tap(find.text('Opportunities'));
      expect(selected, 3);
    });

    testWidgets('marks only the selected tab and can hide the bar', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpAt(
        AtTabShell(
          body: const SizedBox(),
          selectedIndex: 1,
          onSelected: (_) {},
        ),
        scaffold: false,
      );
      expect(
        t
            .getSemantics(find.bySemanticsLabel('Explore'))
            .flagsCollection
            .isSelected
            .name,
        'isTrue',
      );
      expect(
        t
            .getSemantics(find.bySemanticsLabel('Home'))
            .flagsCollection
            .isSelected
            .name,
        'isFalse',
      );
      await t.pumpAt(
        AtTabShell(
          body: const SizedBox(),
          selectedIndex: 1,
          onSelected: (_) {},
          showTabs: false,
        ),
        scaffold: false,
      );
      expect(find.byType(AtTabBar), findsNothing);
      handle.dispose();
    });
  });

  group('media', () {
    testWidgets(
      'failed upload offers retry; uploading shows progress; remove works',
      (t) async {
        var retry = 0, removed = 0;
        await t.pumpAt(
          Wrap(
            children: [
              AtMediaTile(
                state: AtMediaTileState.failed,
                onRetry: () => retry++,
              ),
              const AtMediaTile(
                state: AtMediaTileState.uploading,
                progress: 0.45,
              ),
              AtMediaTile(onRemove: () => removed++),
            ],
          ),
        );
        expect(find.text('45%'), findsOneWidget);
        await t.tap(find.bySemanticsLabel('Upload failed. Tap to retry.'));
        await t.tap(find.bySemanticsLabel('Remove'));
        expect((retry, removed), (1, 1));
      },
    );

    testWidgets('upload zone is a labelled button', (t) async {
      var taps = 0;
      await t.pumpAt(AtUploadZone(label: 'Add project', onTap: () => taps++));
      await t.tap(find.text('Add project'));
      expect(taps, 1);
    });
  });

  group('domain widgets', () {
    test(
      'deadline urgency: ≤7 days pink, 8–14 days orange, otherwise none',
      () {
        final now = DateTime.utc(2026, 10, 1);
        expect(
          deadlineUrgency(now.add(const Duration(days: 5)), now),
          DeadlineUrgency.closing,
        );
        expect(
          deadlineUrgency(now.add(const Duration(days: 7)), now),
          DeadlineUrgency.closing,
        );
        expect(
          deadlineUrgency(now.add(const Duration(days: 8)), now),
          DeadlineUrgency.soon,
        );
        expect(
          deadlineUrgency(now.add(const Duration(days: 14)), now),
          DeadlineUrgency.soon,
        );
        expect(
          deadlineUrgency(now.add(const Duration(days: 15)), now),
          DeadlineUrgency.none,
        );
        expect(
          deadlineUrgency(now.subtract(const Duration(days: 1)), now),
          DeadlineUrgency.none,
        );
        expect(deadlineUrgency(null, now), DeadlineUrgency.none);
        expect(
          deadlineUrgency(
            now.add(const Duration(days: 3)),
            now,
            finished: true,
          ),
          DeadlineUrgency.none,
        );
      },
    );

    testWidgets('opportunity card shows only the trust badge it is given', (
      t,
    ) async {
      await t.pumpAt(
        const Column(
          children: [
            OpportunityCard(
              title: 'A',
              providerName: 'P',
              typeLabel: 'Grant',
              trust: OpportunityTrustLevel.verified,
              deadlineLabel: '5 days',
              urgency: DeadlineUrgency.closing,
            ),
            OpportunityCard(
              title: 'B',
              providerName: 'P',
              typeLabel: 'Job',
              trust: OpportunityTrustLevel.externalSource,
              deadlineLabel: '30 days',
              urgency: DeadlineUrgency.none,
            ),
          ],
        ),
      );
      expect(find.text('Verified by Atarah'), findsOneWidget);
      expect(find.text('External source'), findsOneWidget);
    });

    testWidgets('post card like, reply and save are labelled and call back', (
      t,
    ) async {
      var like = 0, reply = 0, save = 0;
      await t.pumpAt(
        PostCard(
          authorName: 'A',
          metaLine: 'now',
          typeLabel: 'Question',
          body: 'Body',
          likeCount: 3,
          replyCount: 1,
          onLike: () => like++,
          onReply: () => reply++,
          onSave: () => save++,
        ),
      );
      await t.tap(find.bySemanticsLabel('Like, 3 likes'));
      await t.tap(find.bySemanticsLabel('Replies, 1'));
      await t.tap(find.bySemanticsLabel('Save post'));
      expect((like, reply, save), (1, 1, 1));
    });

    testWidgets('saved item row can be unsaved', (t) async {
      var removed = 0;
      await t.pumpAt(
        SavedItemRow(
          typeLabel: 'Opportunity',
          title: 'Sample',
          meta: 'Closes soon',
          icon: LucideIcons.briefcase,
          onUnsave: () => removed++,
        ),
      );
      await t.tap(find.bySemanticsLabel('Remove from saved: Sample'));
      expect(removed, 1);
    });

    testWidgets('group card toggles between Join and Joined', (t) async {
      var joined = false;
      await t.pumpAt(
        StatefulBuilder(
          builder: (c, set) => GroupCard(
            name: 'G',
            memberCountLabel: '10',
            typeLabel: 'Discipline',
            joined: joined,
            onToggle: () => set(() => joined = !joined),
          ),
        ),
      );
      expect(find.text('Join'), findsOneWidget);
      await t.tap(find.text('Join'));
      await t.pump();
      expect(find.text('Joined'), findsOneWidget);
    });

    testWidgets('skill card draws the level bar and verification state', (
      t,
    ) async {
      await t.pumpAt(
        const SkillCard(
          name: 'Colour',
          level: 3,
          levelLabel: 'Advanced',
          verification: AtVerification.selfDeclared,
        ),
      );
      expect(find.text('Self-declared'), findsOneWidget);
      expect(find.bySemanticsLabel('Advanced, level 3 of 4'), findsOneWidget);
    });

    testWidgets('passport card shows trust pills only when given', (t) async {
      await t.pumpAt(
        const Column(
          children: [
            PassportCard(
              passportNumber: 'ATR-NBI-0042',
              name: 'N',
              disciplineLine: 'Animation',
              locationLine: 'Nairobi',
              memberSince: 'Member since 2026',
            ),
            PassportCard(
              passportNumber: 'ATR-MSA-0001',
              name: 'N',
              disciplineLine: 'Music',
              locationLine: 'Mombasa',
              memberSince: 'Member since 2026',
              trustLabels: ['Identity verified'],
            ),
          ],
        ),
      );
      expect(find.text('Identity verified'), findsOneWidget);
      expect(find.text('ATR-NBI-0042'), findsOneWidget);
    });
  });
}
