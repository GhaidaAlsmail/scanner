// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/presentation/widgets/rich_text_widget.dart';
import '../../translation.dart';
import '../data/firestore_photos_repository.dart';
import '../data/photos_repository_provider.dart';
import '../domain/photos.dart';
import 'add_photos_provider.dart';

part 'photos_services.g.dart';

@riverpod
PhotosServices photosServices(Ref ref) {
  return PhotosServices(
    firestorePhotosRepository: ref.read(firestorePhotosRepositoryProvider),
    ref: ref,
  );
}

class PhotosServices {
  final FirestorePhotosRepository firestorePhotosRepository;
  final Ref ref;

  PhotosServices({required this.firestorePhotosRepository, required this.ref});

  Future<Photos?> createAndGetPhotos({required Photos photos}) async {
    final id = await firestorePhotosRepository.createPhotos(photos: photos);

    return firestorePhotosRepository.readPhotos(id: id);
  }

  void showImagePicker(BuildContext context, WidgetRef ref) {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      builder: (_) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Camera'),
              onTap: () async {
                final pickedFile = await picker.pickImage(
                  source: ImageSource.camera,
                );

                if (pickedFile != null) {
                  ref.read(imgFileProvider.notifier).state = File(
                    pickedFile.path,
                  );
                }
                context.pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Gallery'),
              onTap: () async {
                final pickedFile = await picker.pickImage(
                  source: ImageSource.gallery,
                );

                if (pickedFile != null) {
                  ref.read(imgFileProvider.notifier).state = File(
                    pickedFile.path,
                  );
                }
                context.pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove),
              title: Text('Remove Picture'.i18n),
              onTap: () {
                ref.read(imgFileProvider.notifier).state = null;
                context.pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Future<void> createPhoto({required FormGroup form}) async {
  //   try {
  //     BotToast.showLoading();

  //     final imageFile = ref.read(imgFileProvider);
  //     String? imageUrl;

  //     if (imageFile != null) {
  //       imageUrl = await firestorePhotosRepository.uploadImage(
  //         imageFile: imageFile,
  //         folderPath: 'photos',
  //       );
  //     }

  //     final photo = Photos(
  //       userId: ref.read(authNotifierProvider)!.id!,
  //       title: form.control('head').value,
  //       details: ref
  //           .read(richTextProvider)
  //           .document
  //           .toDelta()
  //           .toJson()
  //           .toString(),
  //       category: Category.values.firstWhere(
  //         (e) => e.name == form.control('category').value,
  //       ),
  //       // date: DateTime.now(),
  //       profilePictureUrl: imageUrl,
  //       tags: List<String>.from(form.control('tags').value),
  //     );

  //     await firestorePhotosRepository.createPhotos(photos: photo);

  //     BotToast.showNotification(
  //       title: (_) => Text('Photo added'.i18n),
  //       subtitle: (_) => const Text('✅'),
  //     );
  //   } catch (e, s) {
  //     debugPrint(e.toString());
  //     debugPrintStack(stackTrace: s);
  //     BotToast.showText(text: 'Something went wrong'.i18n);
  //   } finally {
  //     BotToast.closeAllLoading();
  //   }
  // }

  Future<void> createPhoto({required FormGroup form}) async {
    try {
      BotToast.showLoading();

      // // 1. تحقق من وجود المستخدم لتجنب الـ Crash
      // final currentUser = ref.read(authNotifierProvider);
      // if (currentUser == null || currentUser.id == null) {
      //   BotToast.showText(text: "يجب تسجيل الدخول أولاً");
      //   return;
      // }

      final imageFile = ref.read(imgFileProvider);
      String? imageUrl;

      if (imageFile != null) {
        // نصيحة: تأكد أن دالة uploadImage داخل الـ Repository
        // تضيف اسماً فريداً للملف مثل: DateTime.now().toString()
        imageUrl = await firestorePhotosRepository.uploadImage(
          imageFile: imageFile,
          folderPath: 'photos/${'3'}', // تنظيم الصور حسب المستخدم
          // folderPath: 'photos/${currentUser.id}', // تنظيم الصور حسب المستخدم
        );
      }

      final photo = Photos(
        // userId: currentUser.id!, // استخدام المتغير الذي تحققنا منه
        userId: '3', // استخدام المتغير الذي تحققنا منه
        title: form.control('head').value,
        details: ref
            .read(richTextProvider)
            .document
            .toDelta()
            .toJson()
            .toString(),
        category: Category.values.firstWhere(
          (e) => e.name == form.control('category').value,
          orElse: () => Category.values.first, // حماية في حال لم يجد الفئة
        ),
        profilePictureUrl: imageUrl,
        tags: List<String>.from(form.control('tags').value ?? []),
      );

      await firestorePhotosRepository.createPhotos(photos: photo);

      BotToast.showNotification(
        title: (_) => Text('Photo added'.i18n),
        subtitle: (_) => const Text('✅'),
      );

      // اختيارياً: تصفير الصورة بعد النجاح
      ref.read(imgFileProvider.notifier).state = null;
    } catch (e, s) {
      debugPrint("Detailed Error: $e");
      debugPrintStack(stackTrace: s);
      BotToast.showText(text: 'Something went wrong'.i18n);
    } finally {
      BotToast.closeAllLoading();
    }
  }
}
