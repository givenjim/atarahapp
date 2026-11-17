import 'package:atarah/core/api/generated/export.dart' as api;
import 'package:atarah/core/api/generated/export.dart' hide Visibility;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/fake_account.dart';
import '../support/fake_profile.dart';
import '../support/fakes.dart';

/// The one thing two accounts share in the real system: what the server stores. [contactVisible] stands in for
/// the `CONTACT` privacy setting, written by the owner's settings and read when anyone opens their profile.
class _Server {
  api.Visibility contact = api.Visibility.private;
}

class _OwnerAccount extends FakeAccountRepository {
  _OwnerAccount(this.server);
  final _Server server;

  @override
  Future<PrivacyDto> setPrivacy(PrivacyField field, api.Visibility v) {
    if (field == PrivacyField.contact) server.contact = v;
    return super.setPrivacy(field, v);
  }
}

/// Tears the current app down, as when one person hands the phone to another.
Future<void> _signOffScreen(WidgetTester t) async {
  await t.pumpWidget(const SizedBox());
  await t.pump(const Duration(seconds: 1));
}

/// P1-M12 journey (e), fake-backed: a privacy change made by one account is what another account sees; then the
/// account is deleted. Real-backend twin: `integration_test/journey_settings_test.dart` (written, not run: no
/// emulator). The cross-account part here shares a stand-in for the server's stored setting, so it proves the
/// screens send the change and render what the server returns; the server's rule is covered by backend tests.
void main() {
  testWidgets('privacy change, then another account sees it', (t) async {
    final server = _Server();
    final owner = _OwnerAccount(server);
    final a = Harness(
      auth: FakeAuthRepository(restored: fakeUser(name: 'Nia Wairimu')),
      account: owner,
    );
    await a.pump(t);
    a.router.go('/settings/privacy');
    await t.pumpAndSettle();
    await t.tap(find.text('Public').first);
    await t.pumpAndSettle();
    expect(owner.privacyCalls.single, (
      PrivacyField.contact,
      api.Visibility.public,
    ));
    expect(server.contact, api.Visibility.public);

    await _signOffScreen(t);

    // Another account opens Nia's profile and sees the contact details.
    PublicProfileDto niaAsSeenBy() => publicProfile(
      handle: 'nia_w',
      name: 'Nia Wairimu',
      contact: server.contact == api.Visibility.public
          ? const ContactDetailsDto(email: 'nia@example.com', phone: null)
          : null,
    );
    final profile = FakeProfileRepository()
      ..creatives['nia_w'] = (_) => niaAsSeenBy();
    final b = Harness(
      auth: FakeAuthRepository(restored: fakeUser(name: 'Kiptoo Langat')),
      profile: profile,
    );
    await b.pump(t);
    b.router.go('/creatives/nia_w');
    await t.pumpAndSettle();
    expect(find.text('nia@example.com'), findsOneWidget);

    await _signOffScreen(t);

    // Nia hides it again (a new session of the same account); the other account no longer sees it.
    final a2 = Harness(
      auth: FakeAuthRepository(restored: fakeUser(name: 'Nia Wairimu')),
      account: owner,
    );
    await a2.pump(t);
    a2.router.go('/settings/privacy');
    await t.pumpAndSettle();
    await t.tap(find.text('Only me').first);
    await t.pumpAndSettle();
    expect(server.contact, api.Visibility.private);
    await _signOffScreen(t);
    final b2 = Harness(
      auth: FakeAuthRepository(restored: fakeUser(name: 'Kiptoo Langat')),
      profile: profile,
    );
    await b2.pump(t);
    b2.router.go('/creatives/nia_w');
    await t.pumpAndSettle();
    expect(find.text('nia@example.com'), findsNothing);
  });

  testWidgets('delete account: confirm with DELETE, scheduled, signed out', (
    t,
  ) async {
    final account = FakeAccountRepository();
    final h = Harness(
      auth: FakeAuthRepository(restored: fakeUser(name: 'Nia Wairimu')),
      account: account,
    );
    await h.pump(t);
    h.router.go('/settings');
    await t.pumpAndSettle();
    await tapText(t, 'Delete account');
    expect(h.path, '/settings/delete');
    await typeInto(t, 0, 'DELETE');
    await tapText(t, 'Delete account permanently');
    expect(account.deleteCalls.single.confirm, 'DELETE');
    expect(find.text('Your account is scheduled for deletion'), findsOneWidget);
    await tapText(t, 'OK');
    expect(h.auth.calls, contains('signOut'));
    expect(t.takeException(), isNull);
  });
}
