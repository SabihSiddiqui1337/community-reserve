// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'amenity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AmenityPricing {

 bool get isPaid; int get amountCents; String get currency; int get depositCents;
/// Create a copy of AmenityPricing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AmenityPricingCopyWith<AmenityPricing> get copyWith => _$AmenityPricingCopyWithImpl<AmenityPricing>(this as AmenityPricing, _$identity);

  /// Serializes this AmenityPricing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AmenityPricing&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.amountCents, amountCents) || other.amountCents == amountCents)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.depositCents, depositCents) || other.depositCents == depositCents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isPaid,amountCents,currency,depositCents);

@override
String toString() {
  return 'AmenityPricing(isPaid: $isPaid, amountCents: $amountCents, currency: $currency, depositCents: $depositCents)';
}


}

/// @nodoc
abstract mixin class $AmenityPricingCopyWith<$Res>  {
  factory $AmenityPricingCopyWith(AmenityPricing value, $Res Function(AmenityPricing) _then) = _$AmenityPricingCopyWithImpl;
@useResult
$Res call({
 bool isPaid, int amountCents, String currency, int depositCents
});




}
/// @nodoc
class _$AmenityPricingCopyWithImpl<$Res>
    implements $AmenityPricingCopyWith<$Res> {
  _$AmenityPricingCopyWithImpl(this._self, this._then);

  final AmenityPricing _self;
  final $Res Function(AmenityPricing) _then;

/// Create a copy of AmenityPricing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isPaid = null,Object? amountCents = null,Object? currency = null,Object? depositCents = null,}) {
  return _then(_self.copyWith(
isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,amountCents: null == amountCents ? _self.amountCents : amountCents // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,depositCents: null == depositCents ? _self.depositCents : depositCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AmenityPricing].
extension AmenityPricingPatterns on AmenityPricing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AmenityPricing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AmenityPricing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AmenityPricing value)  $default,){
final _that = this;
switch (_that) {
case _AmenityPricing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AmenityPricing value)?  $default,){
final _that = this;
switch (_that) {
case _AmenityPricing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isPaid,  int amountCents,  String currency,  int depositCents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AmenityPricing() when $default != null:
return $default(_that.isPaid,_that.amountCents,_that.currency,_that.depositCents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isPaid,  int amountCents,  String currency,  int depositCents)  $default,) {final _that = this;
switch (_that) {
case _AmenityPricing():
return $default(_that.isPaid,_that.amountCents,_that.currency,_that.depositCents);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isPaid,  int amountCents,  String currency,  int depositCents)?  $default,) {final _that = this;
switch (_that) {
case _AmenityPricing() when $default != null:
return $default(_that.isPaid,_that.amountCents,_that.currency,_that.depositCents);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AmenityPricing implements AmenityPricing {
  const _AmenityPricing({this.isPaid = false, this.amountCents = 0, this.currency = 'USD', this.depositCents = 0});
  factory _AmenityPricing.fromJson(Map<String, dynamic> json) => _$AmenityPricingFromJson(json);

@override@JsonKey() final  bool isPaid;
@override@JsonKey() final  int amountCents;
@override@JsonKey() final  String currency;
@override@JsonKey() final  int depositCents;

/// Create a copy of AmenityPricing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AmenityPricingCopyWith<_AmenityPricing> get copyWith => __$AmenityPricingCopyWithImpl<_AmenityPricing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AmenityPricingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AmenityPricing&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.amountCents, amountCents) || other.amountCents == amountCents)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.depositCents, depositCents) || other.depositCents == depositCents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isPaid,amountCents,currency,depositCents);

@override
String toString() {
  return 'AmenityPricing(isPaid: $isPaid, amountCents: $amountCents, currency: $currency, depositCents: $depositCents)';
}


}

/// @nodoc
abstract mixin class _$AmenityPricingCopyWith<$Res> implements $AmenityPricingCopyWith<$Res> {
  factory _$AmenityPricingCopyWith(_AmenityPricing value, $Res Function(_AmenityPricing) _then) = __$AmenityPricingCopyWithImpl;
@override @useResult
$Res call({
 bool isPaid, int amountCents, String currency, int depositCents
});




}
/// @nodoc
class __$AmenityPricingCopyWithImpl<$Res>
    implements _$AmenityPricingCopyWith<$Res> {
  __$AmenityPricingCopyWithImpl(this._self, this._then);

  final _AmenityPricing _self;
  final $Res Function(_AmenityPricing) _then;

/// Create a copy of AmenityPricing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isPaid = null,Object? amountCents = null,Object? currency = null,Object? depositCents = null,}) {
  return _then(_AmenityPricing(
isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,amountCents: null == amountCents ? _self.amountCents : amountCents // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,depositCents: null == depositCents ? _self.depositCents : depositCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Amenity {

 String get id; String get type; String get name; String get description; String? get photoUrl; AmenityStatus get status; int get slotMinutes; int get bufferMinutes; int get capacity; bool get requiresPin; int get openHour; int get closeHour; AmenityPricing get pricing;
/// Create a copy of Amenity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AmenityCopyWith<Amenity> get copyWith => _$AmenityCopyWithImpl<Amenity>(this as Amenity, _$identity);

  /// Serializes this Amenity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Amenity&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.slotMinutes, slotMinutes) || other.slotMinutes == slotMinutes)&&(identical(other.bufferMinutes, bufferMinutes) || other.bufferMinutes == bufferMinutes)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.requiresPin, requiresPin) || other.requiresPin == requiresPin)&&(identical(other.openHour, openHour) || other.openHour == openHour)&&(identical(other.closeHour, closeHour) || other.closeHour == closeHour)&&(identical(other.pricing, pricing) || other.pricing == pricing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,name,description,photoUrl,status,slotMinutes,bufferMinutes,capacity,requiresPin,openHour,closeHour,pricing);

@override
String toString() {
  return 'Amenity(id: $id, type: $type, name: $name, description: $description, photoUrl: $photoUrl, status: $status, slotMinutes: $slotMinutes, bufferMinutes: $bufferMinutes, capacity: $capacity, requiresPin: $requiresPin, openHour: $openHour, closeHour: $closeHour, pricing: $pricing)';
}


}

/// @nodoc
abstract mixin class $AmenityCopyWith<$Res>  {
  factory $AmenityCopyWith(Amenity value, $Res Function(Amenity) _then) = _$AmenityCopyWithImpl;
@useResult
$Res call({
 String id, String type, String name, String description, String? photoUrl, AmenityStatus status, int slotMinutes, int bufferMinutes, int capacity, bool requiresPin, int openHour, int closeHour, AmenityPricing pricing
});


$AmenityPricingCopyWith<$Res> get pricing;

}
/// @nodoc
class _$AmenityCopyWithImpl<$Res>
    implements $AmenityCopyWith<$Res> {
  _$AmenityCopyWithImpl(this._self, this._then);

  final Amenity _self;
  final $Res Function(Amenity) _then;

/// Create a copy of Amenity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? name = null,Object? description = null,Object? photoUrl = freezed,Object? status = null,Object? slotMinutes = null,Object? bufferMinutes = null,Object? capacity = null,Object? requiresPin = null,Object? openHour = null,Object? closeHour = null,Object? pricing = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AmenityStatus,slotMinutes: null == slotMinutes ? _self.slotMinutes : slotMinutes // ignore: cast_nullable_to_non_nullable
as int,bufferMinutes: null == bufferMinutes ? _self.bufferMinutes : bufferMinutes // ignore: cast_nullable_to_non_nullable
as int,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,requiresPin: null == requiresPin ? _self.requiresPin : requiresPin // ignore: cast_nullable_to_non_nullable
as bool,openHour: null == openHour ? _self.openHour : openHour // ignore: cast_nullable_to_non_nullable
as int,closeHour: null == closeHour ? _self.closeHour : closeHour // ignore: cast_nullable_to_non_nullable
as int,pricing: null == pricing ? _self.pricing : pricing // ignore: cast_nullable_to_non_nullable
as AmenityPricing,
  ));
}
/// Create a copy of Amenity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AmenityPricingCopyWith<$Res> get pricing {
  
  return $AmenityPricingCopyWith<$Res>(_self.pricing, (value) {
    return _then(_self.copyWith(pricing: value));
  });
}
}


/// Adds pattern-matching-related methods to [Amenity].
extension AmenityPatterns on Amenity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Amenity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Amenity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Amenity value)  $default,){
final _that = this;
switch (_that) {
case _Amenity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Amenity value)?  $default,){
final _that = this;
switch (_that) {
case _Amenity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  String name,  String description,  String? photoUrl,  AmenityStatus status,  int slotMinutes,  int bufferMinutes,  int capacity,  bool requiresPin,  int openHour,  int closeHour,  AmenityPricing pricing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Amenity() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.description,_that.photoUrl,_that.status,_that.slotMinutes,_that.bufferMinutes,_that.capacity,_that.requiresPin,_that.openHour,_that.closeHour,_that.pricing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  String name,  String description,  String? photoUrl,  AmenityStatus status,  int slotMinutes,  int bufferMinutes,  int capacity,  bool requiresPin,  int openHour,  int closeHour,  AmenityPricing pricing)  $default,) {final _that = this;
switch (_that) {
case _Amenity():
return $default(_that.id,_that.type,_that.name,_that.description,_that.photoUrl,_that.status,_that.slotMinutes,_that.bufferMinutes,_that.capacity,_that.requiresPin,_that.openHour,_that.closeHour,_that.pricing);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  String name,  String description,  String? photoUrl,  AmenityStatus status,  int slotMinutes,  int bufferMinutes,  int capacity,  bool requiresPin,  int openHour,  int closeHour,  AmenityPricing pricing)?  $default,) {final _that = this;
switch (_that) {
case _Amenity() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.description,_that.photoUrl,_that.status,_that.slotMinutes,_that.bufferMinutes,_that.capacity,_that.requiresPin,_that.openHour,_that.closeHour,_that.pricing);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Amenity implements Amenity {
  const _Amenity({required this.id, this.type = 'generic', this.name = '', this.description = '', this.photoUrl, this.status = AmenityStatus.active, this.slotMinutes = 60, this.bufferMinutes = 0, this.capacity = 1, this.requiresPin = true, this.openHour = 6, this.closeHour = 22, this.pricing = const AmenityPricing()});
  factory _Amenity.fromJson(Map<String, dynamic> json) => _$AmenityFromJson(json);

@override final  String id;
@override@JsonKey() final  String type;
@override@JsonKey() final  String name;
@override@JsonKey() final  String description;
@override final  String? photoUrl;
@override@JsonKey() final  AmenityStatus status;
@override@JsonKey() final  int slotMinutes;
@override@JsonKey() final  int bufferMinutes;
@override@JsonKey() final  int capacity;
@override@JsonKey() final  bool requiresPin;
@override@JsonKey() final  int openHour;
@override@JsonKey() final  int closeHour;
@override@JsonKey() final  AmenityPricing pricing;

/// Create a copy of Amenity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AmenityCopyWith<_Amenity> get copyWith => __$AmenityCopyWithImpl<_Amenity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AmenityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Amenity&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.slotMinutes, slotMinutes) || other.slotMinutes == slotMinutes)&&(identical(other.bufferMinutes, bufferMinutes) || other.bufferMinutes == bufferMinutes)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.requiresPin, requiresPin) || other.requiresPin == requiresPin)&&(identical(other.openHour, openHour) || other.openHour == openHour)&&(identical(other.closeHour, closeHour) || other.closeHour == closeHour)&&(identical(other.pricing, pricing) || other.pricing == pricing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,name,description,photoUrl,status,slotMinutes,bufferMinutes,capacity,requiresPin,openHour,closeHour,pricing);

@override
String toString() {
  return 'Amenity(id: $id, type: $type, name: $name, description: $description, photoUrl: $photoUrl, status: $status, slotMinutes: $slotMinutes, bufferMinutes: $bufferMinutes, capacity: $capacity, requiresPin: $requiresPin, openHour: $openHour, closeHour: $closeHour, pricing: $pricing)';
}


}

/// @nodoc
abstract mixin class _$AmenityCopyWith<$Res> implements $AmenityCopyWith<$Res> {
  factory _$AmenityCopyWith(_Amenity value, $Res Function(_Amenity) _then) = __$AmenityCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String name, String description, String? photoUrl, AmenityStatus status, int slotMinutes, int bufferMinutes, int capacity, bool requiresPin, int openHour, int closeHour, AmenityPricing pricing
});


