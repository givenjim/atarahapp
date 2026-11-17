import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';

/// Why the player is reporting where it is. Playback ticks are throttled by the [ProgressReporter]; the rest
/// (pausing, finishing, leaving) are written at once.
enum PositionReason { tick, pause, ended, exit }

/// Everything a lesson video player needs from the screen.
class LessonVideoArgs {
  const LessonVideoArgs({
    required this.url,
    required this.posterUrl,
    required this.startAt,
    required this.onPosition,
    required this.onFailed,
  });

  /// The signed address of the MP4.
  final String url;
  final String? posterUrl;

  /// Where to resume from.
  final Duration startAt;

  /// Called with the current position in whole seconds.
  final void Function(int seconds, PositionReason reason) onPosition;
  final VoidCallback onFailed;
}

/// How a lesson's own video is drawn. A seam so widget tests do not start a platform player.
typedef LessonVideoBuilder = Widget Function(
  BuildContext context,
  LessonVideoArgs args,
);

/// How a lesson's embedded player is drawn. [onFailed] is called when the page cannot load, so the screen can say
/// so ("YouTube isn't responding").
typedef LessonEmbedBuilder = Widget Function(
  BuildContext context, {
  required String url,
  required VoidCallback onFailed,
});

final lessonVideoBuilderProvider = Provider<LessonVideoBuilder>(
  (ref) =>
      (context, args) => DeviceLessonVideo(args: args),
);

final lessonEmbedBuilderProvider = Provider<LessonEmbedBuilder>(
  (ref) =>
      (context, {required url, required onFailed}) =>
          DeviceLessonEmbed(url: url, onFailed: onFailed),
);

/// The services a member may see named when their player does not answer. Anything else is "The video".
String embedServiceName(String url, {required String fallback}) {
  final host = Uri.tryParse(url)?.host ?? '';
  if (host.contains('youtube')) return 'YouTube';
  if (host.contains('vimeo')) return 'Vimeo';
  return fallback;
}

/// Sends progress to the server at a steady pace: a tick at most every [interval] while playing, and every pause,
/// finish or exit straight away. The position it sends never goes backwards (the server enforces the same rule; this
/// just avoids pointless writes). Time comes from [now] so tests can drive it.
class ProgressReporter {
  ProgressReporter({
    required this.send,
    DateTime Function()? now,
    this.interval = const Duration(seconds: 15),
    int startAt = 0,
  }) : _now = now ?? DateTime.now,
       _best = startAt,
       _lastSent = startAt;

  final Future<void> Function(int seconds) send;
  final Duration interval;
  final DateTime Function() _now;

  int _best;
  int? _lastSent;
  DateTime? _lastSentAt;

  /// The furthest position seen so far.
  int get best => _best;

  /// Takes a position from the player. Returns the future of the write when one was started.
  Future<void>? report(int seconds, PositionReason reason) {
    if (seconds > _best) _best = seconds;
    final due = switch (reason) {
      PositionReason.tick =>
        _lastSentAt == null || _now().difference(_lastSentAt!) >= interval,
      _ => true,
    };
    if (!due || _best == _lastSent) return null;
    _lastSent = _best;
    _lastSentAt = _now();
    return send(_best);
  }
}

/// Plays a lesson's video from a signed address: play and pause, a scrubber, resume from the saved position, and
/// position reports through [LessonVideoArgs.onPosition].
class DeviceLessonVideo extends StatefulWidget {
  const DeviceLessonVideo({super.key, required this.args});

  final LessonVideoArgs args;

  @override
  State<DeviceLessonVideo> createState() => _DeviceLessonVideoState();
}

