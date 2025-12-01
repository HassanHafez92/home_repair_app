// File: lib/blocs/service/service_state.dart
// Purpose: Define states for ServiceBloc

import 'package:equatable/equatable.dart';
import '../../models/service_model.dart';
import '../../models/paginated_result.dart';

enum ServiceStatus { initial, loading, success, failure }

class ServiceState extends Equatable {
  final ServiceStatus status;
  final List<ServiceModel> services;
  final List<ServiceModel> filteredServices;
  final String? selectedCategory;
  final String searchQuery;
  final String? errorMessage;

  // Pagination fields
  final PaginatedResult<ServiceModel>? paginatedServices;
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
    List<ServiceModel>? services,
    List<ServiceModel>? filteredServices,
    String? selectedCategory,
    String? searchQuery,
    String? errorMessage,
    PaginatedResult<ServiceModel>? paginatedServices,
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
