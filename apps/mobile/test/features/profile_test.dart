import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/design_system/design_system.dart';
import 'package:atarah/core/networking/failures.dart';
import 'package:atarah/features/profile/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/fake_profile.dart';
import '../support/fakes.dart';

Future<Harness> openApp(
  WidgetTester t, {
  FakeProfileRepository? profile,
  MeDto? user,
  String at = '/profile',
}) async {
  final h = Harness(
    auth: FakeAuthRepository(restored: user ?? fakeUser(name: 'Nia Wairimu')),
    profile: profile ?? FakeProfileRepository(),
  );
  await h.pump(t);
  if (at != '/home') {
    h.router.go(at);
    await t.pumpAndSettle();
  }
  return h;
}

Finder inTabBar(String label) =>
    find.descendant(of: find.byType(AtTabBar), matching: find.text(label));

void main() {
  group('my profile', () {
    testWidgets(
      'shows who you are, the completion ring and the Passport card',
      (t) async {
        await openApp(t);
        expect(find.text('Nia Wairimu'), findsOneWidget);
        expect(find.text('Character animator'), findsOneWidget);
        expect(find.text('Nairobi, Kenya'), findsOneWidget);
        expect(find.text('70% complete'), findsOneWidget);
        expect(find.text('ATR · NBI · 0042'), findsOneWidget);
        expect(find.text('Add your first project'), findsOneWidget);
        // No verification exists yet, so no verified tick anywhere.
        expect(find.byType(AtVerifiedTick), findsNothing);
      },
    );

    testWidgets('the next best step starts the first project', (t) async {
      final h = await openApp(t);
      await tapText(t, 'Add your first project');
      expect(h.path, '/portfolio/new/edit');
    });

    testWidgets('a step that cannot be done yet opens its labelled screen', (
      t,
    ) async {
      await openApp(
        t,
        profile: FakeProfileRepository(
          me: ownProfile(
            next: const [
              CompletionItemDto(
                key: 'avatar',
                label: 'Add a profile photo',
                weight: 15,
                done: false,
              ),
            ],
          ),
        ),
      );
      await tapText(t, 'Add a profile photo');
      expect(find.text('Soon · P1'), findsOneWidget);
    });

    testWidgets('a bio or headline step opens the edit sheet', (t) async {
      final repo = FakeProfileRepository(
        me: ownProfile(
          bio: null,
          next: const [
            CompletionItemDto(
              key: 'bio',
              label: 'Write a short bio',
              weight: 10,
              done: false,
            ),
          ],
        ),
      );
      await openApp(t, profile: repo);
      await tapText(t, 'Write a short bio');
      expect(find.text('Edit profile'), findsWidgets);
      expect(find.text('Save changes'), findsOneWidget);
    });

    testWidgets('a complete profile says so instead of inventing a next step', (
      t,
    ) async {
      await openApp(
        t,
        profile: FakeProfileRepository(
          me: ownProfile(percent: 100, next: const []),
        ),
      );
      expect(find.text('Your profile is complete. Nice work.'), findsOneWidget);
    });

    testWidgets('no headline invites you to add one', (t) async {
      await openApp(
        t,
        profile: FakeProfileRepository(me: ownProfile(headline: null)),
      );
      await tapText(t, 'Add a headline');
      expect(find.text('Save changes'), findsOneWidget);
    });

    testWidgets('tools appear only for mentors and sellers', (t) async {
      await openApp(t);
      expect(find.text('Your tools'), findsNothing);
      expect(find.text('Mentor tools'), findsNothing);
    });

    testWidgets(
      'a mentor sees mentor tools, which open the Phase 2 placeholder',
      (t) async {
        await openApp(t, user: fakeUser(roles: const [MeDtoRoles.mentor]));
        expect(find.text('Your tools'), findsOneWidget);
        expect(find.text('Mentor tools'), findsOneWidget);
        expect(find.text('Seller tools'), findsNothing);
        await tapText(t, 'Mentor tools');
        expect(find.text('Soon · P2'), findsOneWidget);
      },
    );

    testWidgets(
      'the identity list shows real counts and every row opens a labelled screen',
      (t) async {
        final repo = FakeProfileRepository(
          me: ownProfile(skills: 3, connections: 2, pending: 1),
        );
        await openApp(t, profile: repo);
        expect(find.text('My creative identity'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('1 waiting'), findsOneWidget);
        // Portfolio, skills, experience, achievements and services are real screens now (see portfolio_test).
        for (final (label, phase) in [
          ('Connections', 'Soon · P1'),
          ('Activity', 'Soon · P1'),
          ('Saved', 'Soon · P1'),
          ('Membership', 'Soon · P2'),
          ('Settings', 'Soon · P1'),
        ]) {
          await tapText(t, label);
          expect(find.text(phase), findsOneWidget, reason: label);
          await tapText(t, 'Go back');
          expect(find.byType(AtTabBar), findsOneWidget, reason: label);
        }
      },
    );

    testWidgets('membership shows the real plan', (t) async {
      await openApp(t);
      expect(find.text('Free plan'), findsOneWidget);
    });

    testWidgets('"Improve my bio" opens the Phase 3 placeholder', (t) async {
      await openApp(t);
      await tapText(t, 'Improve my bio');
      expect(find.text('Soon · P3'), findsOneWidget);
    });

    testWidgets('a profile that cannot load offers a retry', (t) async {
      final repo = FakeProfileRepository(meFailure: const NetworkFailure());
      await openApp(t, profile: repo);
      expect(find.text("We couldn't load your profile"), findsOneWidget);
      expect(
        find.text("You're offline. Check your connection and try again."),
        findsOneWidget,
      );
      await tapText(t, 'Try again');
      expect(find.text('Character animator'), findsOneWidget);
    });

    testWidgets('Passport opens from the card', (t) async {
      final h = await openApp(t);
      await tapText(t, 'Creative Passport'.toUpperCase());
      expect(h.path, '/passport');
    });
  });

  group('edit profile', () {
    Future<FakeProfileRepository> openSheet(
      WidgetTester t, {
      FakeProfileRepository? repo,
    }) async {
      final r = repo ?? FakeProfileRepository();
      await openApp(t, profile: r);
      await tapText(t, 'Edit profile');
      return r;
    }

    testWidgets('starts with what the profile has', (t) async {
      await openSheet(
        t,
        repo: FakeProfileRepository(
          me: ownProfile(
            links: const [
              ProfileLinkDto(
                id: 'l',
                label: 'Site',
                url: 'https://nia.example.com',
              ),
            ],
            openToCommissions: true,
          ),
        ),
      );
      expect(find.text('Nia Wairimu'), findsWidgets);
      expect(find.text('Site'), findsOneWidget);
      expect(find.text('https://nia.example.com'), findsOneWidget);
      expect(find.text('Open to commissions'), findsOneWidget);
    });

    testWidgets('saves changes and shows them on the profile', (t) async {
      final repo = await openSheet(t);
      await t.enterText(find.byType(TextField).at(0), 'Nia W.');
      await t.enterText(find.byType(TextField).at(1), 'Illustrator');
      await t.enterText(
        find.byType(TextField).at(2),
        'New bio that is long enough.',
      );
      await tapText(t, 'Add a link');
      await t.enterText(
        find.widgetWithText(TextField, 'Label').last,
        'Instagram',
      );
      await t.enterText(
        find.widgetWithText(TextField, 'Address (https://)').last,
        'https://instagram.com/nia',
      );
      await tapText(t, 'Save changes');
      final u = repo.updates.single;
      expect(u.displayName, 'Nia W.');
      expect(u.headline, 'Illustrator');
      expect(u.bio, 'New bio that is long enough.');
      expect(u.links!.single.url, 'https://instagram.com/nia');
      expect(find.text('Profile updated.'), findsOneWidget);
      expect(find.text('Nia W.'), findsWidgets);
      expect(find.text('Illustrator'), findsOneWidget);
    });

    testWidgets('contact preferences are sent', (t) async {
      final repo = await openSheet(t);
      await tapText(
        t,
        'Show my phone number when my contact details are visible',
      );
      await tapText(t, 'My connections can see my contact details');
      await tapText(t, 'Accept connection requests');
      await tapText(t, 'Open to commissions');
      await tapText(t, 'Save changes');
      final u = repo.updates.single;
      expect(u.contactShowPhone, isTrue);
      expect(u.contactForConnections, isTrue);
      expect(u.acceptConnections, isFalse);
      expect(u.openToCommissions, isTrue);
    });

    testWidgets('checks the form before sending', (t) async {
      final repo = await openSheet(t);
      await t.enterText(find.byType(TextField).at(0), ' ');
      await tapText(t, 'Add a link');
      await t.enterText(
        find.widgetWithText(TextField, 'Address (https://)').last,
        'http://insecure.example.com',
      );
      await tapText(t, 'Save changes');
      expect(
        find.text('Enter the name you want people to see.'),
        findsOneWidget,
      );
      expect(find.text('Give the link a label.'), findsOneWidget);
      expect(
        find.text('Enter a web address that starts with https://'),
        findsOneWidget,
      );
      expect(repo.updates, isEmpty);
    });

    testWidgets('links can be removed, and the limit hides the add button', (
      t,
    ) async {
      final links = [
        for (var i = 0; i < 8; i++)
          ProfileLinkDto(
            id: '$i',
            label: 'L$i',
            url: 'https://x$i.example.com',
          ),
      ];
      final repo = await openSheet(
        t,
        repo: FakeProfileRepository(me: ownProfile(links: links)),
      );
      expect(find.text('Add a link'), findsNothing);
      expect(find.text('You can add up to 8 links.'), findsOneWidget);
      await t.tap(find.bySemanticsLabel('Remove link').first);
      await t.pumpAndSettle();
      expect(find.text('Add a link'), findsOneWidget);
      await tapText(t, 'Save changes');
      expect(repo.updates.single.links, hasLength(7));
    });

    testWidgets("the server's message appears under the field it is about", (
      t,
    ) async {
      final repo = FakeProfileRepository()
        ..updateFailure = const ApiFailure(
          code: 'VALIDATION_ERROR',
          message: 'Keep your bio to 160 characters.',
          statusCode: 400,
          details: {'field': 'bio'},
        );
      await openSheet(t, repo: repo);
      await tapText(t, 'Save changes');
      expect(find.text('Keep your bio to 160 characters.'), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget); // the sheet stays open
    });

    testWidgets('an offline save keeps the sheet open with a message', (
      t,
    ) async {
      final repo = FakeProfileRepository()
        ..updateFailure = const NetworkFailure();
      await openSheet(t, repo: repo);
      await tapText(t, 'Save changes');
      expect(
        find.text("You're offline. Check your connection and try again."),
        findsOneWidget,
      );
    });
  });

  group('Creative Passport', () {
    Future<(Harness, FakeProfileRepository)> openPassport(
      WidgetTester t,
    ) async {
      final repo = FakeProfileRepository();
      final h = await openApp(t, profile: repo, at: '/passport');
      return (h, repo);
    }

    testWidgets('shows the card, real growth bars and the share link', (
      t,
    ) async {
      await openPassport(t);
      expect(find.text('ATR · NBI · 0042'), findsOneWidget);
      expect(find.text('Nia Wairimu'), findsOneWidget);
      expect(find.text('Animation · 2D animation'), findsOneWidget);
      expect(find.text('Nairobi, Kenya'), findsOneWidget);
      expect(find.text('Member since September 2026'), findsOneWidget);
      expect(find.text('Growth'), findsOneWidget);
      expect(find.text('Early'), findsOneWidget);
      for (final label in [
        'Identity',
        'Portfolio',
        'Skills',
        'Learning',
        'Connections',
        'Professionalisation',
      ]) {
        expect(find.text(label), findsWidgets, reason: label);
      }
      expect(find.text('54%'), findsOneWidget);
      expect(find.text('https://atarah.app/niawairimu'), findsOneWidget);
      // No trust pills until verification exists.
      expect(find.byType(AtVerificationBadge), findsNothing);
    });

    testWidgets('lists every section with its audience', (t) async {
      await openPassport(t);
      expect(find.text('Sections & visibility'), findsOneWidget);
      for (final s in [
        'Bio',
        'Location',
        'Portfolio',
        'Skills',
        'Experience',
        'Services',
        'Links',
        'Contact details',
      ]) {
        expect(find.text(s), findsWidgets, reason: s);
      }
      expect(
        find.text('Only me'),
        findsOneWidget,
      ); // contact is private by default
      expect(
        find.text('Members only'),
        findsNWidgets(2),
      ); // location, experience
    });

    testWidgets('changing a row updates it at once and tells the server', (
      t,
    ) async {
      final (_, repo) = await openPassport(t);
      await tapText(t, 'Bio');
      expect(find.text('Who can see Bio?'), findsOneWidget);
      await tapText(
        t,
        'Only me — Only you (and connections, for contact details, if you allow it).',
      );
      expect(repo.visibility.single, (
        SetSectionVisibilityDtoSection.bio,
        SetSectionVisibilityDtoVisibility.private,
      ));
      expect(find.text('Only me'), findsNWidgets(2));
    });

    testWidgets('a failed change puts the old value back and says so', (
      t,
    ) async {
      final (_, repo) = await openPassport(t);
      repo.visibilityFailure = const NetworkFailure();
      await tapText(t, 'Bio');
      await tapText(t, 'Members only — Signed-in Atarah members.');
      expect(
        find.text("You're offline. Check your connection and try again."),
        findsOneWidget,
      );
      expect(
        find.text('Members only'),
        findsNWidgets(2),
      ); // unchanged: location and experience
    });

    testWidgets(
      'Copy link puts the public link on the clipboard and confirms',
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
        await openPassport(t);
        await tapText(t, 'Copy link');
        expect(copied, 'https://atarah.app/niawairimu');
        expect(find.text('Link copied.'), findsOneWidget);
      },
    );

    testWidgets('CV and EPK open the Phase 2 placeholder', (t) async {
      await openPassport(t);
      await tapText(t, 'Create CV / EPK');
      expect(find.text('Soon · P2'), findsOneWidget);
    });

    testWidgets('Back returns to the profile', (t) async {
      final (h, _) = await openPassport(t);
      await t.tap(find.bySemanticsLabel('Back'));
      await t.pumpAndSettle();
      expect(h.path, '/profile');
    });
  });

  group("another member's profile", () {
    late FakeProfileRepository repo;
    late PublicProfileDto Function(PublicProfilePreview?) make;
    ConnectionStateDto conn = const ConnectionStateDto(
      id: null,
      state: ConnectionStateDtoState.none,
      canConnect: true,
    );

    Future<Harness> openCreative(
      WidgetTester t, {
      PublicProfileDto Function(PublicProfilePreview?)? builder,
    }) async {
      repo = FakeProfileRepository();
      make = builder ?? (_) => publicProfile(connection: conn);
      repo.creatives['amina'] = (p) => make(p);
      return openApp(t, profile: repo, at: '/creatives/amina');
    }

    setUp(() {
      conn = const ConnectionStateDto(
        id: null,
        state: ConnectionStateDtoState.none,
        canConnect: true,
      );
    });

    testWidgets('shows the identity and the About content the server allowed', (
      t,
    ) async {
      await openCreative(
        t,
        builder: (_) => publicProfile(
          contact: const ContactDetailsDto(
            email: 'amina@example.com',
            phone: null,
          ),
        ),
      );
      expect(find.text('Amina Hassan'), findsOneWidget);
      expect(find.text('Photographer'), findsOneWidget);
      expect(find.text('Photography · Documentary'), findsOneWidget);
      expect(find.text('Mombasa, Kenya'), findsOneWidget);
      expect(find.text('Open to commissions'), findsOneWidget);
      expect(find.text('4 connections'), findsOneWidget);
      expect(
        find.text('Documentary photographer on the coast.'),
        findsOneWidget,
      );
      expect(find.text('Colour'), findsOneWidget);
      expect(find.text('Instagram'), findsOneWidget);
      expect(find.text('amina@example.com'), findsOneWidget);
      expect(find.byType(AtVerifiedTick), findsNothing);
    });

    testWidgets('hidden parts are named, not shown', (t) async {
      await openCreative(
        t,
        builder: (_) => publicProfile(
          bio: null,
          location: null,
          skills: null,
          links: null,
          openToCommissions: false,
          connectionCount: null,
          locked: const [
            PublicProfileDtoLockedSections.bio,
            PublicProfileDtoLockedSections.location,
            PublicProfileDtoLockedSections.skills,
            PublicProfileDtoLockedSections.links,
            PublicProfileDtoLockedSections.contact,
          ],
        ),
      );
      expect(find.text('Documentary photographer on the coast.'), findsNothing);
      expect(find.text('Mombasa, Kenya'), findsNothing);
      expect(find.text('Open to commissions'), findsNothing);
      for (final s in [
        'Bio',
        'Location',
        'Skills',
        'Links',
        'Contact details',
      ]) {
        expect(find.text('$s is hidden.'), findsOneWidget, reason: s);
      }
      expect(find.textContaining('connections'), findsNothing);
    });

    testWidgets(
      'portfolio and services say nothing yet, or that they are hidden',
      (t) async {
        await openCreative(
          t,
          builder: (_) => publicProfile(
            locked: const [PublicProfileDtoLockedSections.services],
          ),
        );
        await tapText(t, 'Portfolio');
        expect(find.text('No projects yet.'), findsOneWidget);
        await tapText(t, 'Services');
        expect(find.text('Services is hidden.'), findsOneWidget);
      },
    );

    testWidgets('Connect sends a request and the button becomes Request sent', (
      t,
    ) async {
      final h = await openCreative(t);
      make = (_) => publicProfile(connection: conn);
      repo.connectionResult = const ConnectionStateDto(
        id: 'c-9',
        state: ConnectionStateDtoState.pendingSent,
        canConnect: false,
      );
      // After the request the server reports it pending.
      repo.creatives['amina'] = (_) => publicProfile(
        connection: repo.calls.contains('connect:amina')
            ? repo.connectionResult
            : conn,
      );
      await tapText(t, 'Connect');
      expect(repo.calls, contains('connect:amina'));
      expect(find.text('Request sent'), findsOneWidget);
      expect(find.text('Cancel request'), findsOneWidget);
      expect(h.events, contains('connection_action'));
      await tapText(t, 'Cancel request');
      expect(repo.calls, contains('remove:c-9'));
    });

    testWidgets('a request you received can be accepted or declined', (
      t,
    ) async {
      await openCreative(
        t,
        builder: (_) => publicProfile(
          connection: const ConnectionStateDto(
            id: 'c-3',
            state: ConnectionStateDtoState.pendingReceived,
            canConnect: false,
          ),
        ),
      );
      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);
      await tapText(t, 'Decline');
      expect(repo.calls, contains('decline:c-3'));
      await tapText(t, 'Accept');
      expect(repo.calls, contains('accept:c-3'));
    });

    testWidgets('a connection can be removed after confirming', (t) async {
      await openCreative(
        t,
        builder: (_) => publicProfile(
          relation: PublicProfileDtoRelation.connection,
          connection: const ConnectionStateDto(
            id: 'c-5',
            state: ConnectionStateDtoState.connected,
            canConnect: false,
          ),
        ),
      );
      expect(find.text('Connected'), findsOneWidget);
      await tapText(t, 'Remove connection');
      expect(find.text('Remove this connection?'), findsOneWidget);
      expect(repo.calls.where((c) => c.startsWith('remove')), isEmpty);
      await tapText(t, 'Remove connection', last: true);
      expect(repo.calls, contains('remove:c-5'));
    });

    testWidgets('declining the confirmation keeps the connection', (t) async {
      await openCreative(
        t,
        builder: (_) => publicProfile(
          connection: const ConnectionStateDto(
            id: 'c-5',
            state: ConnectionStateDtoState.connected,
            canConnect: false,
          ),
        ),
      );
      await tapText(t, 'Remove connection');
      await tapText(t, 'Cancel');
      expect(repo.calls.where((c) => c.startsWith('remove')), isEmpty);
    });

    testWidgets(
      'Connect is off, with the reason, when the member is not accepting or you must wait',
      (t) async {
        await openCreative(
          t,
          builder: (_) => publicProfile(
            connection: const ConnectionStateDto(
              id: null,
              state: ConnectionStateDtoState.none,
              canConnect: false,
              reason: 'NOT_ACCEPTING',
            ),
          ),
        );
        expect(find.text('Not accepting requests'), findsOneWidget);
        await tapText(t, 'Connect');
        expect(repo.calls.where((c) => c.startsWith('connect')), isEmpty);
      },
    );

    testWidgets(
      'after a decline the requester is told when they can ask again',
      (t) async {
        await openCreative(
          t,
          builder: (_) => publicProfile(
            connection: const ConnectionStateDto(
              id: 'c-1',
              state: ConnectionStateDtoState.none,
              canConnect: false,
              reason: 'COOLDOWN',
            ),
          ),
        );
        expect(find.text('You can ask again later'), findsOneWidget);
      },
    );

    testWidgets('a failed request shows the server message and stays usable', (
      t,
    ) async {
      await openCreative(t);
      repo.connectFailure = const ApiFailure(
        code: 'CONFLICT',
        message:
            'You can send another request after 30 days from the last answer.',
        statusCode: 409,
      );
      await tapText(t, 'Connect');
      expect(
        find.text(
          'You can send another request after 30 days from the last answer.',
        ),
        findsOneWidget,
      );
      expect(find.text('Connect'), findsWidgets);
    });

    testWidgets(
      'Message opens the labelled screen: messaging is not in scope',
      (t) async {
        await openCreative(t);
        await tapText(t, 'Message');
        expect(find.text('Soon · Later'), findsOneWidget);
      },
    );

    testWidgets('Share hands the public link to the share sheet', (t) async {
      final h = await openCreative(t);
      await t.tap(find.bySemanticsLabel('Share profile'));
      await t.pumpAndSettle();
      expect(
        h.shared.single,
        'Amina Hassan on Atarah\nhttps://atarah.app/amina',
      );
    });

    testWidgets(
      'a link asks before leaving Atarah, then opens in the browser',
      (t) async {
        final h = await openCreative(t);
        await tapText(t, 'Instagram');
        expect(find.text("You're leaving Atarah"), findsOneWidget);
        expect(h.opened, isEmpty);
        await tapText(t, 'Continue to website');
        expect(h.opened.single.toString(), 'https://instagram.com/amina');
      },
    );

    testWidgets('staying on Atarah opens nothing', (t) async {
      final h = await openCreative(t);
      await tapText(t, 'Instagram');
      await tapText(t, 'Stay on Atarah');
      expect(h.opened, isEmpty);
    });

    testWidgets('a profile that does not exist says so', (t) async {
      final h = Harness(
        auth: FakeAuthRepository(restored: fakeUser()),
        profile: FakeProfileRepository(),
      );
      await h.pump(t);
      h.router.go('/creatives/nobody');
      await t.pumpAndSettle();
      expect(find.text("We couldn't find that creative"), findsOneWidget);
    });
  });

  group('your own profile as others see it', () {
    testWidgets(
      'Public view opens the preview, which can switch between public and members',
      (t) async {
        final repo = FakeProfileRepository();
        repo.creatives['niawairimu'] = (p) => publicProfile(
          handle: 'niawairimu',
          name: 'Nia Wairimu',
          relation: p == PublicProfilePreview.members
              ? PublicProfileDtoRelation.member
              : PublicProfileDtoRelation.anonymous,
          location: p == PublicProfilePreview.members
              ? const LocationDto(
                  countryName: 'Kenya',
                  countyName: 'Nairobi',
                  town: null,
                )
              : null,
          locked: p == PublicProfilePreview.members
              ? const []
              : const [PublicProfileDtoLockedSections.location],
          connection: null,
        );
        await openApp(t, profile: repo);
        await tapText(t, 'Public view');
        expect(
          find.text('This is how your profile looks to others.'),
          findsOneWidget,
        );
        expect(repo.calls, contains('creative:niawairimu:public'));
        expect(find.text('Location is hidden.'), findsOneWidget);
        // No Connect button on your own profile.
        expect(find.text('Connect'), findsNothing);
        await tapText(t, 'Members');
        expect(repo.calls, contains('creative:niawairimu:members'));
        expect(find.text('Nairobi, Kenya'), findsOneWidget);
        expect(find.text('Location is hidden.'), findsNothing);
      },
    );
  });

  group('large text', () {
    for (final (name, path) in [
      ('profile', '/profile'),
      ('passport', '/passport'),
      ('creative profile', '/creatives/amina'),
    ]) {
      testWidgets('$name lays out at 200% text without overflow', (t) async {
        t.platformDispatcher.textScaleFactorTestValue = 2.0;
        addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
        final repo = FakeProfileRepository();
        repo.creatives['amina'] = (_) => publicProfile();
        await openApp(t, profile: repo, at: path);
        expect(t.takeException(), isNull);
      });
    }
  });
}
