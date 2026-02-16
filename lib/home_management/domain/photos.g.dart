// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Photos _$PhotosFromJson(Map<String, dynamic> json) => _Photos(
  id: json['_id'] as String?,
  userId: json['user'] as String?,
  title: json['head'] as String?,
  profilePictureUrl: json['path'] as String?,
  details: json['details'] as String?,
  name: json['name'] as String?,
  category: $enumDecodeNullable(_$CategoryEnumMap, json['category']),
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$PhotosToJson(_Photos instance) => <String, dynamic>{
  '_id': instance.id,
  'user': instance.userId,
  'head': instance.title,
  'path': instance.profilePictureUrl,
  'details': instance.details,
  'name': instance.name,
  'category': _$CategoryEnumMap[instance.category],
  'tags': instance.tags,
};

const _$CategoryEnumMap = {
  Category.finance: 'finance',
  Category.development: 'development',
  Category.healthy: 'healthy',
  Category.science: 'science',
};
