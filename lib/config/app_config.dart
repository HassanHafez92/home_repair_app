enum Environment { dev, prod }

class AppConfig {
  final Environment environment;
  final String appTitle;
  final String apiBaseUrl; // Example of an env-specific variable
  final bool enableLogs;

  AppConfig({
    required this.environment,
    required this.appTitle,
    this.apiBaseUrl = '',
    this.enableLogs = true,
  });

  bool get isDev => environment == Environment.dev;
  bool get isProd => environment == Environment.prod;
}
