import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_repair_app/config/app_config.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'firebase_config.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/address_service.dart';
import 'package:home_repair_app/services/snackbar_service.dart';
import 'core/di/injection_container.dart';
import 'core/services/service_integration.dart';
import 'services/performance_monitoring_service.dart';
import 'domain/repositories/i_auth_repository.dart';
import 'domain/repositories/i_user_repository.dart';
import 'domain/repositories/i_order_repository.dart';
import 'domain/repositories/i_service_repository.dart';
import 'domain/repositories/i_admin_repository.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_state.dart';
import 'domain/entities/user_entity.dart';
import 'presentation/blocs/service/service_bloc.dart';
import 'presentation/blocs/service/service_event.dart';
import 'presentation/blocs/order/customer_order_bloc.dart';
import 'presentation/blocs/order/technician_order_bloc.dart';
import 'presentation/blocs/technician_dashboard/technician_dashboard_bloc.dart';
import 'presentation/blocs/booking/booking_bloc.dart';
import 'presentation/blocs/profile/profile_bloc.dart';
import 'presentation/blocs/admin/admin_bloc.dart';
import 'presentation/blocs/address_book/address_book_bloc.dart';
import 'presentation/blocs/bloc_observer.dart';
import 'presentation/theme/app_theme_v2.dart';
import 'router/app_router.dart';
import 'services/locale_provider.dart';

