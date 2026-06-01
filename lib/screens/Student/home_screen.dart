import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../widgets/drawer_menu.dart';
import '../../services/profile_service.dart';
import '../../services/city_service.dart';
import 'search_results_screen.dart';
import 'just_bot_sheet.dart';
import '../../services/activity_service.dart';
import 'rating_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<Map<String, dynamic>> _profileFuture;

  final LatLng justLocation = const LatLng(32.4953, 35.9900);

  List<String> cityLocations = [];
  bool isLoadingCities = true;
  String city = '';
  bool cityOnTop = true;

  DateTime selectedDate = DateTime.now();
  int persons = 1;

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService.getProfile();
    _loadCities();

    _checkPendingRatings();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadCities() async {
    try {
      final cities = await CityService.getCities();
      setState(() {
        cityLocations = cities;
        city = cities.isNotEmpty ? cities.first : '';
        isLoadingCities = false;
      });
    } catch (e) {
      setState(() => isLoadingCities = false);
    }
  }

  Widget _cityDropdown() {
    if (isLoadingCities) {
      return const Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (cityLocations.isEmpty) {
      return const Text(
        'No cities available',
        style: TextStyle(fontWeight: FontWeight.w600),
      );
    }

    return DropdownPill(
      value: city,
      items: cityLocations,
      onChanged: (v) {
        if (v != null) {
          setState(() => city = v);
        }
      },
    );
  }

  Future<void> _checkPendingRatings() async {
    try {
      final activity = await ActivityService.getMyActivity();

      final trips = List<Map<String, dynamic>>.from(
        activity['trips'] ?? [],
      );

      final pendingTrip = trips.cast<Map<String, dynamic>?>().firstWhere(
            (trip) =>
                trip != null &&
                trip['status'] == 'completed' &&
                trip['has_rating'] == 0,
            orElse: () => null,
          );

      if (pendingTrip == null || !mounted) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RatingScreen(
              tripId: pendingTrip['trip_id'],
            ),
          ),
        );
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Drawer(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final profile = snapshot.data!;
          return DrawerMenu(
            name: profile['name'] ?? '',
            phone: profile['phone'] ?? '',
            avatar: profile['avatar'],
            onProfileUpdated: () {
              setState(() {
                _profileFuture = ProfileService.getProfile();
              });
            },
          );
        },
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.06),
            ),
          ),
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(
                  justLocation.latitude + -0.010,
                  justLocation.longitude,
                ),
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
                      point: justLocation,
                      width: 60,
                      height: 60,
                      child: const Icon(
                        Icons.location_pin,
                        size: 42,
                        color: Color(0xFF1F4B63),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () async {
                    setState(() {
                      _profileFuture = ProfileService.getProfile();
                    });

                    await Future.delayed(
                      const Duration(milliseconds: 100),
                    );

                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(34),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 52,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Where are you\ngoing today?',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
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
                          Column(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                width: 2,
                                height: 70,
                                color: Color(0xFFD9D9D9),
                              ),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1F4B63),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              children: cityOnTop
                                  ? [
                                      _cityDropdown(),
                                      const SizedBox(height: 12),
                                      const FixedLocation(
                                          label: 'JUST university'),
                                    ]
                                  : [
                                      const FixedLocation(
                                          label: 'JUST university'),
                                      const SizedBox(height: 12),
                                      _cityDropdown(),
                                    ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => setState(() => cityOnTop = !cityOnTop),
                            child: Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F4B63),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
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
                    Row(
                      children: [
                        Expanded(
                          child: SmallInfoCard(
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
                          child: SmallInfoCard(
                            icon: Icons.people_alt_rounded,
                            text:
                                persons == 1 ? '1 Person' : '$persons Persons',
                            onTap: () =>
                                setState(() => persons = (persons % 5) + 1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1F4B63).withOpacity(0.22),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton(
                          onPressed: city.isEmpty
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SearchResultsScreen(
                                        from: cityOnTop
                                            ? city
                                            : 'JUST university',
                                        to: cityOnTop
                                            ? 'JUST university'
                                            : city,
                                        date: '${selectedDate.year}-'
                                            '${selectedDate.month.toString().padLeft(2, '0')}-'
                                            '${selectedDate.day.toString().padLeft(2, '0')}',
                                        persons: persons,
                                      ),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shadowColor: Colors.transparent,
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
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: FloatingActionButton(
                heroTag: 'justbot',
                backgroundColor: const Color(0xFF1F4B63),
                onPressed: () => _openJustBot(context),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/bot.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DropdownPill extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const DropdownPill({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          builder: (_) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: items.map((e) {
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      title: Text(
                        e,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      trailing: e == value
                          ? const Icon(
                              Icons.check_circle,
                              color: Color(0xFF1F4B63),
                            )
                          : null,
                      onTap: () {
                        onChanged(e);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            );
          },
        );
      },
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.black45,
            ),
          ],
        ),
      ),
    );
  }
}

class FixedLocation extends StatelessWidget {
  final String label;
  const FixedLocation({super.key, required this.label});

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

class SmallInfoCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const SmallInfoCard({
    super.key,
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
