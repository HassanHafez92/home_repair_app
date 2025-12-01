// File: lib/widgets/status_badge.dart
// Purpose: Display a consistent status label with color coding.

import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/technician_model.dart';

class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final bool isSmall;

  const StatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.isSmall = false,
  });

  // Factory constructor for OrderStatus
  factory StatusBadge.fromOrderStatus(
    OrderStatus status, {
    bool isSmall = false,
  }) {
    Color color;
    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        break;
      case OrderStatus.accepted:
      case OrderStatus.traveling:
      case OrderStatus.arrived:
      case OrderStatus.working:
        color = Colors.blue;
        break;
      case OrderStatus.completed:
        color = Colors.green;
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        break;
    }
    return StatusBadge(
      text: status.toString().split('.').last.toUpperCase(),
      color: color,
      isSmall: isSmall,
    );
  }

  // Factory constructor for TechnicianStatus
  factory StatusBadge.fromTechnicianStatus(
    TechnicianStatus status, {
    bool isSmall = false,
  }) {
    Color color;
    switch (status) {
      case TechnicianStatus.pending:
        color = Colors.orange;
        break;
      case TechnicianStatus.approved:
        color = Colors.green;
        break;
      case TechnicianStatus.rejected:
      case TechnicianStatus.suspended:
        color = Colors.red;
        break;
    }
    return StatusBadge(
      text: status.toString().split('.').last.toUpperCase(),
      color: color,
      isSmall: isSmall,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 10,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: isSmall ? 10 : 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
