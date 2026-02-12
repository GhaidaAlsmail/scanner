import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'photos_service.dart';

final addNewsFormGroupProvider = Provider.autoDispose<FormGroup>((ref) {
  return FormGroup({
    'head': FormControl<String>(validators: [Validators.required]),
    'name': FormControl<String>(value: ""),
    'details': FormControl<String>(value: ""),
    'tags': FormControl<List<String>>(value: <String>[]),
    'category': FormControl<String>(value: ""),
  });
});

// هذا المزود هو المسؤول عن استدعاء الدالة وانتظار البيانات
final allPhotosProvider = FutureProvider((ref) {
  final service = ref.watch(photosServicesProvider);
  return service.fetchAllPhotos();
});

var imgFileProvider = StateProvider<File?>((ref) => null);
