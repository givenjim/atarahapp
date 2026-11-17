import 'package:atarah/core/api/generated/export.dart' hide Visibility;
import 'package:atarah/core/api/generated/export.dart' as api show Visibility;
import 'package:atarah/core/auth/two_step.dart';
import 'package:atarah/core/networking/failures.dart';
import 'package:atarah/features/account/account_repository.dart';

import 'fake_opportunities.dart';

// ---- builders --------------------------------------------------------------------------------------------------

final _now = DateTime.utc(2026, 10, 22, 12);

NotificationItemDto notif({
  String id = 'n-1',
  String title = 'New connection request',
  String body = 'Nia Wairimu wants to connect with you.',
  NotificationCategory category = NotificationCategory.community,
  bool read = false,
  NotificationItemDtoGroup group = NotificationItemDtoGroup.today,
  String? deepLink = '/creatives/nia_wairimu',
  Duration ago = const Duration(minutes: 5),
}) => NotificationItemDto(
  id: id,
  category: category,
  type: null,
  title: title,
  body: body,
  deepLink: deepLink,
  data: null,
  read: read,
  createdAt: _now.subtract(ago),
  group: group,
);

SavedItemDto savedItem({
  SavedKind type = SavedKind.opportunity,
  String id = 's-1',
  String title = 'Emerging Creatives Grant 2027',
  String? subtitle = 'Nairobi Creative Fund · closes in 9 days',
  String path = '/opportunities/o-1',
}) => SavedItemDto(
  type: type,
  targetId: id,
  savedAt: _now,
  collection: null,
  title: title,
  subtitle: subtitle,
  imageUrl: null,
  path: path,
  article: null,
);

ActivityDto activity({
  List<ResumeCardDto>? resume,
  int saved = 3,
  int applications = 2,
  int learning = 1,
  int portfolio = 4,
  int pending = 1,
  int unread = 5,
}) => ActivityDto(
  resume:
      resume ??
      [
        ResumeCardDto(
          kind: ResumeCardDtoKind.lesson,
          title: 'Choosing your three projects',
          subtitle: 'Build a Portfolio That Gets You Hired',
          progressPercent: 40,
          path: '/learning/lessons/l-2',
          updatedAt: _now,
        ),
        ResumeCardDto(
          kind: ResumeCardDtoKind.opportunityGap,
          title: 'Emerging Creatives Grant 2027',
          subtitle: 'Missing 2 requirements',
          progressPercent: null,
          path: '/opportunities/o-1',
          updatedAt: _now,
        ),
        ResumeCardDto(
          kind: ResumeCardDtoKind.draftProject,
          title: 'Lake Victoria Stories',
          subtitle: null,
          progressPercent: null,
          path: '/portfolio/p-1/edit',
          updatedAt: _now,
        ),
      ],
  counts: ActivityCountsDto(
    saved: saved,
    applications: applications,
    unreadNotifications: unread,
    learningInProgress: learning,
    portfolio: portfolio,
    pendingConnections: pending,
  ),
);

ApplicationItemDto application({
  String id = 'o-1',
  String title = 'Emerging Creatives Grant 2027',
  ApplicationItemDtoStatus status = ApplicationItemDtoStatus.applied,
  String meta = 'Applied 12 Oct 2026',
}) => ApplicationItemDto(
  opportunity: cardOf(oppDto(id: id, title: title)),
  tracking: trackingOf(OpportunityTrackingStatus.applied),
  status: status,
  metaLine: meta,
);

AccountDto accountDto({
  String name = 'Nia Wairimu',
  String? handle = 'nia_wairimu',
  String? email = 'nia@example.com',
  bool emailVerified = true,
  String? phone,
  bool phoneVerified = false,
  String? pendingEmail,
}) => AccountDto(
  fullName: name,
  handle: handle,
  email: email,
  emailVerified: emailVerified,
  phone: phone,
  phoneVerified: phoneVerified,
  pendingEmail: pendingEmail,
  pendingPhone: null,
);

List<PrivacyFieldDto> privacyFields() => [
  for (final (f, label) in [
    (PrivacyField.contact, 'Contact details'),
    (PrivacyField.location, 'Location'),
    (PrivacyField.portfolio, 'Portfolio'),
    (PrivacyField.experience, 'Experience'),
    (PrivacyField.activity, 'Activity'),
  ])
    PrivacyFieldDto(
      field: f,
      label: label,
      visibility: f == PrivacyField.contact
          ? api.Visibility.private
          : api.Visibility.members,
      defaultVisibility: api.Visibility.members,
    ),
];

