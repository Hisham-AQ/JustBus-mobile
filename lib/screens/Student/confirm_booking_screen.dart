import 'dart:async';
import 'package:flutter/material.dart';
import 'ticket_screen.dart';
import '../../services/booking_service.dart';
import '../../services/secure_storage.dart';
import '../../services/card_service.dart';
import '../../services/wallet_service.dart';

enum PaymentMethod { applePay, visa, wallet }

TextEditingController _rewardController = TextEditingController();
bool isRewardApplied = false;
bool isCheckingReward = false;
String? rewardMessage;
double? previewPrice;

class ConfirmBookingScreen extends StatefulWidget {
  final int bookingId;
  final String holdExpiresAt;
  final int tripId;
  final String fromCity;
  final String toCity;
  final Map<String, dynamic> pickup;
  final Map<String, dynamic> dropoff;
  final String tripDate;
  final String departureTime;
  final String arrivalTime;
  final String busNumber;
  final List<int> seats;
  final double pricePerSeat;

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
    required this.pricePerSeat,
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
  double walletBalance = 0;
  String cardLast4 = '----';
  String cardBrand = 'Visa';

  // ===== TIMER =====
  Timer? _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _initTimerFromServer();
    _loadWallet();
    _loadCards();
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

  Future<void> _loadWallet() async {
    try {
      final balance = await WalletService.getBalance();

      if (!mounted) return;

      setState(() {
        walletBalance = balance;
      });
    } catch (e) {
      debugPrint(
        "Wallet error: $e",
      );
    }
  }

  Future<void> _loadCards() async {
    try {
      final cards = await CardService.getCards();

      if (cards.isEmpty) return;

      final firstCard = cards[0];

      if (!mounted) return;

      setState(() {
        cardLast4 = firstCard['last4'] ?? '----';

        cardBrand = firstCard['brand'] ?? 'Visa';
      });
    } catch (e) {
      debugPrint(
        "Cards error: $e",
      );
    }
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

    final code = _rewardController.text.trim();
    try {
      await BookingService.confirmBooking(
        bookingId: widget.bookingId,
        rewardCode: isRewardApplied ? code : null,
      );

      if (!mounted) return;

      _rewardController.clear();

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
            pickupLocation: widget.pickup['name'],
            dropoffLocation: widget.dropoff['name'],
            date: widget.tripDate,
            time: '${widget.departureTime} → ${widget.arrivalTime}',
            busNumber: int.tryParse(widget.busNumber) ?? 0,
            tripId: widget.tripId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      String msg = e.toString();

      msg = msg.replaceAll("Exception: ", "");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final originalPrice = widget.seats.length * widget.pricePerSeat;
    final totalPrice = previewPrice ?? originalPrice;
    final isDanger = _remainingSeconds <= 30;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text(
          'Confirm Booking',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: const Color(0xFFF6F8FB),
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
                      '${widget.fromCity} (${widget.pickup['name']})'),
                  _row(Icons.flag_rounded, 'To',
                      '${widget.toCity} (${widget.dropoff['name']})'),
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
              title: 'Reward Code',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _rewardController,
                          decoration: InputDecoration(
                            hintText: "Enter code",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: isCheckingReward ? null : _applyReward,
                        child: isCheckingReward
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text("Apply"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (rewardMessage != null &&
                      _rewardController.text.isNotEmpty)
                    Text(
                      rewardMessage!,
                      style: TextStyle(
                        color: isRewardApplied ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
                    subtitle: 'Balance: ${walletBalance.toStringAsFixed(2)} JD',
                    value: PaymentMethod.wallet,
                  ),
                  _paymentTile(
                    icon: Icons.credit_card_rounded,
                    title: cardBrand,
                    subtitle: '•••• •••• •••• $cardLast4',
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

            const SizedBox(height: 14),

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
                      if (previewPrice != null)
                        Text(
                          '$originalPrice JD',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: totalPrice.toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                            const TextSpan(
                              text: ' JD',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (_isSubmitting || _remainingSeconds <= 0)
                          ? null
                          : _showConfirmDialog,
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

  Future<void> _showConfirmDialog() async {
    final totalPrice =
        previewPrice ?? (widget.seats.length * widget.pricePerSeat);

    final paymentName = payment == PaymentMethod.wallet
        ? "Wallet"
        : payment == PaymentMethod.visa
            ? "$cardBrand •••• $cardLast4"
            : "Apple Pay / Google Pay";

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.directions_bus_rounded,
                  size: 58,
                  color: primary,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Confirm Booking",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 20),
                _simpleRow(
                  "Route",
                  "${widget.fromCity} → ${widget.toCity}",
                ),
                _simpleRow(
                  "Seats",
                  widget.seats.join(", "),
                ),
                _simpleRow(
                  "Date",
                  widget.tripDate,
                ),
                _simpleRow(
                  "Time",
                  "${widget.departureTime} → ${widget.arrivalTime}",
                ),
                _simpleRow(
                  "Payment",
                  paymentName,
                ),
                const Divider(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      "${totalPrice.toStringAsFixed(2)} JD",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            false,
                          );
                        },
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                        ),
                        onPressed: () {
                          Navigator.pop(
                            context,
                            true,
                          );
                        },
                        child: const Text(
                          "Confirm",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      await _confirmBooking();
    }
  }

  // ================= HELPERS =================

  Widget _card({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
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
      child: AnimatedContainer(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? primary : Colors.transparent,
            width: 1.4,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: primary.withOpacity(0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
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

  Future<void> _applyReward() async {
    final code = _rewardController.text.trim();

    if (code.isEmpty) return;

    setState(() {
      isCheckingReward = true;
      rewardMessage = null;
    });

    try {
      final result = await BookingService.validateReward(
        code: code,
        tripId: widget.tripId,
      );

      if (result['type'] != 'free_trip') {
        setState(() {
          isRewardApplied = false;
          rewardMessage = "Only free trip allowed";
          previewPrice = null;
        });
        return;
      }

      setState(() {
        isRewardApplied = result['valid'] == true;
        previewPrice = (result['finalPrice'] as num).toDouble();

        rewardMessage = result['valid']
            ? "Reward applied 🎉"
            : result['message'] ?? "Invalid code";
      });
    } catch (e) {
      setState(() {
        isRewardApplied = false;
        previewPrice = null;
        rewardMessage = e.toString();
      });
    } finally {
      setState(() {
        isCheckingReward = false;
      });
    }
  }
}
