// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Photos {

 String? get id;@JsonKey(name: 'user') String? get userId;// السيرفر يرسل user
@JsonKey(name: 'head') String? get title;// السيرفر يرسل head
@JsonKey(name: 'path') String? get profilePictureUrl;// السيرفر يرسل path
 String? get details; String? get name;// أضيفي هذا لأنكِ ترسلينه من صفحة الإضافة
 Category? get category;// اجعليه اختيارياً بإضافة ?
 List<String>? get tags;
/// Create a copy of Photos
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotosCopyWith<Photos> get copyWith => _$PhotosCopyWithImpl<Photos>(this as Photos, _$identity);

  /// Serializes this Photos to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Photos&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl)&&(identical(other.details, details) || other.details == details)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.tags, tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,title,profilePictureUrl,details,name,category,const DeepCollectionEquality().hash(tags));

@override
String toString() {
  return 'Photos(id: $id, userId: $userId, title: $title, profilePictureUrl: $profilePictureUrl, details: $details, name: $name, category: $category, tags: $tags)';
}


}

/// @nodoc
abstract mixin class $PhotosCopyWith<$Res>  {
  factory $PhotosCopyWith(Photos value, $Res Function(Photos) _then) = _$PhotosCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'user') String? userId,@JsonKey(name: 'head') String? title,@JsonKey(name: 'path') String? profilePictureUrl, String? details, String? name, Category? category, List<String>? tags
});




}
/// @nodoc
class _$PhotosCopyWithImpl<$Res>
    implements $PhotosCopyWith<$Res> {
  _$PhotosCopyWithImpl(this._self, this._then);

  final Photos _self;
  final $Res Function(Photos) _then;

/// Create a copy of Photos
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? userId = freezed,Object? title = freezed,Object? profilePictureUrl = freezed,Object? details = freezed,Object? name = freezed,Object? category = freezed,Object? tags = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,profilePictureUrl: freezed == profilePictureUrl ? _self.profilePictureUrl : profilePictureUrl // ignore: cast_nullable_to_non_nullable
as String?,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category?,tags: freezed == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [Photos].
extension PhotosPatterns on Photos {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Photos value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Photos() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Photos value)  $default,){
final _that = this;
switch (_that) {
case _Photos():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Photos value)?  $default,){
final _that = this;
switch (_that) {
case _Photos() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'user')  String? userId, @JsonKey(name: 'head')  String? title, @JsonKey(name: 'path')  String? profilePictureUrl,  String? details,  String? name,  Category? category,  List<String>? tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Photos() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.profilePictureUrl,_that.details,_that.name,_that.category,_that.tags);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'user')  String? userId, @JsonKey(name: 'head')  String? title, @JsonKey(name: 'path')  String? profilePictureUrl,  String? details,  String? name,  Category? category,  List<String>? tags)  $default,) {final _that = this;
switch (_that) {
case _Photos():
return $default(_that.id,_that.userId,_that.title,_that.profilePictureUrl,_that.details,_that.name,_that.category,_that.tags);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'user')  String? userId, @JsonKey(name: 'head')  String? title, @JsonKey(name: 'path')  String? profilePictureUrl,  String? details,  String? name,  Category? category,  List<String>? tags)?  $default,) {final _that = this;
switch (_that) {
case _Photos() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.profilePictureUrl,_that.details,_that.name,_that.category,_that.tags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Photos implements Photos {
  const _Photos({this.id, @JsonKey(name: 'user') this.userId, @JsonKey(name: 'head') this.title, @JsonKey(name: 'path') this.profilePictureUrl, this.details, this.name, this.category, final  List<String>? tags}): _tags = tags;
  factory _Photos.fromJson(Map<String, dynamic> json) => _$PhotosFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'user') final  String? userId;
// السيرفر يرسل user
@override@JsonKey(name: 'head') final  String? title;
// السيرفر يرسل head
@override@JsonKey(name: 'path') final  String? profilePictureUrl;
// السيرفر يرسل path
@override final  String? details;
@override final  String? name;
// أضيفي هذا لأنكِ ترسلينه من صفحة الإضافة
@override final  Category? category;
// اجعليه اختيارياً بإضافة ?
 final  List<String>? _tags;
// اجعليه اختيارياً بإضافة ?
@override List<String>? get tags {
  final value = _tags;
  if (value == null) return null;
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of Photos
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotosCopyWith<_Photos> get copyWith => __$PhotosCopyWithImpl<_Photos>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PhotosToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Photos&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl)&&(identical(other.details, details) || other.details == details)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._tags, _tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,title,profilePictureUrl,details,name,category,const DeepCollectionEquality().hash(_tags));

@override
String toString() {
  return 'Photos(id: $id, userId: $userId, title: $title, profilePictureUrl: $profilePictureUrl, details: $details, name: $name, category: $category, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$PhotosCopyWith<$Res> implements $PhotosCopyWith<$Res> {
  factory _$PhotosCopyWith(_Photos value, $Res Function(_Photos) _then) = __$PhotosCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'user') String? userId,@JsonKey(name: 'head') String? title,@JsonKey(name: 'path') String? profilePictureUrl, String? details, String? name, Category? category, List<String>? tags
});




}
/// @nodoc
class __$PhotosCopyWithImpl<$Res>
    implements _$PhotosCopyWith<$Res> {
  __$PhotosCopyWithImpl(this._self, this._then);

  final _Photos _self;
  final $Res Function(_Photos) _then;

/// Create a copy of Photos
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? userId = freezed,Object? title = freezed,Object? profilePictureUrl = freezed,Object? details = freezed,Object? name = freezed,Object? category = freezed,Object? tags = freezed,}) {
  return _then(_Photos(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,profilePictureUrl: freezed == profilePictureUrl ? _self.profilePictureUrl : profilePictureUrl // ignore: cast_nullable_to_non_nullable
as String?,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category?,tags: freezed == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
