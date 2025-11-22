import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:qlmoney/profile/edit_account_page.dart';
import 'package:qlmoney/screen/remind_page.dart';
import 'package:qlmoney/data/theme_manager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  DatabaseReference? _accountRef;

  String? _name;
  String? _email;
  String? _avatar;
  bool _isDark = false;
  bool _syncEnabled = false;
  late VoidCallback _themeListener;

  @override
  void initState() {
    super.initState();
    // initialize theme state from global notifier
    _isDark = themeNotifier.value == ThemeMode.dark;
    _themeListener = () {
      setState(() {
        _isDark = themeNotifier.value == ThemeMode.dark;
      });
    };
    themeNotifier.addListener(_themeListener);
    if (_currentUser != null) {
      _accountRef = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(_currentUser.uid)
        .child('account');
      _loadAccount();
    }
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_themeListener);
    super.dispose();
  }

  Future<void> _loadAccount() async {
    try {
      if (_accountRef == null) return;
      final snap = await _accountRef!.get();
      if (snap.exists && snap.value is Map) {
        final data = Map<String, dynamic>.from(snap.value as Map);
        setState(() {
          _name = (data['name'] as String?) ?? _currentUser?.displayName ?? 'user'.tr();
          _email = (data['email'] as String?) ?? _currentUser?.email ?? '';
          _avatar = (data['avatar'] as String?) ?? 'assets/image/avatar.png';
        });
      }
    } catch (e) {
      debugPrint('Error loading account in SettingsPage: $e');
    }
  }

  void _openEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditAccountPage()),
    );
    if (result != null && result is Map<String, String>) {
      setState(() {
        _name = result['name'];
        _email = result['email'];
        _avatar = result['avatar'];
      });
    } else {
      // reload in case of other changes
      _loadAccount();
    }
  }


  @override
  Widget build(BuildContext context) {
    try {
      // Helpers to avoid throwing during build
      ImageProvider safeAvatarProvider() {
        try {
          final path = (_avatar != null && _avatar!.isNotEmpty) ? _avatar! : 'assets/image/avatar.png';
          if (path.startsWith('http')) return NetworkImage(path);
          return AssetImage(path) as ImageProvider;
        } catch (_) {
          return const AssetImage('assets/image/avatar.png');
        }
      }
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.maybePop(context),
          ),
          centerTitle: true,
          title: const Text('Cài đặt'),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Profile header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundImage: safeAvatarProvider(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _name ?? 'default_name'.tr(),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(_email ?? '', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _openEdit,
                      child: Text('edit'.tr()),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Settings list
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  children: [
                    // Account Section
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
                      child: Text('Tài khoản', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey)),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Text('👤', style: TextStyle(fontSize: 22)),
                            title: const Text('Thông tin Cá nhân'),
                            subtitle: const Text('Chỉnh sửa tên, email, ảnh đại diện'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: _openEdit,
                          ),
                        ],
                      ),
                    ),

                    // Security Section

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
                      child: Text('Bảo mật & Đăng nhập', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey)),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Text('🔒', style: TextStyle(fontSize: 22)),
                            title: const Text('Bảo mật & Đăng nhập'),
                            subtitle: const Text('Đổi mật khẩu, xác thực 2 yếu tố'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              // TODO: navigate to security page if exists
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mở Bảo mật & Đăng nhập')));
                            },
                          ),
                        ],
                      ),
                    ),

                    // Appearance
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
                      child: Text('Giao diện', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey)),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Column(
                        children: [
                          SwitchListTile(
                            secondary: const Text('🌙', style: TextStyle(fontSize: 22)),
                            title: const Text('Chủ đề'),
                            subtitle: const Text('Chế độ Sáng / Chế độ Tối'),
                            value: _isDark,
                            onChanged: (v) {
                              // update global theme notifier
                              themeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
                              // local state will be updated via listener
                            },
                          ),
                        ],
                      ),
                    ),

                    // Notifications
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
                      child: Text('Thông báo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey)),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: const Text('🔔', style: TextStyle(fontSize: 22)),
                        title: const Text('Thông báo'),
                        subtitle: const Text('Quản lý loại thông báo và âm thanh'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          try {
                            Navigator.pushNamed(context, '/remind');
                          } catch (_) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => RemindPage()));
                          }
                        },
                      ),
                    ),

                    // Data & Sync
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
                      child: Text('Dữ liệu và Đồng bộ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey)),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Column(
                        children: [
                          SwitchListTile(
                            secondary: const Text('🔁', style: TextStyle(fontSize: 22)),
                            title: const Text('Đồng bộ Hóa'),
                            subtitle: const Text('Trạng thái đồng bộ với đám mây'),
                            value: _syncEnabled,
                            onChanged: (v) => setState(() => _syncEnabled = v),
                          ),
                          ListTile(
                            leading: const Text('🗑️', style: TextStyle(fontSize: 22)),
                            title: const Text('Xóa Cache'),
                            subtitle: const Text('Xóa dữ liệu tạm thời để giải phóng dung lượng'),
                            trailing: ElevatedButton(
                              onPressed: () {
                                // perform clear cache (local) action
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cache đã được xóa')));
                              },
                              child: const Text('Xóa'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // General
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
                      child: Text('Tổng quan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey)),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Text('❓', style: TextStyle(fontSize: 22)),
                            title: const Text('Trợ giúp & Phản hồi'),
                            subtitle: const Text('Câu hỏi thường gặp và liên hệ hỗ trợ'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mở Trợ giúp & Phản hồi')));
                            },
                          ),
                          ListTile(
                            leading: const Text('i', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            title: const Text('Về Ứng dụng'),
                            subtitle: const Text('Phiên bản ứng dụng: v1.0.0'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              showAboutDialog(
                                context: context,
                                applicationName: 'QLMoney',
                                applicationVersion: 'v1.0.0',
                                children: [const Text('Ứng dụng quản lý thu chi.')],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Logout button (primary)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                        },
                        child: Text('Đăng xuất'.tr()),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e, st) {
      debugPrint('SettingsPage build error: $e');
      debugPrint('$st');
      return Scaffold(
        appBar: AppBar(title: Text('settings'.tr())),
        body: Center(child: Text('Đã xảy ra lỗi khi tải trang settings: $e')),
      );
    }
  }
}
