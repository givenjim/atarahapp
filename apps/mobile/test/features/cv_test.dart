import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/design_system/design_system.dart';
import 'package:atarah/core/networking/failures.dart';
import 'package:atarah/features/cv/cv_providers.dart';
import 'package:atarah/features/cv/cv_repository.dart';
import 'package:atarah/features/cv/cv_screen.dart';
import 'package:atarah/features/profile/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_app.dart';

const _sections = [
  'BIO',
  'LOCATION',
  'PORTFOLIO',
  'SKILLS',
  'EXPERIENCE',
  'LINKS',
];

CvStateDto _state(
  String format, {
  List<String> picked = const ['BIO', 'PORTFOLIO', 'SKILLS'],
  List<String> restricted = const [],
  List<String> projectIds = const ['p-pub'],
  List<CvShareDto> shares = const [],
  bool verified = true,
}) {
  final withheld = [
    for (final s in picked)
      if (s != 'SKILLS' && s != 'PORTFOLIO' && !restricted.contains(s)) s,
  ];
  return CvStateDto(
    info: CvFormatInfoDto(
      format: CvFormatInfoDtoFormat.fromJson(format),
      label: switch (format) {
        'CV' => 'Creative CV',
        'BIO' => 'Artist biography',
        'EPK' => 'Electronic press kit',
        _ => 'Portfolio presentation',
      },
      allowedSections: [
        for (final s in _sections) CvFormatInfoDtoAllowedSections.fromJson(s),
      ],
      defaultSections: const [],
      maxProjects: 8,
    ),
    config: CvConfigDto(
      sections: [for (final s in picked) CvConfigDtoSections.fromJson(s)],
      projectIds: projectIds,
      restricted: [
        for (final s in restricted) CvConfigDtoRestricted.fromJson(s),
      ],
    ),
    sections: [
      for (final s in _sections)
        CvSectionAudienceDto(
          section: CvSectionAudienceDtoSection.fromJson(s),
          visibility: s == 'BIO' || s == 'LOCATION' || s == 'EXPERIENCE'
              ? CvSectionAudienceDtoVisibility.members
              : CvSectionAudienceDtoVisibility.public,
          available: true,
        ),
    ],
    projects: const [
      CvProjectChoiceDto(
        id: 'p-pub',
        title: 'Mvua music video',
        role: 'Lead animator',
        year: 2026,
        visibility: CvProjectChoiceDtoVisibility.public,
      ),
      CvProjectChoiceDto(
        id: 'p-priv',
        title: 'Unreleased client work',
        visibility: CvProjectChoiceDtoVisibility.private,
      ),
    ],
    preview: CvPreviewDto(
      displayName: 'Nia Wairimu',
      subtitle: switch (format) {
        'CV' => 'Creative CV',
        'BIO' => 'Artist biography',
        'EPK' => 'Electronic press kit',
        _ => 'Portfolio presentation',
      },
      identityVerified: false,
      summary: restricted.contains('BIO') ? 'Illustrator in Nairobi.' : null,
      work: [
        for (final id in projectIds)
          if (id == 'p-pub')
            const CvPreviewWorkDto(
              title: 'Mvua music video',
              role: 'Lead animator',
              year: 2026,
            ),
      ],
      skills: [
        CvPreviewSkillDto(name: '2D animation', verified: verified),
        const CvPreviewSkillDto(name: 'Storyboarding', verified: false),
      ],
      included: const [],
      withheld: [for (final s in withheld) CvPreviewDtoWithheld.fromJson(s)],
    ),
    shares: shares,
  );
}

class FakeCvRepository implements CvRepository {
  FakeCvRepository({this.shares = const [], this.pdfStatuses = const []});

  final Map<String, CvStateDto> docs = {};
  List<CvShareDto> shares;
  final List<CvRenderDtoStatus> pdfStatuses;
  final List<UpdateCvDto> updates = [];
  int generated = 0;
  int statusChecks = 0;
  bool failSave = false;
  final List<int?> created = [];
  final List<String> revoked = [];

  @override
  Future<CvStateDto> state(String format) async =>
      docs[format] ?? _state(format, shares: shares);

  @override
  Future<CvStateDto> update(String format, UpdateCvDto body) async {
    if (failSave) {
      throw const ApiFailure(
        code: 'INTERNAL_ERROR',
        message: 'Save failed on server.',
        statusCode: 500,
      );
    }
    updates.add(body);
    final next = _state(
      format,
      picked: [
        for (final s in body.sections ?? <UpdateCvDtoSections>[]) s.json!,
      ],
      restricted: [
        for (final s in body.restricted ?? <UpdateCvDtoRestricted>[]) s.json!,
      ],
      projectIds: body.projectIds ?? const [],
      shares: shares,
    );
    docs[format] = next;
    return next;
  }

