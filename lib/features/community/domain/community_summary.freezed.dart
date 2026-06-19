// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CommunitySummary {

 String get id; String get name; String get city; String? get logoUrl; String get joinCode; String get primaryColor;
/// Create a copy of CommunitySummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunitySummaryCopyWith<CommunitySummary> get copyWith => _$CommunitySummaryCopyWithImpl<CommunitySummary>(this as CommunitySummary, _$identity);

  /// Serializes this CommunitySummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommunitySummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.city, city) || other.city == city)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.joinCode, joinCode) || other.joinCode == joinCode)&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,city,logoUrl,joinCode,primaryColor);

@override
String toString() {
  return 'CommunitySummary(id: $id, name: $name, city: $city, logoUrl: $logoUrl, joinCode: $joinCode, primaryColor: $primaryColor)';
}


}

/// @nodoc
abstract mixin class $CommunitySummaryCopyWith<$Res>  {
  factory $CommunitySummaryCopyWith(CommunitySummary value, $Res Function(CommunitySummary) _then) = _$CommunitySummaryCopyWithImpl;
@useResult
$Res call({
 String id, String name, String city, String? logoUrl, String joinCode, String primaryColor
});




}
/// @nodoc
class _$CommunitySummaryCopyWithImpl<$Res>
    implements $CommunitySummaryCopyWith<$Res> {
  _$CommunitySummaryCopyWithImpl(this._self, this._then);

  final CommunitySummary _self;
  final $Res Function(CommunitySummary) _then;

/// Create a copy of CommunitySummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? city = null,Object? logoUrl = freezed,Object? joinCode = null,Object? primaryColor = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,joinCode: null == joinCode ? _self.joinCode : joinCode // ignore: cast_nullable_to_non_nullable
as String,primaryColor: null == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CommunitySummary].
extension CommunitySummaryPatterns on CommunitySummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommunitySummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommunitySummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommunitySummary value)  $default,){
final _that = this;
switch (_that) {
case _CommunitySummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommunitySummary value)?  $default,){
final _that = this;
switch (_that) {
case _CommunitySummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String city,  String? logoUrl,  String joinCode,  String primaryColor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommunitySummary() when $default != null:
return $default(_that.id,_that.name,_that.city,_that.logoUrl,_that.joinCode,_that.primaryColor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String city,  String? logoUrl,  String joinCode,  String primaryColor)  $default,) {final _that = this;
switch (_that) {
case _CommunitySummary():
return $default(_that.id,_that.name,_that.city,_that.logoUrl,_that.joinCode,_that.primaryColor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String city,  String? logoUrl,  String joinCode,  String primaryColor)?  $default,) {final _that = this;
switch (_that) {
case _CommunitySummary() when $default != null:
return $default(_that.id,_that.name,_that.city,_that.logoUrl,_that.joinCode,_that.primaryColor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CommunitySummary implements CommunitySummary {
  const _CommunitySummary({required this.id, required this.name, this.city = '', this.logoUrl, this.joinCode = '', this.primaryColor = '#5B8DEF'});
  factory _CommunitySummary.fromJson(Map<String, dynamic> json) => _$CommunitySummaryFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  String city;
@override final  String? logoUrl;
@override@JsonKey() final  String joinCode;
@override@JsonKey() final  String primaryColor;

/// Create a copy of CommunitySummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommunitySummaryCopyWith<_CommunitySummary> get copyWith => __$CommunitySummaryCopyWithImpl<_CommunitySummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommunitySummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommunitySummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.city, city) || other.city == city)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.joinCode, joinCode) || other.joinCode == joinCode)&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,city,logoUrl,joinCode,primaryColor);

@override
String toString() {
  return 'CommunitySummary(id: $id, name: $name, city: $city, logoUrl: $logoUrl, joinCode: $joinCode, primaryColor: $primaryColor)';
}


}

/// @nodoc
abstract mixin class _$CommunitySummaryCopyWith<$Res> implements $CommunitySummaryCopyWith<$Res> {
  factory _$CommunitySummaryCopyWith(_CommunitySummary value, $Res Function(_CommunitySummary) _then) = __$CommunitySummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String city, String? logoUrl, String joinCode, String primaryColor
});




}
/// @nodoc
class __$CommunitySummaryCopyWithImpl<$Res>
    implements _$CommunitySummaryCopyWith<$Res> {
  __$CommunitySummaryCopyWithImpl(this._self, this._then);

  final _CommunitySummary _self;
  final $Res Function(_CommunitySummary) _then;

/// Create a copy of CommunitySummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? city = null,Object? logoUrl = freezed,Object? joinCode = null,Object? primaryColor = null,}) {
  return _then(_CommunitySummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,joinCode: null == joinCode ? _self.joinCode : joinCode // ignore: cast_nullable_to_non_nullable
as String,primaryColor: null == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
