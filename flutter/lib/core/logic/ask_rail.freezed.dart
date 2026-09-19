// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ask_rail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BackgroundKb {

 KbStatus get status; int get current; int get total;
/// Create a copy of BackgroundKb
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BackgroundKbCopyWith<BackgroundKb> get copyWith => _$BackgroundKbCopyWithImpl<BackgroundKb>(this as BackgroundKb, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BackgroundKb;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BackgroundKb&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.current, _this.current) || other.current == _this.current)&&(identical(other.total, _this.total) || other.total == _this.total));
}


@override
int get hashCode {
  final _this = this as BackgroundKb;
  return Object.hash(runtimeType,_this.status,_this.current,_this.total);
}

@override
String toString() {
  final _this = this as BackgroundKb;
  return 'BackgroundKb(status: ${_this.status}, current: ${_this.current}, total: ${_this.total})';
}


}

/// @nodoc
abstract mixin class $BackgroundKbCopyWith<$Res>  {
  factory $BackgroundKbCopyWith(BackgroundKb value, $Res Function(BackgroundKb) _then) = _$BackgroundKbCopyWithImpl;
@useResult
$Res call({
 KbStatus status, int current, int total
});




}
/// @nodoc
class _$BackgroundKbCopyWithImpl<$Res>
    implements $BackgroundKbCopyWith<$Res> {
  _$BackgroundKbCopyWithImpl(this._self, this._then);

  final BackgroundKb _self;
  final $Res Function(BackgroundKb) _then;

/// Create a copy of BackgroundKb
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? current = null,Object? total = null,}) {
  return _then(BackgroundKb(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as KbStatus,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BackgroundKb].
extension BackgroundKbPatterns on BackgroundKb {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BackgroundKb value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BackgroundKb() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BackgroundKb value)  $default,){
final _that = this;
switch (_that) {
case _BackgroundKb():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BackgroundKb value)?  $default,){
final _that = this;
switch (_that) {
case _BackgroundKb() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( KbStatus status,  int current,  int total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BackgroundKb() when $default != null:
return $default(_that.status,_that.current,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( KbStatus status,  int current,  int total)  $default,) {final _that = this;
switch (_that) {
case _BackgroundKb():
return $default(_that.status,_that.current,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( KbStatus status,  int current,  int total)?  $default,) {final _that = this;
switch (_that) {
case _BackgroundKb() when $default != null:
return $default(_that.status,_that.current,_that.total);case _:
  return null;

}
}

}

/// @nodoc


class _BackgroundKb implements BackgroundKb {
  const _BackgroundKb({required this.status, this.current = 0, this.total = 0});
  

@override final  KbStatus status;
@override@JsonKey() final  int current;
@override@JsonKey() final  int total;

/// Create a copy of BackgroundKb
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BackgroundKbCopyWith<_BackgroundKb> get copyWith => __$BackgroundKbCopyWithImpl<_BackgroundKb>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BackgroundKb&&(identical(other.status, status) || other.status == status)&&(identical(other.current, current) || other.current == current)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,current,total);
}

@override
String toString() {
    return 'BackgroundKb(status: $status, current: $current, total: $total)';
}


}

/// @nodoc
abstract mixin class _$BackgroundKbCopyWith<$Res> implements $BackgroundKbCopyWith<$Res> {
  factory _$BackgroundKbCopyWith(_BackgroundKb value, $Res Function(_BackgroundKb) _then) = __$BackgroundKbCopyWithImpl;
@override @useResult
$Res call({
 KbStatus status, int current, int total
});




}
/// @nodoc
class __$BackgroundKbCopyWithImpl<$Res>
    implements _$BackgroundKbCopyWith<$Res> {
  __$BackgroundKbCopyWithImpl(this._self, this._then);

  final _BackgroundKb _self;
  final $Res Function(_BackgroundKb) _then;

/// Create a copy of BackgroundKb
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? current = null,Object? total = null,}) {
  return _then(_BackgroundKb(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as KbStatus,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$AskRailNode {

 String get key; String get label; RailStatus get status; String? get hint;
/// Create a copy of AskRailNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AskRailNodeCopyWith<AskRailNode> get copyWith => _$AskRailNodeCopyWithImpl<AskRailNode>(this as AskRailNode, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AskRailNode;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AskRailNode&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.hint, _this.hint) || other.hint == _this.hint));
}


@override
int get hashCode {
  final _this = this as AskRailNode;
  return Object.hash(runtimeType,_this.key,_this.label,_this.status,_this.hint);
}

@override
String toString() {
  final _this = this as AskRailNode;
  return 'AskRailNode(key: ${_this.key}, label: ${_this.label}, status: ${_this.status}, hint: ${_this.hint})';
}


}

/// @nodoc
abstract mixin class $AskRailNodeCopyWith<$Res>  {
  factory $AskRailNodeCopyWith(AskRailNode value, $Res Function(AskRailNode) _then) = _$AskRailNodeCopyWithImpl;
@useResult
$Res call({
 String key, String label, RailStatus status, String? hint
});




}
/// @nodoc
class _$AskRailNodeCopyWithImpl<$Res>
    implements $AskRailNodeCopyWith<$Res> {
  _$AskRailNodeCopyWithImpl(this._self, this._then);

  final AskRailNode _self;
  final $Res Function(AskRailNode) _then;

/// Create a copy of AskRailNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? label = null,Object? status = null,Object? hint = freezed,}) {
  return _then(AskRailNode(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RailStatus,hint: freezed == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AskRailNode].
extension AskRailNodePatterns on AskRailNode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AskRailNode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AskRailNode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AskRailNode value)  $default,){
final _that = this;
switch (_that) {
case _AskRailNode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AskRailNode value)?  $default,){
final _that = this;
switch (_that) {
case _AskRailNode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String label,  RailStatus status,  String? hint)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AskRailNode() when $default != null:
return $default(_that.key,_that.label,_that.status,_that.hint);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String label,  RailStatus status,  String? hint)  $default,) {final _that = this;
switch (_that) {
case _AskRailNode():
return $default(_that.key,_that.label,_that.status,_that.hint);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String label,  RailStatus status,  String? hint)?  $default,) {final _that = this;
switch (_that) {
case _AskRailNode() when $default != null:
return $default(_that.key,_that.label,_that.status,_that.hint);case _:
  return null;

}
}

}

/// @nodoc


class _AskRailNode implements AskRailNode {
  const _AskRailNode({required this.key, required this.label, required this.status, this.hint});
  

@override final  String key;
@override final  String label;
@override final  RailStatus status;
@override final  String? hint;

/// Create a copy of AskRailNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AskRailNodeCopyWith<_AskRailNode> get copyWith => __$AskRailNodeCopyWithImpl<_AskRailNode>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AskRailNode&&(identical(other.key, key) || other.key == key)&&(identical(other.label, label) || other.label == label)&&(identical(other.status, status) || other.status == status)&&(identical(other.hint, hint) || other.hint == hint));
}


@override
int get hashCode {
    return Object.hash(runtimeType,key,label,status,hint);
}

@override
String toString() {
    return 'AskRailNode(key: $key, label: $label, status: $status, hint: $hint)';
}


}

/// @nodoc
abstract mixin class _$AskRailNodeCopyWith<$Res> implements $AskRailNodeCopyWith<$Res> {
  factory _$AskRailNodeCopyWith(_AskRailNode value, $Res Function(_AskRailNode) _then) = __$AskRailNodeCopyWithImpl;
@override @useResult
$Res call({
 String key, String label, RailStatus status, String? hint
});




}
/// @nodoc
class __$AskRailNodeCopyWithImpl<$Res>
    implements _$AskRailNodeCopyWith<$Res> {
  __$AskRailNodeCopyWithImpl(this._self, this._then);

  final _AskRailNode _self;
  final $Res Function(_AskRailNode) _then;

/// Create a copy of AskRailNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? label = null,Object? status = null,Object? hint = freezed,}) {
  return _then(_AskRailNode(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RailStatus,hint: freezed == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
