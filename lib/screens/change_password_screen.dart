import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    final user = FirebaseAuth.instance.currentUser!;
    final email = user.email;

    if (email == null) {
      _show('No email linked to this account');
      return;
    }

    if (oldPass.text.isEmpty) {
      _show('Please enter your current password');
      return;
    }

    if (newPass.text.length < 6) {
      _show('New password must be at least 6 characters');
      return;
    }

    if (newPass.text != confirmPass.text) {
      _show('Passwords do not match');
      return;
    }

    try {
      setState(() => loading = true);

      // 🔐 Re-authenticate with old password
      final credential = EmailAuthProvider.credential(
        email: email,
        password: oldPass.text.trim(),
      );

      await user.reauthenticateWithCredential(credential);

      // 🔄 Update password
      await user.updatePassword(newPass.text.trim());

      if (!mounted) return;
      Navigator.pop(context);
      _show('Password updated successfully');
    } on FirebaseAuthException catch (e) {
      _show(e.message ?? 'Failed to change password');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
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

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🔑 CURRENT PASSWORD
            TextField(
              controller: oldPass,
              obscureText: !showOld,
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    showOld ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => showOld = !showOld);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🆕 NEW PASSWORD
            TextField(
              controller: newPass,
              obscureText: !showNew,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    showNew ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => showNew = !showNew);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ✅ CONFIRM PASSWORD
            TextField(
              controller: confirmPass,
              obscureText: !showConfirm,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    showConfirm ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => showConfirm = !showConfirm);
                  },
                ),
              ),
            ),

            const Spacer(),

            // 💾 SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
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
