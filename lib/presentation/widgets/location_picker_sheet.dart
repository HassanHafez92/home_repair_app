import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/design_tokens.dart';

/// A bottom sheet for selecting a location/area
/// Includes search functionality and "Use Current Location" option
class LocationPickerSheet extends StatefulWidget {
  final String currentLocation;
  final List<String> areas;

  const LocationPickerSheet({
    super.key,
    required this.currentLocation,
    required this.areas,
  });

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  late TextEditingController _searchController;
  late List<String> _filteredAreas;
  String? _selectedArea;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredAreas = widget.areas;
    _selectedArea = widget.currentLocation;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterAreas(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAreas = widget.areas;
      } else {
        _filteredAreas = widget.areas
            .where((area) => area.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _selectArea(String area) {
    setState(() {
      _selectedArea = area;
    });
    Navigator.pop(context, area);
  }

  void _useCurrentLocation() {
    // In a real app, this would use geolocator to get current location
    // For now, we'll just show a snackbar and select a default
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('useCurrentLocation'.tr()),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context, 'Cairo'); // Default to Cairo for demo
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(DesignTokens.radiusXL),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: DesignTokens.spaceMD),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: DesignTokens.neutral300,
                borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.spaceLG),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceLG,
            ),
            child: Text(
              'selectArea'.tr(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: DesignTokens.fontWeightBold,
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.spaceBase),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceLG,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterAreas,
              decoration: InputDecoration(
                hintText: 'searchArea'.tr(),
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceMD,
                  vertical: DesignTokens.spaceSM,
                ),
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.spaceBase),

          // Use Current Location button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceLG,
            ),
            child: InkWell(
              onTap: _useCurrentLocation,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
              child: Container(
                padding: const EdgeInsets.all(DesignTokens.spaceMD),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(DesignTokens.spaceXS),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.my_location_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spaceMD),
                    Expanded(
                      child: Text(
                        'useCurrentLocation'.tr(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: DesignTokens.fontWeightMedium,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: colorScheme.primary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.spaceBase),

          // Divider
          Divider(color: colorScheme.outline.withValues(alpha: 0.3), height: 1),

          // Areas list
          Expanded(
            child: _filteredAreas.isEmpty
                ? Center(
                    child: Text(
                      'No areas found',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: DesignTokens.neutral500,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: DesignTokens.spaceXS,
                    ),
                    itemCount: _filteredAreas.length,
                    itemBuilder: (context, index) {
                      final area = _filteredAreas[index];
                      final isSelected = area == _selectedArea;

                      return ListTile(
                        onTap: () => _selectArea(area),
                        leading: Icon(
                          Icons.location_on_outlined,
                          color: isSelected
                              ? colorScheme.primary
                              : DesignTokens.neutral400,
                        ),
                        title: Text(
                          area,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: isSelected
                                ? DesignTokens.fontWeightBold
                                : DesignTokens.fontWeightRegular,
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: colorScheme.primary,
                              )
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
