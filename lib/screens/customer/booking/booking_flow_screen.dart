// File: lib/screens/customer/booking/booking_flow_screen.dart
// Purpose: Multi-step booking process for service orders using BLoC.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../models/service_model.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../blocs/booking/booking_bloc.dart';
import '../../../blocs/booking/booking_event.dart';
import '../../../blocs/booking/booking_state.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../blocs/address_book/address_book_bloc.dart';
import '../../../blocs/address_book/address_book_event.dart';
import '../../../blocs/address_book/address_book_state.dart';
import '../../../widgets/map_location_picker.dart';

class BookingFlowScreen extends StatefulWidget {
  final ServiceModel service;

  const BookingFlowScreen({super.key, required this.service});

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

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
    super.dispose();
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
          // Show success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 32),
                  const SizedBox(width: 12),
                  Flexible(child: Text('bookingConfirmed'.tr())),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('orderCreatedSuccessfully'.tr()),
                  const SizedBox(height: 8),
                  if (state.orderId != null)
                    Text(
                      'orderNumber'.tr(args: [state.orderId!.substring(0, 8)]),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.popUntil(context, (route) => route.isFirst);
                    if (state.orderId != null) {
                      context.push('/customer/order/${state.orderId}');
                    }
                  },
                  child: Text('viewOrder'.tr()),
                ),
              ],
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('bookService'.tr(args: [widget.service.name])),
          ),
          body: Stack(
            children: [
              Stepper(
                currentStep: state.currentStep,
                onStepContinue: () {
                  final bookingBloc = context.read<BookingBloc>();
                  switch (state.currentStep) {
                    case 0: // Description
                      if (state.isStep1Valid) {
                        bookingBloc.add(const BookingStepChanged(1));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('pleaseDescribeProblem'.tr())),
                        );
                      }
                      break;
                    case 1: // Location & Time
                      if (state.isStep2Valid) {
                        bookingBloc.add(const BookingStepChanged(2));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('pleaseFillAddressDateTime'.tr()),
                          ),
                        );
                      }
                      break;
                    case 2: // Payment
                      bookingBloc.add(const BookingStepChanged(3));
                      break;
                    case 3: // Confirmation
                      final authState = context.read<AuthBloc>().state;
                      if (authState is AuthAuthenticated) {
                        // Check email verification before allowing booking
                        final authService = AuthService();
                        if (!authService.isEmailVerified) {
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
                          return;
                        }

                        bookingBloc.add(BookingSubmitted(authState.user.id));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('pleaseLoginToBook'.tr())),
                        );
                      }
                      break;
                  }
                },
                onStepCancel: () {
                  if (state.currentStep > 0) {
                    context.read<BookingBloc>().add(
                      BookingStepChanged(state.currentStep - 1),
                    );
                  }
                },
                steps: [
                  // Step 1: Description
                  Step(
                    title: Text('describeProblem'.tr()),
                    content: CustomTextField(
                      label: 'problemDescription'.tr(),
                      hint: 'describeWhatNeedsToBeFixed'.tr(),
                      controller: _descriptionController,
                      maxLines: 4,
                      onChanged: (value) {
                        context.read<BookingBloc>().add(
                          BookingDescriptionChanged(value),
                        );
                      },
                    ),
                    isActive: state.currentStep >= 0,
                  ),
                  // Step 2: Location & Schedule
                  Step(
                    title: Text('locationTime'.tr()),
                    content: Column(
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 40,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: addressState.addresses.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(width: 8),
                                    itemBuilder: (context, index) {
                                      final address =
                                          addressState.addresses[index];
                                      return ActionChip(
                                        avatar: Icon(
                                          _getIconForLabel(address.label),
                                          size: 16,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                        label: Text(address.label),
                                        onPressed: () {
                                          _addressController.text =
                                              address.address;
                                          final lat =
                                              address.location['latitude']
                                                  as double;
                                          final lng =
                                              address.location['longitude']
                                                  as double;
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
                                const SizedBox(height: 16),
                              ],
                            );
                          },
                        ),
                        // Address display with map picker button
                        InkWell(
                          onTap: () async {
                            // Get current location if available
                            LatLng? initialLocation;
                            if (state.latitude != null &&
                                state.longitude != null) {
                              initialLocation = LatLng(
                                state.latitude!,
                                state.longitude!,
                              );
                            }

                            // Open map picker
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
                          child: AbsorbPointer(
                            child: CustomTextField(
                              label: 'serviceAddress'.tr(),
                              hint: 'tapToSelectOnMap'.tr(),
                              controller: _addressController,
                              suffixIcon: const Icon(Icons.map),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'preferredDate'.tr(),
                          hint: 'selectDate'.tr(),
                          readOnly: true,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 30),
                              ),
                            );
                            if (date != null && context.mounted) {
                              context.read<BookingBloc>().add(
                                BookingScheduleChanged(date: date),
                              );
                            }
                          },
                          controller: TextEditingController(
                            text: state.scheduledDate != null
                                ? state.scheduledDate.toString().split(' ')[0]
                                : '',
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'preferredTime'.tr(),
                          hint: 'selectTime'.tr(),
                          readOnly: true,
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null && context.mounted) {
                              context.read<BookingBloc>().add(
                                BookingScheduleChanged(time: time),
                              );
                            }
                          },
                          controller: TextEditingController(
                            text: state.scheduledTime?.format(context) ?? '',
                          ),
                        ),
                      ],
                    ),
                    isActive: state.currentStep >= 1,
                  ),
                  // Step 3: Payment Method
                  Step(
                    title: Text('paymentMethod'.tr()),
                    content: RadioGroup<String>(
                      groupValue: state.paymentMethod,
                      onChanged: (value) {
                        if (value != null) {
                          context.read<BookingBloc>().add(
                            BookingPaymentMethodChanged(value),
                          );
                        }
                      },
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            title: Text('cashOnDelivery'.tr()),
                            value: 'cash',
                          ),
                          RadioListTile<String>(
                            title: Text('wallet'.tr()),
                            value: 'wallet',
                          ),
                          RadioListTile<String>(
                            title: Text('card'.tr()),
                            value: 'card',
                          ),
                        ],
                      ),
                    ),
                    isActive: state.currentStep >= 2,
                  ),
                  // Step 4: Confirmation
                  Step(
                    title: Text('confirmation'.tr()),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryRow('services'.tr(), widget.service.name),
                        _buildSummaryRow('serviceAddress'.tr(), state.address),
                        _buildSummaryRow(
                          'preferredDate'.tr(),
                          state.scheduledDate != null
                              ? state.scheduledDate.toString().split(' ')[0]
                              : '',
                        ),
                        _buildSummaryRow(
                          'preferredTime'.tr(),
                          state.scheduledTime?.format(context) ?? '',
                        ),
                        _buildSummaryRow(
                          'paymentMethod'.tr(),
                          state.paymentMethod.toUpperCase(),
                        ),
                        const Divider(),
                        _buildSummaryRow(
                          'serviceFee'.tr(),
                          '${widget.service.avgPrice.toInt()} EGP',
                          bold: true,
                        ),
                        _buildSummaryRow(
                          'visitFee'.tr(),
                          '${widget.service.visitFee.toInt()} EGP',
                        ),
                        _buildSummaryRow(
                          'vat'.tr(),
                          '${(widget.service.avgPrice * 0.14).toInt()} EGP',
                        ),
                        const Divider(),
                        _buildSummaryRow(
                          'total'.tr(),
                          '${(widget.service.avgPrice + widget.service.visitFee + widget.service.avgPrice * 0.14).toInt()} EGP',
                          bold: true,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    isActive: state.currentStep >= 3,
                  ),
                ],
              ),
              if (state.status == BookingStatus.submitting)
                Container(
                  color: Colors.black54,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool bold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
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

// Helper widget for RadioGroup since it was used in the original code but might be a custom widget
// Wait, I see `RadioGroup` in the original code. It might be imported or defined elsewhere.
// I'll assume it's not needed if I configure RadioListTiles correctly.
// I'll modify the build method to not use RadioGroup wrapper if it's not standard.
// But to be safe, I'll check if it was imported. It wasn't imported in the original file I read.
// It might be a typo in my reading or it was defined in the file but I missed it?
// No, I read the whole file.
// Ah, `RadioListTile` is standard. `RadioGroup` is NOT standard Flutter widget.
// It must have been a custom widget or I misread.
// Let me check the original file content again.
// Line 279: `content: RadioGroup<String>(`
// It was there. But no import for it.
// Maybe it's in `custom_text_field.dart`? Or just a missing import in the original file that worked by accident or global export?
// Or maybe it was defined in the file and I missed it?
// I'll check the file content again.
