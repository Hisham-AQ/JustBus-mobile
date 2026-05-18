import 'package:flutter/material.dart';
import 'package:justbus/services/auth_service.dart';
import '../Student/login_screen.dart';
import '../Driver/driver_scan_screen.dart';
import '../../services/driver_service.dart';
import 'driver_passengers_screen.dart';
import 'driver_report_screen.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../Student/notifications_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  static const Color primary = Color(0xFF1F4B63);
  static const Color bg = Color(0xFFF7F7F7);

  List<dynamic> trips = [];

  Map<String, dynamic>? trip;

  int? selectedTripId;
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
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    try {
      final data = await DriverService.getDriverTrips();

      if (data.isEmpty) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      selectedTripId = data.first['id'];

      final selectedTrip = await DriverService.getDriverTripById(
        selectedTripId!,
      );

      setState(() {
        trips = data;
        trip = selectedTrip;
        isLoading = false;
      });

      if (selectedTrip['status'] == 'ongoing') {
        await startLiveLocation(
          selectedTrip['id'],
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _changeTrip(
    int tripId,
  ) async {
    setState(() {
      isLoading = true;
    });

    final selectedTrip = await DriverService.getDriverTripById(
      tripId,
    );

    setState(() {
      selectedTripId = tripId;
      trip = selectedTrip;
      isLoading = false;
    });

    if (selectedTrip['status'] == 'ongoing') {
      await startLiveLocation(
        selectedTrip['id'],
      );
    } else {
      locationTimer?.cancel();
    }
  }

  String _formatDate(
    String? date,
  ) {
    if (date == null) return '';

    final d = DateTime.parse(date);

    return "${d.day}/${d.month}/${d.year}";
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
              final confirm = await _confirmDialog(
                context,
                title: 'Sign Out?',
                message: 'Are you sure you want to sign out from your account?',
                confirmText: 'Sign Out',
                color: Colors.red,
              );

              if (confirm != true) return;

              await AuthService.logout();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            margin: const EdgeInsets.only(
              bottom: 16,
            ),
            child: DropdownButtonFormField<int>(
              value: selectedTripId,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Select Trip",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              items: trips.map((t) {
                return DropdownMenuItem<int>(
                  value: t['id'],
                  child: Text(
                    "${t['from_city']} → "
                    "${t['to_city']} "
                    "(${t['departure_time']})",
                  ),
                );
              }).toList(),
              onChanged: (value) async {
                if (value == null) return;

                await _changeTrip(value);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1F4B63),
                  Color(0xFF2D6B8A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white24,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Text(
                      trip!['driver_name']
                          .toString()
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip!['driver_name'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.directions_bus_rounded,
                            color: Colors.white70,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Bus #${trip!['bus_number']}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          trip!['status'].toString().toUpperCase(),
                          style: TextStyle(
                            color: trip!['status'] == 'ongoing'
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (trip!['status'] == 'ongoing')
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.green.shade200,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Live tracking is active for passengers',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                  _formatDate(
                    trip!['trip_date'],
                  ),
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
                child: _actionCard(
                  title: 'Start Trip',
                  subtitle: 'Enable live tracking',
                  icon: Icons.play_arrow_rounded,
                  color: Colors.green,
                  onTap: () async {
                    final confirm = await _confirmDialog(
                      context,
                      title: 'Start Trip?',
                      message: 'Live tracking will begin for passengers.',
                      confirmText: 'Start',
                      color: Colors.green,
                    );

                    if (confirm != true) return;

                    await DriverService.startTrip(
                      tripId,
                    );

                    await startLiveLocation(
                      tripId,
                    );

                    await _loadTrips();

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        content: const Text(
                          'Trip started successfully',
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _actionCard(
                  title: 'End Trip',
                  subtitle: 'Finish current route',
                  icon: Icons.stop_rounded,
                  color: Colors.red,
                  onTap: () async {
                    final confirm = await _confirmDialog(
                      context,
                      title: 'End Trip?',
                      message: 'Passengers will no longer see live tracking.',
                      confirmText: 'End',
                      color: Colors.red,
                    );

                    if (confirm != true) return;

                    await DriverService.endTrip(
                      tripId,
                    );

                    locationTimer?.cancel();

                    await _loadTrips();

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        content: const Text(
                          'Trip completed',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _menuTile(
            icon: Icons.qr_code_scanner_rounded,
            title: 'Scan Passenger Ticket',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => DriverScanScreen(
                          tripId: selectedTripId!,
                        )),
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
                  builder: (_) => DriverPassengersScreen(
                    tripId: tripId,
                  ),
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
                    builder: (_) => DriverReportScreen(
                          tripId: selectedTripId!,
                        )),
              );
            },
          ),
          _menuTile(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static Widget _card({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(
                    999,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: primary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }

  static Widget _actionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color,
              color.withOpacity(0.75),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<bool?> _confirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required Color color,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    14,
                  ),
                ),
              ),
              child: Text(
                confirmText,
              ),
            ),
          ],
        );
      },
    );
  }
}
