import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showIpSettingsDialog(BuildContext context) {
  final TextEditingController ipController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('إعدادات السيرفر'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('أدخل عنوان الـ IP الجديد للسيرفر:'),
            const SizedBox(height: 10),
            TextField(
              controller: ipController,
              decoration: const InputDecoration(
                hintText: 'مثلاً: 192.168.1.5',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (ipController.text.isNotEmpty) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('server_ip', ipController.text.trim());

                BotToast.showText(
                  text: "تم حفظ الـ IP بنجاح: ${ipController.text}",
                );
                Navigator.pop(context);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      );
    },
  );
}
