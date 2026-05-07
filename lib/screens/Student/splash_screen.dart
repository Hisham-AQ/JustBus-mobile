import 'package:flutter/material.dart';
import 'package:justbus/screens/Student/welcome_screen.dart';
import '../../services/secure_storage.dart';
import '../Driver/driver_home_screen.dart';
import '../Student/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

Future<void> _checkLogin() async {
  await Future.delayed(
    const Duration(seconds: 2),
  );

  if (!mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => const WelcomeScreen(),
    ),
  );
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: Center(
      child: Image.asset(
        'assets/images/JustBus_Main_Logo.png',
        width: 170,
      ),
    ),
  );
}

  
}
