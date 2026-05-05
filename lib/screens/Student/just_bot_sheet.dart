import 'package:flutter/material.dart';
import '../../services/ai_service.dart';

class JustBotSheet extends StatefulWidget {
  const JustBotSheet({super.key});

  @override
  State<JustBotSheet> createState() => _JustBotSheetState();
}

class _JustBotSheetState extends State<JustBotSheet> {
  final TextEditingController controller = TextEditingController();

  List<Map<String, String>> messages = [];
  bool loading = false;

  Future<void> sendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": text});
      loading = true;
    });

    controller.clear();

    try {
      final data = await AIService.sendMessage(text);

      setState(() {
        messages.add({"role": "bot", "text": data['reply'] ?? ''});
      });

      final trips = List.from(data['trips'] ?? []);

      if (trips.isNotEmpty) {
        setState(() {
          messages
              .add({"role": "bot", "text": "وجدت لك ${trips.length} رحلة 👇"});
        });

      }
    } catch (e) {
      setState(() {
        messages.add({"role": "bot", "text": "Error: $e"});
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Widget buildMessage(Map<String, String> msg) {
    final isUser = msg["role"] == "user";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          msg["text"] ?? "",
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        children: [
          // Header
          const Row(
            children: [
              Icon(Icons.smart_toy_outlined),
              SizedBox(width: 8),
              Text(
                'JustBot',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Messages
          Expanded(
            child: ListView(
              reverse: true,
              children:
                  messages.reversed.map((msg) => buildMessage(msg)).toList(),
            ),
          ),

          if (loading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),

          // Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onSubmitted: (_) => sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'Ask anything...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
