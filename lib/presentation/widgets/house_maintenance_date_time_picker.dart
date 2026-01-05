// File: lib/presentation/widgets/house_maintenance_date_time_picker.dart
// Purpose: House Maintenance style date and time picker widget

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/design_tokens.dart';

/// House Maintenance style date and time selection widget
class HouseMaintenanceDateTimePicker extends StatefulWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final Function(DateTime) onDateSelected;
  final Function(TimeOfDay) onTimeSelected;

  const HouseMaintenanceDateTimePicker({
    super.key,
    this.selectedDate,
    this.selectedTime,
    required this.onDateSelected,
    required this.onTimeSelected,
  });

  @override
  State<HouseMaintenanceDateTimePicker> createState() =>
      _HouseMaintenanceDateTimePickerState();
}

class _HouseMaintenanceDateTimePickerState
    extends State<HouseMaintenanceDateTimePicker> {
  late ScrollController _dateScrollController;

  // Generate time slots
  final List<String> _timeSlots = [
    '1:00 PM - 1:30 PM',
    '2:00 PM - 2:30 PM',
    '3:00 PM - 3:30 PM',
    '4:00 PM - 4:30 PM',
    '5:00 PM - 5:30 PM',
    '6:00 PM - 6:30 PM',
  ];

  @override
  void initState() {
    super.initState();
    _dateScrollController = ScrollController();
  }

  @override
  void dispose() {
    _dateScrollController.dispose();
    super.dispose();
  }

  // Get dates for the next 7 days
  List<DateTime> get _availableDates {
    final now = DateTime.now();
    return List.generate(7, (index) => now.add(Duration(days: index)));
  }

  TimeOfDay _parseTimeSlot(String slot) {
    // Parse the start time from slot like "1:00 PM - 1:30 PM"
    final startTime = slot.split(' - ')[0];
    final parts = startTime.split(':');
    var hour = int.parse(parts[0]);
    final minute = int.parse(parts[1].split(' ')[0]);
    final isPM = startTime.contains('PM');

    if (isPM && hour != 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;

    return TimeOfDay(hour: hour, minute: minute);
  }

  bool _isSelectedDate(DateTime date) {
    if (widget.selectedDate == null) return false;
    return widget.selectedDate!.year == date.year &&
        widget.selectedDate!.month == date.month &&
        widget.selectedDate!.day == date.day;
  }

  bool _isSelectedTimeSlot(String slot) {
    if (widget.selectedTime == null) return false;
    final slotTime = _parseTimeSlot(slot);
    return slotTime.hour == widget.selectedTime!.hour &&
        slotTime.minute == widget.selectedTime!.minute;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Selection Section
        Text(
          'whichDayWouldYouLikeUsToCome'.tr(),
          style: TextStyle(
            fontSize: DesignTokens.fontSizeMD,
            fontWeight: DesignTokens.fontWeightBold,
            color: DesignTokens.neutral900,
          ),
        ),
        const SizedBox(height: DesignTokens.spaceSM),

        // Month label
        Text(
          DateFormat.MMMM().format(_availableDates.first),
          style: TextStyle(
            fontSize: DesignTokens.fontSizeSM,
            color: DesignTokens.neutral600,
          ),
        ),
        const SizedBox(height: DesignTokens.spaceMD),

        // Horizontal date picker
        SizedBox(
          height: 80,
          child: ListView.separated(
            controller: _dateScrollController,
            scrollDirection: Axis.horizontal,
            itemCount: _availableDates.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: DesignTokens.spaceSM),
            itemBuilder: (context, index) {
              final date = _availableDates[index];
              final isSelected = _isSelectedDate(date);

              return GestureDetector(
                onTap: () => widget.onDateSelected(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 50,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? DesignTokens.primaryBlue
                        : DesignTokens.neutral100,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
                    border: isSelected
                        ? null
                        : Border.all(color: DesignTokens.neutral200),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat.E()
                            .format(date)
                            .substring(0, 3)
                            .toUpperCase(),
                        style: TextStyle(
                          fontSize: DesignTokens.fontSizeXS,
                          fontWeight: DesignTokens.fontWeightMedium,
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.8)
                              : DesignTokens.neutral500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: DesignTokens.fontSizeLG,
                          fontWeight: DesignTokens.fontWeightBold,
                          color: isSelected
                              ? Colors.white
                              : DesignTokens.neutral900,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: DesignTokens.spaceXL),

        // Time Selection Section
        Text(
          'whatTimeWouldYouLikeUsToArrive'.tr(),
          style: TextStyle(
            fontSize: DesignTokens.fontSizeMD,
            fontWeight: DesignTokens.fontWeightBold,
            color: DesignTokens.neutral900,
          ),
        ),
        const SizedBox(height: DesignTokens.spaceMD),

        // Time slots grid (2 columns)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: DesignTokens.spaceMD,
            mainAxisSpacing: DesignTokens.spaceMD,
            childAspectRatio: 2.8,
          ),
          itemCount: _timeSlots.length,
          itemBuilder: (context, index) {
            final slot = _timeSlots[index];
            final isSelected = _isSelectedTimeSlot(slot);

            return GestureDetector(
              onTap: () => widget.onTimeSelected(_parseTimeSlot(slot)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? DesignTokens.primaryBlue.withValues(alpha: 0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
                  border: Border.all(
                    color: isSelected
                        ? DesignTokens.primaryBlue
                        : DesignTokens.neutral200,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    slot,
                    style: TextStyle(
                      fontSize: DesignTokens.fontSizeSM,
                      fontWeight: isSelected
                          ? DesignTokens.fontWeightSemiBold
                          : DesignTokens.fontWeightMedium,
                      color: isSelected
                          ? DesignTokens.primaryBlue
                          : DesignTokens.neutral700,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Progress indicator for booking flow - House Maintenance style
class BookingProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const BookingProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep;

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 8 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: isCompleted || isCurrent
                  ? DesignTokens.primaryBlue
                  : DesignTokens.neutral200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
