import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/drawer_menu.dart';
import 'search_results_screen.dart';
import 'just_bot_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> cityLocations = const [
    'Amman',
    'Irbid',
    'Zarqa',
    'Jerash',
  ];

  String city = 'Amman';
  bool cityOnTop = true;

  DateTime selectedDate = DateTime(2026, 1, 1);
  int persons = 1;

  @override
  Widget build(BuildContext context) {
    final just = LatLng(32.4953, 35.9900);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const DrawerMenu(),
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
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () =>
                      _scaffoldKey.currentState?.openDrawer(),
                ),
              ),
            ),
          ),

          // ================= BOTTOM CARD =================
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 30,
                    offset: Offset(0, -10),
                    color: Color(0x22000000),
                  ),
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

                    // ===== LOCATIONS =====
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
                              children: cityOnTop
                                  ? [
                                      _DropdownPill(
                                        value: city,
                                        items: cityLocations,
                                        onChanged: (v) {
                                          if (v != null) {
                                            setState(() => city = v);
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      const _FixedLocation(
                                          label: 'JUST university'),
                                    ]
                                  : [
                                      const _FixedLocation(
                                          label: 'JUST university'),
                                      const SizedBox(height: 12),
                                      _DropdownPill(
                                        value: city,
                                        items: cityLocations,
                                        onChanged: (v) {
                                          if (v != null) {
                                            setState(() => city = v);
                                          }
                                        },
                                      ),
                                    ],
                            ),
                          ),
                          const SizedBox(width: 12),

                          // ===== SWAP =====
                          GestureDetector(
                            onTap: () =>
                                setState(() => cityOnTop = !cityOnTop),
                            child: Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F4B63),
                                borderRadius: BorderRadius.circular(29),
                              ),
                              child: const Icon(
                                Icons.swap_vert_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ===== DATE & PERSONS =====
                    Row(
                      children: [
                        Expanded(
                          child: _SmallInfoCard(
                            icon: Icons.calendar_month_rounded,
                            text:
                                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2035),
                              );
                              if (picked != null) {
                                setState(() => selectedDate = picked);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SmallInfoCard(
                            icon: Icons.people_alt_rounded,
                            text: persons == 1
                                ? '1 Person'
                                : '$persons Persons',
                            onTap: () =>
                                setState(() => persons = (persons % 5) + 1),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ===== SEARCH =====
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SearchResultsScreen(
                                from: cityOnTop ? city : 'JUST',
                                to: cityOnTop ? 'JUST' : city,
                                date:
                                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                persons: persons,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F4B63),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'Search',
                          style: TextStyle(
                            fontSize: 26,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ================= JUST BOT (CORRECT PLACE) =================
          Positioned(
            right: 16,
            bottom: 790, // فوق الكارد
            child: FloatingActionButton(
              heroTag: 'justbot',
              backgroundColor: const Color(0xFF1F4B63),
              onPressed: () => _openJustBot(context),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= JUST BOT SHEET =================
void _openJustBot(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const JustBotSheet(),
  );
}

/* ================= WIDGETS ================= */

class _DropdownPill extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownPill({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _FixedLocation extends StatelessWidget {
  final String label;
  const _FixedLocation({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SmallInfoCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _SmallInfoCard({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
