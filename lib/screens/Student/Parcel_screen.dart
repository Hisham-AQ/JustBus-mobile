import 'package:flutter/material.dart';
import '../../services/parcel_service.dart';
import 'package:justbus/screens/Student/home_screen.dart';
import 'package:flutter/services.dart';
import 'package:justbus/screens/Student/wallet_screen.dart';

class PackageScreen extends StatefulWidget {
  const PackageScreen({super.key});

  @override
  State<PackageScreen> createState() => _PackageScreenState();
}

class _PackageScreenState extends State<PackageScreen> {
  static const Color primary = Color(0xFF1F4B63);
  static const Color lightGrey = Color(0xFFEDEDED);
  final TextEditingController receiverNameCtrl = TextEditingController();
  bool isSubmitting = false;

  final List<String> locations = const [
    'Amman office',
    'Irbid office',
    'Zarqa office',
    'Jerash office',
    'JUST office',
  ];

  String pickup = 'JUST office';
  String dropoff = 'Amman office';

  final List<_ParcelType> parcelTypes = const [
    _ParcelType('Documents', Icons.description_outlined),
    _ParcelType('Small Box', Icons.inventory_2_outlined),
    _ParcelType('Medium Box', Icons.all_inbox_outlined),
    _ParcelType('Large Box', Icons.archive_outlined),
  ];

  Future<void> _applyReward() async {
    final code = rewardCtrl.text.trim();
    if (code.isEmpty) return;

    setState(() {
      isCheckingReward = true;
      rewardMessage = null;
    });

    try {
      final result = await ParcelService.validateReward(
        code: code,
        pickup: pickup,
        dropoff: dropoff,
        weight: weightKg,
        type: selectedType.name,
      );

      setState(() {
        isRewardApplied = result['valid'];
        previewPrice = (result['finalPrice'] as num).toDouble();

        rewardMessage =
            result['valid'] ? "Discount applied 🎉" : "Invalid code";
      });
    } catch (e) {
      setState(() {
        isRewardApplied = false;
        rewardMessage = e.toString();
      });
    } finally {
      setState(() {
        isCheckingReward = false;
      });
    }
  }

  _ParcelType selectedType =
      const _ParcelType('Small Box', Icons.inventory_2_outlined);

  double weightKg = 2.0;

  int deliveryOption = 0;

  final TextEditingController notesCtrl = TextEditingController();
  final TextEditingController rewardCtrl = TextEditingController();
  bool isRewardApplied = false;
  bool isCheckingReward = false;
  String? rewardMessage;
  double? previewPrice;

  @override
  void dispose() {
    notesCtrl.dispose();
    receiverNameCtrl.dispose();
    rewardCtrl.dispose();
    super.dispose();
  }

  void swapLocations() {
    setState(() {
      final t = pickup;
      pickup = dropoff;
      dropoff = t;
    });
  }

  double _estimatePriceJOD() {
    double base = 1.25;

    double dist;
    if (pickup == dropoff) {
      dist = 0.0;
    } else if ((pickup == 'JUST' && dropoff == 'Irbid') ||
        (pickup == 'Irbid' && dropoff == 'JUST')) {
      dist = 0.75;
    } else if ((pickup == 'JUST' && dropoff == 'Amman') ||
        (pickup == 'Amman' && dropoff == 'JUST')) {
      dist = 1.25;
    } else {
      dist = 1.0;
    }

    double weightFee = 0.35 * weightKg;

    double typeFee = switch (selectedType.name) {
      'Documents' => 0.0,
      'Small Box' => 0.35,
      'Medium Box' => 0.75,
      'Large Box' => 1.10,
      _ => 0.40,
    };

    double express = deliveryOption == 1 ? 1.25 : 0.0;

    final total = base + dist + weightFee + typeFee + express;
    return double.parse(total.toStringAsFixed(2));
  }

