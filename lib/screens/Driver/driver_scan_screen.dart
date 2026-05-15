import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/driver_service.dart';

class DriverScanScreen extends StatefulWidget {
  final int tripId;

  const DriverScanScreen({
    super.key,
    required this.tripId,
  });

  @override
  State<DriverScanScreen> createState() => _DriverScanScreenState();
}

class _DriverScanScreenState extends State<DriverScanScreen> {
  MobileScannerController controller = MobileScannerController();

  bool dialogOpen = false;
  bool isScanning = false;

  Future<void> _handleScan(String qr) async {
    qr = qr.trim();

    print("SCANNED QR = $qr");
    if (isScanning || dialogOpen) return;

    setState(() => isScanning = true);
    await controller.stop();

    try {
      final result = await DriverService.scanTicket(
        qrToken: qr,
        tripId: widget.tripId,
      );

      if (!mounted) return;

      _showResult(
        success: result['valid'] == true,
        message: result['message'],
      );
    } catch (e) {
      print("SCAN ERROR = $e");

      _showResult(
        success: false,
        message: "Invalid ticket",
      );
    }

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => isScanning = false);
    }
  }

  void _showResult({
    required bool success,
    required String message,
  }) {
    dialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor:
                      success ? Colors.green.shade100 : Colors.red.shade100,
                  child: Icon(
                    success ? Icons.check : Icons.close,
                    size: 42,
                    color: success ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  success ? "Scan Successful" : "Scan Failed",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      dialogOpen = false;
                      controller.start();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: success ? Colors.green : Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // CAMERA
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final barcode = capture.barcodes.first;

              if (barcode.rawValue != null) {
                _handleScan(barcode.rawValue!);
              }
            },
          ),

          // OVERLAY
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(),
            ),
          ),

          // TOP BAR
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    "Scan Ticket",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // SCAN BOX
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeInOut,
                  top: isScanning ? 220 : 40,
                  child: Container(
                    width: 220,
                    height: 3,
                    color: Colors.greenAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🔥 CUSTOM OVERLAY
class QrScannerOverlayShape extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path();
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRect(rect)
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: rect.center,
            width: 260,
            height: 260,
          ),
          const Radius.circular(24),
        ),
      )
      ..fillType = PathFillType.evenOdd;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()..color = Colors.black.withOpacity(0.55);

    canvas.drawPath(getOuterPath(rect), paint);
  }

  @override
  ShapeBorder scale(double t) => this;
}
