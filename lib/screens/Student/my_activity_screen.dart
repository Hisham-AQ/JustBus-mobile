import 'package:flutter/material.dart';
import '../../services/activity_service.dart';
import 'ticket_screen.dart';
import '../../services/secure_storage.dart';

class MyActivityScreen extends StatefulWidget {
  const MyActivityScreen({super.key});

  @override
  State<MyActivityScreen> createState() => _MyActivityScreenState();
}

class _MyActivityScreenState extends State<MyActivityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool loading = true;
  String? avatar;

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
      final savedAvatar = await SecureStorage.getAvatar();

      setState(() {
        trips = List<Map<String, dynamic>>.from(data['trips'] ?? []);
        parcels = List<Map<String, dynamic>>.from(data['parcels'] ?? []);
        specialTrips =
            List<Map<String, dynamic>>.from(data['specialTrips'] ?? []);
        avatar = savedAvatar;
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
      case "cancelled":
        return const Color.fromARGB(255, 218, 3, 3);
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text(
            'My Activity',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        backgroundColor: const Color(0xFFF5F7FA),
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: TabBar(
                controller: _tabController,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black54,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: const Color(0xFF1F4B63),
                  borderRadius: BorderRadius.circular(14),
                ),
                indicatorPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                tabs: const [
                  Tab(
                    icon: Icon(
                      Icons.confirmation_num,
                      size: 18,
                    ),
                    text: "Trips",
                  ),
                  Tab(
                    icon: Icon(Icons.inventory_2),
                    text: "Parcels",
                  ),
                  Tab(
                    icon: Icon(Icons.star),
                    text: "Special",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadData,
              child: TabBarView(
                controller: _tabController,
                children: [
                  buildTrips(),
                  buildParcels(),
                  buildSpecialTrips(),
                ],
              ),
            ),
    );
  }

  Widget buildTrips() {
    if (trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.confirmation_num_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 18),
            const Text(
              'No bookings yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final t = trips[index];
        return tripTicketCard(t);
      },
    );
  }

  Widget buildParcels() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: parcels.length,
      itemBuilder: (context, index) {
        final p = parcels[index];

        return card(
          icon: Icons.inventory_2_rounded,
          iconColor: Colors.orange,
          title: "${p['pickup_location']} → ${p['dropoff_location']}",
          subtitle: "📦 ${p['parcel_type']}\n"
              "⚖️ ${p['weight']} KG • ${p['delivery_type']}\n"
              "🔐 PIN: ${p['pin_code'] ?? 'Not assigned'}",
          status: p['status'],
        );
      },
    );
  }

  Widget buildSpecialTrips() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: specialTrips.length,
      itemBuilder: (context, index) {
        final s = specialTrips[index];

        final date = DateTime.parse(s['created_at']);
        final formattedDate = "${date.day}-${date.month}-${date.year}";

        return card(
          icon: Icons.star_rounded,
          iconColor: Colors.purple,
          title: s['title'],
          subtitle: "📍 ${s['pickup_points']}\n"
              "📅 $formattedDate",
          status: s['status'] ?? 'Unknown',
        );
      },
    );
  }

  Widget tripTicketCard(
    Map<String, dynamic> t,
  ) {
    final hasPendingCancellation = t['has_pending_cancellation'] == 1;

    final status = t['status'] ?? 'Unknown';
    final color = getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1F4B63),
                  Color(0xFF2C6B8A),
                ],
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${t['from_city']} → ${t['to_city']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${t['departure_time']} → ${t['arrival_time']}',
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t['trip_date'].toString().split('T').first,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: Colors.white70,
                          ),
                          Icon(
                            Icons.directions_bus,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${t['pickup_location']} → ${t['dropoff_location']}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
            ),
            child: Row(
              children: List.generate(
                30,
                (index) => Expanded(
                  child: Container(
                    height: 1,
                    color: index.isEven
                        ? Colors.grey.shade300
                        : Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    _infoChip(
                      Icons.event_seat,
                      'Seats ${t['seats'] ?? '--'}',
                    ),
                    const SizedBox(width: 10),
                    _infoChip(
                      Icons.directions_bus,
                      'Bus ${t['bus_number'] ?? '--'}',
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Icon(
                      Icons.payments_rounded,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${t['total_price']} JD',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          '#JB-${t['booking_id']}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    const Spacer(),
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              status.toLowerCase() != "confirmed" ||
                                      hasPendingCancellation
                                  ? Colors.grey
                                  : Colors.red,
                          child: IconButton(
                            onPressed:
                                status.toLowerCase() != "confirmed" ||
                                        hasPendingCancellation
                                    ? null
                                    : () async {
                                        final reasonCtrl =
                                            TextEditingController();

                                        await showDialog(
                                          context: context,
                                          builder: (_) {
                                            return Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(26),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(24),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 82,
                                                      height: 82,
                                                      decoration: BoxDecoration(
                                                        color: Colors.red
                                                            .withOpacity(.1),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        hasPendingCancellation
                                                            ? Icons
                                                                .hourglass_top_rounded
                                                            : Icons
                                                                .cancel_rounded,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 18,
                                                    ),
                                                    const Text(
                                                      "Cancel Booking Request",
                                                      style: TextStyle(
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    const Text(
                                                      "Please tell us why you want to cancel this booking.",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.black54,
                                                        height: 1.5,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 22,
                                                    ),
                                                    TextField(
                                                      controller: reasonCtrl,
                                                      maxLines: 4,
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            "Enter cancellation reason...",
                                                        filled: true,
                                                        fillColor: const Color(
                                                          0xFFF5F7FA,
                                                        ),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            18,
                                                          ),
                                                          borderSide:
                                                              BorderSide.none,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 24,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: OutlinedButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                context,
                                                              );
                                                            },
                                                            child: const Text(
                                                              "Close",
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 12,
                                                        ),
                                                        Expanded(
                                                          child: ElevatedButton(
                                                            onPressed:
                                                                () async {
                                                              if (reasonCtrl
                                                                  .text
                                                                  .trim()
                                                                  .isEmpty) {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder: (_) =>
                                                                      Dialog(
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              24),
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          24),
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          Container(
                                                                            width:
                                                                                82,
                                                                            height:
                                                                                82,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: Colors.red.withOpacity(.1),
                                                                              shape: BoxShape.circle,
                                                                            ),
                                                                            child:
                                                                                const Icon(
                                                                              Icons.warning_rounded,
                                                                              color: Colors.red,
                                                                              size: 46,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 18),
                                                                          const Text(
                                                                            "Missing Reason",
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 22,
                                                                              fontWeight: FontWeight.w900,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 10),
                                                                          const Text(
                                                                            "Please enter cancellation reason before sending request.",
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.black54,
                                                                              height: 1.5,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 24),
                                                                          SizedBox(
                                                                            width:
                                                                                double.infinity,
                                                                            child:
                                                                                ElevatedButton(
                                                                              onPressed: () {
                                                                                Navigator.pop(context);
                                                                              },
                                                                              style: ElevatedButton.styleFrom(
                                                                                backgroundColor: const Color(0xFF1F4B63),
                                                                                padding: const EdgeInsets.symmetric(
                                                                                  vertical: 14,
                                                                                ),
                                                                                shape: RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(16),
                                                                                ),
                                                                              ),
                                                                              child: const Text(
                                                                                "OK",
                                                                                style: TextStyle(
                                                                                  fontWeight: FontWeight.w800,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );

                                                                return;
                                                              }

                                                              try {
                                                                await ActivityService
                                                                    .requestBookingCancellation(
                                                                  bookingId: t[
                                                                      'booking_id'],
                                                                  reason:
                                                                      reasonCtrl
                                                                          .text
                                                                          .trim(),
                                                                );

                                                                if (!context
                                                                    .mounted) {
                                                                  return;
                                                                }

                                                                Navigator.pop(
                                                                  context,
                                                                );

                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder: (_) =>
                                                                      Dialog(
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .circular(
                                                                        24,
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .all(
                                                                        24,
                                                                      ),
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          Container(
                                                                            width:
                                                                                82,
                                                                            height:
                                                                                82,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: Colors.green.withOpacity(
                                                                                .1,
                                                                              ),
                                                                              shape: BoxShape.circle,
                                                                            ),
                                                                            child:
                                                                                const Icon(
                                                                              Icons.check_circle_rounded,
                                                                              color: Colors.green,
                                                                              size: 46,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                18,
                                                                          ),
                                                                          const Text(
                                                                            "Request Submitted",
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 22,
                                                                              fontWeight: FontWeight.w900,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          const Text(
                                                                            "Your cancellation request has been sent to admin successfully.",
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.black54,
                                                                              height: 1.5,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                24,
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                double.infinity,
                                                                            child:
                                                                                ElevatedButton(
                                                                              onPressed: () {
                                                                                Navigator.pop(
                                                                                  context,
                                                                                );
                                                                              },
                                                                              style: ElevatedButton.styleFrom(
                                                                                backgroundColor: const Color(
                                                                                  0xFF1F4B63,
                                                                                ),
                                                                              ),
                                                                              child: const Text(
                                                                                "Done",
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              } catch (e) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                    content:
                                                                        Text(
                                                                      e.toString(),
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            },
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  Colors.red,
                                                            ),
                                                            child: const Text(
                                                              "Send",
                                                            ),
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
                                      },
                            icon: Icon(
                              hasPendingCancellation
                                  ? Icons.hourglass_top_rounded
                                  : Icons.cancel_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              status.toLowerCase() == "completed" ||
                                      status.toLowerCase() == "cancelled"
                                  ? Colors.grey
                                  : const Color(0xFF1F4B63),
                          child: IconButton(
                            onPressed: status.toLowerCase() == "completed" ||
                                    status.toLowerCase() == "cancelled"
                                ? null
                                : () async {
                                    final userName =
                                        await SecureStorage.getUserName();

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TicketScreen(
                                          seats: (t['seats'] ?? '')
                                              .toString()
                                              .split(',')
                                              .map((e) => int.parse(e))
                                              .toList(),
                                          userName: userName ?? 'Passenger',
                                          avatar: avatar,
                                          qrToken: t['qr_token'] ?? '',
                                          bookingId: t['booking_id'] ?? 0,
                                          from: t['from_city'] ?? '',
                                          to: t['to_city'] ?? '',
                                          pickupLocation:
                                              t['pickup_location'] ?? '',
                                          dropoffLocation:
                                              t['dropoff_location'] ?? '',
                                          date: t['trip_date']
                                              .toString()
                                              .split('T')
                                              .first,
                                          time:
                                              '${t['departure_time']} - ${t['arrival_time']}',
                                          busNumber: t['bus_id'],
                                          tripId: t['trip_id'] ?? 0,
                                        ),
                                      ),
                                    );
                                  },
                            icon: const Icon(
                              Icons.qr_code_2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(
    IconData icon,
    String text,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.blue.shade900,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget card({
    required String title,
    required String subtitle,
    required String status,
    IconData icon = Icons.local_shipping_rounded,
    Color iconColor = const Color(0xFF1F4B63),
  }) {
    final color = getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      height: 1.5,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
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
