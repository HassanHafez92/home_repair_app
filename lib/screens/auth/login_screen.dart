// File: lib/screens/auth/login_screen.dart
// Purpose: Login screen handling user authentication.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;

    // Dispatch login event to AuthBloc
    context.read<AuthBloc>().add(
      AuthLoginRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Handle errors
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          appBar: AppBar(title: Text('login'.tr())),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'welcomeBack'.tr(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'pleaseLoginToContinue'.tr(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    label: 'email'.tr(),
                    hint: 'enterYourEmail'.tr(),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'pleaseEnterEmail'.tr();
                      }
                      final emailRegex = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      );
                      if (!emailRegex.hasMatch(value)) {
                        return 'invalidEmailAddress'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'password'.tr(),
                    hint: 'enterYourPassword'.tr(),
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'pleaseEnterPassword'.tr();
                      }
                      return null;
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (_emailController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('pleaseEnterEmailFirst'.tr()),
                                  ),
                                );
                                return;
                              }
                              // Note: Password reset still uses AuthService directly
                              // We can add a PasswordResetRequested event later
                              try {
                                // For now, we'll skip password reset in BLoC
                                // This can be migrated later
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Password reset will be implemented',
                                    ),
                                  ),
                                );
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'errorMessage'.tr(args: [e.toString()]),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                      child: Text('forgotPassword'.tr()),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'login'.tr(),
                    onPressed: isLoading ? null : _login,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('or'.tr()),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'continueWithGoogle'.tr(),
                    variant: ButtonVariant.outline,
                    icon: Icons.g_mobiledata,
                    onPressed: isLoading
                        ? null
                        : () {
                            context.read<AuthBloc>().add(
                              const AuthGoogleSignInRequested(),
                            );
                          },
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'continueWithFacebook'.tr(),
                    variant: ButtonVariant.outline,
                    icon: Icons.facebook,
                    onPressed: isLoading
                        ? null
                        : () {
                            context.read<AuthBloc>().add(
                              const AuthFacebookSignInRequested(),
                            );
                          },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
