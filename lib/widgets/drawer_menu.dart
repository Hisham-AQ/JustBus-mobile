import 'package:flutter/material.dart';
import '../screens/Student/about_screen.dart';
import '../screens/Student/help_center_screen.dart';
import '../screens/Student/my_activity_screen.dart';
import '../screens/Student/Parcel_screen.dart';
import '../screens/Student/profile_screen.dart';
import '../screens/Student/rewards_screen.dart';
import '../screens/Student/special_trip_screen.dart';
import '../screens/Student/wallet_screen.dart';
import '../screens/Student/lost_and_found_screen.dart';
import '../screens/Student/notifications_screen.dart';

class DrawerMenu extends StatelessWidget {
  final String name;
  final String phone;
  final VoidCallback? onProfileUpdated;

  const DrawerMenu({
    super.key,
    required this.name,
    required this.phone,
    this.onProfileUpdated,
  });

  void _go(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _openProfile(BuildContext context) async {
    Navigator.pop(context);
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
    if (updated == true) onProfileUpdated?.call();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = name.isNotEmpty ? name : 'User';
    final firstLetter = displayName[0].toUpperCase();

    return Drawer(
      child: Container(
        color: const Color(0xFFF7F9FB),
        child: Column(
          children: [
            // 🔥 HEADER
            Container(
              padding: const EdgeInsets.fromLTRB(16, 36, 16, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1F4B63), Color(0xFF2F6F8F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: InkWell(
                onTap: () => _openProfile(context),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white,
                      child: Text(
                        firstLetter,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            phone,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        color: Colors.white, size: 16)
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 🔹 MAIN SECTION
            _section([
              _tile(context, Icons.inventory_2_outlined, 'Package',
                  () => _go(context, const PackageScreen())),
              _tile(context, Icons.star_border, 'Special Trip',
                  () => _go(context, const SpecialTripScreen())),
            ]),

            _section([
              _tile(context, Icons.account_balance_wallet_outlined, 'Wallet',
                  () => _go(context, const WalletScreen())),
              _tile(context, Icons.card_giftcard, 'Rewards',
                  () => _go(context, const RewardsScreen())),
              _tile(context, Icons.history, 'My Activity',
                  () => _go(context, const MyActivityScreen())),
            ]),

            _section([
              _tile(context, Icons.search_off, 'Lost & Found',
                  () => _go(context, const LostAndFoundScreen())),

              // 🔥 Notifications with badge
              ListTile(
                leading: Stack(
                  children: [
                    const Icon(Icons.notifications_none),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                title: const Text('Notifications',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _go(context, const NotificationsScreen()),
              ),
            ]),

            _section([
              _tile(context, Icons.info_outline, 'About',
                  () => _go(context, const AboutScreen())),
              _tile(context, Icons.headset_mic, 'Help Center',
                  () => _go(context, const HelpCenterScreen())),
            ]),
          ],
        ),
      ),
    );
  }

  // 🔹 SECTION CARD
  Widget _section(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  // 🔹 ITEM
  Widget _tile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, size: 22, color: const Color(0xFF1F4B63)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
