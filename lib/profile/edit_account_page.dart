import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:qlmoney/screen/target_budget_page.dart';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({Key? key}) : super(key: key);

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _avatarUrl = 'assets/image/avatar.png';

  DatabaseReference? _accountRef;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (_currentUser != null) {
      _accountRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(_currentUser.uid)
          .child('account');
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    try {
      if (_accountRef == null) return;
      final snapshot = await _accountRef!.get();
      if (snapshot.exists && snapshot.value is Map) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          _nameController.text = data['name'] ?? '';
          _emailController.text = data['email'] ?? _currentUser?.email ?? '';
          _avatarUrl = data['avatar'] ?? _avatarUrl;
        });
      }
    } catch (e) {
      debugPrint('Error loading account data: $e');
    }
  }

  Future<void> _saveChanges() async {
    if (_currentUser == null || _accountRef == null) return;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    try {
      await _accountRef!.update({
        'name': name,
        'email': email,
        'avatar': _avatarUrl,
      });

      if (email != _currentUser.email) {
        await _currentUser.updateEmail(email);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('user_updated_success'))),
      );

      Navigator.pop(context, {
        'name': name,
        'email': email,
        'avatar': _avatarUrl,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('update_failed'))),
      );
      debugPrint('Error saving account data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('edit_account')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: _avatarUrl.startsWith('http')
                  ? NetworkImage(_avatarUrl)
                  : AssetImage(_avatarUrl) as ImageProvider,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: tr('name_label')),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: tr('email_label')),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveChanges,
                child: Text(tr('save_changes')),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TargetBudgetPage()),
                  );
                },
                child: const Text('Ngân sách mục tiêu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}