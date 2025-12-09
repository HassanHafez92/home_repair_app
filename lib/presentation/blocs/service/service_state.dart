// File: lib/blocs/service/service_state.dart
// Purpose: Define states for ServiceBloc

import 'package:equatable/equatable.dart';
import 'package:home_repair_app/domain/entities/service_entity.dart';
import 'package:home_repair_app/domain/repositories/i_order_repository.dart';

enum ServiceStatus { initial, loading, success, failure }

class ServiceState extends Equatable {
  final ServiceStatus status;
  final List<ServiceEntity> services;
  final List<ServiceEntity> filteredServices;
  final String? selectedCategory;
  final String searchQuery;
  final String? errorMessage;

  // Pagination fields
  final PaginatedResult<ServiceEntity>? paginatedServices;
  final bool isLoadingMore;

  const ServiceState({
    this.status = ServiceStatus.initial,
    this.services = const [],
    this.filteredServices = const [],
    this.selectedCategory,
    this.searchQuery = '',
    this.errorMessage,
    this.paginatedServices,
    this.isLoadingMore = false,
  });

  List<String> get categories =>
      services.map((s) => s.category).toSet().toList();

  ServiceState copyWith({
    ServiceStatus? status,
    List<ServiceEntity>? services,
    List<ServiceEntity>? filteredServices,
    String? selectedCategory,
    String? searchQuery,
    String? errorMessage,
    PaginatedResult<ServiceEntity>? paginatedServices,
    bool? isLoadingMore,
  }) {
    return ServiceState(
      status: status ?? this.status,
      services: services ?? this.services,
      filteredServices: filteredServices ?? this.filteredServices,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
      paginatedServices: paginatedServices ?? this.paginatedServices,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    status,
    services,
    filteredServices,
    selectedCategory,
    searchQuery,
    errorMessage,
    paginatedServices,
    isLoadingMore,
  ];
}
