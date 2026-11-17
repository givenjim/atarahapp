import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_people.dart';

/// People tab and connections / requests view, light and dark, 390x844 at 1x. Regenerate with
/// `flutter test --update-goldens test/features/people_goldens_test.dart`.
void main() {
  for (final appearance in AtAppearance.values) {
    testWidgets('people tab ${appearance.name}', (t) async {
      final h = PeopleHarness(
        appearance: appearance,
        people: FakePeopleRepository(
          people: [
            personToMeet(verified: true, open: true),
            personToMeet(
              handle: 'otieno',
              name: 'Otieno Ouma',
              reason: 'Based in Nairobi',
              pending: true,
            ),
          ],
          received: [
            connectionItem(state: ConnectionListItemDtoState.pendingReceived),
          ],
        ),
      );
      await h.pump(t);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/people/people_tab.${appearance.name}.png'),
      );
    });

    testWidgets('requests view ${appearance.name}', (t) async {
      final h = PeopleHarness(
        appearance: appearance,
        start: '/connections?list=received',
        people: FakePeopleRepository(
          received: [
            connectionItem(state: ConnectionListItemDtoState.pendingReceived),
            connectionItem(
              id: 'c-2',
              handle: 'zuri',
              name: 'Zuri Mwangi',
              state: ConnectionListItemDtoState.pendingReceived,
            ),
          ],
        ),
      );
      await h.pump(t);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/people/requests.${appearance.name}.png'),
      );
    });
  }
}
