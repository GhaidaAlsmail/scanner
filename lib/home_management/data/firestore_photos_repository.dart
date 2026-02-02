import 'dart:io';
import '../domain/photos.dart';

abstract class FirestorePhotosRepository {
  Future<String> createPhotos({required Photos photos});
  Future<Photos?> readPhotos({required String id});
  Future<String> uploadImage({
    required File imageFile,
    required String folderPath,
  });
  Future<List<Photos>> getAllPhotos();
}
