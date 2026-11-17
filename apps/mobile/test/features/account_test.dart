import 'package:atarah/core/api/generated/export.dart' hide Visibility;
import 'package:atarah/core/api/generated/export.dart' as api show Visibility;
import 'package:atarah/core/auth/two_step.dart';
import 'package:atarah/core/design_system/design_system.dart';
import 'package:atarah/core/networking/failures.dart';
import 'package:atarah/core/routing/notification_route.dart';
import 'package:atarah/features/discover/unread_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/fake_account.dart';
import '../support/fake_opportunities.dart';
import '../support/fakes.dart';

Future<Harness> openApp(
  WidgetTester t, {
  String at = '/home',
  MeDto? user,
  FakeActivityRepository? activity,
  FakeNotificationsRepository? notifications,
  FakeSavedRepository? saved,
  FakeAccountRepository? account,
  FakeHelpRepository? help,
  FakeTwoStepVerifier? twoStep,
}) async {
  final h = Harness(
    auth: FakeAuthRepository(restored: user ?? fakeUser(name: 'Nia Wairimu')),
    opportunities: FakeOpportunitiesRepository(opportunities: [oppDto()]),
    activity: activity,
    notifications: notifications,
    saved: saved,
    account: account,
    help: help,
    twoStep: twoStep,
  );
  await h.pump(t);
  h.router.go(at);
  await t.pumpAndSettle();
  return h;
}

