import 'package:flutter/material.dart';
import 'package:justbus/services/auth_service.dart';
import '../Student/login_screen.dart';
import '../Driver/driver_scan_screen.dart';
import '../../services/driver_service.dart';
import 'driver_passengers_screen.dart';
import 'driver_report_screen.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  static const Color primary = Color(0xFF1F4B63);
  static const Color bg = Color(0xFFF7F7F7);

  Map<String, dynamic>? trip;
  bool isLoading = true;
  Timer? locationTimer;

  Future<void> startLiveLocation(int tripId) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    locationTimer?.cancel();
    try {
      Position pos = await Geolocator.getCurrentPosition();

      await DriverService.updateLocation(
        tripId: tripId,
        lat: pos.latitude,
        lng: pos.longitude,
      );

      print(
        "FIRST LOCATION SENT: "
        "${pos.latitude}, ${pos.longitude}",
      );
    } catch (e) {
      print(e);
    }
    locationTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) async {
        try {
          Position pos = await Geolocator.getCurrentPosition();

          await DriverService.updateLocation(
            tripId: tripId,
            lat: pos.latitude,
            lng: pos.longitude,
          );

          print(
            "LOCATION SENT: "
            "${pos.latitude}, ${pos.longitude}",
          );
        } catch (e) {
          print(e);
        }
      },
    );
  }

  @override
  void dispose() {
    locationTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadTrip();
  }

  Future<void> _loadTrip() async {
    try {
      final data = await DriverService.getCurrentTrip();
      setState(() {
        trip = data;
        isLoading = false;
      });

      if (data['status'] == 'ongoing') {
        await startLiveLocation(data['id']);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (trip == null) {
      return const Scaffold(
        body: Center(
          child: Text("No assigned trip"),
        ),
      );
    }

    final tripId = trip!['id'];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Driver Dashboard',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await AuthService.logout();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: primary,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip!['driver_name'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bus #${trip!['bus_number']}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _card(
              title: 'Current Trip',
              child: Column(
                children: [
                  _row(
                    Icons.place_rounded,
                    'From',
                    trip!['from_city'] ?? '',
                  ),
                  _row(
                    Icons.flag_rounded,
                    'To',
                    trip!['to_city'] ?? '',
                  ),
                  const Divider(),
                  _row(
                    Icons.calendar_month,
                    'Date',
                    trip!['trip_date'] ?? '',
                  ),
                  _row(
                    Icons.access_time,
                    'Time',
                    '${trip!['departure_time']} → ${trip!['arrival_time']}',
                  ),
                  _row(
                    Icons.info_outline,
                    'Status',
                    trip!['status'],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Start Trip'),
                    onPressed: () async {
                      await DriverService.startTrip(tripId);
                      await startLiveLocation(tripId);
                      await _loadTrip();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Trip started"),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.stop_rounded),
                    label: const Text('End Trip'),
                    onPressed: () async {
                      await DriverService.endTrip(tripId);
                      locationTimer?.cancel();
                      await _loadTrip();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Trip completed"),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _menuTile(
                    icon: Icons.qr_code_scanner_rounded,
                    title: 'Scan Passenger Ticket',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DriverScanScreen(),
                        ),
                      );
                    },
                  ),
                  _menuTile(
                    icon: Icons.people_outline_rounded,
                    title: 'Passenger Drop-off List',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DriverPassengersScreen(),
                        ),
                      );
                    },
                  ),
                  _menuTile(
                    icon: Icons.report_problem_outlined,
                    title: 'Report Misconduct',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DriverReportScreen(),
                        ),
                      );
                    },
                  ),
                  _menuTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _card({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  static Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  static Widget _menuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: Icon(icon, color: primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
