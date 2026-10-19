import 'dart:async';

import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/design_system/design_system.dart';
import 'package:atarah/core/networking/failures.dart';
import 'package:atarah/features/portfolio/media_seams.dart';
import 'package:atarah/features/portfolio/portfolio_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../support/app_harness.dart';
import '../support/fake_portfolio.dart';
import '../support/fake_profile.dart';
import '../support/fakes.dart';

Future<Harness> openApp(
  WidgetTester t, {
  FakePortfolioRepository? portfolio,
  FakeProfileRepository? profile,
  FakeMediaPicker? media,
  String at = '/portfolio',
}) async {
  final h = Harness(
    auth: FakeAuthRepository(restored: fakeUser(name: 'Nia Wairimu')),
    profile: profile ?? FakeProfileRepository(),
    portfolio: portfolio ?? FakePortfolioRepository(),
    media: media,
  );
  await h.pump(t);
  // Tall, so a long list builds every row and the test can see all of it.
  t.view.physicalSize = const Size(390, 3000);
  h.router.go(at);
  await t.pumpAndSettle();
  return h;
}

const _animation = TaxonomyItemDto(
  id: 'k-1',
  slug: 'animation',
  name: 'Animation',
);
const _colour = TaxonomyItemDto(id: 'k-2', slug: 'colour', name: 'Colour');

FakePortfolioRepository withCatalogue() =>
    FakePortfolioRepository()
      ..skillCatalogue.addAll(const [_animation, _colour]);

/// The text field of the [AtTextField] with this label.
Finder fieldWithLabel(String label) => find.descendant(
  of: find.byWidgetPredicate((w) => w is AtTextField && w.label == label),
  matching: find.byType(TextField),
);

