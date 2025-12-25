import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'package:home_repair_app/core/network/network_info.dart';

// Data Sources - Remote
import 'package:home_repair_app/data/datasources/remote/auth_remote_data_source.dart';
import 'package:home_repair_app/data/datasources/remote/user_remote_data_source.dart';
import 'package:home_repair_app/data/datasources/remote/order_remote_data_source.dart';
import 'package:home_repair_app/data/datasources/remote/service_remote_data_source.dart';
import 'package:home_repair_app/data/datasources/remote/i_auth_remote_data_source.dart';
import 'package:home_repair_app/data/datasources/remote/i_user_remote_data_source.dart';
import 'package:home_repair_app/data/datasources/remote/i_order_remote_data_source.dart';
import 'package:home_repair_app/data/datasources/remote/i_service_remote_data_source.dart';

// Data Sources - Local
import 'package:home_repair_app/data/datasources/local/user_local_data_source.dart';
import 'package:home_repair_app/data/datasources/local/service_local_data_source.dart';
import 'package:home_repair_app/data/datasources/local/i_user_local_data_source.dart';

// Domain - Repositories (Interfaces)
import 'package:home_repair_app/domain/repositories/i_auth_repository.dart';
import 'package:home_repair_app/domain/repositories/i_user_repository.dart';
import 'package:home_repair_app/domain/repositories/i_order_repository.dart';
import 'package:home_repair_app/domain/repositories/i_service_repository.dart';
import 'package:home_repair_app/domain/repositories/i_admin_repository.dart';
import 'package:home_repair_app/domain/repositories/i_address_repository.dart';
import 'package:home_repair_app/domain/repositories/i_chat_repository.dart';
import 'package:home_repair_app/domain/repositories/i_notification_repository.dart';
import 'package:home_repair_app/domain/repositories/i_review_repository.dart';

// Data - Repository Implementations
import 'package:home_repair_app/data/repositories/auth_repository_impl.dart';
import 'package:home_repair_app/data/repositories/user_repository_impl.dart';
import 'package:home_repair_app/data/repositories/order_repository_impl.dart';
import 'package:home_repair_app/data/repositories/service_repository_impl.dart';
import 'package:home_repair_app/data/repositories/admin_repository_impl.dart';
import 'package:home_repair_app/data/repositories/address_repository_impl.dart';
import 'package:home_repair_app/data/repositories/chat_repository_impl.dart';
import 'package:home_repair_app/data/repositories/notification_repository_impl.dart';
import 'package:home_repair_app/data/repositories/review_repository_impl.dart';

// Domain - Use Cases (Auth)
import 'package:home_repair_app/domain/usecases/auth/sign_in_with_email.dart';
import 'package:home_repair_app/domain/usecases/auth/sign_up_with_email.dart';
import 'package:home_repair_app/domain/usecases/auth/sign_in_with_google.dart';
import 'package:home_repair_app/domain/usecases/auth/sign_in_with_facebook.dart';
import 'package:home_repair_app/domain/usecases/auth/sign_out.dart';
import 'package:home_repair_app/domain/usecases/auth/send_password_reset_email.dart';

// Domain - Use Cases (Order)
import 'package:home_repair_app/domain/usecases/order/create_order.dart'
    as order_uc;
import 'package:home_repair_app/domain/usecases/order/update_order_status.dart'
    as order_uc;
import 'package:home_repair_app/domain/usecases/order/complete_order.dart';
import 'package:home_repair_app/domain/usecases/order/get_order.dart';

// Domain - Use Cases (User)
import 'package:home_repair_app/domain/usecases/user/get_user.dart';
import 'package:home_repair_app/domain/usecases/user/update_user_fields.dart';
import 'package:home_repair_app/domain/usecases/user/create_user.dart';
import 'package:home_repair_app/domain/usecases/user/get_technician_stats.dart';

// Domain - Use Cases (Service)
import 'package:home_repair_app/domain/usecases/service/get_services.dart';

// Domain - Use Cases (Review)
import 'package:home_repair_app/domain/usecases/review/create_review.dart';
import 'package:home_repair_app/domain/usecases/review/get_technician_reviews.dart';

