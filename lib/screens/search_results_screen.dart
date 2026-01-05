import 'package:flutter/material.dart';
import 'seat_selection_screen.dart';

final Map<String, List<String>> cityStops = {
  'Amman': [
    'Abdali Station',
    'University Street',
    '7th Circle',
  ],
  'Irbid': [
    'Irbid Downtown',
    'Irbid Bus Station',
  ],
  'Zarqa': [
    'Zarqa New Station',
    'Zarqa Old Station',
  ],
  'Jerash': [
    'Jerash Center',
  ],
  'JUST': [
    'JUST Main Gate',
    'JUST Gate 1',
    'JUST Gate 3',
  ],
};

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
  static const Color primary = Color(0xFF1F4B63);
  static const Color lightGrey = Color(0xFFEDEDED);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Available Trips',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
        children: [
          _tripCard(
            fromTime: 'Now',
            toTime: '09:15 AM',
            duration: '1h 15m',
            price: '2.50 JD',
            seats: 12,
          ),
          _tripCard(
            fromTime: '08:00 AM',
            toTime: '09:20 AM',
            duration: '1h 20m',
            price: '3.00 JD',
            seats: 6,
          ),
          _tripCard(
            fromTime: '10:30 AM',
            toTime: '11:45 AM',
            duration: '1h 15m',
            price: '2.00 JD',
            seats: 0,
            full: true,
          ),
        ],
      ),
    );
  }

  Widget _tripCard({
    required String fromTime,
    required String toTime,
    required String duration,
    required String price,
    required int seats,
    bool full = false,
  }) {
    final pickupOptions = cityStops[widget.from] ?? [];
    final dropoffOptions = cityStops[widget.to] ?? [];

    String pickup = pickupOptions.isNotEmpty ? pickupOptions.first : '';
    String dropoff = dropoffOptions.isNotEmpty ? dropoffOptions.first : '';

    return StatefulBuilder(
      builder: (context, setLocalState) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: lightGrey,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.from} → ${widget.to}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _info(Icons.access_time_rounded, '$fromTime → $toTime'),
                  const Spacer(),
                  Text(
                    price,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _info(Icons.timelapse_rounded, duration),
                  const SizedBox(width: 16),
                  _info(Icons.event_seat_rounded, '$seats seats'),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _locationDropdown(
                      label: 'Pickup',
                      value: pickup,
                      items: pickupOptions,
                      onChanged: (v) => setLocalState(() => pickup = v),
                    ),
                    const SizedBox(height: 8),
                    _locationDropdown(
                      label: 'Drop-off',
                      value: dropoff,
                      items: dropoffOptions,
                      onChanged: (v) => setLocalState(() => dropoff = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: full
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SeatSelectionScreen(
                                persons: widget.persons,
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    full ? 'Full' : 'Book',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _info(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _locationDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                items: items
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
