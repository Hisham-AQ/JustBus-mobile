import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:justbus/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<DocumentSnapshot<Map<String, dynamic>>> _loadProfile() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _loadProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Profile not found'));
          }

          final data = snapshot.data!.data()!;
          final email = data['email'] ?? '';
          final phone = data['phone'] ?? '';
          final gender = data['gender'] ?? '';
          final birthDate = (data['birthDate'] as Timestamp).toDate();

          return Column(
            children: [
              // ================= HEADER =================
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 38,
                      backgroundColor: Color(0xFFD9D9D9),
                      child: Text(
                        'U',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phone,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // ================= LIST =================
              Expanded(
                child: ListView(
                  children: [
                    _Section(
                      children: [
                        _Item(
                          icon: Icons.phone_outlined,
                          title: 'Phone Number',
                          value: phone,
                        ),
                        _Item(
                          icon: Icons.email_outlined,
                          title: 'Email',
                          value: email,
                        ),
                      ],
                    ),
                    _Section(
                      children: [
                        _Item(
                          icon: Icons.cake_outlined,
                          title: 'Date of Birth',
                          value:
                              '${birthDate.day}/${birthDate.month}/${birthDate.year}',
                        ),
                        _Item(
                          icon: Icons.male_rounded,
                          title: 'Gender',
                          value: gender,
                        ),
                      ],
                    ),
                    _Section(
                      children: const [
                        _Item(
                          icon: Icons.settings_outlined,
                          title: 'Manage',
                        ),
                        _Item(
                          icon: Icons.notifications_outlined,
                          title: 'Promotional Preferences',
                        ),
                      ],
                    ),
                    _Section(
                      children: [
                        _Item(
                          icon: Icons.logout_rounded,
                          title: 'Log Out',
                          isDanger: true,
                          onTap: _showLogoutDialog,
                        ),
                        _Item(
                          icon: Icons.delete_forever_rounded,
                          title: 'Delete Profile',
                          isDanger: true,
                          onTap: _showDeleteAccountDialog,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= DIALOGS =================

  static void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text(
              'Log out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  static void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Profile'),
        content: const Text(
          'This action is permanent.\nYour account and all data will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= COMPONENTS ================= */

class _Section extends StatelessWidget {
  final List<Widget> children;

  const _Section({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      color: Colors.white,
      child: Column(children: children),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final bool isPlaceholder;
  final bool isDanger;
  final void Function(BuildContext)? onTap;

  const _Item({
    required this.icon,
    required this.title,
    this.value,
    this.isPlaceholder = false,
    this.isDanger = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? Colors.red : Colors.black54;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDanger ? Colors.red : Colors.black87,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(
              value!,
              style: TextStyle(
                fontSize: 13,
                color: isPlaceholder ? Colors.black38 : Colors.black87,
              ),
            ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded, color: Colors.black38),
        ],
      ),
      onTap: onTap == null ? null : () => onTap!(context),
    );
  }
}
