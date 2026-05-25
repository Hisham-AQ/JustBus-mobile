import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/trip_service.dart';
import '../../widgets/drawer_menu.dart';
import '../../services/profile_service.dart';
import '../../services/city_service.dart';
import 'search_results_screen.dart';
import 'just_bot_sheet.dart';
import '../../services/secure_storage.dart';
import 'rating_screen.dart';
import '../../services/panic_service.dart';

class HomeScreen extends StatefulWidget {
  final int? trackingTripId;
  final String? pickupLocation;

  const HomeScreen({
    super.key,
    this.trackingTripId,
    this.pickupLocation,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController mapController = MapController();
  int? activeTrackingTripId;
  Timer? trackingTimer;
  LatLng? busLocation;
  List<LatLng> routePoints = [];
  LatLng? destinationLocation;

  double etaMinutes = 0;
  bool isBoarded = false;
  bool trackingMode = false;
  String tripStatus = '';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<Map<String, dynamic>> _profileFuture;

  final LatLng justLocation = const LatLng(32.4953, 35.9900);

  List<String> cityLocations = [];
  bool isLoadingCities = true;
  bool firstMapMove = true;
  String city = '';
  bool cityOnTop = true;

  DateTime selectedDate = DateTime.now();
  int persons = 1;
  Future<void> loadRoute({
    required LatLng start,
    required LatLng end,
  }) async {
    try {
      final url = 'https://router.project-osrm.org/route/v1/driving/'
          '${start.longitude},${start.latitude};'
          '${end.longitude},${end.latitude}'
          '?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(url));

      final data = jsonDecode(response.body);

      final coords = data['routes'][0]['geometry']['coordinates'] as List;

      routePoints = coords.map((c) {
        return LatLng(c[1], c[0]);
      }).toList();

      setState(() {});
    } catch (e) {
      print("ROUTE ERROR: $e");
    }
  }

  Future<void> loadBusLocation() async {
    if (activeTrackingTripId == null) {
      return;
    }
    try {
      final data = await TripService.getLiveLocation(
        tripId: activeTrackingTripId!,
      );
      if (data['booking_status'] == 'cancelled') {
        trackingTimer?.cancel();

        await SecureStorage.clearTrackingTrip();
        await SecureStorage.clearPickupLocation();

        if (!mounted) return;

        setState(() {
          trackingMode = false;
          activeTrackingTripId = null;
          busLocation = null;
          etaMinutes = 0;
          isBoarded = false;
          routePoints = [];
          destinationLocation = null;
        });

        await showDialog(
          context: context,
          builder: (_) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cancel_rounded,
                        color: Colors.orange,
                        size: 46,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Trip Cancelled",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Your booking was cancelled by the admin.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F4B63),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "OK",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        return;
      }

      if (data['trip_status'] == 'completed') {
        final finishedTripId = activeTrackingTripId;

        await SecureStorage.clearTrackingTrip();
        await SecureStorage.clearPickupLocation();

        trackingTimer?.cancel();
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RatingScreen(
              tripId: finishedTripId!,
            ),
          ),
        );
        setState(() {
          trackingMode = false;

          busLocation = null;

          activeTrackingTripId = null;
        });

        return;
      }
      setState(() {
        tripStatus = data['trip_status'] ?? '';
      });

      if (data['current_lat'] == null || data['current_lng'] == null) {
        setState(() {
          trackingMode = true;

          tripStatus = data['trip_status'] ?? 'scheduled';

          busLocation = null;

          etaMinutes = 0;
        });

        return;
      }

      final location = LatLng(
        data['current_lat'],
        data['current_lng'],
      );
      if (!mounted) return;
      final boarded = data['is_boarded'] == 1 ||
          data['is_boarded'] == true ||
          data['is_boarded'].toString() == '1';

      print("IS BOARDED => $boarded");

      setState(() {
        tripStatus = data['trip_status'] ?? '';
        busLocation = location;
        etaMinutes = (data['eta_minutes'] ?? 0).toDouble();
        isBoarded = boarded;
      });

      final destination = boarded
          ? LatLng(
              data['dropoff_location']['lat'],
              data['dropoff_location']['lng'],
            )
          : LatLng(
              data['pickup_location']['lat'],
              data['pickup_location']['lng'],
            );

      setState(() {
        destinationLocation = destination;
      });

      await loadRoute(
        start: location,
        end: destination,
      );

      if (firstMapMove) {
        Future.delayed(
          const Duration(milliseconds: 300),
          () {
            if (!mounted) return;

            try {
              mapController.move(
                location,
                15,
              );
            } catch (_) {}
          },
        );

        firstMapMove = false;
      }
    } catch (e) {
      print(e);

      await SecureStorage.clearTrackingTrip();

      await SecureStorage.clearPickupLocation();

      if (!mounted) return;

      trackingTimer?.cancel();

      setState(() {
        trackingMode = false;

        activeTrackingTripId = null;

        busLocation = null;

        etaMinutes = 0;

        isBoarded = false;
      });
    }
  }

  Future<void> startTracking() async {
    trackingTimer?.cancel();
    await loadBusLocation();

    trackingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => loadBusLocation(),
    );
  }

