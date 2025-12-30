import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  static const Color primary = Color(0xFF1F4B63);
  static const Color lightGrey = Color(0xFFEDEDED);

  Future<int> _loadPoints() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    return doc.data()?['points'] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Rewards',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<int>(
        future: _loadPoints(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final points = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
            children: [
              // ===== POINTS CARD =====
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1F4B63),
                      Color(0xFF2E6F8E),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Icon(Icons.emoji_events_rounded,
                        color: Colors.white, size: 42),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Points',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '$points pts',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // ===== HOW TO EARN =====
              const Text(
                'How to Earn Points',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),

              _earnTile(Icons.directions_bus_rounded, 'Take a trip', '+10 pts'),
              _earnTile(Icons.star_rounded, 'Take a special trip', '+20 pts'),
              _earnTile(
                  Icons.inventory_2_outlined, 'Send a package', '+15 pts'),

              const SizedBox(height: 26),

              // ===== AVAILABLE REWARDS =====
              const Text(
                'Available Rewards',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),

              _rewardTile(
                title: 'Free Trip',
                subtitle: 'One free ride to JUST',
                points: 500,
                icon: Icons.directions_bus_rounded,
                context: context,
              ),
              _rewardTile(
                title: 'Free Package',
                subtitle: 'Send a package for free',
                points: 350,
                icon: Icons.inventory_2_outlined,
                context: context,
              ),
              _rewardTile(
                title: '10% Discount',
                subtitle: 'On your next trip',
                points: 250,
                icon: Icons.percent_rounded,
                context: context,
              ),
            ],
          );
        },
      ),
    );
  }
  // ================= Widgets =================

  static Widget _earnTile(IconData icon, String title, String points) {
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
          Text(
            points,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: primary,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _rewardTile({
    required String title,
    required String subtitle,
    required int points,
    required IconData icon,
    required BuildContext context,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: primary, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '$points pts',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$title redeemed (demo)')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Redeem',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
