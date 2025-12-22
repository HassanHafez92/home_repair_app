import 'package:home_repair_app/config/app_config.dart';
import 'package:home_repair_app/main_common.dart';
import 'package:home_repair_app/flavors.dart';

void main() async {
  F.appFlavor = Flavor.stg;

  final config = AppConfig(
    environment: Environment.dev, // STG uses dev-like settings
    appTitle: F.title,
    enableLogs: true,
  );

  await mainCommon(config);
}
