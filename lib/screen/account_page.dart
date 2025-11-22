import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:qlmoney/main.dart'; // for themeNotifier
import 'package:qlmoney/screen/bottom_navigation_bar.dart';
import 'package:qlmoney/screen/edit_account_page.dart';
import 'package:qlmoney/screen/screen_started.dart';
import 'package:qlmoney/widgets/forward_button.dart';
import 'package:qlmoney/widgets/setting_item.dart';
import 'package:qlmoney/widgets/setting_switch.dart';
import 'package:qlmoney/main.dart' show themeNotifier;

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool isDarkMode = false;
  String? _avatarUrl;
  String? _nameUser;
  String? _emailUser;
  late DatabaseReference _userRef;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Load current user data from Firebase Auth and Realtime Database
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _emailUser = user.email;
    _userRef = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(user.uid)
        .child('account');

    try {
      final event = await _userRef.once();
      final snapshot = event.snapshot;
      if (snapshot.value != null && snapshot.value is Map) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          _avatarUrl = data['avatar'] as String?;
          _nameUser = data['name'] as String?;
        });
      } else {
        setState(() {
          _avatarUrl = null;
          _nameUser = null;
        });
      }
    } catch (e) {
      // Handle error
      debugPrint('Error loading user data: $e');
    }
    setState(() {});
  }

  /// Sign out current user
  void _signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            // Navigate back to bottom navigation
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const BottomNavigationPage(),
              ),
            );
          },
          icon: const Icon(Ionicons.chevron_back_outline),
        ),
        leadingWidth: 80,
        title: Text('settings'.tr()),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'account'.tr(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Avatar, Name, Email row
                    Row(
                      children: [
                        _avatarUrl != null
                            ? ClipOval(
                          child: Image.network(
                            _avatarUrl!,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (ctx, obj, stack) => Image.asset(
                              'assets/image/avatar.png',
                              width: 70,
                              height: 70,
                            ),
                          ),
                        )
                            : ClipOval(
                          child: Image.asset(
                            'assets/image/avatar.png',
                            width: 70,
                            height: 70,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _nameUser ?? 'default_name'.tr(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _emailUser ?? 'no_email'.tr(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ForwardButton(
                          ontap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditAccountPage(),
                              ),
                            );
                            if (result != null && result is Map<String, String>) {
                              setState(() {
                                _avatarUrl = result['avatar'];
                                _nameUser = result['name'];
                                _emailUser = result['email'];
                              });
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                    Text(
                      'settings'.tr(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Language toggle
                    SettingItem(
                      title: 'language'.tr(),
                      icon: Ionicons.earth,
                      bgColor: Colors.orange.shade100,
                      iconColor: Colors.orange,
                      value: context.locale.languageCode.toUpperCase(),
                      onTap: () {
                        final newLocale = context.locale.languageCode == 'en'
                            ? const Locale('vi')
                            : const Locale('en');
                        context.setLocale(newLocale);
                      },
                    ),
                    const SizedBox(height: 20),

                    // Notification placeholder
                    SettingItem(
                      title: 'notification'.tr(),
                      icon: Ionicons.notifications,
                      bgColor: Colors.blue.shade100,
                      iconColor: Colors.blue,
                      onTap: () {
                        // TODO: implement notification settings
                      },
                    ),
                    const SizedBox(height: 20),

                    // Dark Mode switch
                    SettingSwitch(
                      title: 'dark_mode'.tr(),
                      icon: Ionicons.moon,
                      bgColor: Colors.purple.shade100,
                      iconColor: Colors.purple,
                      value: isDarkMode,
                      onTap: (value) {
                        setState(() {
                          // Cập nhật state cho switch
                          isDarkMode = value;
                          // Gán themeNotifier ở đây để đổi theme toàn app
                          // themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Help
                    SettingItem(
                      title: 'help'.tr(),
                      icon: Ionicons.help_circle_outline,
                      bgColor: Colors.green.shade100,
                      iconColor: Colors.black,
                      onTap: () {
                        // TODO: navigate to Help page or show dialog
                      },
                    ),
                    const SizedBox(height: 20),

                    // Logout
                    SettingItem(
                      title: 'logout'.tr(),
                      icon: Ionicons.log_out,
                      bgColor: Colors.red.shade100,
                      iconColor: Colors.red,
                      onTap: () {
                        _signUserOut();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SplashScreen(onTap: () {}),
                          ),
                              (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      );
    } catch (e, st) {
      debugPrint('AccountPage build error: $e');
      debugPrint('$st');
      return Scaffold(
        appBar: AppBar(title: Text('settings'.tr())),
        body: Center(child: Text('Đã xảy ra lỗi khi tải trang account: $e')),
      );
    }
  }
}