# Troubleshooting Guide

Common issues and solutions for the Home Repair App.

## Table of Contents
- [Build & Setup Issues](#build--setup-issues)
- [Firebase Issues](#firebase-issues)
- [Runtime Issues](#runtime-issues)
- [Development Issues](#development-issues)
- [Platform-Specific Issues](#platform-specific-issues)

---

## Build & Setup Issues

### Flutter Doctor Issues

#### Issue: Android SDK Not Found
```
[✗] Android toolchain - develop for Android devices
    ✗ Unable to locate Android SDK
```

**Solution**:
```bash
# Set Android SDK path
flutter config --android-sdk C:\Users\<YourName>\AppData\Local\Android\Sdk  # Windows
flutter config --android-sdk ~/Library/Android/sdk  # macOS
flutter config --android-sdk ~/Android/Sdk  # Linux
```

#### Issue: Android Licenses Not Accepted
```
[!] Android toolchain
    ✗ Android licenses not accepted
```

**Solution**:
```bash
flutter doctor --android-licenses
# Press 'y' to accept all licenses
```

#### Issue: Xcode Not Configured (macOS)
```
[✗] Xcode - develop for iOS and macOS
```

**Solution**:
```bash
sudo xcodebuild -license accept
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

### Dependency Issues

#### Issue: Pub Get Fails
```
Error: Could not resolve package dependencies
```

**Solutions**:
1. **Clean and retry**:
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Clear pub cache**:
   ```bash
   flutter pub cache repair
   flutter pub get
   ```

3. **Check pubspec.yaml for version conflicts**

#### Issue: Build Runner Conflicts
```
Conflicting outputs were detected
```

**Solution**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Code Generation Issues

#### Issue: Generated Files Not Found
```
Error: 'user_model.g.dart' doesn't exist
```

**Solution**:
```bash
# Generate all .g.dart files
flutter pub run build_runner build --delete-conflicting-outputs

# Or watch mode (regenerates on changes)
flutter pub run build_runner watch --delete-conflicting-outputs
```

---

## Firebase Issues

### Initialization Issues

#### Issue: Firebase Not Initialized
```
[core/no-app] No Firebase App has been created
```

**Solutions**:
1. **Ensure Firebase is initialized in main.dart**:
   ```dart
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

2. **Run FlutterFire configure**:
   ```bash
   flutterfire configure
   ```

3. **Verify firebase_options.dart exists**:
   - Should be in `lib/firebase_options.dart`
   - Contains platform-specific Firebase config

#### Issue: google-services.json Missing (Android)
```
File google-services.json is missing
```

**Solution**:
1. Download from Firebase Console → Project Settings → Your Apps
2. Place in `android/app/google-services.json`
3. Verify `google-services` plugin is in `android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

#### Issue: GoogleService-Info.plist Missing (iOS)
```
Could not find GoogleService-Info.plist
```

**Solution**:
1. Download from Firebase Console
2. Place in `ios/Runner/GoogleService-Info.plist`
3. Add to Xcode project (drag into Runner folder in Xcode)

### Authentication Issues

#### Issue: Google Sign-In Fails
```
PlatformException: sign_in_failed
```

**Solutions**:

**For Android**:
1. Add SHA-1 fingerprint to Firebase:
   ```bash
   cd android
   ./gradlew signingReport
   ```
2. Copy SHA-1 from output
3. Add to Firebase Console → Project Settings → Your Apps → SHA certificate fingerprints

**For iOS**:
1. Verify URL scheme in `Info.plist`:
   - Open `ios/Runner/Info.plist`
   - Should contain reversed client ID from `GoogleService-Info.plist`

#### Issue: Email Sign-In Fails
```
[firebase_auth/invalid-email] The email address is badly formatted
```

**Solution**:
- Ensure email validation before calling sign-in
- Use validators from `lib/utils/validators.dart`:
  ```dart
  if (!Validators.isValidEmail(email)) {
    // Show error
  }
  ```

### Firestore Issues

#### Issue: Permission Denied
```
[cloud_firestore/permission-denied]
PERMISSION_DENIED: Missing or insufficient permissions
```

**Solutions**:
1. **Check user is authenticated**:
   ```dart
   final user = FirebaseAuth.instance.currentUser;
   if (user == null) {
     // User not logged in
   }
   ```

2. **Verify security rules**:
   - Check `firestore.rules`
   - Ensure rules allow the operation
   - Deploy rules: `firebase deploy --only firestore:rules`

3. **Check user role**:
   ```dart
   final userDoc = await FirebaseFirestore.instance
       .collection('users')
       .doc(userId)
       .get();
   final role = userDoc.data()?['role'];
   ```

#### Issue: Firestore Index Missing
```
The query requires an index
```

**Solution**:
1. Click the link in the error message (creates index automatically)
2. Or manually create in Firebase Console → Firestore → Indexes
3. Add to `firestore.indexes.json`:
   ```json
   {
     "indexes": [
       {
         "collectionGroup": "orders",
         "queryScope": "COLLECTION",
         "fields": [
           {"fieldPath": "customerId", "order": "ASCENDING"},
           {"fieldPath": "status", "order": "ASCENDING"},
           {"fieldPath": "createdAt", "order": "DESCENDING"}
         ]
       }
     ]
   }
   ```

---

## Runtime Issues

### Crash on Startup

#### Issue: App Crashes Immediately
**Check**:
1. **Run in debug mode** to see error:
   ```bash
   flutter run --debug
   ```
2. **Check Crashlytics** in Firebase Console
3. **Review logs**:
   ```bash
   flutter logs
   ```

**Common Causes**:
- Firebase not initialized
- Missing native dependencies
- Invalid Firebase configuration

### Map Issues

#### Issue: Maps Not Showing
**Solutions**:

**For Android**:
1. **Verify API key** in `AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_API_KEY"/>
   ```

2. **Enable Maps SDK** in Google Cloud Console:
   - Go to APIs & Services → Library
   - Enable "Maps SDK for Android"

3. **Check API key restrictions**:
   - Should allow Android apps
   - Package name should match your app

**For iOS**:
1. **Verify API key** in `AppDelegate.swift`:
   ```swift
   GMSServices.provideAPIKey("YOUR_API_KEY")
   ```

2. **Enable Maps SDK for iOS** in Google Cloud Console

#### Issue: Location Permission Denied
```
PermissionDeniedException: Location access denied
```

**Solution**:
1. **Request permissions** using `geolocator`:
   ```dart
   LocationPermission permission = await Geolocator.requestPermission();
   ```

2. **Check permissions are in manifest** (Android):
   ```xml
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
   ```

3. **Check Info.plist** (iOS):
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>We need your location to show nearby technicians</string>
   ```

### Image Loading Issues

#### Issue: Images Not Loading
**Solutions**:
1. **Check internet connection**
2. **Verify Storage rules**:
   ```bash
   firebase deploy --only storage
   ```
3. **Check image URLs are valid**
4. **Use cached_network_image** for better error handling:
   ```dart
   CachedNetworkImage(
     imageUrl: imageUrl,
     errorWidget: (context, url, error) => Icon(Icons.error),
   )
   ```

---

## Development Issues

### Hot Reload Issues

#### Issue: Hot Reload Not Working
**Solutions**:
1. **Use Hot Restart** instead: Press `R` in terminal
2. **Full restart**: Stop and `flutter run` again
3. **Clean and rebuild**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

#### Issue: Changes Not Reflecting
**Causes & Solutions**:
- **BLoC changes**: Requires full restart
- **Model changes**: Run code generation:
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```
- **Dependency injection changes**: Full restart required
- **Asset changes**: Hot restart (not hot reload)

### State Management Issues

#### Issue: BLoC Not Rebuilding UI
**Check**:
1. **Widget is wrapped in BlocBuilder**:
   ```dart
   BlocBuilder<AuthBloc, AuthState>(
     builder: (context, state) {
       // UI based on state
     },
   )
   ```

2. **States are Equatable**:
   ```dart
   class MyState extends Equatable {
     @override
     List<Object?> get props => [field1, field2];
   }
   ```

3. **BLoC is provided**:
   ```dart
   BlocProvider(
     create: (_) => MyBloc(),
     child: MyScreen(),
   )
   ```

#### Issue: State Not Persisting
**Solutions**:
- Use `HydratedBloc` for state persistence
- Or implement manual state saving with `shared_preferences`

---

## Platform-Specific Issues

### Android Issues

#### Issue: Gradle Build Fails
```
Execution failed for task ':app:processDebugResources'
```

**Solutions**:
1. **Update Gradle**:
   - Edit `android/gradle/wrapper/gradle-wrapper.properties`
   - Change to: `gradle-8.0-all.zip`

2. **Clean gradle**:
   ```bash
   cd android
   ./gradlew clean
   cd ..
   flutter clean
   flutter pub get
   ```

3. **Invalidate caches** (Android Studio):
   - File → Invalidate Caches → Invalidate and Restart

#### Issue: Multidex Error
```
Cannot fit requested classes in a single dex file
```

**Solution**:
Add to `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        multiDexEnabled true
    }
}

dependencies {
    implementation 'androidx.multidex:multidex:2.0.1'
}
```

### iOS Issues

#### Issue: Pod Install Fails
```
[!] CocoaPods could not find compatible versions
```

**Solutions**:
```bash
cd ios
pod repo update
pod install --repo-update
cd ..
```

#### Issue: Signing Errors
```
Signing for "Runner" requires a development team
```

**Solution**:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Signing & Capabilities → Team → Select your team
4. Or use automatic signing

---

## Performance Issues

### App Slow to Load

**Check**:
1. **Run in release mode**:
   ```bash
   flutter run --release
   ```
   Debug mode is intentionally slower

2. **Check for expensive operations** in build():
   - Move to initState() or separate methods
   - Use const constructors where possible

3. **Profile the app**:
   ```bash
   flutter run --profile
   # Then use DevTools
   ```

### Large APK Size

**Solutions**:
1. **Enable code shrinking** (`android/app/build.gradle`):
   ```gradle
   buildTypes {
       release {
           minifyEnabled true
           shrinkResources true
       }
   }
   ```

2. **Build app bundle** instead of APK:
   ```bash
   flutter build appbundle
   ```

3. **Remove unused dependencies** from `pubspec.yaml`

---

## Getting More Help

### Debug Tools

**Flutter DevTools**:
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

**Logs**:
```bash
# All logs
flutter logs

# Filtered logs
flutter logs | grep "ERROR"
```

**ADB Logcat** (Android):
```bash
adb logcat | grep flutter
```

### Resources

- **Flutter Docs**: https://docs.flutter.dev/
- **Firebase Docs**: https://firebase.google.com/docs/
- **Stack Overflow**: Tag questions with `flutter` and `firebase`
- **GitHub Issues**: Check the repository issues

### Still Stuck?

1. **Check existing issues** in the repository
2. **Create a new issue** with:
   - Flutter doctor output
   - Full error message
   - Steps to reproduce
   - Platform (Android/iOS)
   - Flutter version
3. **Contact support**: support@homerepairapp.com

---

_Last Updated: December 2025_
