import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'home_screen.dart';
import '../../services/secure_storage.dart';

class TicketScreen extends StatelessWidget {
  final List<int> seats;
  final String userName;
  final String qrToken;
  final int bookingId;

  final String from;
  final String to;
  final String pickupLocation;
  final String dropoffLocation;
  final String date;
  final String time;
  final int? busNumber;
  final int tripId;
  final String? avatar;

  TicketScreen({
    super.key,
    required this.seats,
    required this.userName,
    required this.qrToken,
    required this.bookingId,
    required this.from,
    required this.to,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.date,
    required this.time,
    required this.busNumber,
    required this.tripId,
    required this.avatar,
  });

  final GlobalKey _ticketKey = GlobalKey();

  static const Color bg = Color(0xFF4E6F87);
  static const Color primary = Color(0xFF1F4B63);
  static const Color ticketBg = Color(0xFFF8F7F4);


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: bg,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'Your Ticket',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              RepaintBoundary(
                key: _ticketKey,
                child: _ticket(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _saveTicketAsImage(context),
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
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.location_on),
                  label: const Text("Track Bus"),
                  onPressed: () async {
                    await SecureStorage.saveTrackingTrip(
                      tripId,
                    );
                    print(
                      "PICKUP LOCATION: "
                      "$pickupLocation",
                    );

                    await SecureStorage.savePickupLocation(
                      pickupLocation,
                    );
                    await SecureStorage.saveDropoffLocation(
                      dropoffLocation,
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomeScreen(
                          trackingTripId: tripId,
                          pickupLocation: pickupLocation,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F4B63),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // SAVE IMAGE

  Future<void> _saveTicketAsImage(BuildContext context) async {
    try {
      final boundary = _ticketKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;

      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      final pngBytes = byteData!.buffer.asUint8List();

      final directory = Directory('/storage/emulated/0/Pictures/JustBus');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final filePath = '${directory.path}/ticket_$bookingId.png';
      final file = File(filePath);

      await file.writeAsBytes(pngBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket saved to Gallery')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save ticket')),
      );
    }
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
                      backgroundColor: Colors.transparent,
                      child: avatar != null && avatar!.isNotEmpty
                          ? Image.asset(
                              avatar!,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                            )
                          : Text(
                              userName.isNotEmpty
                                  ? userName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: Color(0xFF1F4B63),
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        userName,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _bigInfo('SEAT', seats.join(', ')),
                    _bigInfo(
                      'BUS',
                      busNumber == null || busNumber == 0
                          ? '-'
                          : busNumber.toString(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Container(
                  width: 220,
                  height: 220,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: QrImageView(
                    data: bookingId.toString(),
                    version: QrVersions.auto,
                    size: 180,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Colors.black,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Colors.black,
                    ),
                  )),
              const SizedBox(height: 26),
            ],
          ),
        ),
        Positioned(left: -12, top: 90, child: _cut()),
        Positioned(right: -12, top: 90, child: _cut()),
        Positioned(left: -12, bottom: 290, child: _cut()),
        Positioned(right: -12, bottom: 290, child: _cut()),
      ],
    );
  }

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

  Widget _routeBlock(String label, String value, {required bool alignStart}) {
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
