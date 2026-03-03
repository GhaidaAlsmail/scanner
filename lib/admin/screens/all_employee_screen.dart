// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../auth/application/auth_notifier_provider.dart';
import '../../auth/application/auth_service.dart' show authServiceProvider;

class ManageEmployeesScreen extends ConsumerStatefulWidget {
  const ManageEmployeesScreen({super.key});

  @override
  ConsumerState<ManageEmployeesScreen> createState() =>
      _ManageEmployeesScreenState();
}

class _ManageEmployeesScreenState extends ConsumerState<ManageEmployeesScreen> {
  List<dynamic> employees = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    try {
      final data = await ref.read(authServiceProvider).getAllEmployees();
      setState(() {
        employees = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      BotToast.showText(text: "خطأ في جلب الموظفين");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إدارة الموظفين")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchEmployees,
              child: ListView.builder(
                itemCount: employees.length,
                itemBuilder: (context, index) {
                  final emp = employees[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(
                        emp['name'] ?? 'بدون اسم',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("اسم المستخدم: ${emp['username']}"),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () => _showEditDialog(emp),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  void _showEditDialog(dynamic employee) {
    // إضافة Controller للاسم الكامل
    final nameController = TextEditingController(text: employee['name']);
    final userController = TextEditingController(text: employee['username']);
    final passController = TextEditingController();

    final currentUser = ref.read(authNotifierProvider);
    // final String? currentUsername = currentUser?.name;
    final String? currentUsername = currentUser?.username;
    const String superAdminUsername = "manager";
    bool isUserAdmin = employee['isAdmin'] ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("تعديل بيانات الموظف"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "الاسم الكامل",
                    prefixIcon: Icon(Icons.badge),
                  ),
                ),
                const Gap(10),
                TextField(
                  controller: userController,
                  decoration: const InputDecoration(
                    labelText: "اسم المستخدم",
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                ),
                const Gap(10),
                TextField(
                  controller: passController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "كلمة المرور الجديدة",
                    helperText: "اتركها فارغة لعدم التغيير",
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const Gap(20),

                if (currentUsername == superAdminUsername) ...[
                  const Divider(),
                  SwitchListTile(
                    title: const Text("صلاحية مشرف (Admin)"),
                    value: isUserAdmin,
                    onChanged: (val) => setDialogState(() => isUserAdmin = val),
                  ),
                ] else ...[
                  const Text(
                    "تغيير الصلاحيات متاح فقط للمدير العام",
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (passController.text.isNotEmpty &&
                    passController.text.length < 6) {
                  BotToast.showText(text: "كلمة المرور قصيرة");
                  return;
                }
                await _updateEmployee(
                  employee['_id'],
                  nameController.text,
                  userController.text,
                  passController.text,
                  isUserAdmin,
                );
                Navigator.pop(context);
              },
              child: const Text("حفظ"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateEmployee(
    String id,
    String newName,
    String newUsername,
    String newPassword,
    bool isAdmin,
  ) async {
    try {
      BotToast.showLoading();
      await ref
          .read(authServiceProvider)
          .updateEmployee(
            userId: id,
            newName: newName,
            newUsername: newUsername,
            newPassword: newPassword.isEmpty ? null : newPassword,
            isAdmin: isAdmin,
          );
      BotToast.closeAllLoading();
      BotToast.showText(text: "تم التحديث بنجاح");
      _fetchEmployees();
    } catch (e) {
      BotToast.closeAllLoading();
      BotToast.showText(text: "خطأ: $e");
    }
  }
}
