// File: lib/blocs/service/service_event.dart
// Purpose: Define events for ServiceBloc

import 'package:equatable/equatable.dart';
import 'package:home_repair_app/domain/entities/service_entity.dart';

abstract class ServiceEvent extends Equatable {
  const ServiceEvent();

  @override
  List<Object?> get props => [];
}

class ServiceLoadRequested extends ServiceEvent {
  const ServiceLoadRequested();
}

class ServiceSearchChanged extends ServiceEvent {
  final String query;

  const ServiceSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class ServiceCategorySelected extends ServiceEvent {
  final String? category;

  const ServiceCategorySelected(this.category);

  @override
  List<Object?> get props => [category];
}

class ServiceRefreshRequested extends ServiceEvent {
  const ServiceRefreshRequested();
}

class ServiceAddRequested extends ServiceEvent {
  final ServiceEntity service;
  const ServiceAddRequested(this.service);
  @override
  List<Object?> get props => [service];
}

class ServiceUpdateRequested extends ServiceEvent {
  final ServiceEntity service;
  const ServiceUpdateRequested(this.service);
  @override
  List<Object?> get props => [service];
}

class ServiceDeleteRequested extends ServiceEvent {
  final String serviceId;
  const ServiceDeleteRequested(this.serviceId);
  @override
  List<Object?> get props => [serviceId];
}

/// Load services with pagination (initial load)
class LoadServices extends ServiceEvent {
  final int limit;
  final String? category;
  final String? searchQuery;
  final String? languageCode;

  const LoadServices({
    this.limit = 20,
    this.category,
    this.searchQuery,
    this.languageCode,
  });

  @override
  List<Object?> get props => [limit, category, searchQuery, languageCode];
}

/// Load more services (next page)
class LoadMoreServices extends ServiceEvent {
  const LoadMoreServices();
}
