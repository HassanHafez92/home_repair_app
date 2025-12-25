import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/design_tokens.dart';
import 'testimonial_card.dart';

/// A model representing a customer testimonial
class Testimonial {
  final String id;
  final String customerName;
  final String? customerPhotoUrl;
  final int rating;
  final String quote;
  final String serviceType;
  final DateTime date;

  const Testimonial({
    required this.id,
    required this.customerName,
    this.customerPhotoUrl,
    required this.rating,
    required this.quote,
    required this.serviceType,
    required this.date,
  });
}

/// A horizontally scrolling section displaying customer testimonials
/// Inspired by Fixawy's "What Our Customers Say" section
class TestimonialsSection extends StatelessWidget {
  final List<Testimonial>? testimonials;
  final VoidCallback? onViewAllTap;

  const TestimonialsSection({super.key, this.testimonials, this.onViewAllTap});

  /// Sample testimonials for demonstration
  static List<Testimonial> get sampleTestimonials => [
    Testimonial(
      id: '1',
      customerName: 'Ahmed Hassan',
      rating: 5,
      quote:
          'Excellent service! The technician was professional and fixed my AC quickly. Highly recommended!',
      serviceType: 'AC Repair',
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Testimonial(
      id: '2',
      customerName: 'Sara Mohamed',
      rating: 5,
      quote:
          'Very impressed with the plumbing work. Fair pricing and great quality. Will use again!',
      serviceType: 'Plumbing',
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Testimonial(
      id: '3',
      customerName: 'Omar Ali',
      rating: 4,
      quote:
          'Good electrical work. The technician explained everything clearly. Fast response time.',
      serviceType: 'Electrical',
      date: DateTime.now().subtract(const Duration(days: 8)),
    ),
    Testimonial(
      id: '4',
      customerName: 'Fatima Ibrahim',
      rating: 5,
      quote:
          'Amazing painting job! My apartment looks brand new. Professional team and clean work.',
      serviceType: 'Painting',
      date: DateTime.now().subtract(const Duration(days: 12)),
    ),
    Testimonial(
      id: '5',
      customerName: 'Khaled Mahmoud',
      rating: 5,
      quote:
          'Emergency plumbing at midnight and they came within an hour. Lifesavers!',
      serviceType: 'Emergency Plumbing',
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayTestimonials = testimonials ?? sampleTestimonials;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceLG),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'whatCustomersSay'.tr(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: DesignTokens.fontWeightBold,
                ),
              ),
              if (onViewAllTap != null)
                TextButton(
                  onPressed: onViewAllTap,
                  child: Text(
                    'viewAll'.tr(),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: DesignTokens.fontWeightBold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: DesignTokens.spaceBase),

        // Testimonial Cards
        SizedBox(
          height: 200,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceMD,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: displayTestimonials.length,
            itemBuilder: (context, index) {
              final testimonial = displayTestimonials[index];
              return Padding(
                padding: const EdgeInsets.only(right: DesignTokens.spaceMD),
                child: TestimonialCard(
                  customerName: testimonial.customerName,
                  customerPhotoUrl: testimonial.customerPhotoUrl,
                  rating: testimonial.rating,
                  quote: testimonial.quote,
                  serviceType: testimonial.serviceType,
                  date: testimonial.date,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
