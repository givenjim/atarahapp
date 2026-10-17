import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../shared/widgets/domain_cards.dart';
import '../../l10n/app_localizations.dart';
import '../design_system.dart';

/// Dev-only component gallery. It lists every design-system component in every state. It is registered
/// only in the `dev` flavour and is covered by golden tests (one image per entry at 1x and 2x text scale).
///
/// Strings here are neutral placeholders ("Sample ..."); no real people, prices or listings.
class GalleryEntry {
  const GalleryEntry(this.id, this.title, this.builder);

  /// Stable id, used as the golden file name.
  final String id;
  final String title;
  final WidgetBuilder builder;
}

Widget _stack(List<Widget> children, {double gap = 14}) => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    for (var i = 0; i < children.length; i++) ...[
      if (i > 0) SizedBox(height: gap),
      children[i],
    ],
  ],
);

Widget _label(String s) => Padding(
  padding: const EdgeInsets.only(bottom: 4),
  child: Text(
    s.toUpperCase(),
    style: AtTextStyles.label.copyWith(color: AtColors.muted),
  ),
);

Widget _labelled(String label, Widget child) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [_label(label), child],
);

void _noop() {}

final List<GalleryEntry> galleryEntries = [
  GalleryEntry('buttons', 'AtButton', (_) {
    return _stack([
      _labelled(
        'Primary · large',
        const AtButton(label: 'Continue', onPressed: _noop),
      ),
      _labelled(
        'Primary · icon',
        const AtButton(
          label: 'Create account',
          icon: LucideIcons.userPlus,
          onPressed: _noop,
        ),
      ),
      _labelled(
        'Primary · loading',
        const AtButton(label: 'Continue', onPressed: _noop, loading: true),
      ),
      _labelled(
        'Primary · disabled',
        const AtButton(label: 'Continue', onPressed: null),
      ),
      _labelled(
        'Secondary',
        const AtButton(
          label: 'Sign in',
          variant: AtButtonVariant.secondary,
          onPressed: _noop,
        ),
      ),
      _labelled(
        'Tertiary',
        const AtButton(
          label: 'Skip for now',
          variant: AtButtonVariant.tertiary,
          onPressed: _noop,
        ),
      ),
      _labelled(
        'Destructive',
        const AtButton(
          label: 'Delete account',
          variant: AtButtonVariant.destructive,
          onPressed: _noop,
        ),
      ),
      _labelled(
        'Medium',
        const AtButton(
          label: 'Medium',
          size: AtButtonSize.md,
          onPressed: _noop,
        ),
      ),
      _labelled(
        'Small',
        const Align(
          alignment: Alignment.centerLeft,
          child: AtButton(
            label: 'Small',
            size: AtButtonSize.sm,
            fullWidth: false,
            onPressed: _noop,
          ),
        ),
      ),
    ]);
  }),
  GalleryEntry('icon-buttons', 'AtIconButton', (_) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        const AtIconButton(
          icon: LucideIcons.chevronLeft,
          semanticLabel: 'Back',
          onPressed: _noop,
        ),
        const AtIconButton(
          icon: LucideIcons.heart,
          semanticLabel: 'Like',
          onPressed: _noop,
          variant: AtIconButtonVariant.floating,
        ),
        Container(
          color: AtColors.ink,
          padding: const EdgeInsets.all(8),
          child: const AtIconButton(
            icon: LucideIcons.share2,
            semanticLabel: 'Share',
            onPressed: _noop,
            variant: AtIconButtonVariant.glass,
          ),
        ),
        const AtIconButton(
          icon: LucideIcons.slidersHorizontal,
          semanticLabel: 'Filters',
          onPressed: _noop,
          variant: AtIconButtonVariant.filter,
          showDot: true,
        ),
        const AtIconButton(
          icon: LucideIcons.plus,
          semanticLabel: 'Compose',
          onPressed: _noop,
          variant: AtIconButtonVariant.gradient,
        ),
        const AtIconButton(
          icon: LucideIcons.bell,
          semanticLabel: 'Notifications',
          onPressed: _noop,
          variant: AtIconButtonVariant.filter,
          badge: 3,
        ),
        const AtIconButton(
          icon: LucideIcons.chevronLeft,
          semanticLabel: 'Back (disabled)',
          onPressed: null,
        ),
      ],
    );
  }),
  GalleryEntry('text-fields', 'AtTextField', (_) {
    return _stack([
      const AtTextField(label: 'Full name', hint: 'Your name'),
      AtTextField(
        label: 'Email or phone number',
        controller: TextEditingController(text: 'sample@example.com'),
      ),
      const AtTextField(
        label: 'Phone',
        prefixText: '+254',
        hint: '712 345 678',
      ),
      const AtTextField(
        label: 'Profile link',
        prefixText: 'atarah.app/',
        hint: 'your-name',
      ),
      AtTextField(
        label: 'Email',
        controller: TextEditingController(text: 'not-an-email'),
        errorText: 'Enter a valid email address.',
      ),
      const AtTextField(
        label: 'County',
        hint: 'Choose',
        helperText: 'Used to personalise what you see.',
      ),
      const AtTextField(
        label: 'Disabled',
        hint: 'Not editable',
        enabled: false,
      ),
      AtTextField(
        label: 'Short bio',
        controller: TextEditingController(text: 'Illustrator and animator.'),
        maxLines: 4,
        minLines: 3,
        maxLength: 160,
        showCounter: true,
      ),
    ]);
  }),
  GalleryEntry('code-input', 'AtCodeInput', (_) {
    return _stack([
      _labelled('Empty', const AtCodeInput()),
      _labelled(
        'Partial',
        AtCodeInput(controller: TextEditingController(text: '482')),
      ),
      _labelled(
        'Complete',
        AtCodeInput(controller: TextEditingController(text: '482913')),
      ),
      _labelled(
        'Error',
        AtCodeInput(
          controller: TextEditingController(text: '000000'),
          hasError: true,
        ),
      ),
    ]);
  }),
  GalleryEntry('password', 'AtPasswordField', (_) {
    return _stack([
      const AtPasswordField(label: 'Password', hint: 'At least 8 characters'),
      _labelled('Weak', const AtPasswordStrengthMeter(password: 'abc')),
      _labelled('Almost', const AtPasswordStrengthMeter(password: 'abcdefgh')),
      _labelled('Strong', const AtPasswordStrengthMeter(password: 'abcdefg1')),
      _labelled(
        'Very strong',
        const AtPasswordStrengthMeter(password: 'Abcdefg1!xyz'),
      ),
    ]);
  }),
  GalleryEntry('selection', 'Checkbox · Toggle · Radio · Segmented', (_) {
    return StatefulBuilder(
      builder: (context, set) {
        return _stack([
          const Row(
            children: [
              Expanded(
                child: AtCheckbox(
                  value: true,
                  onChanged: null,
                  label: 'Checked',
                ),
              ),
              Expanded(
                child: AtCheckbox(
                  value: false,
                  onChanged: null,
                  label: 'Unchecked',
                ),
              ),
            ],
          ),
          const Row(
            children: [
              AtToggle(value: true, onChanged: null, semanticLabel: 'On'),
              SizedBox(width: 16),
              AtToggle(value: false, onChanged: null, semanticLabel: 'Off'),
            ],
          ),
          const AtRadioCard(
            title: 'Members only',
            subtitle: 'Only signed-in members can see it.',
            selected: true,
            onTap: _noop,
          ),
          const AtRadioCard(
            title: 'Public',
            subtitle: 'Anyone can see it.',
            selected: false,
            onTap: _noop,
          ),
          AtSegmented(
            labels: const ['All', 'Closing soon', 'Applied', 'Completed'],
            selectedIndex: 1,
            onChanged: (_) {},
          ),
        ]);
      },
    );
  }),
  GalleryEntry('chips', 'AtChip', (_) {
    return const Wrap(
      spacing: 8,
      runSpacing: 0,
      children: [
        AtChip(label: 'Selected', selected: true, onTap: _noop),
        AtChip(label: 'Not selected', onTap: _noop),
        AtChip(label: 'Removable', kind: AtChipKind.removable, onRemove: _noop),
        AtChip(label: 'Discipline', kind: AtChipKind.dropdown, onTap: _noop),
        AtChip(label: 'With icon', icon: LucideIcons.mapPin, onTap: _noop),
      ],
    );
  }),
  GalleryEntry('tags', 'Tags · Status pills · Verification', (_) {
    return _stack([
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final t in AtTone.values) AtTag(label: t.name, tone: t),
          const AtTag(label: 'Solid', solid: true),
        ],
      ),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final t in AtTone.values) AtStatusPill(label: t.name, tone: t),
        ],
      ),
      const Row(
        children: [
          AtVerifiedTick(),
          SizedBox(width: 12),
          AtVerifiedTick(size: 24),
        ],
      ),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final v in AtVerification.values) AtVerificationBadge(status: v),
        ],
      ),
    ]);
  }),
  GalleryEntry('surfaces', 'Cards · Section header · Top bar · List rows', (_) {
    return _stack([
      const AtTopBar(
        title: 'Settings',
        onBack: _noop,
        actions: [
          AtIconButton(
            icon: LucideIcons.search,
            semanticLabel: 'Search',
            onPressed: _noop,
          ),
        ],
      ),
      const AtSectionHeader(title: 'Recommended for you', onSeeAll: _noop),
      const AtSectionHeader(title: 'Details', compact: true),
      const AtCard(child: Text('A standard card')),
      AtDarkCard(
        child: Text(
          'Dark hero card',
          style: AtTextStyles.sectionTitle.copyWith(color: AtColors.white),
        ),
      ),
      const AtCard(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            AtListRow(
              title: 'Account',
              subtitle: 'Email, phone, username',
              icon: LucideIcons.user,
              onTap: _noop,
              showDivider: true,
            ),
            AtListRow(
              title: 'Privacy & visibility',
              icon: LucideIcons.eye,
              tone: AtTone.purple,
              onTap: _noop,
              showDivider: true,
            ),
            AtListRow(
              title: 'Delete account',
              icon: LucideIcons.trash2,
              destructive: true,
              onTap: _noop,
            ),
          ],
        ),
      ),
      const Row(
        children: [
          Expanded(
            child: AtStatTile(
              value: '3',
              label: 'In progress',
              icon: LucideIcons.bookOpen,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: AtStatTile(
              value: '12',
              label: 'Completed',
              icon: LucideIcons.circleCheck,
              tone: AtTone.success,
            ),
          ),
        ],
      ),
      const AtTimeline(
        items: [
          AtTimelineItem(
            title: 'Application submitted',
            subtitle: 'Step one',
            state: AtTimelineState.done,
          ),
          AtTimelineItem(
            title: 'Under review',
            subtitle: 'In progress',
            state: AtTimelineState.current,
          ),
          AtTimelineItem(title: 'Decision', state: AtTimelineState.upcoming),
        ],
      ),
    ], gap: 16);
  }),
  GalleryEntry('avatars-progress', 'Avatar · Progress', (_) {
    return _stack([
      const Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AtAvatar(name: 'Sample Creative', size: AtAvatar.xs),
          AtAvatar(name: 'Sample Creative', size: AtAvatar.sm),
          AtAvatar(name: 'Sample Creative', size: AtAvatar.md),
          AtAvatar(
            name: 'Sample Creative',
            size: AtAvatar.lg,
            shape: AtAvatarShape.rounded,
          ),
          AtAvatar(name: 'Sample Creative', size: AtAvatar.lg, progress: 0.72),
          AtAvatar(
            name: 'Sample Creative',
            size: AtAvatar.lg,
            shape: AtAvatarShape.rounded,
            progress: 0.4,
          ),
        ],
      ),
      _labelled('Bar · 35%', const AtProgressBar(value: 0.35)),
      _labelled(
        'Bar · green',
        const AtProgressBar(value: 0.8, color: AtColors.successFg),
      ),
      Row(
        children: [
          const AtProgressRing(value: 0.64),
          const SizedBox(width: 16),
          Container(
            color: AtColors.ink,
            padding: const EdgeInsets.all(8),
            child: const AtProgressRing(value: 0.3, onDark: true),
          ),
        ],
      ),
      _labelled('Stepper · 3 of 6', const AtStepper(steps: 6, current: 3)),
    ]);
  }),
  GalleryEntry('sheets-modals', 'Sheet · Modal · Leaving Atarah · AI', (_) {
    return _stack([
      AtSheetFrame(
        title: 'Filters',
        child: _stack([
          const Wrap(
            spacing: 8,
            children: [
              AtChip(label: 'Nairobi', selected: true, onTap: _noop),
              AtChip(label: 'Mombasa', onTap: _noop),
            ],
          ),
          const AtButton(label: 'Show results', onPressed: _noop),
        ]),
      ),
      AtModalFrame(
        child: AtLeavingAtarahModal(domain: 'example.org', onResult: (_) {}),
      ),
      const AtSheetFrame(
        child: AtAiSheet(
          title: 'Improve my bio',
          testMode: true,
          onApply: _noop,
          onDiscard: _noop,
          child: AtCard(
            shadow: false,
            child: Text('Suggested text appears here for review.'),
          ),
        ),
      ),
    ], gap: 24);
  }),
  GalleryEntry('states', 'Skeleton · Empty · Error · Offline', (_) {
    return _stack([
      const AtOfflineBanner(),
      const Row(
        children: [
          AtSkeleton.circle(size: 48),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AtSkeleton(height: 14, width: 160),
                SizedBox(height: 8),
                AtSkeleton(height: 12),
              ],
            ),
          ),
        ],
      ),
      const AtSkeleton(height: 120, radius: 18),
      const SizedBox(
        height: 330,
        child: AtEmptyState(
          icon: LucideIcons.imagePlus,
          title: 'Your portfolio is waiting for its first project.',
          body: 'Projects tell the story of your work.',
          ctaLabel: 'Add project',
          onCta: _noop,
        ),
      ),
      const SizedBox(
        height: 330,
        child: AtErrorState(onCta: _noop, onContactSupport: _noop),
      ),
      const SizedBox(
        height: 330,
        child: AtErrorState(variant: AtErrorVariant.external, onCta: _noop),
      ),
      const SizedBox(
        height: 330,
        child: AtErrorState(variant: AtErrorVariant.invalidLink, onCta: _noop),
      ),
    ], gap: 8);
  }),
  GalleryEntry('premium-future', 'Premium gate · Future screen', (_) {
    return _stack([
      const SizedBox(
        height: 560,
        child: AtPremiumGate(
          feature: 'Mentorship',
          whatItDoes: 'Book one-to-one sessions with approved mentors.',
          whyItMatters: 'Guidance helps you move faster.',
          howToGet: 'Upgrade to Pro, or check scholarship eligibility.',
          priceLabel: 'sample price',
          onSeePro: _noop,
          onCheckScholarship: _noop,
        ),
      ),
      const SizedBox(
        height: 460,
        child: ClipRect(
          child: AtFutureScreen(
            phase: AtFuturePhase.p2,
            featureName: 'Marketplace',
            onBack: _noop,
          ),
        ),
      ),
    ], gap: 16);
  }),
  GalleryEntry('navigation', 'Tab bar · Page wash', (context) {
    final items = atDefaultTabs(AppLocalizations.of(context));
    return _stack([
      AtTabBar(items: items, selectedIndex: 0, onSelected: (_) {}),
      AtTabBar(items: items, selectedIndex: 3, onSelected: (_) {}),
      const SizedBox(
        height: 160,
        child: ClipRRect(
          borderRadius: AtRadii.card,
          child: AtPage(
            wash: AtWash.opportunities,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Opportunities wash'),
            ),
          ),
        ),
      ),
    ]);
  }),
  GalleryEntry('media', 'Upload zone · Media tile', (_) {
    return _stack([
      const AtUploadZone(
        label: 'Add project',
        hint: 'Images, video or audio',
        onTap: _noop,
      ),
      const Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          AtMediaTile(icon: LucideIcons.image, onRemove: _noop),
          AtMediaTile(
            icon: LucideIcons.music,
            state: AtMediaTileState.uploading,
            progress: 0.45,
          ),
          AtMediaTile(
            icon: LucideIcons.video,
            state: AtMediaTileState.failed,
            onRetry: _noop,
          ),
        ],
      ),
    ]);
  }),
  GalleryEntry('domain-cards', 'Domain widgets', (_) {
    return _stack([
      const CreativeCard(
        name: 'Sample Creative',
        roleLine: 'Animation · 2D animation',
        location: 'Nairobi',
        tags: ['Animation', 'Illustration'],
        verified: true,
        actionLabel: 'Connect',
        reason: 'Also works in Animation',
      ),
      const OpportunityCard(
        title: 'Sample opportunity',
        providerName: 'Sample organisation',
        typeLabel: 'Grant',
        trust: OpportunityTrustLevel.verified,
        deadlineLabel: '5 days left',
        urgency: DeadlineUrgency.closing,
        valueLabel: 'Up to sample value',
        locationLabel: 'Remote',
        saved: true,
        onSave: _noop,
      ),
      const OpportunityCard(
        title: 'Another sample opportunity',
        providerName: 'Sample organisation',
        typeLabel: 'Job',
        trust: OpportunityTrustLevel.externalSource,
        deadlineLabel: '12 days left',
        urgency: DeadlineUrgency.soon,
        trackingLabel: 'Applied',
      ),
      const LearningCard(
        title: 'Sample course',
        meta: '7 lessons · Beginner',
        typeLabel: 'Course',
        sourceLabel: 'Atarah Course',
        progress: 0.42,
      ),
      const ListingCard(
        title: 'Sample service',
        sellerName: 'Sample Seller',
        priceLabel: 'From sample price',
        rating: 4.8,
        categoryLabel: 'Design',
      ),
      const MentorCard(
        name: 'Sample Mentor',
        headline: 'Sample headline',
        priceLabel: 'sample price',
        tags: ['Portfolio review'],
        rating: 4.9,
        reviewCount: 24,
        nextAvailability: 'Next: Tue 10:00',
        verified: true,
      ),
      const PostCard(
        authorName: 'Sample Creative',
        metaLine: 'Nairobi · 2h',
        typeLabel: 'Question',
        typeTone: AtTone.info,
        body: 'Sample post text for the gallery.',
        likeCount: 12,
        replyCount: 3,
        liked: true,
      ),
      const ProjectCard(
        title: 'Sample project',
        subtitle: 'Director · 2026',
        featured: true,
      ),
      const PassportCard(
        passportNumber: 'ATR-NBI-0000',
        name: 'Sample Creative',
        disciplineLine: 'Animation · 2D animation',
        locationLine: 'Nairobi, Kenya',
        memberSince: 'Member since 2026',
        trustLabels: ['Identity verified'],
      ),
      const SkillCard(
        name: 'Sample skill',
        level: 3,
        levelLabel: 'Advanced',
        verification: AtVerification.underReview,
        onImprove: _noop,
        onFindOpportunities: _noop,
        onVerify: _noop,
      ),
      const GroupCard(
        name: 'Sample group',
        memberCountLabel: '1.2k members',
        typeLabel: 'Discipline',
        joined: true,
        onToggle: _noop,
      ),
      const NotificationTile(
        title: 'Sample notification',
        body: 'Something happened.',
        timeLabel: '2h ago',
        icon: LucideIcons.bell,
        unread: true,
      ),
      const SavedItemRow(
        typeLabel: 'Opportunity',
        title: 'Sample saved item',
        meta: 'Closes soon',
        icon: LucideIcons.briefcase,
        tone: AtTone.warning,
      ),
    ], gap: 14);
  }),
];

/// The gallery screen: a scrollable list of entries. Registered in the dev flavour only.
class ComponentGalleryScreen extends StatelessWidget {
  const ComponentGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AtColors.white,
      appBar: AppBar(
        title: Text(
          'Component gallery',
          style: AtTextStyles.sectionTitleSm.copyWith(color: AtColors.ink),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AtSpacing.gutter),
        itemCount: galleryEntries.length,
        separatorBuilder: (_, _) => const SizedBox(height: 32),
        itemBuilder: (context, i) {
          final e = galleryEntries[i];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                e.title,
                style: AtTextStyles.sectionTitle.copyWith(color: AtColors.ink),
              ),
              const SizedBox(height: 12),
              e.builder(context),
            ],
          );
        },
      ),
    );
  }
}
