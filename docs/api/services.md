# Services API Reference

Complete reference for all service layer classes in the Home Repair App.

## Table of Contents
- [AuthService](#authservice)
- [FirestoreService](#firestoreservice)
- [StorageService](#storageservice)
- [ChatService](#chatservice)
- [ReviewService](#reviewservice)
- [NotificationService](#notificationservice)
- [AnalyticsService](#analyticsservice)
- [CacheService](#cacheservice)

---

## AuthService

**Location**: `lib/services/auth_service.dart`

Handles user authentication using Firebase Auth.

### Methods

#### signInWithEmail
```dart
Future<UserModel> signInWithEmail(String email, String password)
```

Signs in a user with email and password.

**Parameters**:
- `email`: User's email address
- `password`: User's password

**Returns**: `UserModel` of authenticated user

**Throws**: 
- `AuthException` if credentials are invalid
- `NetworkException` if no internet connection

**Example**:
```dart
final authService = AuthService();
try {
  final user = await authService.signInWithEmail(
    'user@example.com',
    'password123',
  );
  print('Logged in: ${user.fullName}');
} on AuthException catch (e) {
  print('Login failed: ${e.message}');
}
```

#### signInWithGoogle
```dart
Future<UserModel> signInWithGoogle()
```

Signs in using Google Sign-In.

**Returns**: `UserModel` of authenticated user

**Throws**: `AuthException` if sign-in is cancelled or fails

#### createUserWithEmail
```dart
Future<UserModel> createUserWithEmail({
  required String email,
  required String password,
  required String fullName,
  required UserRole role,
})
```

Creates a new user account.

**Parameters**:
- `email`: User's email address
- `password`: Password (min 6 characters)
- `fullName`: User's full name
- `role`: User role (customer, technician, admin)

**Returns**: `UserModel` of created user

#### signOut
```dart
Future<void> signOut()
```

Signs out the current user.

#### getCurrentUser
```dart
User? getCurrentUser()
```

Gets the currently authenticated Firebase user.

**Returns**: `User?` or null if not authenticated

---

## FirestoreService

**Location**: `lib/services/firestore_service.dart`

Manages all Firestore database operations.

### User Operations

#### createUser
```dart
Future<void> createUser(UserModel user)
```

Creates a new user document in Firestore.

#### getUser
```dart
Future<UserModel?> getUser(String userId)
```

Fetches a user by ID.

**Returns**: `UserModel` or null if not found

#### updateUser
```dart
Future<void> updateUser(String userId, Map<String, dynamic> updates)
```

Updates user fields.

**Example**:
```dart
await firestoreService.updateUser(userId, {
  'fullName': 'New Name',
  'phoneNumber': '+966501234567',
});
```

### Service Operations

#### getServices
```dart
Future<List<ServiceModel>> getServices()
```

Fetches all active services.

#### getService
```dart
Future<ServiceModel?> getService(String serviceId)
```

Gets a single service by ID.

### Order Operations

#### createOrder
```dart
Future<String> createOrder(OrderModel order)
```

Creates a new order.

**Returns**: Order ID

#### getOrder
```dart
Future<OrderModel?> getOrder(String orderId)
```

Fetches an order by ID.

#### getUserOrders
```dart
Stream<List<OrderModel>> getUserOrders({
  required String userId,
  required bool isTechnician,
})
```

Streams user's orders (customer or technician).

**Parameters**:
- `userId`: User ID
- `isTechnician`: true for technician orders, false for customer orders

**Returns**: Stream of `List<OrderModel>`

**Example**:
```dart
firestoreService.getUserOrders(
  userId: currentUser.id,
  isTechnician: false,
).listen((orders) {
  print('Orders: ${orders.length}');
});
```

#### updateOrderStatus
```dart
Future<void> updateOrderStatus(String orderId, OrderStatus status)
```

Updates order status.

#### getCustomerOrdersPaginated
```dart
Future<PaginatedResult<OrderModel>> getCustomerOrdersPaginated({
  required String customerId,
  int limit = 10,
  DocumentSnapshot? lastDocument,
})
```

Gets paginated customer orders.

**Returns**: `PaginatedResult<OrderModel>` with orders and pagination info

---

## StorageService

**Location**: `lib/services/storage_service.dart`

Handles file uploads to Firebase Storage.

### Methods

#### uploadImage
```dart
Future<String> uploadImage({
  required File file,
  required String path,
  Function(double)? onProgress,
})
```

Uploads an image file.

**Parameters**:
- `file`: Image file to upload
- `path`: Storage path (e.g., `'profiles/user123.jpg'`)
- `onProgress`: Optional callback for upload progress (0.0 to 1.0)

**Returns**: Download URL of uploaded image

**Example**:
```dart
final url = await storageService.uploadImage(
  file: imageFile,
  path: 'profiles/${user.id}.jpg',
  onProgress: (progress) {
    print('Upload: ${(progress * 100).toInt()}%');
  },
);
```

#### uploadOrderPhotos
```dart
Future<List<String>> uploadOrderPhotos({
  required String orderId,
  required List<File> photos,
})
```

Uploads multiple order photos.

**Returns**: List of download URLs

#### deleteFile
```dart
Future<void> deleteFile(String url)
```

Deletes a file from Storage.

---

## ChatService

**Location**: `lib/services/chat_service.dart`

Manages real-time chat functionality.

### Methods

#### getChatForOrder
```dart
Future<ChatModel?> getChatForOrder(String orderId)
```

Gets or creates a chat for an order.

#### sendMessage
```dart
Future<void> sendMessage({
  required String chatId,
  required MessageModel message,
})
```

Sends a message in a chat.

**Example**:
```dart
final message = MessageModel(
  id: uuid.v4(),
  senderId: currentUser.id,
  text: 'Hello!',
  timestamp: DateTime.now(),
  type: MessageType.text,
  isRead: false,
);

await chatService.sendMessage(
  chatId: chatId,
  message: message,
);
```

#### streamMessages
```dart
Stream<List<MessageModel>> streamMessages(String chatId)
```

Streams messages for a chat in real-time.

**Returns**: Stream of `List<MessageModel>` ordered by timestamp

#### markAsRead
```dart
Future<void> markAsRead(String chatId, String messageId)
```

Marks a message as read.

---

## ReviewService

**Location**: `lib/services/review_service.dart`

Handles review creation and retrieval.

### Methods

#### createReview
```dart
Future<void> createReview(ReviewModel review)
```

Creates a new review.

**Validation**:
- Rating must be 1-5
- Comment must be 10-500 characters
- User must be the order customer

#### getTechnicianReviews
```dart
Future<List<ReviewModel>> getTechnicianReviews(String technicianId)
```

Gets all reviews for a technician.

#### getAverageRating
```dart
Future<double> getAverageRating(String technicianId)
```

Calculates average rating for a technician.

**Returns**: Average rating (0.0 to 5.0)

---

## NotificationService

**Location**: `lib/services/notification_service.dart`

Manages Firebase Cloud Messaging notifications.

### Methods

#### initialize
```dart
Future<void> initialize()
```

Initializes FCM and notification handlers.

Must be called in `main()` after Firebase initialization.

#### getToken
```dart
Future<String?> getToken()
```

Gets the device FCM token.

**Returns**: FCM token or null

#### requestPermission
```dart
Future<bool> requestPermission()
```

Requests notification permissions.

**Returns**: true if granted

#### sendNotification
```dart
Future<void> sendNotification({
  required String userId,
  required String title,
  required String body,
  Map<String, dynamic>? data,
})
```

Sends a notification to a user.

**Note**: In production, this should be done server-side via Cloud Functions.

---

## AnalyticsService

**Location**: `lib/services/analytics_service.dart`

Tracks user events with Firebase Analytics.

### Methods

#### logEvent
```dart
Future<void> logEvent({
  required String name,
  Map<String, dynamic>? parameters,
})
```

Logs a custom event.

**Example**:
```dart
await analyticsService.logEvent(
  name: 'service_booked',
  parameters: {
    'service_id': serviceId,
    'service_name': serviceName,
    'price': price,
  },
);
```

#### logScreenView
```dart
Future<void> logScreenView(String screenName)
```

Logs a screen view.

#### setUserId
```dart
Future<void> setUserId(String userId)
```

Sets the user ID for analytics.

#### logLogin
```dart
Future<void> logLogin(String method)
```

Logs a login event.

**Parameters**:
- `method`: 'email', 'google', 'facebook'

---

## CacheService

**Location**: `lib/services/cache_service.dart`

Manages local data caching with SharedPreferences.

### Methods

#### saveServiceCache
```dart
Future<void> saveServiceCache(List<ServiceModel> services)
```

Caches services locally (24-hour TTL).

#### getServiceCache
```dart
Future<List<ServiceModel>?> getServiceCache()
```

Retrieves cached services if not expired.

**Returns**: List of services or null if cache expired

#### clearCache
```dart
Future<void> clearCache()
```

Clears all cached data.

---

## Usage Examples

### Complete Order Flow

```dart
// 1. Create order
final order = OrderModel(/* ... */);
final orderId = await firestoreService.createOrder(order);

// 2. Upload photos
final photoUrls = await storageService.uploadOrderPhotos(
  orderId: orderId,
  photos: selectedPhotos,
);

// 3. Update order with photos
await firestoreService.updateOrder(orderId, {
  'photoUrls': photoUrls,
});

// 4. Log analytics
await analyticsService.logEvent(
  name: 'order_created',
  parameters: {
    'order_id': orderId,
    'service_id': order.serviceId,
  },
);

// 5 Send notification to technicians
await notificationService.sendNotification(
  userId: technicianId,
  title: 'New Order',
  body: 'You have a new repair request',
  data: {'orderId': orderId},
);
```

### Chat Implementation

```dart
// Get or create chat
final chat = await chatService.getChatForOrder(orderId);

// Stream messages
chatService.streamMessages(chat.id).listen((messages) {
  // Update UI with messages
});

// Send message
final message = MessageModel(/* ... */);
await chatService.sendMessage(
  chatId: chat.id,
  message: message,
);
```

---

## Error Handling

All services throw custom exceptions:

- `AuthException`: Authentication errors
- `FirestoreException`: Database errors
- `StorageException`: File upload errors
- `NetworkException`: Network connectivity issues

**Handle errors**:
```dart
try {
  await service.method();
} on AuthException catch (e) {
  // Handle auth error
} on NetworkException catch (e) {
  // Handle network error
} catch (e) {
  // Handle unknown error
}
```

---

_Last Updated: December 2025_
