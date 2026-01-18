import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketScreen extends StatelessWidget {
  final List<int> seats;
  final String userName;
  final String qrToken;
  final int bookingId;

  final String from;
  final String to;
  final String date;
  final String time;
  final int? busNumber;

  const TicketScreen({
    super.key,
    required this.seats,
    required this.userName,
    required this.qrToken,
    required this.bookingId,
    required this.from,
    required this.to,
    required this.date,
    required this.time,
    required this.busNumber,
  });

  static const Color bg = Color(0xFF4E6F87);
  static const Color primary = Color(0xFF1F4B63);
  static const Color ticketBg = Color(0xFFF8F7F4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'Your Ticket',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _ticket(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Download Ticket',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= TICKET =================

  Widget _ticket() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: ticketBg,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              const SizedBox(height: 22),

              // ===== USER =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: primary,
                      child: Text(
                        userName.isNotEmpty
                            ? userName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        userName,
                        maxLines: 2,
                        overflow: TextOverflow.visible,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _perforation(),
              const SizedBox(height: 20),

              // ===== FROM / TO =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _routeBlock('FROM', from, alignStart: true),
                    const SizedBox(width: 12),
                    _routeLine(),
                    const SizedBox(width: 12),
                    _routeBlock('TO', to, alignStart: false),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ===== DATE & TIME =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(child: _infoCard(Icons.calendar_month, date)),
                    const SizedBox(width: 12),
                    Expanded(child: _infoCard(Icons.access_time, time)),
                  ],
                ),
              ),

              const SizedBox(height: 22),
              _perforation(),
              const SizedBox(height: 18),

              // ===== SEAT & BUS =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _bigInfo('SEAT', seats.join(', ')),
                    _bigInfo(
                      'BUS',
                      (busNumber == null || busNumber == 0)
                          ? '-'
                          : busNumber.toString(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ===== QR =====
              Container(
                width: 190,
                height: 190,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: QrImageView(
                  data: qrToken,
                  version: QrVersions.auto,
                ),
              ),

              const SizedBox(height: 26),
            ],
          ),
        ),

        // ===== CUTS =====
        Positioned(left: -12, top: 90, child: _cut()),
        Positioned(right: -12, top: 90, child: _cut()),
        Positioned(left: -12, bottom: 290, child: _cut()),
        Positioned(right: -12, bottom: 290, child: _cut()),
      ],
    );
  }

  // ================= HELPERS =================

  Widget _cut() {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _perforation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(
          32,
          (i) => Expanded(
            child: Container(
              height: 1,
              color: i.isEven ? Colors.black26 : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _routeBlock(String label, String value,
      {required bool alignStart}) {
    return Expanded(
      child: Column(
        crossAxisAlignment:
            alignStart ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.visible,
            textAlign: alignStart ? TextAlign.start : TextAlign.end,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _routeLine() {
    return Container(
      width: 40,
      height: 2,
      color: primary,
    );
  }

  Widget _infoCard(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bigInfo(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
