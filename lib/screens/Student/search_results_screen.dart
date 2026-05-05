import 'package:flutter/material.dart';
import '../../services/trip_service.dart';
import 'seat_selection_screen.dart';
import 'package:intl/intl.dart';

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

  final parsedDate = DateTime.parse(widget.date);

  final formattedDate =
      DateFormat('yyyy-MM-dd').format(parsedDate);

  _tripsFuture = TripService.searchTrips(
    from: widget.from.trim(),
    to: widget.to.trim(),
    date: formattedDate,
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
                tripDate: widget.date,
              );
            },
          );
        },
      ),
    );
  }
}

class TripCard extends StatefulWidget {
  final Map<String, dynamic> trip;
  final int persons;
  final String tripDate;

  const TripCard({
    super.key,
    required this.trip,
    required this.persons,
    required this.tripDate,
  });

  @override
  State<TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> {
  late List<String> pickupOptions;
  late List<String> dropoffOptions;

  String? selectedPickup;
  String? selectedDropoff;

@override
void initState() {
  super.initState();

  pickupOptions =
      List<String>.from(widget.trip['pickup_location'] ?? []);
  dropoffOptions =
      List<String>.from(widget.trip['dropoff_location'] ?? []);

  selectedPickup = pickupOptions.isNotEmpty ? pickupOptions.first : null;
  selectedDropoff = dropoffOptions.isNotEmpty ? dropoffOptions.first : null;
}

  @override
  Widget build(BuildContext context) {
    final int availableSeats = widget.trip['available_seats'] ?? 0;
    final bool canBook = availableSeats >= widget.persons &&
        selectedPickup != null &&
        selectedDropoff != null;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.trip['from_city']} → ${widget.trip['to_city']}',
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              Text(
                '${widget.trip['price']} JD',
                style:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.access_time, size: 18),
              const SizedBox(width: 6),
              Text(
                '${widget.trip['departure_time']} → ${widget.trip['arrival_time']}',
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.timelapse, size: 18),
              const SizedBox(width: 6),
              Text('${widget.trip['duration_minutes']} min'),
              const SizedBox(width: 20),
              const Icon(Icons.event_seat, size: 18),
              const SizedBox(width: 6),
              Text('$availableSeats seats'),
            ],
          ),
          const SizedBox(height: 14),
          _DropdownField(
            label: 'Pickup',
            items: pickupOptions,
            value: selectedPickup,
            onChanged: (v) => setState(() => selectedPickup = v),
          ),
          const SizedBox(height: 10),
          _DropdownField(
            label: 'Drop-off',
            items: dropoffOptions,
            value: selectedDropoff,
            onChanged: (v) => setState(() => selectedDropoff = v),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: canBook
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SeatSelectionScreen(
                            tripId: widget.trip['id'] ?? 0,
                            pricePerSeat: double.parse(widget.trip['price'].toString()),
                            persons: widget.persons,
                            pickup: selectedPickup!,
                            dropoff: selectedDropoff!,
                            fromCity: widget.trip['from_city'] ?? '',
                            toCity: widget.trip['to_city'] ?? '',
                            tripDate: widget.tripDate,
                            departureTime: widget.trip['departure_time'] ?? '',
                            arrivalTime: widget.trip['arrival_time'] ?? '',
                            busNumber:
                                widget.trip['bus_number']?.toString() ?? '',
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F4B63),
                disabledBackgroundColor: Colors.grey,
              ),
              child: const Text(
                'Book',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
