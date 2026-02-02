import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class PhotosRepository {
  final _supabase = Supabase.instance.client;

  Future<String> uploadImage({required File imageFile}) async {
    try {
      // 1. توليد اسم فريد للملف
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'user_photos/$fileName';

      // 2. عملية الرفع إلى الباكت الذي أنشأناه
      await _supabase.storage.from('photos').upload(path, imageFile);

      // 3. الحصول على رابط الصورة المباشر
      final String publicUrl = _supabase.storage
          .from('photos')
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      throw Exception('خطأ في الرفع لـ Supabase: $e');
    }
  }
}