void main() {
  group('notification routes', () {
    test('only in-app paths to screens the app has are opened', () {
      expect(
        resolveNotificationRoute('/opportunities/o-1'),
        '/opportunities/o-1',
      );
      expect(
        resolveNotificationRoute('/learning/courses/c-1'),
        '/learning/courses/c-1',
      );
      expect(
        resolveNotificationRoute('/creatives/nia?x=1'),
        '/creatives/nia?x=1',
      );
      expect(resolveNotificationRoute(null), isNull);
      expect(resolveNotificationRoute(''), isNull);
      // Anything that could take the member somewhere else, or to a screen that does not exist, is ignored.
      expect(resolveNotificationRoute('https://evil.example.com/x'), isNull);
      expect(resolveNotificationRoute('//evil.example.com'), isNull);
      expect(resolveNotificationRoute('javascript:alert(1)'), isNull);
      expect(resolveNotificationRoute('/admin/users'), isNull);
      expect(resolveNotificationRoute('/opportunities/o 1'), isNull);
      expect(resolveNotificationRoute(r'/opportunities\x'), isNull);
    });
  });

  group('notifications', () {
    final list = [
      notif(
        id: 'n-1',
        title: 'New connection request',
        body: 'Nia wants to connect.',
        deepLink: '/opportunities/o-1',
      ),
      notif(
        id: 'n-2',
        title: 'One week left',
        body: 'Emerging Creatives Grant closes in 7 days.',
        category: NotificationCategory.opportunities,
        read: true,
        group: NotificationItemDtoGroup.earlier,
        ago: const Duration(days: 2),
        deepLink: '/nowhere/at/all',
      ),
    ];

    testWidgets('groups into Today and Earlier and tints the unread one', (
      t,
    ) async {
      await openApp(
        t,
        at: '/notifications',
        notifications: FakeNotificationsRepository(items: list),
      );
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Earlier'), findsOneWidget);
      expect(find.text('New connection request'), findsOneWidget);
      expect(find.text('One week left'), findsOneWidget);
      // The unread row says so to a screen reader, the read one does not.
      expect(
        find.bySemanticsLabel(RegExp('^Unread\\b.*New connection request')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp('^Unread\\b.*One week left')),
        findsNothing,
      );
    });

    testWidgets('opening one marks it read and goes to what it is about', (
      t,
    ) async {
      final repo = FakeNotificationsRepository(items: list);
      final h = await openApp(t, at: '/notifications', notifications: repo);
      await tapText(t, 'New connection request');
      expect(repo.markedRead, ['n-1']);
      expect(h.path, '/opportunities/o-1');
    });

    testWidgets('a notification whose target the app cannot open just stays', (
      t,
    ) async {
      final repo = FakeNotificationsRepository(items: list);
      final h = await openApp(t, at: '/notifications', notifications: repo);
      await tapText(t, 'One week left');
      expect(h.path, '/notifications');
    });

    testWidgets('a category chip narrows the list', (t) async {
      final repo = FakeNotificationsRepository(items: list);
      await openApp(t, at: '/notifications', notifications: repo);
      await tapText(t, 'Opportunities');
      expect(repo.listCalls.last, NotificationCategory.opportunities);
      expect(find.text('One week left'), findsOneWidget);
      expect(find.text('New connection request'), findsNothing);
      await tapText(t, 'Learning');
      expect(find.text('No Learning notifications'), findsOneWidget);
    });

    testWidgets('Mark all read clears the dots and the bell count', (t) async {
      final repo = FakeNotificationsRepository(items: list);
      final h = await openApp(t, at: '/notifications', notifications: repo);
      expect(find.text('Mark all read'), findsOneWidget);
      await tapText(t, 'Mark all read');
      expect(repo.readAllCalls, [null]);
      expect(find.text('Mark all read'), findsNothing);
      expect(h.container.read(unreadNotificationsProvider), 0);
    });

    testWidgets('empty and failed states', (t) async {
      await openApp(
        t,
        at: '/notifications',
        notifications: FakeNotificationsRepository(items: []),
      );
      expect(find.byType(AtEmptyState), findsOneWidget);
      expect(find.text("You're all caught up"), findsOneWidget);
    });

    testWidgets('a failed load offers Try again, which loads', (t) async {
      final repo = FakeNotificationsRepository(items: list)
        ..failure = const NetworkFailure();
      await openApp(t, at: '/notifications', notifications: repo);
      expect(find.byType(AtErrorState), findsOneWidget);
      repo.failure = null;
      await tapText(t, 'Try again');
      expect(find.text('New connection request'), findsOneWidget);
    });

    testWidgets('the gear opens notification settings', (t) async {
      final h = await openApp(t, at: '/notifications');
      await t.tap(find.bySemanticsLabel('Notification settings'));
      await t.pumpAndSettle();
      expect(h.path, '/settings/notifications');
    });
  });

  group('saved', () {
    final items = [
      savedItem(),
      savedItem(
        type: SavedKind.learning,
        id: 'c-1',
        title: 'Build a Portfolio That Gets You Hired',
        subtitle: 'Course · Portfolio Building',
        path: '/learning/courses/c-1',
      ),
      savedItem(
        type: SavedKind.article,
        id: 'a-1',
        title: 'Pricing for illustrators',
        subtitle: 'Atarah Editorial',
        path: '/articles/pricing',
      ),
    ];

    testWidgets('lists every saved type and filters by chip', (t) async {
      await openApp(
        t,
        at: '/saved',
        saved: FakeSavedRepository(items: items),
      );
      expect(find.text('Emerging Creatives Grant 2027'), findsOneWidget);
      expect(
        find.text('Build a Portfolio That Gets You Hired'),
        findsOneWidget,
      );
      expect(find.text('Pricing for illustrators'), findsOneWidget);
      await tapText(t, 'Skill Labs');
      expect(find.text('Emerging Creatives Grant 2027'), findsNothing);
      expect(
        find.text('Build a Portfolio That Gets You Hired'),
        findsOneWidget,
      );
    });

    testWidgets('Listings and Mentors lead to their Soon screens', (t) async {
      final h = await openApp(
        t,
        at: '/saved',
        saved: FakeSavedRepository(items: items),
      );
      await t.scrollUntilVisible(
        find.text('Listings'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tapText(t, 'Listings');
      expect(h.path, startsWith('/soon/p2'));
      expect(find.text('Soon · P2'), findsOneWidget);
    });

    testWidgets(
      'unsaving removes the row; a failure puts it back and says why',
      (t) async {
        final repo = FakeSavedRepository(items: items);
        await openApp(t, at: '/saved', saved: repo);
        await t.tap(
          find.bySemanticsLabel('Remove from saved: Pricing for illustrators'),
        );
        await t.pumpAndSettle();
        expect(repo.unsaved, [(SavedKind.article, 'a-1')]);
        expect(find.text('Pricing for illustrators'), findsNothing);

        repo.unsaveFailure = const NetworkFailure();
        await t.tap(
          find.bySemanticsLabel(
            'Remove from saved: Emerging Creatives Grant 2027',
          ),
        );
        await t.pumpAndSettle();
        expect(find.text('Emerging Creatives Grant 2027'), findsOneWidget);
        expect(find.textContaining('could not be removed'), findsOneWidget);
      },
    );

    testWidgets('a row opens what was saved', (t) async {
      final h = await openApp(
        t,
        at: '/saved',
        saved: FakeSavedRepository(items: items),
      );
      await tapText(t, 'Emerging Creatives Grant 2027');
      expect(h.path, '/opportunities/o-1');
    });

    testWidgets('empty state for a type with nothing', (t) async {
      await openApp(
        t,
        at: '/saved',
        saved: FakeSavedRepository(items: [items.first]),
      );
      await t.scrollUntilVisible(
        find.text('Posts'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tapText(t, 'Posts');
      expect(find.byType(AtEmptyState), findsOneWidget);
      expect(find.text('No saved Posts'), findsOneWidget);
    });
  });

  group('activity and applications', () {
    testWidgets('shows where the member left off and live counts', (t) async {
      final h = await openApp(t, at: '/activity');
      expect(find.text('Pick up where you left off'), findsOneWidget);
      expect(find.text('Choosing your three projects'), findsOneWidget);
      expect(find.text('Lake Victoria Stories'), findsOneWidget);
      expect(find.text('3 saved'), findsOneWidget);
      expect(find.text('5 unread'), findsOneWidget);
      expect(find.text('1 waiting'), findsOneWidget);
      // Mentorship and Marketplace are Phase 2.
      await t.scrollUntilVisible(
        find.text('Mentorship'),
        200,
        scrollable: find
            .descendant(
              of: find.byType(RefreshIndicator),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await t.pumpAndSettle();
      await t.ensureVisible(find.text('Mentorship'));
      await t.pumpAndSettle();
      await t.tap(find.text('Mentorship'), warnIfMissed: false);
      await t.pumpAndSettle();
      expect(h.path, startsWith('/soon/p2'));
    });

    testWidgets('a resume card opens its target', (t) async {
      final h = await openApp(t, at: '/activity');
      await tapText(t, 'Emerging Creatives Grant 2027');
      expect(h.path, '/opportunities/o-1');
    });

    testWidgets('nothing to resume reads kindly', (t) async {
      await openApp(
        t,
        at: '/activity',
        activity: FakeActivityRepository(hub: activity(resume: const [])),
      );
      expect(find.textContaining('Nothing to pick up'), findsOneWidget);
    });

    testWidgets('applications show status pills and meta lines', (t) async {
      final h = await openApp(
        t,
        at: '/applications',
        activity: FakeActivityRepository(
          apps: [
            application(),
            application(
              id: 'o-2',
              title: 'Short Film Development Fund',
              status: ApplicationItemDtoStatus.inProgress,
              meta: 'Started 3 days ago',
            ),
          ],
        ),
      );
      expect(find.text('Applied'), findsOneWidget);
      expect(find.text('In progress'), findsOneWidget);
      expect(find.text('Applied 12 Oct 2026'), findsOneWidget);
      await tapText(t, 'Emerging Creatives Grant 2027');
      expect(h.path, '/opportunities/o-1');
    });

    testWidgets('no applications yet', (t) async {
      await openApp(
        t,
        at: '/applications',
        activity: FakeActivityRepository(apps: []),
      );
      expect(find.byType(AtEmptyState), findsOneWidget);
    });
  });

  group('settings', () {
    testWidgets('every row opens its screen', (t) async {
      final h = await openApp(t, at: '/settings');
      for (final (label, path) in [
        ('Account', '/settings/account'),
        ('Privacy & visibility', '/settings/privacy'),
        ('Notifications', '/settings/notifications'),
        ('Membership', '/settings/membership'),
        ('Security', '/settings/security'),
        ('Help', '/settings/help'),
        ('Legal', '/settings/legal'),
      ]) {
        final row = find.widgetWithText(AtListRow, label);
        await t.ensureVisible(row);
        await t.tap(row);
        await t.pumpAndSettle();
        expect(h.path, path, reason: label);
        h.router.pop();
        await t.pumpAndSettle();
        expect(find.text('Appearance'), findsOneWidget, reason: label);
      }
    });

    testWidgets(
      'account: Save changes is off until something changes, and sends only what changed',
      (t) async {
        final repo = FakeAccountRepository();
        await openApp(t, at: '/settings/account', account: repo);
        expect(find.text('Verified'), findsOneWidget);
        final save = find.widgetWithText(AtButton, 'Save changes');
        expect(t.widget<AtButton>(save).onPressed, isNull);
        await typeInto(t, 0, 'Nia W. Wairimu');
        expect(t.widget<AtButton>(save).onPressed, isNotNull);
        await t.tap(save);
        await t.pumpAndSettle();
        expect(repo.lastUpdate, (fullName: 'Nia W. Wairimu', handle: null));
        expect(find.text('Saved'), findsOneWidget);
      },
    );

    testWidgets('account: changing email sends a link to the new address', (
      t,
    ) async {
      await openApp(t, at: '/settings/account');
      await t.tap(find.widgetWithText(AtButton, 'Change').first);
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextField).last, 'new@example.com');
      await t.pump();
      await tapText(t, 'Send link');
      expect(
        find.textContaining('We sent a link to new@example.com'),
        findsOneWidget,
      );
    });

    testWidgets(
      'privacy: a choice applies at once and is sent; a failure goes back and says so',
      (t) async {
        final repo = FakeAccountRepository();
        await openApp(t, at: '/settings/privacy', account: repo);
        // Contact details start private.
        await t.tap(find.text('Public').first);
        await t.pumpAndSettle();
        expect(repo.privacyCalls.single, (
          PrivacyField.contact,
          api.Visibility.public,
        ));

        repo.privacyFailure = const NetworkFailure();
        await t.tap(find.text('Only me').at(1));
        await t.pumpAndSettle();
        expect(find.text('That change was not saved.'), findsOneWidget);
      },
    );

    testWidgets('notification settings: each switch saves as it is flipped', (
      t,
    ) async {
      final repo = FakeNotificationsRepository();
      await openApp(t, at: '/settings/notifications', notifications: repo);
      await t.tap(
        find.bySemanticsLabel('Push notifications for Opportunities'),
      );
      await t.pumpAndSettle();
      final sent = repo.prefUpdates.single.single;
      expect(sent.category, PreferenceDtoCategory.opportunities);
      expect(sent.pushEnabled, isFalse);
      expect(sent.emailEnabled, isTrue);
      expect(find.textContaining('Security notices'), findsOneWidget);
    });

    testWidgets('security: two-step switch and signing out another device', (
      t,
    ) async {
      final repo = FakeAccountRepository();
      await openApp(t, at: '/settings/security', account: repo);
      expect(find.text('This device · Nairobi · now'), findsOneWidget);
      await t.tap(find.byType(AtToggle).first);
      await t.pumpAndSettle();
      expect(repo.twoStepCalls, [true]);
      await tapText(t, 'Sign out');
      expect(repo.revoked, ['sess-2']);
      expect(find.text('Chrome on Windows'), findsNothing);
    });

    testWidgets('help: search, FAQ, safety centre and chat with us', (t) async {
      final h = await openApp(t, at: '/settings/help');
      expect(find.text('Is Atarah free?'), findsOneWidget);
      expect(find.textContaining('Yes. Pro adds'), findsNothing);
      await tapText(t, 'Is Atarah free?');
      expect(find.textContaining('Yes. Pro adds'), findsOneWidget);
      await tapText(t, 'Chat with us');
      expect(h.opened.single.scheme, 'mailto');
      expect(h.opened.single.path, 'support@atarah.app');
      await t.tap(find.text('Safety centre').first);
      await t.pumpAndSettle();
      expect(h.path, '/settings/help/safety-centre');
      expect(
        find.text('Use the menu on any post to report it.'),
        findsOneWidget,
      );
    });

    testWidgets('help search with no match says so', (t) async {
      await openApp(t, at: '/settings/help');
      await t.enterText(find.byType(TextField).first, 'zzzz');
      await t.testTextInput.receiveAction(TextInputAction.search);
      await t.pumpAndSettle();
      expect(find.text('Nothing matches that'), findsOneWidget);
    });

    testWidgets('legal: drafts are labelled and documents render', (t) async {
      await openApp(t, at: '/settings/legal');
      expect(find.text('Draft'), findsOneWidget);
      await tapText(t, 'Terms of Service');
      expect(find.text('DRAFT — pending legal review'), findsOneWidget);
      expect(find.text('First paragraph of the terms.'), findsOneWidget);
    });

    testWidgets(
      'membership: plan, comparison, scholarship and a Soon upgrade',
      (t) async {
        final h = await openApp(t, at: '/settings/membership');
        expect(find.text('CURRENT PLAN'), findsOneWidget);
        expect(find.text('Book paid mentorship sessions'), findsOneWidget);
        expect(find.textContaining('may qualify for free Pro'), findsOneWidget);
        await tapText(t, 'Upgrade to Pro · KES 1,200/month');
        expect(h.path, startsWith('/soon/p2'));
      },
    );
  });

  group('delete and restore', () {
    testWidgets(
      'the button works only when DELETE is typed; then the account is deleted and signed out',
      (t) async {
        final repo = FakeAccountRepository();
        final h = await openApp(t, at: '/settings/delete', account: repo);
        final button = find.widgetWithText(
          AtButton,
          'Delete account permanently',
        );
        expect(t.widget<AtButton>(button).onPressed, isNull);
        await typeInto(t, 0, 'delete');
        expect(t.widget<AtButton>(button).onPressed, isNull);
        await typeInto(t, 0, 'DELETE');
        expect(t.widget<AtButton>(button).onPressed, isNotNull);
        await t.tap(button);
        await t.pumpAndSettle();
        expect(repo.deleteCalls.single.confirm, 'DELETE');
        expect(
          find.text('Your account is scheduled for deletion'),
          findsOneWidget,
        );
        await tapText(t, 'OK');
        expect(h.auth.calls, contains('signOut'));
      },
    );

    testWidgets('a refusal stays on the screen with its message', (t) async {
      final repo = FakeAccountRepository()
        ..deleteFailure = const ApiFailure(
          code: 'FORBIDDEN',
          message: 'Confirm with your password.',
          statusCode: 403,
        );
      final h = await openApp(t, at: '/settings/delete', account: repo);
      await typeInto(t, 0, 'DELETE');
      await tapText(t, 'Delete account permanently');
      expect(find.text('Confirm with your password.'), findsOneWidget);
      expect(h.path, '/settings/delete');
      expect(h.auth.calls, isNot(contains('signOut')));
    });

    testWidgets(
      'an account scheduled for deletion lands on Restore instead of Home',
      (t) async {
        final repo = FakeAccountRepository();
        final h = await openApp(
          t,
          at: '/home',
          account: repo,
          user: fakeUser(
            status: MeDtoStatus.deactivated,
            deletionScheduledFor: DateTime.utc(2026, 11, 20),
          ),
        );
        expect(h.path, '/restore');
        expect(find.text('Restore your account?'), findsOneWidget);
        expect(find.textContaining('Nov 20, 2026'), findsOneWidget);
        await tapText(t, 'Restore account');
        expect(repo.restoreCalls, 1);
      },
    );
  });

  group('two-step sign-in', () {
    testWidgets(
      'a TWO_STEP_REQUIRED answer shows the challenge; a wrong code says so, the right one carries on',
      (t) async {
        final verifier = FakeTwoStepVerifier();
        final h = await openApp(t, twoStep: verifier);
        h.container.read(twoStepRequiredProvider.notifier).require();
        await t.pumpAndSettle();
        expect(h.path, '/two-step');
        expect(verifier.starts, 1);
        expect(find.text('Confirm it is you'), findsOneWidget);

        // The sixth digit checks the code on its own.
        await t.enterText(find.byType(TextField).first, '000000');
        await t.pumpAndSettle();
        expect(find.textContaining("didn't work"), findsOneWidget);
        expect(h.path, '/two-step');

        await t.enterText(find.byType(TextField).first, '123456');
        await t.pumpAndSettle();
        expect(verifier.codes, ['000000', '123456']);
        expect(h.container.read(twoStepRequiredProvider), isFalse);
        expect(h.path, '/home');
      },
    );

    testWidgets('no second factor on the account is explained', (t) async {
      final h = await openApp(t, twoStep: FakeTwoStepVerifier(noFactor: true));
      h.container.read(twoStepRequiredProvider.notifier).require();
      await t.pumpAndSettle();
      expect(find.textContaining("can't find a second step"), findsOneWidget);
    });
  });
}
