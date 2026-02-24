import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/presentation/widgets/get_base_url.dart'
    show getDynamicBaseUrl;
import '../../application/photos_service.dart';

class AllDocumentsScreen extends ConsumerStatefulWidget {
  const AllDocumentsScreen({super.key});

  @override
  ConsumerState<AllDocumentsScreen> createState() => _AllDocumentsScreenState();
}

class _AllDocumentsScreenState extends ConsumerState<AllDocumentsScreen> {
  final ScrollController _scrollController = ScrollController();
  List<dynamic> documents = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasNextPage = true;
  String? userRole; // لتخزين دور المستخدم (مدير أم لا)

  @override
  void initState() {
    super.initState();
    _getUserRole(); // جلب صلاحيات المستخدم
    _loadMore();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!isLoading && hasNextPage) {
          _loadMore();
        }
      }
    });
  }

  // دالة لجلب صلاحية المستخدم من الجهاز
  Future<void> _getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('role');
    });
  }

  Future<void> _loadMore() async {
    if (isLoading) return;
    setState(() => isLoading = true);
    try {
      final data = await ref
          .read(photosServicesProvider)
          .fetchDocuments(page: currentPage);
      setState(() {
        documents.addAll(data['docs']);
        currentPage++;
        hasNextPage = data['meta']['hasNextPage'];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      BotToast.showText(text: "خطأ في التحميل");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("المستندات المؤرشفة")),
      body: documents.isEmpty && !isLoading
          ? const Center(child: Text("لا توجد مستندات مرفوعة بعد"))
          : ListView.builder(
              controller: _scrollController,
              itemCount: documents.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == documents.length) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final doc = documents[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                      size: 40,
                    ),
                    title: Text(
                      doc['title'] ?? 'بدون عنوان',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "المنطقة: ${doc['region']} \nالتاريخ: ${doc['createdAt'].toString().substring(0, 10)}",
                    ),
                    trailing:
                        userRole ==
                            'admin' // شرط المدير لإظهار زر الحذف
                        ? IconButton(
                            icon: const Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                            ),
                            onPressed: () =>
                                _confirmDelete(doc['_id'], doc['title']),
                          )
                        : const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _openPdf(doc['pdfPath']), // استدعاء دالة الفتح
                  ),
                );
              },
            ),
    );
  }

  // دالة فتح الملف
  Future<void> _openPdf(String? path) async {
    if (path == null || path.isEmpty) {
      BotToast.showText(text: "مسار الملف غير صحيح");
      return;
    }

    try {
      String baseUrl = await getDynamicBaseUrl();
      String domain = baseUrl.replaceAll('/api', '');

      if (domain.endsWith('/')) domain = domain.substring(0, domain.length - 1);

      // تصحيح المسار ليعمل على المتصفح (تبديل الـ backslash بـ forward slash)
      String cleanPath = path.replaceAll('\\', '/');
      if (!cleanPath.startsWith('/')) cleanPath = '/$cleanPath';

      final String fullUrl = "$domain$cleanPath";
      final Uri uri = Uri.parse(Uri.encodeFull(fullUrl));

      debugPrint("Attempting to open: $fullUrl");

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $fullUrl';
      }
    } catch (e) {
      debugPrint("Detailed Error: $e");
      BotToast.showText(text: "تعذر فتح الملف، تأكد من وجود متصفح إنترنت");
    }
  }

  // دالة تأكيد الحذف للمدير
  void _confirmDelete(String id, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text("تأكيد الحذف"),
          ],
        ),
        content: Text(
          "هل أنت متأكد من حذف مستند \n'$title' \nسيتم حذف الملف نهائياً من أرشيف المنطقة.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("إلغاء", style: TextStyle(color: Colors.grey[700])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _deleteDoc(id);
            },
            child: const Text(
              "حذف نهائي",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // دالة الحذف الفعلية
  Future<void> _deleteDoc(String id) async {
    try {
      BotToast.showLoading();
      await ref.read(photosServicesProvider).deleteDocument(id);
      BotToast.closeAllLoading();

      setState(() {
        documents.removeWhere((doc) => doc['_id'] == id);
      });

      BotToast.showText(text: "تم حذف المستند بنجاح");
    } catch (e) {
      BotToast.closeAllLoading();
      BotToast.showText(text: "فشل الحذف: $e");
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
