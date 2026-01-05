import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditSingleFieldScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final String fieldKey;
  final String initialValue;
  final TextInputType keyboardType;

  const EditSingleFieldScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.fieldKey,
    required this.initialValue,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<EditSingleFieldScreen> createState() => _EditSingleFieldScreenState();
}

class _EditSingleFieldScreenState extends State<EditSingleFieldScreen> {
  late TextEditingController controller;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialValue);
  }

  Future<void> _save() async {
    setState(() => loading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      widget.fieldKey: controller.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    setState(() => loading = false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF1F4B63);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              widget.subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: primary, width: 1.5),
              ),
              child: TextField(
                controller: controller,
                keyboardType: widget.keyboardType,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
