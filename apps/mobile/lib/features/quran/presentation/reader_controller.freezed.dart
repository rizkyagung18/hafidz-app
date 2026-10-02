// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reader_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReaderHighlight {

 AyahRange get range; bool get pulsing;
/// Create a copy of ReaderHighlight
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReaderHighlightCopyWith<ReaderHighlight> get copyWith => _$ReaderHighlightCopyWithImpl<ReaderHighlight>(this as ReaderHighlight, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ReaderHighlight;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReaderHighlight&&(identical(other.range, _this.range) || other.range == _this.range)&&(identical(other.pulsing, _this.pulsing) || other.pulsing == _this.pulsing));
}


@override
int get hashCode {
  final _this = this as ReaderHighlight;
  return Object.hash(runtimeType,_this.range,_this.pulsing);
}

@override
String toString() {
  final _this = this as ReaderHighlight;
  return 'ReaderHighlight(range: ${_this.range}, pulsing: ${_this.pulsing})';
}


}

/// @nodoc
abstract mixin class $ReaderHighlightCopyWith<$Res>  {
  factory $ReaderHighlightCopyWith(ReaderHighlight value, $Res Function(ReaderHighlight) _then) = _$ReaderHighlightCopyWithImpl;
@useResult
$Res call({
 AyahRange range, bool pulsing
});


$AyahRangeCopyWith<$Res> get range;

}
/// @nodoc
class _$ReaderHighlightCopyWithImpl<$Res>
    implements $ReaderHighlightCopyWith<$Res> {
  _$ReaderHighlightCopyWithImpl(this._self, this._then);

  final ReaderHighlight _self;
  final $Res Function(ReaderHighlight) _then;

/// Create a copy of ReaderHighlight
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? range = null,Object? pulsing = null,}) {
  return _then(ReaderHighlight(
range: null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as AyahRange,pulsing: null == pulsing ? _self.pulsing : pulsing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ReaderHighlight
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AyahRangeCopyWith<$Res> get range {
  
  return $AyahRangeCopyWith<$Res>(_self.range, (value) {
    return _then(_self.copyWith(range: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReaderHighlight].
extension ReaderHighlightPatterns on ReaderHighlight {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReaderHighlight value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReaderHighlight() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReaderHighlight value)  $default,){
final _that = this;
switch (_that) {
case _ReaderHighlight():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReaderHighlight value)?  $default,){
final _that = this;
switch (_that) {
case _ReaderHighlight() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AyahRange range,  bool pulsing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReaderHighlight() when $default != null:
return $default(_that.range,_that.pulsing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AyahRange range,  bool pulsing)  $default,) {final _that = this;
switch (_that) {
case _ReaderHighlight():
return $default(_that.range,_that.pulsing);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AyahRange range,  bool pulsing)?  $default,) {final _that = this;
switch (_that) {
case _ReaderHighlight() when $default != null:
return $default(_that.range,_that.pulsing);case _:
  return null;

}
}

}

/// @nodoc


class _ReaderHighlight implements ReaderHighlight {
  const _ReaderHighlight({required this.range, required this.pulsing});
  

@override final  AyahRange range;
@override final  bool pulsing;

/// Create a copy of ReaderHighlight
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReaderHighlightCopyWith<_ReaderHighlight> get copyWith => __$ReaderHighlightCopyWithImpl<_ReaderHighlight>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReaderHighlight&&(identical(other.range, range) || other.range == range)&&(identical(other.pulsing, pulsing) || other.pulsing == pulsing));
}


@override
int get hashCode {
    return Object.hash(runtimeType,range,pulsing);
}

@override
String toString() {
    return 'ReaderHighlight(range: $range, pulsing: $pulsing)';
}


}

/// @nodoc
abstract mixin class _$ReaderHighlightCopyWith<$Res> implements $ReaderHighlightCopyWith<$Res> {
  factory _$ReaderHighlightCopyWith(_ReaderHighlight value, $Res Function(_ReaderHighlight) _then) = __$ReaderHighlightCopyWithImpl;
@override @useResult
$Res call({
 AyahRange range, bool pulsing
});


@override $AyahRangeCopyWith<$Res> get range;

}
/// @nodoc
class __$ReaderHighlightCopyWithImpl<$Res>
    implements _$ReaderHighlightCopyWith<$Res> {
  __$ReaderHighlightCopyWithImpl(this._self, this._then);

  final _ReaderHighlight _self;
  final $Res Function(_ReaderHighlight) _then;

/// Create a copy of ReaderHighlight
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? range = null,Object? pulsing = null,}) {
  return _then(_ReaderHighlight(
range: null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as AyahRange,pulsing: null == pulsing ? _self.pulsing : pulsing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ReaderHighlight
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AyahRangeCopyWith<$Res> get range {
  
  return $AyahRangeCopyWith<$Res>(_self.range, (value) {
    return _then(_self.copyWith(range: value));
  });
}
}

// dart format on
