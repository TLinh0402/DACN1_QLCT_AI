import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({super.key});

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref().child('users');
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    if (_currentUser != null) {
      final snapshot = await _databaseRef.child(_currentUser!.uid).get();
      if (snapshot.exists) {
        final data = snapshot.value as Map;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _ageController.text = data['age']?.toString() ?? '';
          _phoneController.text = data['phone'] ?? '';
          _emailController.text = data['email'] ?? _currentUser!.email!;
        });
      }
    }
  }

  void _updateUserData() async {
    if (_currentUser != null) {
      await _databaseRef.child(_currentUser!.uid).update({
        'name': _nameController.text,
        'age': int.tryParse(_ageController.text) ?? 0,
        'phone': _phoneController.text,
        'email': _emailController.text,
      });

      // Cập nhật email trong Firebase Auth nếu thay đổi
      if (_emailController.text != _currentUser!.email) {
        await _currentUser!.updateEmail(_emailController.text);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User information updated successfully!')),
      );

      Navigator.pop(context); // Quay lại trang trước
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUserData,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}