import 'package:flutter/material.dart';

class MyRidesScreen extends StatelessWidget {
  const MyRidesScreen({super.key});

  static const Color primary = Color(0xFF1F4B63);
  static const Color lightGrey = Color(0xFFEDEDED);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'My Rides',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          bottom: const TabBar(
            labelColor: primary,
            unselectedLabelColor: Colors.black54,
            indicatorColor: primary,
            labelStyle: TextStyle(fontWeight: FontWeight.w900),
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
              children: const [
                _RideCard(
                  from: 'Amman',
                  to: 'JUST',
                  date: '1 / 1 / 2026',
                  persons: 2,
                  status: 'Scheduled',
                  statusColor: Colors.blue,
                ),
                _RideCard(
                  from: 'Irbid',
                  to: 'JUST',
                  date: '3 / 1 / 2026',
                  persons: 1,
                  status: 'Confirmed',
                  statusColor: Colors.green,
                ),
              ],
            ),
            ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
              children: const [
                _RideCard(
                  from: 'JUST',
                  to: 'Amman',
                  date: '20 / 12 / 2025',
                  persons: 1,
                  status: 'Completed',
                  statusColor: Colors.grey,
                ),
                _RideCard(
                  from: 'JUST',
                  to: 'Zarqa',
                  date: '15 / 12 / 2025',
                  persons: 3,
                  status: 'Completed',
                  statusColor: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RideCard extends StatelessWidget {
  final String from;
  final String to;
  final String date;
  final int persons;
  final String status;
  final Color statusColor;

  const _RideCard({
    required this.from,
    required this.to,
    required this.date,
    required this.persons,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MyRidesScreen.lightGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined),
              const SizedBox(width: 6),
              Text(
                '$from → $to',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _info(Icons.calendar_month_rounded, date),
              const SizedBox(width: 14),
              _info(
                Icons.people_alt_rounded,
                persons == 1 ? '1 Person' : '$persons Persons',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
