// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ayah_ref.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AyahRef {

 int get surah; int get ayah;
/// Create a copy of AyahRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AyahRefCopyWith<AyahRef> get copyWith => _$AyahRefCopyWithImpl<AyahRef>(this as AyahRef, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AyahRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AyahRef&&(identical(other.surah, _this.surah) || other.surah == _this.surah)&&(identical(other.ayah, _this.ayah) || other.ayah == _this.ayah));
}


@override
int get hashCode {
  final _this = this as AyahRef;
  return Object.hash(runtimeType,_this.surah,_this.ayah);
}

@override
String toString() {
  final _this = this as AyahRef;
  return 'AyahRef(surah: ${_this.surah}, ayah: ${_this.ayah})';
}


}

/// @nodoc
abstract mixin class $AyahRefCopyWith<$Res>  {
  factory $AyahRefCopyWith(AyahRef value, $Res Function(AyahRef) _then) = _$AyahRefCopyWithImpl;
@useResult
$Res call({
 int surah, int ayah
});




}
/// @nodoc
class _$AyahRefCopyWithImpl<$Res>
    implements $AyahRefCopyWith<$Res> {
  _$AyahRefCopyWithImpl(this._self, this._then);

  final AyahRef _self;
  final $Res Function(AyahRef) _then;

/// Create a copy of AyahRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? surah = null,Object? ayah = null,}) {
  return _then(AyahRef(
surah: null == surah ? _self.surah : surah // ignore: cast_nullable_to_non_nullable
as int,ayah: null == ayah ? _self.ayah : ayah // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AyahRef].
extension AyahRefPatterns on AyahRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AyahRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AyahRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AyahRef value)  $default,){
final _that = this;
switch (_that) {
case _AyahRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AyahRef value)?  $default,){
final _that = this;
switch (_that) {
case _AyahRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int surah,  int ayah)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AyahRef() when $default != null:
return $default(_that.surah,_that.ayah);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int surah,  int ayah)  $default,) {final _that = this;
switch (_that) {
case _AyahRef():
return $default(_that.surah,_that.ayah);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int surah,  int ayah)?  $default,) {final _that = this;
switch (_that) {
case _AyahRef() when $default != null:
return $default(_that.surah,_that.ayah);case _:
  return null;

}
}

}

/// @nodoc


class _AyahRef extends AyahRef {
  const _AyahRef({required this.surah, required this.ayah}): super._();
  

@override final  int surah;
@override final  int ayah;

/// Create a copy of AyahRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AyahRefCopyWith<_AyahRef> get copyWith => __$AyahRefCopyWithImpl<_AyahRef>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AyahRef&&(identical(other.surah, surah) || other.surah == surah)&&(identical(other.ayah, ayah) || other.ayah == ayah));
}


@override
int get hashCode {
    return Object.hash(runtimeType,surah,ayah);
}

@override
String toString() {
    return 'AyahRef(surah: $surah, ayah: $ayah)';
}


}

/// @nodoc
abstract mixin class _$AyahRefCopyWith<$Res> implements $AyahRefCopyWith<$Res> {
  factory _$AyahRefCopyWith(_AyahRef value, $Res Function(_AyahRef) _then) = __$AyahRefCopyWithImpl;
@override @useResult
$Res call({
 int surah, int ayah
});




}
/// @nodoc
class __$AyahRefCopyWithImpl<$Res>
    implements _$AyahRefCopyWith<$Res> {
  __$AyahRefCopyWithImpl(this._self, this._then);

  final _AyahRef _self;
  final $Res Function(_AyahRef) _then;

/// Create a copy of AyahRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? surah = null,Object? ayah = null,}) {
  return _then(_AyahRef(
surah: null == surah ? _self.surah : surah // ignore: cast_nullable_to_non_nullable
as int,ayah: null == ayah ? _self.ayah : ayah // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
