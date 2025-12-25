# API Reference

## Overview

This document serves as a central reference for the Home Repair App's APIs, including:
1.  **Backend API** (Firebase & Cloud Functions)
2.  **Domain API** (Repository Interfaces)
3.  **External Integrations**

---

## 1. Backend API

The application uses **Firebase** as its backend-as-a-service.

### Firestore Database
The database schema, collections, and security rules are documented in detail:
- [**Firestore Schema Documentation**](../FIRESTORE_SCHEMA.md)

### Cloud Functions
Server-side logic is implemented using Firebase Cloud Functions.
- [**Cloud Functions Documentation**](../functions/README.md)

**Key Functions**:
- `emailVerificationReminder24h`: Scheduled reminder
- `emailVerificationReminder48h`: Final scheduled reminder
- `onUserCreated`: Analytics tracking
- `syncEmailVerification`: Auth-Firestore sync

---

## 2. Domain API (Internal Interfaces)

Following **Clean Architecture**, the application business logic (BLoCs) interacts with the data layer exclusively through **Repository Interfaces** defined in the **Domain Layer** (`lib/domain/repositories/`).

### Core Repositories

| Repository Interface | Description | Key Methods |
|----------------------|-------------|-------------|
| **IAuthRepository** | Authentication management | `signIn`, `signUp`, `signOut`, `getCurrentUser` |
| **IUserRepository** | User profile data | `getUserProfile`, `updateProfile` |
| **IServiceRepository**| Service catalog operations | `getServices`, `searchServices`, `getServiceById` |
| **IOrderRepository** | Order lifecycle management | `createOrder`, `getOrders`, `updateOrderStatus` |

### Feature Repositories

| Repository Interface | Description | Key Methods |
|----------------------|-------------|-------------|
| **IChatRepository** | Real-time messaging | `getConversations`, `sendMessage`, `streamMessages` |
| **INotificationRepository** | Push notifications | `initialize`, `getToken`, `sendNotification` |
| **IReviewRepository** | Ratings & reviews | `submitReview`, `getTechnicianReviews` |
| **IAddressRepository** | Saved addresses | `getSavedAddresses`, `saveAddress`, `deleteAddress` |

### Data Implementation
The implementations of these interfaces are located in the **Data Layer** (`lib/data/repositories/`). They handle the direct communication with Firebase, Local Storage, or external APIs.

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

The Domain Layer defines custom failures in `lib/core/errors/failures.dart` (or similar). Exceptions from the Data Layer are caught and mapped to these failures before returning to the Presentation Layer.

**Common Failures**:
- `ServerFailure`: Backend/Network errors
- `CacheFailure`: Local storage errors
- `AuthFailure`: Authentication invalid
- `ValidationFailure`: Invalid input logic

**Example Usage (BLoC)**:
```dart
final result = await authRepository.signIn(email, password);

result.fold(
  (failure) => emit(AuthError(message: failure.message)),
  (user) => emit(AuthAuthenticated(user: user)),
);
```

---

**Last Updated**: December 2025
**Version**: 1.0.1
