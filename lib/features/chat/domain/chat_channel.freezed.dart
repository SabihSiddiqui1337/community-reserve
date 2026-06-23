// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_channel.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatChannel {

 String get id; String get name; bool get isGeneral;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get lastAt;
/// Create a copy of ChatChannel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatChannelCopyWith<ChatChannel> get copyWith => _$ChatChannelCopyWithImpl<ChatChannel>(this as ChatChannel, _$identity);

  /// Serializes this ChatChannel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatChannel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.isGeneral, isGeneral) || other.isGeneral == isGeneral)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastAt, lastAt) || other.lastAt == lastAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,isGeneral,createdAt,lastAt);

@override
String toString() {
  return 'ChatChannel(id: $id, name: $name, isGeneral: $isGeneral, createdAt: $createdAt, lastAt: $lastAt)';
}


}

/// @nodoc
abstract mixin class $ChatChannelCopyWith<$Res>  {
  factory $ChatChannelCopyWith(ChatChannel value, $Res Function(ChatChannel) _then) = _$ChatChannelCopyWithImpl;
@useResult
$Res call({
 String id, String name, bool isGeneral,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? lastAt
});




}
/// @nodoc
class _$ChatChannelCopyWithImpl<$Res>
    implements $ChatChannelCopyWith<$Res> {
  _$ChatChannelCopyWithImpl(this._self, this._then);

  final ChatChannel _self;
  final $Res Function(ChatChannel) _then;

/// Create a copy of ChatChannel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? isGeneral = null,Object? createdAt = freezed,Object? lastAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isGeneral: null == isGeneral ? _self.isGeneral : isGeneral // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastAt: freezed == lastAt ? _self.lastAt : lastAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatChannel].
extension ChatChannelPatterns on ChatChannel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatChannel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatChannel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatChannel value)  $default,){
final _that = this;
switch (_that) {
case _ChatChannel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatChannel value)?  $default,){
final _that = this;
switch (_that) {
case _ChatChannel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  bool isGeneral, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? lastAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatChannel() when $default != null:
return $default(_that.id,_that.name,_that.isGeneral,_that.createdAt,_that.lastAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  bool isGeneral, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? lastAt)  $default,) {final _that = this;
switch (_that) {
case _ChatChannel():
return $default(_that.id,_that.name,_that.isGeneral,_that.createdAt,_that.lastAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  bool isGeneral, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? lastAt)?  $default,) {final _that = this;
switch (_that) {
case _ChatChannel() when $default != null:
return $default(_that.id,_that.name,_that.isGeneral,_that.createdAt,_that.lastAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatChannel implements ChatChannel {
  const _ChatChannel({required this.id, this.name = '', this.isGeneral = false, @TimestampConverter() this.createdAt, @TimestampConverter() this.lastAt});
  factory _ChatChannel.fromJson(Map<String, dynamic> json) => _$ChatChannelFromJson(json);

@override final  String id;
@override@JsonKey() final  String name;
@override@JsonKey() final  bool isGeneral;
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? lastAt;

/// Create a copy of ChatChannel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatChannelCopyWith<_ChatChannel> get copyWith => __$ChatChannelCopyWithImpl<_ChatChannel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatChannelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatChannel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.isGeneral, isGeneral) || other.isGeneral == isGeneral)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastAt, lastAt) || other.lastAt == lastAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,isGeneral,createdAt,lastAt);

@override
String toString() {
  return 'ChatChannel(id: $id, name: $name, isGeneral: $isGeneral, createdAt: $createdAt, lastAt: $lastAt)';
}


}

/// @nodoc
abstract mixin class _$ChatChannelCopyWith<$Res> implements $ChatChannelCopyWith<$Res> {
  factory _$ChatChannelCopyWith(_ChatChannel value, $Res Function(_ChatChannel) _then) = __$ChatChannelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, bool isGeneral,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? lastAt
});




}
/// @nodoc
class __$ChatChannelCopyWithImpl<$Res>
    implements _$ChatChannelCopyWith<$Res> {
  __$ChatChannelCopyWithImpl(this._self, this._then);

  final _ChatChannel _self;
  final $Res Function(_ChatChannel) _then;

/// Create a copy of ChatChannel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? isGeneral = null,Object? createdAt = freezed,Object? lastAt = freezed,}) {
  return _then(_ChatChannel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isGeneral: null == isGeneral ? _self.isGeneral : isGeneral // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastAt: freezed == lastAt ? _self.lastAt : lastAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
