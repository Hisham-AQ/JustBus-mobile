import 'package:flutter/material.dart';
import '../../services/driver_service.dart';

class DriverReportScreen extends StatefulWidget {
  const DriverReportScreen({super.key});

  @override
  State<DriverReportScreen> createState() => _DriverReportScreenState();
}

class _DriverReportScreenState extends State<DriverReportScreen> {
  static const Color primary = Color(0xFF1F4B63);

  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController seatController = TextEditingController();

  final TextEditingController nameController = TextEditingController();

  final List<String> categories = [
    "Smoking",
    "Violence",
    "Harassment",
    "Noise",
    "Seat Damage",
    "Fare Issue",
  ];

  String selectedCategory = "Smoking";
  String selectedSeverity = "low";

  bool isSubmitting = false;

  Future<void> _submit() async {
    if (seatController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Description required"),
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      await DriverService.reportMisconduct(
        seatNumber: seatController.text.trim(),
        passengerName: nameController.text.trim().isEmpty
            ? null
            : nameController.text.trim(),
        category: selectedCategory,
        severity: selectedSeverity,
        description: descriptionController.text.trim(),
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.green.shade100,
                    child: const Icon(
                      Icons.check_rounded,
                      size: 42,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "Report Submitted",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "The misconduct report has been sent successfully.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Done",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to submit"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  Widget _severityChip(String value) {
    final selected = selectedSeverity == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedSeverity = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: selected ? primary : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              value.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    seatController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Report Misconduct",
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.report_problem_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Driver Incident Report",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Submit misconduct or passenger issues to administration.",
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // BOOKING ID
            const Text(
              "Seat Number *",
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),
            
            const Text(
              "Passenger Name (Optional)",
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Example: Ahmad",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: seatController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Example: 12",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // CATEGORY
            const Text(
              "Category",
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  items: categories.map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() {
                      selectedCategory = v!;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 18),

            // SEVERITY
            const Text(
              "Severity",
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                _severityChip("low"),
                const SizedBox(width: 8),
                _severityChip("medium"),
                const SizedBox(width: 8),
                _severityChip("high"),
              ],
            ),

            const SizedBox(height: 20),

            // DESCRIPTION
            const Text(
              "Description",
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: descriptionController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "Describe the incident in detail...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // SUBMIT
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isSubmitting ? null : _submit,
                icon: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                      ),
                label: Text(
                  isSubmitting ? "Submitting..." : "Submit Report",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
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
