import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart'; // ستحتاجين لهذه المكتبة لفتح الروابط
import '../../application/photos_service.dart';

class AllDocumentsScreen extends ConsumerWidget {
  const AllDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // سنفترض أنكِ ستقومين بإنشاء provider لجلب المستندات
    // كحل سريع، سنستخدم FutureBuilder مباشرة مع الدالة التي سنكتبها في الخدمة

    return Scaffold(
      appBar: AppBar(title: const Text("المستندات المحفوظة (PDF)")),
      body: FutureBuilder(
        future: ref
            .read(photosServicesProvider)
            .fetchAllDocuments(), // سننشئ هذه الدالة
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("خطأ: ${snapshot.error}"));
          }

          final docs = snapshot.data as List<dynamic>;

          if (docs.isEmpty) {
            return const Center(child: Text("لا توجد مستندات محفوظة"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              return ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text(doc['title'] ?? 'بدون عنوان'),
                subtitle: Text(
                  "التاريخ: ${doc['createdAt'].toString().split('T')[0]}",
                ),
                trailing: const Icon(Icons.open_in_new),
                onTap: () async {
                  // هنا نفتح رابط الملف الموجود على السيرفر
                  final url = "http://192.168.15.3:3006${doc['pdfPath']}";
                  if (!await launchUrl(Uri.parse(url))) {
                    throw 'Could not launch $url';
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
