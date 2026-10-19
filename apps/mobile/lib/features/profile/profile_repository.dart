import '../../core/api/generated/export.dart';
import '../../core/networking/failures.dart';

/// The profile, Passport, public profile and connection endpoints, with errors mapped to typed failures.
/// Widgets go through providers; tests replace this with an in-memory fake.
class ProfileRepository {
  ProfileRepository({required this._api});

  final AtarahApiClient _api;

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

  Future<PassportDto> passport() =>
      _guard(() async => (await _api.profile.myPassport()).data);

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
