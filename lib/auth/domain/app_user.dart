// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
abstract class AppUser with _$AppUser {
  factory AppUser({
    @JsonKey(name: '_id') String? id, // هنا لربط _id بـ id
    required String name,
    required String email,
    @Default(false) bool isAdmin,
    String? city,
    String? notes,
    // String? password,
    @JsonKey(includeToJson: false) String? password,
    DateTime? birthDate,
    String? profilePictureUrl,
    List<String>? nickNames,
    String? phone,
    @Default(0) int stars,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}
