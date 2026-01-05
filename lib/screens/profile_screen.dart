//import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_storage/firebase_storage.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:justbus/screens/login_screen.dart';
import 'package:justbus/screens/edit_single_field_screen.dart';
import 'package:justbus/screens/edit_date_screen.dart';
import 'package:justbus/screens/change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> _loadProfile() {
    final uid = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(uid).get();
  }

/*
Future<void> _changeProfileImage() async {
  try {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked == null) return;

    final uid = _auth.currentUser!.uid;

    final ref = FirebaseStorage.instance
        .ref()
        .child('avatars')
        .child('$uid.jpg');

  
    final uploadTask = await ref.putFile(File(picked.path));

    if (uploadTask.state != TaskState.success) {
      throw Exception('Upload failed');
    }

    final url = await ref.getDownloadURL();

    await _firestore.collection('users').doc(uid).update({
      'avatarUrl': url,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    setState(() {});
  } catch (e) {
    debugPrint('Profile image error: $e');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to upload image')),
    );
  }
}
*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
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
          final String name = data['name'] ?? '';
          final String email = data['email'] ?? '';
          final String phone = data['phone'] ?? '';
          final String gender = data['gender'] ?? '';
          final String? avatarUrl = data['avatarUrl'];

          final Timestamp? birthTs = data['birthDate'];
          final DateTime? birthDate = birthTs?.toDate();

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    GestureDetector(
                      //onTap: _changeProfileImage,
                      child: CircleAvatar(
                        radius: 42,
                        backgroundColor: const Color(0xFFD9D9D9),
                        backgroundImage:
                            avatarUrl != null ? NetworkImage(avatarUrl) : null,
                        child: avatarUrl == null
                            ? Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name.isNotEmpty ? name : email,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
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
              Expanded(
                child: ListView(
                  children: [
                    _Section(
                      children: [
                        _Item(
                          icon: Icons.person_outline,
                          title: 'Name',
                          value: name,
                          onTap: (context) async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditSingleFieldScreen(
                                  title: 'Edit Name',
                                  subtitle: 'This is the name you would like other people to use referring to you. \n\nEnter your full name:',
                                  fieldKey: 'name',
                                  initialValue: name,
                                ),
                              ),
                            );

                            if (updated == true) {
                              setState(() {});
                            }
                          },
                        ),
                        _Item(
                          icon: Icons.phone_outlined,
                          title: 'Phone Number',
                          value: phone.isEmpty ? 'Not set' : phone,
                          isPlaceholder: phone.isEmpty,
                          onTap: (context) async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditSingleFieldScreen(
                                  title: 'Edit Phone Number',
                                  subtitle: 'Enter your phone number',
                                  fieldKey: 'phone',
                                  initialValue: phone,
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                            );

                            if (updated == true) setState(() {});
                          },
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
                          value: birthDate == null
                              ? 'Not set'
                              : '${birthDate.day}/${birthDate.month}/${birthDate.year}',
                          isPlaceholder: birthDate == null,
                          onTap: (context) async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditDateScreen(
                                  initialDate: birthDate,
                                ),
                              ),
                            );

                            if (updated == true) setState(() {});
                          },
                        ),
                        _Item(
                          icon: Icons.male_rounded,
                          title: 'Gender',
                          value: gender,
                        ),
                      ],
                    ),
                    _Section(
                      children: [
                        _Item(
                          icon: Icons.lock_outline,
                          title: 'Change Password',
                          onTap: (context) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ChangePasswordScreen(),
                              ),
                            );
                          },
                        ),
                        _Item(
                          icon: Icons.logout_rounded,
                          title: 'Log Out',
                          isDanger: true,
                          onTap: _showLogoutDialog,
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
}

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
    final titleColor = isDanger ? Colors.red : Colors.black87;
    final valueColor = isPlaceholder ? Colors.black38 : Colors.black87;

    return ListTile(
      leading: Icon(
        icon,
        color: isDanger ? Colors.red : Colors.black54,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: titleColor,
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
                color: valueColor,
              ),
            ),
          if (onTap != null) ...[
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.black38,
            ),
          ],
        ],
      ),
      onTap: onTap == null ? null : () => onTap!(context),
    );
  }
}
