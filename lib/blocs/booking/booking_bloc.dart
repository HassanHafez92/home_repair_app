// File: lib/blocs/booking/booking_bloc.dart
// Purpose: BLoC for handling booking logic

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/i_order_repository.dart';
import '../../services/notification_service.dart';
import '../../models/order_model.dart';
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
    on<BookingLocationChanged>(_onLocationChanged);
    on<BookingScheduleChanged>(_onScheduleChanged);
    on<BookingPaymentMethodChanged>(_onPaymentMethodChanged);
    on<BookingSubmitted>(_onSubmitted);
  }

  void _onStarted(BookingStarted event, Emitter<BookingState> emit) {
    emit(
      state.copyWith(
        status: BookingStatus.filling,
        service: event.service,
        currentStep: 0,
        description: '',
        address: '',
        scheduledDate: null,
        scheduledTime: null,
        paymentMethod: 'cash',
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

  void _onPaymentMethodChanged(
    BookingPaymentMethodChanged event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(paymentMethod: event.method));
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

      final order = OrderModel(
        id: '', // Will be replaced by Firestore
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
        paymentMethod: state.paymentMethod,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final orderId = await _orderRepository.createOrder(order);

      // Show local notification
      await NotificationService().showNotification(
        title: 'Order Confirmed! 🎉',
        body:
            'Your order #${orderId.substring(0, 8)} has been created successfully.',
        payload: orderId,
      );

      emit(state.copyWith(status: BookingStatus.success, orderId: orderId));
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
