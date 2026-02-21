import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../application/photos_service.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:scanner/core/presentation/widgets/get_base_url.dart';

class AllDocumentsScreen extends ConsumerStatefulWidget {
  const AllDocumentsScreen({super.key});

  @override
  ConsumerState<AllDocumentsScreen> createState() => _AllDocumentsScreenState();
}

class _AllDocumentsScreenState extends ConsumerState<AllDocumentsScreen> {
  // متغير لتسهيل تحديث الصفحة بعد الحذف
  late Future<List<dynamic>> _docsFuture;

  @override
  void initState() {
    super.initState();
    _refreshDocs();
  }

  void _refreshDocs() {
    setState(() {
      _docsFuture = ref.read(photosServicesProvider).fetchAllDocuments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("المستندات المحفوظة (PDF)"),
        actions: [
          IconButton(onPressed: _refreshDocs, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder(
        future: _docsFuture,
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
              final String docId = doc['_id']; // تأكدي أن المعرف يأتي بـ _id

              return ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text(doc['title'] ?? 'بدون عنوان'),
                subtitle: Text(
                  "التاريخ: ${doc['createdAt'].toString().split('T')[0]}",
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min, // مهم جداً داخل ListTile
                  children: [
                    // أيقونة الفتح
                    IconButton(
                      icon: const Icon(Icons.open_in_new, color: Colors.blue),
                      onPressed: () => _openPdf(doc['pdfPath']),
                    ),
                    // أيقونة الحذف
                    // IconButton(
                    //   icon: const Icon(
                    //     Icons.delete_forever,
                    //     color: Colors.redAccent,
                    //   ),
                    //   onPressed: () =>
                    //       _confirmDelete(docId, doc['title'] ?? 'المستند'),
                    // ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  //  دالة فتح الملف

  Future<void> _openPdf(String? path) async {
    if (path == null) return;

    try {
      // 1. جلب الـ Base URL الديناميكي الذي أدخله المستخدم
      String baseUrl = await getDynamicBaseUrl();

      String domain = baseUrl.replaceAll('/api', '');

      // 3. دمج الدومين مع مسار الملف
      final url = "$domain$path";

      debugPrint("Opening PDF from: $url"); // للتأكد من الرابط في الـ Console

      if (!await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      )) {
        BotToast.showText(text: "تعذر فتح الملف");
      }
    } catch (e) {
      debugPrint("Error opening PDF: $e");
      BotToast.showText(text: "خطأ في الرابط المبرمج");
    }
  }

  // دالة تأكيد الحذف
  void _confirmDelete(String id, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: Text("هل أنت متأكد من حذف مستند '$title' نهائياً؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // إغلاق الديالوج
              _deleteDoc(id);
            },
            child: const Text(
              "حذف الآن",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // دالة استدعاء خدمة الحذف
  Future<void> _deleteDoc(String id) async {
    try {
      BotToast.showLoading();
      await ref.read(photosServicesProvider).deleteDocument(id);
      BotToast.closeAllLoading();
      BotToast.showText(text: "تم الحذف بنجاح");
      _refreshDocs(); // تحديث القائمة فوراً
    } catch (e) {
      BotToast.closeAllLoading();
      BotToast.showText(text: "فشل الحذف: $e");
    }
  }
}
