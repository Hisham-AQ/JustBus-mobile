import 'package:flutter/material.dart';
import 'package:justbus/services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final oldPass = TextEditingController();
  final newPass = TextEditingController();
  final confirmPass = TextEditingController();

  bool showOld = false;
  bool showNew = false;
  bool showConfirm = false;
  bool loading = false;
  String? currentPasswordError;
  String? confirmPasswordError;

  String get passwordStrength {
    final password = newPass.text;

    if (password.isEmpty) {
      return '';
    }

    if (password.length < 6) {
      return 'Weak';
    }

    if (password.length < 10) {
      return 'Medium';
    }

    return 'Strong';
  }

  Color get passwordStrengthColor {
    switch (passwordStrength) {
      case 'Weak':
        return Colors.red;

      case 'Medium':
        return Colors.orange;

      case 'Strong':
        return Colors.green;

      default:
        return Colors.transparent;
    }
  }

  bool get passwordsMatch {
    return confirmPass.text.isNotEmpty && newPass.text == confirmPass.text;
  }

  Future<void> _changePassword() async {
    final current = oldPass.text.trim();
    final newPassword = newPass.text.trim();
    final confirm = confirmPass.text.trim();

    setState(() {
      currentPasswordError = null;
      confirmPasswordError = null;
    });

    if (current.isEmpty || newPassword.isEmpty || confirm.isEmpty) {
      return;
    }

    if (newPassword != confirm) {
      setState(() {
        confirmPasswordError = 'Passwords do not match';
      });
      return;
    }

    if (current == newPassword) {
      setState(() {
        confirmPasswordError = 'New password must be different';
      });
      return;
    }
    if (newPassword.length < 6) {
      return;
    }

    setState(() => loading = true);

    try {
      await AuthService.changePassword(
        currentPassword: current,
        newPassword: newPassword,
      );

      showDialog(
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
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.green,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Password Updated',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your password has been changed successfully.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F4B63),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
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
    } catch (e) {
      setState(() {
        currentPasswordError = 'Current password is incorrect';
      });
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    oldPass.dispose();
    newPass.dispose();
    confirmPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1F4B63);

    Widget passwordField({
      required String label,
      required String hint,
      required TextEditingController controller,
      required bool visible,
      required VoidCallback toggle,
      String? errorText,
      bool showSuccess = false,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: primary.withOpacity(.12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.04),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    color: primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextField(
                    onChanged: (_) => setState(() {}),
                    controller: controller,
                    obscureText: !visible,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: hint,
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showSuccess)
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    IconButton(
                      icon: Icon(
                        visible
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        color: primary,
                      ),
                      onPressed: toggle,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (errorText != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(
                errorText,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'Change Password',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1F4B63),
                        Color(0xFF2D6A8D),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(.18),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Create a strong password to keep your account secure.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              passwordField(
                label: 'Current password',
                hint: 'Enter current password',
                controller: oldPass,
                visible: showOld,
                toggle: () => setState(() => showOld = !showOld),
                errorText: currentPasswordError,
              ),
              const SizedBox(height: 28),
              passwordField(
                label: 'New password',
                hint: 'At least 6 characters',
                controller: newPass,
                visible: showNew,
                toggle: () => setState(() => showNew = !showNew),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: passwordStrength == 'Weak'
                              ? 0.33
                              : passwordStrength == 'Medium'
                                  ? 0.66
                                  : passwordStrength == 'Strong'
                                      ? 1
                                      : 0,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: passwordStrengthColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    passwordStrength.isEmpty ? 'Too weak' : passwordStrength,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: passwordStrengthColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              passwordField(
                label: 'Confirm new password',
                hint: 'Re-enter new password',
                controller: confirmPass,
                visible: showConfirm,
                toggle: () => setState(() => showConfirm = !showConfirm),
                errorText: confirmPasswordError,
                showSuccess: passwordsMatch,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Material(
                  color: Colors.transparent,
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1F4B63),
                          Color(0xFF2D6A8D),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: loading || passwordStrength == 'Weak'
                          ? null
                          : _changePassword,
                      child: Center(
                        child: loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Save',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                      ),
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
}
