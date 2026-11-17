import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/networking/failures.dart';
import 'package:atarah/features/opportunities/opportunities_repository.dart';

OpportunityProviderLiteDto provider({
  String id = 'prov-1',
  String name = 'Nairobi Creative Fund',
  bool verified = true,
}) => OpportunityProviderLiteDto(
  id: id,
  name: name,
  type: OpportunityProviderType.ngo,
  verified: verified,
  logoUrl: null,
  website: 'https://nairobicreativefund.example.org',
);

RuleResultDto rule({
  String id = 'r-1',
  OpportunityRuleType type = OpportunityRuleType.minProjects,
  String label = 'At least 3 published projects',
  RuleResultDtoState state = RuleResultDtoState.missing,
  String? detail = 'You have 1 of 3 published projects.',
  RuleFixDto? fix = const RuleFixDto(label: 'Add', path: '/portfolio/new/edit'),
  bool blocking = true,
}) => RuleResultDto(
  id: id,
  ruleType: type,
  label: label,
  isBlocking: blocking,
  state: state,
  detail: detail,
  fix: fix,
);

ProfileGapDto gapOf(
  List<RuleResultDto> rules, {
  ProfileGapDtoVerdict? verdict,
}) {
  final met = rules.where((r) => r.state == RuleResultDtoState.met).length;
  final missing = rules
      .where((r) => r.state == RuleResultDtoState.missing)
      .length;
  final unknown = rules
      .where((r) => r.state == RuleResultDtoState.unknown)
      .length;
  return ProfileGapDto(
    verdict:
        verdict ??
        (rules.isEmpty
            ? ProfileGapDtoVerdict.noRules
            : missing > 0
            ? ProfileGapDtoVerdict.missing
            : met > 0
            ? ProfileGapDtoVerdict.ready
            : ProfileGapDtoVerdict.unchecked),
    metCount: met,
    missingCount: missing,
    unknownCount: unknown,
    blockingMissingCount: rules
        .where((r) => r.state == RuleResultDtoState.missing && r.isBlocking)
        .length,
    rules: rules,
  );
}

/// One opportunity as the detail endpoint answers; [card] gives the list shape.
OpportunityDto oppDto({
  String id = 'o-1',
  String title = 'Emerging Creatives Grant 2027',
  OpportunityType type = OpportunityType.grant,
  OpportunityTrust trust = OpportunityTrust.verified,
  OpportunityProviderLiteDto? by,
  String? value = 'KES 150,000 to 400,000',
  int? daysLeft = 30,
  OpportunityDtoUrgency? urgency,
  bool closed = false,
  bool featured = false,
  bool saved = false,
  TrackingStateDto? tracking,
  ProfileGapDto? gap,
  ApplicationMethod method = ApplicationMethod.externalWebsite,
  String? url = 'https://funds.example.org/apply',
  String? email,
  String? domain = 'funds.example.org',
  String county = 'Nairobi',
  List<String> requirements = const [
    'Kenyan resident',
    'Two published projects',
  ],
  List<String> benefits = const [
    'Unrestricted grant',
    'A mentor for six months',
  ],
}) => OpportunityDto(
  id: id,
  slug: id,
  type: type,
  title: title,
  summary: 'Seed grants for early-career Kenyan creatives.',
  trust: trust,
  provider: by ?? provider(),
  valueLabel: value,
  deadlineAt: daysLeft == null
      ? null
      : DateTime.utc(2026, 10, 24).add(Duration(days: daysLeft)),
  daysLeft: daysLeft,
  urgency: urgency,
  workMode: WorkMode.onsite,
  locationLabel: county,
  featured: featured,
  saved: saved,
  tracking: tracking,
  closed: closed,
  about:
      'The fund supports creatives in the first five years of their practice.',
  requirements: requirements,
  benefits: benefits,
  applicationMethod: method,
  applicationUrl: url,
  applicationEmail: email,
  applicationDomain: domain,
  disciplines: const ['Film / Video'],
  profileGap: gap ?? gapOf(const []),
  shareUrl: 'https://atarah.app/opportunities/$id',
);

