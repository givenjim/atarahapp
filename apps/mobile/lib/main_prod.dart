import 'core/app/bootstrap.dart';
import 'core/config/app_config.dart';

/// Prod flavour entry point: flutter run --flavor prod -t lib/main_prod.dart
void main() => bootstrap(Flavor.prod);
