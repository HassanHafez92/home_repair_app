import 'package:home_repair_app/config/app_config.dart';
import 'package:home_repair_app/main_common.dart';
import 'package:home_repair_app/flavors.dart';

void main() async {
  F.appFlavor = Flavor.uat;

  final config = AppConfig(
    environment: Environment.dev, // UAT uses dev-like settings
    appTitle: F.title,
    enableLogs: true,
  );

  await mainCommon(config);
}
