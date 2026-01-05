import 'package:flutter/material.dart';

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
              // Category
              const Text(
                'Item Category',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                items: const [
                  DropdownMenuItem(value: 'Wallet', child: Text('Wallet')),
                  DropdownMenuItem(value: 'Phone', child: Text('Phone')),
                  DropdownMenuItem(value: 'Bag', child: Text('Bag')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => selectedCategory = v!),
                decoration: _inputDecoration(),
              ),
              const SizedBox(height: 16),

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
                    // TODO: Image picker
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (lostDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select lost date')),
        );
        return;
      }

      // API submit
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted successfully')),
      );
      Navigator.pop(context);
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
