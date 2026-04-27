import 'package:flutter/material.dart';
import '../services/wallet_service.dart';
import '../services/card_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  static const Color primary = Color(0xFF1F4B63);
  static const Color lightGrey = Color(0xFFEDEDED);

  double balance = 0;
  List<dynamic> cards = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final b = await WalletService.getBalance();
      final c = await CardService.getCards();

      setState(() {
        balance = b;
        cards = c;
      });
    } catch (e) {
      print("WALLET ERROR: $e");
    }
  }

  void _showTopUpSheet(BuildContext context) {
    final amountCtrl = TextEditingController();

    void selectAmount(double v) {
      amountCtrl.text = v.toStringAsFixed(0);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            18,
            18,
            18,
            MediaQuery.of(context).viewInsets.bottom + 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Top Up Wallet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [1, 5, 10, 20].map((v) {
                  return ChoiceChip(
                    label: Text('$v JD'),
                    selected: amountCtrl.text == v.toString(),
                    onSelected: (_) => selectAmount(v.toDouble()),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Custom amount',
                  suffixText: 'JD',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountCtrl.text);

                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Enter a valid amount')),
                      );
                      return;
                    }

                    try {
                      await WalletService.topUp(amount);
                      await loadData();

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Wallet topped up successfully')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Confirm Top Up',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSavedCard({
    required String brand,
    required String last4,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: Text('$brand •••• $last4')),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Wallet',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Balance',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${balance.toStringAsFixed(2)} JD',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showTopUpSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Top Up',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Saved Cards',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              final number = TextEditingController();
              final name = TextEditingController();
              final expiry = TextEditingController();

              showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: const Text("Add Card"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                            controller: number,
                            decoration:
                                InputDecoration(labelText: "Card Number")),
                        TextField(
                            controller: name,
                            decoration: InputDecoration(labelText: "Name")),
                        TextField(
                            controller: expiry,
                            decoration: InputDecoration(labelText: "MM/YY")),
                      ],
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () async {
                          // ✅ validation أول شي
                          if (number.text.isEmpty ||
                              name.text.isEmpty ||
                              expiry.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Fill all fields')),
                            );
                            return;
                          }

                          try {
                            await CardService.addCard(
                              number: number.text,
                              holder: name.text,
                              expiry: expiry.text,
                              brand: "Visa",
                            );

                            await loadData();

                            Navigator.pop(context); // 🔥 مهم تسكر الديالوج

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Card added successfully')),
                            );
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: const Text("Save"),
                      )
                    ],
                  );
                },
              );
            },
            child: const Text("Add Card"),
          ),
          // 🔥 هنا التعديل الحقيقي
          ...cards.map((card) => _buildSavedCard(
                brand: card['brand'],
                last4: card['card_number'],
              )),
        ],
      ),
    );
  }
}
