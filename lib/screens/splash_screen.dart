import 'package:flutter/material.dart';
import 'package:justbus/services/auth_service.dart';
import 'home_screen.dart';
import 'driver_home_screen.dart';
import 'login_screen.dart';
import 'package:justbus/screens/welcome_screen.dart';


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
  await Future.delayed(const Duration(milliseconds: 800));

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
  );
}



  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
