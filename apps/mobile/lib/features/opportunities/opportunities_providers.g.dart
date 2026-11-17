// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opportunities_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(opportunitiesRepository)
final opportunitiesRepositoryProvider = OpportunitiesRepositoryProvider._();

final class OpportunitiesRepositoryProvider
    extends
        $FunctionalProvider<
          OpportunitiesRepository,
          OpportunitiesRepository,
          OpportunitiesRepository
        >
    with $Provider<OpportunitiesRepository> {
  OpportunitiesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'opportunitiesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$opportunitiesRepositoryHash();

  @$internal
  @override
  $ProviderElement<OpportunitiesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OpportunitiesRepository create(Ref ref) {
    return opportunitiesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OpportunitiesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OpportunitiesRepository>(value),
    );
  }
}

String _$opportunitiesRepositoryHash() =>
    r'cc304659de2fa645c8917dd556642f06da967808';

/// The Opportunities tab's one aggregated payload.

@ProviderFor(opportunitiesHome)
final opportunitiesHomeProvider = OpportunitiesHomeProvider._();

/// The Opportunities tab's one aggregated payload.

final class OpportunitiesHomeProvider
    extends
        $FunctionalProvider<
          AsyncValue<OpportunitiesHomeDto>,
          OpportunitiesHomeDto,
          FutureOr<OpportunitiesHomeDto>
        >
    with
        $FutureModifier<OpportunitiesHomeDto>,
        $FutureProvider<OpportunitiesHomeDto> {
  /// The Opportunities tab's one aggregated payload.
  OpportunitiesHomeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'opportunitiesHomeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$opportunitiesHomeHash();

  @$internal
  @override
  $FutureProviderElement<OpportunitiesHomeDto> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<OpportunitiesHomeDto> create(Ref ref) {
    return opportunitiesHome(ref);
  }
}

String _$opportunitiesHomeHash() => r'f85dd083422496f5ce0822177fc7267175ec947a';

@ProviderFor(OpportunityListNotifier)
final opportunityListProvider = OpportunityListNotifierFamily._();