  Future<void> _restoreTracking() async {
    int? tripId = widget.trackingTripId;

    tripId ??= await SecureStorage.getTrackingTrip();

    if (tripId == null) {
      return;
    }

    final data = await TripService.getLiveLocation(
      tripId: tripId,
    );

    if (data['trip_status'] != 'ongoing' &&
        data['trip_status'] != 'scheduled') {
      await SecureStorage.clearTrackingTrip();
      await SecureStorage.clearPickupLocation();

      return;
    }

    setState(() {
      trackingMode = true;

      activeTrackingTripId = tripId;
    });

    startTracking();
  }

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService.getProfile();
    _loadCities();
    _restoreTracking();
  }

  @override
  void dispose() {
    trackingTimer?.cancel();

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
                initialCenter: justLocation,
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.justbus_v1',
                ),
                if (routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        strokeWidth: 5,
                        color: const Color(0xFF1F4B63),
                        borderStrokeWidth: 2,
                        borderColor: Colors.white,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    if (!isBoarded)
                      Marker(
                        point: destinationLocation ?? justLocation,
                        width: 60,
                        height: 60,
                        child: const Icon(
                          Icons.location_pin,
                          size: 42,
                          color: Colors.orange,
                        ),
                      ),
                    if (isBoarded)
                      Marker(
                        point: destinationLocation ?? justLocation,
                        width: 60,
                        height: 60,
                        child: const Icon(
                          Icons.location_pin,
                          size: 42,
                          color: Colors.red,
                        ),
                      ),
                    if (busLocation != null)
                      Marker(
                        point: busLocation!,
                        width: 52,
                        height: 52,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.directions_bus_filled_rounded,
                              size: 24,
                              color: Color(0xFF1F4B63),
                            ),
                          ),
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
          if (!trackingMode)
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
                              onTap: () =>
                                  setState(() => cityOnTop = !cityOnTop),
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
          if (trackingMode)
            Positioned(
              left: 16,
              right: 16,
              bottom: 40,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tripStatus == 'scheduled'
                                ? "Waiting for driver ⏳"
                                : isBoarded
                                    ? "Heading to destination 🚍"
                                    : "Bus is on the way 🚍",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showPanicSheet();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.warning_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'PANIC',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      tripStatus == 'scheduled'
                          ? "Calculating ETA..."
                          : isBoarded
                              ? "Destination ETA: ${etaMinutes.toStringAsFixed(1)} min"
                              : "Pickup ETA: ${etaMinutes.toStringAsFixed(1)} min",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      tripStatus == 'scheduled'
                          ? "Waiting for driver..."
                          : isBoarded
                              ? "Bus heading to destination"
                              : "Bus heading to pickup point",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.qr_code),
                        label: const Text(
                          "Tracking Active",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
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

  void _showPanicSheet() {
    String selectedIssue = 'Feeling Unsafe';

    final TextEditingController noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Emergency Alert',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: selectedIssue,
                    decoration: InputDecoration(
                      labelText: 'Issue Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    items: const [
                      'Harassment',
                      'Driver Misconduct',
                      'Unsafe Driving',
                      'Medical Emergency',
                      'Feeling Unsafe',
                      'Other',
                    ].map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() {
                          selectedIssue = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: noteController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Additional details...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              title: const Text(
                                'Send Emergency Alert?',
                              ),
                              content: const Text(
                                'Your live location and trip details will be sent to university security.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: const Text('Send'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm != true) {
                          return;
                        }

                        try {
                          await PanicService.sendPanicAlert(
                            tripId: activeTrackingTripId!,
                            issueType: selectedIssue,
                            note: noteController.text.trim(),
                          );

                          if (!mounted) return;

                          Navigator.pop(context);

                          await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (dialogContext) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 90,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.warning_amber_rounded,
                                          color: Colors.red,
                                          size: 54,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        "Emergency Alert Sent",
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "justBus security has received your alert and location.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          height: 1.4,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 26),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 52,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(dialogContext);
                                          },
                                          child: const Text(
                                            "OK",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Send Alert',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
