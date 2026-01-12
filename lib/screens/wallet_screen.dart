import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  static const Color primary = Color(0xFF1F4B63);
  static const Color lightGrey = Color(0xFFEDEDED);

  Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream() {
    final user = FirebaseAuth.instance.currentUser!;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _transactionsStream() {
    final user = FirebaseAuth.instance.currentUser!;
    return FirebaseFirestore.instance
        .collection('wallet_transactions')
        .where('uid', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots();
  }

  Future<void> addWalletTransaction({
    required double amount,
    required String title,
    required String type,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final currentBalance =
          (snapshot.data()?['walletBalance'] ?? 0).toDouble();
      final newBalance = currentBalance + amount;

      transaction.update(userRef, {
        'walletBalance': newBalance,
      });

      transaction.set(
        FirebaseFirestore.instance.collection('wallet_transactions').doc(),
        {
          'uid': user.uid,
          'type': type,
          'amount': amount,
          'balanceAfter': newBalance,
          'title': title,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );
    });
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
          Container(
            width: 46,
            height: 46,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                ),
              ],
            ),
            child: Image.asset(
              brand.toLowerCase() == 'visa'
                  ? 'assets/images/visa-icon.png'
                  : 'assets/images/mastercard-icon.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brand,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '**** **** **** $last4',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
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
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _userStream(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final balance =
              (userSnapshot.data!.data()?['walletBalance'] ?? 0).toDouble();

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _transactionsStream(),
            builder: (context, txSnapshot) {
              if (!txSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final transactions = txSnapshot.data!.docs;

              return ListView(
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSavedCard(
                    brand: 'Visa',
                    last4: '4242',
                  ),
                  _buildSavedCard(
                    brand: 'MasterCard',
                    last4: '1122',
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Navigate to Add Card Screen
                    },
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Add New Card',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Transaction History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (transactions.isEmpty)
                    const Text(
                      'No transactions yet',
                      style: TextStyle(color: Colors.black54),
                    )
                  else
                    ...transactions.map((doc) {
                      final data = doc.data();
                      final amount = (data['amount'] ?? 0).toDouble();
                      final title = data['title'] ?? '';
                      final isNegative = amount < 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: lightGrey,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isNegative
                                  ? Icons.remove_circle_outline
                                  : Icons.add_circle_outline,
                              color: isNegative ? Colors.red : Colors.green,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                            Text(
                              '${amount > 0 ? '+' : ''}${amount.toStringAsFixed(2)} JD',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: isNegative ? Colors.red : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showTopUpSheet(BuildContext context) {
    final amountCtrl = TextEditingController();
    const primary = Color(0xFF1F4B63);

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
                    selectedColor: primary.withOpacity(0.15),
                    labelStyle: const TextStyle(fontWeight: FontWeight.w800),
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

                    Navigator.pop(context);

                    await addWalletTransaction(
                      amount: amount,
                      title: 'Wallet Top Up',
                      type: 'topup',
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Wallet topped up')),
                    );
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
}
