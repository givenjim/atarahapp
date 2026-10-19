import 'dart:typed_data';

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
import 'package:atarah/features/discover/discover_providers.dart';
import 'package:atarah/features/onboarding/onboarding_providers.dart';
import 'package:atarah/features/portfolio/portfolio_providers.dart';
import 'package:atarah/features/profile/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'fake_discover.dart';
import 'fake_onboarding.dart';
import 'fake_portfolio.dart';
import 'fake_profile.dart';
import 'fakes.dart';

/// A 1x1 transparent PNG, so avatar images decode in tests without a network.
final _pixel = Uint8List.fromList(const [
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0xF8,
  0xFF,
  0xFF,
  0x3F,
  0x00,
  0x05,
  0xFE,
  0x02,
  0xFE,
  0xA7,
  0x35,
  0x81,
  0x84,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

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
    FakeOnboardingRepository? onboarding,
    FakeLocationLookup? location,
    FakePhotoPicker? picker,
    FakeProfileRepository? profile,
    FakePortfolioRepository? portfolio,
    FakeDiscoverRepository? discover,
    FakeMediaPicker? media,
    Flavor flavor = Flavor.dev,
  }) : auth = auth ?? FakeAuthRepository(),
       content = content ?? FakeContentRepository(),
       // Most tests are about a member whose profile setup is finished.
       onboarding =
           onboarding ??
           FakeOnboardingRepository(
             completed: true,
             step: OnboardingStateDtoStep.done,
           ),
       location = location ?? FakeLocationLookup(),
       picker = picker ?? FakePhotoPicker(),
       profile = profile ?? FakeProfileRepository(),
       portfolio = portfolio ?? FakePortfolioRepository(),
       discover = discover ?? FakeDiscoverRepository(),
       media = media ?? FakeMediaPicker(),
       analytics = RecordingAnalytics() {
    container = ProviderContainer(
      retry: noAutomaticRetry,
      overrides: [
        appConfigProvider.overrideWithValue(
          AppConfig(flavor: flavor, apiBaseUrl: 'http://test.local'),
        ),
        authRepositoryProvider.overrideWithValue(this.auth),
        contentRepositoryProvider.overrideWithValue(this.content),
        onboardingRepositoryProvider.overrideWithValue(this.onboarding),
        locationLookupProvider.overrideWithValue(this.location),
        photoPickerProvider.overrideWithValue(this.picker),
        profileRepositoryProvider.overrideWithValue(this.profile),
        portfolioRepositoryProvider.overrideWithValue(this.portfolio),
        discoverRepositoryProvider.overrideWithValue(this.discover),
        mediaPickerProvider.overrideWithValue(this.media),
        videoViewProvider.overrideWithValue(fakePlayer),
        audioViewProvider.overrideWithValue(fakePlayer),
        embedViewProvider.overrideWithValue(fakePlayer),
        shareTextProvider.overrideWithValue((text) async => shared.add(text)),
        openLinkProvider.overrideWithValue((uri) async {
          opened.add(uri);
          return true;
        }),
        photoCropperProvider.overrideWithValue(fakeCropper),
        avatarImageProvider.overrideWithValue((_) => MemoryImage(_pixel)),
        analyticsProvider.overrideWithValue(analytics),
        tokenStoreProvider.overrideWithValue(MemoryTokenStore()),
        isOnlineProvider.overrideWith((ref) => Stream.value(true)),
      ],
    );
  }

  final FakeAuthRepository auth;
  final FakeContentRepository content;
  final FakeOnboardingRepository onboarding;
  final FakeLocationLookup location;
  final FakePhotoPicker picker;
  final FakeProfileRepository profile;
  final FakePortfolioRepository portfolio;
  final FakeDiscoverRepository discover;
  final FakeMediaPicker media;

  /// Text handed to the share sheet and addresses opened in the browser.
  final List<String> shared = [];
  final List<Uri> opened = [];
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
