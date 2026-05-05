import 'package:flutter/material.dart';
import 'package:justbus/services/secure_storage.dart';
import 'package:justbus/services/profile_service.dart';
import 'package:justbus/screens/Student/login_screen.dart';
import 'package:justbus/screens/Student/edit_single_field_screen.dart';
import 'package:justbus/screens/Student/edit_date_screen.dart';
import 'package:justbus/screens/Student/change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? avatarUrl;

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
      body: FutureBuilder<Map<String, dynamic>>(
        future: ProfileService.getProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Failed to load profile'));
          }

          final data = snapshot.data!;
          final name = data['name'] ?? '';
          final email = data['email'] ?? '';
          final phone = data['phone'] ?? '';
          final gender = data['gender'] ?? '';
          final birthDate = data['birth_date'] != null
              ? DateTime.parse(data['birth_date'])
              : null;

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1F4B63), Color(0xFF2F6F8F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.white,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name.isNotEmpty ? name : email,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phone,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 12), 

                    _Section(children: [
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
                                subtitle: 'Enter your full name',
                                fieldKey: 'name',
                                initialValue: name,
                              ),
                            ),
                          );
                          if (updated == true) setState(() {});
                        },
                      ),
                      _Item(
                        icon: Icons.phone_outlined,
                        title: 'Phone Number',
                        value: phone,
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
                    ]),
                    _Section(children: [
                      _Item(
                        icon: Icons.cake_outlined,
                        title: 'Date of Birth',
                        value: birthDate == null
                            ? 'Not set'
                            : '${birthDate.day}/${birthDate.month}/${birthDate.year}',
                        onTap: (context) async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditDateScreen(initialDate: birthDate),
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
                    ]),
                    _Section(children: [
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
                    ]),
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
              await SecureStorage.clear();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
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

//INTERNAL UI WIDGETS

class _Section extends StatelessWidget {
  final List<Widget> children;

  const _Section({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final bool isDanger;
  final void Function(BuildContext)? onTap;

  const _Item({
    required this.icon,
    required this.title,
    this.value,
    this.isDanger = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = isDanger ? Colors.red : Colors.black87;

    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDanger
              ? Colors.red.withOpacity(0.1)
              : const Color(0xFF1F4B63).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDanger ? Colors.red : const Color(0xFF1F4B63),
        ),
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
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          if (onTap != null) ...[
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: Colors.black38),
          ],
        ],
      ),
      onTap: onTap == null ? null : () => onTap!(context),
    );
  }
}
