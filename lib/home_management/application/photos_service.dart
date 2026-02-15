import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/presentation/widgets/get_base_url.dart';
import '../application/add_photos_provider.dart';
import '../domain/photos.dart';

final photosServicesProvider = Provider((ref) => PhotosServices(Dio()));

class PhotosServices {
  final ImagePicker _picker = ImagePicker();
  final Dio _dio;

  PhotosServices(this._dio);

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

  Future<void> _pickImage(ImageSource source, WidgetRef ref) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 50,
      );

      if (pickedFile != null) {
        if (ref.context.mounted) {
          ref.read(imgFileProvider.notifier).state = File(pickedFile.path);
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

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

    // 2. تجهيز البيانات
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
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception("انتهت صلاحية الجلسة (401).");
      }
      throw Exception(e.response?.data['message'] ?? "خطأ في الاتصال بالسيرفر");
    }
  }

  Future<void> uploadPdfToServer(File pdfFile) async {
    final dio = Dio();
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        pdfFile.path,
        filename: 'document.pdf',
      ),
      'title': 'My New PDF',
    });

    await dio.post('http://192.168.15.3:3006/api/upload-pdf', data: formData);
  }
}
