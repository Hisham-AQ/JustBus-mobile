import 'package:flutter/material.dart';
import 'confirm_booking_screen.dart';

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
  final int persons;

  const SeatSelectionScreen({super.key, required this.persons});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  static const Color primary = Color(0xFF1F4B63);
  static const Color aisle = Color(0xFFD6EBF3);

  final Set<int> selectedSeats = {};

  final List<List<Seat?>> bus = [
    [_s(1), _s(2), null, _s(3), _s(4)],
    [_s(5), _s(6), null, _s(7), _s(8)],
    [_s(9), _s(10), null, _s(11), _s(12)],
    [_s(13), _s(14), null, _s(15), _s(16)],
    [_s(17), _s(18), null, _s(19), _s(20)],
    [_s(21), _s(22), null, _s(23), _s(24)],
    [_s(25), _s(26), null, _s(27), _s(28)],
    [_s(29), _s(30), null, _s(31), _s(32)],
    [_s(33), _s(34), null, _s(35), _s(36)],
    [_s(37), _s(38), null, _s(39), _s(40)],
    [_s(41), _s(42), null, _s(43), _s(44)],
    [_s(45), _s(46), null, _s(47), _s(48)],
  ];

  static Seat _s(int n) {
    if ([6, 14, 18, 25, 33].contains(n)) {
      return Seat(number: n, reserved: true);
    }
    if (n % 3 == 0) return Seat(number: n, gender: Gender.female);
    if (n % 2 == 0) return Seat(number: n, gender: Gender.male);
    return Seat(number: n);
  }

  @override
  Widget build(BuildContext context) {
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
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: const [
                            Icon(Icons.person, size: 28),
                            Text('Driver',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
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
                onPressed: selectedSeats.length == widget.persons
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ConfirmBookingScreen(
                              seats: selectedSeats.toList(),
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text(
                  'Confirm Seat',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
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

    Color bg;
    if (seat.reserved) {
      bg = Colors.grey;
    } else if (selected) {
      bg = Colors.green;
    } else if (seat.gender == Gender.male) {
      bg = Colors.blue.shade300;
    } else if (seat.gender == Gender.female) {
      bg = Colors.pink.shade300;
    } else {
      bg = Colors.white;
    }

    return GestureDetector(
      onTap: seat.reserved
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
              decoration: BoxDecoration(
                  color: c, borderRadius: BorderRadius.circular(4))),
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
