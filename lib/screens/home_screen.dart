import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> locations = const [
    'Amman',
    'Irbid',
    'Zarqa',
    'Jerash',
    'JUST',
  ];

  String fromLocation = 'Amman';
  String toLocation = 'JUST';

  DateTime selectedDate = DateTime(2026, 1, 1);
  int persons = 1;

  void swapLocations() {
    setState(() {
      final tmp = fromLocation;
      fromLocation = toLocation;
      toLocation = tmp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final just = LatLng(32.4953, 35.9900);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const _AppDrawer(),

      body: Stack(
        children: [
          // ================= MAP =================
          FlutterMap(
            options: MapOptions(
              initialCenter: just,
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.justbus_v1',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: just,
                    width: 46,
                    height: 46,
                    child: const Icon(
                      Icons.directions_bus_rounded,
                      size: 40,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ================= MENU BUTTON =================
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 18,
                      offset: Offset(0, 8),
                      color: Color(0x22000000),
                    )
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              ),
            ),
          ),

          // ================= BOTTOM UI =================
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 30,
                    offset: Offset(0, -10),
                    color: Color(0x22000000),
                  )
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Where would like\nto go today ?',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDEDED),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                _DropdownPill(
                                  value: fromLocation,
                                  items: locations,
                                  onChanged: (v) {
                                    if (v != null) setState(() => fromLocation = v);
                                  },
                                ),
                                const SizedBox(height: 12),
                                _DropdownPill(
                                  value: toLocation,
                                  items: locations,
                                  onChanged: (v) {
                                    if (v != null) setState(() => toLocation = v);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: swapLocations,
                            child: Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F4B63),
                                borderRadius: BorderRadius.circular(29),
                              ),
                              child: const Icon(Icons.swap_vert_rounded, color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: _SmallInfoCard(
                            icon: Icons.calendar_month_rounded,
                            text: '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2035),
                              );
                              if (picked != null) setState(() => selectedDate = picked);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SmallInfoCard(
                            icon: Icons.people_alt_rounded,
                            text: persons == 1 ? '1 Person' : '$persons Persons',
                            onTap: () => setState(() => persons = (persons % 5) + 1),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F4B63),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'Search',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= DRAWER ================= */

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.82,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFFEDEDED),
                    child: Text('U', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('User', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                        SizedBox(height: 4),
                        Text('+9627XXXXXXXX', style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
            const Divider(),

            Expanded(
              child: ListView(
                children: [
                  _DrawerTile(icon: Icons.inventory_rounded, title: 'Package'),
                  _DrawerTile(icon: Icons.star_rounded, title: 'Special Trip'),
                  const Divider(),
                  _DrawerTile(icon: Icons.redeem_rounded, title: 'Rewards'),
                  _DrawerTile(icon: Icons.history_rounded, title: 'My Rides'),
                  _DrawerTile(icon: Icons.notifications_none_rounded, title: 'Notifications'),
                  _DrawerTile(icon: Icons.account_balance_wallet_outlined, title: 'Wallet'),
                  const Divider(),
                  _DrawerTile(icon: Icons.info_outline_rounded, title: 'About'),
                  _DrawerTile(icon: Icons.headset_mic_rounded, title: 'Help Center'),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: const [
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= SMALL WIDGETS ================= */

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const _DrawerTile({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1F4B63)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => Navigator.pop(context),
    );
  }
}

class _DropdownPill extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownPill({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SmallInfoCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _SmallInfoCard({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 58,
        decoration: BoxDecoration(color: const Color(0xFFEDEDED), borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
