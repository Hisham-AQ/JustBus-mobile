import 'package:flutter/material.dart';
import '../../services/trip_service.dart';
import '../../services/activity_service.dart';

class MyActivityScreen extends StatefulWidget {
  const MyActivityScreen({super.key});

  @override
  State<MyActivityScreen> createState() => _MyActivityScreenState();
}

class _MyActivityScreenState extends State<MyActivityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool loading = true;

  List<Map<String, dynamic>> trips = [];
  List parcels = [];
  List specialTrips = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadData();
  }

  Future<void> loadData() async {
    try {
      final data = await ActivityService.getMyActivity();

      setState(() {
        trips = List<Map<String, dynamic>>.from(data['trips'] ?? []);
        parcels = List<Map<String, dynamic>>.from(data['parcels'] ?? []);
        specialTrips =
            List<Map<String, dynamic>>.from(data['specialTrips'] ?? []);
        loading = false;
      });
    } catch (e) {
      print("ERROR: $e");
      setState(() {
        loading = false;
      });
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "confirmed":
      case "delivered":
      case "active":
        return Colors.green;
      case "scheduled":
      case "pending":
        return Colors.blue;
      case "in transit":
        return Colors.orange;
      case "completed":
        return Colors.grey;
        case "expired":
        return const Color.fromARGB(255, 218, 3, 3);
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'My Activity',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.black54,
          tabs: const [
            Tab(text: "Trips"),
            Tab(text: "Parcels"),
            Tab(text: "Special"),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                buildTrips(),
                buildParcels(),
                buildSpecialTrips(),
              ],
            ),
    );
  }

  // ================= TRIPS =================
  Widget buildTrips() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final t = trips[index];

        final date = DateTime.parse(t['trip_date']);

        final formattedDate = "${date.day}-${date.month}-${date.year}";

        final time = t['departure_time'] ?? '';

        return card(
          title: "${t['from_city']} → ${t['to_city']}",
          subtitle:
              "Date: $formattedDate  •  Time: $time\nPersons: ${t['persons'] ?? 1}",
          status: t['status'] ?? 'Unknown',
        );
      },
    );
  }

  // ================= PARCELS =================
  Widget buildParcels() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: parcels.length,
      itemBuilder: (context, index) {
        final p = parcels[index];

        return card(
          title: "${p['pickup_location']} → ${p['dropoff_location']}",
          subtitle: "Weight: ${p['weight']} • ${p['delivery_type']}\n"
              "Type: ${p['parcel_type']}\n"
              "PIN: ${p['pin_code'] ?? 'Not assigned'}",
          status: p['status'],
        );
      },
    );
  }

  // ================= SPECIAL =================
  Widget buildSpecialTrips() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: specialTrips.length,
      itemBuilder: (context, index) {
        final s = specialTrips[index];

        final date = DateTime.parse(s['created_at']);
        final formattedDate = "${date.day}-${date.month}-${date.year}";

        return card(
          title: s['title'],
          subtitle: "From: ${s['pickup_points']}\nDate: $formattedDate",
          status: s['status'] ?? 'Unknown',
        );
      },
    );
  }

  // ================= CARD =================
  Widget card({
    required String title,
    required String subtitle,
    required String status,
  }) {
    final color = getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
