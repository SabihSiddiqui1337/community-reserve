// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dm_thread.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DmThread {

 String get id; List<String> get participantIds; List<String> get participantNames; bool get isGroup; String get lastText;@TimestampConverter() DateTime? get lastAt;@TimestampConverter() DateTime? get createdAt;
/// Create a copy of DmThread
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DmThreadCopyWith<DmThread> get copyWith => _$DmThreadCopyWithImpl<DmThread>(this as DmThread, _$identity);

  /// Serializes this DmThread to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DmThread&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.participantIds, participantIds)&&const DeepCollectionEquality().equals(other.participantNames, participantNames)&&(identical(other.isGroup, isGroup) || other.isGroup == isGroup)&&(identical(other.lastText, lastText) || other.lastText == lastText)&&(identical(other.lastAt, lastAt) || other.lastAt == lastAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(participantIds),const DeepCollectionEquality().hash(participantNames),isGroup,lastText,lastAt,createdAt);

@override
String toString() {
  return 'DmThread(id: $id, participantIds: $participantIds, participantNames: $participantNames, isGroup: $isGroup, lastText: $lastText, lastAt: $lastAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $DmThreadCopyWith<$Res>  {
  factory $DmThreadCopyWith(DmThread value, $Res Function(DmThread) _then) = _$DmThreadCopyWithImpl;
@useResult
$Res call({
 String id, List<String> participantIds, List<String> participantNames, bool isGroup, String lastText,@TimestampConverter() DateTime? lastAt,@TimestampConverter() DateTime? createdAt
});




}
/// @nodoc
class _$DmThreadCopyWithImpl<$Res>
    implements $DmThreadCopyWith<$Res> {
  _$DmThreadCopyWithImpl(this._self, this._then);

  final DmThread _self;
  final $Res Function(DmThread) _then;

/// Create a copy of DmThread
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? participantIds = null,Object? participantNames = null,Object? isGroup = null,Object? lastText = null,Object? lastAt = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,participantIds: null == participantIds ? _self.participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,participantNames: null == participantNames ? _self.participantNames : participantNames // ignore: cast_nullable_to_non_nullable
as List<String>,isGroup: null == isGroup ? _self.isGroup : isGroup // ignore: cast_nullable_to_non_nullable
as bool,lastText: null == lastText ? _self.lastText : lastText // ignore: cast_nullable_to_non_nullable
as String,lastAt: freezed == lastAt ? _self.lastAt : lastAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DmThread].
extension DmThreadPatterns on DmThread {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DmThread value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DmThread() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DmThread value)  $default,){
final _that = this;
switch (_that) {
case _DmThread():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DmThread value)?  $default,){
final _that = this;
switch (_that) {
case _DmThread() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<String> participantIds,  List<String> participantNames,  bool isGroup,  String lastText, @TimestampConverter()  DateTime? lastAt, @TimestampConverter()  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DmThread() when $default != null:
return $default(_that.id,_that.participantIds,_that.participantNames,_that.isGroup,_that.lastText,_that.lastAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<String> participantIds,  List<String> participantNames,  bool isGroup,  String lastText, @TimestampConverter()  DateTime? lastAt, @TimestampConverter()  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _DmThread():
return $default(_that.id,_that.participantIds,_that.participantNames,_that.isGroup,_that.lastText,_that.lastAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<String> participantIds,  List<String> participantNames,  bool isGroup,  String lastText, @TimestampConverter()  DateTime? lastAt, @TimestampConverter()  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _DmThread() when $default != null:
return $default(_that.id,_that.participantIds,_that.participantNames,_that.isGroup,_that.lastText,_that.lastAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DmThread implements DmThread {
  const _DmThread({required this.id, final  List<String> participantIds = const <String>[], final  List<String> participantNames = const <String>[], this.isGroup = false, this.lastText = '', @TimestampConverter() this.lastAt, @TimestampConverter() this.createdAt}): _participantIds = participantIds,_participantNames = participantNames;
  factory _DmThread.fromJson(Map<String, dynamic> json) => _$DmThreadFromJson(json);

@override final  String id;
 final  List<String> _participantIds;
@override@JsonKey() List<String> get participantIds {
  if (_participantIds is EqualUnmodifiableListView) return _participantIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participantIds);
}

 final  List<String> _participantNames;
@override@JsonKey() List<String> get participantNames {
  if (_participantNames is EqualUnmodifiableListView) return _participantNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participantNames);
}

@override@JsonKey() final  bool isGroup;
@override@JsonKey() final  String lastText;
@override@TimestampConverter() final  DateTime? lastAt;
@override@TimestampConverter() final  DateTime? createdAt;

/// Create a copy of DmThread
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DmThreadCopyWith<_DmThread> get copyWith => __$DmThreadCopyWithImpl<_DmThread>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DmThreadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DmThread&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._participantIds, _participantIds)&&const DeepCollectionEquality().equals(other._participantNames, _participantNames)&&(identical(other.isGroup, isGroup) || other.isGroup == isGroup)&&(identical(other.lastText, lastText) || other.lastText == lastText)&&(identical(other.lastAt, lastAt) || other.lastAt == lastAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_participantIds),const DeepCollectionEquality().hash(_participantNames),isGroup,lastText,lastAt,createdAt);

@override
String toString() {
  return 'DmThread(id: $id, participantIds: $participantIds, participantNames: $participantNames, isGroup: $isGroup, lastText: $lastText, lastAt: $lastAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$DmThreadCopyWith<$Res> implements $DmThreadCopyWith<$Res> {
  factory _$DmThreadCopyWith(_DmThread value, $Res Function(_DmThread) _then) = __$DmThreadCopyWithImpl;
@override @useResult
$Res call({
 String id, List<String> participantIds, List<String> participantNames, bool isGroup, String lastText,@TimestampConverter() DateTime? lastAt,@TimestampConverter() DateTime? createdAt
});




}
/// @nodoc
class __$DmThreadCopyWithImpl<$Res>
    implements _$DmThreadCopyWith<$Res> {
  __$DmThreadCopyWithImpl(this._self, this._then);

  final _DmThread _self;
  final $Res Function(_DmThread) _then;

/// Create a copy of DmThread
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? participantIds = null,Object? participantNames = null,Object? isGroup = null,Object? lastText = null,Object? lastAt = freezed,Object? createdAt = freezed,}) {
  return _then(_DmThread(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,participantIds: null == participantIds ? _self._participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,participantNames: null == participantNames ? _self._participantNames : participantNames // ignore: cast_nullable_to_non_nullable
as List<String>,isGroup: null == isGroup ? _self.isGroup : isGroup // ignore: cast_nullable_to_non_nullable
as bool,lastText: null == lastText ? _self.lastText : lastText // ignore: cast_nullable_to_non_nullable
as String,lastAt: freezed == lastAt ? _self.lastAt : lastAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
