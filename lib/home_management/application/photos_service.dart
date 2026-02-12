import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/domain/app_user.dart';
import '../../core/presentation/widgets/get_base_url.dart';
import '../application/add_photos_provider.dart'; // تأكدي من المسار الصحيح

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

  Future<List<AppUser>> fetchAllPhotos() async {
    final baseUrl = await getDynamicBaseUrl(); // الآن أصبحت مرئية هنا

    try {
      final response = await _dio.get('$baseUrl/photos/all');

      if (response.statusCode == 200) {
        // نصل لمكان المصفوفة حسب تصميم السيرفر الخاص بكِ
        List data = response.data['photos'] ?? [];
        return data.map((json) => AppUser.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception("فشل تحميل الصور: $e");
    }
  }

  /// دالة التقاط الصورة وتحديث الـ Provider
  Future<void> _pickImage(ImageSource source, WidgetRef ref) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // لتقليل حجم الصورة قبل رفعها للسيرفر
      );

      if (pickedFile != null) {
        // تحديث الـ Provider بالملف الجديد
        // ملاحظة: تأكدي أن imgFileProvider هو StateProvider<File?>
        ref.read(imgFileProvider.notifier).state = File(pickedFile.path);
      }
    } catch (e) {
      debugPrint("خطأ أثناء التقاط الصورة: $e");
    }
  }
}