// Domain - Use Cases (Chat)
import 'package:home_repair_app/domain/usecases/chat/get_or_create_order_chat.dart';
import 'package:home_repair_app/domain/usecases/chat/send_message.dart';

// Domain - Use Cases (Notification)
import 'package:home_repair_app/domain/usecases/notification/get_user_notifications.dart';
import 'package:home_repair_app/domain/usecases/notification/mark_notification_as_read.dart';

// Domain - Use Cases (Address)
import 'package:home_repair_app/domain/usecases/address/get_user_addresses.dart';
import 'package:home_repair_app/domain/usecases/address/save_address.dart';
import 'package:home_repair_app/domain/usecases/address/delete_address.dart';

// Services (Legacy)
import 'package:home_repair_app/services/auth_service.dart';
import 'package:home_repair_app/services/firestore_service.dart';
import 'package:home_repair_app/services/storage_service.dart';
import 'package:home_repair_app/services/address_service.dart';
import 'package:home_repair_app/services/chat_service.dart';
import 'package:home_repair_app/services/review_service.dart';

// BLoCs
import 'package:home_repair_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:home_repair_app/presentation/blocs/service/service_bloc.dart';
import 'package:home_repair_app/presentation/blocs/order/customer_order_bloc.dart';
import 'package:home_repair_app/presentation/blocs/order/technician_order_bloc.dart';
import 'package:home_repair_app/presentation/blocs/technician_dashboard/technician_dashboard_bloc.dart';
import 'package:home_repair_app/presentation/blocs/booking/booking_bloc.dart';
import 'package:home_repair_app/presentation/blocs/profile/profile_bloc.dart';
import 'package:home_repair_app/presentation/blocs/admin/admin_bloc.dart';
import 'package:home_repair_app/presentation/blocs/address_book/address_book_bloc.dart';

/// Global service locator instance
final sl = GetIt.instance;

