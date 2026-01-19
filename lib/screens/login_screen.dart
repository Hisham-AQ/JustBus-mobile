import 'package:flutter/material.dart';
import 'package:justbus/screens/SignUp_screen.dart';
import 'package:justbus/services/auth_service.dart';
import 'home_screen.dart';
import 'forgot_password_screen.dart';
import 'driver_home_screen.dart';
import 'package:justbus/services/profile_service.dart';
import 'package:justbus/services/secure_storage.dart';

enum UserRole { student, driver }

UserRole selectedRole = UserRole.student;

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

  const _InputPill({
    required this.label,
    required this.hint,
    required this.controller,
    required this.prefix,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              prefixIcon: Icon(prefix),
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Column(
            children: [
              const SizedBox(height: 90),
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: lightGrey,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    _InputPill(
                      label: 'Email',
                      hint: 'name@student.just.edu.jo',
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      prefix: Icons.email_rounded,
                    ),
                    const SizedBox(height: 12),
                    _InputPill(
                      label: 'Password',
                      hint: '••••••••',
                      controller: passCtrl,
                      obscure: hidePass,
                      prefix: Icons.lock_rounded,
                      suffix: IconButton(
                        onPressed: () => setState(() => hidePass = !hidePass),
                        icon: Icon(
                          hidePass
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _roleButton(
                            label: 'Student',
                            icon: Icons.person_rounded,
                            selected: selectedRole == UserRole.student,
                            onTap: () =>
                                setState(() => selectedRole = UserRole.student),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _roleButton(
                            label: 'Driver',
                            icon: Icons.airport_shuttle_rounded,
                            selected: selectedRole == UserRole.driver,
                            onTap: () =>
                                setState(() => selectedRole = UserRole.driver),
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
                                builder: (_) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Please enter email and password'),
                              ),
                            );
                            return;
                          }

                          try {
                            final role = await AuthService.login(
                              email: emailCtrl.text.trim(),
                              password: passCtrl.text.trim(),
                            );
                            final profile = await ProfileService.getProfile();
                            await SecureStorage.saveUserName(
                                profile['name'] ?? 'User');
                            if (role == 'driver') {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DriverHomeScreen(),
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
                          } catch (_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Invalid email or password'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
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
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Don’t have an account? ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
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
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
