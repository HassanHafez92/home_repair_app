// File: test/customer_order_bloc_test.dart
// Purpose: Unit tests for CustomerOrderBloc

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_repair_app/core/error/failures.dart';
import 'package:home_repair_app/presentation/blocs/order/customer_order_bloc.dart';
import 'package:home_repair_app/domain/entities/order_entity.dart';
import 'package:home_repair_app/domain/repositories/i_order_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:home_repair_app/domain/usecases/order/create_order.dart'
    as usecase;
import 'package:home_repair_app/domain/usecases/order/update_order_status.dart'
    as usecase;

// Generate mocks
@GenerateNiceMocks([
  MockSpec<IOrderRepository>(),
  MockSpec<usecase.CreateOrder>(),
  MockSpec<usecase.UpdateOrderStatus>(),
])
import 'customer_order_bloc_test.mocks.dart';

void main() {
  group('CustomerOrderBloc', () {
    late MockIOrderRepository mockOrderRepository;
    late MockCreateOrder mockCreateOrder;
    late MockUpdateOrderStatus mockUpdateOrderStatus;
    late CustomerOrderBloc customerOrderBloc;

    // Test data
    final testOrder = OrderEntity(
      id: 'order-1',
      customerId: 'customer-1',
      serviceId: 'service-1',
      status: OrderStatus.pending,
      description: 'Test order',
      address: '123 Test St',
      location: {'lat': 24.7136, 'lng': 46.6753},
      dateRequested: DateTime(2025, 1, 1),
      visitFee: 50.0,
      vat: 15.0,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );

    final testPaginatedResult = PaginatedResult<OrderEntity>(
      items: [testOrder],
      hasMore: false,
      nextCursor: null,
    );

    setUp(() {
      mockOrderRepository = MockIOrderRepository();
      mockCreateOrder = MockCreateOrder();
      mockUpdateOrderStatus = MockUpdateOrderStatus();

      customerOrderBloc = CustomerOrderBloc(
        orderRepository: mockOrderRepository,
        createOrder: mockCreateOrder,
        updateOrderStatus: mockUpdateOrderStatus,
      );
    });

    tearDown(() {
      customerOrderBloc.close();
    });

    test('initial state is CustomerOrderState with initial status', () {
      expect(
        customerOrderBloc.state,
        const CustomerOrderState(status: CustomerOrderStatus.initial),
      );
    });

    blocTest<CustomerOrderBloc, CustomerOrderState>(
      'emits [loading, success] when LoadCustomerOrders succeeds',
      setUp: () {
        when(
          mockOrderRepository.getCustomerOrdersPaginated(
            customerId: 'customer-1',
            limit: 20,
            statusFilter: null,
          ),
        ).thenAnswer((_) async => Right(testPaginatedResult));
      },
      build: () => customerOrderBloc,
      act: (bloc) => bloc.add(const LoadCustomerOrders(userId: 'customer-1')),
      expect: () => [
        const CustomerOrderState(status: CustomerOrderStatus.loading),
        CustomerOrderState(
          status: CustomerOrderStatus.success,
          paginatedOrders: testPaginatedResult,
        ),
      ],
    );

    blocTest<CustomerOrderBloc, CustomerOrderState>(
      'emits [loading, failure] when LoadCustomerOrders fails',
      setUp: () {
        when(
          mockOrderRepository.getCustomerOrdersPaginated(
            customerId: 'customer-1',
            limit: 20,
            statusFilter: null,
          ),
        ).thenAnswer((_) async => Left(ServerFailure('Failed to load orders')));
      },
      build: () => customerOrderBloc,
      act: (bloc) => bloc.add(const LoadCustomerOrders(userId: 'customer-1')),
      expect: () => [
        const CustomerOrderState(status: CustomerOrderStatus.loading),
        isA<CustomerOrderState>()
            .having((s) => s.status, 'status', CustomerOrderStatus.failure)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('Failed to load orders'),
            ),
      ],
    );

    blocTest<CustomerOrderBloc, CustomerOrderState>(
      'emits [failure] when CancelOrder fails',
      setUp: () {
        // Now stubbing the use case instead of the repository
        when(
          mockUpdateOrderStatus.call(any),
        ).thenAnswer((_) async => Left(ServerFailure('Failed to cancel')));
      },
      build: () => customerOrderBloc,
      act: (bloc) => bloc.add(const CancelOrder('order-1')),
      expect: () => [
        isA<CustomerOrderState>().having(
          (s) => s.status,
          'status',
          CustomerOrderStatus.failure,
        ),
      ],
    );

    blocTest<CustomerOrderBloc, CustomerOrderState>(
      'emits [failure] when CustomerOrderError is added',
      build: () => customerOrderBloc,
      act: (bloc) => bloc.add(const CustomerOrderError('Test error message')),
      expect: () => [
        const CustomerOrderState(
          status: CustomerOrderStatus.failure,
          errorMessage: 'Test error message',
        ),
      ],
    );
  });
}