// ---- activity, notifications, saved -----------------------------------------------------------------------------

class FakeActivityRepository implements ActivityRepository {
  FakeActivityRepository({ActivityDto? hub, List<ApplicationItemDto>? apps})
    : hubData = hub ?? activity(),
      apps = apps ?? [application()];

  ActivityDto hubData;
  List<ApplicationItemDto> apps;
  AppFailure? failure;

  @override
  Future<ActivityDto> hub() async {
    if (failure case final f?) throw f;
    return hubData;
  }

  @override
  Future<PageOf<ApplicationItemDto>> applications({
    int page = 1,
    int limit = 20,
  }) async {
    if (failure case final f?) throw f;
    return PageOf(apps, apps.length);
  }
}

class FakeNotificationsRepository implements NotificationsRepository {
  FakeNotificationsRepository({List<NotificationItemDto>? items})
    : items = items ?? [notif()];

  List<NotificationItemDto> items;
  AppFailure? failure;
  AppFailure? readAllFailure;
  final List<String> markedRead = [];
  final List<NotificationCategory?> readAllCalls = [];
  final List<NotificationCategory?> listCalls = [];
  List<PreferenceDto> prefs = [
    for (final c in PreferenceDtoCategory.values.where((c) => c.json != null))
      PreferenceDto(category: c, pushEnabled: true, emailEnabled: true),
  ];
  AppFailure? prefsFailure;
  final List<List<PreferenceDto>> prefUpdates = [];

  int get unread => items.where((n) => !n.read).length;

  @override
  Future<PageOf<NotificationItemDto>> list({
    NotificationCategory? category,
    int page = 1,
    int limit = 20,
  }) async {
    listCalls.add(category);
    if (failure case final f?) throw f;
    final rows = category == null
        ? items
        : items.where((n) => n.category == category).toList();
    return PageOf(rows, rows.length);
  }

  @override
  Future<UnreadCountDto> unreadCount() async =>
      UnreadCountDto(unread: unread, byCategory: const {});

  @override
  Future<void> markRead(String id) async {
    markedRead.add(id);
    items = [
      for (final n in items)
        if (n.id == id)
          NotificationItemDto(
            id: n.id,
            category: n.category,
            type: n.type,
            title: n.title,
            body: n.body,
            deepLink: n.deepLink,
            data: n.data,
            read: true,
            createdAt: n.createdAt,
            group: n.group,
          )
        else
          n,
    ];
  }

  @override
  Future<void> readAll({NotificationCategory? category}) async {
    readAllCalls.add(category);
    if (readAllFailure case final f?) throw f;
    items = [
      for (final n in items)
        NotificationItemDto(
          id: n.id,
          category: n.category,
          type: n.type,
          title: n.title,
          body: n.body,
          deepLink: n.deepLink,
          data: n.data,
          read: category == null || n.category == category ? true : n.read,
          createdAt: n.createdAt,
          group: n.group,
        ),
    ];
  }

  @override
  Future<List<PreferenceDto>> preferences() async {
    if (prefsFailure case final f?) throw f;
    return prefs;
  }

  @override
  Future<List<PreferenceDto>> updatePreferences(
    List<PreferenceDto> next,
  ) async {
    if (prefsFailure case final f?) throw f;
    prefUpdates.add(next);
    prefs = [
      for (final p in prefs)
        next.firstWhere((n) => n.category == p.category, orElse: () => p),
    ];
    return prefs;
  }
}

class FakeSavedRepository implements SavedRepository {
  FakeSavedRepository({List<SavedItemDto>? items}) : items = items ?? [];

  List<SavedItemDto> items;
  AppFailure? failure;
  AppFailure? unsaveFailure;
  final List<(SavedKind, String)> unsaved = [];

  @override
  Future<PageOf<SavedItemDto>> list({
    SavedKind? type,
    int page = 1,
    int limit = 20,
  }) async {
    if (failure case final f?) throw f;
    final rows = type == null
        ? items
        : items.where((s) => s.type == type).toList();
    return PageOf(rows, rows.length);
  }

  @override
  Future<SavedCountsDto> counts() async =>
      SavedCountsDto(total: items.length, byType: const {});

  @override
  Future<void> save(SavedKind type, String id) async {}

