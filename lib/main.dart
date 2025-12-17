import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const JustBusApp());
}

class JustBusApp extends StatelessWidget {
  const JustBusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JustBus',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F647E),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}
