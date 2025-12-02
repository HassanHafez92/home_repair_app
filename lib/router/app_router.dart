// File: lib/router/app_router.dart
// Purpose: Centralized routing configuration with role-based guards.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../models/user_model.dart';

// Screens
import '../screens/auth/splash_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/technician_signup_screen.dart';
import '../screens/customer/home_screen.dart';
import '../screens/customer/edit_profile_screen.dart';
import '../screens/customer/saved_addresses_screen.dart';
import '../screens/customer/payment_methods_screen.dart';
import '../screens/customer/notifications_settings_screen.dart';
import '../screens/customer/help_support_screen.dart';
import '../screens/customer/about_screen.dart';
import '../screens/customer/notifications_screen.dart';
import '../screens/customer/order_details_screen.dart';
import '../screens/auth/email_verification_screen.dart';
import '../screens/technician/technician_home_screen.dart';
import '../screens/technician/order_detail_screen.dart';
import '../screens/admin/admin_layout.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/order_model.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/chat/chat_screen.dart';

// Helper class to convert BLoC stream to ChangeNotifier for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  final AuthBloc authBloc;
  late final GoRouter router;

  AppRouter(this.authBloc) {
    router = GoRouter(
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      initialLocation: '/',
      debugLogDiagnostics: true,
      redirect: (context, state) {
        // Get current auth state
        final authState = authBloc.state;
        final isLoggedIn = authState is AuthAuthenticated;
        final currentUser = authState is AuthAuthenticated
            ? authState.user
            : null;
        final userRole = currentUser?.role;

        final isLoggingIn =
            state.uri.toString() == '/login' ||
            state.uri.toString() == '/signup' ||
            state.uri.toString() == '/technician-signup' ||
            state.uri.toString() == '/welcome';
        final isSplash = state.uri.toString() == '/';
        final isEmailVerification =
            state.uri.toString() == '/email-verification';

        debugPrint(
          'AppRouter: Redirect check. Path: ${state.uri}, LoggedIn: $isLoggedIn, Role: $userRole, State: ${authState.runtimeType}',
        );

        // If not logged in and not on auth/splash pages, redirect to welcome
        if (!isLoggedIn && !isLoggingIn && !isSplash && !isEmailVerification) {
          debugPrint('AppRouter: Redirecting to /welcome');
          return '/welcome';
        }

        // Handle Splash Screen:
        // If on splash and unauthenticated (and not initial), go to welcome
        if (isSplash && !isLoggedIn) {
          if (authState is AuthInitial) {
            // Still loading auth state, stay on splash
            return null;
          }
          debugPrint(
            'AppRouter: Unauthenticated on splash, redirecting to /welcome',
          );
          return '/welcome';
        }

        // If logged in but email not verified, redirect to verification screen
        if (isLoggedIn && !isEmailVerification) {
          final authService = AuthService();
          // Reload user to get fresh verification status
          authService.reloadUser();
          if (!authService.isEmailVerified) {
            debugPrint(
              'AppRouter: Email not verified, redirecting to /email-verification',
            );
            return '/email-verification';
          }
        }

        // If logged in and trying to access auth pages, redirect to dashboard
        if (isLoggedIn && (isLoggingIn || isSplash)) {
          final role = userRole;
          debugPrint('AppRouter: Redirecting to dashboard for role: $role');
          if (role == UserRole.technician) {
            return '/technician/dashboard';
          } else if (role == UserRole.admin) {
            return '/admin/dashboard';
          } else {
            return '/customer/home';
          }
        }

        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
        GoRoute(
          path: '/welcome',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: '/technician-signup',
          builder: (context, state) => const TechnicianSignupScreen(),
        ),
        GoRoute(
          path: '/email-verification',
          builder: (context, state) => const EmailVerificationScreen(),
        ),

        // Customer Routes
        GoRoute(
          path: '/customer/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/customer/edit-profile',
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: '/customer/addresses',
          builder: (context, state) => const SavedAddressesScreen(),
        ),
        GoRoute(
          path: '/customer/payment-methods',
          builder: (context, state) => const PaymentMethodsScreen(),
        ),
        GoRoute(
          path: '/customer/notifications',
          builder: (context, state) => const NotificationsSettingsScreen(),
        ),
        GoRoute(
          path: '/customer/help',
          builder: (context, state) => const HelpSupportScreen(),
        ),
        GoRoute(
          path: '/customer/about',
          builder: (context, state) => const AboutScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/customer/order/:orderId',
          builder: (context, state) {
            final orderId = state.pathParameters['orderId']!;
            final firestoreService = Provider.of<FirestoreService>(
              context,
              listen: false,
            );
            return OrderDetailsScreenWrapper(
              orderId: orderId,
              firestoreService: firestoreService,
            );
          },
        ),

        // Technician Routes
        GoRoute(
          path: '/technician/dashboard',
          builder: (context, state) => const TechnicianHomeScreen(),
        ),
        GoRoute(
          path: '/technician/order/:orderId',
          builder: (context, state) {
            final orderId = state.pathParameters['orderId']!;
            final firestoreService = Provider.of<FirestoreService>(
              context,
              listen: false,
            );
            return TechnicianOrderDetailScreenWrapper(
              orderId: orderId,
              firestoreService: firestoreService,
            );
          },
        ),

        // Admin Routes
        GoRoute(
          path: '/admin/dashboard',
          builder: (context, state) => const AdminLayout(),
        ),
        // Chat Routes
        GoRoute(
          path: '/chats',
          builder: (context, state) => const ChatListScreen(),
        ),
        GoRoute(
          path: '/chat/:chatId',
          builder: (context, state) {
            final chatId = state.pathParameters['chatId']!;
            final extra = state.extra as Map<String, dynamic>?;
            final otherUserName = extra?['otherUserName'] as String? ?? 'Chat';
            final otherUserId = extra?['otherUserId'] as String? ?? '';

            return ChatScreen(
              chatId: chatId,
              otherUserName: otherUserName,
              otherUserId: otherUserId,
            );
          },
        ),
      ],
    );
  }
}

// Wrapper to fetch order with proper Provider context
class OrderDetailsScreenWrapper extends StatelessWidget {
  final String orderId;
  final FirestoreService firestoreService;

  const OrderDetailsScreenWrapper({
    super.key,
    required this.orderId,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OrderModel?>(
      future: firestoreService.getOrder(orderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Order not found')),
          );
        }
        return OrderDetailsScreen(order: snapshot.data!);
      },
    );
  }
}

class TechnicianOrderDetailScreenWrapper extends StatelessWidget {
  final String orderId;
  final FirestoreService firestoreService;

  const TechnicianOrderDetailScreenWrapper({
    super.key,
    required this.orderId,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OrderModel?>(
      future: firestoreService.getOrder(orderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Order not found')),
          );
        }
        return OrderDetailScreen(order: snapshot.data!);
      },
    );
  }
}
