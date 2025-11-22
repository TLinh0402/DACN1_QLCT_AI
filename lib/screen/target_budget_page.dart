import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TargetBudgetPage extends StatefulWidget {
  const TargetBudgetPage({Key? key}) : super(key: key);

  @override
  State<TargetBudgetPage> createState() => _TargetBudgetPageState();
}

class _TargetBudgetPageState extends State<TargetBudgetPage> {
  List<Map<String, dynamic>> categories = [];
  Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _deleteCategory(String categoryId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Remove category
      await FirebaseDatabase.instance
          .reference()
          .child('users')
          .child(user.uid)
          .child('typecategorys')
          .child(categoryId)
          .remove();

      // Remove budget entry if exists
      await FirebaseDatabase.instance
          .reference()
          .child('users')
          .child(user.uid)
          .child('budgets')
          .child(categoryId)
          .remove();

      // For all transactions with this category_id, set category_id to empty
      DatabaseEvent txs = await FirebaseDatabase.instance
          .reference()
          .child('users')
          .child(user.uid)
          .child('khoanthuchi')
          .orderByChild('category_id')
          .equalTo(categoryId)
          .once();

      if (txs.snapshot.value != null) {
        final map = txs.snapshot.value as Map<dynamic, dynamic>;
        for (var entry in map.entries) {
          final key = entry.key as String;
          await FirebaseDatabase.instance
              .reference()
              .child('users')
              .child(user.uid)
              .child('khoanthuchi')
              .child(key)
              .update({'category_id': ''});
        }
      }
    } catch (e) {
      debugPrint('Error deleting category: $e');
    }
  }

  Future<void> _loadCategories() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      DatabaseEvent snapshot = await FirebaseDatabase.instance
          .reference()
          .child('users')
          .child(user.uid)
          .child('typecategorys')
          .once();

      final map = snapshot.snapshot.value as Map<dynamic, dynamic>?;
      if (map != null) {
        categories = [];
        for (var entry in map.entries) {
          final k = entry.key as String;
          final v = entry.value as Map<dynamic, dynamic>;
          if ((v['name'] ?? '') != 'Lương') {
            categories.add({'id': k, 'name': v['name']});
          }
        }

        // Load existing budgets
        for (var c in categories) {
          final catId = c['id'] as String;
          DatabaseEvent b = await FirebaseDatabase.instance
              .reference()
              .child('users')
              .child(user.uid)
              .child('budgets')
              .child(catId)
              .once();
          String value = '';
          if (b.snapshot.value != null) {
            final bm = b.snapshot.value as Map<dynamic, dynamic>;
            value = bm['limit']?.toString() ?? '';
          }
          controllers[catId] = TextEditingController(text: value);
        }

        setState(() {});
      }
    } catch (e) {
      debugPrint('Error loading categories/budgets: $e');
    }
  }

  Future<void> _saveBudget(String categoryId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final controller = controllers[categoryId];
    if (controller == null) return;
    final text = controller.text.trim();
    if (text.isEmpty) return;

    final double? limit = double.tryParse(text);
    if (limit == null) return;

    try {
      await FirebaseDatabase.instance
          .reference()
          .child('users')
          .child(user.uid)
          .child('budgets')
          .child(categoryId)
          .set({
        'id': categoryId,
        'category_id': categoryId,
        'limit': limit,
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lưu ngân sách thành công')));
    } catch (e) {
      debugPrint('Error saving budget: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Lưu thất bại')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ngân sách mục tiêu')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: categories.isEmpty
            ? const Center(child: Text('Không có danh mục'))
            : ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final id = cat['id'] as String;
                  final name = cat['name'] as String;
                  controllers.putIfAbsent(id, () => TextEditingController());
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Expanded(child: Text(name)),
                          SizedBox(
                            width: 120,
                            child: TextField(
                              controller: controllers[id],
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Limit',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.save),
                            onPressed: () => _saveBudget(id),
                          )
                          ,
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Xóa danh mục?'),
                                  content: const Text('Bạn có chắc muốn xóa danh mục này? Các giao dịch liên quan sẽ bị gán category trống.'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Huỷ')),
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Xóa')),
                                  ],
                                ),
                              ) ?? false;

                              if (confirm) {
                                await _deleteCategory(id);
                                await _loadCategories();
                                setState(() {});
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
