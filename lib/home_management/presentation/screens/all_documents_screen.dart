import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../auth/application/auth_notifier_provider.dart';
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
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> documents = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasNextPage = true;
  String? userRole;

  // متغيرات التصفية والبحث
  String? selectedRegion;
  String? selectedSubArea;
  String searchQuery = "";
  bool isSearching = false;

  // نصوص ثابتة لمعالجة القيم الفارغة
  static const String undefinedRegion = "تصنيف غير محدد";
  static const String undefinedSubArea = "منطقة غير محددة";

  @override
  void initState() {
    super.initState();
    _getUserRole();
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

  Future<void> _getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => userRole = prefs.getString('role'));
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

  void _goBack() {
    setState(() {
      if (selectedSubArea != null) {
        selectedSubArea = null;
      } else if (selectedRegion != null) {
        selectedRegion = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider);
    final bool isAdmin = user?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "ابحث بالعنوان أو المعرف...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() => searchQuery = val),
              )
            : Text(selectedSubArea ?? selectedRegion ?? "الأرشيف الرئيسي"),
        leading: isSearching
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    isSearching = false;
                    searchQuery = "";
                    _searchController.clear();
                  });
                },
              )
            : (selectedRegion != null
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _goBack,
                    )
                  : null),
        actions: [
          if (!isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => isSearching = true),
            ),
        ],
      ),
      body: _buildMainContent(isAdmin),
    );
  }

  Widget _buildMainContent(bool isAdmin) {
    if (documents.isEmpty && !isLoading) {
      return const Center(child: Text("لا توجد مستندات بعد"));
    }

    // 1. منطق البحث الشامل
    if (searchQuery.isNotEmpty) {
      final results = documents.where((doc) {
        final title = (doc['title'] ?? '').toString().toLowerCase();
        final id = (doc['id'] ?? '').toString();
        return title.contains(searchQuery.toLowerCase()) ||
            id.contains(searchQuery);
      }).toList();
      return _buildFilesList(results, isAdmin, isSearchMode: true);
    }

    // 2. منطق المجلدات المستوى الأول (Regions)
    if (selectedRegion == null) {
      final regions = documents
          .map((e) => e['region']?.toString() ?? undefinedRegion)
          .toSet()
          .toList();

      return _buildFolderList(
        regions,
        Icons.folder_shared,
        const Color.fromARGB(255, 237, 201, 122),
        (val) => setState(() => selectedRegion = val),
      );
    }

    // 3. منطق المجلدات المستوى الثاني (SubAreas)
    if (selectedSubArea == null) {
      final subAreas = documents
          .where(
            (e) =>
                (e['region']?.toString() ?? undefinedRegion) == selectedRegion,
          )
          .map((e) => e['subArea']?.toString() ?? undefinedSubArea)
          .toSet()
          .toList();

      return _buildFolderList(
        subAreas,
        Icons.folder_copy, // أيقونة مختلفة قليلاً للتميز
        Theme.of(context).colorScheme.primary,
        (val) => setState(() => selectedSubArea = val),
      );
    }

    // 4. عرض الملفات النهائية بعد اختيار المنطقة والمنطقة الفرعية
    final filteredDocs = documents.where((e) {
      final docRegion = e['region']?.toString() ?? undefinedRegion;
      final docSubArea = e['subArea']?.toString() ?? undefinedSubArea;
      return docRegion == selectedRegion && docSubArea == selectedSubArea;
    }).toList();

    return _buildFilesList(filteredDocs, isAdmin);
  }

  // ويدجت عرض المجلدات
  Widget _buildFolderList(
    List<String> items,
    IconData icon,
    Color color,
    Function(String) onTap,
  ) {
    if (items.isEmpty) return const Center(child: Text("المجلد فارغ"));
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: ListTile(
          leading: Icon(icon, color: color, size: 35),
          title: Text(
            items[index],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () => onTap(items[index]),
        ),
      ),
    );
  }

  // ويدجت عرض الملفات
  Widget _buildFilesList(
    List<dynamic> docs,
    bool isAdmin, {
    bool isSearchMode = false,
  }) {
    if (docs.isEmpty) return const Center(child: Text("لا توجد ملفات"));

    return RefreshIndicator(
      onRefresh: _refreshDocuments,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: isSearchMode
            ? null
            : _scrollController, // تجنب تعارض السكرول عند البحث
        itemCount: docs.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == docs.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final doc = docs[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: Icon(
                Icons.picture_as_pdf,
                color: Colors.red.shade700,
                size: 40,
              ),
              title: Text(
                doc['title'] ?? 'بدون عنوان',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                isSearchMode
                    ? "المسار: ${doc['region'] ?? '؟'} > ${doc['subArea'] ?? '؟'}\nالمعرف: ${doc['id']}"
                    : "المعرف: ${doc['id']} | ${doc['createdAt']?.toString().substring(0, 10) ?? ''}",
                style: const TextStyle(fontSize: 12),
              ),
              trailing: isAdmin
                  ? _buildAdminActions(doc)
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // يظهر للكل
                        IconButton(
                          icon: const Icon(
                            Icons.print,
                            color: Colors.blueGrey,
                            size: 20,
                          ),
                          onPressed: () => ref
                              .read(photosServicesProvider)
                              .printRemotePdf(
                                doc['pdfPath'],
                                doc['title'] ?? 'مستند',
                              ),
                        ),
                      ],
                    ),
              onTap: () => _openPdf(doc['pdfPath']),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdminActions(dynamic doc) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.edit_note,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () async {
            await context.push('/edit-document', extra: doc);
            _refreshDocuments();
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.delete_forever,
            color: Color.fromARGB(255, 26, 102, 29),
          ),
          onPressed: () => _confirmDelete(doc['_id'], doc['title']),
        ),
        // --- زر الطباعة الجديد ---
        IconButton(
          icon: const Icon(Icons.print, color: Colors.blueGrey),
          tooltip: 'طباعة المستند',
          onPressed: () {
            // التأكد من وجود مسار للملف قبل استدعاء الطباعة
            if (doc['pdfPath'] != null &&
                doc['pdfPath'].toString().isNotEmpty) {
              ref
                  .read(photosServicesProvider)
                  .printRemotePdf(doc['pdfPath'], doc['title'] ?? 'مستند_مالي');
            } else {
              BotToast.showText(text: "ملف الـ PDF غير متوفر لهذا المستند");
            }
          },
        ),
      ],
    );
  }

  // --- الدوال الخدمية ---
  Future<void> _openPdf(String? path) async {
    if (path == null || path.isEmpty) return;

    try {
      String baseUrl = await getDynamicBaseUrl();
      String domain = baseUrl.replaceAll('/api', '');
      if (domain.endsWith('/')) domain = domain.substring(0, domain.length - 1);

      String cleanPath = path.replaceAll('\\', '/');
      if (!cleanPath.startsWith('/')) cleanPath = '/$cleanPath';

      final String fullUrl = "$domain$cleanPath";

      await ScreenProtector.preventScreenshotOn();

      if (await canLaunchUrl(Uri.parse(fullUrl))) {
        await launchUrl(
          Uri.parse(fullUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      BotToast.showText(text: "تعذر فتح المستند");
    }
  }

  void _confirmDelete(String id, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: Text("هل أنت متأكد من حذف '$title'؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _deleteDoc(id);
            },
            child: const Text("حذف", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshDocuments() async {
    setState(() {
      documents.clear();
      currentPage = 1;
      hasNextPage = true;
    });
    await _loadMore();
  }

  Future<void> _deleteDoc(String id) async {
    try {
      BotToast.showLoading();
      await ref.read(photosServicesProvider).deleteDocument(id);
      BotToast.closeAllLoading();
      setState(() => documents.removeWhere((doc) => doc['_id'] == id));
      BotToast.showText(text: "تم الحذف بنجاح");
    } catch (e) {
      BotToast.closeAllLoading();
      BotToast.showText(text: "فشل الحذف");
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
