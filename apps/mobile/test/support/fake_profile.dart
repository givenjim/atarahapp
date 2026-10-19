import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/networking/failures.dart';
import 'package:atarah/features/profile/profile_repository.dart';

const _sections = SectionVisibilityDtoSection.values;

List<SectionVisibilityDto> defaultSections() => [
  for (final s in _sections)
    if (s != SectionVisibilityDtoSection.$unknown)
      SectionVisibilityDto(
        section: s,
        visibility: switch (s) {
          SectionVisibilityDtoSection.location ||
          SectionVisibilityDtoSection.experience =>
            SectionVisibilityDtoVisibility.members,
          SectionVisibilityDtoSection.contact =>
            SectionVisibilityDtoVisibility.private,
          _ => SectionVisibilityDtoVisibility.public,
        },
      ),
];

OwnProfileDto ownProfile({
  String name = 'Nia Wairimu',
  String? handle = 'niawairimu',
  String? headline = 'Character animator',
  String? bio = 'Illustrator and 2D animator in Nairobi.',
  int percent = 70,
  List<CompletionItemDto>? next,
  int skills = 3,
  int connections = 0,
  int pending = 0,
  List<ProfileLinkDto> links = const [],
  bool openToCommissions = false,
  bool acceptConnections = true,
  OwnContactDto? contact,
}) => OwnProfileDto(
  id: 'p-1',
  handle: handle,
  displayName: name,
  headline: headline,
  bio: bio,
  avatarUrl: null,
  discipline: const DisciplineLite(
    id: 'd-1',
    name: 'Animation',
    icon: 'aperture',
  ),
  specialisations: const [
    TaxonomyItemDto(id: 's-1', slug: '2d-animation', name: '2D animation'),
  ],
  skills: const [],
  location: const LocationDto(
    countryName: 'Kenya',
    countyName: 'Nairobi',
    town: 'Kilimani',
  ),
  openToCommissions: openToCommissions,
  acceptConnections: acceptConnections,
  contact:
      contact ??
      const OwnContactDto(
        email: 'nia@example.com',
        phone: '+254712345678',
        showEmail: true,
        showPhone: false,
        forConnections: false,
      ),
  links: links,
  sections: defaultSections(),
  completion: CompletionDto(
    percent: percent,
    items: const [],
    next:
        next ??
        const [
          CompletionItemDto(
            key: 'project',
            label: 'Add your first project',
            weight: 15,
            done: false,
          ),
        ],
  ),
  passport: PassportSummaryDto(
    passportNumber: 'ATR-NBI-0042',
    issuedAt: DateTime.utc(2026, 10, 17),
  ),
  onboardingCompleted: true,
  memberSince: DateTime.utc(2026, 9, 1),
  counts: OwnCountsDto(
    skills: skills,
    connections: connections,
    pendingRequests: pending,
  ),
  shareUrl: handle == null ? null : 'https://atarah.app/$handle',
);

PassportDto passportDto({List<SectionVisibilityDto>? sections}) => PassportDto(
  passportNumber: 'ATR-NBI-0042',
  issuedAt: DateTime.utc(2026, 10, 17),
  displayName: 'Nia Wairimu',
  handle: 'niawairimu',
  avatarUrl: null,
  discipline: 'Animation',
  specialisation: '2D animation',
  location: const LocationDto(
    countryName: 'Kenya',
    countyName: 'Nairobi',
    town: null,
  ),
  memberSince: DateTime.utc(2026, 9, 1),
  trust: const [],
  growth: const GrowthDto(
    score: 17,
    strength: GrowthDtoStrength.early,
    bars: [
      GrowthBarDto(key: 'identity', label: 'Identity', percent: 54),
      GrowthBarDto(key: 'portfolio', label: 'Portfolio', percent: 0),
      GrowthBarDto(key: 'skills', label: 'Skills', percent: 38),
      GrowthBarDto(key: 'learning', label: 'Learning', percent: 0),
      GrowthBarDto(key: 'connections', label: 'Connections', percent: 10),
      GrowthBarDto(
        key: 'professionalisation',
        label: 'Professionalisation',
        percent: 0,
      ),
    ],
  ),
  completion: const CompletionDto(percent: 70, items: [], next: []),
  sections: sections ?? defaultSections(),
  shareUrl: 'https://atarah.app/niawairimu',
);

