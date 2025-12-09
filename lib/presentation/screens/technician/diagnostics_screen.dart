// File: lib/screens/technician/diagnostics_screen.dart
// Purpose: In-app diagnostics and troubleshooting helper

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:home_repair_app/services/auth_service.dart';

class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  bool _isRunningTests = false;
  Map<String, DiagnosticResult> _results = {};

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isRunningTests = true;
      _results = {};
    });

    // Run all diagnostic tests
    await Future.wait([
      _testAuthentication(),
      _testNetworkConnectivity(),
      _testFirestoreConnection(),
      _testAppVersion(),
    ]);

    setState(() => _isRunningTests = false);
  }

  Future<void> _testAuthentication() async {
    try {
      final authService = context.read<AuthService>();
      final user = authService.currentUser;

      if (user == null) {
        _addResult(
          'authentication',
          DiagnosticResult.warning(
            'Not logged in',
            'You are not currently signed in',
          ),
        );
        return;
      }

      if (!user.emailVerified) {
        _addResult(
          'authentication',
          DiagnosticResult.warning(
            'Email not verified',
            'Please verify your email address',
          ),
        );
        return;
      }

      _addResult(
        'authentication',
        DiagnosticResult.success(
          'Authentication OK',
          'Logged in as ${user.email}',
        ),
      );
    } catch (e) {
      _addResult(
        'authentication',
        DiagnosticResult.error('Authentication Error', e.toString()),
      );
    }
  }

  Future<void> _testNetworkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.none)) {
        _addResult(
          'network',
          DiagnosticResult.error(
            'No Internet',
            'Device is not connected to the internet',
          ),
        );
        return;
      }

      final connectionType =
          connectivityResult.contains(ConnectivityResult.wifi)
          ? 'WiFi'
          : connectivityResult.contains(ConnectivityResult.mobile)
          ? 'Mobile Data'
          : 'Unknown';

      _addResult(
        'network',
        DiagnosticResult.success(
          'Network Connected',
          'Connected via $connectionType',
        ),
      );
    } catch (e) {
      _addResult(
        'network',
        DiagnosticResult.error('Network Check Failed', e.toString()),
      );
    }
  }

  Future<void> _testFirestoreConnection() async {
    try {
      // Try to fetch a document to test Firestore connectivity
      await FirebaseFirestore.instance
          .collection('services')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 5));

      _addResult(
        'firestore',
        DiagnosticResult.success(
          'Firestore Connected',
          'Successfully connected to database',
        ),
      );
    } catch (e) {
      _addResult(
        'firestore',
        DiagnosticResult.error(
          'Firestore Connection Failed',
          'Could not connect to database: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _testAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final version = packageInfo.version;
      final buildNumber = packageInfo.buildNumber;

      _addResult(
        'version',
        DiagnosticResult.info(
          'App Version',
          'Version $version (Build $buildNumber)',
        ),
      );
    } catch (e) {
      _addResult(
        'version',
        DiagnosticResult.warning('Version Check Failed', e.toString()),
      );
    }
  }

  void _addResult(String key, DiagnosticResult result) {
    setState(() {
      _results[key] = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('diagnostics'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRunningTests ? null : _runDiagnostics,
            tooltip: 'runTests'.tr(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'diagnosticsIntro'.tr(),
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 16),

          if (_isRunningTests)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Running diagnostics...'),
                  ],
                ),
              ),
            ),

          if (!_isRunningTests && _results.isNotEmpty) ...[
            _buildResultCard(
              'authentication',
              'authenticationStatus'.tr(),
              Icons.person_outline,
            ),
            _buildResultCard('network', 'networkStatus'.tr(), Icons.wifi),
            _buildResultCard('firestore', 'databaseStatus'.tr(), Icons.storage),
            _buildResultCard('version', 'appVersion'.tr(), Icons.info_outline),
            const SizedBox(height: 24),
            _buildSummary(),
          ],
        ],
      ),
    );
  }

  Widget _buildResultCard(String key, String title, IconData icon) {
    final result = _results[key];
    if (result == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: result.color, size: 32),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              result.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: result.color,
              ),
            ),
            if (result.message.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(result.message, style: const TextStyle(fontSize: 12)),
            ],
          ],
        ),
        trailing: Icon(result.icon, color: result.color),
      ),
    );
  }

  Widget _buildSummary() {
    final hasErrors = _results.values.any(
      (r) => r.status == DiagnosticStatus.error,
    );
    final hasWarnings = _results.values.any(
      (r) => r.status == DiagnosticStatus.warning,
    );

    String summaryText;
    Color summaryColor;

    if (hasErrors) {
      summaryText = 'issuesDetected'.tr();
      summaryColor = Colors.red;
    } else if (hasWarnings) {
      summaryText = 'warningsDetected'.tr();
      summaryColor = Colors.orange;
    } else {
      summaryText = 'allSystemsNormal'.tr();
      summaryColor = Colors.green;
    }

    return Card(
      color: summaryColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasErrors
                      ? Icons.error
                      : hasWarnings
                      ? Icons.warning
                      : Icons.check_circle,
                  color: summaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  summaryText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: summaryColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            if (hasErrors || hasWarnings) ...[
              const SizedBox(height: 12),
              Text(
                'contactSupportIfIssuesPersist'.tr(),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  // Navigate to support screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('supportContactInfo'.tr())),
                  );
                },
                icon: const Icon(Icons.support_agent),
                label: Text('contactSupport'.tr()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Diagnostic result model
enum DiagnosticStatus { success, warning, error, info }

class DiagnosticResult {
  final DiagnosticStatus status;
  final String title;
  final String message;

  DiagnosticResult({
    required this.status,
    required this.title,
    required this.message,
  });

  factory DiagnosticResult.success(String title, String message) {
    return DiagnosticResult(
      status: DiagnosticStatus.success,
      title: title,
      message: message,
    );
  }

  factory DiagnosticResult.warning(String title, String message) {
    return DiagnosticResult(
      status: DiagnosticStatus.warning,
      title: title,
      message: message,
    );
  }

  factory DiagnosticResult.error(String title, String message) {
    return DiagnosticResult(
      status: DiagnosticStatus.error,
      title: title,
      message: message,
    );
  }

  factory DiagnosticResult.info(String title, String message) {
    return DiagnosticResult(
      status: DiagnosticStatus.info,
      title: title,
      message: message,
    );
  }

  Color get color {
    switch (status) {
      case DiagnosticStatus.success:
        return Colors.green;
      case DiagnosticStatus.warning:
        return Colors.orange;
      case DiagnosticStatus.error:
        return Colors.red;
      case DiagnosticStatus.info:
        return Colors.blue;
    }
  }

  IconData get icon {
    switch (status) {
      case DiagnosticStatus.success:
        return Icons.check_circle;
      case DiagnosticStatus.warning:
        return Icons.warning;
      case DiagnosticStatus.error:
        return Icons.error;
      case DiagnosticStatus.info:
        return Icons.info;
    }
  }
}



