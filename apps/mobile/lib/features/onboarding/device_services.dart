import 'dart:typed_data';

import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

/// Why the phone could not tell us where the member is.
enum LocationProblem {
  permissionDenied,
  permissionDeniedForever,
  servicesOff,
  unavailable,
}

class LocationLookupException implements Exception {
  const LocationLookupException(this.problem);

  final LocationProblem problem;

  @override
  String toString() => 'LocationLookupException($problem)';
}

/// Works out the place name (county or city) from the phone's location, after asking permission.
/// The name is only used to pick a county from our list; coordinates never leave the device.
abstract class LocationLookup {
  /// Candidate place names, most specific administrative area first (for example `Nairobi County`).
  /// Throws [LocationLookupException].
  Future<List<String>> placeNames();
}

/// The real thing: Android's and iOS's own location and geocoder services (no API key, no third party).
class DeviceLocationLookup implements LocationLookup {
  const DeviceLocationLookup();

  @override
  Future<List<String>> placeNames() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationLookupException(LocationProblem.servicesOff);
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    switch (permission) {
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        throw const LocationLookupException(LocationProblem.permissionDenied);
      case LocationPermission.deniedForever:
        throw const LocationLookupException(
          LocationProblem.permissionDeniedForever,
        );
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        break;
    }
    try {
      // County level is all we need, so ask for the cheapest accuracy.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 12),
        ),
      );
      final marks = await geo.Geocoding().placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final names = <String>[];
      for (final m in marks) {
        for (final n in [
          m.administrativeArea,
          m.subAdministrativeArea,
          m.locality,
        ]) {
          if (n != null && n.trim().isNotEmpty && !names.contains(n)) {
            names.add(n);
          }
        }
      }
      return names;
    } on Object {
      throw const LocationLookupException(LocationProblem.unavailable);
    }
  }
}

/// Lets the member choose a profile photo from the gallery or the camera.
abstract class PhotoPicker {
  /// Returns the picked image, or null when the member cancelled.
  Future<Uint8List?> pick({required bool camera});
}

class DevicePhotoPicker implements PhotoPicker {
  DevicePhotoPicker({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<Uint8List?> pick({required bool camera}) async {
    final file = await _picker.pickImage(
      source: camera ? ImageSource.camera : ImageSource.gallery,
      // Bounded before cropping so the upload stays well under the 10 MB limit.
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 88,
    );
    return file?.readAsBytes();
  }
}
