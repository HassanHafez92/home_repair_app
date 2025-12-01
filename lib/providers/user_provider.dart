// File: lib/providers/user_provider.dart
// Purpose: Manage current user state and profile data.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import 'dart:async';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  final AuthService _authService;
  StreamSubscription<User?>? _authSubscription;

  UserModel? _currentUser;
  bool _isLoading = false;

  UserProvider(this._firestoreService, this._authService) {
    debugPrint('UserProvider: Initialized');
    _authSubscription = _authService.authStateChanges.listen((firebaseUser) {
      loadUser(firebaseUser);
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  UserRole? get userRole => _currentUser?.role;

  Future<void> loadUser(User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('UserProvider: Loading user profile for ${firebaseUser.uid}');
      _currentUser = await _firestoreService.getUser(firebaseUser.uid);
      debugPrint('UserProvider: User profile loaded: ${_currentUser?.role}');
    } catch (e) {
      debugPrint('UserProvider: Error loading user profile: $e');
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    if (_currentUser == null) return;

    try {
      final updatedUser = await _firestoreService.getUser(_currentUser!.id);
      if (updatedUser != null) {
        _currentUser = updatedUser;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshing user: $e');
    }
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}