@override $AmenityPricingCopyWith<$Res> get pricing;

}
/// @nodoc
class __$AmenityCopyWithImpl<$Res>
    implements _$AmenityCopyWith<$Res> {
  __$AmenityCopyWithImpl(this._self, this._then);

  final _Amenity _self;
  final $Res Function(_Amenity) _then;

/// Create a copy of Amenity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? name = null,Object? description = null,Object? photoUrl = freezed,Object? status = null,Object? slotMinutes = null,Object? bufferMinutes = null,Object? capacity = null,Object? requiresPin = null,Object? openHour = null,Object? closeHour = null,Object? pricing = null,}) {
  return _then(_Amenity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AmenityStatus,slotMinutes: null == slotMinutes ? _self.slotMinutes : slotMinutes // ignore: cast_nullable_to_non_nullable
as int,bufferMinutes: null == bufferMinutes ? _self.bufferMinutes : bufferMinutes // ignore: cast_nullable_to_non_nullable
as int,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,requiresPin: null == requiresPin ? _self.requiresPin : requiresPin // ignore: cast_nullable_to_non_nullable
as bool,openHour: null == openHour ? _self.openHour : openHour // ignore: cast_nullable_to_non_nullable
as int,closeHour: null == closeHour ? _self.closeHour : closeHour // ignore: cast_nullable_to_non_nullable
as int,pricing: null == pricing ? _self.pricing : pricing // ignore: cast_nullable_to_non_nullable
as AmenityPricing,
  ));
}

/// Create a copy of Amenity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AmenityPricingCopyWith<$Res> get pricing {
  
  return $AmenityPricingCopyWith<$Res>(_self.pricing, (value) {
    return _then(_self.copyWith(pricing: value));
  });
}
}

// dart format on
