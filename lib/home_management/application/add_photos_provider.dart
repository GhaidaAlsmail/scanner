import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:reactive_forms/reactive_forms.dart';

final addNewsFormGroupProvider = Provider.autoDispose<FormGroup>((ref) {
  return FormGroup({
    'head': FormControl<String>(validators: [Validators.required]),
    'name': FormControl<String>(value: "", validators: [Validators.required]),
    'details': FormControl<String>(value: ""),
    'tags': FormControl<List<String>>(value: <String>[]),
    'region': FormControl<String>(validators: [Validators.required]),
    'category': FormControl<String>(value: ""),
  });
});

final selectedImagesListProvider = StateProvider<List<File>>((ref) => []);
var imgFileProvider = StateProvider<File?>((ref) => null);
