import 'package:home_repair_app/config/app_config.dart';
import 'package:home_repair_app/main_common.dart';
import 'package:home_repair_app/flavors.dart';

// Default main entry point - uses flavor detection
void main() async {
  // Set the flavor from Flutter's appFlavor
  const flavorName = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  // Map flavor string to Flavor enum
  switch (flavorName) {
    case 'production':
      F.appFlavor = Flavor.production;
      break;
    case 'stg':
      F.appFlavor = Flavor.stg;
      break;
    case 'uat':
      F.appFlavor = Flavor.uat;
      break;
    case 'dev':
    default:
      F.appFlavor = Flavor.dev;
      break;
  }

  // Map Flavor to Environment
  final environment = (F.appFlavor == Flavor.production)
      ? Environment.prod
      : Environment.dev;

  final config = AppConfig(
    environment: environment,
    appTitle: F.title,
    enableLogs: F.appFlavor != Flavor.production,
  );

  await mainCommon(config);
}