  @override
  Future<CvRenderDto> generate(String format) async {
    generated++;
    return CvRenderDto(
      id: 'r-1',
      status: CvRenderDtoStatus.queued,
      requestedAt: DateTime.utc(2026, 11, 20),
    );
  }

  @override
  Future<CvRenderDto> renderStatus(String id) async {
    final status = pdfStatuses[statusChecks.clamp(0, pdfStatuses.length - 1)];
    statusChecks++;
    return CvRenderDto(
      id: id,
      status: status,
      requestedAt: DateTime.utc(2026, 11, 20),
      error: status == CvRenderDtoStatus.failed
          ? 'PDF creation is not available right now. Please try again later.'
          : null,
    );
  }

  @override
  Future<CvDownloadDto> download(String id) async => CvDownloadDto(
    url: 'https://signed.test/cv.pdf',
    expiresAt: DateTime.utc(2026, 11, 20, 1),
  );

  @override
  Future<CvShareCreatedDto> createShare(
    String format, {
    int? expiresInDays,
  }) async {
    created.add(expiresInDays);
    final link = CvShareCreatedDto(
      id: 's-${created.length}',
      hint: 'x9Kq',
      createdAt: DateTime.utc(2026, 11, 20),
      status: CvShareCreatedDtoStatus.active,
      url: 'https://atarah.app/niawairimu/cv/secret-token-value',
      expiresAt: expiresInDays == null
          ? null
          : DateTime.utc(2026, 11, 20).add(Duration(days: expiresInDays)),
    );
    shares = [
      CvShareDto(
        id: link.id,
        hint: link.hint,
        createdAt: link.createdAt,
        status: CvShareDtoStatus.active,
        expiresAt: link.expiresAt,
      ),
      ...shares,
    ];
    docs.remove(format);
    return link;
  }

  @override
  Future<CvShareDto> revokeShare(String id) async {
    revoked.add(id);
    shares = [
      for (final s in shares)
        if (s.id == id)
          CvShareDto(
            id: s.id,
            hint: s.hint,
            createdAt: s.createdAt,
            status: CvShareDtoStatus.revoked,
            expiresAt: s.expiresAt,
            revokedAt: DateTime.utc(2026, 11, 21),
          )
        else
          s,
    ];
    docs.remove('CV');
    return shares.firstWhere((s) => s.id == id);
  }
}

Future<void> _open(
  WidgetTester t,
  FakeCvRepository repo, {
  List<String>? shared,
  List<Uri>? opened,
  bool openOk = true,
}) async {
  await t.pumpAt(
    ProviderScope(
      overrides: [
        cvRepositoryProvider.overrideWithValue(repo),
        cvPollIntervalProvider.overrideWithValue(Duration.zero),
        shareTextProvider.overrideWithValue((text) async => shared?.add(text)),
        openLinkProvider.overrideWithValue((uri) async {
          opened?.add(uri);
          return openOk;
        }),
      ],
      child: const CvScreen(),
    ),
    scaffold: false,
    size: const Size(390, 1800),
  );
  await t.pumpAndSettle();
}

