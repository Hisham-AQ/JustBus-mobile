import 'package:flutter/material.dart';
import '../../services/notifications_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const primary = Color(0xFF1F4B63);

  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = NotificationsService.getNotifications();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = NotificationsService.getNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          // 🔄 LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ ERROR
          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load notifications"));
          }

          final data = snapshot.data as List;

          // 💤 EMPTY
          if (data.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "No notifications yet",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // 🔥 LIST + REFRESH
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (context, i) {
                final n = data[i];

                return Dismissible(
                  key: Key(n['id'].toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) async {
                    await NotificationsService.deleteNotification(n['id']);
                    _refresh();
                  },
                  child: GestureDetector(
                    onTap: () async {
                      if (n['is_read'] == 0) {
                        await NotificationsService.markAsRead(n['id']);
                        _refresh();
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: n['is_read'] == 1
                            ? const Color(0xFFF5F5F5)
                            : const Color(0xFFE8F4FF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          // 🔹 ICON
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getIcon(n['type']),
                              color: primary,
                            ),
                          ),

                          const SizedBox(width: 12),

                          // 🔹 TEXT
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (n['title'] != null)
                                  Text(
                                    n['title'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  n['message'],
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _getTimeAgo(n['created_at']),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // 🔥 ICON حسب النوع
  IconData _getIcon(String? type) {
    switch (type) {
      case 'booking':
        return Icons.directions_bus;
      case 'reward':
        return Icons.card_giftcard;
      case 'parcel':
        return Icons.inventory_2;
      default:
        return Icons.notifications;
    }
  }

  // 🔥 TIME AGO
  String _getTimeAgo(String date) {
    final dt = DateTime.parse(date);
    final diff = DateTime.now().difference(dt);

    if (diff.inMinutes < 1) return "Now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} h ago";
    return "${diff.inDays} d ago";
  }
}
