import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const Color primary = Color(0xFF1F4B63);
  static const Color lightGrey = Color(0xFFEDEDED);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Help Center',
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
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: const [
                Icon(Icons.headset_mic_rounded, color: Colors.white, size: 36),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'How can we help you?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          _faqTile(
            question: 'How do I book a trip?',
            answer:
                'Choose your pickup and destination, select the date and number of passengers, then press Search.',
          ),
          _faqTile(
            question: 'How can I send a package?',
            answer:
                'Go to the Package section from the menu, fill in the pickup and drop-off details, and submit your request.',
          ),
          _faqTile(
            question: 'How does the wallet work?',
            answer:
                'You can add balance, save cards, and pay directly for trips and package deliveries.',
          ),
          _faqTile(
            question: 'What are rewards points?',
            answer:
                'You earn points for trips, packages, and special trips. Points can be redeemed for discounts and free services.',
          ),
          const SizedBox(height: 26),
          const Text(
            'Contact Us',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          _contactTile(
            icon: Icons.email_outlined,
            title: 'Email Support',
            subtitle: 'support@justbus.com',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email support (demo)')),
              );
            },
          ),
          _contactTile(
            icon: Icons.phone_outlined,
            title: 'Call Us',
            subtitle: '+962 7X XXX XXXX',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Call support (demo)')),
              );
            },
          ),
          _contactTile(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Live Chat',
            subtitle: 'Chat with our support team',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Live chat (demo)')),
              );
            },
          ),
        ],
      ),
    );
  }

  static Widget _faqTile({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: const TextStyle(
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _contactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        tileColor: lightGrey,
        leading: Icon(icon, color: primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
