import 'package:flutter/material.dart';
import 'package:justbus/services/auth_service.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController codeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  int resendSeconds = 120;
  Timer? resendTimer;
  bool canResend = false;

  String get passwordStrength {
    final password = passwordController.text;

    if (password.isEmpty) {
      return '';
    }

    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasNumbers = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    int score = 0;

    if (password.length >= 8) score++;
    if (hasUppercase) score++;
    if (hasLowercase) score++;
    if (hasNumbers) score++;
    if (hasSpecial) score++;

    if (score <= 2) {
      return 'Weak';
    } else if (score <= 4) {
      return 'Medium';
    } else {
      return 'Strong';
    }
  }

  void startResendTimer() {
    resendTimer?.cancel();

    setState(() {
      resendSeconds = 120;
      canResend = false;
    });

    resendTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (resendSeconds == 0) {
          timer.cancel();

          setState(() {
            canResend = true;
          });
        } else {
          setState(() {
            resendSeconds--;
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    startResendTimer();
  }

  @override
  void dispose() {
    resendTimer?.cancel();

    codeController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: const Text(
          'Reset Password',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Enter verification code',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'We’ve sent a verification code to your email',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Code is required';
                  }
                  if (value.length != 6) {
                    return 'Enter 6-digit code';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Verification Code',
                  counterText: '',
                  prefixIcon: const Icon(Icons.confirmation_number),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: canResend
                      ? () async {
                          startResendTimer();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Verification code resent successfully',
                              ),
                            ),
                          );
                        }
                      : null,
                  child: Text(
                    canResend ? 'Resend Code' : 'Resend in ${resendSeconds}s',
                  ),
                ),
              ),
              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'New password is required';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }

                  if (!RegExp(r'[A-Z]').hasMatch(value)) {
                    return 'Add at least one uppercase letter';
                  }

                  if (!RegExp(r'[0-9]').hasMatch(value)) {
                    return 'Add at least one number';
                  }

                  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                    return 'Add at least one special character';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => obscurePassword = !obscurePassword);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              if (passwordController.text.length >= 4)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Password Strength: ",
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            passwordStrength,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: passwordStrength == 'Strong'
                                  ? Colors.green
                                  : passwordStrength == 'Medium'
                                      ? Colors.orange
                                      : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          value: passwordStrength == 'Weak'
                              ? 0.33
                              : passwordStrength == 'Medium'
                                  ? 0.66
                                  : 1,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            passwordStrength == 'Strong'
                                ? Colors.green
                                : passwordStrength == 'Medium'
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirm password is required';
                  }
                  if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F4B63),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await AuthService.resetPassword(
        code: codeController.text.trim(),
        newPassword: passwordController.text.trim(),
      );

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: 54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Password Reset Successful",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Your password has been updated successfully.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      height: 1.5,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F4B63),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);

                        Navigator.popUntil(
                          context,
                          (route) => route.isFirst,
                        );
                      },
                      child: const Text(
                        "Back to Login",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
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

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (_) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.red,
                      size: 46,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "Reset Failed",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    e.toString().replaceFirst('Exception: ', ''),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F4B63),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "OK",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
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
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
}
