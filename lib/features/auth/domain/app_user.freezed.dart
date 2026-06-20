// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppUser {

 String get uid; String get name; String get email; String get phone; String? get photoUrl; List<String> get fcmTokens; String get globalRole; List<PaymentMethod> get paymentMethods; String? get selectedCardId;
/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUserCopyWith<AppUser> get copyWith => _$AppUserCopyWithImpl<AppUser>(this as AppUser, _$identity);

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUser&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&const DeepCollectionEquality().equals(other.fcmTokens, fcmTokens)&&(identical(other.globalRole, globalRole) || other.globalRole == globalRole)&&const DeepCollectionEquality().equals(other.paymentMethods, paymentMethods)&&(identical(other.selectedCardId, selectedCardId) || other.selectedCardId == selectedCardId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,name,email,phone,photoUrl,const DeepCollectionEquality().hash(fcmTokens),globalRole,const DeepCollectionEquality().hash(paymentMethods),selectedCardId);

@override
String toString() {
  return 'AppUser(uid: $uid, name: $name, email: $email, phone: $phone, photoUrl: $photoUrl, fcmTokens: $fcmTokens, globalRole: $globalRole, paymentMethods: $paymentMethods, selectedCardId: $selectedCardId)';
}


}

/// @nodoc
abstract mixin class $AppUserCopyWith<$Res>  {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) _then) = _$AppUserCopyWithImpl;
@useResult
$Res call({
 String uid, String name, String email, String phone, String? photoUrl, List<String> fcmTokens, String globalRole, List<PaymentMethod> paymentMethods, String? selectedCardId
});




}
/// @nodoc
class _$AppUserCopyWithImpl<$Res>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._self, this._then);

  final AppUser _self;
  final $Res Function(AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? name = null,Object? email = null,Object? phone = null,Object? photoUrl = freezed,Object? fcmTokens = null,Object? globalRole = null,Object? paymentMethods = null,Object? selectedCardId = freezed,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,fcmTokens: null == fcmTokens ? _self.fcmTokens : fcmTokens // ignore: cast_nullable_to_non_nullable
as List<String>,globalRole: null == globalRole ? _self.globalRole : globalRole // ignore: cast_nullable_to_non_nullable
as String,paymentMethods: null == paymentMethods ? _self.paymentMethods : paymentMethods // ignore: cast_nullable_to_non_nullable
as List<PaymentMethod>,selectedCardId: freezed == selectedCardId ? _self.selectedCardId : selectedCardId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppUser].
extension AppUserPatterns on AppUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUser value)  $default,){
final _that = this;
switch (_that) {
case _AppUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUser value)?  $default,){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String name,  String email,  String phone,  String? photoUrl,  List<String> fcmTokens,  String globalRole,  List<PaymentMethod> paymentMethods,  String? selectedCardId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.uid,_that.name,_that.email,_that.phone,_that.photoUrl,_that.fcmTokens,_that.globalRole,_that.paymentMethods,_that.selectedCardId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String name,  String email,  String phone,  String? photoUrl,  List<String> fcmTokens,  String globalRole,  List<PaymentMethod> paymentMethods,  String? selectedCardId)  $default,) {final _that = this;
switch (_that) {
case _AppUser():
return $default(_that.uid,_that.name,_that.email,_that.phone,_that.photoUrl,_that.fcmTokens,_that.globalRole,_that.paymentMethods,_that.selectedCardId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String name,  String email,  String phone,  String? photoUrl,  List<String> fcmTokens,  String globalRole,  List<PaymentMethod> paymentMethods,  String? selectedCardId)?  $default,) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.uid,_that.name,_that.email,_that.phone,_that.photoUrl,_that.fcmTokens,_that.globalRole,_that.paymentMethods,_that.selectedCardId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppUser implements AppUser {
  const _AppUser({required this.uid, this.name = '', this.email = '', this.phone = '', this.photoUrl, final  List<String> fcmTokens = const <String>[], this.globalRole = 'resident', final  List<PaymentMethod> paymentMethods = const <PaymentMethod>[], this.selectedCardId}): _fcmTokens = fcmTokens,_paymentMethods = paymentMethods;
  factory _AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

@override final  String uid;
@override@JsonKey() final  String name;
@override@JsonKey() final  String email;
@override@JsonKey() final  String phone;
@override final  String? photoUrl;
 final  List<String> _fcmTokens;
@override@JsonKey() List<String> get fcmTokens {
  if (_fcmTokens is EqualUnmodifiableListView) return _fcmTokens;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fcmTokens);
}

@override@JsonKey() final  String globalRole;
 final  List<PaymentMethod> _paymentMethods;
@override@JsonKey() List<PaymentMethod> get paymentMethods {
  if (_paymentMethods is EqualUnmodifiableListView) return _paymentMethods;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_paymentMethods);
}

@override final  String? selectedCardId;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUserCopyWith<_AppUser> get copyWith => __$AppUserCopyWithImpl<_AppUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUser&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&const DeepCollectionEquality().equals(other._fcmTokens, _fcmTokens)&&(identical(other.globalRole, globalRole) || other.globalRole == globalRole)&&const DeepCollectionEquality().equals(other._paymentMethods, _paymentMethods)&&(identical(other.selectedCardId, selectedCardId) || other.selectedCardId == selectedCardId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,name,email,phone,photoUrl,const DeepCollectionEquality().hash(_fcmTokens),globalRole,const DeepCollectionEquality().hash(_paymentMethods),selectedCardId);

@override
String toString() {
  return 'AppUser(uid: $uid, name: $name, email: $email, phone: $phone, photoUrl: $photoUrl, fcmTokens: $fcmTokens, globalRole: $globalRole, paymentMethods: $paymentMethods, selectedCardId: $selectedCardId)';
}


}

/// @nodoc
abstract mixin class _$AppUserCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$AppUserCopyWith(_AppUser value, $Res Function(_AppUser) _then) = __$AppUserCopyWithImpl;
@override @useResult
$Res call({
 String uid, String name, String email, String phone, String? photoUrl, List<String> fcmTokens, String globalRole, List<PaymentMethod> paymentMethods, String? selectedCardId
});




}
/// @nodoc
class __$AppUserCopyWithImpl<$Res>
    implements _$AppUserCopyWith<$Res> {
  __$AppUserCopyWithImpl(this._self, this._then);

  final _AppUser _self;
  final $Res Function(_AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? name = null,Object? email = null,Object? phone = null,Object? photoUrl = freezed,Object? fcmTokens = null,Object? globalRole = null,Object? paymentMethods = null,Object? selectedCardId = freezed,}) {
  return _then(_AppUser(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,fcmTokens: null == fcmTokens ? _self._fcmTokens : fcmTokens // ignore: cast_nullable_to_non_nullable
as List<String>,globalRole: null == globalRole ? _self.globalRole : globalRole // ignore: cast_nullable_to_non_nullable
as String,paymentMethods: null == paymentMethods ? _self._paymentMethods : paymentMethods // ignore: cast_nullable_to_non_nullable
as List<PaymentMethod>,selectedCardId: freezed == selectedCardId ? _self.selectedCardId : selectedCardId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
