// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'groups_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(groupsRepository)
final groupsRepositoryProvider = GroupsRepositoryProvider._();

final class GroupsRepositoryProvider
    extends
        $FunctionalProvider<
          GroupsRepository,
          GroupsRepository,
          GroupsRepository
        >
    with $Provider<GroupsRepository> {
  GroupsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupsRepositoryHash();

  @$internal
  @override
  $ProviderElement<GroupsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GroupsRepository create(Ref ref) {
    return groupsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupsRepository>(value),
    );
  }
}

String _$groupsRepositoryHash() => r'9b4888eab8d738cf35e5b802b0844b7d853bd39a';

/// The groups the member belongs to (the "Your groups" carousel).

@ProviderFor(myGroups)
final myGroupsProvider = MyGroupsProvider._();

/// The groups the member belongs to (the "Your groups" carousel).

final class MyGroupsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GroupCardDto>>,
          List<GroupCardDto>,
          FutureOr<List<GroupCardDto>>
        >
    with
        $FutureModifier<List<GroupCardDto>>,
        $FutureProvider<List<GroupCardDto>> {
  /// The groups the member belongs to (the "Your groups" carousel).
  MyGroupsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myGroupsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myGroupsHash();

  @$internal
  @override
  $FutureProviderElement<List<GroupCardDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GroupCardDto>> create(Ref ref) {
    return myGroups(ref);
  }
}

String _$myGroupsHash() => r'13b2d4bdc1f9d666d2950946a942a2a2b186bdfd';

@ProviderFor(GroupQueryState)
final groupQueryStateProvider = GroupQueryStateProvider._();

final class GroupQueryStateProvider
    extends $NotifierProvider<GroupQueryState, GroupQuery> {
  GroupQueryStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupQueryStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupQueryStateHash();

  @$internal
  @override
  GroupQueryState create() => GroupQueryState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupQuery value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupQuery>(value),
    );
  }
}

String _$groupQueryStateHash() => r'6822926997bd7c06e9d2e487af1846d79b62098e';

abstract class _$GroupQueryState extends $Notifier<GroupQuery> {
  GroupQuery build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<GroupQuery, GroupQuery>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GroupQuery, GroupQuery>,
              GroupQuery,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(DiscoverGroups)
final discoverGroupsProvider = DiscoverGroupsProvider._();

final class DiscoverGroupsProvider
    extends $AsyncNotifierProvider<DiscoverGroups, GroupList> {
  DiscoverGroupsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'discoverGroupsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$discoverGroupsHash();

  @$internal
  @override
  DiscoverGroups create() => DiscoverGroups();
}

String _$discoverGroupsHash() => r'11629aa04ecf6873b219230b22a9130aff62d353';

abstract class _$DiscoverGroups extends $AsyncNotifier<GroupList> {
  FutureOr<GroupList> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<GroupList>, GroupList>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<GroupList>, GroupList>,
              AsyncValue<GroupList>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// One group by id or slug.

@ProviderFor(groupDetail)
final groupDetailProvider = GroupDetailFamily._();

/// One group by id or slug.

final class GroupDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<GroupDetailDto>,
          GroupDetailDto,
          FutureOr<GroupDetailDto>
        >
    with $FutureModifier<GroupDetailDto>, $FutureProvider<GroupDetailDto> {
  /// One group by id or slug.
  GroupDetailProvider._({
    required GroupDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupDetailHash();

  @override
  String toString() {
    return r'groupDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<GroupDetailDto> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GroupDetailDto> create(Ref ref) {
    final argument = this.argument as String;
    return groupDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupDetailHash() => r'36ca78d6807701a8ef0ebf6cb83155c9fb7a4e8c';

/// One group by id or slug.

final class GroupDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<GroupDetailDto>, String> {
  GroupDetailFamily._()
    : super(
        retry: null,
        name: r'groupDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One group by id or slug.

  GroupDetailProvider call(String groupRef) =>
      GroupDetailProvider._(argument: groupRef, from: this);

  @override
  String toString() => r'groupDetailProvider';
}

@ProviderFor(GroupPosts)
final groupPostsProvider = GroupPostsFamily._();

final class GroupPostsProvider
    extends $AsyncNotifierProvider<GroupPosts, GroupPostList> {
  GroupPostsProvider._({
    required GroupPostsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupPostsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupPostsHash();

  @override
  String toString() {
    return r'groupPostsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  GroupPosts create() => GroupPosts();

  @override
  bool operator ==(Object other) {
    return other is GroupPostsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupPostsHash() => r'3c4d5bb4690f27b4ffe978872fdd7459526545d1';

final class GroupPostsFamily extends $Family
    with
        $ClassFamilyOverride<
          GroupPosts,
          AsyncValue<GroupPostList>,
          GroupPostList,
          FutureOr<GroupPostList>,
          String
        > {
  GroupPostsFamily._()
    : super(
        retry: null,
        name: r'groupPostsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GroupPostsProvider call(String groupRef) =>
      GroupPostsProvider._(argument: groupRef, from: this);

  @override
  String toString() => r'groupPostsProvider';
}

abstract class _$GroupPosts extends $AsyncNotifier<GroupPostList> {
  late final _$args = ref.$arg as String;
  String get groupRef => _$args;

  FutureOr<GroupPostList> build(String groupRef);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<GroupPostList>, GroupPostList>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<GroupPostList>, GroupPostList>,
              AsyncValue<GroupPostList>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(GroupMembership)
final groupMembershipProvider = GroupMembershipProvider._();

final class GroupMembershipProvider
    extends
        $NotifierProvider<GroupMembership, Map<String, MembershipOverride>> {
  GroupMembershipProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupMembershipProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupMembershipHash();

  @$internal
  @override
  GroupMembership create() => GroupMembership();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, MembershipOverride> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, MembershipOverride>>(
        value,
      ),
    );
  }
}

String _$groupMembershipHash() => r'a855f172e677177889e532455bf87f2f7dc2e3f1';

abstract class _$GroupMembership
    extends $Notifier<Map<String, MembershipOverride>> {
  Map<String, MembershipOverride> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              Map<String, MembershipOverride>,
              Map<String, MembershipOverride>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, MembershipOverride>,
                Map<String, MembershipOverride>
              >,
              Map<String, MembershipOverride>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
