import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:qlmoney/main.dart';
import 'package:qlmoney/screen/bottom_navigation_bar.dart';
import 'package:qlmoney/screen/edit_account_page.dart';
import 'package:qlmoney/widgets/forward_button.dart';
import 'package:qlmoney/widgets/setting_item.dart';
import 'package:qlmoney/widgets/setting_switch.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool isDrakMode = false;
  String name = "Default Name"; // Tên mặc định
  String email = "example@gmail.com"; // Email mặc định
  String avatarUrl = "assets/image/avatar.png"; // Avatar mặc định

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Tải dữ liệu người dùng từ Firebase
  }

  /// Hàm tải dữ liệu người dùng từ Firebase
  void _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef =
          FirebaseDatabase.instance.ref().child('users').child(user.uid).child('account');
      final snapshot = await userRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          name = data['name'] ?? "Default Name";
          email = data['email'] ?? "example@gmail.com";
          avatarUrl = data['avatar'] ?? "assets/image/avatar.png";
        });
      }
    }
  }

  /// Hàm đăng xuất người dùng
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BottomNavigationPage(),
              ),
            );
          },
          icon: const Icon(Ionicons.chevron_back_outline),
        ),
        leadingWidth: 80,
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
                      tr("Settings"),
                      style: TextStyle(
                        color: Colors.blue.shade300,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      tr("Account"),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundImage: avatarUrl.startsWith('http')
                                ? NetworkImage(avatarUrl)
                                : AssetImage(avatarUrl) as ImageProvider,
                            radius: 35,
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name, // Hiển thị tên người dùng
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                email, // Hiển thị email người dùng
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          ForwardButton(
                            ontap: () async {
                              // Điều hướng đến EditAccountPage và chờ kết quả
                              final updatedData = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EditAccountPage(),
                                ),
                              );

                              // Nếu có dữ liệu trả về, cập nhật giao diện
                              if (updatedData != null && mounted) {
                                setState(() {
                                  name = updatedData['name'] ?? name;
                                  email = updatedData['email'] ?? email;
                                  avatarUrl = updatedData['avatar'] ?? avatarUrl;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      tr("Settings"),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SettingItem(
                      title: tr("language"),
                      icon: Ionicons.earth,
                      bgColor: Colors.orange.shade100,
                      iconColor: Colors.orange,
                      value: context.locale.languageCode == 'en'
                          ? "English"
                          : "Tiếng Việt",
                      onTap: () {
                        setState(() {
                          if (context.locale.languageCode == 'en') {
                            context.setLocale(const Locale('vi'));
                          } else {
                            context.setLocale(const Locale('en'));
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    SettingItem(
                      title: tr("Notification"),
                      icon: Ionicons.notifications,
                      bgColor: Colors.blue.shade100,
                      iconColor: Colors.blue,
                      onTap: () {},
                    ),
                    const SizedBox(height: 20),
                    SettingSwitch(
                      title: tr("Dark_Mode"),
                      icon: Ionicons.moon,
                      bgColor: Colors.purple.shade100,
                      iconColor: Colors.purple,
                      value: isDrakMode,
                      onTap: (value) {
                        setState(() {
                          isDrakMode = value;
                          themeNotifier.value =
                              value ? ThemeMode.dark : ThemeMode.light;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    SettingItem(
                      title: tr("Help"),
                      icon: Ionicons.help_circle_outline,
                      bgColor: Colors.green.shade100,
                      iconColor: Colors.black,
                      onTap: () {},
                    ),
                    const SizedBox(height: 20),
                    SettingItem(
                      title: tr("LogOut"),
                      icon: Ionicons.log_out,
                      bgColor: Colors.red.shade100,
                      iconColor: Colors.red,
                      onTap: () {
                        signUserOut();
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
  }
}