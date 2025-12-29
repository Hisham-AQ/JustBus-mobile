import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  static const Color primary = Color(0xFF1F4B63);
  static const Color lightGrey = Color(0xFFEDEDED);

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
          // ===== BALANCE =====
          Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: const Color(0xFF1F4B63),
    borderRadius: BorderRadius.circular(20),
  ),
  child: Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Current Balance',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            SizedBox(height: 6),
            Text(
              '12.50 JD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
      ElevatedButton(
        onPressed: () {
          // TODO: Open Top Up screen / bottom sheet
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1F4B63),
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


          const SizedBox(height: 22),

          // ===== SAVED CARDS =====
          const Text(
            'Saved Cards',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),

          _cardTile(
            icon: Icons.credit_card,
            title: 'Visa',
            subtitle: '**** **** **** 4242',
          ),
          _cardTile(
            icon: Icons.credit_card,
            title: 'MasterCard',
            subtitle: '**** **** **** 1122',
          ),

          const SizedBox(height: 10),

          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add card (later)')),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text(
              'Add New Card',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),

          const SizedBox(height: 26),

          // ===== TRANSACTION HISTORY =====
          const Text(
            'Transaction History',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),

          _transactionTile(
            icon: Icons.directions_bus_rounded,
            title: 'Trip to JUST',
            amount: '-1.50 JD',
            negative: true,
          ),
          _transactionTile(
            icon: Icons.inventory_2_outlined,
            title: 'Package Delivery',
            amount: '-3.00 JD',
            negative: true,
          ),
          _transactionTile(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Wallet Top Up',
            amount: '+10.00 JD',
            negative: false,
          ),
        ],
      ),
    );
  }

  // ================== Widgets ==================

  static Widget _cardTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }

  static Widget _transactionTile({
    required IconData icon,
    required String title,
    required String amount,
    required bool negative,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: negative ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
