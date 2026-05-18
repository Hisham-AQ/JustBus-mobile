import 'package:flutter/material.dart';
import '../../services/wallet_service.dart';
import '../../services/card_service.dart';
import 'package:flutter/services.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  static const Color primary = Color(0xFF1F4B63);
  static const Color lightGrey = Color(0xFFEDEDED);

  bool isLoading = true;
  double balance = 0;
  List<dynamic> cards = [];
  List<dynamic> transactions = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final results = await Future.wait([
        WalletService.getBalance(),
        CardService.getCards(),
        WalletService.getTransactions(),
      ]);

      final b = results[0] as double;
      final c = results[1] as List;
      final t = results[2] as List;

      if (!mounted) return;

      setState(() {
        balance = b;
        cards = c;
        transactions = t;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("WALLET ERROR: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  void _showTopUpSheet(BuildContext context) {
    final amountCtrl = TextEditingController();

    void selectAmount(double v) {
      setState(() {
        amountCtrl.text = v.toStringAsFixed(0);
      });
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
              const SizedBox(height: 28),
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
                      final newBalance = await WalletService.topUp(amount);

                      setState(() {
                        balance = newBalance;
                      });

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

  String getCardImage(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return 'assets/images/visa-icon.png';
      case 'mastercard':
        return 'assets/images/mastercard-icon.png';
      default:
        return 'assets/images/card.png';
    }
  }

  Widget _buildSavedCard({
    required String brand,
    required String last4,
    required int id,
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
          Image.asset(
            getCardImage(brand),
            width: 40,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text('$brand •••• $last4'),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Delete card?"),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel")),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Delete")),
                  ],
                ),
              );

              if (confirm == true) {
                await CardService.deleteCard(id);
                await loadData();
              }
            },
          )
        ],
      ),
    );
  }

  String getLast4(String number) {
    final clean = number.replaceAll(' ', '');

    if (clean.length <= 4) {
      return clean;
    }

    return clean.substring(clean.length - 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Wallet',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: const Color(0xFFF5F7FA),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1F4B63),
                          Color(0xFF2C6B8A),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.account_balance_wallet_rounded,
                                color: Colors.white.withOpacity(0.9),
                                size: 34,
                              ),
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
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
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
                  Row(
                    children: [
                      Icon(
                        Icons.credit_card_rounded,
                        color: primary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Saved Cards',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Add Card"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        final number = TextEditingController();
                        final name = TextEditingController();
                        final expiry = TextEditingController();

                        showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: const Text(
                                "Add Card",
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: number,
                                    keyboardType: TextInputType.number,
                                    maxLength: 19,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: InputDecoration(
                                      labelText: "Card Number",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: name,
                                    decoration: InputDecoration(
                                      labelText: "Card Holder",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: expiry,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9/]')),
                                    ],
                                    decoration: InputDecoration(
                                      labelText: "Expiry Date",
                                      hintText: "MM/YY",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final clean =
                                        number.text.replaceAll(' ', '');

                                    if (clean.length < 13 ||
                                        clean.length > 19) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text("Invalid card number")),
                                      );
                                      return;
                                    }

                                    if (name.text.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text("Enter card holder name")),
                                      );
                                      return;
                                    }

                                    if (!RegExp(r'^\d{2}/\d{2}$')
                                        .hasMatch(expiry.text)) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text("Invalid expiry format")),
                                      );
                                      return;
                                    }
                                    final brand = detectCardBrand(clean);

                                    try {
                                      await CardService.addCard(
                                        cardNumber: clean,
                                        holder: name.text,
                                        expiry: expiry.text,
                                        brand: brand,
                                      );

                                      await loadData();
                                      Navigator.pop(context);
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text(e.toString())),
                                      );
                                    }
                                  },
                                  child: const Text("Save"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  ...cards.map((c) {
                    return _buildSavedCard(
                      brand: c['brand'] ?? 'Unknown',
                      last4: getLast4(c['card_number']),
                      id: c['id'],
                    );
                  }).toList(),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        color: primary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Transactions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...transactions.map((tx) {
                    final isTopUp = tx['type'] == 'topup';

                    final date = DateTime.parse(tx['created_at']);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                isTopUp ? Colors.green[100] : Colors.red[100],
                            child: Icon(
                              isTopUp
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: isTopUp ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  getTitle(tx['type']),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  formatDate(date),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "${isTopUp ? '+' : '-'}${double.parse(tx['amount'].toString()).toStringAsFixed(2)} JD",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isTopUp ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }

  String detectCardBrand(String number) {
    if (number.startsWith('4')) return 'Visa';
    if (RegExp(r'^5[1-5]').hasMatch(number)) return 'MasterCard';
    return 'Unknown';
  }
}

String formatDate(DateTime d) {
  return "${d.day.toString().padLeft(2, '0')}/"
      "${d.month.toString().padLeft(2, '0')}/"
      "${d.year}";
}

String getTitle(String type) {
  switch (type) {
    case "topup":
      return "Top Up";
    case "payment":
      return "Booking Payment";
    default:
      return "Transaction";
  }
}
