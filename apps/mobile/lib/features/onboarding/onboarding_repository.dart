import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../core/api/generated/export.dart';
import '../../core/networking/failures.dart';

/// A photo the member picked and cropped, ready to upload.
class AvatarUpload {
  const AvatarUpload({required this.bytes, required this.mimeType});

  final Uint8List bytes;

  /// `image/jpeg` or `image/png`.
  final String mimeType;
}

/// Everything onboarding needs from the API, with errors mapped to typed failures. Widgets go through the
/// controller; tests replace this with an in-memory fake.
class OnboardingRepository {
  OnboardingRepository({required this._api, required this._plain});

  final AtarahApiClient _api;

  /// A Dio with no auth interceptor: the signed upload URL carries its own authority and must not receive
  /// the member's bearer token.
  final Dio _plain;

  /// How long to wait for the background job that validates and resizes the photo.
  static const _processingTimeout = Duration(seconds: 45);
  static const _processingPoll = Duration(milliseconds: 800);

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on Object catch (e) {
      throw mapError(e);
    }
  }

  Future<OnboardingStateDto> state() => _guard(() async {
    return (await _api.onboarding.state()).data;
  });

  Future<OnboardingStateDto> saveStep(SaveOnboardingStepDto body) =>
      _guard(() async => (await _api.onboarding.saveStep(body: body)).data);

  Future<OnboardingCompleteDto> complete() =>
      _guard(() async => (await _api.onboarding.completeOnboarding()).data);

  Future<HandleAvailabilityDto> handleAvailability(String handle) => _guard(
    () async => (await _api.onboarding.availability(
      handle: Uri.encodeComponent(handle),
    )).data,
  );

  Future<List<DisciplineDto>> disciplines() =>
      _guard(() async => (await _api.taxonomy.disciplines()).data);

  Future<List<TaxonomyItemDto>> skills({String? disciplineId}) => _guard(
    () async => (await _api.taxonomy.skills(discipline: disciplineId)).data,
  );

  Future<List<TaxonomyItemDto>> interests() =>
      _guard(() async => (await _api.taxonomy.interests()).data);

  Future<List<TaxonomyItemDto>> developmentAreas() =>
      _guard(() async => (await _api.taxonomy.developmentAreas()).data);

  Future<List<CountryDto>> countries() =>
      _guard(() async => (await _api.locations.countries()).data);

  Future<List<CountyDto>> counties({String? country}) => _guard(
    () async => (await _api.locations.counties(country: country)).data,
  );

  /// Maps a place name from the phone's reverse lookup to a county, or null when nothing matches clearly.
  Future<CountyMatchDto> matchCounty(String place, {String? country}) => _guard(
    () async => (await _api.locations.match(q: place, country: country)).data,
  );

  Future<SuggestionReceiptDto> suggestSpecialisation({
    required String disciplineId,
    required String name,
  }) => _guard(
    () async => (await _api.taxonomy.suggest(
      body: SuggestSpecialisationDto(disciplineId: disciplineId, name: name),
    )).data,
  );

  /// Uploads through the media pipeline (signed PUT, confirm, wait for validation) and attaches the result as
  /// the member's photo. Returns the updated onboarding state.
  Future<OnboardingStateDto> uploadAvatar(AvatarUpload photo) =>
      _guard(() async {
        final ticket = (await _api.media.requestUpload(
          body: RequestUploadDto(
            kind: RequestUploadDtoKind.image,
            mimeType: photo.mimeType,
            sizeBytes: photo.bytes.length,
            visibility: RequestUploadDtoVisibility.public,
          ),
        )).data;
        await _plain.put<void>(
          ticket.uploadUrl,
          data: Stream.fromIterable([photo.bytes]),
          options: Options(
            headers: {
              ...ticket.headers,
              Headers.contentLengthHeader: photo.bytes.length,
            },
            // The storage server answers 200 with an empty body; anything else is a failure.
            validateStatus: (s) => s != null && s >= 200 && s < 300,
          ),
        );
        var asset = (await _api.media.complete(id: ticket.id)).data;
        final deadline = DateTime.now().add(_processingTimeout);
        while (asset.status != MediaAssetDtoStatus.ready) {
          if (asset.status == MediaAssetDtoStatus.rejected ||
              asset.status == MediaAssetDtoStatus.deleted) {
            throw ApiFailure(
              code: 'VALIDATION_ERROR',
              message:
                  asset.rejectionReason ??
                  'That photo could not be used. Try another one.',
              statusCode: 400,
            );
          }
          if (DateTime.now().isAfter(deadline)) {
            throw const NetworkFailure(timedOut: true);
          }
          await Future<void>.delayed(_processingPoll);
          asset = (await _api.media.getApiV1MediaId(id: ticket.id)).data;
        }
        return (await _api.onboarding.setAvatar(
          body: SetAvatarDto(mediaId: ticket.id),
        )).data;
      });

  Future<OnboardingStateDto> removeAvatar() =>
      _guard(() async => (await _api.onboarding.removeAvatar()).data);
}
