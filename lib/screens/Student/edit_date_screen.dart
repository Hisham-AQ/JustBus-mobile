import 'package:flutter/material.dart';
import 'package:justbus/services/profile_service.dart';

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

    try {
      await ProfileService.updateProfile(
        birthDate: selectedDate!,
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update birth date")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1F4B63);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Date of Birth'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            const Text(
              'Enter your birth date',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 12),

            // ===== DATE FIELD =====
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: primary,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cake_outlined, color: primary),
                    const SizedBox(width: 12),
                    Text(
                      selectedDate == null
                          ? 'Select date'
                          : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // ===== SAVE BUTTON =====
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
