// File: lib/screens/auth/welcome_screen.dart
// Purpose: Welcome screen with language selection and entry points.

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'technician_signup_screen.dart';
import '../../widgets/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(Icons.handyman, size: 80, color: Colors.blue),
              const SizedBox(height: 32),
              Text(
                'welcomeMessage'.tr(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'welcomeSubtitle'.tr(),
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Language Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      context.setLocale(const Locale('en'));
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: context.locale.languageCode == 'en'
                          ? Colors.blue
                          : Colors.grey,
                      textStyle: TextStyle(
                        fontWeight: context.locale.languageCode == 'en'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    child: const Text('English'),
                  ),
                  const Text('|', style: TextStyle(color: Colors.grey)),
                  TextButton(
                    onPressed: () {
                      context.setLocale(const Locale('ar'));
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: context.locale.languageCode == 'ar'
                          ? Colors.blue
                          : Colors.grey,
                      textStyle: TextStyle(
                        fontWeight: context.locale.languageCode == 'ar'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    child: const Text('العربية'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'login'.tr(),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'signup'.tr(),
                variant: ButtonVariant.outline,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'joinAsProfessional'.tr(),
                variant: ButtonVariant.text,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TechnicianSignupScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
