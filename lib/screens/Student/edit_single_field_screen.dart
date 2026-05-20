import 'package:flutter/material.dart';
import 'package:justbus/services/profile_service.dart';

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

  void _save() async {
    final value = controller.text.trim();
    if (value.isEmpty) return;

    setState(() => loading = true);

    try {
      if (widget.fieldKey == 'phone') {
        await ProfileService.updateProfile(phone: value);
      } else if (widget.fieldKey == 'name') {
        await ProfileService.updateProfile(name: value);
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.green,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    '${widget.title} Updated',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your information has been updated successfully.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F4B63),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
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
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1F4B63);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        scrolledUnderElevation: 0,
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
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: primary.withOpacity(.12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.04),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                keyboardType: widget.keyboardType,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.fieldKey == 'phone'
                      ? 'Enter phone number'
                      : 'Enter your name',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                  ),
                  prefixIcon: Icon(
                    widget.fieldKey == 'phone'
                        ? Icons.phone_rounded
                        : Icons.person_rounded,
                    color: primary,
                  ),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1F4B63),
                        Color(0xFF2D6A8D),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: loading ? null : _save,
                    child: Center(
                      child: loading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                    ),
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
