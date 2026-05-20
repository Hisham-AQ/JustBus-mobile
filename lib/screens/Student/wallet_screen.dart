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
                      await showErrorDialog("Enter a valid amount");
                      return;
                    }

                    try {
                      final newBalance = await WalletService.topUp(amount);

                      setState(() {
                        balance = newBalance;
                      });
                      Navigator.pop(context);

                      await showDialog(
                        context: context,
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
                                  Container(
                                    width: 74,
                                    height: 74,
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.green,
                                      size: 40,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  const Text(
                                    "Success",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "Wallet topped up successfully",
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 22),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primary,
                                        minimumSize: const Size(0, 54),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: const Text(
                                        "OK",
                                        style: TextStyle(
                                          color: Colors.white,
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
                    } catch (e) {
                      await showErrorDialog(e.toString());
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

  Future<void> showErrorDialog(String text) async {
    await showDialog(
      context: context,
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
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "Error",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      minimumSize: const Size(0, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        color: Colors.white,
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
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: StatefulBuilder(
                                builder: (context, setDialogState) {
                                  return SingleChildScrollView(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // ===== CARD PREVIEW =====

                                        Container(
                                          width: double.infinity,
                                          height: 200,
                                          padding: const EdgeInsets.all(22),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(26),
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF1F4B63),
                                                Color(0xFF2D6A8D),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Spacer(),
                                              Text(
                                                number.text.isEmpty
                                                    ? '**** **** **** ****'
                                                    : number.text,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 22,
                                                  letterSpacing: 2,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              const SizedBox(height: 18),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'CARD HOLDER',
                                                        style: TextStyle(
                                                          color: Colors.white54,
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        name.text.isEmpty
                                                            ? 'YOUR NAME'
                                                            : name.text
                                                                .toUpperCase(),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'EXPIRES',
                                                        style: TextStyle(
                                                          color: Colors.white54,
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        expiry.text.isEmpty
                                                            ? 'MM/YY'
                                                            : expiry.text,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: 26),

                                        TextField(
                                          controller: number,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(
                                                19),
                                            CardNumberFormatter(),
                                          ],
                                          onChanged: (_) =>
                                              setDialogState(() {}),
                                          decoration: InputDecoration(
                                            hintText: 'Card Number',
                                            prefixIcon:
                                                const Icon(Icons.credit_card),
                                            filled: true,
                                            fillColor: const Color(0xFFF5F7FA),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 14),

                                        TextField(
                                          controller: name,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[a-zA-Z ]')),
                                          ],
                                          onChanged: (_) =>
                                              setDialogState(() {}),
                                          decoration: InputDecoration(
                                            hintText: 'Card Holder',
                                            prefixIcon: const Icon(
                                                Icons.person_outline),
                                            filled: true,
                                            fillColor: const Color(0xFFF5F7FA),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 14),

                                        TextField(
                                          controller: expiry,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(4),
                                            ExpiryDateFormatter(),
                                          ],
                                          onChanged: (_) =>
                                              setDialogState(() {}),
                                          decoration: InputDecoration(
                                            hintText: 'MM/YY',
                                            prefixIcon: const Icon(
                                              Icons.calendar_month_outlined,
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFFF5F7FA),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 28),

                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Cancel'),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: SizedBox(
                                                height: 52,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: primary,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    final clean = number.text
                                                        .replaceAll(' ', '')
                                                        .trim();
                                                    final holder =
                                                        name.text.trim();
                                                    final exp =
                                                        expiry.text.trim();

                                                    // CARD NUMBER VALIDATION

                                                    if (clean.isEmpty) {
                                                      await showErrorDialog(
                                                          "Enter card number");
                                                      return;
                                                    }

                                                    // only digits
                                                    if (!RegExp(r'^[0-9]+$')
                                                        .hasMatch(clean)) {
                                                      await showErrorDialog(
                                                          "Card number must contain digits only");
                                                      return;
                                                    }

                                                    // Visa / MasterCard usually 16 digits
                                                    if (clean.length != 16) {
                                                      await showErrorDialog(
                                                          "Card number must be 16 digits");
                                                      return;
                                                    }

                                                    // HOLDER NAME VALIDATION

                                                    if (holder.isEmpty) {
                                                      await showErrorDialog(
                                                          "Enter card holder name");
                                                      return;
                                                    }

                                                    // only letters + spaces
                                                    if (!RegExp(r'^[a-zA-Z ]+$')
                                                        .hasMatch(holder)) {
                                                      await showErrorDialog(
                                                        "Card holder name must contain letters only",
                                                      );
                                                      return;
                                                    }

                                                    if (holder.length < 3) {
                                                      await showErrorDialog(
                                                          "Invalid card holder name");
                                                      return;
                                                    }

                                                    // EXPIRY VALIDATION

                                                    if (!RegExp(
                                                            r'^\d{2}/\d{2}$')
                                                        .hasMatch(exp)) {
                                                      await showErrorDialog(
                                                          "Expiry must be MM/YY");
                                                      return;
                                                    }

                                                    final parts =
                                                        exp.split('/');

                                                    final month =
                                                        int.parse(parts[0]);
                                                    final year =
                                                        int.parse(parts[1]);

                                                    if (month < 1 ||
                                                        month > 12) {
                                                      await showErrorDialog(
                                                          "Invalid expiry month");
                                                      return;
                                                    }

                                                    final now = DateTime.now();

                                                    final currentYear =
                                                        now.year % 100;
                                                    final currentMonth =
                                                        now.month;

                                                    if (year < currentYear ||
                                                        (year == currentYear &&
                                                            month <
                                                                currentMonth)) {
                                                      await showErrorDialog(
                                                          "Card has expired");
                                                      return;
                                                    }

                                                    // BRAND DETECTION

                                                    final brand =
                                                        detectCardBrand(clean);

                                                    if (brand == 'Unknown') {
                                                      await showErrorDialog(
                                                        "Only Visa and MasterCard are supported",
                                                      );
                                                      return;
                                                    }

                                                    try {
                                                      await CardService.addCard(
                                                        cardNumber: clean,
                                                        holder: holder,
                                                        expiry: exp,
                                                        brand: brand,
                                                      );
                                                      await loadData();

                                                      if (context.mounted) {
                                                        Navigator.pop(context);
                                                      }

                                                      await showDialog(
                                                        context: context,
                                                        builder: (_) {
                                                          return Dialog(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          24),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(24),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Container(
                                                                    width: 74,
                                                                    height: 74,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .green
                                                                          .withOpacity(
                                                                              .12),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    child:
                                                                        const Icon(
                                                                      Icons
                                                                          .check_circle_rounded,
                                                                      color: Colors
                                                                          .green,
                                                                      size: 40,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          18),
                                                                  const Text(
                                                                    "Success",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          22,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w900,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          10),
                                                                  const Text(
                                                                    "Card added successfully",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          22),
                                                                  SizedBox(
                                                                    width: double
                                                                        .infinity,
                                                                    child:
                                                                        ElevatedButton(
                                                                      onPressed:
                                                                          () =>
                                                                              Navigator.pop(context),
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        backgroundColor:
                                                                            primary,
                                                                        minimumSize: const Size(
                                                                            0,
                                                                            54),
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(16),
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          const Text(
                                                                        "OK",
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.w800,
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
                                                    } catch (e) {
                                                      await showErrorDialog(
                                                        e.toString().replaceAll(
                                                            "Exception: ", ""),
                                                      );
                                                    }
                                                  },
                                                  child: const Text(
                                                    "Save",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
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
                  }),
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
                  }),
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

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;

    if (text.length > 2 && !text.contains('/')) {
      text = '${text.substring(0, 2)}/${text.substring(2)}';
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: text.length,
      ),
    );
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(' ', '');

    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);

      final index = i + 1;

      if (index % 4 == 0 && index != text.length) {
        buffer.write(' ');
      }
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
    );
  }
}
