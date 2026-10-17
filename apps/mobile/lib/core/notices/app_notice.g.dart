// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notice.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A one-time message to show after navigation, for example "You were signed out on your other devices".
/// The shell shows it once and clears it.

@ProviderFor(AppNotice)
final appNoticeProvider = AppNoticeProvider._();

/// A one-time message to show after navigation, for example "You were signed out on your other devices".
/// The shell shows it once and clears it.
final class AppNoticeProvider extends $NotifierProvider<AppNotice, String?> {
  /// A one-time message to show after navigation, for example "You were signed out on your other devices".
  /// The shell shows it once and clears it.
  AppNoticeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appNoticeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appNoticeHash();

  @$internal
  @override
  AppNotice create() => AppNotice();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$appNoticeHash() => r'63e80e70969506a0fb37bc53fcee7770d62ce7bf';

/// A one-time message to show after navigation, for example "You were signed out on your other devices".
/// The shell shows it once and clears it.

abstract class _$AppNotice extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