final class OpportunityListNotifierProvider
    extends $AsyncNotifierProvider<OpportunityListNotifier, OpportunityList> {
  OpportunityListNotifierProvider._({
    required OpportunityListNotifierFamily super.from,
    required OpportunityFilters super.argument,
  }) : super(
         retry: null,
         name: r'opportunityListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$opportunityListNotifierHash();

  @override
  String toString() {
    return r'opportunityListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  OpportunityListNotifier create() => OpportunityListNotifier();

  @override
  bool operator ==(Object other) {
    return other is OpportunityListNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$opportunityListNotifierHash() =>
    r'24ea814eb78bb46e1901c42b7c6302a8a26715eb';

final class OpportunityListNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          OpportunityListNotifier,
          AsyncValue<OpportunityList>,
          OpportunityList,
          FutureOr<OpportunityList>,
          OpportunityFilters
        > {
  OpportunityListNotifierFamily._()
    : super(
        retry: null,
        name: r'opportunityListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OpportunityListNotifierProvider call(OpportunityFilters filters) =>
      OpportunityListNotifierProvider._(argument: filters, from: this);

  @override
  String toString() => r'opportunityListProvider';
}

abstract class _$OpportunityListNotifier
    extends $AsyncNotifier<OpportunityList> {
  late final _$args = ref.$arg as OpportunityFilters;
  OpportunityFilters get filters => _$args;

  FutureOr<OpportunityList> build(OpportunityFilters filters);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<OpportunityList>, OpportunityList>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<OpportunityList>, OpportunityList>,
              AsyncValue<OpportunityList>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// One opportunity with the member's profile check. [refresh] asks the server to skip its 5 minute cache,
/// for when the member comes back from fixing something or pulls to refresh.

@ProviderFor(OpportunityDetail)
final opportunityDetailProvider = OpportunityDetailFamily._();

/// One opportunity with the member's profile check. [refresh] asks the server to skip its 5 minute cache,
/// for when the member comes back from fixing something or pulls to refresh.
final class OpportunityDetailProvider
    extends $AsyncNotifierProvider<OpportunityDetail, OpportunityDto> {
  /// One opportunity with the member's profile check. [refresh] asks the server to skip its 5 minute cache,
  /// for when the member comes back from fixing something or pulls to refresh.
  OpportunityDetailProvider._({
    required OpportunityDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'opportunityDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$opportunityDetailHash();

  @override
  String toString() {
    return r'opportunityDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  OpportunityDetail create() => OpportunityDetail();

  @override
  bool operator ==(Object other) {
    return other is OpportunityDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$opportunityDetailHash() => r'54ea7598ef079ab1344336e85eb08cd89e80a823';

/// One opportunity with the member's profile check. [refresh] asks the server to skip its 5 minute cache,
/// for when the member comes back from fixing something or pulls to refresh.

final class OpportunityDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          OpportunityDetail,
          AsyncValue<OpportunityDto>,
          OpportunityDto,
          FutureOr<OpportunityDto>,
          String
        > {
  OpportunityDetailFamily._()
    : super(
        retry: null,
        name: r'opportunityDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One opportunity with the member's profile check. [refresh] asks the server to skip its 5 minute cache,
  /// for when the member comes back from fixing something or pulls to refresh.

  OpportunityDetailProvider call(String id) =>
      OpportunityDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'opportunityDetailProvider';
}

/// One opportunity with the member's profile check. [refresh] asks the server to skip its 5 minute cache,
/// for when the member comes back from fixing something or pulls to refresh.

abstract class _$OpportunityDetail extends $AsyncNotifier<OpportunityDto> {
  late final _$args = ref.$arg as String;
  String get id => _$args;

  FutureOr<OpportunityDto> build(String id);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<OpportunityDto>, OpportunityDto>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<OpportunityDto>, OpportunityDto>,
              AsyncValue<OpportunityDto>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(MyOpportunitiesNotifier)
final myOpportunitiesProvider = MyOpportunitiesNotifierFamily._();

final class MyOpportunitiesNotifierProvider
    extends $AsyncNotifierProvider<MyOpportunitiesNotifier, MyOpportunities> {
  MyOpportunitiesNotifierProvider._({
    required MyOpportunitiesNotifierFamily super.from,
    required MyTab super.argument,
  }) : super(
         retry: null,
         name: r'myOpportunitiesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myOpportunitiesNotifierHash();

  @override
  String toString() {
    return r'myOpportunitiesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MyOpportunitiesNotifier create() => MyOpportunitiesNotifier();

  @override
  bool operator ==(Object other) {
    return other is MyOpportunitiesNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myOpportunitiesNotifierHash() =>
    r'6e7ad64e3be13002699f86695fc7d8a10add7b26';

final class MyOpportunitiesNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          MyOpportunitiesNotifier,
          AsyncValue<MyOpportunities>,
          MyOpportunities,
          FutureOr<MyOpportunities>,
          MyTab
        > {
  MyOpportunitiesNotifierFamily._()
    : super(
        retry: null,
        name: r'myOpportunitiesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MyOpportunitiesNotifierProvider call(MyTab tab) =>
      MyOpportunitiesNotifierProvider._(argument: tab, from: this);

  @override
  String toString() => r'myOpportunitiesProvider';
}

abstract class _$MyOpportunitiesNotifier
    extends $AsyncNotifier<MyOpportunities> {
  late final _$args = ref.$arg as MyTab;
  MyTab get tab => _$args;

  FutureOr<MyOpportunities> build(MyTab tab);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<MyOpportunities>, MyOpportunities>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MyOpportunities>, MyOpportunities>,
              AsyncValue<MyOpportunities>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// What the member has just saved or un-saved, ahead of the server's answer. A card shows
/// `overrides[id] ?? card.saved`.

@ProviderFor(OpportunitySaves)
final opportunitySavesProvider = OpportunitySavesProvider._();

/// What the member has just saved or un-saved, ahead of the server's answer. A card shows
/// `overrides[id] ?? card.saved`.
final class OpportunitySavesProvider
    extends $NotifierProvider<OpportunitySaves, Map<String, bool>> {
  /// What the member has just saved or un-saved, ahead of the server's answer. A card shows
  /// `overrides[id] ?? card.saved`.
  OpportunitySavesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'opportunitySavesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$opportunitySavesHash();

  @$internal
  @override
  OpportunitySaves create() => OpportunitySaves();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, bool> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, bool>>(value),
    );
  }
}

String _$opportunitySavesHash() => r'df68ad3951bddfab33add883a86acb976c57b24e';

/// What the member has just saved or un-saved, ahead of the server's answer. A card shows
/// `overrides[id] ?? card.saved`.

abstract class _$OpportunitySaves extends $Notifier<Map<String, bool>> {
  Map<String, bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Map<String, bool>, Map<String, bool>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, bool>, Map<String, bool>>,
              Map<String, bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
