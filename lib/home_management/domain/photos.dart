// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'photos.freezed.dart';
part 'photos.g.dart';

enum Category { finance, development, healthy, science }

@freezed
abstract class Photos with _$Photos {
  const factory Photos({
    String? id,
    @JsonKey(name: 'user') String? userId,
    @JsonKey(name: 'head') String? title,
    @JsonKey(name: 'path') String? profilePictureUrl,
    String? details,
    String? name,
    Category? category,
    List<String>? tags,
  }) = _Photos;

  factory Photos.fromJson(Map<String, dynamic> json) => _$PhotosFromJson(json);
}