PublicProfileDto publicProfile({
  String handle = 'amina',
  String name = 'Amina Hassan',
  PublicProfileDtoRelation relation = PublicProfileDtoRelation.member,
  ConnectionStateDto? connection,
  String? bio = 'Documentary photographer on the coast.',
  LocationDto? location = const LocationDto(
    countryName: 'Kenya',
    countyName: 'Mombasa',
    town: null,
  ),
  List<TaxonomyItemDto>? skills = const [
    TaxonomyItemDto(id: 'k-1', slug: 'colour', name: 'Colour'),
  ],
  List<ProfileLinkDto>? links = const [
    ProfileLinkDto(
      id: 'l-1',
      label: 'Instagram',
      url: 'https://instagram.com/amina',
    ),
  ],
  ContactDetailsDto? contact,
  bool openToCommissions = true,
  List<PublicProfileDtoLockedSections> locked = const [],
  num? connectionCount = 4,
}) => PublicProfileDto(
  handle: handle,
  displayName: name,
  avatarUrl: null,
  headline: 'Photographer',
  discipline: const DisciplineLite(
    id: 'd-2',
    name: 'Photography',
    icon: 'camera',
  ),
  specialisations: const [
    TaxonomyItemDto(id: 's-2', slug: 'documentary', name: 'Documentary'),
  ],
  openToCommissions: openToCommissions,
  memberSince: DateTime.utc(2026, 8, 1),
  relation: relation,
  connection:
      connection ??
      const ConnectionStateDto(
        id: null,
        state: ConnectionStateDtoState.none,
        canConnect: true,
      ),
  bio: bio,
  location: location,
  skills: skills,
  links: links,
  contact: contact,
  visibleSections: [
    for (final s in PublicProfileDtoVisibleSections.values)
      if (s != PublicProfileDtoVisibleSections.$unknown &&
          !locked.any((l) => l.json == s.json))
        s,
  ],
  lockedSections: locked,
  connectionCount: connectionCount,
  shareUrl: 'https://atarah.app/$handle',
);

/// In-memory stand-in for the profile API.
class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({OwnProfileDto? me, this.meFailure})
    : own = me ?? ownProfile();

  OwnProfileDto own;
  AppFailure? meFailure;
  AppFailure? updateFailure;
  AppFailure? visibilityFailure;
  AppFailure? connectFailure;
  PassportDto passportData = passportDto();

  /// Profiles other people can open, by handle. A function so tests can vary by preview.
  final Map<String, PublicProfileDto Function(PublicProfilePreview?)>
  creatives = {};

  final List<UpdateProfileDto> updates = [];
  final List<String> calls = [];
  final List<
    (SetSectionVisibilityDtoSection, SetSectionVisibilityDtoVisibility)
  >
  visibility = [];

  /// What the next connection call returns.
  ConnectionStateDto connectionResult = const ConnectionStateDto(
    id: 'c-1',
    state: ConnectionStateDtoState.pendingSent,
    canConnect: false,
  );

  @override
  Future<OwnProfileDto> me() async {
    final f = meFailure;
    if (f != null) {
      meFailure = null;
      throw f;
    }
    return own;
  }

  @override
  Future<OwnProfileDto> update(UpdateProfileDto body) async {
    final f = updateFailure;
    if (f != null) throw f;
    updates.add(body);
    own = ownProfile(
      name: body.displayName ?? own.displayName,
      headline: switch (body.headline) {
        null => own.headline,
        '' => null,
        final h => h,
      },
      bio: body.bio ?? own.bio,
      links: [
        for (final (i, l)
            in (body.links ?? const <ProfileLinkInputDto>[]).indexed)
          ProfileLinkDto(id: 'l$i', label: l.label, url: l.url),
      ],
      openToCommissions: body.openToCommissions ?? own.openToCommissions,
      acceptConnections: body.acceptConnections ?? own.acceptConnections,
      contact: OwnContactDto(
        email: own.contact.email,
        phone: own.contact.phone,
        showEmail: body.contactShowEmail ?? own.contact.showEmail,
        showPhone: body.contactShowPhone ?? own.contact.showPhone,
        forConnections:
            body.contactForConnections ?? own.contact.forConnections,
      ),
    );
    return own;
  }

  @override
  Future<PassportDto> passport() async => passportData;

  @override
  Future<List<SectionVisibilityDto>> setVisibility(
    SetSectionVisibilityDtoSection section,
    SetSectionVisibilityDtoVisibility v,
  ) async {
    final f = visibilityFailure;
    if (f != null) throw f;
    visibility.add((section, v));
    return [
      for (final r in passportData.sections)
        if (r.section.json == section.json)
          SectionVisibilityDto(
            section: r.section,
            visibility: SectionVisibilityDtoVisibility.values.firstWhere(
              (x) => x.json == v.json,
            ),
          )
        else
          r,
    ];
  }

  @override
  Future<PublicProfileDto> creative(
    String handle, {
    PublicProfilePreview? preview,
  }) async {
    calls.add('creative:$handle:${preview?.name ?? '-'}');
    final make = creatives[handle];
    if (make == null) {
      throw const ApiFailure(
        code: 'RESOURCE_NOT_FOUND',
        message: 'We could not find that creative.',
        statusCode: 404,
      );
    }
    return make(preview);
  }

  Future<ConnectionStateDto> _connection(String call) async {
    calls.add(call);
    final f = connectFailure;
    if (f != null) throw f;
    return connectionResult;
  }

  @override
  Future<ConnectionStateDto> connect(String handle) =>
      _connection('connect:$handle');

  @override
  Future<ConnectionStateDto> accept(String connectionId) =>
      _connection('accept:$connectionId');

  @override
  Future<ConnectionStateDto> decline(String connectionId) =>
      _connection('decline:$connectionId');

  @override
  Future<ConnectionStateDto> removeConnection(String connectionId) =>
      _connection('remove:$connectionId');
}
