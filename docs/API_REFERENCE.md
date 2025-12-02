# API Reference

## Overview

This document serves as a central reference for the Home Repair App's APIs, including:
1.  **Backend API** (Firebase & Cloud Functions)
2.  **Internal API** (Service Layer)
3.  **External Integrations**

---

## 1. Backend API

The application uses **Firebase** as its backend-as-a-service.

### Firestore Database
The database schema, collections, and security rules are documented in detail:
- [**Firestore Schema Documentation**](FIRESTORE_SCHEMA.md)

### Cloud Functions
Server-side logic is implemented using Firebase Cloud Functions.
- [**Cloud Functions Documentation**](../functions/README.md)

**Key Functions**:
- `emailVerificationReminder24h`: Scheduled reminder
- `emailVerificationReminder48h`: Final scheduled reminder
- `onUserCreated`: Analytics tracking
- `syncEmailVerification`: Auth-Firestore sync

---

## 2. Internal API (Service Layer)

The application uses a **Service Layer** pattern to abstract external data sources. All services are located in `lib/services/`.

### Core Services

| Service | Description | Key Methods |
|---------|-------------|-------------|
| **AuthService** | Authentication management | `signInWithEmail`, `signUp`, `signOut`, `getCurrentUser` |
| **FirestoreService** | Database operations | `getUser`, `createOrder`, `getServices`, `updateProfile` |
| **StorageService** | File storage (images) | `uploadProfilePhoto`, `uploadOrderPhotos`, `deleteFile` |
| **AnalyticsService** | User behavior tracking | `logEvent`, `setUserProperty`, `logLogin`, `logPurchase` |

### Feature Services

| Service | Description | Key Methods |
|---------|-------------|-------------|
| **ChatService** | Real-time messaging | `getChat`, `sendMessage`, `markAsRead`, `streamMessages` |
| **NotificationService** | Push notifications | `initialize`, `getToken`, `sendNotification` |
| **ReviewService** | Ratings & reviews | `createReview`, `getTechnicianReviews`, `getOrderReview` |
| **SearchService** | Search functionality | `searchServices`, `searchTechnicians` |
| **AddressService** | Location & geocoding | `getCurrentLocation`, `getAddressFromCoordinates` |

### Utility Services

| Service | Description | Key Methods |
|---------|-------------|-------------|
| **CacheService** | Local data caching | `cacheData`, `getCachedData`, `clearCache` |
| **LoggerService** | Application logging | `logInfo`, `logError`, `logWarning` |
| **PerformanceService** | Performance monitoring | `startTrace`, `stopTrace` |
| **SnackbarService** | UI feedback | `showSuccess`, `showError`, `showInfo` |

---

## 3. External Integrations

### Google Maps Platform
- **SDKs**: Maps SDK for Android, Maps SDK for iOS
- **APIs**: Geocoding API, Places API
- **Usage**: Location picking, address resolution, distance calculation

### SendGrid (via Cloud Functions)
- **Usage**: Transactional emails (verification reminders)
- **Integration**: Server-side only (Cloud Functions)

### Firebase Services
- **Authentication**: Identity management
- **Firestore**: NoSQL database
- **Storage**: Blob storage
- **Analytics**: Usage tracking
- **Crashlytics**: Crash reporting
- **Cloud Messaging (FCM)**: Push notifications
- **Remote Config**: Feature flags (planned)

---

## Error Handling

All services throw custom exceptions defined in `lib/utils/exceptions.dart`:

- `AuthException`: Authentication failures
- `ServerException`: Backend/Network errors
- `CacheException`: Local storage errors
- `ValidationException`: Invalid input data

**Example Usage**:
```dart
try {
  await authService.signInWithEmail(email, password);
} on AuthException catch (e) {
  // Handle specific auth error
  snackbarService.showError(e.message);
} catch (e) {
  // Handle generic error
  snackbarService.showError('An unexpected error occurred');
}
```

---

**Last Updated**: December 2025
**Version**: 1.0.0
