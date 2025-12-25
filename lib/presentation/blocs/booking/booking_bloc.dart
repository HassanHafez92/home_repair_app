// File: lib/blocs/booking/booking_bloc.dart
// Purpose: BLoC for handling booking logic

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:home_repair_app/domain/entities/order_entity.dart';
import 'package:home_repair_app/domain/repositories/i_order_repository.dart';
import 'package:home_repair_app/models/media_file_model.dart';
import 'package:home_repair_app/services/notification_service.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final IOrderRepository _orderRepository;

  BookingBloc({required IOrderRepository orderRepository})
    : _orderRepository = orderRepository,
      super(const BookingState()) {
    on<BookingStarted>(_onStarted);
    on<BookingStepChanged>(_onStepChanged);
    on<BookingDescriptionChanged>(_onDescriptionChanged);
    on<BookingMediaAdded>(_onMediaAdded);
    on<BookingMediaRemoved>(_onMediaRemoved);
    on<BookingLocationChanged>(_onLocationChanged);
    on<BookingScheduleChanged>(_onScheduleChanged);
    on<BookingSubmitted>(_onSubmitted);
  }

  void _onStarted(BookingStarted event, Emitter<BookingState> emit) {
    emit(
      state.copyWith(
        status: BookingStatus.filling,
        service: event.service,
        currentStep: 0,
        description: '',
        mediaFiles: [],
        address: '',
        scheduledDate: null,
        scheduledTime: null,
      ),
    );
  }

  void _onStepChanged(BookingStepChanged event, Emitter<BookingState> emit) {
    emit(state.copyWith(currentStep: event.step));
  }

  void _onDescriptionChanged(
    BookingDescriptionChanged event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(description: event.description));
  }

  void _onMediaAdded(BookingMediaAdded event, Emitter<BookingState> emit) {
    final updatedMedia = List<MediaFileModel>.from(state.mediaFiles)
      ..add(event.media);
    emit(state.copyWith(mediaFiles: updatedMedia));
  }

  void _onMediaRemoved(BookingMediaRemoved event, Emitter<BookingState> emit) {
    final updatedMedia = state.mediaFiles
        .where((m) => m.id != event.mediaId)
        .toList();
    emit(state.copyWith(mediaFiles: updatedMedia));
  }

  void _onLocationChanged(
    BookingLocationChanged event,
    Emitter<BookingState> emit,
  ) {
    emit(
      state.copyWith(
        address: event.address,
        latitude: event.latitude,
        longitude: event.longitude,
      ),
    );
  }

  void _onScheduleChanged(
    BookingScheduleChanged event,
    Emitter<BookingState> emit,
  ) {
    emit(
      state.copyWith(
        scheduledDate: event.date ?? state.scheduledDate,
        scheduledTime: event.time ?? state.scheduledTime,
      ),
    );
  }

  Future<void> _onSubmitted(
    BookingSubmitted event,
    Emitter<BookingState> emit,
  ) async {
    if (state.service == null) return;

    emit(state.copyWith(status: BookingStatus.submitting));

    try {
      // Combine date and time
      final date = state.scheduledDate!;
      final time = state.scheduledTime!;
      final scheduledDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      // Location map with real coordinates from map selection
      final locationData = {
        'address': state.address,
        'latitude': state.latitude ?? 0.0,
        'longitude': state.longitude ?? 0.0,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Generate a temporary ID (will be replaced by Firestore)
      final tempId = const Uuid().v4();

      final order = OrderEntity(
        id: tempId,
        customerId: event.userId,
        serviceId: state.service!.id,
        status: OrderStatus.pending,
        description: state.description,
        address: state.address,
        location: locationData,
        dateRequested: DateTime.now(),
        dateScheduled: scheduledDateTime,
        initialEstimate: state.service!.avgPrice,
        visitFee: state.service!.visitFee,
        vat: state.service!.avgPrice * 0.14,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await _orderRepository.createOrder(order);

      String? successOrderId;

      result.fold(
        (failure) => emit(
          state.copyWith(
            status: BookingStatus.failure,
            errorMessage: failure.message,
          ),
        ),
        (orderId) {
          successOrderId = orderId;
        },
      );

      // Handle success case outside of fold to properly await
      if (successOrderId != null) {
        // Show local notification
        await NotificationService().showNotification(
          title: 'Order Confirmed! 🎉',
          body:
              'Your order #${successOrderId!.substring(0, 8)} has been created successfully.',
          payload: successOrderId,
        );

        emit(
          state.copyWith(
            status: BookingStatus.success,
            orderId: successOrderId,
          ),
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('BookingBloc Error: $e');
      emit(
        state.copyWith(
          status: BookingStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
