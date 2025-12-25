// File: lib/firebase_config.dart
// Purpose: Handles Firebase initialization and configuration for different platforms.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  // Firebase initialization is now handled in main.dart
  // Do not call Firebase.initializeApp() here to avoid duplicate app initialization
}

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDSiF5OtgJK9hNb2XtbYDN2rt-_rpdXM9g',
    appId: '1:970866219192:android:679780d0064f07e9d03c4d',
    messagingSenderId: '970866219192',
    projectId: 'home-rapier-app-479514',
    storageBucket: 'home-rapier-app-479514.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD_i-4R01ONjc5dY1b6kfUdqaeM5bVm4S4',
    appId: '1:970866219192:ios:e278504fe7df4b1bd03c4d',
    messagingSenderId: '970866219192',
    projectId: 'home-rapier-app-479514',
    storageBucket: 'home-rapier-app-479514.firebasestorage.app',
    iosClientId:
        '970866219192-1c47a8muciu8ap2v92tehv12lbckj86d.apps.googleusercontent.com',
    iosBundleId: 'com.example.homeRepairApp',
  );
}
