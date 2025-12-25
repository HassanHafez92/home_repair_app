import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import 'rating_stars.dart';

/// A card displaying a customer testimonial
/// Inspired by Fixawy's customer reviews section
class TestimonialCard extends StatelessWidget {
  final String customerName;
  final String? customerPhotoUrl;
  final int rating;
  final String quote;
  final String serviceType;
  final DateTime date;

  const TestimonialCard({
    super.key,
    required this.customerName,
    this.customerPhotoUrl,
    required this.rating,
    required this.quote,
    required this.serviceType,
    required this.date,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${(difference.inDays / 30).floor()} months ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 280,
      padding: const EdgeInsets.all(DesignTokens.spaceMD),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        boxShadow: DesignTokens.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with avatar and name
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                backgroundImage: customerPhotoUrl != null
                    ? NetworkImage(customerPhotoUrl!)
                    : null,
                child: customerPhotoUrl == null
                    ? Text(
                        customerName.isNotEmpty
                            ? customerName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: DesignTokens.fontWeightBold,
                          fontSize: DesignTokens.fontSizeMD,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: DesignTokens.spaceSM),
              // Name and service
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: DesignTokens.fontWeightBold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      serviceType,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: DesignTokens.neutral500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceSM),

          // Rating
          RatingStars(rating: rating.toDouble(), size: 16),
          const SizedBox(height: DesignTokens.spaceSM),

          // Quote
          Flexible(
            child: Text(
              '"$quote"',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceSM),

          // Date
          Text(
            _formatDate(date),
            style: theme.textTheme.bodySmall?.copyWith(
              color: DesignTokens.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}
