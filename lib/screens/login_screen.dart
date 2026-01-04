import 'package:flutter/material.dart';
import 'package:justbus/screens/SignUp_screen.dart';
import 'home_screen.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'forgot_password_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
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
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: lightGrey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 65),
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
    Checkbox(
      value: rememberMe,
      onChanged: (v) =>
          setState(() => rememberMe = v ?? true),
      activeColor: const Color(0xFF1F4B63),
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
                                      Text('Please enter email and password')),
                            );
                            return;
                          }

                          try {
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                              email: emailCtrl.text.trim(),
                              password: passCtrl.text.trim(),
                            );

                            // ✅ Login success → go to Home
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HomeScreen()),
                            );
                          } on FirebaseAuthException catch (e) {
                            String message;

                            switch (e.code) {
                              case 'user-not-found':
                                message = 'No account found for this email';
                                break;

                              case 'wrong-password':
                                message = 'Incorrect password';
                                break;

                              case 'invalid-credential':
                                message = 'Email or password is incorrect';
                                break;

                              case 'invalid-email':
                                message = 'Invalid email format';
                                break;

                              case 'user-disabled':
                                message = 'This account has been disabled';
                                break;

                              case 'too-many-requests':
                                message = 'Too many attempts. Try again later';
                                break;

                              default:
                                message = e.message ?? 'Login failed';
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(message)),
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
                              fontSize: 22, fontWeight: FontWeight.w900),
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
                  const Text('Don’t have an account? ',
                      style: TextStyle( fontSize: 15,fontWeight: FontWeight.w800)),
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
                      style: TextStyle(fontSize: 15,fontWeight: FontWeight.w900),
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
