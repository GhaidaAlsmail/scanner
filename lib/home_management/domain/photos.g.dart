// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Photos _$PhotosFromJson(Map<String, dynamic> json) => _Photos(
  id: json['id'] as String?,
  userId: json['userId'] as String,
  title: json['title'] as String,
  details: json['details'] as String,
  category: $enumDecode(_$CategoryEnumMap, json['category']),
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  profilePictureUrl: json['profilePictureUrl'] as String?,
);

Map<String, dynamic> _$PhotosToJson(_Photos instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'title': instance.title,
  'details': instance.details,
  'category': _$CategoryEnumMap[instance.category]!,
  'tags': instance.tags,
  'profilePictureUrl': instance.profilePictureUrl,
};

const _$CategoryEnumMap = {
  Category.finance: 'finance',
  Category.development: 'development',
  Category.healthy: 'healthy',
  Category.science: 'science',
};
