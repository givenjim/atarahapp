import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../theme.dart';
import '../tokens.g.dart';
import 'at_tap_target.dart';

/// Page scaffold with the soft radial wash in the top-right corner, tinted per area.
class AtPage extends StatelessWidget {
  const AtPage({
    super.key,
    required this.child,
    this.wash = AtWash.standard,
    this.safeTop = true,
  });

  final Widget child;
  final AtWash wash;
  final bool safeTop;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: AtColors.white)),
        Positioned(
          top: -120,
          right: -120,
          width: 380,
          height: 380,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [wash.color, wash.color.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: SafeArea(top: safeTop, bottom: false, child: child),
        ),
      ],
    );
  }
}

/// One bottom-bar destination.
class AtTabItem {
  const AtTabItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// The five bottom tabs, exactly as in the prototype: Home, Explore, Community, Opportunities, Profile.
List<AtTabItem> atDefaultTabs(AppLocalizations l10n) => [
  AtTabItem(icon: LucideIcons.house, label: l10n.tabHome),
  AtTabItem(icon: LucideIcons.compass, label: l10n.tabExplore),
  AtTabItem(icon: LucideIcons.users, label: l10n.tabCommunity),
  AtTabItem(icon: LucideIcons.briefcase, label: l10n.tabOpportunities),
  AtTabItem(icon: LucideIcons.user, label: l10n.tabProfile),
];

/// Bottom bar with a pill indicator behind the selected icon.
class AtTabBar extends StatelessWidget {
  const AtTabBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<AtTabItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final duration = atDuration(context, AtMotion.base);
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AtColors.white,
        border: Border(top: BorderSide(color: AtColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AtSizes.tabBar,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: i == selectedIndex,
                    label: items[i].label,
                    excludeSemantics: true,
                    onTap: () => onSelected(i),
                    child: InkResponse(
                      onTap: () => onSelected(i),
                      radius: 36,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: duration,
                            width: 56,
                            height: 30,
                            decoration: BoxDecoration(
                              color: i == selectedIndex
                                  ? AtColors.tint1
                                  : Colors.transparent,
                              borderRadius: AtRadii.pill,
                            ),
                            child: Icon(
                              items[i].icon,
                              size: 21,
                              color: i == selectedIndex
                                  ? AtColors.primary
                                  : AtColors.muted,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            items[i].label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AtTextStyles.chipSm.copyWith(
                              fontSize: 10.5,
                              color: i == selectedIndex
                                  ? AtColors.primary
                                  : AtColors.muted,
                              fontWeight: i == selectedIndex
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                          ),
                        ],
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

/// Body plus the tab bar. The router drives [selectedIndex]; screens on the `NO_TABS` list set [showTabs] to false.
class AtTabShell extends StatelessWidget {
  const AtTabShell({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onSelected,
    this.showTabs = true,
    this.items,
    this.banner,
  });

  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool showTabs;
  final List<AtTabItem>? items;

  /// Global banner area, e.g. the offline banner.
  final Widget? banner;

  @override
  Widget build(BuildContext context) {
    final tabs = items ?? atDefaultTabs(AppLocalizations.of(context));
    return Scaffold(
      backgroundColor: AtColors.white,
      body: Column(
        children: [
          if (banner != null) SafeArea(bottom: false, child: banner!),
          Expanded(child: body),
        ],
      ),
      bottomNavigationBar: showTabs
          ? AtTabBar(
              items: tabs,
              selectedIndex: selectedIndex,
              onSelected: onSelected,
            )
          : null,
    );
  }
}
