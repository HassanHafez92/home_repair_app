import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import 'location_picker_sheet.dart';

/// A compact location selector widget for the app header
/// Displays current location and opens a picker sheet on tap
class LocationSelector extends StatefulWidget {
  final String? initialLocation;
  final ValueChanged<String>? onLocationChanged;

  const LocationSelector({
    super.key,
    this.initialLocation,
    this.onLocationChanged,
  });

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  late String _currentLocation;

  // List of Egyptian cities/areas for selection
  static const List<String> egyptianAreas = [
    'Cairo',
    'Giza',
    'Alexandria',
    'Shubra El Kheima',
    'Port Said',
    'Suez',
    'Luxor',
    'Mansoura',
    'Tanta',
    'Asyut',
    'Ismailia',
    'Faiyum',
    'Zagazig',
    'Aswan',
    'Damietta',
    'Damanhur',
    'Minya',
    'Beni Suef',
    'Sohag',
    'Hurghada',
    '6th of October City',
    'New Cairo',
    'Nasr City',
    'Maadi',
    'Heliopolis',
    'Mohandessin',
    'Dokki',
    'Zamalek',
  ];

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.initialLocation ?? 'Cairo';
  }

  void _showLocationPicker() async {
    final selectedLocation = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationPickerSheet(
        currentLocation: _currentLocation,
        areas: egyptianAreas,
      ),
    );

    if (selectedLocation != null && selectedLocation != _currentLocation) {
      setState(() {
        _currentLocation = selectedLocation;
      });
      widget.onLocationChanged?.call(selectedLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: _showLocationPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceSM,
          vertical: DesignTokens.spaceXS,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_rounded,
              color: colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: DesignTokens.spaceXXS),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 80),
              child: Text(
                _currentLocation,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: DesignTokens.fontWeightMedium,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: DesignTokens.spaceXXS),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: DesignTokens.neutral500,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
