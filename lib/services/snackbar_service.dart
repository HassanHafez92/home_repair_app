import 'package:flutter/material.dart';

class SnackBarService {
  static final SnackBarService _instance = SnackBarService._internal();

  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  SnackBarService._internal();

  factory SnackBarService() {
    return _instance;
  }

  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: duration,
      action: action,
    );
    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  void showErrorSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: duration,
    );
    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  void showSuccessSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
      duration: duration,
    );
    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }
}
