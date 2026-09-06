// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job_live_monitor.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$JobLiveState {

 JobLive get live; SseConnection get connection; String get lastEventId;
/// Create a copy of JobLiveState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobLiveStateCopyWith<JobLiveState> get copyWith => _$JobLiveStateCopyWithImpl<JobLiveState>(this as JobLiveState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as JobLiveState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobLiveState&&(identical(other.live, _this.live) || other.live == _this.live)&&(identical(other.connection, _this.connection) || other.connection == _this.connection)&&(identical(other.lastEventId, _this.lastEventId) || other.lastEventId == _this.lastEventId));
}


@override
int get hashCode {
  final _this = this as JobLiveState;
  return Object.hash(runtimeType,_this.live,_this.connection,_this.lastEventId);
}

@override
String toString() {
  final _this = this as JobLiveState;
  return 'JobLiveState(live: ${_this.live}, connection: ${_this.connection}, lastEventId: ${_this.lastEventId})';
}


}

/// @nodoc
abstract mixin class $JobLiveStateCopyWith<$Res>  {
  factory $JobLiveStateCopyWith(JobLiveState value, $Res Function(JobLiveState) _then) = _$JobLiveStateCopyWithImpl;
@useResult
$Res call({
 JobLive live, SseConnection connection, String lastEventId
});


$JobLiveCopyWith<$Res> get live;

}
/// @nodoc
class _$JobLiveStateCopyWithImpl<$Res>
    implements $JobLiveStateCopyWith<$Res> {
  _$JobLiveStateCopyWithImpl(this._self, this._then);

  final JobLiveState _self;
  final $Res Function(JobLiveState) _then;

/// Create a copy of JobLiveState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? live = null,Object? connection = null,Object? lastEventId = null,}) {
  return _then(JobLiveState(
live: null == live ? _self.live : live // ignore: cast_nullable_to_non_nullable
as JobLive,connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as SseConnection,lastEventId: null == lastEventId ? _self.lastEventId : lastEventId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of JobLiveState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JobLiveCopyWith<$Res> get live {
  
  return $JobLiveCopyWith<$Res>(_self.live, (value) {
    return _then(_self.copyWith(live: value));
  });
}
}


/// Adds pattern-matching-related methods to [JobLiveState].
extension JobLiveStatePatterns on JobLiveState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JobLiveState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JobLiveState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JobLiveState value)  $default,){
final _that = this;
switch (_that) {
case _JobLiveState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JobLiveState value)?  $default,){
final _that = this;
switch (_that) {
case _JobLiveState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( JobLive live,  SseConnection connection,  String lastEventId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JobLiveState() when $default != null:
return $default(_that.live,_that.connection,_that.lastEventId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( JobLive live,  SseConnection connection,  String lastEventId)  $default,) {final _that = this;
switch (_that) {
case _JobLiveState():
return $default(_that.live,_that.connection,_that.lastEventId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( JobLive live,  SseConnection connection,  String lastEventId)?  $default,) {final _that = this;
switch (_that) {
case _JobLiveState() when $default != null:
return $default(_that.live,_that.connection,_that.lastEventId);case _:
  return null;

}
}

}

/// @nodoc


class _JobLiveState implements JobLiveState {
  const _JobLiveState({this.live = JobLive.empty, this.connection = SseConnection.idle, this.lastEventId = '0-0'});
  

@override@JsonKey() final  JobLive live;
@override@JsonKey() final  SseConnection connection;
@override@JsonKey() final  String lastEventId;

/// Create a copy of JobLiveState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JobLiveStateCopyWith<_JobLiveState> get copyWith => __$JobLiveStateCopyWithImpl<_JobLiveState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _JobLiveState&&(identical(other.live, live) || other.live == live)&&(identical(other.connection, connection) || other.connection == connection)&&(identical(other.lastEventId, lastEventId) || other.lastEventId == lastEventId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,live,connection,lastEventId);
}

@override
String toString() {
    return 'JobLiveState(live: $live, connection: $connection, lastEventId: $lastEventId)';
}


}

/// @nodoc
abstract mixin class _$JobLiveStateCopyWith<$Res> implements $JobLiveStateCopyWith<$Res> {
  factory _$JobLiveStateCopyWith(_JobLiveState value, $Res Function(_JobLiveState) _then) = __$JobLiveStateCopyWithImpl;
@override @useResult
$Res call({
 JobLive live, SseConnection connection, String lastEventId
});


@override $JobLiveCopyWith<$Res> get live;

}
/// @nodoc
class __$JobLiveStateCopyWithImpl<$Res>
    implements _$JobLiveStateCopyWith<$Res> {
  __$JobLiveStateCopyWithImpl(this._self, this._then);

  final _JobLiveState _self;
  final $Res Function(_JobLiveState) _then;

/// Create a copy of JobLiveState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? live = null,Object? connection = null,Object? lastEventId = null,}) {
  return _then(_JobLiveState(
live: null == live ? _self.live : live // ignore: cast_nullable_to_non_nullable
as JobLive,connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as SseConnection,lastEventId: null == lastEventId ? _self.lastEventId : lastEventId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of JobLiveState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JobLiveCopyWith<$Res> get live {
  
  return $JobLiveCopyWith<$Res>(_self.live, (value) {
    return _then(_self.copyWith(live: value));
  });
}
}

// dart format on
