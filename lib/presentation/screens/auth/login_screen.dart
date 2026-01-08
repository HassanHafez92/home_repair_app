// File: lib/screens/auth/login_screen.dart
// Purpose: Login screen handling user authentication.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../theme/design_tokens.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _headerAnimation;
  late Animation<double> _formAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _formAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Handle errors
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: DesignTokens.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
              ),
            ),
          );
        }
        // Handle password reset success
        if (state is AuthPasswordResetSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('passwordResetEmailSent'.tr()),
              backgroundColor: DesignTokens.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Gradient Header
                FadeTransition(
                  opacity: _headerAnimation,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      top:
                          MediaQuery.of(context).padding.top +
                          DesignTokens.spaceLG,
                      bottom: DesignTokens.space2XL,
                      left: DesignTokens.spaceLG,
                      right: DesignTokens.spaceLG,
                    ),
                    decoration: BoxDecoration(
                      gradient: DesignTokens.primaryGradient,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back button
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: DesignTokens.spaceLG),
                          Text(
                            'welcomeBack'.tr(),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: DesignTokens.fontWeightBold,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.spaceXS),
                          Text(
                            'pleaseLoginToContinue'.tr(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Form content with slide animation
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _formAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(DesignTokens.spaceLG),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: DesignTokens.spaceLG),
                            CustomTextField(
                              label: 'email'.tr(),
                              hint: 'enterYourEmail'.tr(),
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: const Icon(Icons.email_outlined),
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
                            const SizedBox(height: DesignTokens.spaceMD),
                            CustomTextField(
                              label: 'password'.tr(),
                              hint: 'enterYourPassword'.tr(),
                              controller: _passwordController,
                              obscureText: true,
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
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
                                    : () {
                                        if (_emailController.text.isEmpty) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'pleaseEnterEmailFirst'.tr(),
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                          return;
                                        }
                                        context.read<AuthBloc>().add(
                                          AuthPasswordResetRequested(
                                            email: _emailController.text.trim(),
                                          ),
                                        );
                                      },
                                child: Text(
                                  'forgotPassword'.tr(),
                                  style: TextStyle(
                                    color: DesignTokens.primaryBlue,
                                    fontWeight: DesignTokens.fontWeightMedium,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: DesignTokens.spaceMD),
                            CustomButton(
                              text: 'login'.tr(),
                              onPressed: isLoading ? null : _login,
                              isLoading: isLoading,
                            ),
                            const SizedBox(height: DesignTokens.spaceLG),

                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: DesignTokens.neutral300,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: DesignTokens.spaceMD,
                                  ),
                                  child: Text(
                                    'or'.tr(),
                                    style: TextStyle(
                                      color: DesignTokens.neutral500,
                                      fontWeight: DesignTokens.fontWeightMedium,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: DesignTokens.neutral300,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: DesignTokens.spaceLG),

                            // Social login buttons with better styling
                            _SocialLoginButton(
                              text: 'continueWithGoogle'.tr(),
                              iconPath: null,
                              icon: Icons.g_mobiledata,
                              backgroundColor: isDark
                                  ? DesignTokens.neutral800
                                  : Colors.white,
                              textColor: isDark
                                  ? Colors.white
                                  : DesignTokens.neutral900,
                              borderColor: DesignTokens.neutral300,
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      HapticFeedback.lightImpact();
                                      context.read<AuthBloc>().add(
                                        const AuthGoogleSignInRequested(),
                                      );
                                    },
                            ),
                            const SizedBox(height: DesignTokens.spaceMD),
                            _SocialLoginButton(
                              text: 'continueWithFacebook'.tr(),
                              iconPath: null,
                              icon: Icons.facebook,
                              backgroundColor: const Color(0xFF1877F2),
                              textColor: Colors.white,
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      HapticFeedback.lightImpact();
                                      context.read<AuthBloc>().add(
                                        const AuthFacebookSignInRequested(),
                                      );
                                    },
                            ),
                            const SizedBox(height: DesignTokens.spaceLG),

                            // Don't have account - Sign up
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'dontHaveAccount'.tr(),
                                  style: TextStyle(
                                    color: DesignTokens.neutral600,
                                    fontSize: DesignTokens.fontSizeBase,
                                  ),
                                ),
                                TextButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const SignupScreen(),
                                            ),
                                          );
                                        },
                                  child: Text(
                                    'signup'.tr(),
                                    style: const TextStyle(
                                      color: DesignTokens.primaryBlue,
                                      fontWeight: DesignTokens.fontWeightBold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: DesignTokens.spaceXL),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A styled social login button
class _SocialLoginButton extends StatelessWidget {
  final String text;
  final String? iconPath;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback? onPressed;

  const _SocialLoginButton({
    required this.text,
    this.iconPath,
    this.icon,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          side: borderColor != null
              ? BorderSide(color: borderColor!)
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, size: 24, color: textColor),
            const SizedBox(width: DesignTokens.spaceSM),
            Text(
              text,
              style: TextStyle(
                fontWeight: DesignTokens.fontWeightMedium,
                fontSize: DesignTokens.fontSizeBase,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
