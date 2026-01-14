import 'package:flutter/material.dart';
import '../services/trip_service.dart';

class SearchResultsScreen extends StatefulWidget {
  final String from;
  final String to;
  final String date;
  final int persons;

  const SearchResultsScreen({
    super.key,
    required this.from,
    required this.to,
    required this.date,
    required this.persons,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late Future<List<Map<String, dynamic>>> _tripsFuture;

  @override
  void initState() {
    super.initState();
    _tripsFuture = TripService.searchTrips(
      from: widget.from,
      to: widget.to,
      date: widget.date,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Trips'),
        leading: const BackButton(),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _tripsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No trips available'));
          }

          final trips = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              return TripCard(
                trip: trips[index],
                persons: widget.persons,
              );
            },
          );
        },
      ),
    );
  }
}

// ================= CARD =================

class TripCard extends StatelessWidget {
  final Map<String, dynamic> trip;
  final int persons;

  const TripCard({
    super.key,
    required this.trip,
    required this.persons,
  });

  @override
  Widget build(BuildContext context) {
    final int availableSeats = trip['available_seats'] ?? 0;
    final bool canBook = availableSeats >= persons;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== HEADER =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${trip['from_city']} → ${trip['to_city']}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              Text(
                '${trip['price']} JD',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ===== TIME FROM → TO =====
          Row(
            children: [
              const Icon(Icons.access_time, size: 18),
              const SizedBox(width: 6),
              Text(
                '${trip['departure_time']} → ${trip['arrival_time']}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // ===== DURATION + SEATS =====
          Row(
            children: [
              const Icon(Icons.timelapse, size: 18),
              const SizedBox(width: 6),
              Text(
                '${trip['duration_minutes']} min',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 20),
              const Icon(Icons.event_seat, size: 18),
              const SizedBox(width: 6),
              Text(
                '$availableSeats seats',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: availableSeats == 0 ? Colors.red : Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ===== PICKUP =====
          _DropdownField(
            label: 'Pickup',
            value: trip['pickup_location'] ?? '',
          ),

          const SizedBox(height: 10),

          // ===== DROPOFF =====
          _DropdownField(
            label: 'Drop-off',
            value: trip['dropoff_location'] ?? '',
          ),

          const SizedBox(height: 16),

          // ===== BOOK BUTTON =====
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: canBook ? () {} : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F4B63),
                disabledBackgroundColor: Colors.grey.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Book',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= DROPDOWN FIELD =================

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;

  const _DropdownField({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down_rounded),
        ],
      ),
    );
  }
}
