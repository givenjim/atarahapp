import '../../core/api/generated/export.dart';
import '../../core/networking/failures.dart';
import '../../core/storage/offline_cache.dart';

/// What narrows the list of opportunities. Equal filters are equal values, so a list can be cached per
/// combination.
class OpportunityFilters {
  const OpportunityFilters({
    this.type,
    this.q,
    this.disciplineId,
    this.countyId,
    this.countyName,
    this.remote = false,
    this.deadline,
    this.trust,
    this.sort = Sort2.deadline,
  });

  final OpportunityType? type;
  final String? q;
  final String? disciplineId;
  final String? countyId;

  /// Only for showing the chosen county on a chip; not sent to the API.
  final String? countyName;
  final bool remote;
  final Deadline? deadline;
  final OpportunityTrust? trust;
  final Sort2 sort;

  /// Filters from the sheet (the category and the sort are tabs, not filters).
  int get activeCount => [
    disciplineId != null,
    countyId != null,
    remote,
    deadline != null,
    trust != null,
  ].where((x) => x).length;

  OpportunityFilters copyWith({
    Object? type = _keep,
    Object? q = _keep,
    Object? disciplineId = _keep,
    Object? countyId = _keep,
    Object? countyName = _keep,
    bool? remote,
    Object? deadline = _keep,
    Object? trust = _keep,
    Sort2? sort,
  }) => OpportunityFilters(
    type: identical(type, _keep) ? this.type : type as OpportunityType?,
    q: identical(q, _keep) ? this.q : q as String?,
    disciplineId: identical(disciplineId, _keep)
        ? this.disciplineId
        : disciplineId as String?,
    countyId: identical(countyId, _keep) ? this.countyId : countyId as String?,
    countyName: identical(countyName, _keep)
        ? this.countyName
        : countyName as String?,
    remote: remote ?? this.remote,
    deadline: identical(deadline, _keep)
        ? this.deadline
        : deadline as Deadline?,
    trust: identical(trust, _keep) ? this.trust : trust as OpportunityTrust?,
    sort: sort ?? this.sort,
  );

  /// The filter sheet's own groups cleared, keeping the category and the sort.
  OpportunityFilters cleared() =>
      OpportunityFilters(type: type, q: q, sort: sort);

  static const _keep = Object();

  @override
  bool operator ==(Object other) =>
      other is OpportunityFilters &&
      other.type == type &&
      other.q == q &&
      other.disciplineId == disciplineId &&
      other.countyId == countyId &&
      other.remote == remote &&
      other.deadline == deadline &&
      other.trust == trust &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(
    type,
    q,
    disciplineId,
    countyId,
    remote,
    deadline,
    trust,
    sort,
  );
}

/// The tabs of the member's own list (the API calls the same values `tab`; its generated enum clashes with
/// Flutter's `Tab` widget, so screens use this).
enum MyTab { all, closing, applied, completed, saved }

/// One page of opportunities with how many there are in all.
class OpportunityPage {
  const OpportunityPage(this.items, this.total);
  final List<OpportunityCardDto> items;
  final int total;
}

/// One page of the member's own list, with the tab counts.
class MyOpportunityPage {
  const MyOpportunityPage(this.items, this.total, this.counts);
  final List<MyOpportunityDto> items;
  final int total;
  final MyOpportunityCounts counts;
}

class MyOpportunityCounts {
  const MyOpportunityCounts({
    this.all = 0,
    this.closing = 0,
    this.applied = 0,
    this.completed = 0,
    this.saved = 0,
  });

  final int all;
  final int closing;
  final int applied;
  final int completed;
  final int saved;

  factory MyOpportunityCounts.fromMeta(dynamic meta) {
    final c = meta is Map ? meta['counts'] : null;
    int n(String k) => c is Map && c[k] is num ? (c[k] as num).toInt() : 0;
    return MyOpportunityCounts(
      all: n('all'),
      closing: n('closing'),
      applied: n('applied'),
      completed: n('completed'),
      saved: n('saved'),
    );
  }
}

int _total(dynamic meta, int fallback) {
  if (meta is Map && meta['total'] is num) {
    return (meta['total'] as num).toInt();
  }
  return fallback;
}

/// Opportunities: discovery, the profile check, saving and tracking, with errors mapped to typed failures.
/// Widgets go through providers; tests replace this with an in-memory fake.
class OpportunitiesRepository {
  OpportunitiesRepository({required this._api, this._cache});

  final AtarahApiClient _api;

  /// Where the saved list is kept for reading offline (null in tests that do not need it).
  final OfflineCache? _cache;

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on Object catch (e) {
      throw mapError(e);
    }
  }

  Future<OpportunitiesHomeDto> home() =>
      _guard(() async => (await _api.opportunities.home()).data);

  Future<OpportunityPage> list(
    OpportunityFilters f, {
    int page = 1,
    int limit = 20,
  }) => _guard(() async {
    final res = await _api.opportunities.list(
      type: f.type,
      q: f.q,
      disciplineId: f.disciplineId,
      countyId: f.countyId,
      remote: f.remote ? true : null,
      deadline: f.deadline,
      trust: f.trust,
      sort: f.sort,
      page: page,
      limit: limit,
    );
    return OpportunityPage(res.data, _total(res.meta, res.data.length));
  });

  /// [refresh] skips the server's 5 minute cache of the profile check (after the member edited their profile).
  Future<OpportunityDto> detail(String id, {bool refresh = false}) => _guard(
    () async => (await _api.opportunities.detail(
      id: id,
      refresh: refresh ? true : null,
    )).data,
  );

  Future<TrackingStateDto> save(String id) =>
      _guard(() async => (await _api.opportunities.save(id: id)).data);

  Future<void> unsave(String id) =>
      _guard(() => _api.opportunities.unsave(id: id));

  Future<TrackingStateDto> track(
    String id,
    OpportunityTrackingStatus status, {
    OpportunityOutcome? outcome,
  }) => _guard(
    () async => (await _api.opportunities.track(
      id: id,
      body: TrackOpportunityDto(status: status, outcome: outcome),
    )).data,
  );

  Future<MyOpportunityPage> mine(MyTab tab, {int page = 1, int limit = 20}) =>
      _guard(() async {
        final res = await _api.opportunities.mine(
          tab: switch (tab) {
            MyTab.all => Tab.all,
            MyTab.closing => Tab.closing,
            MyTab.applied => Tab.applied,
            MyTab.completed => Tab.completed,
            MyTab.saved => Tab.saved,
          },
          page: page,
          limit: limit,
        );
        final result = MyOpportunityPage(
          res.data,
          _total(res.meta, res.data.length),
          MyOpportunityCounts.fromMeta(res.meta),
        );
        // The first page of the saved list is kept for reading offline.
        if (tab == MyTab.saved && page == 1) {
          await _cache?.write('saved-opportunities', {
            'total': result.total,
            'items': [for (final i in result.items) i.toJson()],
          });
        }
        return result;
      }).catchError((Object e) async {
        // Offline: the saved list the member last saw, read-only.
        if (e is NetworkFailure && tab == MyTab.saved && page == 1) {
          final saved = await _cache?.read('saved-opportunities');
          if (saved is Map<String, Object?> && saved['items'] is List) {
            final items = [
              for (final j in saved['items'] as List)
                MyOpportunityDto.fromJson((j as Map).cast<String, Object?>()),
            ];
            return MyOpportunityPage(
              items,
              (saved['total'] as num?)?.toInt() ?? items.length,
              MyOpportunityCounts(saved: items.length),
            );
          }
        }
        throw e;
      });
}
