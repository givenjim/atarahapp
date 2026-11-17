import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'support/journey_support.dart';

/// P1-M12 journey (d) on a real emulator against the real local backend (dev demo seed): post, reply, report,
/// moderation outcome. NOT RUN: no emulator was available when this was written. Fake-backed twin that does
/// run: `test/journeys/community_journey_test.dart`.
///
/// Moderators decide in the admin console, which needs a second factor, so a script cannot take the decision.
/// The journey therefore has two parts. Part 1 posts, replies and reports. After a moderator resolves the
/// report in the admin console, run it again with `--dart-define=ATARAH_REPORTER_EMAIL=<the reporter's email>`
/// and `--dart-define=ATARAH_MODERATION_RESOLVED=true` to check the outcome notification (part 2).
const _resolved = bool.fromEnvironment('ATARAH_MODERATION_RESOLVED');
const _reporter = String.fromEnvironment('ATARAH_REPORTER_EMAIL');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late final JourneyEnv env;
  setUpAll(() async => env = await JourneyEnv.start());

  final stamp = DateTime.now().millisecondsSinceEpoch;
  final email = 'community.$stamp@demo.atarah.test';
  const spam = 'How do you price a licence for illustration';

  testWidgets('post, reply, report', (t) async {
    await registerAndSetUp(
      t,
      env,
      email: email,
      name: 'Community Tester',
      handle: 'comm_$stamp',
    );

    // Post.
    await goTo(t, '/compose');
    await t.enterText(find.byType(TextField).first, 'Journey post $stamp');
    await tapLabel(t, 'Post', wait: 4);
    await goTo(t, '/community');
    expect(find.text('Journey post $stamp'), findsWidgets);

    // Open a demo member's discussion, reply, then report it.
    await reveal(t, find.textContaining(spam));
    await tapLabel(t, spam.substring(0, 20), wait: 4);
    await t.enterText(find.byType(TextField).last, 'Reply $stamp');
    await t.pump();
    await t.tap(find.byIcon(LucideIcons.send));
    await settle(t, seconds: 4);
    expect(find.text('Reply $stamp'), findsOneWidget);

    await t.tap(find.bySemanticsLabel('More options').first);
    await settle(t);
    await tapLabel(t, 'Report');
    await tapLabel(t, 'Scam or spam');
    await tapLabel(t, 'Send report', wait: 4);
    expect(find.text('Thanks for telling us'), findsOneWidget);
  });

  testWidgets('the reporter is told the moderation outcome', (t) async {
    await signIn(t, env, email: _reporter, password: journeyPassword);
    await goTo(t, '/notifications');
    expect(find.text('Update on your report'), findsWidgets);
  }, skip: !_resolved || _reporter.isEmpty);
}
