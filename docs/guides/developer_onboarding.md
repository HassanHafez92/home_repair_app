# Developer Onboarding Guide

Welcome to the Home Repair App project! This guide will help you set up your development environment and get the app running locally.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Environment Setup](#environment-setup)
- [Project Setup](#project-setup)
- [Firebase Configuration](#firebase-configuration)
- [Running the App](#running-the-app)
- [Development Workflow](#development-workflow)
- [Common Issues](#common-issues)
- [Next Steps](#next-steps)

---

## Prerequisites

Before starting, ensure you have the following installed:

### Required Software

| Software | Min Version | Purpose |
|----------|-------------|---------|
| **Flutter SDK** | 3.9.2+ | Cross-platform framework |
| **Dart SDK** | 3.0.0+ | Dart programming language (comes with Flutter) |
| **Git** | Latest | Version control |
| **Android Studio** | Latest | Android development & emulator |
| **Xcode** (macOS only) | 14.0+ | iOS development |
| **VS Code** (recommended) | Latest | Code editor with Flutter extension |

### Account Requirements
- **Firebase Account**: For backend services
- **Google Cloud Account**: For Google Maps API (linked to Firebase)

### Knowledge Prerequisites
- Basic Dart programming
- Understanding of Flutter widgets
- Familiarity with BLoC pattern (recommended)
- Basic Firebase knowledge (Firestore, Auth, Storage)

---

## Environment Setup

### 1. Install Flutter

**Windows:**
```powershell
# Download Flutter SDK from https://docs.flutter.dev/get-started/install/windows
# Extract to C:\src\flutter
# Add to PATH: C:\src\flutter\bin
```

**macOS:**
```bash
brew install flutter
```

**Linux:**
```bash
sudo snap install flutter --classic
```

**Verify Installation:**
```bash
flutter doctor
```

> Fix any issues reported by `flutter doctor` before proceeding.

### 2. Install IDE

**Option A: VS Code (Recommended)**
1. Download from [code.visualstudio.com](https://code.visualstudio.com/)
2. Install extensions:
   - **Flutter** (Dart-Code.flutter)
   - **Dart** (Dart-Code.dart-code)
   - **Bloc** (FelixAngelov.bloc)

**Option B: Android Studio**
1. Download from [developer.android.com/studio](https://developer.android.com/studio)
2. Install Flutter and Dart plugins

### 3. Set Up Android Environment

1. **Install Android Studio**
2. **Set up Android SDK**:
   ```bash
   flutter config --android-sdk <path-to-android-sdk>
   ```
3. **Accept Android licenses**:
   ```bash
   flutter doctor --android-licenses
   ```
4. **Create an Android Emulator**:
   - Open Android Studio > Tools > AVD Manager
   - Create a new Pixel 5 emulator with Android 13+

### 4. Set Up iOS Environment (macOS only)

1. **Install Xcode** from App Store
2. **Install Cocoapods**:
   ```bash
   sudo gem install cocoapods
   ```
3. **Accept Xcode licenses**:
   ```bash
   sudo xcodebuild -license accept
   ```
4. **Set up iOS Simulator**:
   ```bash
   open -a Simulator
   ```

---

## Project Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd home_repair_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

This will download all packages defined in `pubspec.yaml`.

### 3. Run Code Generation

Generate necessary files for JSON serialization and dependency injection:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Firebase Configuration

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **Add Project**
3. Enter project name: `home-repair-app-dev` (for development)
4. Disable Google Analytics (optional for dev)
5. Click **Create Project**

### 2. Add Android App

1. In Firebase Console, click **Add App** → **Android**
2. **Android package name**: `com.example.home_repair_app` (must match `android/app/build.gradle`)
3. Download `google-services.json`
4. Place in `android/app/google-services.json`

### 3. Add iOS App (macOS only)

1. In Firebase Console, click **Add App** → **iOS**
2. **iOS bundle ID**: `com.example.homeRepairApp` (must match Xcode project)
3. Download `GoogleService-Info.plist`
4. Place in `ios/Runner/GoogleService-Info.plist`

### 4. Enable Firebase Services

In Firebase Console:

**Authentication**:
1. Go to **Authentication** → **Sign-in method**
2. Enable **Email/Password**
3. Enable **Google Sign-In**
4. Add your development email to test users

**Firestore Database**:
1. Go to **Firestore Database** → **Create database**
2. Choose **Test mode** initially (for development)
3. Select a location (e.g., `us-central1`)
4. Deploy security rules from `firestore.rules`:
   ```bash
   firebase deploy --only firestore:rules
   ```

**Storage**:
1. Go to **Storage** → **Get started**
2. Choose **Test mode** initially
3. Deploy storage rules from `storage.rules`:
   ```bash
   firebase deploy --only storage
   ```

**Firebase CLI** (for deploying rules):
```bash
npm install -g firebase-tools
firebase login
firebase init # Select Firestore and Storage
firebase use --add # Select your project
```

### 5. Configure FlutterFire

Use FlutterFire CLI to generate configuration:

```bash
# Install FlutterFire CLI
flutter pub global activate flutterfire_cli

# Configure Firebase for all platforms
flutterfire configure
```

This will create `lib/firebase_options.dart` automatically.

### 6. Google Maps Setup

**Get API Key**:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Enable **Maps SDK for Android** and **Maps SDK for iOS**
3. Create API key

**Add to Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

**Add to iOS** (`ios/Runner/AppDelegate.swift`):
```swift
import GoogleMaps

GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
```

---

## Running the App

### 1. Check Available Devices

```bash
flutter devices
```

You should see connected devices or emulators.

### 2. Run Development Build

**Option A: Using Terminal**
```bash
# Run on first available device
flutter run

# Run on specific device
flutter run -d <device-id>

# Run with hot reload debugging
flutter run --debug
```

**Option B: Using VS Code**
1. Open `lib/main.dart`
2. Press `F5` or click **Run** → **Start Debugging**

**Option C: Using Android Studio**
1. Open project in Android Studio
2. Select device from dropdown
3. Click the **Run** button ▶️

### 3. Test Different Environments

**Development**:
```bash
flutter run lib/main_dev.dart
```

**Production**:
```bash
flutter run lib/main_prod.dart
```

### 4. First-Time Setup

1. **Register a Test User**:
   - Launch the app
   - Click **Sign Up**
   - Create an account with your test email
   
2. **Promote to Admin** (for testing admin features):
   - Go to Firebase Console → Firestore
   - Find your user document in `users` collection
   - Change `role` field to `'admin'`

3. **Add Test Service**:
   - As admin, go to **Admin Dashboard** → **Services**
   - Add a test service (e.g., "AC Repair")

---

## Development Workflow

### Project Structure Navigation

```
lib/
├── blocs/           # Business logic - start here for feature logic
├── screens/         # UI screens - for UI changes
├── widgets/         # Reusable components
├── models/          # Data structures
├── services/        # Backend integrations
└── router/          # Navigation configuration
```

### Making Changes

1. **Create a Feature Branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Your Changes**: Follow the [BLoC pattern](../ARCHITECTURE.md#bloc-pattern-implementation)

3. **Run Linter**:
   ```bash
   flutter analyze
   ```

4. **Format Code**:
   ```bash
   flutter format .
   ```

5. **Run Tests**:
   ```bash
   flutter test
   ```

6. **Test on Device**: Use hot reload (`r`) and hot restart (`R`)

### Hot Reload vs Hot Restart

- **Hot Reload** (`r`): Fast UI updates, preserves app state
- **Hot Restart** (`R`): Full restart, resets app state
- **Full Rebuild**: Stop and re-run if BLoC changes

### Debug Tools

**Flutter DevTools**:
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

Features:
- Widget inspector
- Network profiler
- Performance metrics
- BLoC observer logs

---

## Common Issues

### Issue: `flutter doctor` Shows Missing Android SDK

**Solution**:
```bash
flutter config --android-sdk C:\Users\<YourName>\AppData\Local\Android\Sdk
```

### Issue: iOS Build Fails - Pod Install Failed

**Solution**:
```bash
cd ios
pod repo update
pod install
cd ..
```

### Issue: Firebase Not Initialized

**Error**: `[core/no-app] No Firebase App has been created`

**Solution**:
1. Ensure `firebase_core` is initialized in `main.dart`:
   ```dart
   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   ```
2. Verify `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are in correct locations
3. Run `flutterfire configure` again

### Issue: Google Sign-In Not Working

**Solution**:
1. Add SHA-1 fingerprint to Firebase:
   ```bash
   cd android
   ./gradlew signingReport
   ```
2. Copy SHA-1 from output
3. Add to Firebase Console → Project Settings → Your Apps → SHA certificate fingerprints

### Issue: Build Runner Conflicts

**Error**: `Conflicting outputs were detected`

**Solution**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Gradle Build Fails (Android)

**Solution**:
1. Update Gradle in `android/gradle/wrapper/gradle-wrapper.properties`:
   ```properties
   distributionUrl=https\://services.gradle.org/distributions/gradle-8.0-all.zip
   ```
2. Clean and rebuild:
   ```bash
   cd android
   ./gradlew clean
   cd ..
   flutter clean
   flutter pub get
   flutter build apk
   ```

### Issue: Maps Not Showing

**Solution**:
1. Verify API key is correct
2. Ensure **Maps SDK** is enabled in Google Cloud Console
3. Check API key restrictions (should allow your package name)

### Issue: Firestore Permission Denied

**Solution**:
1. Check user is authenticated: `FirebaseAuth.instance.currentUser != null`
2. Verify security rules in `firestore.rules` allow the operation
3. Deploy updated rules: `firebase deploy --only firestore:rules`

---

## Next Steps

### Learn the Codebase

1. **Read Architecture Docs**: [ARCHITECTURE.md](../ARCHITECTURE.md)
2. **Understand Database**: [FIRESTORE_SCHEMA.md](../FIRESTORE_SCHEMA.md)
3. **Explore BLoCs**: Start with `lib/blocs/auth/` for a simple example

### Set Up Your Workflow

1. **Configure Git Hooks** (optional):
   ```bash
   # Auto-format before commit
   echo "flutter format ." > .git/hooks/pre-commit
   chmod +x .git/hooks/pre-commit
   ```

2. **Set Up Code Snippets** in VS Code:
   - Snippets for BLoC boilerplate
   - Snippets for widget creation

3. **Join the Team**:
   - Review open issues/PRs
   - Ask questions in team chat
   - Read [CONTRIBUTING.md](contributing.md)

### Recommended Tasks for New Developers

1. **Fix a Small Bug**: Browse issues tagged `good-first-issue`
2. **Add a Test**: Improve test coverage in `test/`
3. **Update Documentation**: Fix typos or add examples
4. **Create a Widget**: Build a reusable UI component

---

## Useful Commands Reference

```bash
# Development
flutter run                          # Run app
flutter run --release                # Release build (faster)
flutter run -d chrome                # Run on web

# Code Quality
flutter analyze                      # Static analysis
flutter format .                     # Format all files
flutter test                        # Run all tests
flutter test test/specific_test.dart # Run specific test

# Build
flutter build apk                    # Android APK
flutter build appbundle              # Android App Bundle
flutter build ios                    # iOS build (macOS only)

# Clean & Reset
flutter clean                        # Clean build folder
flutter pub get                      # Re-download dependencies
flutter pub upgrade                  # Upgrade dependencies

# Code Generation
flutter pub run build_runner build   # Generate code once
flutter pub run build_runner watch   # Watch and regenerate

# Firebase
firebase deploy --only firestore:rules  # Deploy Firestore rules
firebase deploy --only storage          # Deploy storage rules
```

---

## Getting Help

- **Documentation**: [Flutter Docs](https://docs.flutter.dev/)
- **BLoC Library**: [bloclibrary.dev](https://bloclibrary.dev/)
- **Firebase**: [Firebase Flutter Docs](https://firebase.google.com/docs/flutter/setup)
- **Team**: Ask in Slack/Discord/Email

---

**Welcome to the team! 🚀**

_Last Updated: December 2025_