  @override
  Future<void> unsave(SavedKind type, String id) async {
    if (unsaveFailure case final f?) throw f;
    unsaved.add((type, id));
    items = items.where((s) => !(s.type == type && s.targetId == id)).toList();
  }
}

// ---- account ---------------------------------------------------------------------------------------------------

class FakeAccountRepository implements AccountRepository {
  AccountDto accountData = accountDto();
  List<PrivacyFieldDto> fields = privacyFields();
  SecurityDto securityData = const SecurityDto(
    factors: [],
    twoStepEnabled: false,
    hasVerifiedFactor: true,
    activeSessions: 2,
    deviceCount: 2,
  );
  List<SessionViewDto> sessionList = [
    SessionViewDto(
      id: 'sess-1',
      client: SessionViewDtoClient.android,
      deviceName: 'Pixel 6',
      approxLocation: 'Nairobi',
      lastActiveAt: _now,
      current: true,
    ),
    SessionViewDto(
      id: 'sess-2',
      client: SessionViewDtoClient.web,
      deviceName: 'Chrome on Windows',
      approxLocation: null,
      lastActiveAt: _now.subtract(const Duration(days: 2)),
      current: false,
    ),
  ];
  ExportStateDto exportData = const ExportStateDto(
    status: ExportStateDtoStatus.none,
    id: null,
    requestedAt: null,
    expiresAt: null,
    downloadUrl: null,
    nextAllowedAt: null,
  );
  MembershipViewDto membershipData = const MembershipViewDto(
    plan: MembershipViewDtoPlan.free,
    status: null,
    currentPeriodEnd: null,
    proPriceLabel: 'KES 1,200/month',
    comparison: [
      PlanRowDto(
        label: 'Creative Passport and portfolio',
        free: true,
        pro: true,
      ),
      PlanRowDto(
        label: 'Book paid mentorship sessions',
        free: false,
        pro: true,
      ),
      PlanRowDto(label: 'Reduced marketplace fees', free: false, pro: true),
    ],
    scholarshipNote:
        'Students and programme participants may qualify for free Pro access.',
  );

  AppFailure? failure;
  AppFailure? privacyFailure;
  AppFailure? deleteFailure;
  final List<(PrivacyField, api.Visibility)> privacyCalls = [];
  final List<({String confirm, String? password})> deleteCalls = [];
  final List<String> revoked = [];
  final List<bool> twoStepCalls = [];
  int restoreCalls = 0;
  int exportRequests = 0;
  ({String? fullName, String? handle})? lastUpdate;

  @override
  Future<AccountDto> account() async {
    if (failure case final f?) throw f;
    return accountData;
  }

  @override
  Future<AccountDto> updateAccount({String? fullName, String? handle}) async {
    lastUpdate = (fullName: fullName, handle: handle);
    accountData = accountDto(
      name: fullName ?? accountData.fullName,
      handle: handle ?? accountData.handle,
    );
    return accountData;
  }

  @override
  Future<ContactChangeStartedDto> changeEmail(String email) async =>
      ContactChangeStartedDto(
        kind: ContactChangeStartedDtoKind.email,
        sentTo: email,
      );

  @override
  Future<ContactChangeStartedDto> changePhone(String phone) async =>
      ContactChangeStartedDto(
        kind: ContactChangeStartedDtoKind.phone,
        sentTo: phone,
      );

  @override
  Future<void> verifyPhone(String phone, String code) async {}

  @override
  Future<void> changePassword(String current, String next) async {}

  @override
  Future<PrivacyDto> privacy() async => PrivacyDto(fields: fields);

  @override
  Future<PrivacyDto> setPrivacy(
    PrivacyField field,
    api.Visibility visibility,
  ) async {
    privacyCalls.add((field, visibility));
    if (privacyFailure case final f?) throw f;
    fields = [
      for (final x in fields)
        if (x.field == field)
          PrivacyFieldDto(
            field: x.field,
            label: x.label,
            visibility: visibility,
            defaultVisibility: x.defaultVisibility,
          )
        else
          x,
    ];
    return PrivacyDto(fields: fields);
  }

  @override
  Future<SecurityDto> security() async => securityData;

  @override
  Future<List<SessionViewDto>> sessions() async => sessionList;

  @override
  Future<void> revokeSession(String id) async {
    revoked.add(id);
    sessionList = sessionList.where((s) => s.id != id).toList();
  }

