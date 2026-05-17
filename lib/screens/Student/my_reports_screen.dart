import 'package:flutter/material.dart';
import '../../services/lostItems_service.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _ReportCard extends StatelessWidget {
  final String item;
  final String status;
  final String date;

  const _ReportCard({
    required this.item,
    required this.status,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFound = status == 'found';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isFound ? Colors.green.shade100 : Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isFound ? Icons.check_circle : Icons.hourglass_top,
              color: isFound ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: isFound ? Colors.green.shade100 : Colors.orange.shade100,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isFound ? Icons.check_circle : Icons.schedule,
                  size: 14,
                  color: isFound ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 5),
                Text(
                  isFound ? "FOUND" : "PENDING",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: isFound ? Colors.green : Colors.orange,
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

class _MyReportsScreenState extends State<MyReportsScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = LostItemsService.getMyReports();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = LostItemsService.getMyReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load reports"));
          }

          final data = snapshot.data as List;

          if (data.isEmpty) {
            return const Center(
              child: Text("No reports yet"),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (context, i) {
                final r = data[i];

                return _ReportCard(
                  item: r['item_name'],
                  status: r['status'],
                  date: _formatDate(r['lost_date']),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String date) {
    final d = DateTime.parse(date);
    return "${d.day}/${d.month}/${d.year}";
  }
}
