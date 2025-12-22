import 'package:home_repair_app/config/app_config.dart';
import 'package:home_repair_app/main_common.dart';
import 'package:home_repair_app/flavors.dart';

void main() async {
  F.appFlavor = Flavor.production;

  final config = AppConfig(
    environment: Environment.prod,
    appTitle: F.title,
    enableLogs: false,
  );

  await mainCommon(config);
}
