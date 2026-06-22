// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Branding {

 String? get logoUrl; String get primaryColor; String get accentColor; String? get backgroundUrl; String get theme;
/// Create a copy of Branding
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BrandingCopyWith<Branding> get copyWith => _$BrandingCopyWithImpl<Branding>(this as Branding, _$identity);

  /// Serializes this Branding to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Branding&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&(identical(other.accentColor, accentColor) || other.accentColor == accentColor)&&(identical(other.backgroundUrl, backgroundUrl) || other.backgroundUrl == backgroundUrl)&&(identical(other.theme, theme) || other.theme == theme));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,logoUrl,primaryColor,accentColor,backgroundUrl,theme);

@override
String toString() {
  return 'Branding(logoUrl: $logoUrl, primaryColor: $primaryColor, accentColor: $accentColor, backgroundUrl: $backgroundUrl, theme: $theme)';
}


}

/// @nodoc
abstract mixin class $BrandingCopyWith<$Res>  {
  factory $BrandingCopyWith(Branding value, $Res Function(Branding) _then) = _$BrandingCopyWithImpl;
@useResult
$Res call({
 String? logoUrl, String primaryColor, String accentColor, String? backgroundUrl, String theme
});




}
/// @nodoc
class _$BrandingCopyWithImpl<$Res>
    implements $BrandingCopyWith<$Res> {
  _$BrandingCopyWithImpl(this._self, this._then);

  final Branding _self;
  final $Res Function(Branding) _then;

/// Create a copy of Branding
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? logoUrl = freezed,Object? primaryColor = null,Object? accentColor = null,Object? backgroundUrl = freezed,Object? theme = null,}) {
  return _then(_self.copyWith(
logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,primaryColor: null == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as String,accentColor: null == accentColor ? _self.accentColor : accentColor // ignore: cast_nullable_to_non_nullable
as String,backgroundUrl: freezed == backgroundUrl ? _self.backgroundUrl : backgroundUrl // ignore: cast_nullable_to_non_nullable
as String?,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Branding].
extension BrandingPatterns on Branding {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Branding value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Branding() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Branding value)  $default,){
final _that = this;
switch (_that) {
case _Branding():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Branding value)?  $default,){
final _that = this;
switch (_that) {
case _Branding() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? logoUrl,  String primaryColor,  String accentColor,  String? backgroundUrl,  String theme)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Branding() when $default != null:
return $default(_that.logoUrl,_that.primaryColor,_that.accentColor,_that.backgroundUrl,_that.theme);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? logoUrl,  String primaryColor,  String accentColor,  String? backgroundUrl,  String theme)  $default,) {final _that = this;
switch (_that) {
case _Branding():
return $default(_that.logoUrl,_that.primaryColor,_that.accentColor,_that.backgroundUrl,_that.theme);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? logoUrl,  String primaryColor,  String accentColor,  String? backgroundUrl,  String theme)?  $default,) {final _that = this;
switch (_that) {
case _Branding() when $default != null:
return $default(_that.logoUrl,_that.primaryColor,_that.accentColor,_that.backgroundUrl,_that.theme);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Branding implements Branding {
  const _Branding({this.logoUrl, this.primaryColor = '#FFFFFF', this.accentColor = '#C7CBD1', this.backgroundUrl, this.theme = 'dark'});
  factory _Branding.fromJson(Map<String, dynamic> json) => _$BrandingFromJson(json);

@override final  String? logoUrl;
@override@JsonKey() final  String primaryColor;
@override@JsonKey() final  String accentColor;
@override final  String? backgroundUrl;
@override@JsonKey() final  String theme;

/// Create a copy of Branding
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BrandingCopyWith<_Branding> get copyWith => __$BrandingCopyWithImpl<_Branding>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BrandingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Branding&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&(identical(other.accentColor, accentColor) || other.accentColor == accentColor)&&(identical(other.backgroundUrl, backgroundUrl) || other.backgroundUrl == backgroundUrl)&&(identical(other.theme, theme) || other.theme == theme));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,logoUrl,primaryColor,accentColor,backgroundUrl,theme);

@override
String toString() {
  return 'Branding(logoUrl: $logoUrl, primaryColor: $primaryColor, accentColor: $accentColor, backgroundUrl: $backgroundUrl, theme: $theme)';
}


}

