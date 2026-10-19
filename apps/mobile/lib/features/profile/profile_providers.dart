import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/generated/export.dart';
import '../../core/auth/session_controller.dart';
import '../../core/providers.dart';
import 'profile_repository.dart';

part 'profile_providers.g.dart';

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) =>
    ProfileRepository(api: ref.watch(apiClientProvider));

/// The signed-in member's own profile. Null while signed out. Reloads when a different member signs in.
@Riverpod(keepAlive: true)
class MyProfile extends _$MyProfile {
  @override
  Future<OwnProfileDto?> build() async {
    final userId = ref.watch(sessionControllerProvider).value?.id;
    if (userId == null) return null;
    return ref.watch(profileRepositoryProvider).me();
  }

  /// Saves the edit sheet and keeps the new profile as the state. Throws the typed failure.
  Future<OwnProfileDto> save(UpdateProfileDto body) async {
    final next = await ref.read(profileRepositoryProvider).update(body);
    state = AsyncData(next);
    ref.read(analyticsProvider).track('profile_edited');
    return next;
  }

  void refresh() => ref.invalidateSelf();
}

/// The Creative Passport screen's data, with the visibility rows editable in place.
@riverpod
class MyPassport extends _$MyPassport {
  @override
  Future<PassportDto> build() =>
      ref.watch(profileRepositoryProvider).passport();

  /// Changes one row. The screen shows the new value at once and puts the old one back if the save fails.
  Future<void> setVisibility(
    SetSectionVisibilityDtoSection section,
    SetSectionVisibilityDtoVisibility visibility,
  ) async {
    final current = state.requireValue;
    final repo = ref.read(profileRepositoryProvider);
    state = AsyncData(
      _withSections(current, _swap(current.sections, section, visibility)),
    );
    try {
      final saved = await repo.setVisibility(section, visibility);
      state = AsyncData(_withSections(current, saved));
      ref.read(analyticsProvider).track('profile_visibility_changed', {
        'section': section.json,
        'visibility': visibility.json,
      });
      // The profile screen shows the same rows; let it reload next time it is opened.
      ref.invalidate(myProfileProvider);
    } on Object {
      state = AsyncData(current);
      rethrow;
    }
  }

  List<SectionVisibilityDto> _swap(
    List<SectionVisibilityDto> rows,
    SetSectionVisibilityDtoSection section,
    SetSectionVisibilityDtoVisibility visibility,
  ) => [
    for (final r in rows)
      if (r.section.json == section.json)
        SectionVisibilityDto(
          section: r.section,
          visibility: SectionVisibilityDtoVisibility.values.firstWhere(
            (v) => v.json == visibility.json,
            orElse: () => r.visibility,
          ),
        )
      else
        r,
  ];

  PassportDto _withSections(
    PassportDto p,
    List<SectionVisibilityDto> sections,
  ) => PassportDto(
    passportNumber: p.passportNumber,
    issuedAt: p.issuedAt,
    displayName: p.displayName,
    handle: p.handle,
    avatarUrl: p.avatarUrl,
    discipline: p.discipline,
    specialisation: p.specialisation,
    location: p.location,
    memberSince: p.memberSince,
    trust: p.trust,
    growth: p.growth,
    completion: p.completion,
    sections: sections,
    shareUrl: p.shareUrl,
  );
}

/// Another member's profile (or the owner's own, for "Public view"), filtered by the server for the caller.
@riverpod
Future<PublicProfileDto> creativeProfile(
  Ref ref,
  String handle,
  PublicProfilePreview? preview,
) => ref.watch(profileRepositoryProvider).creative(handle, preview: preview);

/// Opens the phone's share sheet with some text. A provider so tests do not need the platform.
typedef ShareText = Future<void> Function(String text);

@Riverpod(keepAlive: true)
ShareText shareText(Ref ref) =>
    (text) async => SharePlus.instance.share(ShareParams(text: text));

/// Opens a web address in the browser. A provider so tests do not need the platform.
typedef OpenLink = Future<bool> Function(Uri uri);

@Riverpod(keepAlive: true)
OpenLink openLink(Ref ref) =>
    (uri) => launchUrl(uri, mode: LaunchMode.externalApplication);
