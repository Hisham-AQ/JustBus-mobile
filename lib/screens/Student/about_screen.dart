import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const Color primary = Color(0xFF1F4B63);
  static const Color lightGrey = Color(0xFFEDEDED);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'About',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Color(0xFF3F647E),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/JustBus_Main_Logo.png',
                    width: 60,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'JustBus',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Smart Transportation System',
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          _sectionTitle('About the App'),
          const SizedBox(height: 8),
          const Text(
            'JustBus is a smart transportation application designed to simplify daily commuting '
            'for university students and staff. The app allows users to book trips, send packages, '
            'manage payments, and track their transportation history easily.',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 22),

          _sectionTitle('Main Features'),
          const SizedBox(height: 10),
          _featureTile(Icons.directions_bus_rounded, 'Book Trips to/from JUST'),
          _featureTile(Icons.inventory_2_outlined, 'Package Delivery Service'),
          _featureTile(Icons.account_balance_wallet_outlined,
              'Wallet & Online Payments'),
          _featureTile(Icons.redeem_rounded, 'Rewards & Offers'),
          _featureTile(Icons.notifications_none_rounded, 'Trip Notifications'),

          const SizedBox(height: 22),

          _sectionTitle('Development Team'),
          const SizedBox(height: 10),
          _infoTile('Project Type', 'Graduation Project'),
          _infoTile('Department', 'Software Engineering'),
          _infoTile(
              'University', 'Jordan University of Science and Technology'),
          _infoTile('Developed By', 'GP-17 Team'),

          const SizedBox(height: 22),

          Center(
            child: Column(
              children: const [
                Divider(),
                SizedBox(height: 10),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '© 2026 JustBus',
                  style: TextStyle(
                    color: Colors.black38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  static Widget _featureTile(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _infoTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
