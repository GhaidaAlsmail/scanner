import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'dart:convert';
import 'package:flutter/services.dart';

final addNewsFormGroupProvider = Provider.autoDispose<FormGroup>((ref) {
  return FormGroup({
    'head': FormControl<String>(validators: [Validators.required]),
    'id': FormControl<String>(validators: [Validators.required]),
    'name': FormControl<String>(value: "", validators: [Validators.required]),
    'details': FormControl<String>(value: ""),
    'tags': FormControl<List<String>>(value: <String>[]),
    'region': FormControl<String>(validators: [Validators.required]),
    'mainCategory': FormControl<String>(
      validators: [Validators.required],
    ), // حمص المدينة أو الريف
    'subArea': FormControl<String>(validators: [Validators.required]),
    'category': FormControl<String>(value: ""),
  });
});

final selectedImagesListProvider = StateProvider<List<File>>((ref) => []);
var imgFileProvider = StateProvider<File?>((ref) => null);
// المزود المسؤول عن تحميل بيانات المناطق
final areasDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // قراءة الملف من الـ Assets
  final String response = await rootBundle.loadString('assets/data/areas.json');
  final data = await json.decode(response);
  return data as Map<String, dynamic>;
});

// // المزود (Provider)
// final areasDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
//   final String response = await rootBundle.loadString('assets/data/areas.json');
//   return json.decode(response) as Map<String, dynamic>;
// });