OpportunityCardDto cardOf(OpportunityDto o) => OpportunityCardDto(
  id: o.id,
  slug: o.slug,
  type: o.type,
  title: o.title,
  summary: o.summary,
  trust: o.trust,
  provider: o.provider,
  valueLabel: o.valueLabel,
  deadlineAt: o.deadlineAt,
  daysLeft: o.daysLeft,
  urgency: switch (o.urgency) {
    OpportunityDtoUrgency.urgent => OpportunityCardDtoUrgency.urgent,
    OpportunityDtoUrgency.soon => OpportunityCardDtoUrgency.soon,
    _ => null,
  },
  workMode: o.workMode,
  locationLabel: o.locationLabel,
  featured: o.featured,
  saved: o.saved,
  tracking: o.tracking,
  closed: o.closed,
);

TrackingStateDto trackingOf(
  OpportunityTrackingStatus status, {
  OpportunityOutcome? outcome,
}) => TrackingStateDto(
  status: status,
  savedAt: DateTime.utc(2026, 10, 20),
  appliedAt:
      status == OpportunityTrackingStatus.applied ||
          status == OpportunityTrackingStatus.completed
      ? DateTime.utc(2026, 10, 8)
      : null,
  completedAt: status == OpportunityTrackingStatus.completed
      ? DateTime.utc(2026, 10, 22)
      : null,
  outcome: outcome,
);

/// In-memory stand-in for [OpportunitiesRepository]. The member's saves and steps live in [trackings]; every
/// call is recorded in [calls] so tests can assert what was (and was not) sent.
class FakeOpportunitiesRepository implements OpportunitiesRepository {
  FakeOpportunitiesRepository({
    List<OpportunityDto> opportunities = const [],
    Map<String, TrackingStateDto> trackings = const {},
    this.pageSize = 20,
  }) : opportunities = [...opportunities],
       trackings = {...trackings};

  final List<OpportunityDto> opportunities;
  final Map<String, TrackingStateDto> trackings;
  final int pageSize;
  final List<String> calls = [];
  final List<OpportunityFilters> listFilters = [];

  AppFailure? homeFailure;
  AppFailure? listFailure;
  AppFailure? detailFailure;
  AppFailure? saveFailure;
  AppFailure? trackFailure;

  OpportunityDto _live(OpportunityDto o) {
    final t = trackings[o.id];
    return oppDto(
      id: o.id,
      title: o.title,
      type: o.type,
      trust: o.trust,
      by: o.provider,
      value: o.valueLabel,
      daysLeft: o.daysLeft?.toInt(),
      urgency: o.urgency,
      closed: o.closed,
      featured: o.featured,
      saved:
          t != null &&
          (t.status == OpportunityTrackingStatus.saved ||
              t.status == OpportunityTrackingStatus.inProgress),
      tracking: t,
      gap: o.profileGap,
      method: o.applicationMethod,
      url: o.applicationUrl,
      email: o.applicationEmail,
      domain: o.applicationDomain,
      county: o.locationLabel ?? 'Nairobi',
      requirements: o.requirements,
      benefits: o.benefits,
    );
  }

  List<OpportunityCardDto> get _cards => [
    for (final o in opportunities) cardOf(_live(o)),
  ];

  @override
  Future<OpportunitiesHomeDto> home() async {
    calls.add('home');
    final f = homeFailure;
    if (f != null) throw f;
    final cards = _cards;
    return OpportunitiesHomeDto(
      savedCount: cards.where((c) => c.saved).length,
      categories: [
        for (final t in [
          OpportunityType.funding,
          OpportunityType.grant,
          OpportunityType.job,
          OpportunityType.internship,
          OpportunityType.gig,
          OpportunityType.competition,
          OpportunityType.festival,
          OpportunityType.partnership,
        ])
          OpportunityCategoryCountDto(
            type: t,
            count: cards.where((c) => c.type == t).length,
          ),
      ],
      featured: cards.where((c) => c.featured).toList(),
      closingSoon: cards.where((c) => c.urgency != null).toList(),
      recent: cards,
    );
  }

