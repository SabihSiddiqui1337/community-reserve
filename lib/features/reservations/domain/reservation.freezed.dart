// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reservation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Reservation {

 String get id; String get amenityId; String get userId;@TimestampConverter() DateTime? get startTime;@TimestampConverter() DateTime? get endTime; ReservationStatus get status; int? get court; String? get pinHash; String? get salt; String? get qrToken; String? get accessCredentialId;@TimestampConverter() DateTime? get checkedInAt;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get cancelledAt; String? get paymentId; String? get paymentMethod;
/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReservationCopyWith<Reservation> get copyWith => _$ReservationCopyWithImpl<Reservation>(this as Reservation, _$identity);

  /// Serializes this Reservation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Reservation&&(identical(other.id, id) || other.id == id)&&(identical(other.amenityId, amenityId) || other.amenityId == amenityId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.status, status) || other.status == status)&&(identical(other.court, court) || other.court == court)&&(identical(other.pinHash, pinHash) || other.pinHash == pinHash)&&(identical(other.salt, salt) || other.salt == salt)&&(identical(other.qrToken, qrToken) || other.qrToken == qrToken)&&(identical(other.accessCredentialId, accessCredentialId) || other.accessCredentialId == accessCredentialId)&&(identical(other.checkedInAt, checkedInAt) || other.checkedInAt == checkedInAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,amenityId,userId,startTime,endTime,status,court,pinHash,salt,qrToken,accessCredentialId,checkedInAt,createdAt,cancelledAt,paymentId,paymentMethod);

@override
String toString() {
  return 'Reservation(id: $id, amenityId: $amenityId, userId: $userId, startTime: $startTime, endTime: $endTime, status: $status, court: $court, pinHash: $pinHash, salt: $salt, qrToken: $qrToken, accessCredentialId: $accessCredentialId, checkedInAt: $checkedInAt, createdAt: $createdAt, cancelledAt: $cancelledAt, paymentId: $paymentId, paymentMethod: $paymentMethod)';
}


}

