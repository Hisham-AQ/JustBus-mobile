import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditDateScreen extends StatefulWidget {
  final DateTime? initialDate;

  const EditDateScreen({super.key, this.initialDate});

  @override
  State<EditDateScreen> createState() => _EditDateScreenState();
}

class _EditDateScreenState extends State<EditDateScreen> {
  DateTime? selectedDate;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (selectedDate == null) return;

    setState(() => loading = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({
      'birthDate': Timestamp.fromDate(selectedDate!),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1F4B63);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Date of Birth')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            InkWell(
              onTap: _pickDate,
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primary),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cake_outlined),
                    const SizedBox(width: 12),
                    Text(
                      selectedDate == null
                          ? 'Select date'
                          : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : _save,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
