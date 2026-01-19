import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'package:justbus/services/profile_service.dart';
import 'package:justbus/services/secure_storage.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _handleGetStarted(BuildContext context) async {
    final token = await SecureStorage.getToken();

    if (token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    try {
      // Validate token by calling backend
      await ProfileService.getProfile();

      // Token valid → go to home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (_) {
      await SecureStorage.clear();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3F647E),
              Color(0xFF1F3F54),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Center(
                    child: Image.asset(
                      'assets/images/JustBus_Main_Logo.png',
                      width: 350,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  'We’re',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                const Text(
                  'going on a trip.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Are you in?',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: () => _handleGetStarted(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEAEAEA),
                      foregroundColor: const Color(0xFF1F3F54),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    child: const Text(
                      'Get started',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
