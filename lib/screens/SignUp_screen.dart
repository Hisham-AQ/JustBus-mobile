import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? selectedGender;
  DateTime? birthDate;
  bool agreeTerms = false;

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF1F4B63);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Sign Up'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create your JustBus account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 24),

              // ================= EMAIL =================
              _inputField(
                controller: emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Email is required';
                  }
                  final email = v.trim();
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (!emailRegex.hasMatch(email)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              // ================= PHONE =================
              _inputField(
                controller: phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 14),

              // ================= PASSWORD =================
              _inputField(
                controller: passwordController,
                label: 'Password',
                icon: Icons.lock_outline,
                obscure: true,
              ),

              const SizedBox(height: 14),

              // ================= CONFIRM =================
              _inputField(
                controller: confirmPasswordController,
                label: 'Confirm Password',
                icon: Icons.lock_outline,
                obscure: true,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (v != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // ================= GENDER =================
              const Text(
                'Gender',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _genderCard(
                      label: 'Male',
                      icon: Icons.male_rounded,
                      selected: selectedGender == 'Male',
                      onTap: () => setState(() => selectedGender = 'Male'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _genderCard(
                      label: 'Female',
                      icon: Icons.female_rounded,
                      selected: selectedGender == 'Female',
                      onTap: () => setState(() => selectedGender = 'Female'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ================= DATE OF BIRTH =================
              const Text(
                'Date of Birth',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: _pickBirthDate,
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black26),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cake_outlined),
                      const SizedBox(width: 12),
                      Text(
                        birthDate == null
                            ? 'Select date'
                            : '${birthDate!.day}/${birthDate!.month}/${birthDate!.year}',
                        style: TextStyle(
                          color:
                              birthDate == null ? Colors.black45 : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= TERMS =================
              CheckboxListTile(
                value: agreeTerms,
                onChanged: (v) => setState(() => agreeTerms = v ?? false),
                title: const Text(
                  'I agree to the Terms & Conditions',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),

              const SizedBox(height: 16),

              // ================= BUTTON =================
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: agreeTerms ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= FOOTER =================
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Already have an account? Login',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HELPERS =================

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator ??
          (String? v) {
            if (v == null || v.isEmpty) {
              return 'Required field';
            }
            return null;
          },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _genderCard({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1F4B63) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black26),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => birthDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedGender == null || birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    // TODO: Firebase / API Sign Up
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = credential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'gender': selectedGender,
        'birthDate': Timestamp.fromDate(birthDate!),
        'walletBalance': 0.0,
        'points': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully')),
      );

      Navigator.pop(context); // go back to login
    } on FirebaseAuthException catch (e) {
      String message = 'Signup failed';

      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
