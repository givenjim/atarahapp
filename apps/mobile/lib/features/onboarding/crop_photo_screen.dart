import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';

import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';

/// A cropped square photo ready to upload.
class CroppedPhoto {
  const CroppedPhoto({required this.bytes, required this.mimeType});

  final Uint8List bytes;

  /// `image/jpeg` or `image/png`.
  final String mimeType;
}

/// Opens the crop screen for [source] and returns the result, or null when the member cancels.
/// A function so tests can replace the cropper (it needs real image decoding).
typedef PhotoCropper = Future<CroppedPhoto?> Function(
  BuildContext context,
  Uint8List source,
);

Future<CroppedPhoto?> openCropScreen(BuildContext context, Uint8List source) {
  return Navigator.of(context).push<CroppedPhoto>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => CropPhotoScreen(source: source),
    ),
  );
}

String _mimeOf(Uint8List b) {
  if (b.length > 3 && b[0] == 0xFF && b[1] == 0xD8) return 'image/jpeg';
  return 'image/png';
}

/// Square crop with a circular guide, as the profile photo is shown in a circle everywhere.
class CropPhotoScreen extends StatefulWidget {
  const CropPhotoScreen({super.key, required this.source});

  final Uint8List source;

  @override
  State<CropPhotoScreen> createState() => _CropPhotoScreenState();
}

class _CropPhotoScreenState extends State<CropPhotoScreen> {
  final _controller = CropController();
  bool _cropping = false;
  bool _failed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AtColors.ink,
      appBar: AppBar(
        backgroundColor: AtColors.ink,
        foregroundColor: AtColors.white,
        title: Text(l10n.obCropTitle),
        leading: IconButton(
          tooltip: l10n.obCropCancel,
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Crop(
                image: widget.source,
                controller: _controller,
                withCircleUi: true,
                interactive: true,
                baseColor: AtColors.ink,
                maskColor: const Color.fromRGBO(21, 19, 61, 0.7),
                progressIndicator: const CircularProgressIndicator(),
                onCropped: (result) {
                  switch (result) {
                    case CropSuccess(:final croppedImage):
                      Navigator.of(context).pop(
                        CroppedPhoto(
                          bytes: croppedImage,
                          mimeType: _mimeOf(croppedImage),
                        ),
                      );
                    case CropFailure():
                      setState(() {
                        _cropping = false;
                        _failed = true;
                      });
                  }
                },
              ),
            ),
            if (_failed)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AtSpacing.gutter,
                ),
                child: AtInlineBanner(message: l10n.obPhotoPickFailed),
              ),
            Padding(
              padding: const EdgeInsets.all(AtSpacing.gutter),
              child: AtButton(
                label: l10n.obCropUse,
                loading: _cropping,
                onPressed: _cropping
                    ? null
                    : () {
                        setState(() {
                          _cropping = true;
                          _failed = false;
                        });
                        _controller.crop();
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
