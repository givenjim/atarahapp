import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/api/generated/export.dart';
import '../../core/auth/session_controller.dart';
import '../../core/providers.dart';
import 'crop_photo_screen.dart';
import 'device_services.dart';
import 'onboarding_repository.dart';

part 'onboarding_providers.g.dart';

@Riverpod(keepAlive: true)
OnboardingRepository onboardingRepository(Ref ref) => OnboardingRepository(
  api: ref.watch(apiClientProvider),
  plain: ref.watch(plainDioProvider),
);

@Riverpod(keepAlive: true)
LocationLookup locationLookup(Ref ref) => const DeviceLocationLookup();

@Riverpod(keepAlive: true)
PhotoPicker photoPicker(Ref ref) => DevicePhotoPicker();

@Riverpod(keepAlive: true)
PhotoCropper photoCropper(Ref ref) => openCropScreen;

/// How a photo URL becomes an image. A provider so tests can avoid real network requests.
typedef AvatarImageBuilder = ImageProvider Function(String url);

@Riverpod(keepAlive: true)
AvatarImageBuilder avatarImage(Ref ref) => NetworkImage.new;

/// Where the router should send a signed-in member.
enum OnboardingGate {
  /// The state has not loaded yet (the splash keeps showing).
  pending,

  /// Setup is not finished: resume it.
  incomplete,

  /// Setup is finished, or could not be checked (never trap a member behind a failing request).
  complete,
}

/// The signed-in member's onboarding state, fetched from the server. Null while signed out. Every step is
/// saved on the server, so this is also what resumes setup after the app is closed.
@Riverpod(keepAlive: true)
class OnboardingController extends _$OnboardingController {
  @override
  Future<OnboardingStateDto?> build() async {
    final userId = ref.watch(sessionControllerProvider).value?.id;
    if (userId == null) return null;
    return ref.watch(onboardingRepositoryProvider).state();
  }

  /// Store a state the server just returned.
  void apply(OnboardingStateDto next) => state = AsyncData(next);

  Future<OnboardingStateDto> saveStep(SaveOnboardingStepDto body) async {
    final next = await ref.read(onboardingRepositoryProvider).saveStep(body);
    apply(next);
    return next;
  }

  Future<OnboardingCompleteDto> complete() async {
    final done = await ref.read(onboardingRepositoryProvider).complete();
    ref.read(analyticsProvider).track('onboarding_completed');
    apply(done.state);
    return done;
  }

  Future<OnboardingStateDto> uploadAvatar(AvatarUpload photo) async {
    final next = await ref
        .read(onboardingRepositoryProvider)
        .uploadAvatar(photo);
    apply(next);
    return next;
  }

  void retry() => ref.invalidateSelf();
}

@Riverpod(keepAlive: true)
OnboardingGate onboardingGate(Ref ref) {
  if (ref.watch(sessionStatusProvider) != SessionStatus.signedIn) {
    return OnboardingGate.complete;
  }
  final s = ref.watch(onboardingControllerProvider);
  if (s.hasValue && s.value != null) {
    return s.value!.completed
        ? OnboardingGate.complete
        : OnboardingGate.incomplete;
  }
  if (s.hasError) return OnboardingGate.complete;
  return OnboardingGate.pending;
}

// ---- reference lists ---------------------------------------------------------------------------------------
// Small, rarely changing and fetched when a step opens.

@riverpod
Future<List<DisciplineDto>> disciplines(Ref ref) =>
    ref.watch(onboardingRepositoryProvider).disciplines();

@riverpod
Future<List<TaxonomyItemDto>> skillOptions(Ref ref, String? disciplineId) =>
    ref.watch(onboardingRepositoryProvider).skills(disciplineId: disciplineId);

@riverpod
Future<List<TaxonomyItemDto>> interestOptions(Ref ref) =>
    ref.watch(onboardingRepositoryProvider).interests();

@riverpod
Future<List<TaxonomyItemDto>> developmentAreaOptions(Ref ref) =>
    ref.watch(onboardingRepositoryProvider).developmentAreas();

@riverpod
Future<List<CountryDto>> countryOptions(Ref ref) =>
    ref.watch(onboardingRepositoryProvider).countries();

@riverpod
Future<List<CountyDto>> countyOptions(Ref ref, String? country) =>
    ref.watch(onboardingRepositoryProvider).counties(country: country);
