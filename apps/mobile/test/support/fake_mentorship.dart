import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/networking/failures.dart';
import 'package:atarah/features/mentorship/mentorship_repository.dart';

MentorCardDto mentorCard({
  String id = 'm-1',
  String name = 'Wanjiru Kamau',
  String headline = 'Documentary editor',
  bool verified = true,
  num? fromPriceMinor = 150000,
  DateTime? nextAvailableAt,
  num ratingCount = 4,
}) => MentorCardDto(
  id: id,
  displayName: name,
  headline: headline,
  expertiseTags: const ['Editing', 'Storytelling'],
  verified: verified,
  featured: false,
  ratingAverage: 4.8,
  ratingCount: ratingCount,
  sessionsCount: 12,
  currency: 'KES',
  timeZone: 'Africa/Nairobi',
  videoCall: true,
  fromPriceMinor: fromPriceMinor,
  nextAvailableAt: nextAvailableAt ?? DateTime.utc(2026, 12, 1, 6),
);

SessionTypeDto sessionType({
  String id = 's-1',
  String name = 'Portfolio review',
  num priceMinor = 150000,
  num duration = 45,
  bool active = true,
  bool disabledByStaff = false,
}) => SessionTypeDto(
  id: id,
  name: name,
  durationMinutes: duration,
  priceMinor: priceMinor,
  currency: 'KES',
  format: MentorSessionFormat.videoCall,
  sessionCount: 1,
  active: active,
  disabledByStaff: disabledByStaff,
);

MentorDetailDto mentorDetail({
  String id = 'm-1',
  bool allowed = false,
  bool requiresPro = true,
  bool isSelf = false,
  List<SessionTypeDto>? sessions,
}) => MentorDetailDto(
  id: id,
  displayName: 'Wanjiru Kamau',
  headline: 'Documentary editor',
  expertiseTags: const ['Editing'],
  verified: true,
  featured: false,
  ratingAverage: 4.8,
  ratingCount: 4,
  sessionsCount: 12,
  currency: 'KES',
  timeZone: 'Africa/Nairobi',
  videoCall: true,
  fromPriceMinor: 100000,
  bio: 'I have edited documentaries for ten years.',
  yearsExperience: 10,
  disciplines: const [],
  credentials: const [CredentialOutDto(title: 'Editor reel', issuer: 'KFC')],
  sessionTypes:
      sessions ??
      [
        sessionType(),
        sessionType(id: 's-2', name: 'Career chat', priceMinor: 100000),
      ],
  booking: BookingGateDto(
    allowed: allowed,
    requiresPro: requiresPro,
    isSelf: isSelf,
  ),
);

MyMentorDto myMentor({bool listed = true, List<WeeklyRangeDto>? weekly}) =>
    MyMentorDto(
      id: 'm-1',
      status: MentorStatus.approved,
      headline: 'Documentary editor',
      bio: 'I have edited documentaries for ten years and love teaching.',
      yearsExperience: 10,
      expertiseTags: const ['Editing'],
      disciplines: const [],
      credentials: const [],
      timeZone: 'Africa/Nairobi',
      verified: false,
      featured: false,
      ratingAverage: 0,
      ratingCount: 0,
      sessionsCount: 0,
      sessionTypes: [sessionType()],
      availability: AvailabilityDto(
        timeZone: 'Africa/Nairobi',
        weekly: weekly ?? const [],
        exceptions: const [],
      ),
      listed: listed,
    );

/// An in-memory [MentorshipRepository]: it records what the screens ask for and answers what a test sets.
class FakeMentorshipRepository implements MentorshipRepository {
  FakeMentorshipRepository({
    this.homeDto,
    this.mentors = const [],
    this.detailDto,
    this.mine,
    this.application,
    this.requests = const [],
  });

  final MentorshipHomeDto? homeDto;
  final List<MentorCardDto> mentors;
  final MentorDetailDto? detailDto;

  /// Null means "not a mentor": the tools answer 403.
  MyMentorDto? mine;
  final MyApplicationDto? application;
  final List<BookingRequestDto> requests;

  final listCalls = <MentorFilters>[];
  final weeklyCalls = <List<WeeklyRangeDto>>[];
  final createdSessions = <SessionTypeFieldsDto>[];
  ApplyMentorDto? applied;

  @override
  Future<MentorshipHomeDto> home() async => homeDto!;

  @override
  Future<MentorPage> list(
    MentorFilters f, {
    int page = 1,
    int limit = 20,
  }) async {
    listCalls.add(f);
    return MentorPage(mentors, mentors.length);
  }

  @override
  Future<MentorDetailDto> detail(String id) async => detailDto!;

  @override
  Future<ApplicationPrefillDto> prefill() async => const ApplicationPrefillDto(
    headline: 'Documentary editor',
    yearsExperience: 8,
    expertiseTags: ['Editing'],
    disciplineIds: [],
    credentials: [],
    statement: '',
    timeZone: 'Africa/Nairobi',
    profileReady: true,
  );

  @override
  Future<MyApplicationDto> myApplication() async =>
      application ??
      const MyApplicationDto(
        latest: null,
        canApply: true,
        cannotApplyReason: null,
      );

  @override
  Future<MentorApplicationDto> apply(ApplyMentorDto body) async {
    applied = body;
    throw const ApiFailure(
      code: 'CONFLICT',
      message: 'Your application is being reviewed.',
      statusCode: 409,
    );
  }

  @override
  Future<MentorApplicationDto> withdraw() => throw UnimplementedError();

  @override
  Future<MyMentorDto> me() async {
    final m = mine;
    if (m == null) {
      throw const ApiFailure(
        code: 'FORBIDDEN',
        message: 'You do not have permission to do that.',
        statusCode: 403,
      );
    }
    return m;
  }

  @override
  Future<MyMentorDto> updateProfile(UpdateMentorProfileDto body) async => me();

  @override
  Future<MyMentorDto> setPaused(bool paused) async => me();

  @override
  Future<AvailabilityDto> setWeekly(
    List<WeeklyRangeDto> weekly, {
    String? timeZone,
  }) async {
    weeklyCalls.add(weekly);
    return AvailabilityDto(
      timeZone: timeZone ?? 'Africa/Nairobi',
      weekly: weekly,
      exceptions: const [],
    );
  }

  @override
  Future<ExceptionDto> addException(String date, {String? reason}) async =>
      ExceptionDto(id: 'e-1', date: date, reason: reason);

  @override
  Future<void> removeException(String id) async {}

  @override
  Future<SessionTypeDto> createSessionType(SessionTypeFieldsDto body) async {
    createdSessions.add(body);
    return sessionType(id: 's-new', name: body.name);
  }

  @override
  Future<SessionTypeDto> updateSessionType(
    String id,
    UpdateSessionTypeDto body,
  ) async => sessionType(id: id);

  @override
  Future<void> deactivateSessionType(String id) async {}

  @override
  Future<List<BookingRequestDto>> bookingRequests({
    int page = 1,
    int limit = 20,
  }) async => requests;
}
