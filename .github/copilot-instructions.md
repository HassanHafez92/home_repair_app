# Copilot / AI Agent Instructions for Home Repair App

This file gives concise, actionable context for AI coding agents working on the Home Repair App. Focus on discoverable patterns, concrete commands, and examples from the repository.

**Architecture (Big Picture)**
- The app uses Clean Architecture + BLoC. Key layers live under `lib/`: `blocs/` (business logic), `services/` & `providers/` (data access), `models/` (domain/data models), `screens/` and `widgets/` (presentation).
- Dependency injection is implemented with `get_it` + `injectable` (see `lib/core/injection/` and generated files). Routing uses `go_router` (`lib/router/app_router.dart`).

**Critical Files & Directories** (use these as entry points for changes)
- App entry points: `main.dart`, `main_dev.dart`, `main_prod.dart`, and shared logic in `main_common.dart`.
- BLoC examples: `lib/blocs/auth/` (`auth_bloc.dart`, `auth_event.dart`, `auth_state.dart`).
- Services: `lib/services/auth_service.dart`, `lib/services/firestore_service.dart`, `lib/services/notification_service.dart`.
- DI setup: `lib/core/injection/` and generated `*.config.dart` files (run codegen after edits).
- Firebase rules/config: `firestore.rules`, `storage.rules`, and `firebase_config.dart`.
- Translations: `assets/translations/en.json`, `assets/translations/ar.json`.
- Cloud Functions: `functions/` (TypeScript). See `functions/README.md` for deploy and local serve commands.

**Developer Workflows — Commands & Examples**
- Install dependencies and get started:
```bash
flutter pub get
```
- Code generation (models + injectable):
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
- Run app (dev):
```bash
flutter run -t lib/main_dev.dart
```
- Run tests:
```bash
flutter test
```
- Run functions locally and deploy (from `functions/`):
```bash
cd functions
npm install
npm run serve           # emulator
npm run build
npm run deploy          # or: firebase deploy --only functions:NAME
```
- Firebase configuration (first-time):
```bash
flutter pub global activate flutterfire_cli
flutterfire configure
```

**Project-Specific Conventions & Patterns**
- BLoC per feature: each feature has a folder under `lib/blocs/<feature>/` with `*_bloc.dart`, `*_event.dart`, `*_state.dart`.
- Services are thin wrappers around Firebase; prefer adding or updating a service in `lib/services/` instead of directly calling Firebase from UI.
- Use `json_serializable` model annotations — run `build_runner` after model changes.
- DI: register new classes via `@injectable` and update the injection config; then run codegen.
- Navigation: update `lib/router/app_router.dart` when adding routes; prefer named routes and route guards for auth-protected screens.
- Feature flags / environment: multiple `main_*.dart` files are used for dev/prod entrypoints. Prefer feature toggles there.

**Testing & Mocks**
- Unit / BLoC tests use `bloc_test` and `mockito`. Tests live under `test/` and follow the naming `<feature>_bloc_test.dart`.
- When adding tests that require DI, use a test injection container or reset `get_it` between tests.

**Integration Points & External Dependencies**
- Firebase (Auth, Firestore, Storage, Messaging, Analytics, Crashlytics): changes to schemas must be reflected in `FIRESTORE_SCHEMA.md` and `firestore.rules`.
- Cloud Functions under `functions/` integrate via scheduled triggers and Firestore listeners — deploy with `npm run deploy` from `functions/`.
- Maps & location: `google_maps_flutter`, `geolocator`, `geocoding`. API keys live in platform-specific config (check `android/local.properties` or platform build settings).

**When Making Changes — Checklist for AI Agents**
1. Update or add source files under `lib/` following existing folder structure and naming conventions. Reference `lib/blocs/auth/` and `lib/services/` for examples.
2. If you change models or add `@JsonSerializable` / `@injectable`, run `build_runner` to regenerate files.
3. If DI registrations changed, ensure generated injection files are updated and `get_it` is wired in `main_*.dart`.
4. Run unit tests (`flutter test`) and fix failing tests locally where possible.
5. Update `FIRESTORE_SCHEMA.md` and `firestore.rules` when altering data shapes or security.
6. For Firebase or Cloud Functions changes, test with the Emulator Suite before deploying to production.

**Examples for Common Tasks**
- Add a new BLoC: create `lib/blocs/<feature>/<feature>_bloc.dart`, `<feature>_event.dart`, `<feature>_state.dart`. Hook up in UI via `BlocProvider` and wire service via DI.
- Add a new model:
  - Create `lib/models/new_model.dart` with `@JsonSerializable()`
  - Update any service using it
  - Run `flutter pub run build_runner build --delete-conflicting-outputs`
- Register DI:
  - Annotate class with `@injectable`
  - Re-run injectable codegen (build_runner will run generators)

**Do Not**
- Do not change Firebase rules or billing-sensitive configs without CI/testing and a PR explaining the security impact.
- Do not commit large generated files without reason—prefer committing only generated files required by CI and follow repo policy.

**Where to Look for More Context**
- High-level: `README.md`, `ARCHITECTURE.md`, `FIRESTORE_SCHEMA.md`.
- Code examples: `lib/blocs/auth/`, `lib/services/auth_service.dart`, `lib/router/app_router.dart`.
- Backend: `functions/README.md`, `functions/src/`.

If anything above is unclear or you want more examples (e.g., a full sample BLoC PR template), say which area to expand and I will update this file.
