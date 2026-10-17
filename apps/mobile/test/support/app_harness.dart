import 'package:atarah/core/analytics/analytics.dart';
import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/app/app.dart';
import 'package:atarah/core/config/app_config.dart';
import 'package:atarah/core/connectivity/connectivity_provider.dart';
import 'package:atarah/core/content/content_repository.dart';
import 'package:atarah/core/networking/failures.dart';
import 'package:atarah/core/providers.dart';
import 'package:atarah/core/routing/app_router.dart';
import 'package:atarah/core/storage/token_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'fakes.dart';

/// In-memory stand-in for [ContentRepository].
class FakeContentRepository implements ContentRepository {
  FakeContentRepository({this.google = false, this.legalFailure});

  bool google;
  AppFailure? legalFailure;

  @override
  Future<bool> googleSignInEnabled() async => google;

  @override
  Future<LegalDocumentDto> legalDocument(String type) async {
    final f = legalFailure;
    if (f != null) throw f;
    return LegalDocumentDto(
      type: type == 'PRIVACY'
          ? LegalDocumentDtoType.privacy
          : LegalDocumentDtoType.terms,
      version: '1',
      title: type == 'PRIVACY'
          ? 'DRAFT — Privacy Policy'
          : 'DRAFT — Terms of Service',
      body: 'Placeholder legal text for $type.',
      isDraft: true,
    );
  }
}

/// Everything a screen test needs: the real app and router with fakes for the network edges.
class Harness {
  Harness({
    FakeAuthRepository? auth,
    FakeContentRepository? content,
    Flavor flavor = Flavor.dev,
  }) : auth = auth ?? FakeAuthRepository(),
       content = content ?? FakeContentRepository(),
       analytics = RecordingAnalytics() {
    container = ProviderContainer(
      retry: noAutomaticRetry,
      overrides: [
        appConfigProvider.overrideWithValue(
          AppConfig(flavor: flavor, apiBaseUrl: 'http://test.local'),
        ),
        authRepositoryProvider.overrideWithValue(this.auth),
        contentRepositoryProvider.overrideWithValue(this.content),
        analyticsProvider.overrideWithValue(analytics),
        tokenStoreProvider.overrideWithValue(MemoryTokenStore()),
        isOnlineProvider.overrideWith((ref) => Stream.value(true)),
      ],
    );
  }

  final FakeAuthRepository auth;
  final FakeContentRepository content;
  final RecordingAnalytics analytics;
  late final ProviderContainer container;

  GoRouter get router => container.read(appRouterProvider);
  String get path => router.state.uri.path;

  List<String> get events => analytics.events.map((e) => e.event).toList();

  Future<void> pump(WidgetTester t) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    addTearDown(container.dispose);
    await t.pumpWidget(
      UncontrolledProviderScope(container: container, child: const AtarahApp()),
    );
    await t.pumpAndSettle();
  }
}

/// Types into the `index`-th text field on screen.
Future<void> typeInto(WidgetTester t, int index, String text) async {
  await t.enterText(find.byType(TextField).at(index), text);
  await t.pump();
}

Future<void> tapText(WidgetTester t, String text, {bool last = false}) async {
  final finder = last ? find.text(text).last : find.text(text);
  await t.ensureVisible(finder);
  await t.tap(finder);
  await t.pumpAndSettle();
}

const wrongPasswordMessage =
    "That password doesn't match this account. Check it and try again, or reset it.";
