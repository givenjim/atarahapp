import 'dart:async';

import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/networking/failures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../support/fake_people.dart';
import '../support/fake_profile.dart';

class _GatedProfile extends FakeProfileRepository {
  final gate = Completer<void>();

  @override
  Future<ConnectionStateDto> connect(String handle) async {
    await gate.future;
    return super.connect(handle);
  }
}

Future<void> tapChip(WidgetTester t, String label) async {
  await t.ensureVisible(find.text(label).first);
  await t.pumpAndSettle();
  await t.tap(find.text(label).first);
}

void main() {
  group('People to meet', () {
    testWidgets('lists people with their reason line', (t) async {
      final h = PeopleHarness(
        people: FakePeopleRepository(
          people: [
            personToMeet(reason: 'Also works in Animation'),
            personToMeet(
              handle: 'otieno',
              name: 'Otieno Ouma',
              reason: 'Based in Nairobi',
              pending: true,
            ),
          ],
        ),
      );
      await h.pump(t);
      expect(find.text('Wanjiku Njeri'), findsOneWidget);
      expect(find.text('Also works in Animation'), findsOneWidget);
      expect(find.text('Based in Nairobi'), findsOneWidget);
      expect(find.text('Connect'), findsOneWidget);
      expect(find.text('Requested'), findsOneWidget);
    });

    testWidgets('filters are sent to the API', (t) async {
      final h = PeopleHarness(
        people: FakePeopleRepository(people: [personToMeet()]),
      );
      await h.pump(t);
      await tapChip(t, 'Verified');
      await t.pumpAndSettle();
      await tapChip(t, 'Open to work');
      await t.pumpAndSettle();
      await tapChip(t, 'Discipline');
      await t.pumpAndSettle();
      await t.tap(find.text('Animation').last);
      await t.pumpAndSettle();
      await tapChip(t, 'County');
      await t.pumpAndSettle();
      await t.tap(find.text('Nairobi').last);
      await t.pumpAndSettle();
      final f = h.people.filterCalls.last;
      expect(f.verified, isTrue);
      expect(f.available, isTrue);
      expect(f.disciplineId, isNotNull);
      expect(f.countyId, isNotNull);
    });

    testWidgets('loads the next page by offset when scrolling', (t) async {
      final h = PeopleHarness(
        people: FakePeopleRepository(
          people: [
            for (var i = 0; i < 25; i++)
              personToMeet(handle: 'p$i', name: 'Person $i'),
          ],
        ),
      );
      await h.pump(t);
      expect(h.people.pageCalls, [1]);
      await t.drag(find.byType(ListView).first, const Offset(0, -6000));
      await t.pumpAndSettle();
      expect(h.people.pageCalls, [1, 2]);
    });

    testWidgets('empty with filters offers to clear them', (t) async {
      final h = PeopleHarness(people: FakePeopleRepository());
      await h.pump(t);
      expect(find.text('No one to suggest yet'), findsOneWidget);
      await tapChip(t, 'Verified');
      await t.pumpAndSettle();
      expect(find.text('No one matches those filters'), findsOneWidget);
      await t.tap(find.text('Clear filters'));
      await t.pumpAndSettle();
      expect(find.text('No one to suggest yet'), findsOneWidget);
    });

    testWidgets('a failed load shows the error and retries', (t) async {
      final repo = FakePeopleRepository(people: [personToMeet()])
        ..suggestionsFailure = const NetworkFailure();
      final h = PeopleHarness(people: repo);
      await h.pump(t);
      expect(
        find.text("You're offline. Check your connection and try again."),
        findsOneWidget,
      );
      repo.suggestionsFailure = null;
      await t.tap(find.text('Try again'));
      await t.pumpAndSettle();
      expect(find.text('Wanjiku Njeri'), findsOneWidget);
    });

    testWidgets('Connect is optimistic and keeps Requested on success', (
      t,
    ) async {
      final profile = _GatedProfile();
      final h = PeopleHarness(
        people: FakePeopleRepository(people: [personToMeet()]),
        profile: profile,
      );
      await h.pump(t);
      await t.tap(find.text('Connect'));
      await t.pump();
      // Before the server has answered.
      expect(find.text('Requested'), findsOneWidget);
      profile.gate.complete();
      await t.pumpAndSettle();
      expect(find.text('Requested'), findsOneWidget);
      expect(profile.calls, ['connect:wanjiku']);
      expect(
        h.analytics.events.map((e) => e.event),
        contains('connection_action'),
      );
    });

    for (final (failure, message) in [
      (
        const ApiFailure(
          code: 'VERIFICATION_REQUIRED',
          message: 'raw',
          statusCode: 403,
        ),
        'Verify your email or phone first and you can connect with people. It only takes a minute.',
      ),
      (
        const ApiFailure(
          code: 'FORBIDDEN',
          message: 'raw',
          statusCode: 403,
          details: {'reason': 'ACCOUNT_RESTRICTED'},
        ),
        'Your account is restricted for now, so you cannot do this. We will let you know if that changes.',
      ),
      (
        const ApiFailure(code: 'RATE_LIMITED', message: 'raw', statusCode: 429),
        'You have done a lot in a short time. Take a breather and try again a little later.',
      ),
    ]) {
      testWidgets('Connect rolls back and says ${failure.code}', (t) async {
        final profile = FakeProfileRepository()..connectFailure = failure;
        final h = PeopleHarness(
          people: FakePeopleRepository(people: [personToMeet()]),
          profile: profile,
        );
        await h.pump(t);
        await t.tap(find.text('Connect'));
        await t.pumpAndSettle();
        expect(find.text('Connect'), findsOneWidget);
        expect(find.text('Requested'), findsNothing);
        expect(find.text(message), findsOneWidget);
      });
    }

    testWidgets('Save opens the Soon screen, it does not pretend to save', (
      t,
    ) async {
      final h = PeopleHarness(
        people: FakePeopleRepository(people: [personToMeet()]),
      );
      await h.pump(t);
      await t.tap(find.bySemanticsLabel('Save Wanjiku Njeri'));
      await t.pumpAndSettle();
      expect(h.path, startsWith('/soon/later'));
    });
  });

  group('Connections and requests', () {
    testWidgets('the Requests row shows how many are waiting', (t) async {
      final h = PeopleHarness(
        people: FakePeopleRepository(
          received: [
            connectionItem(state: ConnectionListItemDtoState.pendingReceived),
            connectionItem(
              id: 'c-2',
              handle: 'x',
              name: 'Xena',
              state: ConnectionListItemDtoState.pendingReceived,
            ),
          ],
        ),
      );
      await h.pump(t);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('accepted connections are listed', (t) async {
      final h = PeopleHarness(
        people: FakePeopleRepository(connected: [connectionItem()]),
        start: '/connections',
      );
      await h.pump(t);
      expect(find.text('Otieno Ouma'), findsOneWidget);
      await t.tap(find.text('Otieno Ouma'));
      await t.pumpAndSettle();
      expect(h.path, '/creatives/otieno');
    });

    testWidgets('accept removes the request and calls the API', (t) async {
      final h = PeopleHarness(
        people: FakePeopleRepository(
          received: [
            connectionItem(state: ConnectionListItemDtoState.pendingReceived),
          ],
        ),
        start: '/connections?list=received',
      );
      await h.pump(t);
      await t.tap(find.text('Accept'));
      await t.pumpAndSettle();
      expect(h.profile.calls, ['accept:c-1']);
      expect(find.text('Otieno Ouma'), findsNothing);
      expect(find.text('No requests waiting'), findsOneWidget);
    });

    testWidgets('decline removes the request', (t) async {
      final h = PeopleHarness(
        people: FakePeopleRepository(
          received: [
            connectionItem(state: ConnectionListItemDtoState.pendingReceived),
          ],
        ),
        start: '/connections?list=received',
      );
      await h.pump(t);
      await t.tap(find.text('Decline'));
      await t.pumpAndSettle();
      expect(h.profile.calls, ['decline:c-1']);
      expect(find.text('Otieno Ouma'), findsNothing);
    });

    testWidgets('a failed accept puts the request back with a kind message', (
      t,
    ) async {
      final profile = FakeProfileRepository()
        ..connectFailure = const ApiFailure(
          code: 'RATE_LIMITED',
          message: 'raw',
          statusCode: 429,
        );
      final h = PeopleHarness(
        people: FakePeopleRepository(
          received: [
            connectionItem(state: ConnectionListItemDtoState.pendingReceived),
          ],
        ),
        profile: profile,
        start: '/connections?list=received',
      );
      await h.pump(t);
      await t.tap(find.text('Accept'));
      await t.pumpAndSettle();
      expect(find.text('Otieno Ouma'), findsOneWidget);
      expect(find.textContaining('Take a breather'), findsOneWidget);
    });

    testWidgets('a sent request can be withdrawn', (t) async {
      final h = PeopleHarness(
        people: FakePeopleRepository(
          sent: [connectionItem(state: ConnectionListItemDtoState.pendingSent)],
        ),
        start: '/connections?list=sent',
      );
      await h.pump(t);
      await t.tap(find.text('Cancel request'));
      await t.pumpAndSettle();
      expect(h.profile.calls, ['remove:c-1']);
      expect(find.text('Otieno Ouma'), findsNothing);
    });
  });

  group('Blocked people', () {
    testWidgets('reachable from the overflow and unblocks', (t) async {
      final h = PeopleHarness(
        people: FakePeopleRepository(blocked: [blockedMember()]),
      );
      await h.pump(t);
      await t.tap(find.byIcon(LucideIcons.ellipsis));
      await t.pumpAndSettle();
      await t.tap(find.text('Blocked people'));
      await t.pumpAndSettle();
      expect(h.path, '/blocked');
      expect(find.text('Kamau Mwangi'), findsOneWidget);
      await t.tap(find.text('Unblock'));
      await t.pumpAndSettle();
      expect(h.people.unblocked, ['u-1']);
      expect(find.text('Kamau Mwangi'), findsNothing);
      expect(find.text('You have not blocked anyone'), findsOneWidget);
    });

    testWidgets('a failed unblock restores the row', (t) async {
      final repo = FakePeopleRepository(blocked: [blockedMember()])
        ..unblockFailure = const NetworkFailure();
      final h = PeopleHarness(people: repo, start: '/blocked');
      await h.pump(t);
      await t.tap(find.text('Unblock'));
      await t.pumpAndSettle();
      expect(find.text('Kamau Mwangi'), findsOneWidget);
      expect(find.textContaining('offline'), findsOneWidget);
    });
  });
}
