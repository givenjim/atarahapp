import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/generated/export.dart';
import '../../core/networking/failures.dart';
import '../../core/providers.dart';

/// What narrows the mentor directory. Equal filters are equal values, so a list is cached per combination.
class MentorFilters {
  const MentorFilters({
    this.q,
    this.disciplineId,
    this.disciplineName,
    this.verified = false,
    this.availableThisWeek = false,
    this.maxPriceMinor,
    this.videoCall = false,
    this.sort = MentorSort.recommended,
  });

  final String? q;
  final String? disciplineId;

  /// Only for showing the chosen discipline on a chip; not sent to the API.
  final String? disciplineName;
  final bool verified;
  final bool availableThisWeek;
  final int? maxPriceMinor;
  final bool videoCall;
  final MentorSort sort;

  /// Filters that live in the sheet (the chips toggle the same values).
  int get activeCount => [
    disciplineId != null,
    verified,
    availableThisWeek,
    maxPriceMinor != null,
    videoCall,
  ].where((x) => x).length;

  MentorFilters copyWith({
    Object? q = _keep,
    Object? disciplineId = _keep,
    Object? disciplineName = _keep,
    bool? verified,
    bool? availableThisWeek,
    Object? maxPriceMinor = _keep,
    bool? videoCall,
    MentorSort? sort,
  }) => MentorFilters(
    q: identical(q, _keep) ? this.q : q as String?,
    disciplineId: identical(disciplineId, _keep)
        ? this.disciplineId
        : disciplineId as String?,
    disciplineName: identical(disciplineName, _keep)
        ? this.disciplineName
        : disciplineName as String?,
    verified: verified ?? this.verified,
    availableThisWeek: availableThisWeek ?? this.availableThisWeek,
    maxPriceMinor: identical(maxPriceMinor, _keep)
        ? this.maxPriceMinor
        : maxPriceMinor as int?,
    videoCall: videoCall ?? this.videoCall,
    sort: sort ?? this.sort,
  );

  MentorFilters cleared() => MentorFilters(q: q, sort: sort);

  static const _keep = Object();

  @override
  bool operator ==(Object other) =>
      other is MentorFilters &&
      other.q == q &&
      other.disciplineId == disciplineId &&
      other.verified == verified &&
      other.availableThisWeek == availableThisWeek &&
      other.maxPriceMinor == maxPriceMinor &&
      other.videoCall == videoCall &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(
    q,
    disciplineId,
    verified,
    availableThisWeek,
    maxPriceMinor,
    videoCall,
    sort,
  );
}

class MentorPage {
  const MentorPage(this.items, this.total);
  final List<MentorCardDto> items;
  final int total;
}

int _total(dynamic meta, int fallback) => meta is Map && meta['total'] is num
    ? (meta['total'] as num).toInt()
    : fallback;

/// Mentorship discovery, mentor onboarding and mentor tools, with errors mapped to typed failures. Widgets go
/// through providers; tests replace this with an in-memory fake.
class MentorshipRepository {
  MentorshipRepository(this._api);

