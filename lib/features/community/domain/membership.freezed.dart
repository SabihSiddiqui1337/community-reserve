// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'membership.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Membership {

 String get userId; MemberRole get role; ResidencyStatus get residencyStatus; String? get verificationDocUrl; String get unit; String get address; String? get reviewedBy;@TimestampConverter() DateTime? get reviewedAt; String? get rejectionReason; int get noShowCount;@TimestampConverter() DateTime? get bannedUntil;
/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MembershipCopyWith<Membership> get copyWith => _$MembershipCopyWithImpl<Membership>(this as Membership, _$identity);

  /// Serializes this Membership to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Membership&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role)&&(identical(other.residencyStatus, residencyStatus) || other.residencyStatus == residencyStatus)&&(identical(other.verificationDocUrl, verificationDocUrl) || other.verificationDocUrl == verificationDocUrl)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.address, address) || other.address == address)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.noShowCount, noShowCount) || other.noShowCount == noShowCount)&&(identical(other.bannedUntil, bannedUntil) || other.bannedUntil == bannedUntil));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,role,residencyStatus,verificationDocUrl,unit,address,reviewedBy,reviewedAt,rejectionReason,noShowCount,bannedUntil);

@override
String toString() {
  return 'Membership(userId: $userId, role: $role, residencyStatus: $residencyStatus, verificationDocUrl: $verificationDocUrl, unit: $unit, address: $address, reviewedBy: $reviewedBy, reviewedAt: $reviewedAt, rejectionReason: $rejectionReason, noShowCount: $noShowCount, bannedUntil: $bannedUntil)';
}


}

/// @nodoc
abstract mixin class $MembershipCopyWith<$Res>  {
  factory $MembershipCopyWith(Membership value, $Res Function(Membership) _then) = _$MembershipCopyWithImpl;
@useResult
$Res call({
 String userId, MemberRole role, ResidencyStatus residencyStatus, String? verificationDocUrl, String unit, String address, String? reviewedBy,@TimestampConverter() DateTime? reviewedAt, String? rejectionReason, int noShowCount,@TimestampConverter() DateTime? bannedUntil
});




}
/// @nodoc
class _$MembershipCopyWithImpl<$Res>
    implements $MembershipCopyWith<$Res> {
  _$MembershipCopyWithImpl(this._self, this._then);

  final Membership _self;
  final $Res Function(Membership) _then;

/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? role = null,Object? residencyStatus = null,Object? verificationDocUrl = freezed,Object? unit = null,Object? address = null,Object? reviewedBy = freezed,Object? reviewedAt = freezed,Object? rejectionReason = freezed,Object? noShowCount = null,Object? bannedUntil = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRole,residencyStatus: null == residencyStatus ? _self.residencyStatus : residencyStatus // ignore: cast_nullable_to_non_nullable
as ResidencyStatus,verificationDocUrl: freezed == verificationDocUrl ? _self.verificationDocUrl : verificationDocUrl // ignore: cast_nullable_to_non_nullable
as String?,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,noShowCount: null == noShowCount ? _self.noShowCount : noShowCount // ignore: cast_nullable_to_non_nullable
as int,bannedUntil: freezed == bannedUntil ? _self.bannedUntil : bannedUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Membership].
extension MembershipPatterns on Membership {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Membership value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Membership() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Membership value)  $default,){
final _that = this;
switch (_that) {
case _Membership():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Membership value)?  $default,){
final _that = this;
switch (_that) {
case _Membership() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  MemberRole role,  ResidencyStatus residencyStatus,  String? verificationDocUrl,  String unit,  String address,  String? reviewedBy, @TimestampConverter()  DateTime? reviewedAt,  String? rejectionReason,  int noShowCount, @TimestampConverter()  DateTime? bannedUntil)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Membership() when $default != null:
return $default(_that.userId,_that.role,_that.residencyStatus,_that.verificationDocUrl,_that.unit,_that.address,_that.reviewedBy,_that.reviewedAt,_that.rejectionReason,_that.noShowCount,_that.bannedUntil);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  MemberRole role,  ResidencyStatus residencyStatus,  String? verificationDocUrl,  String unit,  String address,  String? reviewedBy, @TimestampConverter()  DateTime? reviewedAt,  String? rejectionReason,  int noShowCount, @TimestampConverter()  DateTime? bannedUntil)  $default,) {final _that = this;
switch (_that) {
case _Membership():
return $default(_that.userId,_that.role,_that.residencyStatus,_that.verificationDocUrl,_that.unit,_that.address,_that.reviewedBy,_that.reviewedAt,_that.rejectionReason,_that.noShowCount,_that.bannedUntil);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  MemberRole role,  ResidencyStatus residencyStatus,  String? verificationDocUrl,  String unit,  String address,  String? reviewedBy, @TimestampConverter()  DateTime? reviewedAt,  String? rejectionReason,  int noShowCount, @TimestampConverter()  DateTime? bannedUntil)?  $default,) {final _that = this;
switch (_that) {
case _Membership() when $default != null:
return $default(_that.userId,_that.role,_that.residencyStatus,_that.verificationDocUrl,_that.unit,_that.address,_that.reviewedBy,_that.reviewedAt,_that.rejectionReason,_that.noShowCount,_that.bannedUntil);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Membership implements Membership {
  const _Membership({required this.userId, this.role = MemberRole.resident, this.residencyStatus = ResidencyStatus.pending, this.verificationDocUrl, this.unit = '', this.address = '', this.reviewedBy, @TimestampConverter() this.reviewedAt, this.rejectionReason, this.noShowCount = 0, @TimestampConverter() this.bannedUntil});
  factory _Membership.fromJson(Map<String, dynamic> json) => _$MembershipFromJson(json);

@override final  String userId;
@override@JsonKey() final  MemberRole role;
@override@JsonKey() final  ResidencyStatus residencyStatus;
@override final  String? verificationDocUrl;
@override@JsonKey() final  String unit;
@override@JsonKey() final  String address;
@override final  String? reviewedBy;
@override@TimestampConverter() final  DateTime? reviewedAt;
@override final  String? rejectionReason;
@override@JsonKey() final  int noShowCount;
@override@TimestampConverter() final  DateTime? bannedUntil;

/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MembershipCopyWith<_Membership> get copyWith => __$MembershipCopyWithImpl<_Membership>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MembershipToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Membership&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role)&&(identical(other.residencyStatus, residencyStatus) || other.residencyStatus == residencyStatus)&&(identical(other.verificationDocUrl, verificationDocUrl) || other.verificationDocUrl == verificationDocUrl)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.address, address) || other.address == address)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.noShowCount, noShowCount) || other.noShowCount == noShowCount)&&(identical(other.bannedUntil, bannedUntil) || other.bannedUntil == bannedUntil));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,role,residencyStatus,verificationDocUrl,unit,address,reviewedBy,reviewedAt,rejectionReason,noShowCount,bannedUntil);

