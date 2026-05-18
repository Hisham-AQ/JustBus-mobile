import 'package:flutter/material.dart';
import '../../services/rewards_service.dart';
import 'package:flutter/services.dart';
import 'package:justbus/screens/Student/home_screen.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  static const Color primary = Color(0xFF1F4B63);
  //static const Color lightGrey = Color(0xFFEDEDED);

  int points = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPoints();
  }

  Future<void> loadPoints() async {
    try {
      final result = await RewardsService.getPoints();

      setState(() {
        points = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
        children: [
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
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Points',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isLoading ? '...' : '$points pts',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (points / 500).clamp(0, 1),
                            minHeight: 6,
                            backgroundColor: Colors.white24,
                            valueColor:
                                const AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
          const SizedBox(height: 26),
          const Text(
            'How to Earn Points',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          _earnTile(Icons.directions_bus_rounded, 'Take a trip', '+10 pts'),
          _earnTile(Icons.star_rounded, 'Take a special trip', '+20 pts'),
          _earnTile(Icons.inventory_2_outlined, 'Send a Parcel', '+15 pts'),
          const SizedBox(height: 26),
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
            currentPoints: points,
            onRedeem: () => handleRedeem("free_trip"),
          ),
          _rewardTile(
            title: 'Free Parcel',
            subtitle: 'Send a Parcel for free',
            points: 350,
            icon: Icons.inventory_2_outlined,
            context: context,
            currentPoints: points,
            onRedeem: () => handleRedeem("free_parcel"),
          ),
          _rewardTile(
            title: '10% Discount',
            subtitle: 'On your next trip',
            points: 250,
            icon: Icons.percent_rounded,
            context: context,
            currentPoints: points,
            onRedeem: () => handleRedeem("discount"),
          ),
        ],
      ),
    );
  }

  Future<void> handleRedeem(String type) async {
    try {
      final result = await RewardsService.redeem(type);

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          final code = result['code'] ?? '';

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.card_giftcard,
                      color: Colors.green,
                      size: 50,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // TITLE
                  const Text(
                    "Your Reward Code 🎉",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // CODE BOX
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            code,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ),

                        // COPY BUTTON
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: code));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Code copied")),
                            );
                          },
                          child: const Icon(Icons.copy, size: 20),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text("OK"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HomeScreen()),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text("Home"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
      await loadPoints();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  static Widget _earnTile(IconData icon, String title, String points) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
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
    required VoidCallback onRedeem,
    required int currentPoints,
  }) {
    final canRedeem = currentPoints >= points;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: primary, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w900)),
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
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$points pts',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: canRedeem ? onRedeem : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canRedeem ? primary : Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Redeem'),
                ),
              ),
              if (!canRedeem)
                Text(
                  "${points - currentPoints} pts",
                  style: const TextStyle(fontSize: 10, color: Colors.red),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
