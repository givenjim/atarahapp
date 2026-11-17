import 'dart:async';

import 'package:atarah/core/api/generated/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../support/app_harness.dart';
import '../support/fake_account.dart';
import '../support/fake_community.dart';
import '../support/fakes.dart';

/// P1-M12 journey (d), fake-backed: write a post, reply to someone's discussion, report it, then the reporter is
/// told the outcome. A moderator's decision is made in the admin console on the server, so here the fake
/// notifications list receives the same copy the backend sends (`REPORT_OUTCOME_COPY`); the real decision flow
/// is covered by the backend tests. Real-backend twin: `integration_test/journey_community_test.dart` (written,
/// not run: no emulator).
void main() {
  testWidgets('post, reply, report, moderation outcome', (t) async {
    final community = FakeCommunityRepository(
      posts: [postDto(id: 'p-other', body: 'Selling followers, DM me.')],
      comments: {'p-other': const []},
    );
    final notifications = FakeNotificationsRepository(items: []);
    final h = Harness(
      auth: FakeAuthRepository(restored: fakeUser(name: 'Nia Wairimu')),
      community: community,
      notifications: notifications,
    );
    await h.pump(t);
    h.router.go('/community');
    await t.pumpAndSettle();

    // Post.
    unawaited(h.router.push('/compose'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).first, 'Working on a mural');
    await t.pump();
    await tapText(t, 'Post');
    expect(community.created.single.body, 'Working on a mural');
    expect(find.text('Posted.'), findsOneWidget);

    // Reply to someone else's discussion (once the "Posted." notice has gone).
    await t.pump(const Duration(seconds: 6));
    h.router.go('/posts/p-other');
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).last, 'Be careful with this one.');
    await t.pump();
    await t.tap(find.byIcon(LucideIcons.send));
    await t.pumpAndSettle();
    expect(community.replies.single.body, 'Be careful with this one.');
    expect(find.text('Be careful with this one.'), findsOneWidget);

    // Report it.
    await t.tap(find.bySemanticsLabel('More options').first);
    await t.pumpAndSettle();
    await t.tap(find.text('Report'));
    await t.pumpAndSettle();
    await t.tap(find.text('Scam or spam'));
    await t.pump();
    await t.ensureVisible(find.text('Send report'));
    await t.tap(find.text('Send report'));
    await t.pumpAndSettle();
    expect(community.reports.single.id, 'p-other');
    expect(community.reports.single.reason, ReportReason.scam);
    expect(find.text('Thanks for telling us'), findsOneWidget);

    // The moderator decides on the server; the reporter gets a notification, with no detail about who or why.
    notifications.items = [
      notif(
        id: 'n-report',
        title: 'Update on your report',
        body: 'We reviewed your report and took action. Thank you for helping keep Atarah safe.',
        deepLink: null,
      ),
    ];
    h.router.go('/notifications');
    await t.pumpAndSettle();
    expect(find.text('Update on your report'), findsOneWidget);
    expect(find.textContaining('took action'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
