import 'package:flutter/material.dart';
import 'package:justbus/services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final oldPass = TextEditingController();
  final newPass = TextEditingController();
  final confirmPass = TextEditingController();

  bool showOld = false;
  bool showNew = false;
  bool showConfirm = false;
  bool loading = false;

  Future<void> _changePassword() async {
    final current = oldPass.text.trim();
    final newPassword = newPass.text.trim();
    final confirm = confirmPass.text.trim();

    if (current.isEmpty || newPassword.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    if (newPassword != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await AuthService.changePassword(
        currentPassword: current,
        newPassword: newPassword,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    oldPass.dispose();
    newPass.dispose();
    confirmPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1F4B63);

    /// ===== PASSWORD FIELD BUILDER =====
    Widget passwordField({
      required String label,
      required String hint,
      required TextEditingController controller,
      required bool visible,
      required VoidCallback toggle,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: primary, width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    obscureText: !visible,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: hint,
                      hintStyle: const TextStyle(
                        color: Colors.black38,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    visible ? Icons.visibility : Icons.visibility_off,
                    color: primary,
                  ),
                  onPressed: toggle,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            passwordField(
              label: 'Current password',
              hint: 'Enter current password',
              controller: oldPass,
              visible: showOld,
              toggle: () => setState(() => showOld = !showOld),
            ),

            const SizedBox(height: 20),

            passwordField(
              label: 'New password',
              hint: 'At least 6 characters',
              controller: newPass,
              visible: showNew,
              toggle: () => setState(() => showNew = !showNew),
            ),

            const SizedBox(height: 20),

            passwordField(
              label: 'Confirm new password',
              hint: 'Re-enter new password',
              controller: confirmPass,
              visible: showConfirm,
              toggle: () => setState(() => showConfirm = !showConfirm),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: loading ? null : _changePassword,
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
