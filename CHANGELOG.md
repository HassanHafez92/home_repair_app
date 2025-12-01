# Changelog

All notable changes to the Home Repair App will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Payment gateway integration (Stripe/Razorpay)
- Enhanced security rules with field-level validation
- Email verification enforcement
- Web admin panel
- AI-powered technician matching

---

## [1.0.0] - 2025-12-01

### Added - Documentation
- **Complete architecture documentation** in `ARCHITECTURE.md`
  - BLoC pattern implementation with diagrams
  - Data flow visualizations
  - Project structure breakdown
  - Design decisions documented
- **Database schema documentation** in `FIRESTORE_SCHEMA.md`
  - All 6 collections documented
  - Security rules explained
  - Entity relationship diagrams
  - Query examples
- **Developer guides** in `docs/guides/`
  - Onboarding guide with step-by-step setup
  - Contributing guidelines with coding standards
  - Testing guide with examples
  - Troubleshooting guide
- **User guides** in `docs/user_guides/`
  - Customer guide
  - Technician guide
- **API reference** in `docs/api/services.md`
- Restructured `README.md` with clear navigation

### Added - Features
- **Multi-environment support** (dev/prod)
  - `main_dev.dart` for development
  - `main_prod.dart` for production
- **Dependency injection** with get_it and injectable
- **Google Maps integration**
  - Map location picker for addresses
  - Real-time technician tracking
- **Real-time chat** between customers and technicians
- **Review and rating system**
  - 5-star ratings
  - Category ratings (quality, professionalism, punctuality, value)
  - Photo uploads in reviews
- **Push notifications** via Firebase Cloud Messaging
- **Analytics and Crashlytics** integration
- **Image optimization**
  - Cached network images
  - Lazy loading
  - Compression before upload
- **Offline persistence** with Firestore caching
- **Localization** (English and Arabic with RTL support)

### Added - Technical
- **BLoC pattern state management** (8 feature BLoCs)
- **Comprehensive Firestore security rules**
  - Role-based access control
  - Field-level validation
  - Time-based restrictions
- **33 data models** with JSON serialization
- **15 service classes** for backend integration
- **Pagination** for orders and reviews
- **Error handling system** with custom exceptions
- **Input validation framework**
- **Performance monitoring**

### Security
- Implemented Firebase Security Rules for Firestore
- Role-based access control (customer, technician, admin)
- Field-level data validation
- Storage security rules for file uploads

---

## [0.2.0] - 2025-11-30

### Added
- Technician dashboard with earnings statistics
- Order status workflow (7 statuses)
- Saved addresses functionality
- Profile picture upload
- Multi-step booking flow

### Fixed
- Translation key duplicates in `en.json` and `ar.json`
- Firebase App Check deprecation warnings
- Null safety violations in admin dashboard
- Signup navigation flow

---

## [0.1.0] - 2025-11-27

### Added
- Initial project structure with Flutter 3.9.2
- Firebase integration (Auth, Firestore, Storage)
- Basic authentication (email/password, Google Sign-In)
- Service catalog browsing
- Simple booking flow
- Order management for customers
- Technician order view
- Admin panel basics

### Technical Debt
- TODO: Implement repository pattern
- TODO: Add comprehensive test coverage
- TODO: Implement proper error handling

---

## Version History

| Version | Release Date | Key Features |
|---------|--------------|--------------|
| 1.0.0 | 2025-12-01 | Complete documentation, chat, reviews, maps |
| 0.2.0 | 2025-11-30 | Technician dashboard, saved addresses |
| 0.1.0 | 2025-11-27 | Initial MVP release |

---

## Upgrade Notes

### Upgrading to 1.0.0

**Breaking Changes**: None

**New Dependencies**:
- `get_it: ^7.6.4`
- `injectable: ^2.3.2`
- `google_maps_flutter: ^2.10.0`
- `geocoding: ^2.2.1`
- `geolocator: ^13.0.2`

**Migration Steps**:
1. Run `flutter pub get` to install new dependencies
2. Run code generation: `flutter pub run build_runner build --delete-conflicting-outputs`
3. Update Firebase security rules: `firebase deploy --only firestore:rules`
4. No code changes required - fully backward compatible

**Database Changes**:
- Added denormalized fields to `orders` collection (`serviceName`, `customerName`, `customerPhoneNumber`)
- Existing data will continue to work; new orders will include denormalized fields

---

## Contributing

See [CONTRIBUTING.md](docs/guides/contributing.md) for guidelines on how to contribute to this project.

---

_Format based on [Keep a Changelog](https://keepachangelog.com/)_
_Last Updated: December 2025_
