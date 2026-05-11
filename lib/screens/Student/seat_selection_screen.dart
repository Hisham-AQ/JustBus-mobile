import 'package:flutter/material.dart';
import 'confirm_booking_screen.dart';
import '../../services/trip_service.dart';
import '../../services/booking_service.dart';

enum Gender { male, female, none }

class Seat {
  final int number;
  final bool reserved;
  final Gender gender;

  Seat({
    required this.number,
    this.reserved = false,
    this.gender = Gender.none,
  });
}

class SeatSelectionScreen extends StatefulWidget {
  final int tripId;
  final int persons;
  final String pickup;
  final String dropoff;
  final String fromCity;
  final String toCity;
  final String tripDate;
  final String departureTime;
  final String arrivalTime;
  final String busNumber;
  final double pricePerSeat;
  final String tripStatus;

  const SeatSelectionScreen({
    super.key,
    required this.tripId,
    required this.persons,
    required this.pricePerSeat,
    required this.tripStatus,
    required this.pickup,
    required this.dropoff,
    required this.fromCity,
    required this.toCity,
    required this.tripDate,
    required this.departureTime,
    required this.arrivalTime,
    required this.busNumber,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  static const Color primary = Color(0xFF1F4B63);
  static const Color aisle = Color(0xFFD6EBF3);

  final Set<int> selectedSeats = {};
  final Map<int, Gender> reservedSeats = {};

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadReservedSeats();
  }

  // LOAD RESERVED
  Future<void> _loadReservedSeats() async {
    try {
      final data = await TripService.getReservedSeats(widget.tripId);

      reservedSeats.clear();

      for (final seat in data) {
        final int? seatNumber = seat['seat_number'];
        if (seatNumber == null) continue;

        final gender = seat['gender']?.toString().toLowerCase() ?? 'none';

        reservedSeats[seatNumber] = gender == 'male'
            ? Gender.male
            : gender == 'female'
                ? Gender.female
                : Gender.none;
      }

      if (mounted) setState(() {});
    } catch (_) {}
  }

  Seat _seatFromNumber(int n) {
    if (reservedSeats.containsKey(n)) {
      return Seat(
        number: n,
        reserved: true,
        gender: reservedSeats[n]!,
      );
    }
    return Seat(number: n);
  }

  List<List<Seat?>> get bus => List.generate(11, (row) {
        final start = row * 4 + 1;
        return [
          _seatFromNumber(start),
          _seatFromNumber(start + 1),
          null,
          _seatFromNumber(start + 2),
          _seatFromNumber(start + 3),
        ];
      });

  // CONFIRM SEAT (HOLD)
  Future<void> _onConfirmSeat() async {
    setState(() => _loading = true);

    try {
      final result = await BookingService.holdSeats(
        tripId: widget.tripId,
        pickup: widget.pickup,
        dropoff: widget.dropoff,
        seats: selectedSeats.toList(),
      );

      final bookingId = result['bookingId'];
      final holdExpiresAt = result['holdExpiresAt'];

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConfirmBookingScreen(
              bookingId: bookingId,
              holdExpiresAt: holdExpiresAt,
              tripId: widget.tripId,
              fromCity: widget.fromCity,
              toCity: widget.toCity,
              pickup: widget.pickup,
              dropoff: widget.dropoff,
              tripDate: widget.tripDate,
              departureTime: widget.departureTime,
              arrivalTime: widget.arrivalTime,
              busNumber: widget.busNumber,
              seats: selectedSeats.toList(),
              pricePerSeat: widget.pricePerSeat),
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seats are no longer available')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canSelectSeats = widget.tripStatus == 'scheduled';
    return Scaffold(
      backgroundColor: const Color(0xFFF2FAFD),
      appBar: AppBar(
        title: const Text('Select Seat',
            style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _legend(),
          const SizedBox(height: 12),
          if (!canSelectSeats)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.red.shade700,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This trip is no longer available.',
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 90),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4F7),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: primary),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.person, size: 28),
                      const Text('Driver',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      const Divider(),
                      ...bus.map(_row),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
            child: SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _loading ||
                        selectedSeats.length != widget.persons ||
                        !canSelectSeats
                    ? null
                    : _onConfirmSeat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        canSelectSeats ? 'Confirm Seat' : 'Trip Unavailable',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(List<Seat?> row) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: row.map((seat) {
          if (seat == null) {
            return Container(
              width: 26,
              height: 26,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: aisle,
                borderRadius: BorderRadius.circular(6),
              ),
            );
          }
          return _seat(seat);
        }).toList(),
      ),
    );
  }

  Widget _seat(Seat seat) {
    final selected = selectedSeats.contains(seat.number);

    final bool disabled = widget.tripStatus != 'scheduled';

    final bool canSelectSeats = widget.tripStatus == 'scheduled';

    Color bg;
    if (seat.reserved) {
      bg = seat.gender == Gender.male
          ? Colors.blue.shade300
          : seat.gender == Gender.female
              ? Colors.pink.shade300
              : Colors.grey;
    } else if (selected) {
      bg = Colors.green;
    } else if (disabled) {
      bg = Colors.grey.shade300;
    } else {
      bg = Colors.white;
    }

    return GestureDetector(
      onTap: seat.reserved || !canSelectSeats
          ? null
          : () {
              setState(() {
                if (selected) {
                  selectedSeats.remove(seat.number);
                } else if (selectedSeats.length < widget.persons) {
                  selectedSeats.add(seat.number);
                }
              });
            },
      child: Container(
        width: 42,
        height: 42,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black54),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              seat.gender == Gender.male
                  ? Icons.male
                  : seat.gender == Gender.female
                      ? Icons.female
                      : Icons.event_seat,
              size: 16,
            ),
            Text(
              seat.number.toString(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legend() {
    Widget item(Color c, IconData i, String t) {
      return Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration:
                BoxDecoration(color: c, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 4),
          Icon(i, size: 14),
          const SizedBox(width: 4),
          Text(t,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          item(Colors.blue.shade300, Icons.male, 'Male'),
          item(Colors.pink.shade300, Icons.female, 'Female'),
          item(Colors.green, Icons.check, 'Selected'),
          item(Colors.grey, Icons.close, 'Reserved'),
        ],
      ),
    );
  }
}