void main() {
  group('Creative CV / EPK screen', () {
    testWidgets(
      'shows the format picker and the preview card for the first format',
      (t) async {
        await _open(t, FakeCvRepository());
        for (final label in ['CV', 'Bio', 'EPK', 'Deck']) {
          expect(
            find.descendant(
              of: find.byType(AtSegmented),
              matching: find.text(label),
            ),
            findsOneWidget,
          );
        }
        expect(find.text('Nia Wairimu'), findsOneWidget);
        expect(find.text('Creative CV'), findsOneWidget);
        expect(find.text('SELECTED WORK'), findsOneWidget);
        expect(
          find.text('Mvua music video · Lead animator · 2026'),
          findsOneWidget,
        );
        expect(find.text('SKILLS'), findsOneWidget);
        expect(find.text('Download PDF'), findsOneWidget);
        expect(find.text('Share link'), findsOneWidget);
      },
    );

    testWidgets(
      'a verified mark appears only on a skill the server says is verified',
      (t) async {
        await _open(t, FakeCvRepository());
        // Only "2D animation" is verified in the data: one check mark in the preview.
        expect(find.byIcon(Icons.check), findsNothing);
        expect(
          find.bySemanticsLabel('2D animation, Verified skill'),
          findsOneWidget,
        );
        expect(find.bySemanticsLabel('Storyboarding'), findsOneWidget);
      },
    );

    testWidgets('switching format loads that format and its subtitle', (
      t,
    ) async {
      await _open(t, FakeCvRepository());
      await t.tap(find.text('EPK'));
      await t.pumpAndSettle();
      expect(find.text('Electronic press kit'), findsWidgets);
      await t.tap(find.text('Deck'));
      await t.pumpAndSettle();
      expect(find.text('Portfolio presentation'), findsWidgets);
    });

    testWidgets(
      'a non-public section is left out and says so until the member allows it',
      (t) async {
        final repo = FakeCvRepository();
        await _open(t, repo);
        expect(
          find.textContaining('Left out of this document'),
          findsOneWidget,
        );
        expect(find.text('Illustrator in Nairobi.'), findsNothing);
        expect(
          find.textContaining('Allow this bio (members only)'),
          findsOneWidget,
        );

        await t.tap(find.textContaining('Allow this bio (members only)'));
        await t.pumpAndSettle();
        expect(repo.updates.single.restricted!.map((e) => e.json), ['BIO']);
        expect(find.text('Illustrator in Nairobi.'), findsOneWidget);
        expect(find.textContaining('Left out of this document'), findsNothing);
      },
    );

    testWidgets('choosing a project saves the list', (t) async {
      final repo = FakeCvRepository();
      await _open(t, repo);
      await t.tap(find.text('Unreleased client work'));
      await t.pumpAndSettle();
      expect(repo.updates.single.projectIds, ['p-pub', 'p-priv']);
      // It is not public, so it needs the explicit allow before it reaches the preview.
      expect(find.textContaining('Visible to: Only me'), findsOneWidget);
      expect(
        find.text('Allow non-public projects in this document'),
        findsOneWidget,
      );
    });

    testWidgets('a failed save shows the reason and keeps the screen usable', (
      t,
    ) async {
      final repo = FakeCvRepository()..failSave = true;
      await _open(t, repo);
      await t.tap(find.text('Unreleased client work'));
      await t.pumpAndSettle();
      expect(find.text('Save failed on server.'), findsOneWidget);
      expect(find.text('Download PDF'), findsOneWidget);
    });

    testWidgets(
      'Download PDF waits for the build, then opens the signed link',
      (t) async {
        final repo = FakeCvRepository(
          pdfStatuses: const [
            CvRenderDtoStatus.processing,
            CvRenderDtoStatus.ready,
          ],
        );
        final opened = <Uri>[];
        await _open(t, repo, opened: opened);
        await t.tap(find.text('Download PDF'));
        await t.pumpAndSettle();
        expect(repo.generated, 1);
        expect(repo.statusChecks, 2);
        expect(opened.single.toString(), 'https://signed.test/cv.pdf');
      },
    );

    testWidgets('a failed build tells the member why and opens nothing', (
      t,
    ) async {
      final repo = FakeCvRepository(
        pdfStatuses: const [CvRenderDtoStatus.failed],
      );
      final opened = <Uri>[];
      await _open(t, repo, opened: opened);
      await t.tap(find.text('Download PDF'));
      await t.pumpAndSettle();
      expect(
        find.text(
          'PDF creation is not available right now. Please try again later.',
        ),
        findsOneWidget,
      );
      expect(opened, isEmpty);
    });

    testWidgets(
      'Share link creates a link, copies it and opens the share sheet',
      (t) async {
        String? copied;
        t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (c) async {
            if (c.method == 'Clipboard.setData') {
              copied = (c.arguments as Map)['text'] as String?;
            }
            return null;
          },
        );
        addTearDown(
          () => t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          ),
        );
        final repo = FakeCvRepository();
        final shared = <String>[];
        await _open(t, repo, shared: shared);
        expect(find.text('No links yet.'), findsOneWidget);

        await t.tap(find.text('Share link'));
        await t.pumpAndSettle();
        expect(
          find.text('When should this link stop working?'),
          findsOneWidget,
        );
        await t.tap(find.text('In 30 days'));
        await t.pumpAndSettle();

        expect(repo.created, [30]);
        expect(copied, 'https://atarah.app/niawairimu/cv/secret-token-value');
        expect(
          shared.single,
          contains('https://atarah.app/niawairimu/cv/secret-token-value'),
        );
        expect(find.textContaining('Link created and copied'), findsOneWidget);
        // The list shows only the hint, never the token.
        expect(find.text('Link ending x9Kq'), findsOneWidget);
        expect(find.textContaining('secret-token-value'), findsNothing);
      },
    );

    testWidgets('a link can be turned off', (t) async {
      final repo = FakeCvRepository(
        shares: [
          CvShareDto(
            id: 's-1',
            hint: 'ab12',
            createdAt: DateTime.utc(2026, 11, 20),
            status: CvShareDtoStatus.active,
          ),
        ],
      );
      await _open(t, repo);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('No expiry'), findsOneWidget);
      await t.tap(find.text('Turn off'));
      await t.pumpAndSettle();
      expect(repo.revoked, ['s-1']);
      expect(find.text('Revoked'), findsOneWidget);
      expect(find.text('Turn off'), findsNothing);
      expect(find.text('Link turned off.'), findsOneWidget);
    });
  });
}
