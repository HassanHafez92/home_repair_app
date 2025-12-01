import 'package:home_repair_app/config/app_config.dart';
import 'package:home_repair_app/main_common.dart';

void main() async {
  final config = AppConfig(
    environment: Environment.prod,
    appTitle: 'Home Repair',
    enableLogs: false,
  );

  await mainCommon(config);
}
