import 'dart:typed_data';

import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/networking/failures.dart';
import 'package:atarah/features/onboarding/crop_photo_screen.dart';
import 'package:atarah/features/onboarding/device_services.dart';
import 'package:atarah/features/onboarding/onboarding_repository.dart';

const _animationId = 'd-animation';
const _musicId = 'd-music';

const _disciplines = [
  DisciplineDto(
    id: _animationId,
    slug: 'animation',
    name: 'Animation',
    icon: 'aperture',
    specialisations: [
      SpecialisationDto(id: 's-2d', slug: '2d-animation', name: '2D animation'),
      SpecialisationDto(id: 's-3d', slug: '3d-animation', name: '3D animation'),
      SpecialisationDto(
        id: 's-char',
        slug: 'character-design',
        name: 'Character design',
      ),
    ],
  ),
  DisciplineDto(
    id: _musicId,
    slug: 'music',
    name: 'Music',
    icon: 'music',
    specialisations: [
      SpecialisationDto(id: 's-singer', slug: 'singer', name: 'Singer'),
      SpecialisationDto(id: 's-dj', slug: 'dj', name: 'DJ'),
    ],
  ),
];

const _skills = [
  TaxonomyItemDto(id: 'k-ae', slug: 'after-effects', name: 'After Effects'),
  TaxonomyItemDto(id: 'k-pro', slug: 'procreate', name: 'Procreate'),
  TaxonomyItemDto(id: 'k-story', slug: 'storyboarding', name: 'Storyboarding'),
];
const _interests = [
  TaxonomyItemDto(id: 'i-mv', slug: 'music-videos', name: 'Music videos'),
  TaxonomyItemDto(id: 'i-comics', slug: 'comics', name: 'Comics'),
];
const _areas = [
  TaxonomyItemDto(id: 'a-price', slug: 'pricing', name: 'Pricing my work'),
];
const _kenya = CountryDto(
  id: 'c-ke',
  isoCode: 'KE',
  name: 'Kenya',
  callingCode: '+254',
);
const _counties = [
  CountyDto(id: 'n-nbi', code: 'NBI', name: 'Nairobi'),
  CountyDto(id: 'n-msa', code: 'MSA', name: 'Mombasa'),
  CountyDto(id: 'n-ksm', code: 'KSM', name: 'Kisumu'),
];

/// In-memory stand-in for the onboarding API: it keeps the member's saved state the way the server does, so
/// tests exercise resume, skip, clearing on discipline change and completion without a network.
class FakeOnboardingRepository implements OnboardingRepository {
  FakeOnboardingRepository({
    this.step = OnboardingStateDtoStep.intro,
    this.completed = false,
    this.displayName = 'Nia Wairimu',
    this.stateFailure,
  });

  OnboardingStateDtoStep step;
  bool completed;
  String displayName;

  /// Thrown (once) by [state], then cleared, so a retry succeeds.
  AppFailure? stateFailure;

  /// Thrown by the next [saveStep] when set (stays until cleared).
  AppFailure? saveFailure;

  /// Handles that are taken, to exercise the live check and the server's conflict.
  final Set<String> takenHandles = {};
  final Set<String> reservedHandles = {'admin'};

  final List<SaveOnboardingStepDto> saves = [];
  final List<({String disciplineId, String name})> suggestions = [];
  final List<String> handleChecks = [];
  int completeCalls = 0;
  int uploads = 0;
  int removals = 0;
  String? uploadFailure;

  String? disciplineId;
  Set<String> specialisationIds = {};
  Set<String> skillIds = {};
  Set<String> interestIds = {};
  Set<String> areaIds = {};
  String? countyId;
  String? town;
  OnboardingProfileDtoLocationVisibility visibility =
      OnboardingProfileDtoLocationVisibility.members;
  String? handle;
  String? bio;
  String? avatarUrl;
  String? passportNumber;

  /// County names the phone "found", for the location lookup fake.
  final Map<String, String> placeToCounty = {
    'Nairobi County': 'n-nbi',
    'Nairobi': 'n-nbi',
  };

  List<TaxonomyItemDto> _pick(Iterable<TaxonomyItemDto> all, Set<String> ids) =>
      all.where((x) => ids.contains(x.id)).toList();

