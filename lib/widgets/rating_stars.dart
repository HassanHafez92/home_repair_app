// File: lib/widgets/rating_stars.dart
// Purpose: Display star ratings, either read-only or interactive.

import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int starCount;
  final double size;
  final Color color;
  final bool isInteractive;
  final Function(double)? onRatingChanged;

  const RatingStars({
    super.key,
    required this.rating,
    this.starCount = 5,
    this.size = 20.0,
    this.color = Colors.amber,
    this.isInteractive = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        final isFull = index < rating.floor();
        final isHalf = index == rating.floor() && (rating - index) >= 0.5;
        
        IconData iconData = Icons.star_border;
        if (isFull) {
          iconData = Icons.star;
        } else if (isHalf) {
          iconData = Icons.star_half;
        }

        final icon = Icon(
          iconData,
          color: color,
          size: size,
        );

        if (isInteractive) {
          return GestureDetector(
            onTap: () {
              if (onRatingChanged != null) {
                onRatingChanged!(index + 1.0);
              }
            },
            child: icon,
          );
        }

        return icon;
      }),
    );
  }
}