  void _resetReward() {
    setState(() {
      previewPrice = null;
      isRewardApplied = false;
      rewardMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final price = previewPrice ?? _estimatePriceJOD();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Estimated Total",
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$price JD",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              SizedBox(
                height: 58,
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (receiverNameCtrl.text.isEmpty) {
                            await showDialog(
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
                                        Container(
                                          width: 78,
                                          height: 78,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.orange.withOpacity(.12),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.warning_amber_rounded,
                                            color: Colors.orange,
                                            size: 42,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        const Text(
                                          'Missing Information',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Please enter the receiver name before submitting.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black54,
                                            height: 1.5,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 26),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 54,
                                          child: ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF1F4B63),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                            ),
                                            child: const Text(
                                              'OK',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );

                            return;
                          }

                          if (pickup == dropoff) {
                            await showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  title: const Text(
                                    'Invalid Route',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  content: const Text(
                                    'Pickup and drop-off locations must be different.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                            return;
                          }

                          final price = previewPrice ?? _estimatePriceJOD();

                          bool? confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 82,
                                        height: 82,
                                        decoration: BoxDecoration(
                                          color: primary.withOpacity(.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.local_shipping_rounded,
                                          color: primary,
                                          size: 42,
                                        ),
                                      ),
                                      const SizedBox(height: 22),
                                      const Text(
                                        "Confirm Parcel",
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "Review your parcel details before submitting.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          height: 1.5,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Container(
                                        padding: const EdgeInsets.all(18),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF7F8FA),
                                          borderRadius:
                                              BorderRadius.circular(22),
                                        ),
                                        child: Column(
                                          children: [
                                            _detailRow("From", pickup),
                                            const SizedBox(height: 12),
                                            _detailRow("To", dropoff),
                                            const SizedBox(height: 12),
                                            _detailRow(
                                                "Type", selectedType.name),
                                            const SizedBox(height: 12),
                                            _detailRow(
                                              "Weight",
                                              "${weightKg.toStringAsFixed(1)} KG",
                                            ),
                                            const SizedBox(height: 12),
                                            _detailRow(
                                              "Delivery",
                                              deliveryOption == 0
                                                  ? "Standard"
                                                  : "Express",
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 16),
                                              child: Divider(height: 1),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  "Total",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                                Text(
                                                  "$price JD",
                                                  style: const TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w900,
                                                    color: primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 26),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              style: OutlinedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 16,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                ),
                                              ),
                                              child: const Text(
                                                "Cancel",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: primary,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 16,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                ),
                                              ),
                                              child: const Text(
                                                "Confirm",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w900,
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

                          if (confirm != true) return;

                          setState(() => isSubmitting = true);

                          try {
                            final result = await ParcelService.submitParcel(
                              pickup: pickup,
                              dropoff: dropoff,
                              type: selectedType.name,
                              weight: weightKg,
                              deliveryType:
                                  deliveryOption == 0 ? "standard" : "express",
                              notes: notesCtrl.text,
                              receiverName: receiverNameCtrl.text,
                              rewardCode: rewardCtrl.text.trim().isEmpty
                                  ? null
                                  : rewardCtrl.text.trim(),
                            );

                            final orderNumber = result['orderNumber'];
                            final pinCode = result['pinCode'];

                            _resetReward();

                            await showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(22),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.green.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 50,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          "Parcel Request Submitted",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF5F5F5),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text("Order"),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        orderNumber,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      InkWell(
                                                        onTap: () {
                                                          Clipboard.setData(
                                                            ClipboardData(
                                                              text: orderNumber,
                                                            ),
                                                          );

                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  "Order copied"),
                                                            ),
                                                          );
                                                        },
                                                        child: const Icon(
                                                          Icons.copy,
                                                          size: 18,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text("PIN"),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        pinCode,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      InkWell(
                                                        onTap: () {
                                                          Clipboard.setData(
                                                            ClipboardData(
                                                              text: pinCode,
                                                            ),
                                                          );

                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: const Text(
                                                                  "PIN copied"),
                                                              backgroundColor:
                                                                  Colors.green,
                                                              behavior:
                                                                  SnackBarBehavior
                                                                      .floating,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            14),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: const Icon(
                                                          Icons.copy,
                                                          size: 18,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            14),
                                                  ),
                                                ),
                                                child: const Text("OK"),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          const HomeScreen(),
                                                    ),
                                                    (route) => false,
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: primary,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            14),
                                                  ),
                                                ),
                                                child: const Text("Home"),
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
                          } catch (e) {
                            final error = e.toString();

                            if (error.contains('Insufficient balance')) {
                              await showDialog(
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
                                          Container(
                                            width: 82,
                                            height: 82,
                                            decoration: BoxDecoration(
                                              color: Colors.orange
                                                  .withOpacity(.12),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons
                                                  .account_balance_wallet_rounded,
                                              color: Colors.orange,
                                              size: 42,
                                            ),
                                          ),
                                          const SizedBox(height: 22),
                                          const Text(
                                            'Insufficient Balance',
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'Your wallet balance is not enough to complete this parcel request.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey.shade600,
                                              height: 1.5,
                                            ),
                                          ),
                                          const SizedBox(height: 26),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 14),
                                                  ),
                                                  child: const Text(
                                                    'Back',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);

                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            const WalletScreen(),
                                                      ),
                                                    );
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: primary,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 14),
                                                  ),
                                                  child: const Text(
                                                    'Top Up',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
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
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(error)),
                              );
                            }
                          } finally {
                            setState(() => isSubmitting = false);

                            receiverNameCtrl.clear();
                            notesCtrl.clear();
                            rewardCtrl.clear();

                            _resetReward();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          children: [
                            Icon(Icons.local_shipping_rounded),
                            SizedBox(width: 10),
                            Text(
                              "Submit",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Parcel Delivery',
            style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        physics: const BouncingScrollPhysics(),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1F4B63),
                  Color(0xFF2B6B8A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Fast Parcel Delivery",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Deliver securely between JUST offices across Jordan.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 18),
                      Row(
                        children: [
                          Icon(Icons.flash_on, color: Colors.amber, size: 18),
                          SizedBox(width: 6),
                          Text(
                            "24-48 Hours Average",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Image.asset(
                    'assets/images/JustBus_Main_Logo.png',
                    fit: BoxFit.contain,
                    color: Colors.white.withOpacity(.92),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: lightGrey,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 118,
                          color: Colors.black12,
                        ),
                        Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        children: [
                          _DropdownPill(
                            label: 'Pickup',
                            parentContext: context,
                            value: pickup,
                            items: locations,
                            onChanged: (v) {
                              setState(() => pickup = v ?? pickup);
                              _resetReward();
                            },
                          ),
                          const SizedBox(height: 18),
                          _DropdownPill(
                            label: 'Drop-off',
                            parentContext: context,
                            value: dropoff,
                            items: locations,
                            onChanged: (v) {
                              setState(() => dropoff = v ?? dropoff);
                              _resetReward();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: GestureDetector(
                        onTap: swapLocations,
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.swap_vert_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: lightGrey,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Parcel type',
                    style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: parcelTypes.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.45,
                  ),
                  itemBuilder: (context, i) {
                    final t = parcelTypes[i];
                    final selected = t.name == selectedType.name;

                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedType = t);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color:
                              selected ? Colors.white : const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: selected ? primary : const Color(0xFFDADADA),
                            width: selected ? 2 : 1,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: primary.withOpacity(0.15),
                                    blurRadius: 18,
                                    offset: const Offset(0, 10),
                                  ),
                                ]
                              : [],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFFEAF4FA)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Icon(
                                t.icon,
                                color: selected ? primary : Colors.black54,
                                size: 24,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              t.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: selected ? Colors.black : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              switch (t.name) {
                                'Documents' => 'Light papers & files',
                                'Small Box' => 'Compact delivery',
                                'Medium Box' => 'Standard parcel',
                                'Large Box' => 'Heavy shipment',
                                _ => '',
                              },
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 174,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: lightGrey,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weight',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          "${weightKg.toStringAsFixed(1)} KG",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          weightKg <= 2
                              ? "Light Package"
                              : weightKg <= 5
                                  ? "Medium Weight"
                                  : "Heavy Shipment",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: primary,
                          inactiveTrackColor: Colors.white,
                          thumbColor: primary,
                          overlayColor: primary.withOpacity(0.15),
                        ),
                        child: Slider(
                          value: weightKg,
                          min: 0.5,
                          max: 10,
                          divisions: 19,
                          label: "${weightKg.toStringAsFixed(1)} kg",
                          onChanged: (v) {
                            setState(() {
                              weightKg = v;
                            });

                            _resetReward();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 174,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: lightGrey,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Delivery',
                            style: TextStyle(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 1),
                        _ChoiceChip(
                          selected: deliveryOption == 0,
                          title: 'Standard',
                          subtitle: 'Next day',
                          onTap: () => setState(() => deliveryOption = 0),
                        ),
                        const SizedBox(height: 1),
                        _ChoiceChip(
                          selected: deliveryOption == 1,
                          title: 'Express',
                          subtitle: 'Same Day',
                          onTap: () => setState(() => deliveryOption = 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: lightGrey,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFE8E8E8),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Receiver Name',
                    style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: lightGrey,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: TextField(
                    controller: receiverNameCtrl,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter receiver name',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: lightGrey,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFE8E8E8),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Notes (optional)',
                    style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: lightGrey,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: TextField(
                    controller: notesCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText:
                          'Ex: fragile, call before arriving, leave at gate...',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: lightGrey,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFE8E8E8),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Reward Code',
                    style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: lightGrey,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        child: TextField(
                          controller: rewardCtrl,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter coupon code',
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: isCheckingReward ? null : _applyReward,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isCheckingReward
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text("Apply"),
                    ),
                  ],
                ),
                if (rewardMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    rewardMessage!,
                    style: TextStyle(
                      color: isRewardApplied ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}

class _DropdownPill extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final BuildContext parentContext;

  const _DropdownPill({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        showModalBottomSheet(
          context: parentContext,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          builder: (_) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: items.map((e) {
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      title: Text(
                        e,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      trailing: e == value
                          ? const Icon(
                              Icons.check_circle,
                              color: Color(0xFF1F4B63),
                            )
                          : null,
                      onTap: () {
                        onChanged(e);
                        Navigator.pop(parentContext);
                      },
                    );
                  }).toList(),
                ),
              ),
            );
          },
        );
      },
      child: Container(
        height: 78,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.black45,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ChoiceChip({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  static const Color primary = Color(0xFF1F4B63);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? primary : const Color(0xFFD6D6D6),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: 18,
              color: selected ? primary : Colors.black54,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _detailRow(String label, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.w700,
        ),
      ),
      Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
        ),
      ),
    ],
  );
}

class _ParcelType {
  final String name;
  final IconData icon;
  const _ParcelType(this.name, this.icon);
}