void main() {
  group('my portfolio', () {
    testWidgets('an empty portfolio says so and invites the first project', (
      t,
    ) async {
      await openApp(t);
      expect(
        find.text(
          'Show your best work. Add a project to start your portfolio.',
        ),
        findsOneWidget,
      );
      expect(find.text('Add project'), findsWidgets);
    });

    testWidgets(
      'shows the featured project as the hero, published projects in a grid and drafts apart',
      (t) async {
        final repo = FakePortfolioRepository()
          ..projects.addAll([
            projectDto(id: 'a', title: 'Hero piece', featured: true),
            projectDto(id: 'b', title: 'Second piece', category: 'PUBLICATION'),
            projectDto(id: 'c', title: 'Half done', status: 'DRAFT'),
          ]);
        await openApp(t, portfolio: repo);
        expect(find.text('Hero piece'), findsOneWidget);
        expect(find.text('Second piece'), findsOneWidget);
        expect(find.text('Drafts'), findsOneWidget);
        expect(find.text('Half done'), findsOneWidget);
        // The draft carries its own tag so nobody mistakes it for something live.
        expect(find.text('Draft'), findsWidgets);
      },
    );

    testWidgets('filter chips narrow the grid by category and featured', (
      t,
    ) async {
      final repo = FakePortfolioRepository()
        ..projects.addAll([
          projectDto(id: 'a', title: 'Short film', category: 'MEDIA'),
          projectDto(id: 'b', title: 'Zine', category: 'PUBLICATION'),
        ]);
      await openApp(t, portfolio: repo);
      await tapText(t, 'Publications');
      expect(find.text('Zine'), findsOneWidget);
      expect(find.text('Short film'), findsNothing);
      await tapText(t, 'Featured');
      expect(find.text('Nothing here yet.'), findsOneWidget);
    });

    testWidgets('opens a published project and a draft in the editor', (
      t,
    ) async {
      final repo = FakePortfolioRepository()
        ..projects.addAll([
          projectDto(id: 'a', title: 'Short film'),
          projectDto(id: 'd', title: 'Half done', status: 'DRAFT'),
        ]);
      final h = await openApp(t, portfolio: repo);
      await tapText(t, 'Short film');
      expect(h.path, '/projects/a');
      h.router.pop();
      await t.pumpAndSettle();
      await tapText(t, 'Half done');
      expect(h.path, '/portfolio/d/edit');
    });

    testWidgets('a failed load can be retried', (t) async {
      final repo = FakePortfolioRepository()
        ..listFailure = const NetworkFailure();
      await openApp(t, portfolio: repo);
      expect(
        find.text("You're offline. Check your connection and try again."),
        findsOneWidget,
      );
      repo.projects.add(projectDto(id: 'a', title: 'Back online'));
      await tapText(t, 'Try again');
      expect(find.text('Back online'), findsOneWidget);
    });

    testWidgets('invitations to be tagged can be accepted or declined', (
      t,
    ) async {
      final repo = FakePortfolioRepository()
        ..collaborations.addAll([
          const CollaborationDto(
            id: 'c1',
            status: CollaborationDtoStatus.pending,
            role: 'Sound design',
            projectId: 'p9',
            projectTitle: 'Kibera Days',
            ownerName: 'Amina Hassan',
          ),
          const CollaborationDto(
            id: 'c2',
            status: CollaborationDtoStatus.pending,
            projectId: 'p10',
            projectTitle: 'Night Market',
            ownerName: 'Baraka Mwangi',
          ),
        ]);
      await openApp(t, portfolio: repo);
      expect(
        find.text('Amina Hassan tagged you on “Kibera Days”'),
        findsOneWidget,
      );
      expect(find.text('As Sound design'), findsOneWidget);
      await t.tap(find.text('Accept').first);
      await t.pumpAndSettle();
      expect(repo.calls, contains('accept:c1'));
      // An accepted invitation is no longer a question.
      expect(
        find.text('Amina Hassan tagged you on “Kibera Days”'),
        findsNothing,
      );
      await t.tap(find.text('Decline'));
      await t.pumpAndSettle();
      expect(repo.calls, contains('leave:c2'));
    });

    testWidgets('lays out at 200% text without overflow', (t) async {
      final repo = FakePortfolioRepository()
        ..projects.addAll([
          projectDto(
            id: 'a',
            title: 'A long project title that wraps',
            featured: true,
          ),
          projectDto(id: 'b', title: 'Another quite long project title'),
          projectDto(
            id: 'c',
            title: 'Draft with a long title',
            status: 'DRAFT',
          ),
        ]);
      t.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
      await openApp(t, portfolio: repo);
      expect(t.takeException(), isNull);
    });
  });

  group('a project', () {
    testWidgets(
      'shows its media first, then the story, skills, collaborators, outcome and links',
      (t) async {
        final repo = FakePortfolioRepository()
          ..projects.add(
            projectDto(
              id: 'a',
              title: 'Mama Mboga',
              client: 'Kaka Studios',
              media: [imageMedia('m1'), videoMedia('m2'), audioMedia('m3')],
              skills: const [_animation],
              collaborators: const [
                CollaboratorDto(
                  id: 'cb',
                  name: 'Wanjiru Kamau',
                  role: 'Sound design',
                  status: CollaboratorDtoStatus.accepted,
                  handle: 'wanjiru',
                ),
                CollaboratorDto(
                  id: 'cb2',
                  name: 'Baraka Mwangi',
                  status: CollaboratorDtoStatus.accepted,
                ),
              ],
              links: const [
                ProjectLinkDto(
                  id: 'l1',
                  label: 'Film',
                  url: 'https://youtu.be/dQw4w9WgXcQ',
                  embedUrl:
                      'https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ',
                ),
                ProjectLinkDto(
                  id: 'l2',
                  label: 'Press',
                  url: 'https://example.com/press',
                ),
              ],
            ),
          );
        final h = await openApp(t, portfolio: repo, at: '/projects/a');
        expect(find.text('Mama Mboga'), findsOneWidget);
        expect(
          find.textContaining('Lead animator · Kaka Studios'),
          findsOneWidget,
        );
        expect(find.text('A short film about the market.'), findsOneWidget);
        expect(find.text('Animation'), findsOneWidget);
        expect(find.text('Shown at three festivals.'), findsOneWidget);
        // Video and audio play through the player seam; YouTube through the embed seam.
        expect(find.text('PLAYER https://signed.test/m2.mp4'), findsOneWidget);
        expect(find.text('PLAYER https://signed.test/m3.mp3'), findsOneWidget);
        expect(
          find.text(
            'PLAYER https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ',
          ),
          findsOneWidget,
        );
        // Only the link that cannot be embedded is listed.
        expect(find.text('Press'), findsOneWidget);
        expect(find.text('Film'), findsNothing);

        // A member collaborator opens their profile; a name typed in has nowhere to go.
        await tapText(t, 'Wanjiru Kamau');
        expect(h.path, '/creatives/wanjiru');
      },
    );

    testWidgets('an outside link goes through the leaving-Atarah modal', (
      t,
    ) async {
      final repo = FakePortfolioRepository()
        ..projects.add(
          projectDto(
            id: 'a',
            links: const [
              ProjectLinkDto(
                id: 'l2',
                label: 'Press',
                url: 'https://example.com/press',
              ),
            ],
          ),
        );
      final h = await openApp(t, portfolio: repo, at: '/projects/a');
      await tapText(t, 'Press');
      expect(find.byType(AtLeavingAtarahModal), findsOneWidget);
      await tapText(t, 'Continue to website');
      expect(h.opened.single.toString(), 'https://example.com/press');
    });

    testWidgets(
      'the owner sees why a moderator hid it and that a draft is private',
      (t) async {
        final repo = FakePortfolioRepository()
          ..projects.addAll([
            projectDto(
              id: 'h',
              title: 'Hidden one',
              hidden: true,
              hiddenReason: 'Uses someone else’s artwork.',
            ),
            projectDto(id: 'd', title: 'Draft one', status: 'DRAFT'),
          ]);
        await openApp(t, portfolio: repo, at: '/projects/h');
        expect(
          find.text(
            'A moderator hid this project: Uses someone else’s artwork.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('a draft says only the owner can see it', (t) async {
      final repo = FakePortfolioRepository()
        ..projects.add(projectDto(id: 'd', status: 'DRAFT'));
      await openApp(t, portfolio: repo, at: '/projects/d');
      expect(
        find.text('This is a draft. Only you can see it.'),
        findsOneWidget,
      );
    });

    testWidgets('sharing hands the title and profile link to the share sheet', (
      t,
    ) async {
      final repo = FakePortfolioRepository()
        ..projects.add(projectDto(id: 'a', title: 'Mama Mboga'));
      final h = await openApp(t, portfolio: repo, at: '/projects/a');
      await t.tap(find.bySemanticsLabel('Share project'));
      await t.pumpAndSettle();
      expect(h.shared.single, contains('Mama Mboga on Atarah'));
      expect(h.shared.single, contains('https://atarah.app/niawairimu'));
    });

    testWidgets(
      'someone else’s project opens by handle, without owner controls',
      (t) async {
        final repo = FakePortfolioRepository()
          ..creativeProjectsByHandle['amina'] = [
            projectDto(id: 'z', title: 'Coast Light'),
          ];
        await openApp(t, portfolio: repo, at: '/projects/z?handle=amina');
        expect(find.text('Coast Light'), findsOneWidget);
        expect(find.bySemanticsLabel('Edit project'), findsNothing);
        expect(find.bySemanticsLabel('Share project'), findsNothing);
      },
    );

    testWidgets('a project the viewer cannot see reads as not available', (
      t,
    ) async {
      await openApp(t, at: '/projects/nope?handle=amina');
      expect(find.text('This project is not available'), findsOneWidget);
    });

    testWidgets('lays out at 200% text without overflow', (t) async {
      final repo = FakePortfolioRepository()
        ..projects.add(
          projectDto(
            id: 'a',
            title: 'A project with a very long title that wraps',
            media: [imageMedia('m1')],
            skills: const [_animation, _colour],
          ),
        );
      t.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
      await openApp(t, portfolio: repo, at: '/projects/a');
      expect(t.takeException(), isNull);
    });
  });

  group('adding a project', () {
    testWidgets('nothing is created until the member starts typing', (t) async {
      final repo = withCatalogue();
      await openApp(t, portfolio: repo, at: '/portfolio/new/edit');
      expect(find.text('Add a project'), findsOneWidget);
      expect(repo.calls, isEmpty);
      expect(repo.projects, isEmpty);
    });

    testWidgets('autosaves a draft as the member types', (t) async {
      final repo = withCatalogue();
      await openApp(t, portfolio: repo, at: '/portfolio/new/edit');
      await t.enterText(fieldWithLabel('Title'), 'Mama Mboga');
      await t.pump(const Duration(milliseconds: 100));
      expect(find.text('Saving…'), findsOneWidget);
      await t.pump(const Duration(seconds: 1));
      await t.pumpAndSettle();
      expect(repo.calls.where((c) => c == 'create'), hasLength(1));
      expect(repo.projects.single.title, 'Mama Mboga');
      expect(repo.projects.single.status, ProjectDtoStatus.draft);
      expect(find.text('Draft saved'), findsOneWidget);

      // Typing more updates the same draft instead of making another.
      await t.enterText(fieldWithLabel('Your role'), 'Director');
      await t.pump(const Duration(seconds: 1));
      await t.pumpAndSettle();
      expect(repo.projects, hasLength(1));
      expect(repo.projects.single.role, 'Director');
    });

    testWidgets('picked files upload with progress, then join the draft', (
      t,
    ) async {
      final repo = withCatalogue();
      final picker = FakeMediaPicker()
        ..queue.add(const [
          PickedMedia(
            path: '/tmp/a.jpg',
            name: 'a.jpg',
            mimeType: 'image/jpeg',
            sizeBytes: 1200,
          ),
          PickedMedia(
            path: '/tmp/b.mp4',
            name: 'b.mp4',
            mimeType: 'video/mp4',
            sizeBytes: 9000,
          ),
        ]);
      await openApp(
        t,
        portfolio: repo,
        media: picker,
        at: '/portfolio/new/edit',
      );
      await tapText(t, 'Add files');
      await tapText(t, 'Photos');
      expect(picker.asked, [MediaPickKind.photos]);
      await t.pump(const Duration(seconds: 1));
      await t.pumpAndSettle();
      expect(repo.uploaded.map((f) => f.name), ['a.jpg', 'b.mp4']);
      expect(repo.projects.single.media, hasLength(2));
    });

    testWidgets('a failed upload can be retried and does not block the draft', (
      t,
    ) async {
      final repo = withCatalogue()..uploadFailure = const NetworkFailure();
      final picker = FakeMediaPicker()
        ..queue.add(const [
          PickedMedia(
            path: '/tmp/a.jpg',
            name: 'a.jpg',
            mimeType: 'image/jpeg',
            sizeBytes: 1200,
          ),
        ]);
      await openApp(
        t,
        portfolio: repo,
        media: picker,
        at: '/portfolio/new/edit',
      );
      await tapText(t, 'Add files');
      await tapText(t, 'Photos');
      expect(
        find.text("You're offline. Check your connection and try again."),
        findsOneWidget,
      );
      repo.uploadFailure = null;
      await t.tap(find.bySemanticsLabel('Upload failed. Tap to retry.'));
      await t.pump(const Duration(seconds: 1));
      await t.pumpAndSettle();
      expect(repo.uploaded, hasLength(1));
    });

    testWidgets('publishing needs a title; with one it publishes and leaves', (
      t,
    ) async {
      final repo = withCatalogue();
      final h = await openApp(t, portfolio: repo, at: '/portfolio');
      unawaited(h.router.push('/portfolio/new/edit'));
      await t.pumpAndSettle();
      await tapText(t, 'Publish');
      expect(find.text('Give your project a title.'), findsOneWidget);
      expect(repo.calls, isNot(contains('publish')));

      await t.enterText(fieldWithLabel('Title'), 'Mama Mboga');
      await t.enterText(
        fieldWithLabel('Description'),
        'A short film about the market, shot over two weeks.',
      );
      await tapText(t, 'Publish');
      expect(repo.calls, contains('publish'));
      expect(repo.projects.single.status, ProjectDtoStatus.published);
      expect(h.path, '/portfolio');
      expect(find.text('Mama Mboga'), findsOneWidget);
    });

    testWidgets('a server refusal on publish is shown, not swallowed', (
      t,
    ) async {
      final repo = withCatalogue()
        ..publishFailure = const ApiFailure(
          code: 'VALIDATION_ERROR',
          message: 'Add at least one file, or describe the project, before you publish it.',
          statusCode: 400,
        );
      await openApp(t, portfolio: repo, at: '/portfolio/new/edit');
      await t.enterText(fieldWithLabel('Title'), 'Mama Mboga');
      await tapText(t, 'Publish');
      expect(
        find.text(
          'Add at least one file, or describe the project, before you publish it.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Save draft saves and leaves; the draft is in the list', (
      t,
    ) async {
      final repo = withCatalogue();
      final h = await openApp(t, portfolio: repo, at: '/portfolio');
      unawaited(h.router.push('/portfolio/new/edit'));
      await t.pumpAndSettle();
      await t.enterText(fieldWithLabel('Title'), 'Work in progress');
      await tapText(t, 'Save draft');
      expect(h.path, '/portfolio');
      expect(find.text('Drafts'), findsOneWidget);
      expect(find.text('Work in progress'), findsOneWidget);
    });

    testWidgets('a save that fails says so and keeps the form', (t) async {
      final repo = withCatalogue()..saveFailure = const NetworkFailure();
      await openApp(t, portfolio: repo, at: '/portfolio/new/edit');
      await t.enterText(fieldWithLabel('Title'), 'Mama Mboga');
      await t.pump(const Duration(seconds: 1));
      await t.pumpAndSettle();
      expect(find.textContaining('Could not save yet'), findsOneWidget);
      expect(
        t.widget<TextField>(fieldWithLabel('Title')).controller!.text,
        'Mama Mboga',
      );
    });

    testWidgets('skills are chosen from the list and can be removed', (
      t,
    ) async {
      final repo = withCatalogue();
      await openApp(t, portfolio: repo, at: '/portfolio/new/edit');
      await t.enterText(fieldWithLabel('Title'), 'Mama Mboga');
      await t.pump(const Duration(seconds: 1));
      await t.pumpAndSettle();
      await tapText(t, 'Add a skill');
      await t.enterText(fieldWithLabel('Search skills'), 'colo');
      await t.pump();
      expect(find.text('Animation'), findsNothing);
      await tapText(t, 'Colour');
      await t.pump(const Duration(seconds: 1));
      await t.pumpAndSettle();
      expect(repo.projects.single.skills.map((s) => s.name), ['Colour']);
      await t.tap(find.byIcon(LucideIcons.x));
      await t.pump(const Duration(seconds: 1));
      await t.pumpAndSettle();
      expect(repo.projects.single.skills, isEmpty);
    });

    testWidgets('links need https and are saved when valid', (t) async {
      final repo = withCatalogue();
      await openApp(t, portfolio: repo, at: '/portfolio/new/edit');
      await t.enterText(fieldWithLabel('Title'), 'Mama Mboga');
      await tapText(t, 'Add a link');
      await t.enterText(fieldWithLabel('Label'), 'Film');
      await t.enterText(
        fieldWithLabel('Address'),
        'http://insecure.example.com',
      );
      await tapText(t, 'Publish');
      expect(
        find.text('Enter an address starting with https://'),
        findsOneWidget,
      );
      expect(repo.calls, isNot(contains('publish')));
      await t.enterText(
        fieldWithLabel('Address'),
        'https://youtu.be/dQw4w9WgXcQ',
      );
      await t.pump(const Duration(seconds: 1));
      await t.pumpAndSettle();
      expect(
        repo.projects.single.links.single.url,
        'https://youtu.be/dQw4w9WgXcQ',
      );
      // Removing a link row must not leave a controller in use after disposal.
      await t.tap(find.byIcon(LucideIcons.trash2));
      await t.pump(const Duration(seconds: 1));
      await t.pumpAndSettle();
      expect(repo.projects.single.links, isEmpty);
      expect(t.takeException(), isNull);
    });

    testWidgets('a collaborator who is not on Atarah is added by name', (
      t,
    ) async {
      final repo = withCatalogue();
      await openApp(t, portfolio: repo, at: '/portfolio/new/edit');
      await t.enterText(fieldWithLabel('Title'), 'Mama Mboga');
      await tapText(t, 'Add a collaborator');
      await tapText(t, 'Someone else');
      await t.enterText(fieldWithLabel('Their name'), 'Baraka Mwangi');
      await t.enterText(fieldWithLabel('Their role (optional)'), 'Voice');
      await tapText(t, 'Add');
      expect(find.text('Baraka Mwangi'), findsOneWidget);
      expect(find.text('Voice'), findsOneWidget);
    });

    testWidgets('a member is found by name and waits to accept', (t) async {
      final repo = withCatalogue()
        ..members.add(
          const MemberHitDto(
            userId: 'u-9',
            displayName: 'Wanjiru Kamau',
            handle: 'wanjiru',
            discipline: 'Music',
          ),
        );
      await openApp(t, portfolio: repo, at: '/portfolio/new/edit');
      await t.enterText(fieldWithLabel('Title'), 'Mama Mboga');
      await tapText(t, 'Add a collaborator');
      await t.enterText(fieldWithLabel('Search by name or @handle'), 'wanj');
      await t.pump(const Duration(milliseconds: 500));
      await t.pumpAndSettle();
      await tapText(t, 'Wanjiru Kamau');
      expect(find.text('Waiting to accept'), findsOneWidget);
    });

    testWidgets('the writing helper opens its labelled screen', (t) async {
      await openApp(t, at: '/portfolio/new/edit');
      await tapText(t, 'Help me describe this');
      expect(find.text('Soon · P3'), findsOneWidget);
    });

    testWidgets('deleting asks first and removes the project', (t) async {
      final repo = withCatalogue()
        ..projects.add(projectDto(id: 'a', title: 'Old work', status: 'DRAFT'));
      final h = await openApp(t, portfolio: repo, at: '/portfolio');
      await tapText(t, 'Old work');
      await tapText(t, 'Delete project');
      expect(find.text('Delete this project?'), findsOneWidget);
      await t.tap(find.text('Delete project').last);
      await t.pumpAndSettle();
      expect(repo.projects, isEmpty);
      expect(h.path, '/portfolio');
    });

    testWidgets('lays out at 200% text without overflow', (t) async {
      final repo = withCatalogue()
        ..projects.add(
          projectDto(
            id: 'a',
            title: 'Long titled draft for the editor',
            status: 'DRAFT',
            media: [imageMedia('m1')],
            skills: const [_animation, _colour],
          ),
        );
      t.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
      await openApp(t, portfolio: repo, at: '/portfolio/a/edit');
      expect(t.takeException(), isNull);
    });
  });

  group('skills', () {
    FakePortfolioRepository seeded() => withCatalogue()
      ..skills.add(
        skillEntry('k-1', 'Animation', level: 'ADVANCED', projects: 2),
      );

    testWidgets('shows each skill with its level, usage and ways to grow it', (
      t,
    ) async {
      await openApp(t, portfolio: seeded(), at: '/skills');
      expect(find.text('Animation'), findsOneWidget);
      expect(find.text('Advanced · Used in 2 projects'), findsOneWidget);
      expect(find.text('Self-declared'), findsOneWidget);
      await tapText(t, 'Improve this skill');
      expect(find.text('Soon · P1'), findsOneWidget);
    });

    testWidgets('Verify opens its Phase 2 screen', (t) async {
      await openApp(t, portfolio: seeded(), at: '/skills');
      await tapText(t, 'Verify');
      expect(find.text('Soon · P2'), findsOneWidget);
    });

    testWidgets('adds a skill from the list at a chosen level', (t) async {
      final repo = seeded();
      await openApp(t, portfolio: repo, at: '/skills');
      await t.tap(find.bySemanticsLabel('Add a skill'));
      await t.pumpAndSettle();
      // A skill the member already has is not offered twice.
      expect(find.text('Animation'), findsNWidgets(1));
      await tapText(t, 'Colour');
      await tapText(t, 'Expert');
      await tapText(t, 'Save');
      expect(repo.calls, contains('setSkill:k-2:EXPERT'));
      expect(find.text('Colour'), findsOneWidget);
    });

    testWidgets('changes a level and removes a skill after confirming', (
      t,
    ) async {
      final repo = seeded();
      await openApp(t, portfolio: repo, at: '/skills');
      await tapText(t, 'Change level');
      await tapText(t, 'Beginner');
      await tapText(t, 'Save');
      expect(repo.calls, contains('setSkill:k-1:BEGINNER'));

      await tapText(t, 'Change level');
      await tapText(t, 'Remove skill');
      expect(find.text('Remove Animation?'), findsOneWidget);
      await t.tap(find.text('Remove skill').last);
      await t.pumpAndSettle();
      expect(repo.skills, isEmpty);
      expect(find.text('No skills yet'), findsOneWidget);
    });
  });

  group('experience', () {
    testWidgets('an empty list invites the first entry', (t) async {
      await openApp(t, at: '/experience');
      expect(find.text('No experience yet'), findsOneWidget);
    });

    testWidgets('asks for an end date unless the member still works there', (
      t,
    ) async {
      await openApp(t, at: '/experience');
      await tapText(t, 'Add experience', last: true);
      await t.enterText(fieldWithLabel('Role'), 'Animator');
      await t.enterText(fieldWithLabel('Where'), 'Kaka Studios');
      await tapText(t, 'Save');
      expect(find.text('Choose when you started.'), findsOneWidget);
      expect(
        find.text('Choose when you left, or switch on “I work here now”.'),
        findsOneWidget,
      );
      // Switching on "I work here now" removes the end date question.
      await tapText(t, 'I work here now');
      expect(find.text('Ended'), findsNothing);
    });

    testWidgets('lists saved experience newest first with its range', (
      t,
    ) async {
      final repo = FakePortfolioRepository()
        ..experience.addAll(const [
          ExperienceDto(
            id: 'x1',
            title: 'Senior animator',
            organisation: 'Kaka Studios',
            startDate: '2024-02-01',
            current: true,
          ),
          ExperienceDto(
            id: 'x2',
            title: 'Animator',
            organisation: 'Studio Two',
            startDate: '2022-01-01',
            endDate: '2024-01-01',
            current: false,
          ),
        ]);
      await openApp(t, portfolio: repo, at: '/experience');
      expect(find.text('Kaka Studios · Feb 2024 – Present'), findsOneWidget);
      expect(find.text('Studio Two · Jan 2022 – Jan 2024'), findsOneWidget);
    });

    testWidgets('deletes after confirming', (t) async {
      final repo = FakePortfolioRepository()
        ..experience.add(
          const ExperienceDto(
            id: 'x1',
            title: 'Animator',
            organisation: 'Studio',
            startDate: '2022-01-01',
            current: true,
          ),
        );
      await openApp(t, portfolio: repo, at: '/experience');
      await tapText(t, 'Animator');
      await tapText(t, 'Delete experience');
      await t.tap(find.text('Delete experience').last);
      await t.pumpAndSettle();
      expect(repo.experience, isEmpty);
    });
  });

  group('achievements', () {
    testWidgets('validates the title and the link before saving', (t) async {
      final repo = FakePortfolioRepository();
      await openApp(t, portfolio: repo, at: '/achievements');
      await tapText(t, 'Add achievement', last: true);
      await tapText(t, 'Save');
      expect(find.text('Enter a title.'), findsOneWidget);
      await t.enterText(fieldWithLabel('Title'), 'Best Short');
      await t.enterText(fieldWithLabel('Link (optional)'), 'http://x.co');
      await tapText(t, 'Save');
      expect(find.text('Links must start with https://'), findsOneWidget);
      await t.enterText(
        fieldWithLabel('Link (optional)'),
        'https://example.com/win',
      );
      await tapText(t, 'Save');
      expect(repo.achievements.single.title, 'Best Short');
    });

    testWidgets('achievements added by Atarah cannot be edited', (t) async {
      final repo = FakePortfolioRepository()
        ..achievements.addAll(const [
          AchievementDto(
            id: 'a1',
            type: AchievementDtoType.certificate,
            title: 'Skill Labs: Colour',
            source: AchievementDtoSource.system,
          ),
          AchievementDto(
            id: 'a2',
            type: AchievementDtoType.award,
            title: 'Best Short',
            source: AchievementDtoSource.manual,
          ),
        ]);
      await openApp(t, portfolio: repo, at: '/achievements');
      expect(find.text('Added by Atarah'), findsOneWidget);
      await tapText(t, 'Skill Labs: Colour');
      expect(find.text('Edit achievement'), findsNothing);
      await tapText(t, 'Best Short');
      expect(find.text('Edit achievement'), findsOneWidget);
    });
  });

  group('services', () {
    testWidgets('adds a fixed-price service and shows the price in shillings', (
      t,
    ) async {
      final repo = FakePortfolioRepository();
      await openApp(t, portfolio: repo, at: '/services');
      await tapText(t, 'Add a service', last: true);
      await t.enterText(fieldWithLabel('Service'), 'Logo animation');
      await tapText(t, 'Fixed');
      await t.enterText(fieldWithLabel('Price').last, '15000');
      await tapText(t, 'Save');
      expect(repo.services.single.priceMin, 15000);
      expect(find.text('KES 15,000'), findsOneWidget);
      expect(find.text('Profile only'), findsOneWidget);
    });

    testWidgets(
      'a range needs a highest price at least as high as the lowest',
      (t) async {
        await openApp(t, at: '/services');
        await tapText(t, 'Add a service', last: true);
        await t.enterText(fieldWithLabel('Service'), 'Storyboards');
        await tapText(t, 'Range');
        await t.enterText(fieldWithLabel('From'), '9000');
        await t.enterText(fieldWithLabel('To'), '5000');
        await tapText(t, 'Save');
        expect(
          find.text('The highest price must be at least the lowest.'),
          findsOneWidget,
        );
      },
    );

    testWidgets('marketplace actions open their Phase 2 screen', (t) async {
      final repo = FakePortfolioRepository()
        ..services.add(
          const ServiceDto(
            id: 's1',
            title: 'Storyboards',
            priceType: ServiceDtoPriceType.onRequest,
            status: ServiceDtoStatus.profileOnly,
          ),
        );
      await openApp(t, portfolio: repo, at: '/services');
      expect(find.text('Price on request'), findsOneWidget);
      await tapText(t, 'Publish to marketplace');
      expect(find.text('Soon · P2'), findsOneWidget);
    });
  });

  group('from the profile', () {
    testWidgets('each identity row opens its own screen', (t) async {
      final h = await openApp(t, at: '/profile');
      for (final (row, path) in [
        ('Portfolio', '/portfolio'),
        ('Skills', '/skills'),
        ('Experience', '/experience'),
        ('Achievements', '/achievements'),
        ('Services', '/services'),
      ]) {
        await tapText(t, row);
        expect(h.path, path, reason: row);
        h.router.pop();
        await t.pumpAndSettle();
      }
    });

    testWidgets(
      'the next best step "Add your first project" starts a project',
      (t) async {
        final h = await openApp(t, at: '/profile');
        await tapText(t, 'Add your first project');
        expect(h.path, '/portfolio/new/edit');
      },
    );
  });
}