Future<void> mainCommon(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable high refresh rate (120Hz) on supported devices
  try {
    await FlutterDisplayMode.setHighRefreshRate();
  } catch (_) {
    // Silently fail on unsupported devices
  }

  // Initialize Firebase (only once - auto-initialization is disabled in AndroidManifest)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // ignore: avoid_print
    print('Firebase initialization error: $e');
    // Continue even if Firebase init fails to prevent app crash
  }

  // Enable Firestore offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Initialize App Check
  // Note: In a real scenario, you might use different keys for dev/prod in AppConfig
  // ignore: deprecated_member_use
  await FirebaseAppCheck.instance.activate(
    // ignore: deprecated_member_use
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    // ignore: deprecated_member_use
    androidProvider: AndroidProvider.debug,
    // ignore: deprecated_member_use
    appleProvider: AppleProvider.debug,
  );

  // Configure image cache size limits for memory optimization
  PaintingBinding.instance.imageCache.maximumSize = 100; // Max 100 images
  PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50 MB

  // Initialize localization
  await EasyLocalization.ensureInitialized();

  // Set up BLoC observer for debugging
  if (config.enableLogs) {
    Bloc.observer = AppBlocObserver();
  }

  // Phase 1: Initialize Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Phase 1: Initialize Notifications
  await NotificationService().initialize();

  // Initialize SharedPreferences and then all dependencies via DI container
  final sharedPreferences = await SharedPreferences.getInstance();
  await initializeDependencies(sharedPreferences);

  // Initialize LocaleProvider with the saved locale from SharedPreferences
  // EasyLocalization stores locale in SharedPreferences with key 'locale'
  final savedLocaleString = sharedPreferences.getString('locale');
  if (savedLocaleString != null && savedLocaleString.isNotEmpty) {
    // Format is 'en' or 'ar'
    LocaleProvider.setLanguageCode(savedLocaleString.split('_').first);
  }

  // Phase 1: Initialize all Phase 1 services (performance, logging, error handling, etc.)
  await ServiceIntegration().initialize(
    continueOnError: true, // Don't block app startup on service failures
    onProgress: (serviceName, status) {
      if (config.enableLogs) {
        debugPrint('📦 Service: $serviceName - $status');
      }
    },
  );

  // Mark app as ready for performance tracking
  PerformanceMonitoringService().markAppReady();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MyApp(config: config),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AppConfig config;

  const MyApp({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Service Providers (Legacy) - accessed via DI container
        RepositoryProvider<AuthService>.value(value: sl<AuthService>()),
        RepositoryProvider<FirestoreService>.value(
          value: sl<FirestoreService>(),
        ),
        RepositoryProvider<StorageService>.value(value: sl<StorageService>()),
        RepositoryProvider<AddressService>.value(value: sl<AddressService>()),

        // Repository Providers - accessed via DI container
        RepositoryProvider<IAuthRepository>.value(value: sl<IAuthRepository>()),
        RepositoryProvider<IUserRepository>.value(value: sl<IUserRepository>()),
        RepositoryProvider<IOrderRepository>.value(
          value: sl<IOrderRepository>(),
        ),
        RepositoryProvider<IServiceRepository>.value(
          value: sl<IServiceRepository>(),
        ),
        RepositoryProvider<IAdminRepository>.value(
          value: sl<IAdminRepository>(),
        ),

        // BLoC Providers - created via DI container factory
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<ServiceBloc>(
          create: (_) => sl<ServiceBloc>()..add(const ServiceLoadRequested()),
        ),
        BlocProvider<CustomerOrderBloc>(create: (_) => sl<CustomerOrderBloc>()),
        BlocProvider<TechnicianOrderBloc>(
          create: (_) => sl<TechnicianOrderBloc>(),
        ),
        BlocProvider<TechnicianDashboardBloc>(
          create: (_) => sl<TechnicianDashboardBloc>(),
        ),
        BlocProvider<BookingBloc>(create: (_) => sl<BookingBloc>()),
        BlocProvider<ProfileBloc>(create: (_) => sl<ProfileBloc>()),
        BlocProvider<AdminBloc>(create: (_) => sl<AdminBloc>()),
        BlocProvider<AddressBookBloc>(create: (_) => sl<AddressBookBloc>()),
      ],
      child: Builder(
        builder: (context) {
          final appRouter = AppRouter(context.read<AuthBloc>());
          // Set up notification tap handler
          NotificationService().onNotificationTapped = (String? payload) {
            if (payload != null && payload.isNotEmpty) {
              debugPrint('🔔 Navigating to payload: $payload');

              // Get current user to determine navigation route
              final authState = context.read<AuthBloc>().state;
              if (authState is! AuthAuthenticated) {
                debugPrint('🔔 User not authenticated, skipping navigation');
                return;
              }

              final userRole = authState.user.role;

              // Parse payload - it can be an orderId or a type:value format
              // Format: just orderId OR "order:orderId" OR "chat:chatId"
              if (payload.contains(':')) {
                // Format: "type:value"
                final parts = payload.split(':');
                final type = parts[0];
                final value = parts.length > 1 ? parts[1] : '';

                switch (type) {
                  case 'order':
                    _navigateToOrder(appRouter, userRole, value);
                    break;
                  case 'chat':
                    appRouter.router.push('/chat/$value');
                    break;
                  default:
                    debugPrint('🔔 Unknown notification type: $type');
                }
              } else {
                // Assume it's an orderId
                _navigateToOrder(appRouter, userRole, payload);
              }
            }
          };
          return MaterialApp.router(
            scaffoldMessengerKey: SnackBarService().scaffoldMessengerKey,
            title: config.appTitle,
            theme: AppThemeV2.lightTheme,
            darkTheme: AppThemeV2.darkTheme,
            themeMode: ThemeMode.system,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            debugShowCheckedModeBanner: config.isDev,
            routerConfig: appRouter.router,
          );
        },
      ),
    );
  }
}

/// Helper function to navigate to order detail screen based on user role
void _navigateToOrder(AppRouter appRouter, UserRole userRole, String orderId) {
  if (orderId.isEmpty) {
    debugPrint('🔔 Empty orderId, skipping navigation');
    return;
  }

  final route = userRole == UserRole.technician
      ? '/technician/order/$orderId'
      : '/customer/order/$orderId';

  debugPrint('🔔 Navigating to: $route');
  appRouter.router.push(route);
}
