import 'package:flutter/material.dart';
import 'package:justbus/screens/Student/SignUp_screen.dart';
import 'package:justbus/services/auth_service.dart';
import 'home_screen.dart';
import 'forgot_password_screen.dart';
import '../Driver/driver_home_screen.dart';
import 'package:justbus/services/profile_service.dart';
import 'package:justbus/services/secure_storage.dart';

enum UserRole { student, driver }

UserRole selectedRole = UserRole.student;
String? emailError;
String? passError;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _InputPill extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final IconData prefix;
  final Widget? suffix;
  final String? errorText;

  const _InputPill({
    required this.label,
    required this.hint,
    required this.controller,
    required this.prefix,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          TextField(
            cursorColor: const Color(0xFF1F4B63),
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              errorText: errorText,
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Colors.transparent,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF1F4B63),
                  width: 1.7,
                ),
              ),
              prefixIcon: Icon(
                prefix,
                color: Colors.black54,
              ),
              suffixIcon: suffix,
            ),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

Widget _roleButton({
  required String label,
  required IconData icon,
  required bool selected,
  required VoidCallback onTap,
}) {
  const primary = Color(0xFF1F4B63);

  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      height: 44,
      decoration: BoxDecoration(
        color: selected ? primary : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? primary : Colors.black12,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: selected ? Colors.white : Colors.black54,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    ),
  );
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool hidePass = true;
  bool rememberMe = true;
  String? loginError;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1F4B63);
    const lightGrey = Color(0xFFEDEDED);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Spacer(),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Welcome Back 👋\nLogin to JustBus',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: lightGrey,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.04),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _InputPill(
                              label: 'Email',
                              hint: 'example@email.com',
                              controller: emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              prefix: Icons.email_rounded,
                              errorText: emailError,
                            ),
                            const SizedBox(height: 12),
                            _InputPill(
                              label: 'Password',
                              hint: '••••••••',
                              controller: passCtrl,
                              obscure: hidePass,
                              prefix: Icons.lock_rounded,
                              errorText: passError,
                              suffix: IconButton(
                                onPressed: () =>
                                    setState(() => hidePass = !hidePass),
                                icon: Icon(
                                  hidePass
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (loginError != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 4,
                                  left: 6,
                                  bottom: 10,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    loginError!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            Row(
                              children: [
                                Expanded(
                                  child: _roleButton(
                                    label: 'Student',
                                    icon: Icons.person_rounded,
                                    selected: selectedRole == UserRole.student,
                                    onTap: () => setState(
                                        () => selectedRole = UserRole.student),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _roleButton(
                                    label: 'Driver',
                                    icon: Icons.airport_shuttle_rounded,
                                    selected: selectedRole == UserRole.driver,
                                    onTap: () => setState(
                                        () => selectedRole = UserRole.driver),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Checkbox(
                                  value: rememberMe,
                                  onChanged: (v) =>
                                      setState(() => rememberMe = v ?? true),
                                  activeColor: primary,
                                ),
                                const Text(
                                  'Remember me',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ForgotPasswordScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Forgot password?',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1F4B63),
                                    Color(0xFF2D6A8D),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1F4B63)
                                        .withOpacity(.25),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    emailError = null;
                                    passError = null;
                                  });

                                  if (emailCtrl.text.isEmpty) {
                                    setState(() {
                                      emailError = 'Please enter your email';
                                    });
                                    return;
                                  }

                                  if (passCtrl.text.isEmpty) {
                                    setState(() {
                                      passError = 'Please enter your password';
                                    });
                                    return;
                                  }

                                  String role;

                                  setState(() {
                                    loginError = null;
                                  });
                                  try {
                                    role = await AuthService.login(
                                      email: emailCtrl.text.trim(),
                                      password: passCtrl.text.trim(),
                                      role: selectedRole == UserRole.driver
                                          ? 'driver'
                                          : 'student',
                                    );
                                  } catch (e) {
                                    setState(() {
                                      loginError =
                                          "Incorrect email or password";
                                    });
                                    return;
                                  }

                                  try {
                                    final profile =
                                        await ProfileService.getProfile();
                                    await SecureStorage.saveUserName(
                                        profile['name'] ?? 'User');
                                  } catch (e) {
                                    debugPrint('Profile fetch failed: $e');
                                  }

                                  if (role == 'driver') {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const DriverHomeScreen(),
                                      ),
                                    );
                                  } else {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const HomeScreen(),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 28),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SignUpScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                              ),
                              child: const Text(
                                'Sign up',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F4B63),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
