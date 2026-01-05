// File: lib/screens/customer/booking/booking_flow_screen.dart
// Purpose: Multi-step booking process with House Maintenance style design.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:home_repair_app/domain/entities/service_entity.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/media_picker_widget.dart';
import '../../../widgets/house_maintenance_date_time_picker.dart';
import '../../../blocs/booking/booking_bloc.dart';
import '../../../blocs/booking/booking_event.dart';
import '../../../blocs/booking/booking_state.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import 'package:home_repair_app/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../blocs/address_book/address_book_bloc.dart';
import '../../../blocs/address_book/address_book_event.dart';
import '../../../blocs/address_book/address_book_state.dart';
import '../../../widgets/map_location_picker.dart';
import '../../../theme/design_tokens.dart';

class BookingFlowScreen extends StatefulWidget {
  final ServiceEntity service;

  const BookingFlowScreen({super.key, required this.service});

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    context.read<BookingBloc>().add(BookingStarted(widget.service));

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<AddressBookBloc>().add(LoadAddresses(authState.user.id));
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state.status == BookingStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'errorMessage'.tr(args: [state.errorMessage ?? '']),
              ),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state.status == BookingStatus.success) {
          _showSuccessDialog(state);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: DesignTokens.neutral900),
              onPressed: () {
                if (state.currentStep > 0) {
                  context.read<BookingBloc>().add(
                    BookingStepChanged(state.currentStep - 1),
                  );
                  _goToStep(state.currentStep - 1);
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            title: Text(
              _getStepTitle(state.currentStep),
              style: TextStyle(
                color: DesignTokens.neutral900,
                fontWeight: DesignTokens.fontWeightBold,
              ),
            ),
            actions: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.only(right: DesignTokens.spaceMD),
                child: SizedBox(
                  width: 80,
                  child: BookingProgressIndicator(
                    currentStep: state.currentStep,
                    totalSteps: 3,
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  context.read<BookingBloc>().add(BookingStepChanged(index));
                },
                children: [
                  // Step 1: Description
                  _buildDescriptionStep(state),
                  // Step 2: Location & Time
                  _buildLocationTimeStep(state),
                  // Step 3: Confirmation
                  _buildConfirmationStep(state),
                ],
              ),
              if (state.status == BookingStatus.submitting)
                Container(
                  color: Colors.black54,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(state),
        );
      },
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'describeProblem'.tr();
      case 1:
        return 'dateAndTime'.tr();
      case 2:
        return 'confirmation'.tr();
      default:
        return '';
    }
  }

  Widget _buildDescriptionStep(BookingState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service info card
          Container(
            padding: const EdgeInsets.all(DesignTokens.spaceMD),
            decoration: BoxDecoration(
              color: DesignTokens.primaryBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
              border: Border.all(
                color: DesignTokens.primaryBlue.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: DesignTokens.primaryBlue,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
                  ),
                  child: const Icon(
                    Icons.build_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: DesignTokens.spaceMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.service.name.tr(),
                        style: TextStyle(
                          fontSize: DesignTokens.fontSizeMD,
                          fontWeight: DesignTokens.fontWeightBold,
                          color: DesignTokens.neutral900,
                        ),
                      ),
                      Text(
                        'startingFrom'.tr(
                          args: ['${widget.service.minPrice.toInt()} EGP'],
                        ),
                        style: TextStyle(
                          fontSize: DesignTokens.fontSizeSM,
                          color: DesignTokens.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: DesignTokens.spaceXL),

          Text(
            'whatIsTheProblem'.tr(),
            style: TextStyle(
              fontSize: DesignTokens.fontSizeMD,
              fontWeight: DesignTokens.fontWeightBold,
              color: DesignTokens.neutral900,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceMD),

          CustomTextField(
            label: 'problemDescription'.tr(),
            hint: 'describeWhatNeedsToBeFixed'.tr(),
            controller: _descriptionController,
            maxLines: 4,
            onChanged: (value) {
              context.read<BookingBloc>().add(BookingDescriptionChanged(value));
            },
          ),

          const SizedBox(height: DesignTokens.spaceXL),

          Text(
            'addPhotosOrVideos'.tr(),
            style: TextStyle(
              fontSize: DesignTokens.fontSizeMD,
              fontWeight: DesignTokens.fontWeightBold,
              color: DesignTokens.neutral900,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceSM),
          Text(
            'photosHelpUsUnderstand'.tr(),
            style: TextStyle(
              fontSize: DesignTokens.fontSizeSM,
              color: DesignTokens.neutral500,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceMD),

          MediaPickerWidget(
            mediaFiles: state.mediaFiles,
            maxPhotos: 5,
            maxVideos: 1,
            maxVideoDurationSeconds: 30,
            onMediaAdded: (media) {
              context.read<BookingBloc>().add(BookingMediaAdded(media));
            },
            onMediaRemoved: (mediaId) {
              context.read<BookingBloc>().add(BookingMediaRemoved(mediaId));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTimeStep(BookingState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saved Addresses
          BlocBuilder<AddressBookBloc, AddressBookState>(
            builder: (context, addressState) {
              if (addressState.addresses.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'savedAddresses'.tr(),
                    style: TextStyle(
                      fontSize: DesignTokens.fontSizeMD,
                      fontWeight: DesignTokens.fontWeightBold,
                      color: DesignTokens.neutral900,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceMD),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: addressState.addresses.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: DesignTokens.spaceSM),
                      itemBuilder: (context, index) {
                        final address = addressState.addresses[index];
                        return _AddressChip(
                          icon: _getIconForLabel(address.label),
                          label: address.label,
                          isSelected:
                              _addressController.text == address.address,
                          onTap: () {
                            _addressController.text = address.address;
                            final lat = address.location['latitude'] as double;
                            final lng = address.location['longitude'] as double;
                            context.read<BookingBloc>().add(
                              BookingLocationChanged(
                                address.address,
                                latitude: lat,
                                longitude: lng,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceXL),
                ],
              );
            },
          ),

          // Location picker
          Text(
            'serviceLocation'.tr(),
            style: TextStyle(
              fontSize: DesignTokens.fontSizeMD,
              fontWeight: DesignTokens.fontWeightBold,
              color: DesignTokens.neutral900,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceMD),

          InkWell(
            onTap: () async {
              LatLng? initialLocation;
              if (state.latitude != null && state.longitude != null) {
                initialLocation = LatLng(state.latitude!, state.longitude!);
              }

              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => DraggableScrollableSheet(
                  initialChildSize: 0.9,
                  minChildSize: 0.5,
                  maxChildSize: 0.95,
                  builder: (_, controller) => MapLocationPicker(
                    initialLocation: initialLocation,
                    onLocationSelected: (location, address) {
                      _addressController.text = address;
                      context.read<BookingBloc>().add(
                        BookingLocationChanged(
                          address,
                          latitude: location.latitude,
                          longitude: location.longitude,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(DesignTokens.spaceMD),
              decoration: BoxDecoration(
                color: DesignTokens.neutral100,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
                border: Border.all(color: DesignTokens.neutral200),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: DesignTokens.primaryBlue),
                  const SizedBox(width: DesignTokens.spaceMD),
                  Expanded(
                    child: Text(
                      state.address.isNotEmpty
                          ? state.address
                          : 'tapToSelectOnMap'.tr(),
                      style: TextStyle(
                        color: state.address.isNotEmpty
                            ? DesignTokens.neutral900
                            : DesignTokens.neutral400,
                      ),
                    ),
                  ),
                  Icon(Icons.map_outlined, color: DesignTokens.neutral400),
                ],
              ),
            ),
          ),

          const SizedBox(height: DesignTokens.spaceXL),

          // House Maintenance style date/time picker
          HouseMaintenanceDateTimePicker(
            selectedDate: state.scheduledDate,
            selectedTime: state.scheduledTime,
            onDateSelected: (date) {
              context.read<BookingBloc>().add(
                BookingScheduleChanged(date: date),
              );
            },
            onTimeSelected: (time) {
              context.read<BookingBloc>().add(
                BookingScheduleChanged(time: time),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep(BookingState state) {
    final totalPrice =
        widget.service.avgPrice +
        widget.service.visitFee +
        (widget.service.avgPrice * 0.14);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'orderSummary'.tr(),
            style: TextStyle(
              fontSize: DesignTokens.fontSizeLG,
              fontWeight: DesignTokens.fontWeightBold,
              color: DesignTokens.neutral900,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceLG),

          // Summary card
          Container(
            padding: const EdgeInsets.all(DesignTokens.spaceMD),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
              border: Border.all(color: DesignTokens.neutral200),
              boxShadow: DesignTokens.shadowSoft,
            ),
            child: Column(
              children: [
                _SummaryRow(
                  label: 'service'.tr(),
                  value: widget.service.name.tr(),
                ),
                const Divider(height: DesignTokens.spaceLG),
                _SummaryRow(label: 'location'.tr(), value: state.address),
                const Divider(height: DesignTokens.spaceLG),
                _SummaryRow(
                  label: 'dateTime'.tr(),
                  value: _formatDateTime(state),
                ),
              ],
            ),
          ),

          const SizedBox(height: DesignTokens.spaceXL),

          // Price breakdown
          Text(
            'priceBreakdown'.tr(),
            style: TextStyle(
              fontSize: DesignTokens.fontSizeMD,
              fontWeight: DesignTokens.fontWeightBold,
              color: DesignTokens.neutral900,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceMD),

          Container(
            padding: const EdgeInsets.all(DesignTokens.spaceMD),
            decoration: BoxDecoration(
              color: DesignTokens.neutral50,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
            ),
            child: Column(
              children: [
                _PriceRow(
                  label: 'serviceFee'.tr(),
                  price: '${widget.service.avgPrice.toInt()} EGP',
                ),
                const SizedBox(height: DesignTokens.spaceSM),
                _PriceRow(
                  label: 'visitFee'.tr(),
                  price: '${widget.service.visitFee.toInt()} EGP',
                ),
                const SizedBox(height: DesignTokens.spaceSM),
                _PriceRow(
                  label: 'vat'.tr(),
                  price: '${(widget.service.avgPrice * 0.14).toInt()} EGP',
                ),
                const Divider(height: DesignTokens.spaceLG),
                _PriceRow(
                  label: 'total'.tr(),
                  price: '${totalPrice.toInt()} EGP',
                  isTotal: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BookingState state) {
    final totalPrice =
        widget.service.avgPrice +
        widget.service.visitFee +
        (widget.service.avgPrice * 0.14);

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceMD),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (state.currentStep == 2) ...[
              // Price display on confirmation step
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AED ${totalPrice.toInt()}',
                    style: TextStyle(
                      fontSize: DesignTokens.fontSizeLG,
                      fontWeight: DesignTokens.fontWeightBold,
                      color: DesignTokens.neutral900,
                    ),
                  ),
                  Text(
                    'total'.tr(),
                    style: TextStyle(
                      fontSize: DesignTokens.fontSizeXS,
                      color: DesignTokens.neutral500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: DesignTokens.spaceLG),
            ],
            Expanded(
              child: ElevatedButton(
                onPressed: () => _handleContinue(state),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: DesignTokens.spaceMD,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  state.currentStep == 2 ? 'confirmBooking'.tr() : 'next'.tr(),
                  style: const TextStyle(
                    fontSize: DesignTokens.fontSizeBase,
                    fontWeight: DesignTokens.fontWeightSemiBold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleContinue(BookingState state) {
    final bookingBloc = context.read<BookingBloc>();

    switch (state.currentStep) {
      case 0:
        if (state.isStep1Valid) {
          bookingBloc.add(const BookingStepChanged(1));
          _goToStep(1);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('pleaseDescribeProblem'.tr())));
        }
        break;
      case 1:
        if (state.isStep2Valid) {
          bookingBloc.add(const BookingStepChanged(2));
          _goToStep(2);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('pleaseFillAddressDateTime'.tr())),
          );
        }
        break;
      case 2:
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          final authService = AuthService();
          if (!authService.isEmailVerified) {
            _showVerificationDialog();
            return;
          }
          bookingBloc.add(BookingSubmitted(authState.user.id));
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('pleaseLoginToBook'.tr())));
        }
        break;
    }
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('verificationRequired'.tr()),
        content: Text('pleaseVerifyEmailToBook'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/email-verification');
            },
            child: Text('verifyNow'.tr()),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BookingState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: DesignTokens.accentGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: DesignTokens.accentGreen,
                size: 48,
              ),
            ),
            const SizedBox(height: DesignTokens.spaceLG),
            Text(
              'bookingConfirmed'.tr(),
              style: TextStyle(
                fontSize: DesignTokens.fontSizeLG,
                fontWeight: DesignTokens.fontWeightBold,
              ),
            ),
            const SizedBox(height: DesignTokens.spaceSM),
            Text(
              'orderCreatedSuccessfully'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(color: DesignTokens.neutral600),
            ),
            if (state.orderId != null) ...[
              const SizedBox(height: DesignTokens.spaceSM),
              Text(
                'orderNumber'.tr(args: [state.orderId!.substring(0, 8)]),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: Text('backToHome'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.popUntil(context, (route) => route.isFirst);
              if (state.orderId != null) {
                context.push('/customer/order/${state.orderId}');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.primaryBlue,
            ),
            child: Text('viewOrder'.tr()),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(BookingState state) {
    if (state.scheduledDate == null) return '-';

    final dateStr = DateFormat.yMMMd().format(state.scheduledDate!);
    final timeStr = state.scheduledTime?.format(context) ?? '';

    return '$dateStr ${timeStr.isNotEmpty ? 'at $timeStr' : ''}';
  }

  IconData _getIconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      default:
        return Icons.location_on;
    }
  }
}

/// Address chip widget
class _AddressChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AddressChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceMD,
          vertical: DesignTokens.spaceSM,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignTokens.primaryBlue.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
          border: Border.all(
            color: isSelected
                ? DesignTokens.primaryBlue
                : DesignTokens.neutral200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? DesignTokens.primaryBlue
                  : DesignTokens.neutral600,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? DesignTokens.primaryBlue
                    : DesignTokens.neutral700,
                fontWeight: isSelected
                    ? DesignTokens.fontWeightSemiBold
                    : DesignTokens.fontWeightMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Summary row widget
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: DesignTokens.neutral500,
            fontSize: DesignTokens.fontSizeSM,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: DesignTokens.neutral900,
              fontWeight: DesignTokens.fontWeightMedium,
            ),
          ),
        ),
      ],
    );
  }
}

/// Price row widget
class _PriceRow extends StatelessWidget {
  final String label;
  final String price;
  final bool isTotal;

  const _PriceRow({
    required this.label,
    required this.price,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? DesignTokens.neutral900 : DesignTokens.neutral600,
            fontWeight: isTotal
                ? DesignTokens.fontWeightBold
                : FontWeight.normal,
          ),
        ),
        Text(
          price,
          style: TextStyle(
            color: isTotal ? DesignTokens.primaryBlue : DesignTokens.neutral900,
            fontWeight: DesignTokens.fontWeightSemiBold,
            fontSize: isTotal ? DesignTokens.fontSizeMD : null,
          ),
        ),
      ],
    );
  }
}