/// Initialize all dependencies.
/// Must be called during app startup, after SharedPreferences is initialized.
Future<void> initializeDependencies(SharedPreferences sharedPreferences) async {
  //============================================================================
  // External
  //============================================================================
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  //============================================================================
  // Core
  //============================================================================
  sl.registerLazySingleton<INetworkInfo>(() => NetworkInfo(sl()));

  //============================================================================
  // Legacy Services (to be deprecated in Phase 6)
  //============================================================================
  sl.registerLazySingleton<AuthService>(() => AuthService());
  sl.registerLazySingleton<FirestoreService>(() => FirestoreService());
  sl.registerLazySingleton<StorageService>(() => StorageService());
  sl.registerLazySingleton<AddressService>(() => AddressService());
  sl.registerLazySingleton<ChatService>(() => ChatService());
  sl.registerLazySingleton<ReviewService>(() => ReviewService());

  //============================================================================
  // Data Sources - Remote
  //============================================================================
  sl.registerLazySingleton<IAuthRemoteDataSource>(() => AuthRemoteDataSource());
  sl.registerLazySingleton<IUserRemoteDataSource>(() => UserRemoteDataSource());
  sl.registerLazySingleton<IOrderRemoteDataSource>(
    () => OrderRemoteDataSource(),
  );
  sl.registerLazySingleton<IServiceRemoteDataSource>(
    () => ServiceRemoteDataSource(),
  );

  //============================================================================
  // Data Sources - Local
  //============================================================================
  sl.registerLazySingleton<IUserLocalDataSource>(
    () => UserLocalDataSource(sl()),
  );
  sl.registerLazySingleton<IServiceLocalDataSource>(
    () => ServiceLocalDataSource(sl()),
  );

  //============================================================================
  // Repositories
  //============================================================================
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(
      authRemoteDataSource: sl(),
      userRemoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<IUserRepository>(
    () => UserRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<IOrderRepository>(
    () => OrderRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<IServiceRepository>(
    () => ServiceRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<IAdminRepository>(
    () => AdminRepositoryImpl(firestore: sl()),
  );
  sl.registerLazySingleton<IAddressRepository>(
    () => AddressRepositoryImpl(addressService: sl()),
  );
  sl.registerLazySingleton<IChatRepository>(
    () => ChatRepositoryImpl(chatService: sl()),
  );
  sl.registerLazySingleton<INotificationRepository>(
    () => NotificationRepositoryImpl(firestoreService: sl()),
  );
  sl.registerLazySingleton<IReviewRepository>(
    () => ReviewRepositoryImpl(reviewService: sl()),
  );

  //============================================================================
  // Use Cases - Auth
  //============================================================================
  sl.registerLazySingleton(() => SignInWithEmail(sl()));
  sl.registerLazySingleton(() => SignUpWithEmail(sl()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignInWithFacebook(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));

  sl.registerLazySingleton(() => SendPasswordResetEmail(sl()));

  //============================================================================
  // Use Cases - Order
  //============================================================================
  sl.registerLazySingleton(() => order_uc.CreateOrder(sl()));
  sl.registerLazySingleton(() => order_uc.UpdateOrderStatus(sl()));
  sl.registerLazySingleton(() => CompleteOrder(sl()));
  sl.registerLazySingleton(() => GetOrder(sl()));

  //============================================================================
  // Use Cases - User
  //============================================================================
  sl.registerLazySingleton(() => GetUser(sl()));
  sl.registerLazySingleton(() => UpdateUserFields(sl()));
  sl.registerLazySingleton(() => CreateUser(sl()));
  sl.registerLazySingleton(() => GetTechnicianStats(sl()));

  //============================================================================
  // Use Cases - Service
  //============================================================================
  sl.registerLazySingleton(() => GetServices(sl()));

  //============================================================================
  // Use Cases - Review
  //============================================================================
  sl.registerLazySingleton(() => CreateReview(sl()));
  sl.registerLazySingleton(() => GetTechnicianReviews(sl()));

  //============================================================================
  // Use Cases - Chat
  //============================================================================
  sl.registerLazySingleton(() => GetOrCreateOrderChat(sl()));
  sl.registerLazySingleton(() => SendMessage(sl()));

  //============================================================================
  // Use Cases - Notification
  //============================================================================
  sl.registerLazySingleton(() => GetUserNotifications(sl()));
  sl.registerLazySingleton(() => MarkNotificationAsRead(sl()));

  //============================================================================
  // Use Cases - Address
  //============================================================================
  sl.registerLazySingleton(() => GetUserAddresses(sl()));
  sl.registerLazySingleton(() => SaveAddress(sl()));
  sl.registerLazySingleton(() => DeleteAddress(sl()));

  //============================================================================
  // BLoCs (Factory - create new instance each time)
  //============================================================================
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      signInWithEmail: sl(),
      signUpWithEmail: sl(),
      signInWithGoogle: sl(),
      signInWithFacebook: sl(),
      signOut: sl(),
      authRepository: sl(),
      userRepository: sl(),
    ),
  );
  sl.registerFactory<ServiceBloc>(() => ServiceBloc(serviceRepository: sl()));
  sl.registerFactory<CustomerOrderBloc>(
    () => CustomerOrderBloc(
      orderRepository: sl(),
      createOrder: sl(),
      updateOrderStatus: sl(),
    ),
  );
  sl.registerFactory<TechnicianOrderBloc>(
    () => TechnicianOrderBloc(orderRepository: sl()),
  );
  sl.registerFactory<TechnicianDashboardBloc>(
    () => TechnicianDashboardBloc(userRepository: sl()),
  );
  sl.registerFactory<BookingBloc>(() => BookingBloc(orderRepository: sl()));
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      authRepository: sl(),
      getUser: sl(),
      updateUserFields: sl(),
      storageService: sl(),
    ),
  );
  sl.registerFactory<AdminBloc>(
    () => AdminBloc(adminRepository: sl(), orderRepository: sl()),
  );
  sl.registerFactory<AddressBookBloc>(
    () => AddressBookBloc(addressService: sl()),
  );
}

/// Reset the service locator (useful for testing)
Future<void> resetDependencies() async {
  await sl.reset();
}
