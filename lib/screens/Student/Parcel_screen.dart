import 'package:flutter/material.dart';
import '../../services/parcel_service.dart';
import 'package:justbus/screens/Student/home_screen.dart';
import 'package:flutter/services.dart';

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
        previewPrice = result['finalPrice'];

        rewardMessage =
            result['valid'] ? "Discount applied 🎉" : "Invalid code";
      });
    } catch (e) {
      setState(() {
        rewardMessage = "Error validating code";
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Parcel Delivery',
            style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        children: [
          const Text(
            'Send a parcel',
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.w900, height: 1.05),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose pickup/drop-off points and package details.',
            style:
                TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: lightGrey,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _DropdownPill(
                        label: 'Pickup',
                        value: pickup,
                        items: locations,
                        onChanged: (v) {
                          setState(() => pickup = v ?? pickup);
                          _resetReward();
                        },
                      ),
                      const SizedBox(height: 12),
                      _DropdownPill(
                        label: 'Drop-off',
                        value: dropoff,
                        items: locations,
                        onChanged: (v) =>
                            setState(() => dropoff = v ?? dropoff),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: swapLocations,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(29),
                    ),
                    child: const Icon(Icons.swap_vert_rounded,
                        color: Colors.white, size: 30),
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
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Parcel type',
                    style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 56,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: parcelTypes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      final t = parcelTypes[i];
                      final selected = t.name == selectedType.name;

                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => setState(() => selectedType = t),
                        child: Ink(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.white
                                : const Color(0xFFF7F7F7),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color:
                                  selected ? primary : const Color(0xFFD6D6D6),
                              width: selected ? 1.6 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(t.icon,
                                  color: selected ? primary : Colors.black54),
                              const SizedBox(width: 8),
                              Text(
                                t.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color:
                                      selected ? Colors.black : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 175,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: lightGrey,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Estimated weight',
                            style: TextStyle(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '${weightKg.toStringAsFixed(1)} kg',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w900),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text('0.5–10 kg',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ),
                        Slider(
                          value: weightKg,
                          min: 0.5,
                          max: 10,
                          divisions: 19,
                          activeColor: primary,
                          onChanged: (v) => setState(() => weightKg = v),
                        ),
                      ],
                    ),
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
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Receiver Name',
                    style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
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
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Notes (optional)',
                    style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                          color: Colors.white,
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
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE2E2E2)),
              boxShadow: const [
                BoxShadow(
                    blurRadius: 18,
                    offset: Offset(0, 10),
                    color: Color(0x11000000)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: lightGrey,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.price_check_rounded, color: primary),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Estimated price',
                          style: TextStyle(fontWeight: FontWeight.w900)),
                      SizedBox(height: 4),
                      Text('Final price may change after confirmation.',
                          style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                              fontSize: 12)),
                    ],
                  ),
                ),
                Text(
                  '$price JD',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 62,
            child: ElevatedButton(
              onPressed: () async {
                if (receiverNameCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter receiver name')),
                  );
                  return;
                }

                if (pickup == dropoff) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pickup and Drop-off must be different'),
                    ),
                  );
                  return;
                }

                final price = previewPrice ?? _estimatePriceJOD();

                bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Confirm Request"),
                      content: Text(
                        "Send parcel from $pickup to $dropoff?\n\n"
                        "Type: ${selectedType.name}\n"
                        "Weight: ${weightKg.toStringAsFixed(1)} kg\n"
                        "Delivery: ${deliveryOption == 0 ? "Standard" : "Express"}\n"
                        "Price: $price JD",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Confirm"),
                        ),
                      ],
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
                    deliveryType: deliveryOption == 0 ? "standard" : "express",
                    notes: notesCtrl.text,
                    receiverName: receiverNameCtrl.text,
                    rewardCode: rewardCtrl.text.trim().isEmpty
                        ? null
                        : rewardCtrl.text.trim(),
                  );

                  final orderNumber = result['orderNumber'];
                  final pinCode = result['pinCode'];

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
                              // ✅ ICON
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 50,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // ✅ TITLE
                              const Text(
                                "Parcel Sent Successfully",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // ✅ INFO BOX
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("Order"),
                                        Row(
                                          children: [
                                            Text(orderNumber,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w900)),
                                            const SizedBox(width: 6),
                                            InkWell(
                                              onTap: () {
                                                Clipboard.setData(ClipboardData(
                                                    text: orderNumber));
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content:
                                                          Text("Order copied")),
                                                );
                                              },
                                              child: const Icon(Icons.copy,
                                                  size: 18),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("PIN"),
                                        Row(
                                          children: [
                                            Text(pinCode,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w900)),
                                            const SizedBox(width: 6),
                                            InkWell(
                                              onTap: () {
                                                Clipboard.setData(ClipboardData(
                                                    text: pinCode));
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content:
                                                          Text("PIN copied")),
                                                );
                                              },
                                              child: const Icon(Icons.copy,
                                                  size: 18),
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
                                  // OK
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.pop(context); //
                                      },
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                      ),
                                      child: const Text("OK"),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  // HOME
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const HomeScreen()),
                                          (route) => false,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Server error: $e")),
                  );
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit Request'),
            ),
          ),
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

  const _DropdownPill({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 78,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
                items: items
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(e),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
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
                        fontSize: 12,
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

class _ParcelType {
  final String name;
  final IconData icon;
  const _ParcelType(this.name, this.icon);
}
