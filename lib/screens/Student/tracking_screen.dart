import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../services/trip_service.dart';
import '../../services/secure_storage.dart';
import 'rating_screen.dart';
import '../../services/panic_service.dart';

class TrackingScreen extends StatefulWidget {
  final int tripId;
  final String pickupLocation;
  final String dropoffLocation;

  const TrackingScreen({
    super.key,
    required this.tripId,
    required this.pickupLocation,
    required this.dropoffLocation,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final MapController mapController = MapController();

  Timer? trackingTimer;
  LatLng? busLocation;
  List<LatLng> routePoints = [];
  LatLng? destinationLocation;
  double etaMinutes = 0;
  bool isBoarded = false;
  String tripStatus = '';
  bool firstMapMove = true;
  String driverName = '';
  String busNumber = '';

  final LatLng justLocation = const LatLng(32.4953, 35.9900);

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
        return LatLng(
          c[1],
          c[0],
        );
      }).toList();

      setState(() {});
    } catch (e) {
      print(
        "ROUTE ERROR: $e",
      );
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

  @override
  void initState() {
    super.initState();

    startTracking();
  }

  @override
  void dispose() {
    trackingTimer?.cancel();

    super.dispose();
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
                            tripId: widget.tripId,
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

  Future<void> loadBusLocation() async {
    final tripId = widget.tripId;
    try {
      final data = await TripService.getLiveLocation(
        tripId: tripId,
      );
      if (data['booking_status'] == 'cancelled') {
        trackingTimer?.cancel();

        await SecureStorage.clearTrackingTrip();
        await SecureStorage.clearPickupLocation();

        if (!mounted) return;

        setState(() {
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
        final finishedTripId = widget.tripId;

        await SecureStorage.clearTrackingTrip();
        await SecureStorage.clearPickupLocation();

        trackingTimer?.cancel();
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RatingScreen(
              tripId: finishedTripId,
            ),
          ),
        );
        setState(() {
          busLocation = null;
        });

        return;
      }
      setState(() {
        tripStatus = data['trip_status'] ?? '';
        driverName = data['driver_name'] ?? '';
        busNumber = data['bus_number'] ?? '';
      });

      if (data['current_lat'] == null || data['current_lng'] == null) {
        setState(() {
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
            if (!mounted || busLocation == null) return;

            try {
              mapController.move(
                busLocation!,
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
        busLocation = null;
        etaMinutes = 0;
        isBoarded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: mapController,
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
                        width: 60,
                        height: 60,
                        child: const Text(
                          '🚌',
                          style: TextStyle(
                            fontSize: 38,
                          ),
                        ),
                      )
                  ],
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16,
                top: 8,
              ),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  width: MediaQuery.of(context).size.width - 24,
                  padding: const EdgeInsets.all(12),
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
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.my_location,
                                color: Color(0xFF1F4B63),
                                size: 22,
                              ),
                              onPressed: () {
                                if (busLocation != null) {
                                  mapController.move(
                                    busLocation!,
                                    15,
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
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
                                ? "Destination ETA: ${etaMinutes.ceil()} min"
                                : "Pickup ETA: ${etaMinutes.ceil()} min",
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
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color:
                                        const Color(0xFF1F4B63).withOpacity(.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Color(0xFF1F4B63),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Driver",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        driverName.isEmpty
                                            ? "Driver unavailable"
                                            : driverName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Divider(
                              color: Colors.grey.shade300,
                              height: 1,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color:
                                        const Color(0xFF1F4B63).withOpacity(.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.directions_bus,
                                    color: Color(0xFF1F4B63),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Bus Number",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        busNumber,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (tripStatus != 'scheduled')
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Live tracking active',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      )
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
