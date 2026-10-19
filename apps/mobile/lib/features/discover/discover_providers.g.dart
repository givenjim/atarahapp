// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discover_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(discoverRepository)
final discoverRepositoryProvider = DiscoverRepositoryProvider._();

final class DiscoverRepositoryProvider
    extends
        $FunctionalProvider<
          DiscoverRepository,
          DiscoverRepository,
          DiscoverRepository
        >
    with $Provider<DiscoverRepository> {
  DiscoverRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'discoverRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$discoverRepositoryHash();

  @$internal
  @override
  $ProviderElement<DiscoverRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DiscoverRepository create(Ref ref) {
    return discoverRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DiscoverRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DiscoverRepository>(value),
    );
  }
}

String _$discoverRepositoryHash() =>
    r'2dab6afb09bb00114695b94dd5373fe407b576a8';

/// The Home tab's one aggregated payload.

@ProviderFor(homeFeed)
final homeFeedProvider = HomeFeedProvider._();

/// The Home tab's one aggregated payload.

final class HomeFeedProvider
    extends $FunctionalProvider<AsyncValue<HomeDto>, HomeDto, FutureOr<HomeDto>>
    with $FutureModifier<HomeDto>, $FutureProvider<HomeDto> {
  /// The Home tab's one aggregated payload.
  HomeFeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeFeedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeFeedHash();

  @$internal
  @override
  $FutureProviderElement<HomeDto> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<HomeDto> create(Ref ref) {
    return homeFeed(ref);
  }
}

String _$homeFeedHash() => r'800f6f84fb311c725d38dff597302cc746aabe1e';

/// The filters Explore is showing. Kept while the app runs so coming back to the tab finds the same list.

@ProviderFor(ExploreFilters)
final exploreFiltersProvider = ExploreFiltersProvider._();

/// The filters Explore is showing. Kept while the app runs so coming back to the tab finds the same list.
final class ExploreFiltersProvider
    extends $NotifierProvider<ExploreFilters, CreativeFilters> {
  /// The filters Explore is showing. Kept while the app runs so coming back to the tab finds the same list.
  ExploreFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreFiltersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreFiltersHash();

  @$internal
  @override
  ExploreFilters create() => ExploreFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreativeFilters value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreativeFilters>(value),
    );
  }
}

String _$exploreFiltersHash() => r'11f4d928b5d844e7a99d852f0352d34f1e078a26';

/// The filters Explore is showing. Kept while the app runs so coming back to the tab finds the same list.

abstract class _$ExploreFilters extends $Notifier<CreativeFilters> {
  CreativeFilters build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CreativeFilters, CreativeFilters>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CreativeFilters, CreativeFilters>,
              CreativeFilters,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// How many creatives match a set of filters (the sheet's "Show n results").

@ProviderFor(creativeCount)
final creativeCountProvider = CreativeCountFamily._();

/// How many creatives match a set of filters (the sheet's "Show n results").

final class CreativeCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// How many creatives match a set of filters (the sheet's "Show n results").
  CreativeCountProvider._({
    required CreativeCountFamily super.from,
    required CreativeFilters super.argument,
  }) : super(
         retry: null,
         name: r'creativeCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$creativeCountHash();

  @override
  String toString() {
    return r'creativeCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as CreativeFilters;
    return creativeCount(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CreativeCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$creativeCountHash() => r'aa4f28d0ef1806d77f8bbcc539aa6dcbdafb5f7c';

/// How many creatives match a set of filters (the sheet's "Show n results").

final class CreativeCountFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, CreativeFilters> {
  CreativeCountFamily._()
    : super(
        retry: null,
        name: r'creativeCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// How many creatives match a set of filters (the sheet's "Show n results").

  CreativeCountProvider call(CreativeFilters filters) =>
      CreativeCountProvider._(argument: filters, from: this);

  @override
  String toString() => r'creativeCountProvider';
}

@ProviderFor(ExploreCreatives)
final exploreCreativesProvider = ExploreCreativesProvider._();

final class ExploreCreativesProvider
    extends $AsyncNotifierProvider<ExploreCreatives, CreativeList> {
  ExploreCreativesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreCreativesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreCreativesHash();

  @$internal
  @override
  ExploreCreatives create() => ExploreCreatives();
}

String _$exploreCreativesHash() => r'6bc8e54b9f240a8f655364eb7cc7e99f89854716';

abstract class _$ExploreCreatives extends $AsyncNotifier<CreativeList> {
  FutureOr<CreativeList> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<CreativeList>, CreativeList>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CreativeList>, CreativeList>,
              AsyncValue<CreativeList>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(recentSearches)
final recentSearchesProvider = RecentSearchesProvider._();

final class RecentSearchesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RecentSearchDto>>,
          List<RecentSearchDto>,
          FutureOr<List<RecentSearchDto>>
        >
    with
        $FutureModifier<List<RecentSearchDto>>,
        $FutureProvider<List<RecentSearchDto>> {
  RecentSearchesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentSearchesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentSearchesHash();

  @$internal
  @override
  $FutureProviderElement<List<RecentSearchDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RecentSearchDto>> create(Ref ref) {
    return recentSearches(ref);
  }
}

String _$recentSearchesHash() => r'4b8b872f7667bb3e27097c92102287042f1029a2';

@ProviderFor(article)
final articleProvider = ArticleFamily._();

final class ArticleProvider
    extends
        $FunctionalProvider<
          AsyncValue<ArticleDto>,
          ArticleDto,
          FutureOr<ArticleDto>
        >
    with $FutureModifier<ArticleDto>, $FutureProvider<ArticleDto> {
  ArticleProvider._({
    required ArticleFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'articleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$articleHash();

  @override
  String toString() {
    return r'articleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ArticleDto> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ArticleDto> create(Ref ref) {
    final argument = this.argument as String;
    return article(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ArticleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$articleHash() => r'601e98c8eb434d97e3de9a69ab89919fa41601ef';

final class ArticleFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ArticleDto>, String> {
  ArticleFamily._()
    : super(
        retry: null,
        name: r'articleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ArticleProvider call(String slug) =>
      ArticleProvider._(argument: slug, from: this);

  @override
  String toString() => r'articleProvider';
}

/// The articles list, a page at a time.

@ProviderFor(ArticleList)
final articleListProvider = ArticleListProvider._();

/// The articles list, a page at a time.
final class ArticleListProvider
    extends $AsyncNotifierProvider<ArticleList, PageOf<ArticleCardDto>> {
  /// The articles list, a page at a time.
  ArticleListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'articleListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$articleListHash();

  @$internal
  @override
  ArticleList create() => ArticleList();
}

String _$articleListHash() => r'e72cf787b2929d0fe16a65fa2db0aa4d44ec837a';

/// The articles list, a page at a time.

abstract class _$ArticleList extends $AsyncNotifier<PageOf<ArticleCardDto>> {
  FutureOr<PageOf<ArticleCardDto>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<PageOf<ArticleCardDto>>, PageOf<ArticleCardDto>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PageOf<ArticleCardDto>>,
                PageOf<ArticleCardDto>
              >,
              AsyncValue<PageOf<ArticleCardDto>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