  OnboardingStateDto snapshot() {
    final d = _disciplines.where((x) => x.id == disciplineId).firstOrNull;
    final specs = [
      for (final disc in _disciplines)
        for (final s in disc.specialisations)
          if (specialisationIds.contains(s.id))
            TaxonomyItemDto(id: s.id, slug: s.slug, name: s.name),
    ];
    final county = _counties.where((c) => c.id == countyId).firstOrNull;
    final done = [
      avatarUrl != null,
      (bio?.trim().length ?? 0) >= 20,
      d != null,
      specs.isNotEmpty,
      skillIds.length >= 3,
      county != null,
      true,
    ];
    final weights = [15, 10, 10, 10, 10, 10, 5];
    var percent = 0;
    for (var i = 0; i < done.length; i++) {
      if (done[i]) percent += weights[i];
    }
    return OnboardingStateDto(
      step: step,
      completed: completed,
      passportNumber: passportNumber,
      completion: CompletionDto(
        percent: percent,
        items: const [],
        next: const [],
      ),
      profile: OnboardingProfileDto(
        id: 'p-1',
        displayName: displayName,
        handle: handle,
        bio: bio,
        headline: null,
        discipline: d == null
            ? null
            : DisciplineLite(id: d.id, name: d.name, icon: d.icon),
        specialisations: specs,
        skills: _pick(_skills, skillIds),
        interests: _pick(_interests, interestIds),
        developmentAreas: _pick(_areas, areaIds),
        countryId: county == null ? null : _kenya.id,
        countryName: county == null ? null : _kenya.name,
        countyId: county?.id,
        countyName: county?.name,
        town: town,
        locationVisibility: visibility,
        avatarUrl: avatarUrl,
      ),
    );
  }

  @override
  Future<OnboardingStateDto> state() async {
    final f = stateFailure;
    if (f != null) {
      stateFailure = null;
      throw f;
    }
    return snapshot();
  }

  @override
  Future<OnboardingStateDto> saveStep(SaveOnboardingStepDto body) async {
    final f = saveFailure;
    if (f != null) throw f;
    saves.add(body);
    if (body.skipped != true) {
      switch (body.step) {
        case SaveOnboardingStepDtoStep.discipline:
          if (body.disciplineId != disciplineId) {
            specialisationIds = {};
          }
          disciplineId = body.disciplineId;
        case SaveOnboardingStepDtoStep.specialisation:
          specialisationIds = {...?body.specialisationIds};
        case SaveOnboardingStepDtoStep.skills:
          if (body.skillIds != null) skillIds = {...body.skillIds!};
          if (body.interestIds != null) interestIds = {...body.interestIds!};
          if (body.developmentAreaIds != null) {
            areaIds = {...body.developmentAreaIds!};
          }
        case SaveOnboardingStepDtoStep.location:
          countyId = body.countyId;
          town = (body.town ?? '').isEmpty ? null : body.town;
          visibility = switch (body.locationVisibility) {
            SaveOnboardingStepDtoLocationVisibility.public =>
              OnboardingProfileDtoLocationVisibility.public,
            SaveOnboardingStepDtoLocationVisibility.private =>
              OnboardingProfileDtoLocationVisibility.private,
            _ => OnboardingProfileDtoLocationVisibility.members,
          };
        case SaveOnboardingStepDtoStep.basics:
          displayName = body.displayName ?? displayName;
          bio = (body.bio ?? '').isEmpty ? null : body.bio;
          final h = body.handle;
          if (h != null) {
            if (takenHandles.contains(h)) {
              throw ApiFailure(
                code: 'CONFLICT',
                message: 'That profile link is taken.',
                statusCode: 409,
                details: {
                  'field': 'handle',
                  'reason': 'TAKEN',
                  'suggestions': ['${h}2', '${h}3'],
                },
              );
            }
            handle = h;
          }
        case SaveOnboardingStepDtoStep.intro:
        case SaveOnboardingStepDtoStep.photo:
        case SaveOnboardingStepDtoStep.$unknown:
          break;
      }
    }
    final next = onboardingStepOrderIndex(body.step) + 1;
    final nextStep = next >= 7 ? OnboardingStateDtoStep.done : _stepAt(next);
    if (_rank(nextStep) > _rank(step)) step = nextStep;
    return snapshot();
  }

  static int onboardingStepOrderIndex(SaveOnboardingStepDtoStep s) =>
      SaveOnboardingStepDtoStep.values.indexOf(s);

  static OnboardingStateDtoStep _stepAt(int i) =>
      OnboardingStateDtoStep.values[i.clamp(
        0,
        OnboardingStateDtoStep.values.length - 1,
      )];

