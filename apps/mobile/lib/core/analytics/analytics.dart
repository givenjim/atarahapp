/// Product analytics. Features emit events through this interface so the sink can change (or be absent)
/// without touching feature code. Events carry no personal data: ids and categories only.
abstract interface class AnalyticsSink {
  void track(String event, [Map<String, Object?> properties = const {}]);
}

/// Development and test sink: records nothing.
class NoopAnalytics implements AnalyticsSink {
  const NoopAnalytics();

  @override
  void track(String event, [Map<String, Object?> properties = const {}]) {}
}

/// Collects events in memory. Used by tests to assert on emitted events.
class RecordingAnalytics implements AnalyticsSink {
  final List<({String event, Map<String, Object?> properties})> events = [];

  @override
  void track(String event, [Map<String, Object?> properties = const {}]) {
    events.add((event: event, properties: properties));
  }
}
