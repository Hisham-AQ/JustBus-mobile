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
  String? selectedAvatar;

  final List<String> avatars = [
    'REMOVE_AVATAR',
    'assets/avatars/trAlex.png',
    'assets/avatars/trCathy.png',
    'assets/avatars/trChad.png',
    'assets/avatars/trChelsea.png',
    'assets/avatars/trEnrique.png',
    'assets/avatars/trEric.png',
    'assets/avatars/trFelix.png',
    'assets/avatars/trFranklin.png',
    'assets/avatars/trHarry.png',
    'assets/avatars/trHelen.png',
    'assets/avatars/trIggy.png',
    'assets/avatars/trImran.png',
    'assets/avatars/trMaria.png',
    'assets/avatars/trNancy.png',
    'assets/avatars/trRachel.png',
    'assets/avatars/trSamantha.png',
    'assets/avatars/trShamila.png',
    'assets/avatars/trSophia.png',
    'assets/avatars/trStu.png',
    'assets/avatars/trTorsten.png',
  ];

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
        titleSpacing: 0,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
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
          final avatar = data['avatar'];
          currentAvatar = avatar;

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
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 34,
                              backgroundColor: Colors.white,
                              child: ((selectedAvatar ?? avatar) != null &&
                                      (selectedAvatar ?? avatar)
                                          .toString()
                                          .isNotEmpty)
                                  ? ClipOval(
                                      child: Image.asset(
                                        selectedAvatar ?? avatar,
                                        width: 58,
                                        height: 58,
                                        fit: BoxFit.contain,
                                      ),
                                    )
                                  : Text(
                                      name.isNotEmpty
                                          ? name[0].toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: _showAvatarPicker,
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF1F4B63),
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: Color(0xFF1F4B63),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
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
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Log out',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Are you sure you want to log out from your account?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);

                          await SecureStorage.clear();

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (_) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: const Size(0, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Log out',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String? currentAvatar;

  void _showAvatarPicker() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        String? tempAvatar = selectedAvatar ?? currentAvatar;

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.72,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Choose Avatar',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 20),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: avatars.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                          ),
                          itemBuilder: (_, index) {
                            final avatar = avatars[index];

                            final isRemove = avatar == 'REMOVE_AVATAR';

                            final isSelected = isRemove
                                ? tempAvatar == null
                                : tempAvatar == avatar;

                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  tempAvatar = isRemove ? null : avatar;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF1F4B63)
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 32,
                                  backgroundColor: Colors.grey.shade200,
                                  child: isRemove
                                      ? Icon(
                                          Icons.close_rounded,
                                          size: 34,
                                          color: Colors.red.shade400,
                                        )
                                      : ClipOval(
                                          child: Image.asset(
                                            avatar,
                                            width: 64,
                                            height: 64,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                await ProfileService.updateProfile(
                                  avatar: tempAvatar,
                                );

                                if (tempAvatar != null) {
                                  await SecureStorage.saveAvatar(
                                    tempAvatar!,
                                  );
                                } else {
                                  await SecureStorage.saveAvatar('');
                                }
                                setState(() {
                                  selectedAvatar = tempAvatar;
                                });

                                Navigator.pop(context, true);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString()),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1F4B63),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Save Avatar',
                              style: TextStyle(
                                color: Colors.white,
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
          },
        );
      },
    );
  }
}

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
