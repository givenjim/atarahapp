import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Taxonomy entries carry a Lucide icon *name* (admins can add disciplines), so the app maps the names it
/// knows onto icons. An unknown name shows a neutral icon instead of nothing.
IconData lucideByName(String name) => switch (name) {
  'music' => LucideIcons.music,
  'drama' => LucideIcons.drama,
  'person-standing' => LucideIcons.personStanding,
  'pen-line' => LucideIcons.penLine,
  'shirt' => LucideIcons.shirt,
  'palette' => LucideIcons.palette,
  'camera' => LucideIcons.camera,
  'clapperboard' => LucideIcons.clapperboard,
  'pen-tool' => LucideIcons.penTool,
  'aperture' => LucideIcons.aperture,
  'sliders-vertical' => LucideIcons.slidersVertical,
  'lightbulb' => LucideIcons.lightbulb,
  'hammer' => LucideIcons.hammer,
  'sparkles' => LucideIcons.sparkles,
  'image' => LucideIcons.image,
  'users' => LucideIcons.users,
  'briefcase' => LucideIcons.briefcase,
  'graduation-cap' => LucideIcons.graduationCap,
  _ => LucideIcons.sparkles,
};