  @override
  Future<OpportunityPage> list(
    OpportunityFilters f, {
    int page = 1,
    int limit = 20,
  }) async {
    calls.add('list:${f.type?.json ?? 'all'}:${f.sort.json}:$page');
    listFilters.add(f);
    final fail = listFailure;
    if (fail != null) throw fail;
    var items = _cards.where((c) => !c.closed).toList();
    if (f.type != null) items = items.where((c) => c.type == f.type).toList();
    if (f.trust != null) {
      items = items.where((c) => c.trust == f.trust).toList();
    }
    if (f.remote) {
      items = items.where((c) => c.workMode == WorkMode.remote).toList();
    }
    final q = f.q?.toLowerCase();
    if (q != null) {
      items = items.where((c) => c.title.toLowerCase().contains(q)).toList();
    }
    final start = (page - 1) * pageSize;
    final slice = items.skip(start).take(pageSize).toList();
    return OpportunityPage(slice, items.length);
  }

  @override
  Future<OpportunityDto> detail(String id, {bool refresh = false}) async {
    calls.add('detail:$id:${refresh ? 'refresh' : 'cached'}');
    final f = detailFailure;
    if (f != null) throw f;
    final found = opportunities.where((o) => o.id == id).firstOrNull;
    if (found == null) {
      throw const ApiFailure(
        code: 'RESOURCE_NOT_FOUND',
        message: 'That opportunity is not available.',
        statusCode: 404,
      );
    }
    return _live(found);
  }

  @override
  Future<TrackingStateDto> save(String id) async {
    calls.add('save:$id');
    final f = saveFailure;
    if (f != null) throw f;
    return trackings.putIfAbsent(
      id,
      () => trackingOf(OpportunityTrackingStatus.saved),
    );
  }

  @override
  Future<void> unsave(String id) async {
    calls.add('unsave:$id');
    final f = saveFailure;
    if (f != null) throw f;
    final t = trackings[id];
    if (t == null) return;
    if (t.status != OpportunityTrackingStatus.saved) {
      throw const ApiFailure(
        code: 'INVALID_STATE',
        message:
            'You have started this one. Mark it applied or completed instead.',
        statusCode: 409,
      );
    }
    trackings.remove(id);
  }

  @override
  Future<TrackingStateDto> track(
    String id,
    OpportunityTrackingStatus status, {
    OpportunityOutcome? outcome,
  }) async {
    calls.add(
      'track:$id:${status.json}${outcome == null ? '' : ':${outcome.json}'}',
    );
    final f = trackFailure;
    if (f != null) throw f;
    final next = trackingOf(
      status,
      outcome: status == OpportunityTrackingStatus.completed
          ? (outcome ?? OpportunityOutcome.unknown)
          : null,
    );
    trackings[id] = next;
    return next;
  }

  @override
  Future<MyOpportunityPage> mine(
    MyTab tab, {
    int page = 1,
    int limit = 20,
  }) async {
    calls.add('mine:${tab.name}:$page');
    final all = [
      for (final o in opportunities)
        if (trackings[o.id] != null)
          MyOpportunityDto(
            opportunity: cardOf(_live(o)),
            tracking: trackings[o.id]!,
          ),
    ];
    bool closing(MyOpportunityDto m) =>
        (m.tracking.status == OpportunityTrackingStatus.saved ||
            m.tracking.status == OpportunityTrackingStatus.inProgress) &&
        m.opportunity.urgency != null;
    bool saved(MyOpportunityDto m) =>
        m.tracking.status == OpportunityTrackingStatus.saved ||
        m.tracking.status == OpportunityTrackingStatus.inProgress;
    bool is_(MyOpportunityDto m, OpportunityTrackingStatus s) =>
        m.tracking.status == s;
    final counts = MyOpportunityCounts(
      all: all.length,
      closing: all.where(closing).length,
      applied: all
          .where((m) => is_(m, OpportunityTrackingStatus.applied))
          .length,
      completed: all
          .where((m) => is_(m, OpportunityTrackingStatus.completed))
          .length,
      saved: all.where(saved).length,
    );
    final items = switch (tab) {
      MyTab.all => all,
      MyTab.closing => all.where(closing).toList(),
      MyTab.applied =>
        all.where((m) => is_(m, OpportunityTrackingStatus.applied)).toList(),
      MyTab.completed =>
        all.where((m) => is_(m, OpportunityTrackingStatus.completed)).toList(),
      MyTab.saved => all.where(saved).toList(),
    };
    return MyOpportunityPage(
      items.skip((page - 1) * pageSize).take(pageSize).toList(),
      items.length,
      counts,
    );
  }
}
