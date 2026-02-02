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

 String? get id; String get userId; String get title; String get details; Category get category;// required DateTime date,
 List<String> get tags; String? get profilePictureUrl;
/// Create a copy of Photos
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotosCopyWith<Photos> get copyWith => _$PhotosCopyWithImpl<Photos>(this as Photos, _$identity);

  /// Serializes this Photos to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Photos&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.details, details) || other.details == details)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,title,details,category,const DeepCollectionEquality().hash(tags),profilePictureUrl);

@override
String toString() {
  return 'Photos(id: $id, userId: $userId, title: $title, details: $details, category: $category, tags: $tags, profilePictureUrl: $profilePictureUrl)';
}


}

/// @nodoc
abstract mixin class $PhotosCopyWith<$Res>  {
  factory $PhotosCopyWith(Photos value, $Res Function(Photos) _then) = _$PhotosCopyWithImpl;
@useResult
$Res call({
 String? id, String userId, String title, String details, Category category, List<String> tags, String? profilePictureUrl
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? userId = null,Object? title = null,Object? details = null,Object? category = null,Object? tags = null,Object? profilePictureUrl = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,profilePictureUrl: freezed == profilePictureUrl ? _self.profilePictureUrl : profilePictureUrl // ignore: cast_nullable_to_non_nullable
as String?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String userId,  String title,  String details,  Category category,  List<String> tags,  String? profilePictureUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Photos() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.details,_that.category,_that.tags,_that.profilePictureUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String userId,  String title,  String details,  Category category,  List<String> tags,  String? profilePictureUrl)  $default,) {final _that = this;
switch (_that) {
case _Photos():
return $default(_that.id,_that.userId,_that.title,_that.details,_that.category,_that.tags,_that.profilePictureUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String userId,  String title,  String details,  Category category,  List<String> tags,  String? profilePictureUrl)?  $default,) {final _that = this;
switch (_that) {
case _Photos() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.details,_that.category,_that.tags,_that.profilePictureUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Photos implements Photos {
   _Photos({this.id, required this.userId, required this.title, required this.details, required this.category, required final  List<String> tags, this.profilePictureUrl}): _tags = tags;
  factory _Photos.fromJson(Map<String, dynamic> json) => _$PhotosFromJson(json);

@override final  String? id;
@override final  String userId;
@override final  String title;
@override final  String details;
@override final  Category category;
// required DateTime date,
 final  List<String> _tags;
// required DateTime date,
@override List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override final  String? profilePictureUrl;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Photos&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.details, details) || other.details == details)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,title,details,category,const DeepCollectionEquality().hash(_tags),profilePictureUrl);

@override
String toString() {
  return 'Photos(id: $id, userId: $userId, title: $title, details: $details, category: $category, tags: $tags, profilePictureUrl: $profilePictureUrl)';
}


}

/// @nodoc
abstract mixin class _$PhotosCopyWith<$Res> implements $PhotosCopyWith<$Res> {
  factory _$PhotosCopyWith(_Photos value, $Res Function(_Photos) _then) = __$PhotosCopyWithImpl;
@override @useResult
$Res call({
 String? id, String userId, String title, String details, Category category, List<String> tags, String? profilePictureUrl
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? userId = null,Object? title = null,Object? details = null,Object? category = null,Object? tags = null,Object? profilePictureUrl = freezed,}) {
  return _then(_Photos(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,profilePictureUrl: freezed == profilePictureUrl ? _self.profilePictureUrl : profilePictureUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
