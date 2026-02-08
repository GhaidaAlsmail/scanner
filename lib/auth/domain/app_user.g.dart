// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => _AppUser(
  id: json['_id'] as String?,
  name: json['name'] as String,
  email: json['email'] as String,
  isAdmin: json['isAdmin'] as bool? ?? false,
  city: json['city'] as String?,
  notes: json['notes'] as String?,
  password: json['password'] as String?,
  birthDate: json['birthDate'] == null
      ? null
      : DateTime.parse(json['birthDate'] as String),
  profilePictureUrl: json['profilePictureUrl'] as String?,
  nickNames: (json['nickNames'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  phone: json['phone'] as String?,
  stars: (json['stars'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'isAdmin': instance.isAdmin,
  'city': instance.city,
  'notes': instance.notes,
  'birthDate': instance.birthDate?.toIso8601String(),
  'profilePictureUrl': instance.profilePictureUrl,
  'nickNames': instance.nickNames,
  'phone': instance.phone,
  'stars': instance.stars,
};