/// @nodoc
abstract mixin class $ReservationCopyWith<$Res>  {
  factory $ReservationCopyWith(Reservation value, $Res Function(Reservation) _then) = _$ReservationCopyWithImpl;
@useResult
$Res call({
 String id, String amenityId, String userId,@TimestampConverter() DateTime? startTime,@TimestampConverter() DateTime? endTime, ReservationStatus status, int? court, String? pinHash, String? salt, String? qrToken, String? accessCredentialId,@TimestampConverter() DateTime? checkedInAt,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? cancelledAt, String? paymentId, String? paymentMethod
});




}
/// @nodoc
class _$ReservationCopyWithImpl<$Res>
    implements $ReservationCopyWith<$Res> {
  _$ReservationCopyWithImpl(this._self, this._then);

  final Reservation _self;
  final $Res Function(Reservation) _then;

/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? amenityId = null,Object? userId = null,Object? startTime = freezed,Object? endTime = freezed,Object? status = null,Object? court = freezed,Object? pinHash = freezed,Object? salt = freezed,Object? qrToken = freezed,Object? accessCredentialId = freezed,Object? checkedInAt = freezed,Object? createdAt = freezed,Object? cancelledAt = freezed,Object? paymentId = freezed,Object? paymentMethod = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amenityId: null == amenityId ? _self.amenityId : amenityId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReservationStatus,court: freezed == court ? _self.court : court // ignore: cast_nullable_to_non_nullable
as int?,pinHash: freezed == pinHash ? _self.pinHash : pinHash // ignore: cast_nullable_to_non_nullable
as String?,salt: freezed == salt ? _self.salt : salt // ignore: cast_nullable_to_non_nullable
as String?,qrToken: freezed == qrToken ? _self.qrToken : qrToken // ignore: cast_nullable_to_non_nullable
as String?,accessCredentialId: freezed == accessCredentialId ? _self.accessCredentialId : accessCredentialId // ignore: cast_nullable_to_non_nullable
as String?,checkedInAt: freezed == checkedInAt ? _self.checkedInAt : checkedInAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentId: freezed == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String?,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Reservation].
extension ReservationPatterns on Reservation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Reservation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Reservation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Reservation value)  $default,){
final _that = this;
switch (_that) {
case _Reservation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Reservation value)?  $default,){
final _that = this;
switch (_that) {
case _Reservation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String amenityId,  String userId, @TimestampConverter()  DateTime? startTime, @TimestampConverter()  DateTime? endTime,  ReservationStatus status,  int? court,  String? pinHash,  String? salt,  String? qrToken,  String? accessCredentialId, @TimestampConverter()  DateTime? checkedInAt, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? cancelledAt,  String? paymentId,  String? paymentMethod)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Reservation() when $default != null:
return $default(_that.id,_that.amenityId,_that.userId,_that.startTime,_that.endTime,_that.status,_that.court,_that.pinHash,_that.salt,_that.qrToken,_that.accessCredentialId,_that.checkedInAt,_that.createdAt,_that.cancelledAt,_that.paymentId,_that.paymentMethod);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String amenityId,  String userId, @TimestampConverter()  DateTime? startTime, @TimestampConverter()  DateTime? endTime,  ReservationStatus status,  int? court,  String? pinHash,  String? salt,  String? qrToken,  String? accessCredentialId, @TimestampConverter()  DateTime? checkedInAt, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? cancelledAt,  String? paymentId,  String? paymentMethod)  $default,) {final _that = this;
switch (_that) {
case _Reservation():
return $default(_that.id,_that.amenityId,_that.userId,_that.startTime,_that.endTime,_that.status,_that.court,_that.pinHash,_that.salt,_that.qrToken,_that.accessCredentialId,_that.checkedInAt,_that.createdAt,_that.cancelledAt,_that.paymentId,_that.paymentMethod);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String amenityId,  String userId, @TimestampConverter()  DateTime? startTime, @TimestampConverter()  DateTime? endTime,  ReservationStatus status,  int? court,  String? pinHash,  String? salt,  String? qrToken,  String? accessCredentialId, @TimestampConverter()  DateTime? checkedInAt, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? cancelledAt,  String? paymentId,  String? paymentMethod)?  $default,) {final _that = this;
switch (_that) {
case _Reservation() when $default != null:
return $default(_that.id,_that.amenityId,_that.userId,_that.startTime,_that.endTime,_that.status,_that.court,_that.pinHash,_that.salt,_that.qrToken,_that.accessCredentialId,_that.checkedInAt,_that.createdAt,_that.cancelledAt,_that.paymentId,_that.paymentMethod);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Reservation implements Reservation {
  const _Reservation({required this.id, required this.amenityId, required this.userId, @TimestampConverter() this.startTime, @TimestampConverter() this.endTime, this.status = ReservationStatus.booked, this.court, this.pinHash, this.salt, this.qrToken, this.accessCredentialId, @TimestampConverter() this.checkedInAt, @TimestampConverter() this.createdAt, @TimestampConverter() this.cancelledAt, this.paymentId, this.paymentMethod});
  factory _Reservation.fromJson(Map<String, dynamic> json) => _$ReservationFromJson(json);

@override final  String id;
@override final  String amenityId;
@override final  String userId;
@override@TimestampConverter() final  DateTime? startTime;
@override@TimestampConverter() final  DateTime? endTime;
@override@JsonKey() final  ReservationStatus status;
@override final  int? court;
@override final  String? pinHash;
@override final  String? salt;
@override final  String? qrToken;
@override final  String? accessCredentialId;
@override@TimestampConverter() final  DateTime? checkedInAt;
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? cancelledAt;
@override final  String? paymentId;
@override final  String? paymentMethod;

/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReservationCopyWith<_Reservation> get copyWith => __$ReservationCopyWithImpl<_Reservation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReservationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Reservation&&(identical(other.id, id) || other.id == id)&&(identical(other.amenityId, amenityId) || other.amenityId == amenityId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.status, status) || other.status == status)&&(identical(other.court, court) || other.court == court)&&(identical(other.pinHash, pinHash) || other.pinHash == pinHash)&&(identical(other.salt, salt) || other.salt == salt)&&(identical(other.qrToken, qrToken) || other.qrToken == qrToken)&&(identical(other.accessCredentialId, accessCredentialId) || other.accessCredentialId == accessCredentialId)&&(identical(other.checkedInAt, checkedInAt) || other.checkedInAt == checkedInAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,amenityId,userId,startTime,endTime,status,court,pinHash,salt,qrToken,accessCredentialId,checkedInAt,createdAt,cancelledAt,paymentId,paymentMethod);

@override
String toString() {
  return 'Reservation(id: $id, amenityId: $amenityId, userId: $userId, startTime: $startTime, endTime: $endTime, status: $status, court: $court, pinHash: $pinHash, salt: $salt, qrToken: $qrToken, accessCredentialId: $accessCredentialId, checkedInAt: $checkedInAt, createdAt: $createdAt, cancelledAt: $cancelledAt, paymentId: $paymentId, paymentMethod: $paymentMethod)';
}


}

/// @nodoc
abstract mixin class _$ReservationCopyWith<$Res> implements $ReservationCopyWith<$Res> {
  factory _$ReservationCopyWith(_Reservation value, $Res Function(_Reservation) _then) = __$ReservationCopyWithImpl;
@override @useResult
$Res call({
 String id, String amenityId, String userId,@TimestampConverter() DateTime? startTime,@TimestampConverter() DateTime? endTime, ReservationStatus status, int? court, String? pinHash, String? salt, String? qrToken, String? accessCredentialId,@TimestampConverter() DateTime? checkedInAt,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? cancelledAt, String? paymentId, String? paymentMethod
});




}
/// @nodoc
class __$ReservationCopyWithImpl<$Res>
    implements _$ReservationCopyWith<$Res> {
  __$ReservationCopyWithImpl(this._self, this._then);

  final _Reservation _self;
  final $Res Function(_Reservation) _then;

/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? amenityId = null,Object? userId = null,Object? startTime = freezed,Object? endTime = freezed,Object? status = null,Object? court = freezed,Object? pinHash = freezed,Object? salt = freezed,Object? qrToken = freezed,Object? accessCredentialId = freezed,Object? checkedInAt = freezed,Object? createdAt = freezed,Object? cancelledAt = freezed,Object? paymentId = freezed,Object? paymentMethod = freezed,}) {
  return _then(_Reservation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amenityId: null == amenityId ? _self.amenityId : amenityId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReservationStatus,court: freezed == court ? _self.court : court // ignore: cast_nullable_to_non_nullable
as int?,pinHash: freezed == pinHash ? _self.pinHash : pinHash // ignore: cast_nullable_to_non_nullable
as String?,salt: freezed == salt ? _self.salt : salt // ignore: cast_nullable_to_non_nullable
as String?,qrToken: freezed == qrToken ? _self.qrToken : qrToken // ignore: cast_nullable_to_non_nullable
as String?,accessCredentialId: freezed == accessCredentialId ? _self.accessCredentialId : accessCredentialId // ignore: cast_nullable_to_non_nullable
as String?,checkedInAt: freezed == checkedInAt ? _self.checkedInAt : checkedInAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentId: freezed == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String?,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
