// File: lib/presentation/widgets/technician_filter_sheet.dart
// Purpose: Bottom sheet for filtering and matching technicians during booking.

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:home_repair_app/models/technician_filter_model.dart';

/// Bottom sheet widget for technician filtering
class TechnicianFilterSheet extends StatefulWidget {
  /// Current filter settings
  final TechnicianFilterModel currentFilter;

  /// Callback when filters are applied
  final Function(TechnicianFilterModel) onApply;

  /// Previous technician info (for "same technician" option)
  final String? previousTechnicianId;
  final String? previousTechnicianName;

  const TechnicianFilterSheet({
    super.key,
    required this.currentFilter,
    required this.onApply,
    this.previousTechnicianId,
    this.previousTechnicianName,
  });

  /// Show the filter sheet as a modal bottom sheet
  static Future<TechnicianFilterModel?> show({
    required BuildContext context,
    required TechnicianFilterModel currentFilter,
    String? previousTechnicianId,
    String? previousTechnicianName,
  }) async {
    return showModalBottomSheet<TechnicianFilterModel>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => TechnicianFilterSheet(
          currentFilter: currentFilter,
          previousTechnicianId: previousTechnicianId,
          previousTechnicianName: previousTechnicianName,
          onApply: (filter) => Navigator.pop(context, filter),
        ),
      ),
    );
  }

  @override
  State<TechnicianFilterSheet> createState() => _TechnicianFilterSheetState();
}

class _TechnicianFilterSheetState extends State<TechnicianFilterSheet> {
  late TechnicianFilterModel _filter;
  double _ratingValue = 0;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    _ratingValue = _filter.minRating ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.tune, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'technicianPreferences'.tr(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_filter.hasActiveFilters)
                  TextButton(
                    onPressed: _resetFilters,
                    child: Text('clearAll'.tr()),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Filter options
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Same technician preference
                if (widget.previousTechnicianId != null) ...[
                  _buildSectionTitle('sameTechnician'.tr()),
                  _buildSameTechnicianOption(),
                  const SizedBox(height: 24),
                ],

                // Verified only toggle
                _buildSectionTitle('verification'.tr()),
                _buildVerifiedOnlyTile(),
                const SizedBox(height: 24),

                // Minimum rating slider
                _buildSectionTitle('minimumRating'.tr()),
                _buildRatingSlider(),
                const SizedBox(height: 24),

                // Sort order
                _buildSectionTitle('sortBy'.tr()),
                _buildSortOrderOptions(),
                const SizedBox(height: 24),

                // Experience filter
                _buildSectionTitle('experience'.tr()),
                _buildExperienceOptions(),
                const SizedBox(height: 80), // Space for button
              ],
            ),
          ),

          // Apply button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('cancel'.tr()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => widget.onApply(_filter),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('applyFilters'.tr()),
                          if (_filter.hasActiveFilters) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_filter.activeFilterCount}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSameTechnicianOption() {
    final isSelected =
        _filter.preferredTechnicianId == widget.previousTechnicianId;

    return Card(
      elevation: isSelected ? 2 : 0,
      color: isSelected
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
          : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(widget.previousTechnicianName ?? 'previousTechnician'.tr()),
        subtitle: Text('requestSameTechnician'.tr()),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              )
            : const Icon(Icons.circle_outlined),
        onTap: () {
          setState(() {
            if (isSelected) {
              _filter = _filter.copyWith(clearPreferredTechnician: true);
            } else {
              _filter = _filter.copyWith(
                preferredTechnicianId: widget.previousTechnicianId,
                preferredTechnicianName: widget.previousTechnicianName,
              );
            }
          });
        },
      ),
    );
  }

  Widget _buildVerifiedOnlyTile() {
    return SwitchListTile(
      title: Row(
        children: [
          const Icon(Icons.verified, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Text('verifiedTechniciansOnly'.tr()),
        ],
      ),
      subtitle: Text('verifiedTechniciansDesc'.tr()),
      value: _filter.verifiedOnly,
      onChanged: (value) {
        setState(() {
          _filter = _filter.copyWith(verifiedOnly: value);
        });
      },
    );
  }

  Widget _buildRatingSlider() {
    return Column(
      children: [
        Row(
          children: [
            ...List.generate(5, (index) {
              final starValue = index + 1;
              final isFilled = _ratingValue >= starValue;
              final isHalf =
                  _ratingValue >= starValue - 0.5 && _ratingValue < starValue;

              return Icon(
                isHalf
                    ? Icons.star_half
                    : (isFilled ? Icons.star : Icons.star_border),
                color: Colors.amber,
                size: 24,
              );
            }),
            const SizedBox(width: 12),
            Text(
              _ratingValue > 0
                  ? '${_ratingValue.toStringAsFixed(1)}+ ${'stars'.tr()}'
                  : 'anyRating'.tr(),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: _ratingValue,
          min: 0,
          max: 5,
          divisions: 10,
          label: _ratingValue > 0
              ? '${_ratingValue.toStringAsFixed(1)}+'
              : 'Any',
          onChanged: (value) {
            setState(() {
              _ratingValue = value;
              _filter = _filter.copyWith(
                minRating: value > 0 ? value : null,
                clearMinRating: value == 0,
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildSortOrderOptions() {
    final options = [
      (TechnicianSortOrder.bestMatch, 'bestMatch'.tr(), Icons.auto_awesome),
      (TechnicianSortOrder.highestRating, 'highestRating'.tr(), Icons.star),
      (TechnicianSortOrder.nearestFirst, 'nearestFirst'.tr(), Icons.near_me),
      (
        TechnicianSortOrder.mostExperienced,
        'mostExperienced'.tr(),
        Icons.military_tech,
      ),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = _filter.sortOrder == option.$1;
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(option.$3, size: 16),
              const SizedBox(width: 4),
              Text(option.$2),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _filter = _filter.copyWith(sortOrder: option.$1);
              });
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildExperienceOptions() {
    final options = [
      (null, 'anyExperience'.tr()),
      (2, '2+ ${'years'.tr()}'),
      (5, '5+ ${'years'.tr()}'),
      (10, '10+ ${'years'.tr()}'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = _filter.minYearsExperience == option.$1;
        return ChoiceChip(
          label: Text(option.$2),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _filter = _filter.copyWith(
                  minYearsExperience: option.$1,
                  clearMinYearsExperience: option.$1 == null,
                );
              });
            }
          },
        );
      }).toList(),
    );
  }

  void _resetFilters() {
    setState(() {
      _filter = TechnicianFilterModel.reset();
      _ratingValue = 0;
    });
  }
}
