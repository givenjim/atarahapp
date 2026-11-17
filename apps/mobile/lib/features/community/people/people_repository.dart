import '../../../core/api/generated/export.dart';
import '../../../core/networking/failures.dart';
import '../../discover/discover_repository.dart' show PageOf;

/// What narrows "People to meet". Equal filters are equal values.
class PeopleFilters {
  const PeopleFilters({
    this.disciplineId,
    this.disciplineName,
    this.countyId,
    this.countyName,
    this.verified = false,
    this.available = false,
  });

  final String? disciplineId;

  /// Only for showing the chosen discipline on a chip; not sent to the API.
  final String? disciplineName;
  final String? countyId;

  /// Only for showing the chosen county on a chip; not sent to the API.
  final String? countyName;
  final bool verified;

  /// Open to work (open to commissions).
  final bool available;

  bool get isEmpty =>
      disciplineId == null && countyId == null && !verified && !available;

  PeopleFilters copyWith({
    Object? disciplineId = _keep,
    Object? disciplineName = _keep,
    Object? countyId = _keep,
    Object? countyName = _keep,
    bool? verified,
    bool? available,
  }) => PeopleFilters(
    disciplineId: identical(disciplineId, _keep)
        ? this.disciplineId
        : disciplineId as String?,
    disciplineName: identical(disciplineName, _keep)
        ? this.disciplineName
        : disciplineName as String?,
    countyId: identical(countyId, _keep) ? this.countyId : countyId as String?,
    countyName: identical(countyName, _keep)
        ? this.countyName
        : countyName as String?,
    verified: verified ?? this.verified,
    available: available ?? this.available,
  );

  static const _keep = Object();

  @override
  bool operator ==(Object other) =>
      other is PeopleFilters &&
      other.disciplineId == disciplineId &&
      other.countyId == countyId &&
      other.verified == verified &&
      other.available == available;

  @override
  int get hashCode => Object.hash(disciplineId, countyId, verified, available);
}

int _total(dynamic meta, int fallback) {
  if (meta is Map && meta['total'] is num) {
    return (meta['total'] as num).toInt();
  }
  return fallback;
}

/// People to meet, the connections lists and the blocked list, with errors mapped to typed failures.
/// Connect / accept / decline / cancel go through the profile repository (P1-M3), not through here.
/// Widgets use providers; tests replace this with an in-memory fake.
class PeopleRepository {
  PeopleRepository({required this._api});

  final AtarahApiClient _api;

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on Object catch (e) {
      throw mapError(e);
    }
  }

  Future<PageOf<PersonToMeetDto>> suggestions(
    PeopleFilters f, {
    int page = 1,
    int limit = 20,
  }) => _guard(() async {
    final res = await _api.community.listPeopleToMeet(
      disciplineId: f.disciplineId,
      countyId: f.countyId,
      verified: f.verified ? true : null,
      available: f.available ? true : null,
      page: page,
      limit: limit,
    );
    return PageOf(res.data, _total(res.meta, res.data.length));
  });

  Future<PageOf<ConnectionListItemDto>> connections(
    ListState listState, {
    int page = 1,
    int limit = 20,
  }) => _guard(() async {
    final res = await _api.profile.myConnections(
      listState: listState,
      page: page,
      limit: limit,
    );
    return PageOf(res.data, _total(res.meta, res.data.length));
  });

  Future<PageOf<BlockedMemberDto>> blocks({int page = 1, int limit = 20}) =>
      _guard(() async {
        final res = await _api.communitySafety.listBlockedMembers(
          page: page,
          limit: limit,
        );
        return PageOf(res.data, _total(res.meta, res.data.length));
      });

  Future<void> unblock(String userId) =>
      _guard(() => _api.communitySafety.unblockMember(userId: userId));
}
