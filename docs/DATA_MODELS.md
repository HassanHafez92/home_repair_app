# Data Models Documentation

## Table of Contents
- [Overview](#overview)
- [Model Architecture](#model-architecture)
- [Core Models](#core-models)
- [User Models](#user-models)
- [Service Models](#service-models)
- [Payment Models](#payment-models)
- [Communication Models](#communication-models)
- [Supporting Models](#supporting-models)
- [Model Relationships](#model-relationships)
- [Code Generation](#code-generation)

---

## Overview

The Home Repair App uses **33 data models** to represent all entities and data structures in the application. All models follow consistent patterns for serialization, type safety, and Firebase integration.

### Model Features

- **JSON Serialization**: All models use `json_serializable` for type-safe JSON conversion
- **Immutability**: Models are immutable with `const` constructors where possible
- **Equatable**: Critical models extend `Equatable` for value-based equality
- **Timestamp Handling**: Custom converters for Firestore `Timestamp` ↔ `DateTime`
- **Null Safety**: Full null safety support with nullable fields where appropriate
- **CopyWith**: Models include `copyWith()` methods for creating modified copies

---

## Model Architecture

### Serialization Pattern

All models follow this pattern:

```dart
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'model_name.g.dart';

@JsonSerializable(explicitToJson: true)
class ModelName {
  final String id;
  
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;
  
  const ModelName({
    required this.id,
    required this.createdAt,
  });
  
  factory ModelName.fromJson(Map<String, dynamic> json) => 
      _$ModelNameFromJson(json);
  
  Map<String, dynamic> toJson() => _$ModelNameToJson(this);
}

// Timestamp converters
DateTime _timestampFromJson(dynamic timestamp) {
  if (timestamp is Timestamp) return timestamp.toDate();
  if (timestamp is String) return DateTime.parse(timestamp);
  return DateTime.now();
}

dynamic _timestampToJson(DateTime date) => Timestamp.fromDate(date);
```

### Generated Files

Each model generates a `.g.dart` file via `build_runner`:
- `user_model.dart` → `user_model.g.dart`
- Contains `fromJson` and `toJson` implementations
- Auto-generated, should not be manually edited

---

## Core Models

### 1. UserModel

**Location**: [`lib/models/user_model.dart`](file:///c:/Users/Hassan/.gemini/antigravity/scratch/home_repair_app/lib/models/user_model.dart)

Base model for all user types.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | `String` | ✅ | User unique identifier (matches Firebase Auth UID) |
| `email` | `String` | ✅ | User email address |
| `phoneNumber` | `String?` | ❌ | Phone number |
| `fullName` | `String` | ✅ | Display name |
| `profilePhoto` | `String?` | ❌ | Profile photo URL |
| `role` | `UserRole` | ✅ | Enum: `customer`, `technician`, `admin` |
| `createdAt` | `DateTime` | ✅ | Account creation timestamp |
| `updatedAt` | `DateTime` | ✅ | Last update timestamp |
| `lastActive` | `DateTime` | ✅ | Last activity timestamp |
| `emailVerified` | `bool?` | ❌ | Email verification status |

**Enums**:
```dart
enum UserRole { customer, technician, admin }
```

---

### 2. CustomerModel

**Location**: [`lib/models/customer_model.dart`](file:///c:/Users/Hassan/.gemini/antigravity/scratch/home_repair_app/lib/models/customer_model.dart)

Extends `UserModel` with customer-specific fields.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| *(Inherits all from UserModel)* | | | |
| `savedAddresses` | `List<String>` | ✅ | List of saved address IDs |
| `savedPaymentMethods` | `List<String>` | ✅ | List of saved payment method IDs |

**Fixed Role**: Always `UserRole.customer`

---

### 3. TechnicianModel

**Location**: [`lib/models/technician_model.dart`](file:///c:/Users/Hassan/.gemini/antigravity/scratch/home_repair_app/lib/models/technician_model.dart)

Extends `UserModel` with technician-specific professional details.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| *(Inherits all from UserModel)* | | | |
| `nationalId` | `String?` | ❌ | National ID number |
| `specializations` | `List<String>` | ✅ | List of service specializations |
| `portfolioUrls` | `List<String>` | ✅ | Portfolio/work photo URLs |
| `yearsOfExperience` | `int` | ✅ | Years of professional experience |
| `status` | `TechnicianStatus` | ✅ | Account approval status |
| `rating` | `double` | ✅ | Average rating (0.0-5.0) |
| `completedJobs` | `int` | ✅ | Total completed jobs count |
| `isAvailable` | `bool` | ✅ | Currently accepting jobs |
| `location` | `Map<String, dynamic>?` | ❌ | Current GeoPoint location |

**Enums**:
```dart
enum TechnicianStatus { pending, approved, rejected, suspended }
```

**Fixed Role**: Always `UserRole.technician`

---

## Service Models

### 4. OrderModel

**Location**: [`lib/models/order_model.dart`](file:///c:/Users/Hassan/.gemini/antigravity/scratch/home_repair_app/lib/models/order_model.dart)

Represents a service order placed by a customer.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | `String` | ✅ | Order unique identifier |
| `customerId` | `String` | ✅ | Customer user ID (FK) |
| `technicianId` | `String?` | ❌ | Assigned technician ID (FK) |
| `serviceId` | `String` | ✅ | Service ID (FK) |
| `description` | `String` | ✅ | Problem description |
| `photoUrls` | `List<String>` | ✅ | Problem photo URLs |
| `location` | `Map<String, dynamic>` | ✅ | GeoPoint as map `{latitude, longitude}` |
| `address` | `String` | ✅ | Full address string |
| `dateRequested` | `DateTime` | ✅ | Order creation timestamp |
| `dateScheduled` | `DateTime?` | ❌ | Scheduled appointment time |
| `status` | `OrderStatus` | ✅ | Current order status |
| `initialEstimate` | `double?` | ❌ | Initial price estimate |
| `finalPrice` | `double?` | ❌ | Final agreed price |
| `visitFee` | `double` | ✅ | Visit/inspection fee |
| `vat` | `double` | ✅ | VAT amount |
| `paymentMethod` | `String` | ✅ | Payment method: `'cash'`, `'card'`, `'wallet'` |
| `paymentStatus` | `String` | ✅ | Status: `'pending'`, `'paid'`, `'failed'` |
| `notes` | `String?` | ❌ | Additional notes |
| `serviceName` | `String?` | ❌ | **Denormalized** service name |
| `customerName` | `String?` | ❌ | **Denormalized** customer name |
| `customerPhoneNumber` | `String?` | ❌ | **Denormalized** customer phone |
| `createdAt` | `DateTime` | ✅ | Creation timestamp |
| `updatedAt` | `DateTime` | ✅ | Last update timestamp |

**Enums**:
```dart
enum OrderStatus {
  pending,    // Awaiting technician
  accepted,   // Technician accepted
  traveling,  // En route to location
  arrived,    // Arrived at location
  working,    // Work in progress
  completed,  // Work completed
  cancelled,  // Order cancelled
}
```

**Helper Methods**:
- `totalPrice` - Returns `finalPrice ?? initialEstimate ?? 0.0`

**Features**:
- Extends `Equatable` for value comparison
- Includes `copyWith()` for immutable updates
- Denormalized fields reduce Firestore reads

---

### 5. ServiceModel

**Location**: [`lib/models/service_model.dart`](file:///c:/Users/Hassan/.gemini/antigravity/scratch/home_repair_app/lib/models/service_model.dart)

Represents a repair service offered on the platform.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | `String` | ✅ | Service unique identifier |
| `name` | `String` | ✅ | Service name |
| `description` | `String` | ✅ | Service description |
| `iconUrl` | `String` | ✅ | Service icon/image URL |
| `category` | `String` | ✅ | Category (e.g., "Plumbing", "Electrical") |
| `avgPrice` | `double` | ✅ | Average service price |
| `minPrice` | `double` | ✅ | Minimum price range |
| `maxPrice` | `double` | ✅ | Maximum price range |
| `visitFee` | `double` | ✅ | Technician visit fee |
| `avgCompletionTimeMinutes` | `int` | ✅ | Average completion time |
| `isActive` | `bool` | ✅ | Service availability |
| `createdAt` | `DateTime` | ✅ | Service creation timestamp |

**Features**:
- Extends `Equatable`
- Immutable with `const` constructor

---

### 6. ReviewModel

**Location**: [`lib/models/review_model.dart`](file:///c:/Users/Hassan/.gemini/antigravity/scratch/home_repair_app/lib/models/review_model.dart)

Customer review for a completed service.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | `String` | ✅ | Review unique identifier |
| `orderId` | `String` | ✅ | Associated order ID (FK) |
| `technicianId` | `String` | ✅ | Technician ID (FK) |
| `customerId` | `String` | ✅ | Customer ID (FK) |
| `rating` | `int` | ✅ | Overall rating (1-5 stars) |
| `categories` | `Map<String, int>` | ✅ | Category ratings: `{quality, punctuality, professionalism, price}` |
| `comment` | `String?` | ❌ | Review text |
| `photoUrls` | `List<String>` | ✅ | Review photo URLs (max 5) |
| `timestamp` | `DateTime` | ✅ | Review creation timestamp |

**Category Ratings**:
- `quality`: Work quality (1-5)
- `punctuality`: Timeliness (1-5)
- `professionalism`: Professional conduct (1-5)
- `price`: Value for money (1-5)

---

## Payment Models

### 7. PaymentModel

**Location**: [`lib/models/payment_model.dart`](file:///c:/Users/Hassan/.gemini/antigravity/scratch/home_repair_app/lib/models/payment_model.dart)

Records payment transactions.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | `String` | ✅ | Payment unique identifier |
| `orderId` | `String` | ✅ | Associated order ID (FK) |
| `amount` | `double` | ✅ | Payment amount |
| `method` | `String` | ✅ | Payment method |
| `status` | `String` | ✅ | Status: `'pending'`, `'completed'`, `'failed'` |
| `transactionId` | `String?` | ❌ | External transaction ID |
| `timestamp` | `DateTime` | ✅ | Payment timestamp |

---

### 8. PaymentMethodModel

**Location**: [`lib/models/payment_method_model.dart`](file:///c:/Users/Hassan/.gemini/antigravity/scratch/home_repair_app/lib/models/payment_method_model.dart)

Saved payment methods for users.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | `String` | ✅ | Payment method ID |
| `userId` | `String` | ✅ | Owner user ID (FK) |
| `type` | `String` | ✅ | Type: `'card'`, `'wallet'` |
| `cardLast4` | `String?` | ❌ | Last 4 digits of card |
| `cardBrand` | `String?` | ❌ | Card brand (Visa, Mastercard) |
| `isDefault` | `bool` | ✅ | Default payment method |
| `createdAt` | `DateTime` | ✅ | Creation timestamp |

---

### 9. InvoiceModel

**Location**: [`lib/models/invoice_model.dart`](file:///c:/Users/Hassan/.gemini/antigravity/scratch/home_repair_app/lib/models/invoice_model.dart)

Invoice for completed orders.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | `String` | ✅ | Invoice unique identifier |
| `orderId` | `String` | ✅ | Associated order ID (FK) |
| `customerId` | `String` | ✅ | Customer ID (FK) |
| `technicianId` | `String` | ✅ | Technician ID (FK) |
| `subtotal` | `double` | ✅ | Subtotal before VAT |
| `vat` | `double` | ✅ | VAT amount |
| `total` | `double` | ✅ | Total amount |
| `timestamp` | `DateTime` | ✅ | Invoice generation timestamp |

---

### 10. WalletModel

**Location**: [`lib/models/wallet_model.dart`](file:///c:/Users/Hassan/.gemini/antigravity/scratch/home_repair_app/lib/models/wallet_model.dart)

User wallet for in-app balance.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | `String` | ✅ | Wallet unique identifier |
| `userId` | `String` | ✅ | Owner user ID (FK) |
| `balance` | `double` | ✅ | Current balance |
| `currency` | `String` | ✅ | Currency code (e.g., "SAR") |
| `transactions` | `List<Map<String, dynamic>>` | ✅ | Transaction history |
| `updatedAt` | `DateTime` | ✅ | Last update timestamp |

---

### 11. PromotionModel

**Location**: [`lib/models/promotion_model.dart`](file:///c:/Users/Hassan/.gemini/antigravity/scratch/home_repair_app/lib/models/promotion_model.dart)

Promotional offers and discounts.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | `String` | ✅ | Promotion unique identifier |
| `code` | `String` | ✅ | Promo code |
| `description` | `String` | ✅ | Promotion description |
| `discountPercentage` | `double?` | ❌ | Discount percentage (0-100) |
| `discountAmount` | `double?` | ❌ | Fixed discount amount |
| `validFrom` | `DateTime` | ✅ | Start date |
| `validTo` | `DateTime` | ✅ | End date |
| `isActive` | `bool` | ✅ | Active status |

---

## Communication Models

### 12. ChatModel

**Location**: [`lib/models/chat_model.dart`](file:///c:/Users/Hassan/.gemini/antigravity/scratch/home_repair_app/lib/models/chat_model.dart)

Chat conversation metadata.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | `String` | ✅ | Chat unique identifier |
| `orderId` | `String` | ✅ | Associated order ID (FK) |
| `participants` | `List<String>` | ✅ | Array of 2 user IDs |
| `lastMessage` | `String?` | ❌ | Last message preview |
| `lastMessageTime` | `DateTime?` | ❌ | Last message timestamp |
| `unreadCounts` | `Map<String, int>` | ✅ | Unread count per user: `{userId: count}` |

---

### 13. MessageModel

**Location**: [`lib/models/message_model.dart`](file:///c:/Users/Hassan/.gemini/antigravity/scratch/home_repair_app/lib/models/message_model.dart)

Individual chat message.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | `String` | ✅ | Message unique identifier |
| `senderId` | `String` | ✅ | Sender user ID (FK) |
| `text` | `String` | ✅ | Message text |
| `timestamp` | `DateTime` | ✅ | Send timestamp |
| `type` | `String` | ✅ | Type: `'text'` or `'image'` |
| `isRead` | `bool` | ✅ | Read status |
| `imageUrl` | `String?` | ❌ | Image URL (if type is `'image'`) |

---

### 14. NotificationModel

**Location**: [`lib/models/notification_model.dart`](file:///c:/Users/Hassan/.gemini/antigravity/scratch/home_repair_app/lib/models/notification_model.dart)

Push notification record.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | `String` | ✅ | Notification unique identifier |
| `userId` | `String` | ✅ | Recipient user ID (FK) |
| `title` | `String` | ✅ | Notification title |
| `body` | `String` | ✅ | Notification body |
| `type` | `String` | ✅ | Type: `'order_update'`, `'new_message'`, etc. |
| `data` | `Map<String, dynamic>?` | ❌ | Additional data payload |
| `isRead` | `bool` | ✅ | Read status |
| `createdAt` | `DateTime` | ✅ | Creation timestamp |

---

## Supporting Models

### 15. AddressModel

**Location**: [`lib/models/address_model.dart`](file:///c:/Users/Hassan/.gemini/antigravity/scratch/home_repair_app/lib/models/address_model.dart)

Physical address (legacy, being replaced by SavedAddress).

---

### 16. SavedAddress

**Location**: [`lib/models/saved_address.dart`](file:///c:/Users/Hassan/.gemini/antigravity/scratch/home_repair_app/lib/models/saved_address.dart)

Saved address with label and location.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | `String` | ✅ | Address unique identifier |
| `userId` | `String` | ✅ | Owner user ID (FK) |
| `label` | `String` | ✅ | Address label (e.g., "Home", "Work") |
| `address` | `String` | ✅ | Full address string |
| `location` | `Map<String, dynamic>` | ✅ | GeoPoint as map |
| `isDefault` | `bool` | ✅ | Default address flag |
| `createdAt` | `DateTime` | ✅ | Creation timestamp |

---

### 17. DashboardStats

**Location**: [`lib/models/dashboard_stats.dart`](file:///c:/Users/Hassan/.gemini/antigravity/scratch/home_repair_app/lib/models/dashboard_stats.dart)

Admin dashboard statistics.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `totalUsers` | `int` | ✅ | Total registered users |
| `totalOrders` | `int` | ✅ | Total orders placed |
| `totalRevenue` | `double` | ✅ | Platform revenue |
| `activeTechnicians` | `int` | ✅ | Active technicians count |

---

### 18. TechnicianStats

**Location**: [`lib/models/technician_stats.dart`](file:///c:/Users/Hassan/.gemini/antigravity/scratch/home_repair_app/lib/models/technician_stats.dart)

Individual technician statistics.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `technicianId` | `String` | ✅ | Technician user ID (FK) |
| `totalJobs` | `int` | ✅ | Total jobs completed |
| `avgRating` | `double` | ✅ | Average rating |
| `totalEarnings` | `double` | ✅ | Total earnings |
| `completionRate` | `double` | ✅ | Job completion rate (0-1) |
| `responseTime` | `int` | ✅ | Avg response time (minutes) |

---

### 19. PaginatedResult<T>

**Location**: [`lib/models/paginated_result.dart`](file:///c:/Users/Hassan/.gemini/antigravity/scratch/home_repair_app/lib/models/paginated_result.dart)

Generic wrapper for paginated data.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | `List<T>` | ✅ | Current page items |
| `hasMore` | `bool` | ✅ | More pages available |
| `lastDocument` | `DocumentSnapshot?` | ❌ | Last document for pagination |

**Usage**:
```dart
PaginatedResult<OrderModel> orders = await getOrders();
```

---

## Model Relationships

### Entity Relationship Diagram

```mermaid
erDiagram
    UserModel ||--o{ OrderModel : "places"
    UserModel ||--o{ ReviewModel : "writes"
    UserModel ||--o{ ChatModel : "participates"
    UserModel ||--o{ NotificationModel : "receives"
    UserModel ||--o{ SavedAddress : "has"
    UserModel ||--o{ PaymentMethodModel : "owns"
    
    CustomerModel --|> UserModel : "extends"
    TechnicianModel --|> UserModel : "extends"
    
    ServiceModel ||--o{ OrderModel : "ordered-as"
    OrderModel ||--|| ChatModel : "has-conversation"
    OrderModel ||--o| ReviewModel : "reviewed-in"
    OrderModel ||--o| PaymentModel : "paid-via"
    OrderModel ||--o| InvoiceModel : "billed-as"
    
    ChatModel ||--o{ MessageModel : "contains"
    
    TechnicianModel ||--o{ ReviewModel : "receives"
    TechnicianModel ||--|| TechnicianStats : "has-stats"
```

### Foreign Key Relationships

| Parent Model | Child Model | Foreign Key Field |
|--------------|-------------|-------------------|
| UserModel | OrderModel | `customerId`, `technicianId` |
| UserModel | ReviewModel | `customerId`, `technicianId` |
| UserModel | SavedAddress | `userId` |
| UserModel | PaymentMethodModel | `userId` |
| UserModel | NotificationModel | `userId` |
| ServiceModel | OrderModel | `serviceId` |
| OrderModel | ChatModel | `orderId` |
| OrderModel | ReviewModel | `orderId` |
| OrderModel | PaymentModel | `orderId` |
| OrderModel | InvoiceModel | `orderId` |
| ChatModel | MessageModel | (subcollection) |

---

## Code Generation

### Generating Model Files

All `.g.dart` files are auto-generated using `build_runner`:

```bash
# Generate once
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on changes)
flutter pub run build_runner watch --delete-conflicting-outputs
```

### When to Regenerate

Regenerate `.g.dart` files when:
- Adding new fields to a model
- Changing field types
- Adding/removing `@JsonKey` annotations
- Creating new models

### Troubleshooting Generation

**Issue**: `build_runner` fails
```bash
# Clean and retry
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

**Issue**: Conflicting outputs
```bash
# Force delete conflicts
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Best Practices

### 1. Model Design

✅ **Do**:
- Use `const` constructors for immutable models
- Extend `Equatable` for models used in state management
- Include `copyWith()` for models that need updates
- Use `@JsonKey` for custom serialization
- Document complex fields with comments

❌ **Don't**:
- Edit `.g.dart` files manually
- Use mutable fields without good reason
- Forget to run code generation after changes
- Mix serialization approaches

### 2. Timestamp Handling

Always use custom converters for Firestore timestamps:

```dart
@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
final DateTime createdAt;

DateTime _timestampFromJson(dynamic timestamp) {
  if (timestamp is Timestamp) return timestamp.toDate();
  if (timestamp is String) return DateTime.parse(timestamp);
  return DateTime.now();
}

dynamic _timestampToJson(DateTime date) => Timestamp.fromDate(date);
```

### 3. Denormalization

Use denormalized fields to reduce Firestore reads:

```dart
// In OrderModel
final String? serviceName;      // Denormalized from ServiceModel
final String? customerName;     // Denormalized from UserModel
final String? customerPhoneNumber;  // Denormalized from UserModel
```

**Benefits**:
- Faster queries (single read instead of multiple)
- Lower costs
- Better offline support

**Tradeoffs**:
- Data can become stale
- Requires update logic when source changes

---

## Model Summary

| Category | Models | Count |
|----------|--------|-------|
| **User Models** | UserModel, CustomerModel, TechnicianModel | 3 |
| **Service Models** | OrderModel, ServiceModel, ReviewModel | 3 |
| **Payment Models** | PaymentModel, PaymentMethodModel, InvoiceModel, WalletModel, PromotionModel | 5 |
| **Communication** | ChatModel, MessageModel, NotificationModel | 3 |
| **Supporting** | AddressModel, SavedAddress, DashboardStats, TechnicianStats, PaginatedResult | 5 |
| **Generated Files** | All `.g.dart` files | 17 |
| **Total** | | **33** |

---

**Last Updated**: December 2025  
**Version**: 1.0.0
