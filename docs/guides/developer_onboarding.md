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

Generate necessary files for JSON serialization, dependency injection, and router configuration:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Configure Flavors

The app uses **flutter_flavorizr** for flavor management.

**Available Flavors**:
- **dev** (`com.example.home_repair_app.dev`): Development environment.
- **stg** (`com.example.home_repair_app.stg`): Staging/QA environment.
- **prod** (`com.example.home_repair_app`): Production environment.
- **uat**  (`com.example.home_repair_app.uat`): UAT environment.

Each flavor has its own `main_<flavor>.dart` entry point and Firebase configuration.

---

## Firebase Configuration

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **Add Project**
3. Create separate projects for each environment (e.g., `home-repair-app-dev`, `home-repair-app-prod`)

### 2. Add Android/iOS Apps

Follow standard Firebase instructions to add apps. Ensure you use the correct Package Name/Bundle ID for the flavor:
- Dev: `com.example.home_repair_app.dev`
- Stg: `com.example.home_repair_app.stg`
- Prod: `com.example.home_repair_app`

### 3. Enable Firebase Services

Enable Auth, Firestore, and Storage as needed.

### 4. Configure FlutterFire

Use FlutterFire CLI to generate configuration for each flavor:

```bash
# Install FlutterFire CLI
flutter pub global activate flutterfire_cli

# Configure for specific flavor/environment
flutterfire configure -o lib/firebase_options_dev.dart
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
# Run Development Flavor (Debug Mode)
flutter run --flavor dev -t lib/main_dev.dart

# Run Staging Flavor
flutter run --flavor stg -t lib/main_stg.dart

# Run Production Flavor (Release Mode)
flutter run --flavor prod -t lib/main_prod.dart --release
```

**Option B: Using VS Code**
1. Go to **Run and Debug** sidebar.
2. Select **"home_repair_app (dev)"** from the dropdown configuration list.
3. Press `F5`.

**Option C: Using Android Studio**
1. Open **Run/Debug Configurations**.
2. Select the flavor configuration (e.g., `main_dev.dart`).
3. Click **Run** ▶️.

### 3. First-Time Setup

1. **Register a Test User**:
   - Run the Dev flavor
   - Click **Sign Up**
   - Create an account with your test email
   
2. **Promote to Admin** (for testing admin features):
   - Go to Firebase Console → Firestore
   - Find your user document in `users` collection
   - Change `role` field to `'admin'`

---

## Development Workflow

### Project Structure Navigation

```
lib/
├── presentation/    # UI Layer (Screens, Widgets, BLoCs)
│   ├── blocs/       # Business Logic Components
│   ├── screens/     # UI Pages
│   └── widgets/     # Reusable Widgets
├── domain/          # Business Layer (Entities, UseCases, Repo Interfaces)
├── data/            # Data Layer (Repositories impl, Remote Data Sources)
├── core/            # Core Utils (DI, Constants, Errors)
├── config/          # Flavor Config & Firebase Options
└── main_*.dart      # Flavor Entry Points
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

---

## Common Issues

### Issue: `flutter doctor` Shows Missing Android SDK

**Solution**:
```bash
flutter config --android-sdk C:\Users\<YourName>\AppData\Local\Android\Sdk
```

### Issue: Firebase Not Initialized

**Error**: `[core/no-app] No Firebase App has been created`

**Solution**:
1. Ensure `firebase_core` is initialized with the correct options in the flavor entry point (e.g., `main_dev.dart`):
   ```dart
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```
   *Note: `DefaultFirebaseOptions` is dynamic based on the active flavor.*

### Issue: Google Sign-In Not Working

**Solution**:
1. Add SHA-1 fingerprint to the correct Firebase project (Dev vs Prod).
2. Download updated `google-services.json` and place it in `android/app/src/<flavor>/`.

### Issue: Build Runner Conflicts

**Error**: `Conflicting outputs were detected`

**Solution**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
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
