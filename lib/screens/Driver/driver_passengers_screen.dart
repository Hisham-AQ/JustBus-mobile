import 'package:flutter/material.dart';
import '../../services/driver_service.dart';

class DriverPassengersScreen extends StatefulWidget {
  const DriverPassengersScreen({super.key});

  @override
  State<DriverPassengersScreen> createState() =>
      _DriverPassengersScreenState();
}

class _DriverPassengersScreenState
    extends State<DriverPassengersScreen> {

  static const Color primary = Color(0xFF1F4B63);

  late Future<List<dynamic>> passengersFuture;

  @override
  void initState() {
    super.initState();
    passengersFuture = DriverService.getPassengers();
  }

  Future<void> _refresh() async {
    setState(() {
      passengersFuture = DriverService.getPassengers();
    });
  }

  Future<void> _dropOff(int seatId) async {
    try {

      await DriverService.dropOffPassenger(seatId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passenger dropped off"),
        ),
      );

      _refresh();

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Passenger Drop-off List",
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),

      body: FutureBuilder<List<dynamic>>(
        future: passengersFuture,

        builder: (context, snapshot) {

          // LOADING
          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ERROR
          if (snapshot.hasError) {

            return const Center(
              child: Text("Failed to load passengers"),
            );
          }

          final passengers = snapshot.data ?? [];

          // EMPTY
          if (passengers.isEmpty) {

            return const Center(
              child: Text("No passengers"),
            );
          }

          // LIST
          return RefreshIndicator(
            onRefresh: _refresh,

            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: passengers.length,

              itemBuilder: (context, index) {

                final p = passengers[index];

                final bool boarded =
                    p['is_boarded'] == 1;

                final bool dropped =
                    p['is_dropped_off'] == 1;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),

                  child: Row(
                    children: [

                      // AVATAR
                      CircleAvatar(
                        radius: 28,
                        backgroundColor:
                            boarded
                                ? Colors.green.shade100
                                : Colors.orange.shade100,

                        child: Icon(
                          boarded
                              ? Icons.check
                              : Icons.access_time,

                          color: boarded
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),

                      const SizedBox(width: 14),

                      // INFO
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            Text(
                              p['name'] ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Row(
                              children: [

                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),

                                  decoration: BoxDecoration(
                                    color: primary.withOpacity(0.1),
                                    borderRadius:
                                        BorderRadius.circular(30),
                                  ),

                                  child: Text(
                                    "Seat ${p['seat_number']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: primary,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),

                                  decoration: BoxDecoration(
                                    color: dropped
                                        ? Colors.red.shade50
                                        : boarded
                                            ? Colors.green.shade50
                                            : Colors.orange.shade50,

                                    borderRadius:
                                        BorderRadius.circular(30),
                                  ),

                                  child: Text(
                                    dropped
                                        ? "Dropped Off"
                                        : boarded
                                            ? "On Board"
                                            : "Pending",

                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,

                                      color: dropped
                                          ? Colors.red
                                          : boarded
                                              ? Colors.green
                                              : Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      // BUTTON
                      if (boarded && !dropped)
                        ElevatedButton(
                          onPressed: () {
                            _dropOff(p['id']);
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            elevation: 0,

                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),

                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                          ),

                          child: const Text(
                            "Drop Off",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}