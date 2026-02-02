import 'package:freezed_annotation/freezed_annotation.dart';

part 'photos.freezed.dart';
part 'photos.g.dart';

enum Category { finance, development, healthy, science }

@freezed
abstract class Photos with _$Photos {
  factory Photos({
    String? id,
    required String userId,
    required String title,
    required String details,
    required Category category,
    // required DateTime date,
    required List<String> tags,
    String? profilePictureUrl,
  }) = _Photos;

  factory Photos.fromJson(Map<String, dynamic> json) => _$PhotosFromJson(json);
}
