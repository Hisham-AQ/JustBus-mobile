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

    final formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);

    _tripsFuture = TripService.searchTrips(
      from: widget.from.trim(),
      to: widget.to.trim(),
      date: formattedDate,
    );
  }

  Future<void> _refreshTrips() async {
    final parsedDate = DateTime.parse(widget.date);

    final formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);

    setState(() {
      _tripsFuture = TripService.searchTrips(
        from: widget.from.trim(),
        to: widget.to.trim(),
        date: formattedDate,
      );
    });

    await _tripsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        titleSpacing: 0,
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

          return RefreshIndicator(
            onRefresh: _refreshTrips,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trips.length,
              itemBuilder: (context, index) {
                return TripCard(
                  trip: trips[index],
                  persons: widget.persons,
                  tripDate: widget.date,
                );
              },
            ),
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
  late List<Map<String, dynamic>> pickupOptions;
  late List<Map<String, dynamic>> dropoffOptions;

  Map<String, dynamic>? selectedPickup;
  Map<String, dynamic>? selectedDropoff;

  @override
  void initState() {
    super.initState();

    pickupOptions = List<Map<String, dynamic>>.from(
      widget.trip['pickup_location'] ?? [],
    );
    dropoffOptions =
        List<Map<String, dynamic>>.from(widget.trip['dropoff_location'] ?? []);

    selectedPickup = pickupOptions.isNotEmpty ? pickupOptions.first : null;
    selectedDropoff = dropoffOptions.isNotEmpty ? dropoffOptions.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final int availableSeats = widget.trip['available_seats'] ?? 0;

    final String tripStatus = widget.trip['status'] ?? '';

    final bool isScheduled = tripStatus == 'scheduled';

    final bool canBook = isScheduled &&
        availableSeats >= widget.persons &&
        selectedPickup != null &&
        selectedDropoff != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${widget.trip['from_city']} → ${widget.trip['to_city']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.trip['departure_time']} → ${widget.trip['arrival_time']}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade50,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_rounded,
                                size: 18,
                                color: Colors.blueGrey.shade700,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.trip['driver_name'] ?? 'Unknown Driver',
                                style: TextStyle(
                                  color: Colors.blueGrey.shade900,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.directions_bus_rounded,
                                size: 18,
                                color: Colors.orange.shade700,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Bus ${widget.trip['bus_number']}',
                                style: TextStyle(
                                  color: Colors.orange.shade900,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isScheduled
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tripStatus.toUpperCase(),
                      style: TextStyle(
                        color: isScheduled
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// PRICE
                  Row(
                    children: [
                      Icon(
                        Icons.payments_rounded,
                        size: 18,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.trip['price']} JD',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 18,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.trip['duration_minutes']} min',
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: availableSeats <= 5
                      ? Colors.red.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.airline_seat_recline_normal_rounded,
                      size: 18,
                      color: availableSeats <= 5
                          ? Colors.red.shade700
                          : Colors.green.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$availableSeats seats',
                      style: TextStyle(
                        color: availableSeats <= 5
                            ? Colors.red.shade900
                            : Colors.green.shade900,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(
            color: Colors.grey.shade200,
            thickness: 1,
          ),
          const SizedBox(height: 18),
          _DropdownField(
            label: 'Pickup',
            items: pickupOptions,
            value: selectedPickup,
            enabled: isScheduled,
            onChanged: (v) => setState(() => selectedPickup = v),
          ),
          const SizedBox(height: 10),
          _DropdownField(
            label: 'Drop-off',
            items: dropoffOptions,
            value: selectedDropoff,
            enabled: isScheduled,
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
                            pricePerSeat: double.parse(
                              widget.trip['price'].toString(),
                            ),
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
                            tripStatus: tripStatus,
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isScheduled ? const Color(0xFF1F4B63) : Colors.red,
                disabledBackgroundColor: isScheduled ? Colors.grey : Colors.red,
              ),
              child: Text(
                isScheduled ? 'Book' : 'Unavailable',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final List<Map<String, dynamic>> items;
  final Map<String, dynamic>? value;
  final ValueChanged<Map<String, dynamic>?>? onChanged;
  final bool enabled;

  const _DropdownField({
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Map<String, dynamic>>(
      initialValue: value,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e['name'])))
          .toList(),
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade200,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
