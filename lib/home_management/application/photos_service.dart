// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/presentation/widgets/get_base_url.dart';
import '../application/add_photos_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

final photosServicesProvider = Provider((ref) => PhotosServices(Dio()));

class PhotosServices {
  final ImagePicker _picker = ImagePicker();
  final Dio _dio;

  PhotosServices(this._dio);

  // 1. التقاط الصور (كاميرا أو معرض) وإضافتها للقائمة
  Future<void> _pickImage(ImageSource source, WidgetRef ref) async {
    try {
      if (source == ImageSource.camera) {
        List<String>? pictures = await CunningDocumentScanner.getPictures();
        if (pictures != null && pictures.isNotEmpty) {
          final currentImages = ref.read(selectedImagesListProvider);
          ref.read(selectedImagesListProvider.notifier).state = [
            ...currentImages,
            ...pictures.map((path) => File(path)),
          ];
        }
      } else {
        final XFile? pickedFile = await _picker.pickImage(source: source);
        if (pickedFile != null) {
          final currentImages = ref.read(selectedImagesListProvider);
          ref.read(selectedImagesListProvider.notifier).state = [
            ...currentImages,
            File(pickedFile.path),
          ];
        }
      }
    } catch (e) {
      BotToast.showText(text: "تعذر التقاط الصور");
    }
  }

  //----------------------------------------------------------------------------//
  Future<void> generateAndUploadPdfFromFiles({
    required List<File> imageFiles,
    required String docTitle,
    required String region,
  }) async {
    try {
      final baseUrl = await getDynamicBaseUrl();
      final prefs = await SharedPreferences.getInstance();

      // جلب التوكن والتأكد من وجوده
      final String? token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception("انتهت صلاحية الجلسة، يرجى إعادة تسجيل الدخول");
      }

      // 1. إنشاء مستند PDF
      final pdf = pw.Document();

      for (var file in imageFiles) {
        if (await file.exists()) {
          final image = pw.MemoryImage(file.readAsBytesSync());
          //   pdf.addPage(
          //     pw.Page(
          //       // استخدام تنسيق A3 مع هوامش بسيطة
          //       pageFormat: PdfPageFormat.a3,
          //       build: (pw.Context context) {
          //         return pw.FullPage(
          //           ignoreMargins: true,
          //           child: pw.Center(
          //             child: pw.Image(image, fit: pw.BoxFit.contain, dpi: 300),
          //           ),
          //         );
          //       },
          //     ),
          //   );
          pdf.addPage(
            pw.Page(
              // تحديد القياس A3 للمصنفات الكبيرة
              pageFormat: PdfPageFormat.a3,
              build: (pw.Context context) {
                return pw.FullPage(
                  ignoreMargins: true, // إلغاء الحواف لاستغلال المساحة كاملة
                  child: pw.Center(
                    child: pw.Image(
                      image,
                      fit: pw.BoxFit.contain, // يضمن ظهور المصنف كاملاً دون قص
                      dpi: 400, // رفع الكثافة النقطية لأن الورقة كبيرة (A3)
                    ),
                  ),
                );
              },
            ),
          );
        }
      }

      // 2. حفظ الملف في المجلد المؤقت للجهاز
      final tempDir = await getTemporaryDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final tempFile = File("${tempDir.path}/pdf_$timestamp.pdf");
      await tempFile.writeAsBytes(await pdf.save());

      // 3. تجهيز FormData
      // ملاحظة: تأكدي أن أسماء الحقول (title, region, pdf) تطابق ما يتوقعه السيرفر
      FormData formData = FormData.fromMap({
        "title": docTitle,
        "region": region,
        "pdf": await MultipartFile.fromFile(
          tempFile.path,
          filename: "$docTitle.pdf",
        ),
      });

      // 4. إرسال الطلب مع ترويسة المصادقة
      final response = await _dio.post(
        '$baseUrl/documents/upload-pdf',
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token", // مفتاح حل مشكلة الـ 401
            "Accept": "application/json",
          },
          // منع Dio من رمي Exception تلقائياً في حالات الـ 401 للتعامل معها يدوياً
          validateStatus: (status) => status! < 500,
        ),
      );

      debugPrint("Server Status Code: ${response.statusCode}");
      debugPrint("Server Response Body: ${response.data}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint("تم الرفع بنجاح للمنطقة: $region");
        // تنظيف الملف المؤقت
        if (await tempFile.exists()) await tempFile.delete();
      } else if (response.statusCode == 401) {
        throw Exception("غير مصرح لك بالعملية، يرجى تسجيل الدخول مجدداً");
      } else {
        throw Exception(
          "فشل الرفع: ${response.data['message'] ?? 'خطأ غير معروف'}",
        );
      }
    } on DioException catch (e) {
      debugPrint("Dio Error Type: ${e.type}");
      debugPrint("Dio Error Response: ${e.response?.data}");
      throw Exception("خطأ في الاتصال بالسيرفر: ${e.message}");
    } catch (e) {
      debugPrint("General Error: $e");
      rethrow;
    }
  }

  //----------------------------------------------------------------------------//
  // 3. إظهار خيارات التقاط الصورة
  Future<void> showImagePicker(BuildContext context, WidgetRef ref) async {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('المعرض (Gallery)'),
                onTap: () {
                  _pickImage(ImageSource.gallery, ref);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('الكاميرا (Camera)'),
                onTap: () {
                  _pickImage(ImageSource.camera, ref);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
  //----------------------------------------------------------------------------//
  // 4. جلب المستندات
  // photos_service.dart

  Future<Map<String, dynamic>> fetchDocuments({required int page}) async {
    try {
      final baseUrl = await getDynamicBaseUrl();
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      final response = await _dio.get(
        '$baseUrl/documents/all',
        queryParameters: {'page': page, 'limit': 10},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return response.data; // يحتوي على القائمة والميتا (meta)
    } catch (e) {
      throw Exception("فشل تحميل البيانات: $e");
    }
  }
  //----------------------------------------------------------------------------//

  // 5. حذف مستند
  Future<void> deleteDocument(String id) async {
    try {
      final baseUrl = await getDynamicBaseUrl();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      await _dio.delete(
        '$baseUrl/documents/$id',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
    } catch (e) {
      throw Exception("خطأ في حذف المستند");
    }
  }
}

//----------------------------------------------------------------------------//
// void _openPdf(String pdfPath, String title) {
//   String fullUrl = "$baseUrl/${pdfPath.replaceAll('\\', '/')}";

//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => Scaffold(
//         appBar: AppBar(title: Text(title)),
//         body: SfPdfViewer.network(
//           fullUrl,
//           headers: {"Authorization": "Bearer $token"}, // إذا كان المجلد محمياً
//         ),
//       ),
//     ),
//   );
// }
