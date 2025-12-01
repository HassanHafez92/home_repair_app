import 'package:home_repair_app/config/app_config.dart';
import 'package:home_repair_app/main_common.dart';

// Default to Dev environment if run directly
void main() async {
  final config = AppConfig(
    environment: Environment.dev,
    appTitle: 'Home Repair (Dev)',
    enableLogs: true,
  );

  await mainCommon(config);
}
