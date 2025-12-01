import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:home_repair_app/config/app_config.dart';
import 'firebase_config.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/address_service.dart';
import 'package:home_repair_app/services/snackbar_service.dart';
import 'domain/repositories/i_auth_repository.dart';
import 'domain/repositories/i_user_repository.dart';
import 'domain/repositories/i_order_repository.dart';
import 'domain/repositories/i_service_repository.dart';
import 'domain/repositories/i_admin_repository.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'data/repositories/order_repository_impl.dart';
import 'data/repositories/service_repository_impl.dart';
import 'data/repositories/admin_repository_impl.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/service/service_bloc.dart';
import 'blocs/service/service_event.dart';
import 'blocs/order/customer_order_bloc.dart';
import 'blocs/order/technician_order_bloc.dart';
import 'blocs/technician_dashboard/technician_dashboard_bloc.dart';
import 'blocs/booking/booking_bloc.dart';
import 'blocs/profile/profile_bloc.dart';
import 'blocs/admin/admin_bloc.dart';
import 'blocs/address_book/address_book_bloc.dart';
import 'blocs/bloc_observer.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';

Future<void> mainCommon(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();

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
    // Initialize services and repositories
    final authService = AuthService();
    final firestoreService = FirestoreService();
    final storageService = StorageService();
    final addressService = AddressService();

    // Repositories
    final authRepository = AuthRepositoryImpl();
    final userRepository = UserRepositoryImpl();
    final orderRepository = OrderRepositoryImpl();
    final serviceRepository = ServiceRepositoryImpl();
    final adminRepository = AdminRepositoryImpl(
      firestore: FirebaseFirestore.instance,
    );

    return MultiBlocProvider(
      providers: [
        // Service Providers (Legacy)
        RepositoryProvider<AuthService>.value(value: authService),
        RepositoryProvider<FirestoreService>.value(value: firestoreService),
        RepositoryProvider<StorageService>.value(value: storageService),
        RepositoryProvider<AddressService>.value(value: addressService),

        // Repository Providers
        RepositoryProvider<IAuthRepository>.value(value: authRepository),
        RepositoryProvider<IUserRepository>.value(value: userRepository),
        RepositoryProvider<IOrderRepository>.value(value: orderRepository),
        RepositoryProvider<IServiceRepository>.value(value: serviceRepository),
        RepositoryProvider<IAdminRepository>.value(value: adminRepository),

        // BLoC Providers
        BlocProvider(
          create: (context) => AuthBloc(
            authRepository: authRepository,
            userRepository: userRepository,
          ),
        ),
        BlocProvider(
          create: (context) =>
              ServiceBloc(serviceRepository: serviceRepository)
                ..add(const ServiceLoadRequested()),
        ),
        BlocProvider(
          create: (context) =>
              CustomerOrderBloc(orderRepository: orderRepository),
        ),
        BlocProvider(
          create: (context) =>
              TechnicianOrderBloc(orderRepository: orderRepository),
        ),
        BlocProvider(
          create: (context) =>
              TechnicianDashboardBloc(userRepository: userRepository),
        ),
        BlocProvider(
          create: (context) => BookingBloc(orderRepository: orderRepository),
        ),
        BlocProvider(
          create: (context) => ProfileBloc(
            authRepository: authRepository,
            userRepository: userRepository,
            storageService: storageService,
          ),
        ),
        BlocProvider(
          create: (context) => AdminBloc(
            adminRepository: adminRepository,
            orderRepository: orderRepository,
          ),
        ),
        BlocProvider(
          create: (context) => AddressBookBloc(addressService: addressService),
        ),
      ],
      child: Builder(
        builder: (context) {
          final appRouter = AppRouter(context.read<AuthBloc>());
          // Set up notification tap handler
          NotificationService().onNotificationTapped = (String? payload) {
            if (payload != null) {
              debugPrint('🔔 Navigating to payload: $payload');
              // TODO: Implement specific navigation based on payload
              // For now, we just log it. In a real app, you'd parse the payload
              // and navigate to the specific screen, e.g.:
              // appRouter.router.push('/orders/$payload');
            }
          };
          return MaterialApp.router(
            scaffoldMessengerKey: SnackBarService().scaffoldMessengerKey,
            title: config.appTitle,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
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
