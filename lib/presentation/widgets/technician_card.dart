// File: lib/widgets/technician_card.dart
// Purpose: Display technician profile summary.

import 'package:flutter/material.dart';
import 'package:home_repair_app/domain/entities/technician_entity.dart';
import 'status_badge.dart';
import 'rating_stars.dart';

class TechnicianCard extends StatelessWidget {
  final TechnicianEntity technician;
  final VoidCallback? onTap;
  final bool showStatus;

  const TechnicianCard({
    super.key,
    required this.technician,
    this.onTap,
    this.showStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.blue[100],
                child: Text(
                  technician.fullName[0].toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      technician.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RatingStars(rating: technician.rating, size: 14),
                    const SizedBox(height: 4),
                    Text(
                      technician.specializations.join(', '),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (showStatus)
                StatusBadge.fromTechnicianStatus(
                  technician.status,
                  isSmall: true,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
