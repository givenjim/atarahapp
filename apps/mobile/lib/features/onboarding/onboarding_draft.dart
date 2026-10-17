import 'package:flutter/foundation.dart';

import '../../core/api/generated/export.dart';

/// Limits that mirror the server's caps (the server enforces them; these keep the chips honest).
abstract final class OnboardingLimits {
  static const skills = 20;
  static const interests = 10;
  static const developmentAreas = 10;
  static const bio = 160;
  static const handleMin = 3;
  static const handleMax = 30;
}

final handlePattern = RegExp(r'^[a-z0-9_]{3,30}$');

/// Result of the live "is this link free?" check.
sealed class HandleStatus {
  const HandleStatus();
}

class HandleUnknown extends HandleStatus {
  const HandleUnknown();
}

class HandleChecking extends HandleStatus {
  const HandleChecking();
}

class HandleAvailable extends HandleStatus {
  const HandleAvailable();
}

class HandleUnavailable extends HandleStatus {
  const HandleUnavailable(this.reason, this.suggestions);

  final HandleAvailabilityDtoReason reason;
  final List<String> suggestions;
}

/// What the member has chosen so far, across all steps. Seeded from the server's saved state, so
/// stepping back shows earlier answers and a resumed setup starts where it stopped.
class OnboardingDraft extends ChangeNotifier {
  OnboardingDraft.from(OnboardingStateDto s) {
    syncFrom(s);
  }

  String? disciplineId;
  String? disciplineName;
  Set<String> specialisationIds = {};
  Set<String> skillIds = {};
  Set<String> interestIds = {};
  Set<String> developmentAreaIds = {};

  String? countryId;
  String? countyId;
  String? countyName;
  String town = '';
  SaveOnboardingStepDtoLocationVisibility visibility =
      SaveOnboardingStepDtoLocationVisibility.members;

  String displayName = '';
  String handle = '';
  String bio = '';
  HandleStatus handleStatus = const HandleUnknown();

  String? avatarUrl;
  bool uploadingPhoto = false;

  /// Messages from the server (or the checks) keyed by field, shown under that field.
  final Map<String, String> fieldErrors = {};

  /// Replace everything with what the server holds. Called after each save, so trimmed and normalised
  /// values (for example the lower-cased handle) are what the member sees.
  void syncFrom(OnboardingStateDto s) {
    final p = s.profile;
    disciplineId = p.discipline?.id;
    disciplineName = p.discipline?.name;
    specialisationIds = {for (final x in p.specialisations) x.id};
    skillIds = {for (final x in p.skills) x.id};
    interestIds = {for (final x in p.interests) x.id};
    developmentAreaIds = {for (final x in p.developmentAreas) x.id};
    countryId = p.countryId ?? countryId;
    countyId = p.countyId;
    countyName = p.countyName;
    town = p.town ?? '';
    visibility = switch (p.locationVisibility) {
      OnboardingProfileDtoLocationVisibility.public =>
        SaveOnboardingStepDtoLocationVisibility.public,
      OnboardingProfileDtoLocationVisibility.private =>
        SaveOnboardingStepDtoLocationVisibility.private,
      _ => SaveOnboardingStepDtoLocationVisibility.members,
    };
    displayName = p.displayName;
    handle = p.handle ?? '';
    bio = p.bio ?? '';
    avatarUrl = p.avatarUrl;
    handleStatus = handle.isEmpty
        ? const HandleUnknown()
        : const HandleAvailable();
    fieldErrors.clear();
    notifyListeners();
  }

  void update(void Function() change) {
    change();
    notifyListeners();
  }

  void setError(String field, String? message) {
    if (message == null) {
      fieldErrors.remove(field);
    } else {
      fieldErrors[field] = message;
    }
    notifyListeners();
  }

  /// Picking a different discipline clears the specialisations that belonged to the old one.
  void chooseDiscipline(DisciplineDto d) {
    if (disciplineId == d.id) return;
    update(() {
      disciplineId = d.id;
      disciplineName = d.name;
      specialisationIds = {};
      fieldErrors.remove('disciplineId');
    });
  }

  void toggle(Set<String> set, String id, int max) {
    update(() {
      if (!set.remove(id)) {
        if (set.length >= max) return;
        set.add(id);
      }
    });
  }
}

/// Which of the seven visible screens a server step lands on.
const onboardingStepOrder = <OnboardingStateDtoStep>[
  OnboardingStateDtoStep.intro,
  OnboardingStateDtoStep.discipline,
  OnboardingStateDtoStep.specialisation,
  OnboardingStateDtoStep.skills,
  OnboardingStateDtoStep.location,
  OnboardingStateDtoStep.basics,
  OnboardingStateDtoStep.photo,
];
