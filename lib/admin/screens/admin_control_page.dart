// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:scanner/translation.dart';
import '../../../auth/application/auth_notifier_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authNotifierProvider);
    final String userName = currentUser?.name ?? "المدير";

    return Scaffold(
      appBar: AppBar(title: Text("لوحة تحكم المدير".i18n), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${"مرحباً".i18n} $userName",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Gap(10),
            Text(
              "يمكنك إدارة الموظفين أو تعديل الوثائق المؤرشفة من هنا.".i18n,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const Gap(30),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildAdminCard(
                    context,
                    title: "إضافة موظف".i18n,
                    icon: Icons.person_add_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () => context.push('/add-employee'),
                  ),
                  _buildAdminCard(
                    context,
                    title: "إدارة الملفات".i18n,
                    icon: Icons.edit_document,
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () => context.push('/manage-documents'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const Gap(15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
