// Network information interface and implementation for Clean Architecture.
//
// Provides abstraction over network connectivity checks, enabling
// offline-first patterns in repository implementations.

import 'package:connectivity_plus/connectivity_plus.dart';

/// Interface for checking network connectivity.
///
/// This abstraction allows repositories to check network status
/// before making remote calls and enables easy mocking in tests.
abstract class INetworkInfo {
  /// Whether the device is currently connected to a network.
  ///
  /// Returns `true` if connected to WiFi, mobile data, ethernet, or VPN.
  /// Returns `false` if offline or connectivity status cannot be determined.
  Future<bool> get isConnected;

  /// Stream of connectivity status changes.
  ///
  /// Emits `true` when connection is established, `false` when lost.
  Stream<bool> get onConnectivityChanged;
}

/// Implementation of [INetworkInfo] using connectivity_plus package.
class NetworkInfo implements INetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return _hasConnection(results);
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_hasConnection);
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    // Check if any of the results indicate a connection
    for (final result in results) {
      if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.vpn) {
        return true;
      }
    }
    return false;
  }
}
