import 'dart:async';
import 'package:flutter/material.dart';
import 'ticket_screen.dart';
import '../services/booking_service.dart';
import '../services/secure_storage.dart';

enum PaymentMethod { applePay, visa, wallet }

class ConfirmBookingScreen extends StatefulWidget {
  final int bookingId;
  final String holdExpiresAt;
  final int tripId;
  final String fromCity;
  final String toCity;
  final String pickup;
  final String dropoff;
  final String tripDate;
  final String departureTime;
  final String arrivalTime;
  final String busNumber;
  final List<int> seats;

  const ConfirmBookingScreen({
    super.key,
    required this.bookingId,
    required this.holdExpiresAt,
    required this.tripId,
    required this.fromCity,
    required this.toCity,
    required this.pickup,
    required this.dropoff,
    required this.tripDate,
    required this.departureTime,
    required this.arrivalTime,
    required this.busNumber,
    required this.seats,
  });

  @override
  State<ConfirmBookingScreen> createState() => _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  static const Color primary = Color(0xFF1F4B63);
  static const Color lightGrey = Color(0xFFEDEDED);

  PaymentMethod payment = PaymentMethod.wallet;
  bool _isSubmitting = false;
  String _userName = 'User';

  // ===== TIMER =====
  Timer? _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _initTimerFromServer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ===== USER NAME =====
  Future<void> _loadUserName() async {
    final name = await SecureStorage.getUserName();
    if (!mounted) return;

    setState(() {
      _userName = name?.isNotEmpty == true ? name! : 'User';
    });
  }

  // ===== INIT TIMER FROM hold_expires_at =====
  void _initTimerFromServer() {
    final expiry = DateTime.parse(widget.holdExpiresAt).toLocal();

    final diff = expiry.difference(DateTime.now());

    _remainingSeconds = diff.inSeconds > 0 ? diff.inSeconds : 0;

    _startTimer();
  }

  // ===== START TIMER =====
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⏰ Hold expired')),
        );

        Navigator.pop(context);
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  String get _timeText {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ===== CONFIRM =====
  Future<void> _confirmBooking() async {
    setState(() => _isSubmitting = true);

    try {
      await BookingService.confirmBooking(
        bookingId: widget.bookingId,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TicketScreen(
            seats: widget.seats,
            userName: _userName,
            bookingId: widget.bookingId,
            qrToken: '',
            from: widget.fromCity,
            to: widget.toCity,
            date: widget.tripDate,
            time: '${widget.departureTime} → ${widget.arrivalTime}',
            busNumber: int.tryParse(widget.busNumber) ?? 0,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Confirm failed')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.seats.length * 2.5;
    final isDanger = _remainingSeconds <= 30;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // ===== TIMER UI =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDanger ? Colors.red.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDanger ? Colors.red : Colors.orange,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer_rounded,
                      color: isDanger ? Colors.red : Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Seat locked for $_timeText',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: isDanger ? Colors.red : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            _card(
              title: 'Trip Details',
              child: Column(
                children: [
                  _row(Icons.place_rounded, 'From',
                      '${widget.fromCity} (${widget.pickup})'),
                  _row(Icons.flag_rounded, 'To',
                      '${widget.toCity} (${widget.dropoff})'),
                  const Divider(),
                  _row(Icons.calendar_month_rounded, 'Date', widget.tripDate),
                  _row(Icons.access_time_rounded, 'Time',
                      '${widget.departureTime} → ${widget.arrivalTime}'),
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
                    value: PaymentMethod.applePay,
                  ),
                ],
              ),
            ),

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
                        const Text('Total Price',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(
                          '$totalPrice JD',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (_isSubmitting || _remainingSeconds <= 0)
                          ? null
                          : _confirmBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Confirm',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w900),
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

  // ================= HELPERS =================

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
                  Text(subtitle,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54)),
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