  @override
  Future<TwoStepDto> setTwoStep(bool enabled) async {
    twoStepCalls.add(enabled);
    securityData = SecurityDto(
      factors: securityData.factors,
      twoStepEnabled: enabled,
      hasVerifiedFactor: securityData.hasVerifiedFactor,
      activeSessions: securityData.activeSessions,
      deviceCount: securityData.deviceCount,
    );
    return TwoStepDto(enabled: enabled, hasVerifiedFactor: true);
  }

  @override
  Future<ExportStateDto> exportState() async => exportData;

  @override
  Future<ExportStateDto> requestExport() async {
    exportRequests += 1;
    exportData = ExportStateDto(
      status: ExportStateDtoStatus.queued,
      id: 'x-1',
      requestedAt: _now,
      expiresAt: null,
      downloadUrl: null,
      nextAllowedAt: _now.add(const Duration(days: 1)),
    );
    return exportData;
  }

  @override
  Future<void> deleteAccount({
    required String confirm,
    String? password,
  }) async {
    deleteCalls.add((confirm: confirm, password: password));
    if (deleteFailure case final f?) throw f;
  }

  @override
  Future<void> restore() async {
    restoreCalls += 1;
  }

  @override
  Future<MembershipViewDto> membership() async => membershipData;
}

class FakeHelpRepository implements HelpRepository {
  final List<HelpArticleCardDto> articles = [
    const HelpArticleCardDto(
      id: 'h-1',
      slug: 'safety-centre',
      title: 'Safety centre',
      summary: 'How to report, block and mute.',
    ),
    const HelpArticleCardDto(
      id: 'h-2',
      slug: 'verify-your-account',
      title: 'Verify your account',
      summary: 'Why and how to confirm your email or phone.',
    ),
  ];
  final List<FaqDto> faq = [
    const FaqDto(
      id: 'f-1',
      question: 'Is Atarah free?',
      answer: 'Yes. Pro adds mentorship booking and lower fees.',
    ),
  ];
  final List<String> searches = [];

  @override
  Future<HelpResultDto> search([String? q]) async {
    searches.add(q ?? '');
    final query = (q ?? '').toLowerCase();
    return HelpResultDto(
      articles: articles
          .where((a) => query.isEmpty || a.title.toLowerCase().contains(query))
          .toList(),
      faq: faq
          .where(
            (f) => query.isEmpty || f.question.toLowerCase().contains(query),
          )
          .toList(),
    );
  }

  @override
  Future<HelpArticleDto> article(String slug) async => HelpArticleDto(
    id: 'h-1',
    slug: slug,
    title: 'Safety centre',
    summary: 'How to report, block and mute.',
    blocks: const [
      HelpBlockDto(
        type: HelpBlockDtoType.paragraph,
        text: 'Use the menu on any post to report it.',
        title: null,
        attribution: null,
      ),
    ],
  );

  @override
  Future<HelpContactDto> contact() async => const HelpContactDto(
    email: 'support@atarah.app',
    note: 'We reply within a day.',
  );

  @override
  Future<List<LegalSummaryDto>> legalList() async => [
    const LegalSummaryDto(
      type: LegalDocumentType.terms,
      title: 'Terms of Service',
      version: '1',
      effectiveAt: null,
      isDraft: true,
      draftLabel: 'DRAFT — pending legal review',
    ),
    const LegalSummaryDto(
      type: LegalDocumentType.privacy,
      title: 'Privacy Policy',
      version: '1',
      effectiveAt: null,
      isDraft: false,
      draftLabel: null,
    ),
  ];

  @override
  Future<LegalFullDto> legalDocument(String type) async => const LegalFullDto(
    type: LegalDocumentType.terms,
    title: 'Terms of Service',
    version: '1',
    effectiveAt: null,
    isDraft: true,
    draftLabel: 'DRAFT — pending legal review',
    body: 'First paragraph of the terms.\n\nSecond paragraph.',
  );
}

class FakeTwoStepVerifier implements TwoStepVerifier {
  FakeTwoStepVerifier({this.rightCode = '123456', this.noFactor = false});

  final String rightCode;
  final bool noFactor;
  int starts = 0;
  final List<String> codes = [];

  @override
  Future<TwoStepChallenge> start() async {
    starts += 1;
    if (noFactor) throw const NoSecondFactorException();
    return const TwoStepChallenge(
      factorId: 'f-1',
      challengeId: 'c-1',
      phone: true,
    );
  }

  @override
  Future<void> complete(TwoStepChallenge challenge, String code) async {
    codes.add(code);
    if (code != rightCode) throw Exception('wrong code');
  }
}
