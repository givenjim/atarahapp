import '../../core/api/generated/export.dart';
import '../../core/l10n/app_localizations.dart';

String sectionLabel(AppLocalizations l10n, SectionVisibilityDtoSection s) =>
    switch (s) {
      SectionVisibilityDtoSection.bio => l10n.secBio,
      SectionVisibilityDtoSection.location => l10n.secLocation,
      SectionVisibilityDtoSection.portfolio => l10n.secPortfolio,
      SectionVisibilityDtoSection.skills => l10n.secSkills,
      SectionVisibilityDtoSection.experience => l10n.secExperience,
      SectionVisibilityDtoSection.services => l10n.secServices,
      SectionVisibilityDtoSection.links => l10n.secLinks,
      SectionVisibilityDtoSection.contact => l10n.secContact,
      SectionVisibilityDtoSection.$unknown => '',
    };

String publicSectionLabel(
  AppLocalizations l10n,
  PublicProfileDtoLockedSections s,
) => switch (s) {
  PublicProfileDtoLockedSections.bio => l10n.secBio,
  PublicProfileDtoLockedSections.location => l10n.secLocation,
  PublicProfileDtoLockedSections.portfolio => l10n.secPortfolio,
  PublicProfileDtoLockedSections.skills => l10n.secSkills,
  PublicProfileDtoLockedSections.experience => l10n.secExperience,
  PublicProfileDtoLockedSections.services => l10n.secServices,
  PublicProfileDtoLockedSections.links => l10n.secLinks,
  PublicProfileDtoLockedSections.contact => l10n.secContact,
  PublicProfileDtoLockedSections.$unknown => '',
};

String visibilityLabel(
  AppLocalizations l10n,
  SectionVisibilityDtoVisibility v,
) => switch (v) {
  SectionVisibilityDtoVisibility.public => l10n.vsPublic,
  SectionVisibilityDtoVisibility.members => l10n.vsMembers,
  SectionVisibilityDtoVisibility.private => l10n.vsPrivate,
  SectionVisibilityDtoVisibility.$unknown => '',
};

String visibilityNote(
  AppLocalizations l10n,
  SetSectionVisibilityDtoVisibility v,
) => switch (v) {
  SetSectionVisibilityDtoVisibility.public => l10n.vsPublicNote,
  SetSectionVisibilityDtoVisibility.members => l10n.vsMembersNote,
  SetSectionVisibilityDtoVisibility.private => l10n.vsPrivateNote,
  SetSectionVisibilityDtoVisibility.$unknown => '',
};

String visibilityOptionLabel(
  AppLocalizations l10n,
  SetSectionVisibilityDtoVisibility v,
) => switch (v) {
  SetSectionVisibilityDtoVisibility.public => l10n.vsPublic,
  SetSectionVisibilityDtoVisibility.members => l10n.vsMembers,
  SetSectionVisibilityDtoVisibility.private => l10n.vsPrivate,
  SetSectionVisibilityDtoVisibility.$unknown => '',
};

String strengthLabel(AppLocalizations l10n, GrowthDtoStrength s) => switch (s) {
  GrowthDtoStrength.early => l10n.ppStrengthEarly,
  GrowthDtoStrength.growing => l10n.ppStrengthGrowing,
  GrowthDtoStrength.active => l10n.ppStrengthActive,
  GrowthDtoStrength.strong => l10n.ppStrengthStrong,
  GrowthDtoStrength.$unknown => '',
};

String growthLabel(AppLocalizations l10n, String key) => switch (key) {
  'identity' => l10n.ppGrowthIdentity,
  'portfolio' => l10n.ppGrowthPortfolio,
  'skills' => l10n.ppGrowthSkills,
  'learning' => l10n.ppGrowthLearning,
  'connections' => l10n.ppGrowthConnections,
  'professionalisation' => l10n.ppGrowthProfessionalisation,
  _ => key,
};

/// "Nairobi, Kenya" (or just the part that is set). Null when nothing is set.
String? placeLine(LocationDto? l) {
  if (l == null) return null;
  final parts = [
    l.countyName,
    l.countryName,
  ].whereType<String>().where((s) => s.isNotEmpty).toList();
  return parts.isEmpty ? null : parts.join(', ');
}
