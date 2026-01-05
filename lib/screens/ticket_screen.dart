import 'package:flutter/material.dart';

class TicketScreen extends StatelessWidget {
  final List<int> seats;
  final String userName;

  const TicketScreen({
    super.key,
    required this.seats,
    required this.userName,
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
        leading: const BackButton(),
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: primary,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _perforation(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  children: [
                    _routePoint('FROM', 'Home', filled: true),
                    Expanded(child: _routeLine()),
                    _routePoint('TO', 'JUST'),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoCard(Icons.calendar_month, '1/1/2026'),
                    _infoCard(Icons.access_time, '11:30 AM'),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _perforation(),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _bigInfo('SEAT', seats.join(', ')),
                    _bigInfo('BUS', '2'),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Container(
                width: 190,
                height: 190,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Image.asset(
                  'assets/images/QR_TEST.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 26),
            ],
          ),
        ),
        Positioned(
          left: -12,
          top: 82,
          child: _cut(),
        ),
        Positioned(
          right: -12,
          top: 82,
          child: _cut(),
        ),
        Positioned(
          right: -12,
          bottom: 298,
          child: _cut(),
        ),
        Positioned(
          left: -12,
          bottom: 298,
          child: _cut(),
        ),
      ],
    );
  }

  Widget _cut() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
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

  Widget _routePoint(String label, String value, {bool filled = false}) {
    return Column(
      crossAxisAlignment:
          filled ? CrossAxisAlignment.start : CrossAxisAlignment.end,
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
        Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? primary : Colors.transparent,
                border: Border.all(color: primary, width: 2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _routeLine() {
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: primary,
    );
  }

  Widget _infoCard(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w800),
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
