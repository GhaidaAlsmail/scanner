// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'dart:io';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart' as pdfr;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pdf_info;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../core/presentation/widgets/get_base_url.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home_management/application/photos_service.dart';

class EditDocumentScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> doc;
  const EditDocumentScreen({super.key, required this.doc});

  @override
  ConsumerState<EditDocumentScreen> createState() => _EditDocumentScreenState();
}

class _EditDocumentScreenState extends ConsumerState<EditDocumentScreen> {
  List<File> _pagesAsImages = [];
  bool _isExtracting = true;
  int _currentPage = 0;
  int _totalPages = 0;

  // 1. تعريف المتحكم
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    // 2. تهيئة المتحكم بالاسم الحالي للمستند
    _titleController = TextEditingController(text: widget.doc['title'] ?? "");
    _convertPdfToImages();
  }

  @override
  void dispose() {
    // 3. تنظيف المتحكم عند إغلاق الشاشة
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _convertPdfToImages() async {
    try {
      setState(() {
        _isExtracting = true;
        _currentPage = 0;
      });

      String baseUrl = await getDynamicBaseUrl();
      baseUrl = baseUrl.replaceAll('/api', '');

      // 1. الحصول على المسار الخام
      String rawPath = widget.doc['pdfPath'] ?? "";

      // 2. تصحيح الميول (تحويل \ إلى /)
      rawPath = rawPath.replaceAll(r'\', '/');

      // 3. التأكد من البداية بـ /
      if (!rawPath.startsWith('/')) {
        rawPath = '/$rawPath';
      }

      // 4. الدمج والتشفير
      final String fullUrl = Uri.encodeFull("$baseUrl$rawPath");
      debugPrint("Fixed URL: $fullUrl");
      debugPrint("Path from DB: ${widget.doc['pdfPath']}");

      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode != 200) {
        throw Exception("الملف غير موجود (404) - تأكد من المسار على السيرفر");
      }

      // 5. تفكيك الملف باستخدام pdfr
      final document = await pdfr.PdfDocument.openData(response.bodyBytes);
      setState(() {
        _totalPages = document.pagesCount; // تحديد إجمالي عدد الصفحات
      });
      final tempDir = await getTemporaryDirectory();
      List<File> tempFiles = [];
      for (int i = 1; i <= document.pagesCount; i++) {
        final page = await document.getPage(i);

        final pageRender = await page.render(
          width: page.width * 2,
          height: page.height * 2,
          format: pdfr.PdfPageImageFormat.jpeg,
          quality: 90,
        );

        if (pageRender != null) {
          final file = File(
            '${tempDir.path}/page_${DateTime.now().microsecondsSinceEpoch}_$i.jpg',
          );
          await file.writeAsBytes(pageRender.bytes);
          tempFiles.add(file);
        }

        await page.close();

        // إضافة استراحة قصيرة كل 10 صفحات للسماح للنظام بتنظيف الذاكرة أثناء التفكيك
        if (i % 10 == 0) {
          await Future.delayed(const Duration(milliseconds: 50));
        }
      }
      // for (int i = 1; i <= document.pagesCount; i++) {
      //   final page = await document.getPage(i);
      //   final pageRender = await page.render(
      //     width: page.width * 3, // دقة عالية
      //     height: page.height * 3,
      //     format: pdfr.PdfPageImageFormat.jpeg,
      //     quality: 100,
      //   );

      //   if (pageRender != null) {
      //     final file = File(
      //       '${tempDir.path}/page_${DateTime.now().microsecondsSinceEpoch}_$i.jpg',
      //     );
      //     await file.writeAsBytes(pageRender.bytes);
      //     tempFiles.add(file);
      //   }
      //   await page.close();
      // }

      setState(() {
        _pagesAsImages = tempFiles;
        _isExtracting = false;
      });

      await document.close();
    } catch (e) {
      setState(() => _isExtracting = false);
      debugPrint("Extraction Error: $e");
      BotToast.showText(text: "خطأ في تفكيك الملف: $e");
    }
  }

  Future<void> _saveNewPdf() async {
    if (_pagesAsImages.isEmpty) {
      BotToast.showText(text: "لا يمكن حفظ مستند فارغ");
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      BotToast.showText(text: "يرجى إدخال اسم للمستند");
      return;
    }

    try {
      BotToast.showLoading();
      final pdf = pw.Document();

      // معالجة الصور واحدة تلو الأخرى لمنع انفجار الرام
      for (int i = 0; i < _pagesAsImages.length; i++) {
        final imageFile = _pagesAsImages[i];

        // 1. قراءة الملف بشكل مباشر (Stream-like)
        final imageBytes = await imageFile.readAsBytes();
        final image = pw.MemoryImage(imageBytes);

        // 2. إضافة الصفحة للـ PDF
        pdf.addPage(
          pw.Page(
            pageFormat: pdf_info.PdfPageFormat.a4,
            build: (pw.Context context) => pw.FullPage(
              ignoreMargins: true,
              child: pw.Image(image, fit: pw.BoxFit.contain),
            ),
          ),
        );

        // 3. تحرير الذاكرة: ننتظر قليلاً كل 5 صور ليعيد النظام تنظيم الرام
        if (i % 5 == 0) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }

      final tempDir = await getTemporaryDirectory();
      final file = File(
        "${tempDir.path}/updated_doc_${DateTime.now().millisecondsSinceEpoch}.pdf",
      );

      // حفظ الملف النهائي
      await file.writeAsBytes(await pdf.save());

      // الرفع للسيرفر
      await ref
          .read(photosServicesProvider)
          .updateDocumentFile(
            docId: widget.doc['_id'],
            region: widget.doc['region'],
            subArea: widget.doc['subArea'],
            newFile: file,
            newTitle: _titleController.text.trim(),
          );

      BotToast.closeAllLoading();
      BotToast.showText(text: "تم تحديث المستند والاسم بنجاح");
      Navigator.pop(context);
    } catch (e) {
      BotToast.closeAllLoading();
      debugPrint("Save Error: $e");
      BotToast.showText(text: "فشل الحفظ: $e");
    }
  }
  // Future<void> _saveNewPdf() async {
  //   if (_pagesAsImages.isEmpty) {
  //     BotToast.showText(text: "لا يمكن حفظ مستند فارغ");
  //     return;
  //   }

  //   // التحقق من أن الاسم ليس فارغاً
  //   if (_titleController.text.trim().isEmpty) {
  //     BotToast.showText(text: "يرجى إدخال اسم للمستند");
  //     return;
  //   }

  //   try {
  //     BotToast.showLoading();
  //     final pdf = pw.Document();
  //     for (var imageFile in _pagesAsImages) {
  //       final image = pw.MemoryImage(imageFile.readAsBytesSync());
  //       pdf.addPage(
  //         pw.Page(
  //           pageFormat: pdf_info.PdfPageFormat.a4,
  //           build: (pw.Context context) => pw.FullPage(
  //             ignoreMargins: true,
  //             child: pw.Image(image, fit: pw.BoxFit.contain),
  //           ),
  //         ),
  //       );
  //     }

  //     final tempDir = await getTemporaryDirectory();
  //     final file = File(
  //       "${tempDir.path}/updated_doc_${DateTime.now().millisecondsSinceEpoch}.pdf",
  //     );
  //     await file.writeAsBytes(await pdf.save());

  //     // 4. إرسال الاسم الجديد (newTitle) من الـ Controller
  //     await ref
  //         .read(photosServicesProvider)
  //         .updateDocumentFile(
  //           docId: widget.doc['_id'],
  //           region: widget.doc['region'],
  //           subArea: widget.doc['subArea'],
  //           newFile: file,
  //           newTitle: _titleController.text.trim(),
  //         );
  //     // ref.invalidate(photosServicesProvider);
  //     BotToast.closeAllLoading();
  //     BotToast.showText(text: "تم تحديث المستند والاسم بنجاح");
  //     Navigator.pop(context);
  //   } catch (e) {
  //     BotToast.closeAllLoading();
  //     BotToast.showText(text: "فشل الحفظ: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تعديل محتوى المستند"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green, size: 30),
            onPressed: _saveNewPdf,
          ),
        ],
      ),
      body: _isExtracting
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    "جاري تفكيك صفحات المستند...",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  // إظهار الرقم الحالي من الإجمالي
                  Text(
                    "صفحة $_currentPage من $_totalPages",
                    style: TextStyle(color: Colors.blue, fontSize: 18),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // 5. حقل إدخال الاسم الجديد
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: "اسم المستند",
                      hintText: "عدل اسم الملف هنا...",
                      prefixIcon: const Icon(Icons.edit_document),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.05),
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: _pagesAsImages.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _pagesAsImages.length) {
                        return _buildAddPhotoButton();
                      }
                      return _buildImageCard(index);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAddPhotoButton() {
    return InkWell(
      onTap: _addNewPhotoWithScanner,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.primary),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const Text("إضافة صورة"),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            _pagesAsImages[index],
            fit: BoxFit.cover,
            cacheWidth: 400,
          ),
        ),
        // زر الحذف
        Positioned(
          top: 5,
          right: 5,
          child: GestureDetector(
            onTap: () {
              setState(() => _pagesAsImages.removeAt(index));
              _addNewPhotoWithScanner(atIndex: index);
            },
            // onTap: () => setState(() => _pagesAsImages.removeAt(index)),
            child: const CircleAvatar(
              radius: 15,
              backgroundColor: Colors.red,
              child: Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ),
        // زر التبديل
        Positioned(
          bottom: 5,
          right: 5,
          child: GestureDetector(
            onTap: () async {
              // 1. التقاط الصورة الجديدة وتحديد مكانها
              await _addNewPhotoWithScanner(atIndex: index);
              if (_pagesAsImages.length > index + 1) {
                setState(() => _pagesAsImages.removeAt(index + 1));
              }
            },
            child: CircleAvatar(
              radius: 15,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(
                Icons.published_with_changes,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _addNewPhotoWithScanner({int? atIndex}) async {
    try {
      List<String>? pictures = await CunningDocumentScanner.getPictures();

      if (pictures != null && pictures.isNotEmpty) {
        setState(() {
          if (atIndex != null) {
            _pagesAsImages.insertAll(
              atIndex,
              pictures.map((path) => File(path)),
            );
          } else {
            _pagesAsImages.addAll(pictures.map((path) => File(path)));
          }
        });
      }
    } catch (e) {
      BotToast.showText(text: "تعذر التقاط الصور أو تشغيل الماسح");
    }
  }
}
