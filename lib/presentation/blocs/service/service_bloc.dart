// File: lib/blocs/service/service_bloc.dart
// Purpose: BLoC for handling service data logic

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_repair_app/domain/entities/service_entity.dart';
import 'package:home_repair_app/domain/repositories/i_order_repository.dart';
import 'package:home_repair_app/domain/repositories/i_service_repository.dart';
import 'service_event.dart';
import 'service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final IServiceRepository _serviceRepository;
  StreamSubscription<List<ServiceEntity>>? _servicesSubscription;

  ServiceBloc({required IServiceRepository serviceRepository})
    : _serviceRepository = serviceRepository,
      super(const ServiceState()) {
    on<ServiceLoadRequested>(_onLoadRequested);
    on<ServiceSearchChanged>(_onSearchChanged);
    on<ServiceCategorySelected>(_onCategorySelected);
    on<ServiceRefreshRequested>(_onRefreshRequested);
    on<_ServiceUpdated>(_onServiceUpdated);
    on<_ServiceError>(_onServiceError);
    on<ServiceAddRequested>(_onAddRequested);
    on<ServiceUpdateRequested>(_onUpdateRequested);
    on<ServiceDeleteRequested>(_onDeleteRequested);
    // Pagination handlers
    on<LoadServices>(_onLoadServices);
    on<LoadMoreServices>(_onLoadMoreServices);
  }

  Future<void> _onLoadRequested(
    ServiceLoadRequested event,
    Emitter<ServiceState> emit,
  ) async {
    emit(state.copyWith(status: ServiceStatus.loading));

    await _servicesSubscription?.cancel();
    _servicesSubscription = _serviceRepository.getServices().listen(
      (services) {
        add(_ServiceUpdated(services));
      },
      onError: (error) {
        add(_ServiceError(error.toString()));
      },
    );
  }

  void _onSearchChanged(
    ServiceSearchChanged event,
    Emitter<ServiceState> emit,
  ) {
    final query = event.query.toLowerCase();
    final filtered = _filterServices(
      state.services,
      query,
      state.selectedCategory,
    );
    emit(state.copyWith(searchQuery: event.query, filteredServices: filtered));
  }

  void _onCategorySelected(
    ServiceCategorySelected event,
    Emitter<ServiceState> emit,
  ) {
    final filtered = _filterServices(
      state.services,
      state.searchQuery,
      event.category,
    );
    emit(
      state.copyWith(
        selectedCategory: event.category,
        filteredServices: filtered,
      ),
    );
  }

  Future<void> _onRefreshRequested(
    ServiceRefreshRequested event,
    Emitter<ServiceState> emit,
  ) async {
    add(const ServiceLoadRequested());
  }

  Future<void> _onAddRequested(
    ServiceAddRequested event,
    Emitter<ServiceState> emit,
  ) async {
    final result = await _serviceRepository.addService(event.service);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ServiceStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => {}, // Stream will update the state
    );
  }

  Future<void> _onUpdateRequested(
    ServiceUpdateRequested event,
    Emitter<ServiceState> emit,
  ) async {
    final result = await _serviceRepository.updateService(event.service);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ServiceStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => {}, // Stream will update the state
    );
  }

  Future<void> _onDeleteRequested(
    ServiceDeleteRequested event,
    Emitter<ServiceState> emit,
  ) async {
    final result = await _serviceRepository.deleteService(event.serviceId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ServiceStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => {}, // Stream will update the state
    );
  }

  // Internal events for stream updates
  Future<void> _onServiceUpdated(
    _ServiceUpdated event,
    Emitter<ServiceState> emit,
  ) async {
    final filtered = _filterServices(
      event.services,
      state.searchQuery,
      state.selectedCategory,
    );
    emit(
      state.copyWith(
        status: ServiceStatus.success,
        services: event.services,
        filteredServices: filtered,
      ),
    );
  }

  void _onServiceError(_ServiceError event, Emitter<ServiceState> emit) {
    emit(
      state.copyWith(
        status: ServiceStatus.failure,
        errorMessage: event.message,
      ),
    );
  }

  List<ServiceEntity> _filterServices(
    List<ServiceEntity> services,
    String query,
    String? category,
  ) {
    return services.where((service) {
      final matchesQuery =
          query.isEmpty ||
          service.name.toLowerCase().contains(query.toLowerCase()) ||
          service.description.toLowerCase().contains(query.toLowerCase());
      final matchesCategory = category == null || service.category == category;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  // Pagination event handlers

  /// Handle initial paginated services load
  Future<void> _onLoadServices(
    LoadServices event,
    Emitter<ServiceState> emit,
  ) async {
    emit(state.copyWith(status: ServiceStatus.loading));

    final result = await _serviceRepository.getServicesPaginated(
      limit: event.limit,
      category: event.category,
      searchQuery: event.searchQuery,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ServiceStatus.failure,
          errorMessage: failure.message,
          isLoadingMore: false,
        ),
      ),
      (paginatedResult) => emit(
        state.copyWith(
          status: ServiceStatus.success,
          paginatedServices: paginatedResult,
          isLoadingMore: false,
        ),
      ),
    );
  }

  /// Handle loading more services (next page)
  Future<void> _onLoadMoreServices(
    LoadMoreServices event,
    Emitter<ServiceState> emit,
  ) async {
    // Don't load if already loading or no more items
    if (state.isLoadingMore || state.paginatedServices?.hasMore == false) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));

    final currentPagination = state.paginatedServices;
    if (currentPagination == null) {
      // No initial load yet, ignore
      emit(state.copyWith(isLoadingMore: false));
      return;
    }

    final result = await _serviceRepository.getServicesPaginated(
      startAfterCursor: currentPagination.nextCursor,
      limit: 20, // Use default limit
      // Note: category and search filters would need to be stored in state
      // if you want them to persist across pagination
    );

    result.fold(
      (failure) => emit(
        state.copyWith(errorMessage: failure.message, isLoadingMore: false),
      ),
      (paginatedResult) {
        // Merge new items with existing ones
        final updatedResult = PaginatedResult<ServiceEntity>(
          items: [...currentPagination.items, ...paginatedResult.items],
          hasMore: paginatedResult.hasMore,
          nextCursor: paginatedResult.nextCursor,
        );

        emit(
          state.copyWith(
            paginatedServices: updatedResult,
            isLoadingMore: false,
          ),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _servicesSubscription?.cancel();
    return super.close();
  }
}

// Internal events
class _ServiceUpdated extends ServiceEvent {
  final List<ServiceEntity> services;
  const _ServiceUpdated(this.services);
  @override
  List<Object?> get props => [services];
}

class _ServiceError extends ServiceEvent {
  final String message;
  const _ServiceError(this.message);
  @override
  List<Object?> get props => [message];
}