@override
String toString() {
  return 'Membership(userId: $userId, role: $role, residencyStatus: $residencyStatus, verificationDocUrl: $verificationDocUrl, unit: $unit, address: $address, reviewedBy: $reviewedBy, reviewedAt: $reviewedAt, rejectionReason: $rejectionReason, noShowCount: $noShowCount, bannedUntil: $bannedUntil)';
}


}

/// @nodoc
abstract mixin class _$MembershipCopyWith<$Res> implements $MembershipCopyWith<$Res> {
  factory _$MembershipCopyWith(_Membership value, $Res Function(_Membership) _then) = __$MembershipCopyWithImpl;
@override @useResult
$Res call({
 String userId, MemberRole role, ResidencyStatus residencyStatus, String? verificationDocUrl, String unit, String address, String? reviewedBy,@TimestampConverter() DateTime? reviewedAt, String? rejectionReason, int noShowCount,@TimestampConverter() DateTime? bannedUntil
});




}
/// @nodoc
class __$MembershipCopyWithImpl<$Res>
    implements _$MembershipCopyWith<$Res> {
  __$MembershipCopyWithImpl(this._self, this._then);

  final _Membership _self;
  final $Res Function(_Membership) _then;

/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? role = null,Object? residencyStatus = null,Object? verificationDocUrl = freezed,Object? unit = null,Object? address = null,Object? reviewedBy = freezed,Object? reviewedAt = freezed,Object? rejectionReason = freezed,Object? noShowCount = null,Object? bannedUntil = freezed,}) {
  return _then(_Membership(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRole,residencyStatus: null == residencyStatus ? _self.residencyStatus : residencyStatus // ignore: cast_nullable_to_non_nullable
as ResidencyStatus,verificationDocUrl: freezed == verificationDocUrl ? _self.verificationDocUrl : verificationDocUrl // ignore: cast_nullable_to_non_nullable
as String?,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,noShowCount: null == noShowCount ? _self.noShowCount : noShowCount // ignore: cast_nullable_to_non_nullable
as int,bannedUntil: freezed == bannedUntil ? _self.bannedUntil : bannedUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