  static int _rank(OnboardingStateDtoStep s) =>
      OnboardingStateDtoStep.values.indexOf(s);

  @override
  Future<OnboardingCompleteDto> complete() async {
    completeCalls++;
    completed = true;
    step = OnboardingStateDtoStep.done;
    handle ??= 'niawairimu';
    final county = _counties.where((c) => c.id == countyId).firstOrNull;
    passportNumber ??= 'ATR-${county?.code ?? 'GEN'}-0042';
    return OnboardingCompleteDto(
      state: snapshot(),
      passport: PassportPreviewDto(
        passportNumber: passportNumber!,
        issuedAt: DateTime.utc(2026, 10, 17),
      ),
    );
  }

  @override
  Future<HandleAvailabilityDto> handleAvailability(String h) async {
    handleChecks.add(h);
    if (reservedHandles.contains(h)) {
      return HandleAvailabilityDto(
        handle: h,
        available: false,
        reason: HandleAvailabilityDtoReason.reserved,
        suggestions: const [],
      );
    }
    if (takenHandles.contains(h)) {
      return HandleAvailabilityDto(
        handle: h,
        available: false,
        reason: HandleAvailabilityDtoReason.taken,
        suggestions: ['${h}2', '${h}3', '${h}4'],
      );
    }
    return HandleAvailabilityDto(
      handle: h,
      available: true,
      reason: null,
      suggestions: const [],
    );
  }

  @override
  Future<List<DisciplineDto>> disciplines() async => _disciplines;

  @override
  Future<List<TaxonomyItemDto>> skills({String? disciplineId}) async => _skills;

  @override
  Future<List<TaxonomyItemDto>> interests() async => _interests;

  @override
  Future<List<TaxonomyItemDto>> developmentAreas() async => _areas;

  @override
  Future<List<CountryDto>> countries() async => const [_kenya];

  @override
  Future<List<CountyDto>> counties({String? country}) async => _counties;

  @override
  Future<CountyMatchDto> matchCounty(String place, {String? country}) async {
    final id = placeToCounty[place];
    return CountyMatchDto(
      county: id == null ? null : _counties.firstWhere((c) => c.id == id),
      countryId: _kenya.id,
    );
  }

  @override
  Future<SuggestionReceiptDto> suggestSpecialisation({
    required String disciplineId,
    required String name,
  }) async {
    if (name.toLowerCase() == 'singer') {
      throw const ApiFailure(
        code: 'CONFLICT',
        message:
            '“Singer” is already in the Music list. Pick it from the list.',
        statusCode: 409,
      );
    }
    suggestions.add((disciplineId: disciplineId, name: name));
    return SuggestionReceiptDto(
      id: 'sg-${suggestions.length}',
      name: name,
      status: SuggestionReceiptDtoStatus.pending,
    );
  }

  @override
  Future<OnboardingStateDto> uploadAvatar(AvatarUpload photo) async {
    final f = uploadFailure;
    if (f != null) {
      throw ApiFailure(code: 'VALIDATION_ERROR', message: f, statusCode: 400);
    }
    uploads++;
    avatarUrl = 'https://img.test/avatar.png';
    return snapshot();
  }

  @override
  Future<OnboardingStateDto> removeAvatar() async {
    removals++;
    avatarUrl = null;
    return snapshot();
  }
}

class FakeLocationLookup implements LocationLookup {
  FakeLocationLookup({this.names = const ['Nairobi County'], this.problem});

  List<String> names;
  LocationProblem? problem;
  int calls = 0;

  @override
  Future<List<String>> placeNames() async {
    calls++;
    final p = problem;
    if (p != null) throw LocationLookupException(p);
    return names;
  }
}

class FakePhotoPicker implements PhotoPicker {
  FakePhotoPicker() : bytes = Uint8List.fromList([1, 2, 3]);

  /// A member who opens the gallery and backs out without choosing.
  FakePhotoPicker.cancelling() : bytes = null;

  final Uint8List? bytes;
  final List<bool> requests = [];

  @override
  Future<Uint8List?> pick({required bool camera}) async {
    requests.add(camera);
    return bytes;
  }
}

/// Stands in for the crop screen, which needs real image decoding.
Future<CroppedPhoto?> fakeCropper(Object context, Uint8List source) async =>
    CroppedPhoto(bytes: source, mimeType: 'image/png');
