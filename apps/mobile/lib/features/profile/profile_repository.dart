import '../../core/api/generated/export.dart';
import '../../core/networking/failures.dart';
import '../../core/storage/offline_cache.dart';

/// The profile, Passport, public profile and connection endpoints, with errors mapped to typed failures.
/// Widgets go through providers; tests replace this with an in-memory fake.
class ProfileRepository {
  ProfileRepository({required this._api, this._cache});

  final AtarahApiClient _api;

  /// Where the Passport is kept for reading offline (null in tests that do not need it).
  final OfflineCache? _cache;

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on Object catch (e) {
      throw mapError(e);
    }
  }

  Future<OwnProfileDto> me() =>
      _guard(() async => (await _api.profile.myProfile()).data);

  Future<OwnProfileDto> update(UpdateProfileDto body) =>
      _guard(() async => (await _api.profile.updateProfile(body: body)).data);

  /// The Passport. Without a connection the last copy the member saw is returned (read-only); any other failure is
  /// still a failure.
  Future<PassportDto> passport() async {
    try {
      final p = await _guard(
        () async => (await _api.profile.myPassport()).data,
      );
      await _cache?.write('passport', p.toJson());
      return p;
    } on NetworkFailure {
      final saved = await _cache?.read('passport');
      if (saved is Map<String, Object?>) return PassportDto.fromJson(saved);
      rethrow;
    }
  }

  Future<List<SectionVisibilityDto>> setVisibility(
    SetSectionVisibilityDtoSection section,
    SetSectionVisibilityDtoVisibility visibility,
  ) => _guard(
    () async => (await _api.profile.setVisibility(
      body: SetSectionVisibilityDto(section: section, visibility: visibility),
    )).data,
  );

  /// Another member's profile as the caller may see it. [preview] is for the owner's "Public view".
  Future<PublicProfileDto> creative(
    String handle, {
    PublicProfilePreview? preview,
  }) => _guard(
    () async => (await _api.profile.creative(
      handle: handle,
      previewAs: switch (preview) {
        PublicProfilePreview.public => PreviewAs.public,
        PublicProfilePreview.members => PreviewAs.members,
        null => null,
      },
    )).data,
  );

  Future<ConnectionStateDto> connect(String handle) =>
      _guard(() async => (await _api.profile.connect(handle: handle)).data);

  Future<ConnectionStateDto> accept(String connectionId) =>
      _guard(() async => (await _api.profile.accept(id: connectionId)).data);

  Future<ConnectionStateDto> decline(String connectionId) =>
      _guard(() async => (await _api.profile.decline(id: connectionId)).data);

  Future<ConnectionStateDto> removeConnection(String connectionId) => _guard(
    () async => (await _api.profile.removeConnection(id: connectionId)).data,
  );
}

enum PublicProfilePreview { public, members }