class _DeviceLessonVideoState extends State<DeviceLessonVideo>
    with WidgetsBindingObserver {
  late final VideoPlayerController _c;
  bool _ready = false;
  bool _failed = false;
  bool _wasPlaying = false;
  bool _ended = false;

  int get _seconds => _c.value.position.inSeconds;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _c = VideoPlayerController.networkUrl(Uri.parse(widget.args.url));
    _c.addListener(_onChange);
    _c.initialize().then(
      (_) async {
        if (!mounted) return;
        if (widget.args.startAt > Duration.zero) {
          await _c.seekTo(widget.args.startAt);
        }
        if (mounted) setState(() => _ready = true);
      },
      onError: (Object _) {
        if (!mounted) return;
        setState(() => _failed = true);
        widget.args.onFailed();
      },
    );
  }

  void _onChange() {
    if (!mounted) return;
    final v = _c.value;
    if (v.hasError && !_failed) {
      setState(() => _failed = true);
      widget.args.onFailed();
      return;
    }
    if (v.isPlaying) {
      widget.args.onPosition(_seconds, PositionReason.tick);
    } else if (_wasPlaying) {
      final finished =
          v.duration > Duration.zero && v.position >= v.duration && !_ended;
      if (finished) {
        _ended = true;
        widget.args.onPosition(_seconds, PositionReason.ended);
      } else {
        widget.args.onPosition(_seconds, PositionReason.pause);
      }
    }
    _wasPlaying = v.isPlaying;
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _ready) {
      widget.args.onPosition(_seconds, PositionReason.pause);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_ready) widget.args.onPosition(_seconds, PositionReason.exit);
    _c.removeListener(_onChange);
    _c.dispose();
    super.dispose();
  }

  String _clock(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_failed) {
      return _Frame(
        child: Text(
          l10n.lnVideoLoadFailed,
          textAlign: TextAlign.center,
          style: AtTextStyles.bodySm.copyWith(color: context.at.white),
        ),
      );
    }
    if (!_ready) {
      return const _Frame(child: CircularProgressIndicator());
    }
    final v = _c.value;
    final total = v.duration.inMilliseconds;
    final position = v.position.inMilliseconds.clamp(0, total > 0 ? total : 1);
    return Semantics(
      container: true,
      label: l10n.lnVideoSemantic,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.at.ink,
          borderRadius: AtRadii.card,
        ),
        child: ClipRRect(
          borderRadius: AtRadii.card,
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: v.aspectRatio == 0 ? 16 / 9 : v.aspectRatio,
                child: VideoPlayer(_c),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
                child: Row(
                  children: [
                    AtIconButton(
                      icon: v.isPlaying ? LucideIcons.pause : LucideIcons.play,
                      semanticLabel: v.isPlaying ? l10n.pjPause : l10n.pjPlay,
                      variant: AtIconButtonVariant.glass,
                      onPressed: () => v.isPlaying ? _c.pause() : _c.play(),
                    ),
                    Expanded(
                      child: Slider(
                        value: position.toDouble(),
                        max: (total > 0 ? total : 1).toDouble(),
                        onChanged: (x) =>
                            _c.seekTo(Duration(milliseconds: x.round())),
                      ),
                    ),
                    Text(
                      '${_clock(v.position)} / ${_clock(v.duration)}',
                      style: AtTextStyles.metaSm.copyWith(
                        color: context.at.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 16 / 9,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: context.at.ink,
        borderRadius: AtRadii.card,
      ),
      child: Center(child: child),
    ),
  );
}

/// An embedded player (YouTube or Vimeo, on the server's allow-list). The page stays on the player's own host:
/// anything it links to is refused. A page that does not load within [timeout] counts as failed.
class DeviceLessonEmbed extends StatefulWidget {
  const DeviceLessonEmbed({
    super.key,
    required this.url,
    required this.onFailed,
    this.timeout = const Duration(seconds: 20),
  });

  final String url;
  final VoidCallback onFailed;
  final Duration timeout;

  @override
  State<DeviceLessonEmbed> createState() => _DeviceLessonEmbedState();
}

class _DeviceLessonEmbedState extends State<DeviceLessonEmbed> {
  late final WebViewController _web;
  Timer? _timer;
  bool _loaded = false;
  bool _failed = false;

  void _fail() {
    if (_failed || _loaded) return;
    _failed = true;
    widget.onFailed();
  }

  @override
  void initState() {
    super.initState();
    final host = Uri.tryParse(widget.url)?.host;
    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final h = Uri.tryParse(request.url)?.host;
            return request.url == widget.url || (host != null && h == host)
                ? NavigationDecision.navigate
                : NavigationDecision.prevent;
          },
          onPageFinished: (_) => _loaded = true,
          onWebResourceError: (e) {
            if (e.isForMainFrame ?? true) _fail();
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    _timer = Timer(widget.timeout, _fail);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 16 / 9,
    child: ClipRRect(
      borderRadius: AtRadii.card,
      child: WebViewWidget(controller: _web),
    ),
  );
}
