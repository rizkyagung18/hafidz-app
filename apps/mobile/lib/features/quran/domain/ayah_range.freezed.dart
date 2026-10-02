// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ayah_range.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AyahRange {

 AyahRef get start; AyahRef get end;
/// Create a copy of AyahRange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AyahRangeCopyWith<AyahRange> get copyWith => _$AyahRangeCopyWithImpl<AyahRange>(this as AyahRange, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AyahRange;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AyahRange&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.end, _this.end) || other.end == _this.end));
}


@override
int get hashCode {
  final _this = this as AyahRange;
  return Object.hash(runtimeType,_this.start,_this.end);
}

@override
String toString() {
  final _this = this as AyahRange;
  return 'AyahRange(start: ${_this.start}, end: ${_this.end})';
}


}

/// @nodoc
abstract mixin class $AyahRangeCopyWith<$Res>  {
  factory $AyahRangeCopyWith(AyahRange value, $Res Function(AyahRange) _then) = _$AyahRangeCopyWithImpl;
@useResult
$Res call({
 AyahRef start, AyahRef end
});


$AyahRefCopyWith<$Res> get start;$AyahRefCopyWith<$Res> get end;

}
/// @nodoc
class _$AyahRangeCopyWithImpl<$Res>
    implements $AyahRangeCopyWith<$Res> {
  _$AyahRangeCopyWithImpl(this._self, this._then);

  final AyahRange _self;
  final $Res Function(AyahRange) _then;

/// Create a copy of AyahRange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? start = null,Object? end = null,}) {
  return _then(AyahRange(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as AyahRef,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as AyahRef,
  ));
}
/// Create a copy of AyahRange
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AyahRefCopyWith<$Res> get start {
  
  return $AyahRefCopyWith<$Res>(_self.start, (value) {
    return _then(_self.copyWith(start: value));
  });
}/// Create a copy of AyahRange
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AyahRefCopyWith<$Res> get end {
  
  return $AyahRefCopyWith<$Res>(_self.end, (value) {
    return _then(_self.copyWith(end: value));
  });
}
}


/// Adds pattern-matching-related methods to [AyahRange].
extension AyahRangePatterns on AyahRange {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AyahRange value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AyahRange() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AyahRange value)  $default,){
final _that = this;
switch (_that) {
case _AyahRange():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AyahRange value)?  $default,){
final _that = this;
switch (_that) {
case _AyahRange() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AyahRef start,  AyahRef end)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AyahRange() when $default != null:
return $default(_that.start,_that.end);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AyahRef start,  AyahRef end)  $default,) {final _that = this;
switch (_that) {
case _AyahRange():
return $default(_that.start,_that.end);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AyahRef start,  AyahRef end)?  $default,) {final _that = this;
switch (_that) {
case _AyahRange() when $default != null:
return $default(_that.start,_that.end);case _:
  return null;

}
}

}

/// @nodoc


class _AyahRange extends AyahRange {
  const _AyahRange({required this.start, required this.end}): super._();
  

@override final  AyahRef start;
@override final  AyahRef end;

/// Create a copy of AyahRange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AyahRangeCopyWith<_AyahRange> get copyWith => __$AyahRangeCopyWithImpl<_AyahRange>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AyahRange&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end));
}


@override
int get hashCode {
    return Object.hash(runtimeType,start,end);
}

@override
String toString() {
    return 'AyahRange(start: $start, end: $end)';
}


}

/// @nodoc
abstract mixin class _$AyahRangeCopyWith<$Res> implements $AyahRangeCopyWith<$Res> {
  factory _$AyahRangeCopyWith(_AyahRange value, $Res Function(_AyahRange) _then) = __$AyahRangeCopyWithImpl;
@override @useResult
$Res call({
 AyahRef start, AyahRef end
});


@override $AyahRefCopyWith<$Res> get start;@override $AyahRefCopyWith<$Res> get end;

}
/// @nodoc
class __$AyahRangeCopyWithImpl<$Res>
    implements _$AyahRangeCopyWith<$Res> {
  __$AyahRangeCopyWithImpl(this._self, this._then);

  final _AyahRange _self;
  final $Res Function(_AyahRange) _then;

/// Create a copy of AyahRange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? start = null,Object? end = null,}) {
  return _then(_AyahRange(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as AyahRef,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as AyahRef,
  ));
}

/// Create a copy of AyahRange
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AyahRefCopyWith<$Res> get start {
  
  return $AyahRefCopyWith<$Res>(_self.start, (value) {
    return _then(_self.copyWith(start: value));
  });
}/// Create a copy of AyahRange
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AyahRefCopyWith<$Res> get end {
  
  return $AyahRefCopyWith<$Res>(_self.end, (value) {
    return _then(_self.copyWith(end: value));
  });
}
}

// dart format on
