# Home Repair App

A Flutter mobile application connecting homeowners with repair service technicians. Supports customers booking services and technicians managing jobs.

[![Flutter Version](https://img.shields.io/badge/Flutter-3.9.2+-blue.svg)](https://flutter.dev/)
[![CI](https://github.com/HassanHafez92/home_repair_app/actions/workflows/ci.yml/badge.svg)](https://github.com/HassanHafez92/home_repair_app/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/License-Private-red.svg)]()

## 📱 Quick Start

### For Developers
```bash
# Clone and setup
git clone <repository-url>
cd home_repair_app
flutter pub get

# Configure Firebase
flutterfire configure

# Run the app
flutter run
```

**New to the project?** → See our [Developer Onboarding Guide](docs/guides/developer_onboarding.md)

### For Users
- 👤 **Customers**: [How to book a service](docs/user_guides/customer_guide.md)
- 🔧 **Technicians**: [How to manage jobs](docs/user_guides/technician_guide.md)

---

## ✨ Features

### Customer Features
- 🔍 Browse and search home repair services
- 📅 Book appointments with qualified technicians
- 📍 Real-time order tracking with map integration
- ⭐ Reviews and ratings system
- 💬 Real-time chat with technicians
- 🌍 Multi-language support (English/Arabic with RTL)

### Technician Features
- 📋 View and accept repair requests
- 🚀 Real-time order status updates
- 💰 Earnings dashboard with analytics
- 📊 Performance statistics and reviews
- 🔔 Push notifications for new jobs
- 💬 Customer communication via chat

### Admin Features
- 👥 User and technician management
- 🛠️ Service catalog management
- 📈 Platform analytics dashboard

---

## 🏗️ Tech Stack

**Frontend**: Flutter 3.9.2+ | **State Management**: BLoC Pattern | **Backend**: Firebase

**Key Technologies**:
- Firebase Auth, Firestore, Storage, Analytics, Crashlytics
- Google Maps integration
- Real-time messaging
- Offline-first architecture

**For detailed architecture** → See [ARCHITECTURE.md](ARCHITECTURE.md)

---

## 📚 Documentation

### Core Documentation
- **[Architecture Guide](ARCHITECTURE.md)** - BLoC pattern, data flow, design decisions
- **[Firestore Schema](FIRESTORE_SCHEMA.md)** - Complete database structure and security rules
- **[API Reference](docs/API_REFERENCE.md)** - Service layer and data models documentation

### Developer Guides
- **[Onboarding](docs/guides/developer_onboarding.md)** - Environment setup and first-time configuration
- **[Contributing](docs/guides/contributing.md)** - Coding standards and workflow
- **[Testing Guide](docs/guides/testing_guide.md)** - Unit, widget, and integration testing

### User Guides
- **[Customer Guide](docs/user_guides/customer_guide.md)** - How to use the app as a customer
- **[Technician Guide](docs/user_guides/technician_guide.md)** - How to manage jobs as a technician

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.9.2+
- Firebase account
- Android Studio or VS Code
- Git

### Installation

```bash
# 1. Clone the repository
git clone <repository-url>
cd home_repair_app

# 2. Install dependencies
flutter pub get

# 3. Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Configure Firebase (if setting up new environment)
# Note: Project already configured for dev, stg, prod flavors
flutterfire configure

# 5. Run the app (Development Flavor)
flutter run --flavor dev -t lib/main_dev.dart
```

**For detailed setup instructions** → See [Developer Onboarding](docs/guides/developer_onboarding.md)

---

## 📁 Project Structure

```
lib/
├── config/             # App configuration & Flavor setup
├── core/               # Shared utilities, DI, constants
├── data/               # Data Layer (Repositories impl, Datasources, Models)
├── domain/             # Domain Layer (Entities, Repository Interfaces, UseCases)
├── presentation/       # Presentation Layer (BLoCs, Screens, Widgets)
│   ├── blocs/          # State management
│   ├── screens/        # UI Screens
│   └── widgets/        # Reusable components
├── router/             # Navigation configuration
├── services/           # External service wrappers
└── utils/              # Helper functions
```

**For complete structure** → See [ARCHITECTURE.md](ARCHITECTURE.md#project-structure)

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

**Current Coverage**: ~70% | **Target**: 80%+

**For testing best practices** → See [Testing Guide](docs/guides/testing_guide.md)

---

## 🔒 Security

- **Firebase Security Rules**: Implemented in `firestore.rules` and `storage.rules`
- **Role-Based Access Control**: Customer, Technician, Admin roles
- **Field-Level Validation**: Strict data validation in Firestore rules

**For complete security documentation** → See [FIRESTORE_SCHEMA.md](FIRESTORE_SCHEMA.md#security-rules-summary)

---

## 🌍 Localization

Supported languages: **English** | **العربية (Arabic)**

Translation files: `assets/translations/en.json`, `assets/translations/ar.json`

To add a language:
1. Create `assets/translations/<locale>.json`
2. Add locale to `supportedLocales` in `main.dart`
3. Run `flutter pub get`

---

## 🗺️ Roadmap

### Critical (P0) - Production Blockers
- 🔴 Payment Gateway Integration (Stripe/Razorpay)
- 🔴 Enhanced Security Rules
- 🔴 Email Verification Enforcement

### High Priority (P1)
- 🟡 Review & Rating System Enhancement
- 🟡 Offline Support & Caching
- 🟡 Performance Optimization

### Future Enhancements
- ⚪ Web Admin Panel
- ⚪ AI-Powered Technician Matching
- ⚪ Voice Ordering Integration

**For complete roadmap** → See [Known Issues section](#known-issues--todos) below

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Follow our [Coding Standards](docs/guides/contributing.md#coding-standards)
4. Write tests for new features
5. Submit a pull request

**For detailed guidelines** → See [Contributing Guide](docs/guides/contributing.md)

---

## 📞 Support

- **Documentation**: Browse the `/docs` directory
- **Issues**: Create an issue in the repository
- **Email**: support@homerepairapp.com

---

## 📄 License

This project is private and not published to pub.dev.

---

## Known Issues & TODOs

<details>
<summary><strong>Click to expand full roadmap and known issues</strong></summary>

### Legend
- 🔴 **P0**: Critical - Blocks production/revenue
- 🟡 **P1**: High - Important for user experience
- 🟢 **P2**: Medium - Nice to have
- ⚪ **P3**: Low - Future enhancement

**Status Indicators:** ✅ Complete | 🟡 Partial | ❌ Not started | 🔧 In progress

---

### Critical (P0) - Production Blockers

#### Payment & Revenue
- [ ] 🔴 **Payment Gateway Integration** ❌
  - Effort: High (2-3 weeks)
  - Recommended: Stripe or Razorpay
  
#### Security & Compliance
- [/] 🔴 **Enhanced Firestore Security Rules** 🔧
  - Effort: Low (2-3 days)
  
- [ ] 🔴 **Email Verification Enforcement** 🟡
  - Effort: Low (1-2 days)

#### User Engagement
- [x] 🔴 **Push Notifications via FCM** ✅
  - Status: Implemented

---

### High Priority (P1) - User Experience

- [ ] 🟡 Review & Rating System Enhancement
- [ ] 🟡 Real-time Chat Improvements
- [ ] 🟡 Offline Support & Caching
- [x] 🟡 Image Optimization ✅
- [x] 🟡 Firebase Analytics ✅
- [x] 🟡 Crashlytics ✅

---

### Medium Priority (P2) - Features

- [ ] 🟢 Password Reset in BLoC Pattern
- [ ] 🟢 Technician Availability Calendar
- [x] 🟢 Earnings Dashboard ✅
- [ ] 🟢 Promotional Campaigns

---

### Low Priority (P3) - Future

- [ ] ⚪ Web Admin Panel
- [ ] ⚪ Desktop Apps
- [ ] ⚪ AI-Powered Matching
- [ ] ⚪ Voice Orders
- [ ] ⚪ AR Visualization

**Priority Order for Next Sprint:**
1. Push Notifications ✅
2. Enhanced Security Rules (2-3 days)
3. Payment Integration (2-3 weeks)
4. Review System (1-2 weeks)

**Estimated Total Effort for P0+P1:** 10-12 weeks with 2-3 developers

</details>

---

<p align="center">
  <strong>Version 1.0.0+1</strong><br>
  Last Updated: December 2025
</p>

<p align="center">
  Made with ❤️ using Flutter
</p>
