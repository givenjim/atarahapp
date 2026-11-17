// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unread_notifications.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The live unread-notification count for the Home bell.
///
/// It starts from what `GET /home` reports and goes up by one for each new row the member's own
/// `notifications` Realtime channel delivers (Master Prompt 5.7 rule 4). The channel is opened once after
/// sign-in and closed on sign-out. The notifications screen (P1-M11) keeps it in step through [set] and [decrement].

@ProviderFor(UnreadNotifications)
final unreadNotificationsProvider = UnreadNotificationsProvider._();

/// The live unread-notification count for the Home bell.
///
/// It starts from what `GET /home` reports and goes up by one for each new row the member's own
/// `notifications` Realtime channel delivers (Master Prompt 5.7 rule 4). The channel is opened once after
/// sign-in and closed on sign-out. The notifications screen (P1-M11) keeps it in step through [set] and [decrement].
final class UnreadNotificationsProvider
    extends $NotifierProvider<UnreadNotifications, int> {
  /// The live unread-notification count for the Home bell.
  ///
  /// It starts from what `GET /home` reports and goes up by one for each new row the member's own
  /// `notifications` Realtime channel delivers (Master Prompt 5.7 rule 4). The channel is opened once after
  /// sign-in and closed on sign-out. The notifications screen (P1-M11) keeps it in step through [set] and [decrement].
  UnreadNotificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadNotificationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadNotificationsHash();

  @$internal
  @override
  UnreadNotifications create() => UnreadNotifications();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$unreadNotificationsHash() =>
    r'af955927ee5fa7226fde13d4f8984069dad979f0';

/// The live unread-notification count for the Home bell.
///
/// It starts from what `GET /home` reports and goes up by one for each new row the member's own
/// `notifications` Realtime channel delivers (Master Prompt 5.7 rule 4). The channel is opened once after
/// sign-in and closed on sign-out. The notifications screen (P1-M11) keeps it in step through [set] and [decrement].

abstract class _$UnreadNotifications extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
