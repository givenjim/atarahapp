import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import 'portfolio_repository.dart';

/// What the member wants to add to a project.
enum MediaPickKind { photos, video, audio }

/// Lets the member choose files for a project. A seam so tests do not need the platform.
abstract class MediaPicker {
  /// The chosen files, or an empty list when the member cancelled. [limit] caps how many.
  Future<List<PickedMedia>> pick(MediaPickKind kind, {required int limit});
}

class DeviceMediaPicker implements MediaPicker {
  DeviceMediaPicker({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const _mimeByExtension = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
    'mp4': 'video/mp4',
    'mov': 'video/quicktime',
    'webm': 'video/webm',
    'mp3': 'audio/mpeg',
    'm4a': 'audio/mp4',
    'wav': 'audio/wav',
    'ogg': 'audio/ogg',
  };

  @override
  Future<List<PickedMedia>> pick(
    MediaPickKind kind, {
    required int limit,
  }) async {
    if (limit <= 0) return const [];
    switch (kind) {
      case MediaPickKind.photos:
        final files = await _picker.pickMultiImage(
          // Bounded so a 10 MB limit is not hit by a phone camera's full-size photo.
          maxWidth: 2400,
          maxHeight: 2400,
          imageQuality: 88,
          limit: limit < 2 ? null : limit,
        );
        return [for (final f in files.take(limit)) await _fromXFile(f)];
      case MediaPickKind.video:
        final f = await _picker.pickVideo(source: ImageSource.gallery);
        return f == null ? const [] : [await _fromXFile(f)];
      case MediaPickKind.audio:
        final files = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: const ['mp3', 'm4a', 'wav', 'ogg'],
        );
        final picked = files.firstOrNull;
        final path = picked?.path;
        if (picked == null || path == null) return const [];
        return [
          PickedMedia(
            path: path,
            name: picked.name,
            mimeType: _mimeOf(picked.name) ?? 'audio/mpeg',
            sizeBytes: await File(path).length(),
          ),
        ];
    }
  }

  Future<PickedMedia> _fromXFile(XFile f) async => PickedMedia(
    path: f.path,
    name: f.name,
    mimeType: f.mimeType ?? _mimeOf(f.name) ?? 'application/octet-stream',
    sizeBytes: await File(f.path).length(),
  );

  String? _mimeOf(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0) return null;
    return _mimeByExtension[name.substring(dot + 1).toLowerCase()];
  }
}

/// How a project's video, audio and embedded player are drawn. Seams so widget tests do not start platform
/// players.
typedef MediaViewBuilder = Widget Function(BuildContext context, String url);

Widget deviceVideoView(BuildContext context, String url) =>
    NetworkMediaPlayer(url: url, audioOnly: false);

Widget deviceAudioView(BuildContext context, String url) =>
    NetworkMediaPlayer(url: url, audioOnly: true);

Widget deviceEmbedView(BuildContext context, String url) =>
    EmbeddedPlayer(url: url);

/// Plays a video or an audio file from a signed address, with play and pause, a scrubber and the time.
class NetworkMediaPlayer extends StatefulWidget {
  const NetworkMediaPlayer({
    super.key,
    required this.url,
    required this.audioOnly,
  });

  final String url;
  final bool audioOnly;

  @override
  State<NetworkMediaPlayer> createState() => _NetworkMediaPlayerState();
}

class _NetworkMediaPlayerState extends State<NetworkMediaPlayer> {
  late final VideoPlayerController _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller.initialize().then(
      (_) {
        if (mounted) setState(() {});
      },
      onError: (Object _) {
        if (mounted) setState(() => _failed = true);
      },
    );
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
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
      return _PlayerFrame(
        child: Text(
          l10n.pjMediaFailed,
          style: AtTextStyles.bodySm.copyWith(color: AtColors.white),
        ),
      );
    }
    final v = _controller.value;
    if (!v.isInitialized) {
      return const _PlayerFrame(child: CircularProgressIndicator());
    }
    final total = v.duration.inMilliseconds;
    final position = v.position.inMilliseconds.clamp(0, total > 0 ? total : 1);
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AtColors.ink,
        borderRadius: AtRadii.card,
      ),
      child: ClipRRect(
        borderRadius: AtRadii.card,
        child: Column(
          children: [
            if (!widget.audioOnly)
              AspectRatio(
                aspectRatio: v.aspectRatio == 0 ? 16 / 9 : v.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
              child: Row(
                children: [
                  AtIconButton(
                    icon: v.isPlaying ? LucideIcons.pause : LucideIcons.play,
                    semanticLabel: v.isPlaying ? l10n.pjPause : l10n.pjPlay,
                    variant: AtIconButtonVariant.glass,
                    onPressed: () =>
                        v.isPlaying ? _controller.pause() : _controller.play(),
                  ),
                  Expanded(
                    child: Slider(
                      value: position.toDouble(),
                      max: (total > 0 ? total : 1).toDouble(),
                      onChanged: (x) =>
                          _controller.seekTo(Duration(milliseconds: x.round())),
                    ),
                  ),
                  Text(
                    _clock(v.position),
                    style: AtTextStyles.meta.copyWith(color: AtColors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerFrame extends StatelessWidget {
  const _PlayerFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 16 / 9,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        color: AtColors.ink,
        borderRadius: AtRadii.card,
      ),
      child: Center(child: child),
    ),
  );
}

/// A YouTube or Vimeo player inside the page. Only addresses the server marked as embeddable reach this.
class EmbeddedPlayer extends StatefulWidget {
  const EmbeddedPlayer({super.key, required this.url});

  final String url;

  @override
  State<EmbeddedPlayer> createState() => _EmbeddedPlayerState();
}

class _EmbeddedPlayerState extends State<EmbeddedPlayer> {
  late final WebViewController _web = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    // The player stays on its own address: nothing it links to opens in here.
    ..setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (request) =>
            request.url == widget.url ||
                request.url.startsWith('https://www.youtube-nocookie.com/') ||
                request.url.startsWith('https://player.vimeo.com/')
            ? NavigationDecision.navigate
            : NavigationDecision.prevent,
      ),
    )
    ..loadRequest(Uri.parse(widget.url));

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 16 / 9,
    child: ClipRRect(
      borderRadius: AtRadii.card,
      child: WebViewWidget(controller: _web),
    ),
  );
}
