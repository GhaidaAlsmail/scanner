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
  // final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _convertPdfToImages();
  }

  /// 1. دالة تحميل الـ PDF من السيرفر وتحويل كل صفحة فيه إلى صورة File
  Future<void> _convertPdfToImages() async {
    try {
      setState(() => _isExtracting = true);

      String baseUrl = await getDynamicBaseUrl();
      baseUrl = baseUrl.replaceAll('/api', '');

      // 1. الحصول على المسار الخام
      String rawPath = widget.doc['pdfPath'] ?? "";

      // 2. تصحيح الميول (تحويل \ إلى /) - هذا هو السطر السحري
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

      // String baseUrl = await getDynamicBaseUrl();

      // baseUrl = baseUrl.replaceAll('/api', '');

      // String rawPath = widget.doc['pdfPath'] ?? "";
      // if (!rawPath.startsWith('/')) {
      //   rawPath = '/$rawPath';
      // }

      // final String fullUrl = Uri.encodeFull("$baseUrl$rawPath");
      // debugPrint("Fetching PDF from: $fullUrl");

      // // 4. طلب الملف من السيرفر
      // final response = await http.get(Uri.parse(fullUrl));

      // if (response.statusCode != 200) {
      //   throw Exception("خطأ في السيرفر: ${response.statusCode}");
      // }

      // 5. تفكيك الملف باستخدام pdfr
      final document = await pdfr.PdfDocument.openData(response.bodyBytes);
      final tempDir = await getTemporaryDirectory();
      List<File> tempFiles = [];

      for (int i = 1; i <= document.pagesCount; i++) {
        final page = await document.getPage(i);
        final pageRender = await page.render(
          width: page.width * 3, // دقة عالية
          height: page.height * 3,
          format: pdfr.PdfPageImageFormat.jpeg,
          quality: 100,
        );

        if (pageRender != null) {
          final file = File(
            '${tempDir.path}/page_${DateTime.now().microsecondsSinceEpoch}_$i.jpg',
          );
          await file.writeAsBytes(pageRender.bytes);
          tempFiles.add(file);
        }
        await page.close();
      }

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

  /// 2. دالة فتح الكاميرا لإضافة صورة جديدة للمستند
  // Future<void> _addNewPhoto() async {
  //   final XFile? photo = await _picker.pickImage(
  //     source: ImageSource.camera,
  //     imageQuality: 80,
  //   );
  //   if (photo != null) {
  //     setState(() {
  //       _pagesAsImages.add(File(photo.path));
  //     });
  //   }
  // }

  /// 3. دالة تجميع الصور المتبقية والجديدة في ملف PDF واحد ورفعه
  Future<void> _saveNewPdf() async {
    if (_pagesAsImages.isEmpty) {
      BotToast.showText(text: "لا يمكن حفظ مستند فارغ");
      return;
    }

    try {
      BotToast.showLoading();

      final pdf = pw.Document();
      for (var imageFile in _pagesAsImages) {
        final image = pw.MemoryImage(imageFile.readAsBytesSync());

        pdf.addPage(
          pw.Page(
            pageFormat: pdf_info.PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.FullPage(
                ignoreMargins: true,
                child: pw.Image(image, fit: pw.BoxFit.contain),
              );
            },
          ),
        );
      }

      final tempDir = await getTemporaryDirectory();
      final file = File(
        "${tempDir.path}/updated_doc_${DateTime.now().millisecondsSinceEpoch}.pdf",
      );
      await file.writeAsBytes(await pdf.save());

      // إرسال الملف الجديد للسيرفر عبر الـ Service
      await ref
          .read(photosServicesProvider)
          .updateDocumentFile(
            docId: widget.doc['_id'],
            region: widget.doc['region'],
            subArea: widget.doc['subArea'],
            newFile: file,
            newTitle: widget.doc['title'] ?? "مستند معدل",
          );

      BotToast.closeAllLoading();
      BotToast.showText(text: "تم تحديث المستند بنجاح");
      Navigator.pop(context);
    } catch (e) {
      BotToast.closeAllLoading();
      BotToast.showText(text: "فشل الحفظ: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // ref.read(photosServicesProvider);
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
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("جاري تفكيك المستند إلى صور..."),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _pagesAsImages.length + 1,
              itemBuilder: (context, index) {
                // الخلية الأخيرة لإضافة صورة جديدة
                if (index == _pagesAsImages.length) {
                  return InkWell(
                    onTap: _addNewPhotoWithScanner, // _addNewPhoto,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 40, color: Colors.blue),
                          SizedBox(height: 5),
                          Text(
                            "إضافة صورة",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // عرض صفحات الـ PDF كصور مع زر الحذف
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _pagesAsImages[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _pagesAsImages.removeAt(index));
                        },
                        child: const CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.red,
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Future<void> _addNewPhotoWithScanner() async {
    try {
      // استخدام السكنر لالتقاط صور احترافية
      List<String>? pictures = await CunningDocumentScanner.getPictures();

      if (pictures != null && pictures.isNotEmpty) {
        setState(() {
          // إضافة الصور الملتقطة إلى القائمة المحلية للشاشة
          _pagesAsImages.addAll(pictures.map((path) => File(path)));
        });
      }
    } catch (e) {
      BotToast.showText(text: "تعذر التقاط الصور أو تشغيل الماسح");
    }
  }
}