  final AtarahApiClient _api;

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on Object catch (e) {
      throw mapError(e);
    }
  }

  Future<MentorshipHomeDto> home() =>
      _guard(() async => (await _api.mentorship.home()).data);

  Future<MentorPage> list(MentorFilters f, {int page = 1, int limit = 20}) =>
      _guard(() async {
        final res = await _api.mentorship.list(
          q: f.q,
          disciplineId: f.disciplineId,
          verified: f.verified ? true : null,
          availableThisWeek: f.availableThisWeek ? true : null,
          maxPriceMinor: f.maxPriceMinor,
          videoCall: f.videoCall ? true : null,
          sort: f.sort,
          page: page,
          limit: limit,
        );
        return MentorPage(res.data, _total(res.meta, res.data.length));
      });

  Future<MentorDetailDto> detail(String id) =>
      _guard(() async => (await _api.mentorship.detail(id: id)).data);

  Future<ApplicationPrefillDto> prefill() =>
      _guard(() async => (await _api.mentorship.prefill()).data);

  Future<MyApplicationDto> myApplication() =>
      _guard(() async => (await _api.mentorship.mine()).data);

  Future<MentorApplicationDto> apply(ApplyMentorDto body) =>
      _guard(() async => (await _api.mentorship.apply(body: body)).data);

  Future<MentorApplicationDto> withdraw() =>
      _guard(() async => (await _api.mentorship.withdraw()).data);

  // ---- mentor tools ----

  Future<MyMentorDto> me() =>
      _guard(() async => (await _api.mentorTools.me()).data);

  Future<MyMentorDto> updateProfile(UpdateMentorProfileDto body) => _guard(
    () async => (await _api.mentorTools.updateProfile(body: body)).data,
  );

  Future<MyMentorDto> setPaused(bool paused) => _guard(
    () async => (await _api.mentorTools.setPaused(
      body: SetMentorPausedDto(paused: paused),
    )).data,
  );

  Future<AvailabilityDto> setWeekly(
    List<WeeklyRangeDto> weekly, {
    String? timeZone,
  }) => _guard(
    () async => (await _api.mentorTools.setWeekly(
      body: SetWeeklyAvailabilityDto(weekly: weekly, timeZone: timeZone),
    )).data,
  );

  Future<ExceptionDto> addException(String date, {String? reason}) => _guard(
    () async => (await _api.mentorTools.addException(
      body: AddExceptionDto(date: date, reason: reason),
    )).data,
  );

  Future<void> removeException(String id) =>
      _guard(() => _api.mentorTools.removeException(id: id));

  Future<SessionTypeDto> createSessionType(SessionTypeFieldsDto body) => _guard(
    () async => (await _api.mentorTools.createSessionType(body: body)).data,
  );

  Future<SessionTypeDto> updateSessionType(
    String id,
    UpdateSessionTypeDto body,
  ) => _guard(
    () async =>
        (await _api.mentorTools.updateSessionType(id: id, body: body)).data,
  );

  Future<void> deactivateSessionType(String id) =>
      _guard(() => _api.mentorTools.deactivateSessionType(id: id));

  Future<List<BookingRequestDto>> bookingRequests({
    int page = 1,
    int limit = 20,
  }) => _guard(
    () async =>
        (await _api.mentorTools.bookingRequests(page: page, limit: limit)).data,
  );
}

final mentorshipRepositoryProvider = Provider<MentorshipRepository>(
  (ref) => MentorshipRepository(ref.watch(apiClientProvider)),
);

/// The hub's one aggregated payload.
final mentorshipHomeProvider = FutureProvider.autoDispose<MentorshipHomeDto>(
  (ref) => ref.watch(mentorshipRepositoryProvider).home(),
);

/// One page of the directory for a set of filters. The list screen keeps its own paging state on top of this.
final mentorDirectoryProvider = FutureProvider.autoDispose
    .family<MentorPage, MentorFilters>(
      (ref, filters) =>
          ref.watch(mentorshipRepositoryProvider).list(filters, limit: 100),
    );

final mentorDetailProvider = FutureProvider.autoDispose
    .family<MentorDetailDto, String>(
      (ref, id) => ref.watch(mentorshipRepositoryProvider).detail(id),
    );

final applicationPrefillProvider =
    FutureProvider.autoDispose<ApplicationPrefillDto>(
      (ref) => ref.watch(mentorshipRepositoryProvider).prefill(),
    );

final myApplicationProvider = FutureProvider.autoDispose<MyApplicationDto>(
  (ref) => ref.watch(mentorshipRepositoryProvider).myApplication(),
);

/// The signed-in mentor's own profile. A member who is not a mentor gets a failure (403 or 404): the tools
/// screen turns that into the "become a mentor" state.
final myMentorProvider = FutureProvider.autoDispose<MyMentorDto>(
  (ref) => ref.watch(mentorshipRepositoryProvider).me(),
);

final bookingRequestsProvider =
    FutureProvider.autoDispose<List<BookingRequestDto>>(
      (ref) => ref.watch(mentorshipRepositoryProvider).bookingRequests(),
    );
