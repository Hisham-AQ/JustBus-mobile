import 'package:flutter/material.dart';
import '../../services/lostItems_service.dart';

class ReportLostItemScreen extends StatefulWidget {
  const ReportLostItemScreen({super.key});

  @override
  State<ReportLostItemScreen> createState() => _ReportLostItemScreenState();
}

class _ReportLostItemScreenState extends State<ReportLostItemScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController itemController = TextEditingController();
  final TextEditingController rideController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String selectedCategory = 'Wallet';
  DateTime? lostDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Lost Item'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Item Category',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _categoryCard(
                      icon: Icons.account_balance_wallet_rounded,
                      title: "Wallet",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _categoryCard(
                      icon: Icons.phone_iphone_rounded,
                      title: "Phone",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _categoryCard(
                      icon: Icons.work_outline_rounded,
                      title: "Bag",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _categoryCard(
                      icon: Icons.inventory_2_outlined,
                      title: "Other",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _field(
                label: 'Lost Item Name',
                hint: 'e.g. Black Leather Wallet',
                controller: itemController,
              ),

              _field(
                label: 'Ride ID (optional)',
                hint: 'Enter your ride number',
                controller: rideController,
                required: false,
              ),

              const Text(
                'Lost Date',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: _inputDecoration(),
                  child: Text(
                    lostDate == null
                        ? 'Select date'
                        : '${lostDate!.day}/${lostDate!.month}/${lostDate!.year}',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _field(
                label: 'Description',
                hint: 'Color, brand, additional details',
                controller: descriptionController,
                maxLines: 4,
              ),

              // Upload Image
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () {
                    //Image picker
                  },
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Upload Item Image'),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text(
                    'Submit Report',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Our support team will contact you if the item is found.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => lostDate = date);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (lostDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select lost date')),
      );
      return;
    }

    try {
      await LostItemsService.submitReport(
        category: selectedCategory,
        itemName: itemController.text,
        rideId: rideController.text,
        date:
            "${lostDate!.year}-${lostDate!.month.toString().padLeft(2, '0')}-${lostDate!.day.toString().padLeft(2, '0')}",
        description: descriptionController.text,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      print("ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: (v) {
              if (!required) return null;
              return v == null || v.isEmpty ? 'This field is required' : null;
            },
            decoration: _inputDecoration(hint: hint),
          ),
        ],
      ),
    );
  }

  Widget _categoryCard({
    required IconData icon,
    required String title,
  }) {
    final bool isSelected = selectedCategory == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = title;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 180,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1F4B63) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFF1F4B63) : Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: isSelected ? Colors.white : Colors.black87,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }
}
