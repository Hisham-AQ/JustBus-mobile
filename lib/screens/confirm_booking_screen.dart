import 'package:flutter/material.dart';
import 'ticket_screen.dart';

enum PaymentMethod { ApplePay, visa, wallet }

class ConfirmBookingScreen extends StatefulWidget {
  final int tripId;
  final String pickup;
  final String dropoff;
  final List<int> seats;

  const ConfirmBookingScreen({
    super.key,
    required this.tripId,
    required this.pickup,
    required this.dropoff,
    required this.seats,
  });

  @override
  State<ConfirmBookingScreen> createState() => _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  static const Color primary = Color(0xFF1F4B63);
  static const Color lightGrey = Color(0xFFEDEDED);

  PaymentMethod payment = PaymentMethod.wallet;

  Future<String> _getUserName() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return 'Student Name';
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.seats.length * 2.5;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Confirm Booking',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _card(
              title: 'Trip Details',
              child: Column(
                children: [
                  _row(Icons.place_rounded, 'From', widget.pickup),
                  _row(Icons.flag_rounded, 'To', widget.dropoff),
                  const Divider(),
                  _row(Icons.calendar_month_rounded, 'Date', '1/1/2026'),
                  _row(
                    Icons.access_time_rounded,
                    'Time',
                    '08:00 AM → 09:15 AM',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _card(
              title: 'Passengers',
              child: Column(
                children: [
                  _simpleRow('Seats', widget.seats.join(', ')),
                  _simpleRow('Passengers', widget.seats.length.toString()),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _card(
              title: 'Payment Method',
              child: Column(
                children: [
                  _paymentTile(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'Wallet',
                    subtitle: 'Balance: 12.50 JD',
                    value: PaymentMethod.wallet,
                  ),
                  _paymentTile(
                    icon: Icons.credit_card_rounded,
                    title: 'Visa / MasterCard',
                    subtitle: '**** **** **** 2413',
                    value: PaymentMethod.visa,
                  ),
                  _paymentTile(
                    icon: Icons.payments_rounded,
                    title: 'Apple Pay / Google Pay',
                    subtitle: 'Double Click',
                    value: PaymentMethod.ApplePay,
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lightGrey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Price',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$totalPrice JD',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = await _getUserName();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TicketScreen(
                              seats: widget.seats,
                              userName: name,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Confirm',
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
          ],
        ),
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _card({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          SizedBox(
            width: 70,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _simpleRow(String l, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(l, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: Text(v, style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _paymentTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required PaymentMethod value,
  }) {
    final selected = payment == value;

    return InkWell(
      onTap: () => setState(() => payment = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? primary : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: primary),
          ],
        ),
      ),
    );
  }
}
