import 'package:flutter/material.dart';
import '../screens/about_screen.dart';
import '../screens/help_center_screen.dart';
import '../screens/my_rides_screen.dart';
import '../screens/package_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/rewards_screen.dart';
import '../screens/special_trip_screen.dart';
import '../screens/wallet_screen.dart';
import '../screens/lost_and_found_screen.dart';
import '../screens/notifications_screen.dart';

class DrawerMenu extends StatelessWidget {
  final String name;
  final String phone;
  final VoidCallback? onProfileUpdated;
  const DrawerMenu(
      {super.key,
      required this.name,
      required this.phone,
      this.onProfileUpdated});

  void _go(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Future<void> _openProfile(BuildContext context) async {
    Navigator.pop(context);

    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );

    if (updated == true) {
      onProfileUpdated?.call();
    }
  }

  // ================= USER HEADER (UI ONLY) =================

  Widget _userHeader(BuildContext context) {
    final displayName = name.isNotEmpty ? name : 'User';
    final displayPhone = phone.isNotEmpty ? phone : '';
    final firstLetter = displayName[0].toUpperCase();

    return InkWell(
      onTap: () => _openProfile(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFEDEDED),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                firstLetter,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (displayPhone.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      displayPhone,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }

  // ================= ITEM =================

  Widget _item({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
      dense: true,
      visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _userHeader(context),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _item(
                    context: context,
                    icon: Icons.inventory_2_outlined,
                    title: 'Package',
                    onTap: () => _go(context, const PackageScreen()),
                  ),
                  _item(
                    context: context,
                    icon: Icons.star_border_rounded,
                    title: 'Special Trip',
                    onTap: () => _go(context, const SpecialTripScreen()),
                  ),
                  const Divider(height: 1),
                  _item(
                    context: context,
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Wallet',
                    onTap: () => _go(context, const WalletScreen()),
                  ),
                  _item(
                    context: context,
                    icon: Icons.card_giftcard_outlined,
                    title: 'Rewards',
                    onTap: () => _go(context, const RewardsScreen()),
                  ),
                  _item(
                    context: context,
                    icon: Icons.history_rounded,
                    title: 'My Rides',
                    onTap: () => _go(context, const MyRidesScreen()),
                  ),
                  _item(
                    context: context,
                    icon: Icons.search_off_rounded,
                    title: 'Lost & Found',
                    onTap: () => _go(context, const LostAndFoundScreen()),
                  ),
                  _item(
                    context: context,
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    onTap: () => _go(context, const NotificationsScreen()),
                  ),
                  const Divider(height: 1),
                  _item(
                    context: context,
                    icon: Icons.info_outline_rounded,
                    title: 'About',
                    onTap: () => _go(context, const AboutScreen()),
                  ),
                  _item(
                    context: context,
                    icon: Icons.headset_mic_outlined,
                    title: 'Help Center',
                    onTap: () => _go(context, const HelpCenterScreen()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
