import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../blocs/order/technician_order_bloc.dart';
import '../../helpers/auth_helper.dart';
import 'order_action_screen.dart';
import '../../widgets/order_card.dart';
import '../../widgets/empty_state.dart';

class IncomingOrdersScreen extends StatefulWidget {
  const IncomingOrdersScreen({super.key});

  @override
  State<IncomingOrdersScreen> createState() => _IncomingOrdersScreenState();
}

class _IncomingOrdersScreenState extends State<IncomingOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final userId = context.userId;
        if (userId != null) {
          context.read<TechnicianOrderBloc>().add(LoadTechnicianOrders(userId));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.userId;

    if (userId == null) {
      return Scaffold(body: Center(child: Text('pleaseLogin'.tr())));
    }

    return Scaffold(
      appBar: AppBar(title: Text('incomingOrders'.tr())),
      body: BlocBuilder<TechnicianOrderBloc, TechnicianOrderState>(
        builder: (context, state) {
          if (state.status == TechnicianOrderStatus.loading &&
              state.incomingOrders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == TechnicianOrderStatus.failure) {
            return Center(
              child: Text('errorMessage'.tr(args: [state.errorMessage ?? ''])),
            );
          }

          final orders = state.incomingOrders;

          if (orders.isEmpty) {
            return EmptyState(
              title: 'noIncomingOrders'.tr(),
              message: 'waitingForRequests'.tr(),
              icon: Icons.inbox,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderCard(
                order: order,
                isTechnicianView: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderActionScreen(order: order),
                    ),
                  );
                },
                onAccept: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderActionScreen(order: order),
                    ),
                  );
                },
                onReject: () async {
                  // Simple reject for now
                },
              );
            },
          );
        },
      ),
    );
  }
}
