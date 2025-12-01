import 'package:home_repair_app/config/app_config.dart';
import 'package:home_repair_app/main_common.dart';

void main() async {
  final config = AppConfig(
    environment: Environment.dev,
    appTitle: 'Home Repair (Dev)',
    enableLogs: true,
  );

  await mainCommon(config);
}
