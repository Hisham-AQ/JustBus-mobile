import 'package:flutter/material.dart';
import '../../services/secure_storage.dart';
import '../../services/special_trip_service.dart';
import 'package:justbus/services/profile_service.dart';
import 'package:justbus/screens/Student/special_trip_ticket_screen.dart';

class SpecialTripDetailsScreen extends StatefulWidget {
  final String title;
  final String description;
  final String price;
  final String duration;
  final String rating;
  final String imageUrl;
  final int tripId;

  const SpecialTripDetailsScreen({
    super.key,
    required this.tripId,
    required this.title,
    required this.description,
    required this.price,
    required this.duration,
    required this.rating,
    required this.imageUrl,
  });

  @override
  State<SpecialTripDetailsScreen> createState() =>
      _SpecialTripDetailsScreenState();
}

class _SpecialTripDetailsScreenState extends State<SpecialTripDetailsScreen> {
  Map<String, dynamic>? trip;
  bool isLoading = true;
  bool isBooking = false;

  @override
  void initState() {
    super.initState();
    loadTrip();
  }

  Future<String> getUserName() async {
    final profile = await ProfileService.getProfile();
    return profile['name'] ?? "User";
  }

  Future<void> loadTrip() async {
    try {
      final data = await SpecialTripService.getTrip(
        widget.tripId,
      );

      setState(() {
        trip = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to load trip"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    List<String> includes = (trip!['includes'] ?? "").toString().split(",");
    List<String> notes = (trip!['notes'] ?? "").toString().split(",");

    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Hero(
                tag: widget.imageUrl,
                child: Image.network(
                  widget.imageUrl,
                  height: 380,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 48,
                left: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(widget.description,
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _infoBox('Duration', '${widget.duration} km'),
                        _infoBox('Rating', '${widget.rating} ★'),
                        _infoBox('Price', '${widget.price} JD'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text("Trip Details",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _detailRow(
                      "Seats",
                      "${trip!['seats_available']} / ${trip!['seats_total']}",
                    ),
                    _detailRow("Departure", trip!['departure_time']),
                    _detailRow("Return", trip!['return_time']),
                    _detailRow("Pickup", trip!['pickup_points']),
                    _detailRow("Bus", trip!['bus_type']),
                    const SizedBox(height: 16),
                    const Text("Includes",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...includes.map((e) => _bullet(e)),
                    const SizedBox(height: 16),
                    const Text("Important Notes",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...notes.map((e) => _bullet(e)),
                    const SizedBox(height: 30),

                    /// BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isBooking
                            ? null
                            : () async {
                                setState(() => isBooking = true);

                                bool? confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("Confirm Booking"),
                                      content: Text("Book ${widget.title}?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text("Cancel"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text("Confirm"),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirm != true) {
                                  setState(() => isBooking = false);
                                  return;
                                }

                                try {
                                  final token = await SecureStorage.getToken();

                                  final data =
                                      await SpecialTripService.bookTrip(
                                    widget.tripId,
                                    token!,
                                  );

                                  await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title:
                                            const Text("✅ Booking Confirmed"),
                                        content: const Text(
                                            "Your trip has been booked successfully"),
                                        actions: [
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("OK"),
                                          )
                                        ],
                                      );
                                    },
                                  );

                                  final name = await getUserName();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SpecialTicketScreen(
                                        userName: name,
                                        qrToken: data['qrToken'],
                                        bookingId: data['bookingId'],
                                        from: trip!['pickup_points'],
                                        to: trip!['title'],
                                        date: trip!['departure_time'],
                                        time: trip!['return_time'],
                                        status: data['status'] ?? "active",
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        e
                                            .toString()
                                            .replaceAll("Exception: ", ""),
                                      ),
                                    ),
                                  );
                                } finally {
                                  setState(() => isBooking = false);
                                }
                              },
                        child: const Text(
                          'Book Now',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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

  // ===== خارج build =====

  Widget _infoBox(String title, String value) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Row(
      children: [
        const Text("• "),
        Expanded(child: Text(text)),
      ],
    );
  }
}
