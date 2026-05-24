import 'package:flutter/material.dart';
import '../../services/ai_service.dart';
import '../../services/profile_service.dart';
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

  Future<void> sendMessage() async {
    final text = controller.text.trim();
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
        messages.add({"role": "bot", "text": data['reply'] ?? ''});
      });
      scrollToBottom();

      final trips = List.from(data['trips'] ?? []);

      if (trips.isNotEmpty) {
        setState(() {
          messages.add({"role": "bot", "text": "كيف أقدر أساعدك كمان 👇"});
        });
      }
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

    messages.add({
      "role": "bot",
      "text": "مرحبا 👋\nأنا JustBot.\nكيف أقدر أساعدك اليوم؟"
    });
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
                    const Expanded(
                      child: Text(
                        'JustBot',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
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
                        child: const Icon(Icons.close_rounded),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: messages.map((msg) => buildMessage(msg)).toList(),
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
