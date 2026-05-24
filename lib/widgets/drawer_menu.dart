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
import '../../services/notifications_service.dart';

class DrawerMenu extends StatefulWidget {
  final String name;
  final String phone;
  final String? avatar;
  final VoidCallback? onProfileUpdated;

  const DrawerMenu({
    super.key,
    required this.name,
    required this.phone,
    this.avatar,
    this.onProfileUpdated,
  });

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  int unreadCount = 0;
  bool loadingNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final notifications = await NotificationsService.getNotifications();

      unreadCount = notifications.where((n) => n['is_read'] == 0).length;
    } catch (_) {
      unreadCount = 0;
    }

    if (mounted) {
      setState(() {
        loadingNotifications = false;
      });
    }
  }

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
    if (updated == true) widget.onProfileUpdated?.call();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.name.isNotEmpty ? widget.name : 'User';
    final avatarUrl = widget.avatar;
    final firstLetter = displayName[0].toUpperCase();

    return Drawer(
      child: Container(
        color: const Color(0xFFF7F9FB),
        child: Column(
          children: [
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
                      child: avatarUrl != null && avatarUrl.isNotEmpty
                          ? ClipOval(
                              child: Image.asset(
                                avatarUrl,
                                key: ValueKey(avatarUrl),
                                width: 52,
                                height: 52,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Text(
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
                            widget.phone,
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
            _section([
              _tile(context, Icons.inventory_2_outlined, 'Parcel',
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
              ListTile(
                leading: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.notifications_none,
                      color: Color(0xFF1F4B63),
                    ),
                    if (!loadingNotifications && unreadCount > 0)
                      Positioned(
                        right: -6,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                title: const Text(
                  'Notifications',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );

                  _loadUnreadCount();
                },
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
