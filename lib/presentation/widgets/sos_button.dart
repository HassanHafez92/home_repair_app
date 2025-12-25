// File: lib/presentation/widgets/sos_button.dart
// Purpose: SOS emergency button widget for technicians.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

/// Emergency SOS button for technicians
class SosButton extends StatefulWidget {
  /// Callback when SOS is triggered
  final VoidCallback onSosTriggered;

  /// Whether the button is currently active (on a job)
  final bool isActive;

  const SosButton({
    super.key,
    required this.onSosTriggered,
    this.isActive = true,
  });

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isHolding = false;
  double _holdProgress = 0;
  Timer? _holdTimer;

  static const _holdDuration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _holdTimer?.cancel();
    super.dispose();
  }

  void _startHold() {
    if (!widget.isActive) return;

    setState(() {
      _isHolding = true;
      _holdProgress = 0;
    });

    // Vibrate on start
    HapticFeedback.heavyImpact();

    // Start progress timer
    const interval = Duration(milliseconds: 50);
    final totalSteps = _holdDuration.inMilliseconds ~/ interval.inMilliseconds;
    int currentStep = 0;

    _holdTimer = Timer.periodic(interval, (timer) {
      currentStep++;
      setState(() {
        _holdProgress = currentStep / totalSteps;
      });

      if (_holdProgress >= 1) {
        timer.cancel();
        _triggerSos();
      }
    });
  }

  void _endHold() {
    _holdTimer?.cancel();
    setState(() {
      _isHolding = false;
      _holdProgress = 0;
    });
  }

  void _triggerSos() {
    // Strong vibration pattern
    HapticFeedback.heavyImpact();

    setState(() {
      _isHolding = false;
      _holdProgress = 0;
    });

    // Show confirmation dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.emergency, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text('sosAlert'.tr()),
          ],
        ),
        content: Text('sosConfirmMessage'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onSosTriggered();
              _showAlertSent();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('sendSos'.tr()),
          ),
        ],
      ),
    );
  }

  void _showAlertSent() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('sosAlertSent'.tr()),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onLongPressStart: (_) => _startHold(),
      onLongPressEnd: (_) => _endHold(),
      onLongPressCancel: _endHold,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isHolding ? 1.0 : _pulseAnimation.value,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Colors.red, Color(0xFFB71C1C)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.4),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Progress indicator
                  if (_isHolding)
                    SizedBox(
                      width: 68,
                      height: 68,
                      child: CircularProgressIndicator(
                        value: _holdProgress,
                        strokeWidth: 4,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        backgroundColor: Colors.white24,
                      ),
                    ),

                  // SOS text
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.emergency,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Floating SOS button that can be added to any screen
class FloatingSosButton extends StatelessWidget {
  final VoidCallback onSosTriggered;

  const FloatingSosButton({super.key, required this.onSosTriggered});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 80,
      child: SosButton(onSosTriggered: onSosTriggered, isActive: true),
    );
  }
}
