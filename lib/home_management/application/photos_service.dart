import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/presentation/widgets/get_base_url.dart';
import '../application/add_photos_provider.dart';
import '../domain/photos.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

final photosServicesProvider = Provider((ref) => PhotosServices(Dio()));

class PhotosServices {
  final ImagePicker _picker = ImagePicker();
  final Dio _dio;

  PhotosServices(this._dio);
  //----------------------------------------------------------------------------//
  /// دالة إظهار خيارات التقاط الصورة
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
  Future<List<Photos>> fetchAllPhotos() async {
    final baseUrl = await getDynamicBaseUrl();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await _dio.get(
        '$baseUrl/photos/all',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        List data = response.data['photos'] ?? [];
        return data.map((json) => Photos.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception("فشل تحميل الصور: $e");
    }
  }

  //----------------------------------------------------------------------------//
  // Future<void> _pickImage(ImageSource source, WidgetRef ref) async {
  //   try {
  //     final XFile? pickedFile = await _picker.pickImage(
  //       source: source,
  //       maxWidth: 800,
  //       imageQuality: 50,
  //     );

  //     if (pickedFile != null) {
  //       if (ref.context.mounted) {
  //         ref.read(imgFileProvider.notifier).state = File(pickedFile.path);
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint("Error picking image: $e");
  //   }
  // }

  Future<void> _pickImage(ImageSource source, WidgetRef ref) async {
    try {
      // إذا كان المصدر هو الكاميرا، نستخدم الماسح الضوئي الذكي
      if (source == ImageSource.camera) {
        List<String>? pictures = await CunningDocumentScanner.getPictures();

        if (pictures != null && pictures.isNotEmpty) {
          // نأخذ أول صورة تم التقاطها (لأن المكتبة تدعم التقاط عدة صور)
          ref.read(imgFileProvider.notifier).state = File(pictures.first);
        }
      }
      // إذا كان المصدر هو المعرض، نبقى على الطريقة القديمة
      else {
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: 800,
          imageQuality: 50,
        );
        if (pickedFile != null) {
          ref.read(imgFileProvider.notifier).state = File(pickedFile.path);
        }
      }
    } catch (e) {
      debugPrint("خطأ في التقاط الصورة أو المسح الضوئي: $e");
      BotToast.showText(text: "تعذر فتح الماسح الضوئي");
    }
  }

  //----------------------------------------------------------------------------//
  /// دالة إرسال الصورة والبيانات للسيرفر
  Future<void> createPhoto({
    required String head,
    required String name,
    required String details,
    required File imageFile,
  }) async {
    final baseUrl = await getDynamicBaseUrl();

    final prefs = await SharedPreferences.getInstance();

    final String? token = prefs.getString('token');

    debugPrint("DEBUG: My Token is -> $token");

    if (token == null || token.isEmpty) {
      throw Exception(
        "لم يتم العثور على مفتاح الدخول، يرجى تسجيل الدخول مجدداً.",
      );
    }

    // تجهيز البيانات
    FormData formData = FormData.fromMap({
      "head": head,
      "name": name,
      "details": details,
      "image": await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ),
    });

    try {
      final response = await _dio.post(
        '$baseUrl/photos/add-photo',
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );

      debugPrint("DEBUG: Server Response -> ${response.data}");
      // BotToast.showText(text: "تم حفظ الصورة بنجاح");
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception("انتهت صلاحية الجلسة (401).");
      }
      throw Exception(e.response?.data['message'] ?? "خطأ في الاتصال بالسيرفر");
    }
  }

  //----------------------------------------------------------------------------//
  Future<void> generateAndUploadPdf({
    required List<String> imageUrls,
    required String docTitle,
  }) async {
    final dio = Dio();

    try {
      // 1. جلب البيانات الأساسية
      final baseUrl = await getDynamicBaseUrl();
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) throw Exception("Session expired");

      // 2. إنشاء ملف PDF في الذاكرة (Memory)
      final pdf = pw.Document();
      for (var url in imageUrls) {
        final response = await dio.get(
          url,
          options: Options(responseType: ResponseType.bytes),
        );
        final image = pw.MemoryImage(response.data);
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) => pw.Center(child: pw.Image(image)),
          ),
        );
      }

      // 3. حفظ الملف في مجلد مؤقت (سيحذف تلقائياً لاحقاً ولن يظهر للمستخدم في المعرض)
      final tempDir = await getTemporaryDirectory();
      //   إضافة .pdf للاسم هنا
      final tempFile = File("${tempDir.path}/$docTitle.pdf");
      await tempFile.writeAsBytes(await pdf.save());

      // 4. تجهيز الـ FormData للرفع
      FormData formData = FormData.fromMap({
        "title": docTitle,
        "pdf": await MultipartFile.fromFile(
          tempFile.path,
          filename: "$docTitle.pdf", // هذا الاسم الذي سيستلمه السيرفر
        ),
      });

      // 5. إرسال الطلب للسيرفر
      final response = await dio.post(
        '$baseUrl/documents/upload-pdf',
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );

      if (response.statusCode == 201) {
        debugPrint(" تم الرفع للسيرفر بنجاح باسم: $docTitle");
        // اختياري: حذف الملف المؤقت فوراً بعد الرفع لزيادة المساحة
        if (await tempFile.exists()) await tempFile.delete();
      }
    } catch (e) {
      debugPrint(" فشل الرفع: $e");
      rethrow;
    }
  }

  //----------------------------------------------------------------------------//
  Future<List<dynamic>> fetchAllDocuments() async {
    final rawBaseUrl = await getDynamicBaseUrl();

    final url = '$rawBaseUrl/documents/all';

    debugPrint(" جاري طلب الرابط: $url");

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.get(
        url,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return [];
    } on DioException catch (e) {
      debugPrint(" خطأ من Dio: ${e.response?.statusCode} - ${e.message}");

      throw Exception("فشل تحميل المستندات: ${e.response?.statusCode}");
    }
  }

  //----------------------------------------------------------------------------//
  Future<void> deletePhoto(String id) async {
    final baseUrl = await getDynamicBaseUrl();

    final url = '$baseUrl/photos/$id';

    debugPrint(" محاولة الحذف بالرابط الصحيح: $url");

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    await _dio.delete(
      url,
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }

  //----------------------------------------------------------------------------//
  /// دالة حذف مستند PDF من السيرفر
  Future<void> deleteDocument(String id) async {
    final baseUrl = await getDynamicBaseUrl();

    final url = '$baseUrl/documents/$id'; //////////////////////

    debugPrint(" جاري حذف المستند بالرابط: $url");

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      await _dio.delete(
        url,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      debugPrint(" تم حذف المستند بنجاح من السيرفر");
    } on DioException catch (e) {
      debugPrint(" فشل حذف المستند: ${e.response?.statusCode}");
      throw Exception(e.response?.data['message'] ?? "خطأ في حذف المستند");
    }
  }
}