/// @nodoc
abstract mixin class _$BrandingCopyWith<$Res> implements $BrandingCopyWith<$Res> {
  factory _$BrandingCopyWith(_Branding value, $Res Function(_Branding) _then) = __$BrandingCopyWithImpl;
@override @useResult
$Res call({
 String? logoUrl, String primaryColor, String accentColor, String? backgroundUrl, String theme
});




}
/// @nodoc
class __$BrandingCopyWithImpl<$Res>
    implements _$BrandingCopyWith<$Res> {
  __$BrandingCopyWithImpl(this._self, this._then);

  final _Branding _self;
  final $Res Function(_Branding) _then;

/// Create a copy of Branding
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? logoUrl = freezed,Object? primaryColor = null,Object? accentColor = null,Object? backgroundUrl = freezed,Object? theme = null,}) {
  return _then(_Branding(
logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,primaryColor: null == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as String,accentColor: null == accentColor ? _self.accentColor : accentColor // ignore: cast_nullable_to_non_nullable
as String,backgroundUrl: freezed == backgroundUrl ? _self.backgroundUrl : backgroundUrl // ignore: cast_nullable_to_non_nullable
as String?,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CommunitySettings {

 int get maxBookingHoursPerWeek; int get advanceBookingDays; int get maxActiveReservationsPerUser; int get checkInGraceMinutes; int get noShowThreshold; int get noShowBanDays; int get cancellationCutoffMinutes; int get cancellationAllowance;
/// Create a copy of CommunitySettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunitySettingsCopyWith<CommunitySettings> get copyWith => _$CommunitySettingsCopyWithImpl<CommunitySettings>(this as CommunitySettings, _$identity);

  /// Serializes this CommunitySettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommunitySettings&&(identical(other.maxBookingHoursPerWeek, maxBookingHoursPerWeek) || other.maxBookingHoursPerWeek == maxBookingHoursPerWeek)&&(identical(other.advanceBookingDays, advanceBookingDays) || other.advanceBookingDays == advanceBookingDays)&&(identical(other.maxActiveReservationsPerUser, maxActiveReservationsPerUser) || other.maxActiveReservationsPerUser == maxActiveReservationsPerUser)&&(identical(other.checkInGraceMinutes, checkInGraceMinutes) || other.checkInGraceMinutes == checkInGraceMinutes)&&(identical(other.noShowThreshold, noShowThreshold) || other.noShowThreshold == noShowThreshold)&&(identical(other.noShowBanDays, noShowBanDays) || other.noShowBanDays == noShowBanDays)&&(identical(other.cancellationCutoffMinutes, cancellationCutoffMinutes) || other.cancellationCutoffMinutes == cancellationCutoffMinutes)&&(identical(other.cancellationAllowance, cancellationAllowance) || other.cancellationAllowance == cancellationAllowance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,maxBookingHoursPerWeek,advanceBookingDays,maxActiveReservationsPerUser,checkInGraceMinutes,noShowThreshold,noShowBanDays,cancellationCutoffMinutes,cancellationAllowance);

@override
String toString() {
  return 'CommunitySettings(maxBookingHoursPerWeek: $maxBookingHoursPerWeek, advanceBookingDays: $advanceBookingDays, maxActiveReservationsPerUser: $maxActiveReservationsPerUser, checkInGraceMinutes: $checkInGraceMinutes, noShowThreshold: $noShowThreshold, noShowBanDays: $noShowBanDays, cancellationCutoffMinutes: $cancellationCutoffMinutes, cancellationAllowance: $cancellationAllowance)';
}


}

/// @nodoc
abstract mixin class $CommunitySettingsCopyWith<$Res>  {
  factory $CommunitySettingsCopyWith(CommunitySettings value, $Res Function(CommunitySettings) _then) = _$CommunitySettingsCopyWithImpl;
@useResult
$Res call({
 int maxBookingHoursPerWeek, int advanceBookingDays, int maxActiveReservationsPerUser, int checkInGraceMinutes, int noShowThreshold, int noShowBanDays, int cancellationCutoffMinutes, int cancellationAllowance
});




}
/// @nodoc
class _$CommunitySettingsCopyWithImpl<$Res>
    implements $CommunitySettingsCopyWith<$Res> {
  _$CommunitySettingsCopyWithImpl(this._self, this._then);

  final CommunitySettings _self;
  final $Res Function(CommunitySettings) _then;

/// Create a copy of CommunitySettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? maxBookingHoursPerWeek = null,Object? advanceBookingDays = null,Object? maxActiveReservationsPerUser = null,Object? checkInGraceMinutes = null,Object? noShowThreshold = null,Object? noShowBanDays = null,Object? cancellationCutoffMinutes = null,Object? cancellationAllowance = null,}) {
  return _then(_self.copyWith(
maxBookingHoursPerWeek: null == maxBookingHoursPerWeek ? _self.maxBookingHoursPerWeek : maxBookingHoursPerWeek // ignore: cast_nullable_to_non_nullable
as int,advanceBookingDays: null == advanceBookingDays ? _self.advanceBookingDays : advanceBookingDays // ignore: cast_nullable_to_non_nullable
as int,maxActiveReservationsPerUser: null == maxActiveReservationsPerUser ? _self.maxActiveReservationsPerUser : maxActiveReservationsPerUser // ignore: cast_nullable_to_non_nullable
as int,checkInGraceMinutes: null == checkInGraceMinutes ? _self.checkInGraceMinutes : checkInGraceMinutes // ignore: cast_nullable_to_non_nullable
as int,noShowThreshold: null == noShowThreshold ? _self.noShowThreshold : noShowThreshold // ignore: cast_nullable_to_non_nullable
as int,noShowBanDays: null == noShowBanDays ? _self.noShowBanDays : noShowBanDays // ignore: cast_nullable_to_non_nullable
as int,cancellationCutoffMinutes: null == cancellationCutoffMinutes ? _self.cancellationCutoffMinutes : cancellationCutoffMinutes // ignore: cast_nullable_to_non_nullable
as int,cancellationAllowance: null == cancellationAllowance ? _self.cancellationAllowance : cancellationAllowance // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CommunitySettings].
extension CommunitySettingsPatterns on CommunitySettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommunitySettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommunitySettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommunitySettings value)  $default,){
final _that = this;
switch (_that) {
case _CommunitySettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommunitySettings value)?  $default,){
final _that = this;
switch (_that) {
case _CommunitySettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int maxBookingHoursPerWeek,  int advanceBookingDays,  int maxActiveReservationsPerUser,  int checkInGraceMinutes,  int noShowThreshold,  int noShowBanDays,  int cancellationCutoffMinutes,  int cancellationAllowance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommunitySettings() when $default != null:
return $default(_that.maxBookingHoursPerWeek,_that.advanceBookingDays,_that.maxActiveReservationsPerUser,_that.checkInGraceMinutes,_that.noShowThreshold,_that.noShowBanDays,_that.cancellationCutoffMinutes,_that.cancellationAllowance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int maxBookingHoursPerWeek,  int advanceBookingDays,  int maxActiveReservationsPerUser,  int checkInGraceMinutes,  int noShowThreshold,  int noShowBanDays,  int cancellationCutoffMinutes,  int cancellationAllowance)  $default,) {final _that = this;
switch (_that) {
case _CommunitySettings():
return $default(_that.maxBookingHoursPerWeek,_that.advanceBookingDays,_that.maxActiveReservationsPerUser,_that.checkInGraceMinutes,_that.noShowThreshold,_that.noShowBanDays,_that.cancellationCutoffMinutes,_that.cancellationAllowance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int maxBookingHoursPerWeek,  int advanceBookingDays,  int maxActiveReservationsPerUser,  int checkInGraceMinutes,  int noShowThreshold,  int noShowBanDays,  int cancellationCutoffMinutes,  int cancellationAllowance)?  $default,) {final _that = this;
switch (_that) {
case _CommunitySettings() when $default != null:
return $default(_that.maxBookingHoursPerWeek,_that.advanceBookingDays,_that.maxActiveReservationsPerUser,_that.checkInGraceMinutes,_that.noShowThreshold,_that.noShowBanDays,_that.cancellationCutoffMinutes,_that.cancellationAllowance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CommunitySettings implements CommunitySettings {
  const _CommunitySettings({this.maxBookingHoursPerWeek = 3, this.advanceBookingDays = 7, this.maxActiveReservationsPerUser = 2, this.checkInGraceMinutes = 15, this.noShowThreshold = 3, this.noShowBanDays = 30, this.cancellationCutoffMinutes = 60, this.cancellationAllowance = 2});
  factory _CommunitySettings.fromJson(Map<String, dynamic> json) => _$CommunitySettingsFromJson(json);

@override@JsonKey() final  int maxBookingHoursPerWeek;
@override@JsonKey() final  int advanceBookingDays;
@override@JsonKey() final  int maxActiveReservationsPerUser;
@override@JsonKey() final  int checkInGraceMinutes;
@override@JsonKey() final  int noShowThreshold;
@override@JsonKey() final  int noShowBanDays;
@override@JsonKey() final  int cancellationCutoffMinutes;
@override@JsonKey() final  int cancellationAllowance;

/// Create a copy of CommunitySettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommunitySettingsCopyWith<_CommunitySettings> get copyWith => __$CommunitySettingsCopyWithImpl<_CommunitySettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommunitySettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommunitySettings&&(identical(other.maxBookingHoursPerWeek, maxBookingHoursPerWeek) || other.maxBookingHoursPerWeek == maxBookingHoursPerWeek)&&(identical(other.advanceBookingDays, advanceBookingDays) || other.advanceBookingDays == advanceBookingDays)&&(identical(other.maxActiveReservationsPerUser, maxActiveReservationsPerUser) || other.maxActiveReservationsPerUser == maxActiveReservationsPerUser)&&(identical(other.checkInGraceMinutes, checkInGraceMinutes) || other.checkInGraceMinutes == checkInGraceMinutes)&&(identical(other.noShowThreshold, noShowThreshold) || other.noShowThreshold == noShowThreshold)&&(identical(other.noShowBanDays, noShowBanDays) || other.noShowBanDays == noShowBanDays)&&(identical(other.cancellationCutoffMinutes, cancellationCutoffMinutes) || other.cancellationCutoffMinutes == cancellationCutoffMinutes)&&(identical(other.cancellationAllowance, cancellationAllowance) || other.cancellationAllowance == cancellationAllowance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,maxBookingHoursPerWeek,advanceBookingDays,maxActiveReservationsPerUser,checkInGraceMinutes,noShowThreshold,noShowBanDays,cancellationCutoffMinutes,cancellationAllowance);

@override
String toString() {
  return 'CommunitySettings(maxBookingHoursPerWeek: $maxBookingHoursPerWeek, advanceBookingDays: $advanceBookingDays, maxActiveReservationsPerUser: $maxActiveReservationsPerUser, checkInGraceMinutes: $checkInGraceMinutes, noShowThreshold: $noShowThreshold, noShowBanDays: $noShowBanDays, cancellationCutoffMinutes: $cancellationCutoffMinutes, cancellationAllowance: $cancellationAllowance)';
}


}

/// @nodoc
abstract mixin class _$CommunitySettingsCopyWith<$Res> implements $CommunitySettingsCopyWith<$Res> {
  factory _$CommunitySettingsCopyWith(_CommunitySettings value, $Res Function(_CommunitySettings) _then) = __$CommunitySettingsCopyWithImpl;
@override @useResult
$Res call({
 int maxBookingHoursPerWeek, int advanceBookingDays, int maxActiveReservationsPerUser, int checkInGraceMinutes, int noShowThreshold, int noShowBanDays, int cancellationCutoffMinutes, int cancellationAllowance
});




}
/// @nodoc
class __$CommunitySettingsCopyWithImpl<$Res>
    implements _$CommunitySettingsCopyWith<$Res> {
  __$CommunitySettingsCopyWithImpl(this._self, this._then);

  final _CommunitySettings _self;
  final $Res Function(_CommunitySettings) _then;

/// Create a copy of CommunitySettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? maxBookingHoursPerWeek = null,Object? advanceBookingDays = null,Object? maxActiveReservationsPerUser = null,Object? checkInGraceMinutes = null,Object? noShowThreshold = null,Object? noShowBanDays = null,Object? cancellationCutoffMinutes = null,Object? cancellationAllowance = null,}) {
  return _then(_CommunitySettings(
maxBookingHoursPerWeek: null == maxBookingHoursPerWeek ? _self.maxBookingHoursPerWeek : maxBookingHoursPerWeek // ignore: cast_nullable_to_non_nullable
as int,advanceBookingDays: null == advanceBookingDays ? _self.advanceBookingDays : advanceBookingDays // ignore: cast_nullable_to_non_nullable
as int,maxActiveReservationsPerUser: null == maxActiveReservationsPerUser ? _self.maxActiveReservationsPerUser : maxActiveReservationsPerUser // ignore: cast_nullable_to_non_nullable
as int,checkInGraceMinutes: null == checkInGraceMinutes ? _self.checkInGraceMinutes : checkInGraceMinutes // ignore: cast_nullable_to_non_nullable
as int,noShowThreshold: null == noShowThreshold ? _self.noShowThreshold : noShowThreshold // ignore: cast_nullable_to_non_nullable
as int,noShowBanDays: null == noShowBanDays ? _self.noShowBanDays : noShowBanDays // ignore: cast_nullable_to_non_nullable
as int,cancellationCutoffMinutes: null == cancellationCutoffMinutes ? _self.cancellationCutoffMinutes : cancellationCutoffMinutes // ignore: cast_nullable_to_non_nullable
as int,cancellationAllowance: null == cancellationAllowance ? _self.cancellationAllowance : cancellationAllowance // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$FeatureFlags {

 bool get paymentsEnabled; bool get gymEnabled; bool get waitlistEnabled;
/// Create a copy of FeatureFlags
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeatureFlagsCopyWith<FeatureFlags> get copyWith => _$FeatureFlagsCopyWithImpl<FeatureFlags>(this as FeatureFlags, _$identity);

  /// Serializes this FeatureFlags to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeatureFlags&&(identical(other.paymentsEnabled, paymentsEnabled) || other.paymentsEnabled == paymentsEnabled)&&(identical(other.gymEnabled, gymEnabled) || other.gymEnabled == gymEnabled)&&(identical(other.waitlistEnabled, waitlistEnabled) || other.waitlistEnabled == waitlistEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,paymentsEnabled,gymEnabled,waitlistEnabled);

@override
String toString() {
  return 'FeatureFlags(paymentsEnabled: $paymentsEnabled, gymEnabled: $gymEnabled, waitlistEnabled: $waitlistEnabled)';
}


}

/// @nodoc
abstract mixin class $FeatureFlagsCopyWith<$Res>  {
  factory $FeatureFlagsCopyWith(FeatureFlags value, $Res Function(FeatureFlags) _then) = _$FeatureFlagsCopyWithImpl;
@useResult
$Res call({
 bool paymentsEnabled, bool gymEnabled, bool waitlistEnabled
});




}
/// @nodoc
class _$FeatureFlagsCopyWithImpl<$Res>
    implements $FeatureFlagsCopyWith<$Res> {
  _$FeatureFlagsCopyWithImpl(this._self, this._then);

  final FeatureFlags _self;
  final $Res Function(FeatureFlags) _then;

/// Create a copy of FeatureFlags
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? paymentsEnabled = null,Object? gymEnabled = null,Object? waitlistEnabled = null,}) {
  return _then(_self.copyWith(
paymentsEnabled: null == paymentsEnabled ? _self.paymentsEnabled : paymentsEnabled // ignore: cast_nullable_to_non_nullable
as bool,gymEnabled: null == gymEnabled ? _self.gymEnabled : gymEnabled // ignore: cast_nullable_to_non_nullable
as bool,waitlistEnabled: null == waitlistEnabled ? _self.waitlistEnabled : waitlistEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FeatureFlags].
extension FeatureFlagsPatterns on FeatureFlags {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeatureFlags value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeatureFlags() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeatureFlags value)  $default,){
final _that = this;
switch (_that) {
case _FeatureFlags():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeatureFlags value)?  $default,){
final _that = this;
switch (_that) {
case _FeatureFlags() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool paymentsEnabled,  bool gymEnabled,  bool waitlistEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeatureFlags() when $default != null:
return $default(_that.paymentsEnabled,_that.gymEnabled,_that.waitlistEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool paymentsEnabled,  bool gymEnabled,  bool waitlistEnabled)  $default,) {final _that = this;
switch (_that) {
case _FeatureFlags():
return $default(_that.paymentsEnabled,_that.gymEnabled,_that.waitlistEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool paymentsEnabled,  bool gymEnabled,  bool waitlistEnabled)?  $default,) {final _that = this;
switch (_that) {
case _FeatureFlags() when $default != null:
return $default(_that.paymentsEnabled,_that.gymEnabled,_that.waitlistEnabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeatureFlags implements FeatureFlags {
  const _FeatureFlags({this.paymentsEnabled = false, this.gymEnabled = false, this.waitlistEnabled = true});
  factory _FeatureFlags.fromJson(Map<String, dynamic> json) => _$FeatureFlagsFromJson(json);

@override@JsonKey() final  bool paymentsEnabled;
@override@JsonKey() final  bool gymEnabled;
@override@JsonKey() final  bool waitlistEnabled;

/// Create a copy of FeatureFlags
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeatureFlagsCopyWith<_FeatureFlags> get copyWith => __$FeatureFlagsCopyWithImpl<_FeatureFlags>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeatureFlagsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeatureFlags&&(identical(other.paymentsEnabled, paymentsEnabled) || other.paymentsEnabled == paymentsEnabled)&&(identical(other.gymEnabled, gymEnabled) || other.gymEnabled == gymEnabled)&&(identical(other.waitlistEnabled, waitlistEnabled) || other.waitlistEnabled == waitlistEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,paymentsEnabled,gymEnabled,waitlistEnabled);

@override
String toString() {
  return 'FeatureFlags(paymentsEnabled: $paymentsEnabled, gymEnabled: $gymEnabled, waitlistEnabled: $waitlistEnabled)';
}


}

/// @nodoc
abstract mixin class _$FeatureFlagsCopyWith<$Res> implements $FeatureFlagsCopyWith<$Res> {
  factory _$FeatureFlagsCopyWith(_FeatureFlags value, $Res Function(_FeatureFlags) _then) = __$FeatureFlagsCopyWithImpl;
@override @useResult
$Res call({
 bool paymentsEnabled, bool gymEnabled, bool waitlistEnabled
});




}
/// @nodoc
class __$FeatureFlagsCopyWithImpl<$Res>
    implements _$FeatureFlagsCopyWith<$Res> {
  __$FeatureFlagsCopyWithImpl(this._self, this._then);

  final _FeatureFlags _self;
  final $Res Function(_FeatureFlags) _then;

/// Create a copy of FeatureFlags
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? paymentsEnabled = null,Object? gymEnabled = null,Object? waitlistEnabled = null,}) {
  return _then(_FeatureFlags(
paymentsEnabled: null == paymentsEnabled ? _self.paymentsEnabled : paymentsEnabled // ignore: cast_nullable_to_non_nullable
as bool,gymEnabled: null == gymEnabled ? _self.gymEnabled : gymEnabled // ignore: cast_nullable_to_non_nullable
as bool,waitlistEnabled: null == waitlistEnabled ? _self.waitlistEnabled : waitlistEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Community {

 String get id; String get name; String get address; String get timezone; Branding get branding; CommunitySettings get settings; FeatureFlags get featureFlags;
/// Create a copy of Community
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunityCopyWith<Community> get copyWith => _$CommunityCopyWithImpl<Community>(this as Community, _$identity);

  /// Serializes this Community to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Community&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.branding, branding) || other.branding == branding)&&(identical(other.settings, settings) || other.settings == settings)&&(identical(other.featureFlags, featureFlags) || other.featureFlags == featureFlags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,address,timezone,branding,settings,featureFlags);

@override
String toString() {
  return 'Community(id: $id, name: $name, address: $address, timezone: $timezone, branding: $branding, settings: $settings, featureFlags: $featureFlags)';
}


}

/// @nodoc
abstract mixin class $CommunityCopyWith<$Res>  {
  factory $CommunityCopyWith(Community value, $Res Function(Community) _then) = _$CommunityCopyWithImpl;
@useResult
$Res call({
 String id, String name, String address, String timezone, Branding branding, CommunitySettings settings, FeatureFlags featureFlags
});


$BrandingCopyWith<$Res> get branding;$CommunitySettingsCopyWith<$Res> get settings;$FeatureFlagsCopyWith<$Res> get featureFlags;

}
/// @nodoc
class _$CommunityCopyWithImpl<$Res>
    implements $CommunityCopyWith<$Res> {
  _$CommunityCopyWithImpl(this._self, this._then);

  final Community _self;
  final $Res Function(Community) _then;

/// Create a copy of Community
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? address = null,Object? timezone = null,Object? branding = null,Object? settings = null,Object? featureFlags = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,branding: null == branding ? _self.branding : branding // ignore: cast_nullable_to_non_nullable
as Branding,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as CommunitySettings,featureFlags: null == featureFlags ? _self.featureFlags : featureFlags // ignore: cast_nullable_to_non_nullable
as FeatureFlags,
  ));
}
/// Create a copy of Community
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BrandingCopyWith<$Res> get branding {
  
  return $BrandingCopyWith<$Res>(_self.branding, (value) {
    return _then(_self.copyWith(branding: value));
  });
}/// Create a copy of Community
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommunitySettingsCopyWith<$Res> get settings {
  
  return $CommunitySettingsCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}/// Create a copy of Community
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FeatureFlagsCopyWith<$Res> get featureFlags {
  
  return $FeatureFlagsCopyWith<$Res>(_self.featureFlags, (value) {
    return _then(_self.copyWith(featureFlags: value));
  });
}
}


/// Adds pattern-matching-related methods to [Community].
extension CommunityPatterns on Community {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Community value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Community() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Community value)  $default,){
final _that = this;
switch (_that) {
case _Community():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Community value)?  $default,){
final _that = this;
switch (_that) {
case _Community() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String address,  String timezone,  Branding branding,  CommunitySettings settings,  FeatureFlags featureFlags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Community() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.timezone,_that.branding,_that.settings,_that.featureFlags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String address,  String timezone,  Branding branding,  CommunitySettings settings,  FeatureFlags featureFlags)  $default,) {final _that = this;
switch (_that) {
case _Community():
return $default(_that.id,_that.name,_that.address,_that.timezone,_that.branding,_that.settings,_that.featureFlags);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String address,  String timezone,  Branding branding,  CommunitySettings settings,  FeatureFlags featureFlags)?  $default,) {final _that = this;
switch (_that) {
case _Community() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.timezone,_that.branding,_that.settings,_that.featureFlags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Community implements Community {
  const _Community({required this.id, required this.name, this.address = '', this.timezone = 'America/New_York', this.branding = const Branding(), this.settings = const CommunitySettings(), this.featureFlags = const FeatureFlags()});
  factory _Community.fromJson(Map<String, dynamic> json) => _$CommunityFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  String address;
@override@JsonKey() final  String timezone;
@override@JsonKey() final  Branding branding;
@override@JsonKey() final  CommunitySettings settings;
@override@JsonKey() final  FeatureFlags featureFlags;

/// Create a copy of Community
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommunityCopyWith<_Community> get copyWith => __$CommunityCopyWithImpl<_Community>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommunityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Community&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.branding, branding) || other.branding == branding)&&(identical(other.settings, settings) || other.settings == settings)&&(identical(other.featureFlags, featureFlags) || other.featureFlags == featureFlags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,address,timezone,branding,settings,featureFlags);

@override
String toString() {
  return 'Community(id: $id, name: $name, address: $address, timezone: $timezone, branding: $branding, settings: $settings, featureFlags: $featureFlags)';
}


}

/// @nodoc
abstract mixin class _$CommunityCopyWith<$Res> implements $CommunityCopyWith<$Res> {
  factory _$CommunityCopyWith(_Community value, $Res Function(_Community) _then) = __$CommunityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String address, String timezone, Branding branding, CommunitySettings settings, FeatureFlags featureFlags
});


@override $BrandingCopyWith<$Res> get branding;@override $CommunitySettingsCopyWith<$Res> get settings;@override $FeatureFlagsCopyWith<$Res> get featureFlags;

}
/// @nodoc
class __$CommunityCopyWithImpl<$Res>
    implements _$CommunityCopyWith<$Res> {
  __$CommunityCopyWithImpl(this._self, this._then);

  final _Community _self;
  final $Res Function(_Community) _then;

/// Create a copy of Community
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? address = null,Object? timezone = null,Object? branding = null,Object? settings = null,Object? featureFlags = null,}) {
  return _then(_Community(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,branding: null == branding ? _self.branding : branding // ignore: cast_nullable_to_non_nullable
as Branding,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as CommunitySettings,featureFlags: null == featureFlags ? _self.featureFlags : featureFlags // ignore: cast_nullable_to_non_nullable
as FeatureFlags,
  ));
}

/// Create a copy of Community
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BrandingCopyWith<$Res> get branding {
  
  return $BrandingCopyWith<$Res>(_self.branding, (value) {
    return _then(_self.copyWith(branding: value));
  });
}/// Create a copy of Community
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommunitySettingsCopyWith<$Res> get settings {
  
  return $CommunitySettingsCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}/// Create a copy of Community
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FeatureFlagsCopyWith<$Res> get featureFlags {
  
  return $FeatureFlagsCopyWith<$Res>(_self.featureFlags, (value) {
    return _then(_self.copyWith(featureFlags: value));
  });
}
}

// dart format on
