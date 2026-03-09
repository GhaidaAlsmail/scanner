// ignore_for_file: curly_braces_in_flow_control_structures, depend_on_referenced_packages, unnecessary_import

import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/presentation/widgets/get_base_url.dart';
import '../application/add_photos_provider.dart';
import 'package:printing/printing.dart';

// --- (1) مزود نسبة الرفع لتحديث الواجهة بسلاسة ---
final uploadProgressProvider = StateProvider<int>((ref) => 0);

// --- (2) مزود الخدمة الرئيسي ---
final photosServicesProvider = Provider((ref) => PhotosServices(Dio(), ref));

class PhotosServices {
  final ImagePicker _picker = ImagePicker();
  final Dio _dio;
  final Ref ref; // نحتاج الـ Ref لتحديث الـ Provider

  PhotosServices(this._dio, this.ref);

  // التقاط الصور
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

  // ----------------------------- الرفع بالجودة الكاملة (صور كقائمة) ------------------------------------
  Future<void> uploadImagesAsList({
    required List<File> imageFiles,
    required String docTitle,
    required String region,
    required String subArea,
    required String id,
  }) async {
    try {
      BotToast.showLoading();
      final baseUrl = await getDynamicBaseUrl();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // تصفير النسبة عند البدء
      ref.read(uploadProgressProvider.notifier).state = 0;

      List<MultipartFile> multipartImages = [];
      for (File file in imageFiles) {
        multipartImages.add(
          await MultipartFile.fromFile(
            file.path,
            filename: path.basename(file.path),
          ),
        );
      }

      FormData formData = FormData.fromMap({
        "title": docTitle,
        "region": region,
        "subArea": subArea,
        "id": id,
        "images": multipartImages,
      });

      final response = await _dio.post(
        '$baseUrl/documents/upload-images-to-pdf',
        data: formData,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
          sendTimeout: const Duration(minutes: 10),
        ),
        onSendProgress: (sent, total) {
          if (total != -1) {
            int progress = ((sent / total) * 100).toInt();
            ref.read(uploadProgressProvider.notifier).state = progress;

            // تحديث رسالة BotToast بدون تكرار (Spam)
            BotToast.showText(
              text: "جاري رفع الصور الأصلية: $progress%",
              align: Alignment.center,
              onlyOne: true,
              duration: const Duration(milliseconds: 800),
            );
          }
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        BotToast.showText(text: " تم الرفع.. جاري تنظيف الذاكرة المؤقتة");

        for (File file in imageFiles) {
          try {
            if (await file.exists()) await file.delete();
          } catch (e) {
            debugPrint(" تعذر حذف ملف مؤقت: $e");
          }
        }
        BotToast.closeAllLoading();
        BotToast.showText(text: " تم الحفظ بنجاح وتوفير المساحة");
        ref.read(uploadProgressProvider.notifier).state = 0;
      }
    } catch (e) {
      BotToast.closeAllLoading();
      BotToast.showText(text: " فشل الرفع: تأكدي من الإنترنت");
      rethrow;
    }
  }

  // ----------------------------- الطباعة ------------------------------------
  Future<void> printRemotePdf(String relativePath, String title) async {
    try {
      BotToast.showLoading();
      final baseUrl = await getDynamicBaseUrl();
      String domain = baseUrl.replaceAll('/api', '');
      if (domain.endsWith('/')) domain = domain.substring(0, domain.length - 1);

      final String fullUrl = "$domain/$relativePath".replaceAll('\\', '/');
      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode == 200) {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => response.bodyBytes,
          name: title,
        );
      } else {
        throw Exception("فشل تحميل الملف");
      }
    } catch (e) {
      BotToast.showText(text: "خطأ في الطباعة: ${e.toString()}");
    } finally {
      BotToast.closeAllLoading();
    }
  }

  // جلب المستندات
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
      return response.data;
    } catch (e) {
      throw Exception("فشل تحميل البيانات");
    }
  }

  // حذف مستند
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

  // ----------------------------- التعديل (Update) ------------------------------------
  Future<void> updateDocumentFile({
    required String docId,
    File? newFile,
    required String newTitle,
    required String region,
    required String subArea,
  }) async {
    try {
      BotToast.showLoading();
      final baseUrl = await getDynamicBaseUrl();
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      FormData formData = FormData.fromMap({
        "title": newTitle,
        "region": region,
        "subArea": subArea,
        if (newFile != null)
          "pdf": await MultipartFile.fromFile(
            newFile.path,
            filename: "$newTitle.pdf",
            contentType: DioMediaType.parse("application/pdf"),
          ),
      });

      final response = await _dio.put(
        '$baseUrl/documents/update-pdf/$docId',
        data: formData,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
          sendTimeout: const Duration(minutes: 5),
        ),
        onSendProgress: (sent, total) {
          if (newFile != null && total != -1) {
            int progress = ((sent / total) * 100).toInt();
            BotToast.showText(
              text: "جاري تحديث الملف الأصلي: $progress%",
              align: Alignment.center,
              onlyOne: true,
            );
          }
        },
      );

      BotToast.closeAllLoading();
      if (response.statusCode == 200) {
        BotToast.showText(text: " تم تحديث البيانات بنجاح");
      }
    } catch (e) {
      BotToast.closeAllLoading();
      BotToast.showText(text: " خطأ في التحديث");
      rethrow;
    }
  }

  // عرض قائمة اختيار الصور
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
}
