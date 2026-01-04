// File: lib/router/app_router.dart
// Purpose: Centralized routing configuration with role-based guards.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../presentation/blocs/auth/auth_bloc.dart';
import '../presentation/blocs/auth/auth_state.dart';
import '../domain/entities/user_entity.dart';

// Screens
import '../presentation/screens/auth/splash_screen.dart';
import '../presentation/screens/auth/welcome_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/signup_screen.dart';
import '../presentation/screens/auth/technician_signup_screen.dart';
import '../presentation/screens/customer/home_screen.dart';
import '../presentation/screens/customer/edit_profile_screen.dart';
import '../presentation/screens/customer/saved_addresses_screen.dart';

import '../presentation/screens/customer/notifications_settings_screen.dart';
import '../presentation/screens/customer/help_support_screen.dart';
import '../presentation/screens/customer/about_screen.dart';
import '../presentation/screens/customer/notifications_screen.dart';
import '../presentation/screens/customer/order_details_screen.dart';
import '../presentation/screens/customer/recommendations_screen.dart';
import '../presentation/screens/customer/referral_screen.dart';
import '../presentation/screens/customer/service_history_screen.dart';
import '../presentation/screens/customer/service_details_screen.dart';
import '../presentation/screens/customer/add_edit_address_screen.dart';
import '../presentation/screens/customer/add_review_screen.dart';
import '../presentation/screens/customer/booking/booking_flow_screen.dart';
import '../presentation/screens/auth/email_verification_screen.dart';
import '../presentation/screens/technician/technician_home_screen.dart';
import '../presentation/screens/technician/order_detail_screen.dart';
import '../presentation/screens/technician/diagnostics_screen.dart';
import '../presentation/screens/technician/performance_dashboard.dart';
import '../presentation/screens/technician/permissions_helper_screen.dart';
import '../presentation/screens/technician/edit_profile_screen.dart' as tech;
import '../presentation/screens/technician/portfolio_screen.dart';
import '../presentation/screens/technician/certifications_screen.dart';
import '../presentation/screens/technician/service_areas_screen.dart';
import '../presentation/screens/technician/account_settings_screen.dart';
import '../presentation/screens/technician/notification_settings_screen.dart';
import '../presentation/screens/technician/privacy_settings_screen.dart';
import '../presentation/screens/technician/withdrawal_screen.dart';
import '../presentation/screens/technician/job_completion_screen.dart';
import '../presentation/screens/technician/order_action_screen.dart';
import '../presentation/screens/customer/orders_screen.dart';
import '../presentation/screens/customer/profile_screen.dart';
import '../presentation/screens/customer/services_screen.dart';
import '../presentation/screens/admin/admin_layout.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/order_model.dart';
import '../models/service_model.dart';
import '../presentation/screens/chat/chat_list_screen.dart';
import '../presentation/screens/chat/chat_screen.dart';
import '../presentation/widgets/async_data_screen.dart';

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
            final firestoreService = context.read<FirestoreService>();
            return AsyncDataScreen<OrderModel>(
              future: firestoreService.getOrder(orderId),
              builder: (order) => OrderDetailsScreen(order: order.toEntity()),
              errorTitle: 'Error',
              errorMessage: 'Order not found',
            );
          },
        ),
        GoRoute(
          path: '/customer/recommendations',
          builder: (context, state) => const RecommendationsScreen(),
        ),
        GoRoute(
          path: '/customer/referrals',
          builder: (context, state) {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              return ReferralScreen(
                userId: authState.user.id,
                userName: authState.user.fullName,
              );
            }
            // Fallback - redirect handled by guards but provide empty screen
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ),
        GoRoute(
          path: '/customer/service-history',
          builder: (context, state) => const ServiceHistoryScreen(),
        ),
        GoRoute(
          path: '/customer/service/:serviceId',
          builder: (context, state) {
            final serviceId = state.pathParameters['serviceId']!;
            final firestoreService = context.read<FirestoreService>();
            return AsyncDataScreen<ServiceModel>(
              future: firestoreService.getService(serviceId),
              builder: (service) =>
                  ServiceDetailsScreen(service: service.toEntity()),
              errorTitle: 'Error',
              errorMessage: 'Service not found',
            );
          },
        ),
        GoRoute(
          path: '/customer/book/:serviceId',
          builder: (context, state) {
            final serviceId = state.pathParameters['serviceId']!;
            final firestoreService = context.read<FirestoreService>();
            return AsyncDataScreen<ServiceModel>(
              future: firestoreService.getService(serviceId),
              builder: (service) =>
                  BookingFlowScreen(service: service.toEntity()),
              errorTitle: 'Error',
              errorMessage: 'Service not found',
            );
          },
        ),
        GoRoute(
          path: '/customer/address/add',
          builder: (context, state) {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              return AddEditAddressScreen(userId: authState.user.id);
            }
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ),
        GoRoute(
          path: '/customer/review/:orderId/:technicianId',
          builder: (context, state) {
            final orderId = state.pathParameters['orderId']!;
            final technicianId = state.pathParameters['technicianId']!;
            return AddReviewScreen(
              orderId: orderId,
              technicianId: technicianId,
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
            final firestoreService = context.read<FirestoreService>();
            return AsyncDataScreen<OrderModel>(
              future: firestoreService.getOrder(orderId),
              builder: (order) => OrderDetailScreen(order: order.toEntity()),
              errorTitle: 'Error',
              errorMessage: 'Order not found',
            );
          },
        ),
        GoRoute(
          path: '/technician/diagnostics',
          builder: (context, state) => const DiagnosticsScreen(),
        ),
        GoRoute(
          path: '/technician/performance',
          builder: (context, state) {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              return PerformanceDashboard(technicianId: authState.user.id);
            }
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ),
        GoRoute(
          path: '/technician/permissions',
          builder: (context, state) => const PermissionsHelperScreen(),
        ),
        GoRoute(
          path: '/technician/edit-profile',
          builder: (context, state) => const tech.EditProfileScreen(),
        ),
        GoRoute(
          path: '/technician/portfolio',
          builder: (context, state) => const PortfolioScreen(),
        ),
        GoRoute(
          path: '/technician/certifications',
          builder: (context, state) => const CertificationsScreen(),
        ),
        GoRoute(
          path: '/technician/service-areas',
          builder: (context, state) => const ServiceAreasScreen(),
        ),
        GoRoute(
          path: '/technician/account-settings',
          builder: (context, state) => const AccountSettingsScreen(),
        ),
        GoRoute(
          path: '/technician/notification-settings',
          builder: (context, state) => const NotificationSettingsScreen(),
        ),
        GoRoute(
          path: '/technician/privacy-settings',
          builder: (context, state) => const PrivacySettingsScreen(),
        ),
        GoRoute(
          path: '/technician/withdrawal',
          builder: (context, state) => const WithdrawalScreen(),
        ),
        GoRoute(
          path: '/technician/order/:orderId/action',
          builder: (context, state) {
            final orderId = state.pathParameters['orderId']!;
            final firestoreService = context.read<FirestoreService>();
            return AsyncDataScreen<OrderModel>(
              future: firestoreService.getOrder(orderId),
              builder: (order) => OrderActionScreen(order: order.toEntity()),
              errorTitle: 'Error',
              errorMessage: 'Order not found',
            );
          },
        ),
        GoRoute(
          path: '/technician/order/:orderId/complete',
          builder: (context, state) {
            final orderId = state.pathParameters['orderId']!;
            final firestoreService = context.read<FirestoreService>();
            return AsyncDataScreen<OrderModel>(
              future: firestoreService.getOrder(orderId),
              builder: (order) => JobCompletionScreen(order: order.toEntity()),
              errorTitle: 'Error',
              errorMessage: 'Order not found',
            );
          },
        ),

        // Customer Bottom Nav Screens
        GoRoute(
          path: '/customer/orders',
          builder: (context, state) => const OrdersScreen(),
        ),
        GoRoute(
          path: '/customer/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/customer/services',
          builder: (context, state) => const ServicesScreen(),
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
