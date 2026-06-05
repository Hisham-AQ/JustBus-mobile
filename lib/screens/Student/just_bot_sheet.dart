import 'package:flutter/material.dart';
import '../../services/ai_service.dart';
import '../../services/profile_service.dart';
import 'search_results_screen.dart';
import 'dart:async';

class JustBotSheet extends StatefulWidget {
  const JustBotSheet({super.key});

  @override
  State<JustBotSheet> createState() => _JustBotSheetState();
}

class _JustBotSheetState extends State<JustBotSheet> {
  final TextEditingController controller = TextEditingController();

  List<Map<String, String>> messages = [];
  bool loading = false;
  int typingDots = 1;
  Timer? typingTimer;
  String? selectedAvatar;
  bool showSuggestions = true;
  List<Map<String, dynamic>> tripResults = [];

  Future<void> sendMessage() async {
    final text = controller.text.trim();
    showSuggestions = false;
    if (text.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": text});
      loading = true;
    });
    scrollToBottom();

    typingTimer?.cancel();

    typingTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) {
        setState(() {
          typingDots++;

          if (typingDots > 3) {
            typingDots = 1;
          }
          scrollToBottom();
        });
      },
    );
    controller.clear();

    try {
      final data = await AIService.sendMessage(text);

      setState(() {
        final reply = (data['reply'] ?? '').toString();

        if (reply.isNotEmpty) {
          messages.add({
            "role": "bot",
            "text": reply,
          });
        }
      });
      scrollToBottom();

      final trips = List<Map<String, dynamic>>.from(
        data['trips'] ?? [],
      );

      setState(() {
        tripResults.clear();
        tripResults = trips;
      });
    } catch (e) {
      setState(() {
        messages.add({"role": "bot", "text": "Error: $e"});
      });
    } finally {
      typingTimer?.cancel();

      setState(() {
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    typingTimer?.cancel();
    super.dispose();
  }

  void sendQuickMessage(String text) {
    controller.text = text;
    sendMessage();

    setState(() {
      showSuggestions = false;
    });
  }

  Widget buildMessage(Map<String, String> msg) {
    final isUser = msg["role"] == "user";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1F4B63),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/bot.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              constraints: const BoxConstraints(
                maxWidth: 260,
              ),
              decoration: BoxDecoration(
                color:
                    isUser ? const Color(0xFF1E4F6F) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(
                    isUser ? 20 : 6,
                  ),
                  bottomRight: Radius.circular(
                    isUser ? 6 : 20,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                msg["text"] ?? "",
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (isUser)
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(left: 8),
              child: CircleAvatar(
                backgroundColor: Colors.orange.shade100,
                child: selectedAvatar != null
                    ? ClipOval(
                        child: Image.asset(
                          selectedAvatar!,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.person_rounded,
                        color: Color(0xFF1F4B63),
                        size: 20,
                      ),
              ),
            ),
        ],
      ),
    );
  }

  final ScrollController scrollController = ScrollController();

  void scrollToBottom() {
    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        if (!scrollController.hasClients) return;

        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _loadAvatar();

    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      },
    );
  }

  Widget quickCard({
    required IconData icon,
    required String title,
    required String question,
    required Color color,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => sendQuickMessage(question),
      child: Container(
        width: 165,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tripCard(Map<String, dynamic> trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  trip['from_city'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFF1F4B63),
              ),
              Expanded(
                child: Text(
                  trip['to_city'],
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 18,
                color: Colors.orange.shade700,
              ),
              const SizedBox(width: 6),
              Text("${trip['departure_time']}"),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                size: 18,
                color: Colors.purple.shade700,
              ),
              const SizedBox(width: 6),
              Text(
                trip['trip_date'].toString().split('T').first,
              )
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.event_seat_rounded,
                size: 18,
                color: Colors.green.shade700,
              ),
              const SizedBox(width: 6),
              Text("${trip['available_seats']} Seats"),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.payments_rounded,
                size: 18,
                color: Colors.teal.shade700,
              ),
              const SizedBox(width: 6),
              Text("${trip['price']} JD"),
            ],
          ),
          Text(
            "👨‍✈️ Driver: ${trip['driver_name'] ?? 'N/A'}",
          ),
          Text(
            "🚌 Bus: ${trip['bus_number'] ?? 'N/A'}",
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: trip['status'] == 'ongoing'
                  ? Colors.orange.shade50
                  : Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              trip['status'] ?? '',
              style: TextStyle(
                color: trip['status'] == 'ongoing'
                    ? Colors.orange.shade700
                    : Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(
                Icons.event_seat_rounded,
                color: Colors.white,
              ),
              label: const Text(
                'Book Now',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F4B63),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: trip['status'] == 'scheduled'
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SearchResultsScreen(
                            from: trip['from_city'],
                            to: trip['to_city'],
                            date: trip['trip_date'],
                            persons: 1,
                          ),
                        ),
                      );
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF7F8FA),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          children: [
            SafeArea(
              top: true,
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 4,
                  right: 4,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F4B63),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/bot.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'JustBot',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Online now',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          messages.clear();
                          tripResults.clear();
                          showSuggestions = true;
                        });
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.refresh_rounded,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (messages.isEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(
                  bottom: 20,
                  top: 10,
                ),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F4B63),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.asset(
                          'assets/images/bot.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Welcome to JustBot 👋",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "I can help you with trips, bookings, tickets, tracking, rewards, parcels and more.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  ...messages.map(
                    (msg) => buildMessage(msg),
                  ),
                  if (tripResults.isNotEmpty)
                    ...tripResults.map(
                      (trip) => tripCard(trip),
                    ),
                ],
              ),
            ),
            if (showSuggestions)
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 12,
                  top: 6,
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    quickCard(
                      icon: Icons.directions_bus_rounded,
                      title: "Available Trips",
                      question: "Show available trips",
                      color: Colors.blue,
                    ),
                    quickCard(
                      icon: Icons.confirmation_num_rounded,
                      title: "How to Book?",
                      question: "How can I book a seat?",
                      color: Colors.green,
                    ),
                    quickCard(
                      icon: Icons.location_on_rounded,
                      title: "Track Bus",
                      question: "How does bus tracking work?",
                      color: Colors.red,
                    ),
                    quickCard(
                      icon: Icons.card_giftcard_rounded,
                      title: "Rewards",
                      question: "Explain rewards system",
                      color: Colors.purple,
                    ),
                    quickCard(
                      icon: Icons.inventory_2_rounded,
                      title: "Parcel Service",
                      question: "How can I send a parcel?",
                      color: Colors.orange,
                    ),
                    quickCard(
                      icon: Icons.warning_amber_rounded,
                      title: "Panic Alert",
                      question: "How does panic alert work?",
                      color: Colors.red.shade800,
                    ),
                  ],
                ),
              ),
            if (loading)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    'JustBot is typing${"." * typingDots}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onSubmitted: (_) => sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Ask anything...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: Color(0xFF1F4B63),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 52,
                  height: 52,
                  margin: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F4B63),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                    ),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadAvatar() async {
    try {
      final profile = await ProfileService.getProfile();

      if (mounted) {
        setState(() {
          selectedAvatar = profile['avatar'];
        });
      }
    } catch (_) {}
  }
}
