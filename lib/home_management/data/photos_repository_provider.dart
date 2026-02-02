import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/photos.dart';
import 'firebase_firestore_photos_repository.dart';
import 'firestore_photos_repository.dart';

final firestorePhotosRepositoryProvider = Provider<FirestorePhotosRepository>(
  (ref) => FirebaseFirestorePhotosRepository(),
);

final allPhotosProvider = FutureProvider<List<Photos>>((ref) async {
  final repo = ref.read(firestorePhotosRepositoryProvider);
  return repo.getAllPhotos();
});
