# Architecture Documentation

## Table of Contents
- [Overview](#overview)
- [Application Architecture](#application-architecture)
- [BLoC Pattern Implementation](#bloc-pattern-implementation)
- [Data Flow](#data-flow)
- [Project Structure](#project-structure)
- [Key Components](#key-components)
- [Design Decisions](#design-decisions)

---

## Overview

The Home Repair App is built using **Flutter** with a **Clean Architecture** approach and the **BLoC (Business Logic Component) pattern** for state management. The architecture separates concerns into distinct layers, making the application maintainable, testable, and scalable.

### High-Level Architecture

```mermaid
graph TB
    subgraph "Presentation Layer"
        UI[Screens & Widgets]
        BLoC[BLoC Components]
    end
    
    subgraph "Domain Layer"
        Models[Data Models]
        Utils[Utilities & Validators]
    end
    
    subgraph "Data Layer"
        Services[Services]
        Providers[Providers]
    end
    
    subgraph "External"
        Firebase[(Firebase Backend)]
    end
    
    UI --> BLoC
    BLoC --> Services
    BLoC --> Models
    Services --> Firebase
    Services --> Models
    Providers --> Services
```

### Technology Stack

- **Frontend Framework**: Flutter 3.9.2+
- **State Management**: BLoC (flutter_bloc)
- **Dependency Injection**: get_it + injectable
- **Navigation**: go_router
- **Backend**: Firebase (Auth, Firestore, Storage, Analytics, Crashlytics)
- **Localization**: easy_localization
- **Maps**: Google Maps Flutter

---

## Application Architecture

The app follows **Clean Architecture** principles with three main layers:

### 1. Presentation Layer

**Location**: `lib/screens/`, `lib/widgets/`

- **Responsibility**: UI components and user interactions
- **Components**:
  - **Screens**: Full-page views organized by feature
  - **Widgets**: Reusable UI components
- **Pattern**: Uses BLoC for state management, reacts to state changes

### 2. Business Logic Layer

**Location**: `lib/blocs/`

- **Responsibility**: Application business logic and state management
- **Components**:
  - **BLoCs**: Process events and emit states
  - **Events**: User actions or system triggers
  - **States**: Represent UI state at any point in time
- **Pattern**: BLoC pattern with flutter_bloc

### 3. Data Layer

**Location**: `lib/services/`, `lib/providers/`, `lib/models/`

- **Responsibility**: Data access, external service integration
- **Components**:
  - **Services**: Interface with Firebase and external APIs
  - **Providers**: Manage app-wide state and data
  - **Models**: Data structures and serialization
- **Pattern**: Repository pattern (planned - currently direct service access)

### Supporting Layers

**Domain Layer** (`lib/models/`, `lib/utils/`):
- Data models with business logic
- Validators and utility functions
- Exception handling

**Configuration** (`lib/config/`, `lib/theme/`, `lib/router/`):
- Firebase configuration
- App theming
- Navigation routing

---

## BLoC Pattern Implementation

The BLoC pattern separates business logic from UI, making code testable and maintainable.

### BLoC Flow Diagram

```mermaid
sequenceDiagram
    participant UI as User Interface
    participant BLoC as BLoC
    participant Service as Service Layer
    participant Firebase as Firebase Backend
    
    UI->>BLoC: Dispatch Event (e.g., LoginRequested)
    BLoC->>BLoC: Emit Loading State
    UI->>UI: Show Loading Indicator
    BLoC->>Service: Call Service Method
    Service->>Firebase: API Request
    Firebase-->>Service: Response
    Service-->>BLoC: Return Data/Error
    alt Success
        BLoC->>BLoC: Emit Success State
        UI->>UI: Update UI with Data
    else Error
        BLoC->>BLoC: Emit Error State
        UI->>UI: Show Error Message
    end
```

### BLoC Components

#### Events
User actions or system triggers that cause state changes.

**Example**: `AuthEvent` (from `lib/blocs/auth/`)
```dart
abstract class AuthEvent extends Equatable {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
}

class AuthLogoutRequested extends AuthEvent {}
```

#### States
Represent the current state of the application.

**Example**: `AuthState` (from `lib/blocs/auth/`)
```dart
abstract class AuthState extends Equatable {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final UserModel user;
}
class AuthError extends AuthState {
  final String message;
}
```

#### BLoCs
Process events and emit states based on business logic.

**Example**: `AuthBloc` (from `lib/blocs/auth/`)
```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;
  
  AuthBloc({required this.authService}) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }
  
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authService.signInWithEmail(
        event.email,
        event.password,
      );
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
```

### BLoC Modules

The app organizes BLoCs by feature:

| BLoC | Purpose | Location |
|------|---------|----------|
| **AuthBloc** | User authentication | `lib/blocs/auth/` |
| **ServiceBloc** | Service catalog browsing | `lib/blocs/service/` |
| **BookingBloc** | Booking flow management | `lib/blocs/booking/` |
| **OrderBloc** | Customer order management | `lib/blocs/order/` |
| **ProfileBloc** | User profile management | `lib/blocs/profile/` |
| **TechnicianDashboardBloc** | Technician statistics | `lib/blocs/technician_dashboard/` |
| **AdminBloc** | Admin panel operations | `lib/blocs/admin/` |
| **AddressBookBloc** | Saved addresses | `lib/blocs/address_book/` |

---

## Data Flow

### Complete Data Flow Example: User Login

```mermaid
graph LR
    A[User enters credentials] --> B[LoginScreen dispatches AuthLoginRequested]
    B --> C[AuthBloc receives event]
    C --> D[AuthBloc emits AuthLoading]
    D --> E[UI shows loading spinner]
    C --> F[AuthBloc calls AuthService.signInWithEmail]
    F --> G[AuthService calls Firebase Auth]
    G --> H{Success?}
    H -->|Yes| I[AuthService creates UserModel]
    I --> J[AuthBloc emits AuthAuthenticated]
    J --> K[UI navigates to home]
    H -->|No| L[Error thrown]
    L --> M[AuthBloc emits AuthError]
    M --> N[UI shows error message]
```

### State Management Flow

1. **User Action**: User interacts with UI (tap button, enter text)
2. **Event Dispatch**: Widget dispatches event to BLoC via `context.read<BLoC>().add(Event())`
3. **State Emission**: BLoC processes event and emits new state
4. **UI Reaction**: Widget wrapped in `BlocBuilder` or `BlocListener` reacts to state
5. **UI Update**: UI rebuilds based on new state

### Data Persistence Flow

```mermaid
graph TB
    A[User Action] --> B[BLoC Event]
    B --> C[Service Layer]
    C --> D{Data Source}
    D -->|Remote| E[Firebase Firestore]
    D -->|Local| F[Shared Preferences / Cache]
    E --> G[Data returned]
    F --> G
    G --> H[Model Created]
    H --> I[BLoC State Updated]
    I --> J[UI Rendered]
```

---

## Project Structure

```
lib/
├── blocs/                      # BLoC state management
│   ├── address_book/          # Saved addresses management
│   │   ├── address_book_bloc.dart
│   │   ├── address_book_event.dart
│   │   └── address_book_state.dart
│   ├── admin/                 # Admin dashboard logic
│   ├── auth/                  # Authentication logic
│   ├── booking/               # Service booking flow
│   ├── order/                 # Order management (customer & technician)
│   ├── profile/               # User profile management
│   ├── service/               # Service catalog browsing
│   ├── technician_dashboard/  # Technician statistics
│   └── bloc_observer.dart     # Global BLoC monitoring
│
├── config/                     # App configuration
│   └── firebase_options.dart  # Firebase platform configs
│
├── core/                       # Core utilities
│   ├── constants/             # App constants
│   ├── errors/                # Error handling
│   └── injection/             # Dependency injection setup
│
├── data/                       # Data layer (repositories, DTOs)
│   ├── datasources/           # Remote and local data sources
│   ├── models/                # Data transfer objects
│   └── repositories/          # Repository implementations
│
├── domain/                     # Domain layer (business logic)
│   ├── entities/              # Business entities
│   ├── repositories/          # Repository interfaces
│   └── usecases/              # Use cases
│
├── models/                     # Data models (33 models)
│   ├── user_model.dart        # User, Customer, Technician
│   ├── order_model.dart       # Service orders
│   ├── service_model.dart     # Service catalog
│   ├── review_model.dart      # Reviews and ratings
│   ├── chat_model.dart        # Chat conversations
│   ├── message_model.dart     # Chat messages
│   ├── payment_model.dart     # Payment records
│   └── ...                    # 26 more models
│
├── providers/                  # State providers (legacy, being replaced by BLoC)
│   ├── order_provider.dart
│   ├── service_provider.dart
│   └── theme_provider.dart
│
├── router/                     # Navigation configuration
│   └── app_router.dart        # GoRouter setup with all routes
│
├── screens/                    # UI screens (42 screens)
│   ├── admin/                 # Admin panel screens
│   ├── auth/                  # Login, signup, password reset
│   ├── customer/              # Customer-facing screens
│   │   ├── home_screen.dart
│   │   ├── booking_flow_screen.dart
│   │   ├── order_list_screen.dart
│   │   └── ...
│   ├── technician/            # Technician dashboard screens
│   ├── shared/                # Shared screens (profile, settings)
│   └── chat/                  # Chat screens
│
├── services/                   # Backend service integrations (15 services)
│   ├── auth_service.dart      # Firebase Auth wrapper
│   ├── firestore_service.dart # Firestore operations
│   ├── storage_service.dart   # Firebase Storage (file uploads)
│   ├── chat_service.dart      # Real-time chat
│   ├── review_service.dart    # Reviews and ratings
│   ├── notification_service.dart # FCM push notifications
│   ├── analytics_service.dart # Firebase Analytics
│   ├── performance_service.dart # Performance monitoring
│   ├── cache_service.dart     # Local data caching
│   ├── search_service.dart    # Service search functionality
│   ├── social_service.dart    # Social features (share, invite)
│   ├── address_service.dart   # Address management
│   └── ...
│
├── theme/                      # App theming
│   ├── app_theme.dart         # Light and dark themes
│   └── text_styles.dart       # Typography
│
├── utils/                      # Utility functions (9 utilities)
│   ├── exceptions.dart        # Custom exceptions
│   ├── validators.dart        # Input validation
│   ├── responsive_helper.dart # Responsive design utilities
│   ├── date_formatter.dart    # Date/time formatting
│   └── ...
│
├── widgets/                    # Reusable UI components (12 widgets)
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   ├── service_card.dart
│   ├── order_card.dart
│   ├── map_location_picker.dart
│   └── ...
│
├── firebase_config.dart        # Firebase initialization
├── main_common.dart            # Shared main app logic
├── main_dev.dart               # Development entry point
├── main_prod.dart              # Production entry point
└── main.dart                   # Default entry point
```

---

## Key Components

### 1. Authentication System

**Components**:
- `AuthBloc` - Manages authentication state
- `AuthService` - Interfaces with Firebase Auth
- `UserModel` - Represents authenticated user

**Features**:
- Email/password authentication
- Google Sign-In
- Facebook authentication (implemented but not used)
- Multi-role support (customer, technician, admin)

### 2. Service Catalog

**Components**:
- `ServiceBloc` - Manages service browsing
- `FirestoreService` - Fetches services from Firestore
- `ServiceModel` - Service data structure
- `CacheService` - Caches services locally (24-hour TTL)

**Features**:
- Browse all services
- Search services
- Filter by category
- Offline caching

### 3. Booking System

**Components**:
- `BookingBloc` - Manages booking flow
- `OrderModel` - Order data structure
- `AddressBookBloc` - Saved addresses
- Map integration with `MapLocationPicker`

**Features**:
- Multi-step booking flow
- Address selection (saved or map-based)
- Date/time scheduling
- Order confirmation

### 4. Order Management

**Components**:
- `CustomerOrderBloc` - Customer order tracking
- `TechnicianOrderBloc` - Technician job management
- `OrderProvider` - Real-time order updates
- `FirestoreService` - Order CRUD operations

**Features**:
- Real-time order status updates
- Pagination for large order lists
- Order filtering and sorting
- Status transitions (pending → confirmed → in_progress → completed)

### 5. Real-Time Chat

**Components**:
- `ChatService` - Firestore real-time listeners
- `ChatModel` - Conversation metadata
- `MessageModel` - Individual messages

**Features**:
- Real-time messaging between customer and technician
- Message timestamps
- Read/unread status
- Order-specific chats

### 6. Reviews & Ratings

**Components**:
- `ReviewService` - Review CRUD operations
- `ReviewModel` - Review data with ratings
- Rating aggregation in `TechnicianModel`

**Features**:
- 5-star rating system
- Text reviews with optional photos
- Multiple rating categories (quality, professionalism, value)
- Aggregate ratings on technician profiles

### 7. Admin Dashboard

**Components**:
- `AdminBloc` - Admin operations
- `DashboardStats` - Platform statistics
- Admin screens for user/service management

**Features**:
- User management (view, edit, delete)
- Service management (CRUD operations)
- Platform analytics
- Revenue tracking

---

## Design Decisions

### 1. Why BLoC Pattern?

**Chosen over**: Provider, Riverpod, MobX

**Reasons**:
- **Separation of Concerns**: Clear separation between UI and business logic
- **Testability**: BLoCs are pure Dart classes, easy to unit test
- **Predictability**: Unidirectional data flow makes debugging easier
- **Scalability**: Well-suited for large apps with complex state
- **Flutter Team Endorsed**: Official state management solution

**Tradeoffs**:
- More boilerplate code compared to Provider
- Steeper learning curve for beginners
- Requires more files per feature (event, state, bloc)

### 2. Why Firebase?

**Chosen over**: Custom backend, Supabase, AWS Amplify

**Reasons**:
- **Rapid Development**: Pre-built authentication, database, storage
- **Real-Time Capabilities**: Firestore offers real-time listeners out of the box
- **Scalability**: Automatic scaling without infrastructure management
- **Integrated Services**: Analytics, Crashlytics, Cloud Messaging in one ecosystem
- **Security**: Firestore Security Rules for fine-grained access control

**Tradeoffs**:
- Vendor lock-in
- Costs can scale with usage
- Limited complex query capabilities
- Offline support requires careful design

### 3. Why GoRouter over Navigator 2.0?

**Reasons**:
- **Declarative Routing**: Define routes in a single configuration
- **Deep Linking**: Built-in support for web URLs
- **Type Safety**: Type-safe route parameters
- **Redirection**: Easy authentication-based redirects
- **Nested Navigation**: Support for tab-based and drawer navigation

### 4. Clean Architecture Approach

**Reasoning**:
- **Maintainability**: Clear boundaries between layers
- **Testability**: Each layer can be tested independently
- **Flexibility**: Easy to swap out implementations (e.g., switch from Firebase to another backend)
- **Scalability**: Structure supports growth without becoming messy

**Current State**: Partially implemented
- ✅ Presentation layer fully separated
- ✅ Business logic in BLoCs
- ⚠️ Data layer needs abstraction (direct service usage instead of repository pattern)
- 🔄 Domain layer being developed (`lib/domain/` created)

### 5. Dependency Injection with get_it + injectable

**Chosen over**: Provider-based DI, manual injection

**Reasons**:
- **Decoupling**: Services not tied to widget tree
- **Testability**: Easy to mock dependencies
- **Code Generation**: `injectable` generates registration code
- **Performance**: Service locator pattern is fast

**Implementation**: Located in `lib/core/injection/`

### 6. Localization with easy_localization

**Reasoning**:
- **Simplicity**: JSON-based translations are easy to manage
- **RTL Support**: Built-in right-to-left language support (for Arabic)
- **Hot Reload**: Translation changes reflect immediately during development
- **Plural Support**: Handles plural forms correctly

**Supported Languages**: English (en), Arabic (ar)

### 7. Multi-Environment Setup

**Structure**:
- `main_dev.dart` - Development environment
- `main_prod.dart` - Production environment
- `main.dart` - Default (development)

**Benefits**:
- Separate Firebase projects for dev/prod
- Different configurations for testing
- Prevents accidental data corruption in production

---

## Future Architectural Improvements

Based on `COMPREHENSIVE_ANALYSIS.md`, recommended enhancements:

### 1. Repository Pattern Implementation
- **Current**: BLoCs call services directly
- **Target**: BLoCs depend on repository interfaces
- **Benefits**: Better testability, easier to switch data sources

### 2. Use Cases / Interactors
- **Current**: Business logic in BLoCs
- **Target**: Extract complex logic into use cases
- **Benefits**: Reusable business logic, cleaner BLoCs

### 3. Centralized Asset Management
- **Current**: Asset paths as strings scattered in code
- **Target**: `AppAssets` class with constants or code generation
- **Benefits**: Type safety, fewer runtime errors

### 4. Enhanced Error Handling
- **Current**: Try-catch in BLoCs with generic error states
- **Target**: Centralized error handling with custom exceptions
- **Benefits**: Consistent error UX, easier debugging

---

## Useful Resources

- [BLoC Pattern Official Docs](https://bloclibrary.dev/)
- [Flutter Clean Architecture](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course)
- [Firebase for Flutter](https://firebase.google.com/docs/flutter/setup)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Injectable DI](https://pub.dev/packages/injectable)

---

**Last Updated**: December 2025  
**Version**: 1.0.0
