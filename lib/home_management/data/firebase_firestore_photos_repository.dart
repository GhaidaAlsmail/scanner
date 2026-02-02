// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../domain/photos.dart';
import 'firestore_photos_repository.dart';

class FirebaseFirestorePhotosRepository implements FirestorePhotosRepository {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  @override
  Future<String> createPhotos({required Photos photos}) async {
    final doc = _firestore.collection('photos').doc();
    await doc.set(photos.copyWith(id: doc.id).toJson());
    return doc.id;
  }

  @override
  Future<Photos?> readPhotos({required String id}) async {
    final snap = await _firestore.collection('photos').doc(id).get();
    if (!snap.exists) return null;
    return Photos.fromJson(snap.data()!);
  }

  @override
  // Future<String> uploadImage({
  //   required File imageFile,
  //   required String folderPath,
  // }) async {
  //   final ref = _storage.ref('$folderPath/${_uuid.v4()}.jpg');
  //   // await ref.putFile(imageFile);
  //   try {
  //     await ref.putFile(imageFile);
  //   } on FirebaseException catch (e) {
  //     debugPrint('Storage error: ${e.code}');
  //     debugPrint(e.message);
  //     rethrow;
  //   }
  //   return await ref.getDownloadURL();
  // }
  // Future<String> uploadImage({
  //   required File imageFile,
  //   required String folderPath,
  // }) async {
  //   // توليد اسم ملف فريد لمنع تداخل الملفات أو الخطأ 404
  //   String fileName = DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";
  //   // المرجع الصحيح: المجلد + اسم الملف
  //   final ref = FirebaseStorage.instance
  //       .ref()
  //       .child(folderPath)
  //       .child(fileName);
  //   // تنفيذ الرفع
  //   await ref.putFile(imageFile);
  //   // جلب الرابط
  //   return await ref.getDownloadURL();
  // }
  Future<String> uploadImage({
    required File imageFile,
    required String folderPath,
  }) async {
    try {
      // 1. استخراج اسم الملف الأصلي أو توليد اسم فريد
      String fileName =
          "${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}";

      // 2. إنشاء المرجع (تأكد من دمج المجلد مع اسم الملف)
      // folderPath هنا يجب أن يكون 'photos'
      final storageRef = FirebaseStorage.instance
          .ref()
          .child(folderPath)
          .child(fileName);

      // 3. أمر الرفع (استخدم putFile)
      final uploadTask = await storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
        ), // تحديد نوع الملف يساعد السيرفر
      );

      // 4. الحصول على الرابط بعد اكتمال الرفع تماماً
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print("Error in Repository Upload: $e");
      rethrow;
    }
  }

  @override
  Future<List<Photos>> getAllPhotos() async {
    final snap = await _firestore.collection('photos').get();

    return snap.docs.map((doc) => Photos.fromJson(doc.data())).toList();
  }
}
