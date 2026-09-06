// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'jobs.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$JobProgress {

 String get stage; int? get current; int? get total;
/// Create a copy of JobProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobProgressCopyWith<JobProgress> get copyWith => _$JobProgressCopyWithImpl<JobProgress>(this as JobProgress, _$identity);

  /// Serializes this JobProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as JobProgress;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobProgress&&(identical(other.stage, _this.stage) || other.stage == _this.stage)&&(identical(other.current, _this.current) || other.current == _this.current)&&(identical(other.total, _this.total) || other.total == _this.total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as JobProgress;
  return Object.hash(runtimeType,_this.stage,_this.current,_this.total);
}

@override
String toString() {
  final _this = this as JobProgress;
  return 'JobProgress(stage: ${_this.stage}, current: ${_this.current}, total: ${_this.total})';
}


}

/// @nodoc
abstract mixin class $JobProgressCopyWith<$Res>  {
  factory $JobProgressCopyWith(JobProgress value, $Res Function(JobProgress) _then) = _$JobProgressCopyWithImpl;
@useResult
$Res call({
 String stage, int? current, int? total
});




}
/// @nodoc
class _$JobProgressCopyWithImpl<$Res>
    implements $JobProgressCopyWith<$Res> {
  _$JobProgressCopyWithImpl(this._self, this._then);

  final JobProgress _self;
  final $Res Function(JobProgress) _then;

/// Create a copy of JobProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stage = null,Object? current = freezed,Object? total = freezed,}) {
  return _then(JobProgress(
stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as String,current: freezed == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int?,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [JobProgress].
extension JobProgressPatterns on JobProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JobProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JobProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JobProgress value)  $default,){
final _that = this;
switch (_that) {
case _JobProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JobProgress value)?  $default,){
final _that = this;
switch (_that) {
case _JobProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String stage,  int? current,  int? total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JobProgress() when $default != null:
return $default(_that.stage,_that.current,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String stage,  int? current,  int? total)  $default,) {final _that = this;
switch (_that) {
case _JobProgress():
return $default(_that.stage,_that.current,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String stage,  int? current,  int? total)?  $default,) {final _that = this;
switch (_that) {
case _JobProgress() when $default != null:
return $default(_that.stage,_that.current,_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JobProgress implements JobProgress {
  const _JobProgress({this.stage = '', this.current, this.total});
  factory _JobProgress.fromJson(Map<String, dynamic> json) => _$JobProgressFromJson(json);

@override@JsonKey() final  String stage;
@override final  int? current;
@override final  int? total;

/// Create a copy of JobProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JobProgressCopyWith<_JobProgress> get copyWith => __$JobProgressCopyWithImpl<_JobProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JobProgressToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _JobProgress&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.current, current) || other.current == current)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,stage,current,total);
}

@override
String toString() {
    return 'JobProgress(stage: $stage, current: $current, total: $total)';
}


}

/// @nodoc
abstract mixin class _$JobProgressCopyWith<$Res> implements $JobProgressCopyWith<$Res> {
  factory _$JobProgressCopyWith(_JobProgress value, $Res Function(_JobProgress) _then) = __$JobProgressCopyWithImpl;
@override @useResult
$Res call({
 String stage, int? current, int? total
});




}
/// @nodoc
class __$JobProgressCopyWithImpl<$Res>
    implements _$JobProgressCopyWith<$Res> {
  __$JobProgressCopyWithImpl(this._self, this._then);

  final _JobProgress _self;
  final $Res Function(_JobProgress) _then;

/// Create a copy of JobProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stage = null,Object? current = freezed,Object? total = freezed,}) {
  return _then(_JobProgress(
stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as String,current: freezed == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int?,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$Job {

 String get id; JobKind get kind; JobStatus get status; String? get userId; Map<String, dynamic> get params; JobProgress? get progress; JobError? get error; Map<String, dynamic>? get result; DateTime get createdAt; DateTime? get startedAt; DateTime? get finishedAt;
/// Create a copy of Job
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobCopyWith<Job> get copyWith => _$JobCopyWithImpl<Job>(this as Job, _$identity);

  /// Serializes this Job to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Job;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Job&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&const DeepCollectionEquality().equals(other.params, _this.params)&&(identical(other.progress, _this.progress) || other.progress == _this.progress)&&(identical(other.error, _this.error) || other.error == _this.error)&&const DeepCollectionEquality().equals(other.result, _this.result)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.finishedAt, _this.finishedAt) || other.finishedAt == _this.finishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Job;
  return Object.hash(runtimeType,_this.id,_this.kind,_this.status,_this.userId,const DeepCollectionEquality().hash(_this.params),_this.progress,_this.error,const DeepCollectionEquality().hash(_this.result),_this.createdAt,_this.startedAt,_this.finishedAt);
}

@override
String toString() {
  final _this = this as Job;
  return 'Job(id: ${_this.id}, kind: ${_this.kind}, status: ${_this.status}, userId: ${_this.userId}, params: ${_this.params}, progress: ${_this.progress}, error: ${_this.error}, result: ${_this.result}, createdAt: ${_this.createdAt}, startedAt: ${_this.startedAt}, finishedAt: ${_this.finishedAt})';
}


}

/// @nodoc
abstract mixin class $JobCopyWith<$Res>  {
  factory $JobCopyWith(Job value, $Res Function(Job) _then) = _$JobCopyWithImpl;
@useResult
$Res call({
 String id, JobKind kind, JobStatus status, String? userId, Map<String, dynamic> params, JobProgress? progress, JobError? error, Map<String, dynamic>? result, DateTime createdAt, DateTime? startedAt, DateTime? finishedAt
});


$JobProgressCopyWith<$Res>? get progress;$JobErrorCopyWith<$Res>? get error;

}
/// @nodoc
class _$JobCopyWithImpl<$Res>
    implements $JobCopyWith<$Res> {
  _$JobCopyWithImpl(this._self, this._then);

  final Job _self;
  final $Res Function(Job) _then;

/// Create a copy of Job
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? status = null,Object? userId = freezed,Object? params = null,Object? progress = freezed,Object? error = freezed,Object? result = freezed,Object? createdAt = null,Object? startedAt = freezed,Object? finishedAt = freezed,}) {
  return _then(Job(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as JobKind,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as JobStatus,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,params: null == params ? _self.params : params // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as JobProgress?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as JobError?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Job
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JobProgressCopyWith<$Res>? get progress {
    if (_self.progress == null) {
    return null;
  }

  return $JobProgressCopyWith<$Res>(_self.progress!, (value) {
    return _then(_self.copyWith(progress: value));
  });
}/// Create a copy of Job
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JobErrorCopyWith<$Res>? get error {
    if (_self.error == null) {
    return null;
  }

  return $JobErrorCopyWith<$Res>(_self.error!, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}


/// Adds pattern-matching-related methods to [Job].
extension JobPatterns on Job {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Job value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Job() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Job value)  $default,){
final _that = this;
switch (_that) {
case _Job():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Job value)?  $default,){
final _that = this;
switch (_that) {
case _Job() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  JobKind kind,  JobStatus status,  String? userId,  Map<String, dynamic> params,  JobProgress? progress,  JobError? error,  Map<String, dynamic>? result,  DateTime createdAt,  DateTime? startedAt,  DateTime? finishedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Job() when $default != null:
return $default(_that.id,_that.kind,_that.status,_that.userId,_that.params,_that.progress,_that.error,_that.result,_that.createdAt,_that.startedAt,_that.finishedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  JobKind kind,  JobStatus status,  String? userId,  Map<String, dynamic> params,  JobProgress? progress,  JobError? error,  Map<String, dynamic>? result,  DateTime createdAt,  DateTime? startedAt,  DateTime? finishedAt)  $default,) {final _that = this;
switch (_that) {
case _Job():
return $default(_that.id,_that.kind,_that.status,_that.userId,_that.params,_that.progress,_that.error,_that.result,_that.createdAt,_that.startedAt,_that.finishedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  JobKind kind,  JobStatus status,  String? userId,  Map<String, dynamic> params,  JobProgress? progress,  JobError? error,  Map<String, dynamic>? result,  DateTime createdAt,  DateTime? startedAt,  DateTime? finishedAt)?  $default,) {final _that = this;
switch (_that) {
case _Job() when $default != null:
return $default(_that.id,_that.kind,_that.status,_that.userId,_that.params,_that.progress,_that.error,_that.result,_that.createdAt,_that.startedAt,_that.finishedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Job implements Job {
  const _Job({required this.id, required this.kind, required this.status, this.userId,  Map<String, dynamic> params = const <String, dynamic>{}, this.progress, this.error,  Map<String, dynamic>? result, required this.createdAt, this.startedAt, this.finishedAt}): _params = params,_result = result;
  factory _Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);

@override final  String id;
@override final  JobKind kind;
@override final  JobStatus status;
@override final  String? userId;
 final  Map<String, dynamic> _params;
@override@JsonKey() Map<String, dynamic> get params {
  if (_params is EqualUnmodifiableMapView) return _params;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_params);
}

@override final  JobProgress? progress;
@override final  JobError? error;
 final  Map<String, dynamic>? _result;
@override Map<String, dynamic>? get result {
  final value = _result;
  if (value == null) return null;
  if (_result is EqualUnmodifiableMapView) return _result;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime createdAt;
@override final  DateTime? startedAt;
@override final  DateTime? finishedAt;

/// Create a copy of Job
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JobCopyWith<_Job> get copyWith => __$JobCopyWithImpl<_Job>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JobToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Job&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.status, status) || other.status == status)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other.params, _params)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.result, _result)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,kind,status,userId,const DeepCollectionEquality().hash(_params),progress,error,const DeepCollectionEquality().hash(_result),createdAt,startedAt,finishedAt);
}

@override
String toString() {
    return 'Job(id: $id, kind: $kind, status: $status, userId: $userId, params: $params, progress: $progress, error: $error, result: $result, createdAt: $createdAt, startedAt: $startedAt, finishedAt: $finishedAt)';
}


}

/// @nodoc
abstract mixin class _$JobCopyWith<$Res> implements $JobCopyWith<$Res> {
  factory _$JobCopyWith(_Job value, $Res Function(_Job) _then) = __$JobCopyWithImpl;
@override @useResult
$Res call({
 String id, JobKind kind, JobStatus status, String? userId, Map<String, dynamic> params, JobProgress? progress, JobError? error, Map<String, dynamic>? result, DateTime createdAt, DateTime? startedAt, DateTime? finishedAt
});


@override $JobProgressCopyWith<$Res>? get progress;@override $JobErrorCopyWith<$Res>? get error;

}
/// @nodoc
class __$JobCopyWithImpl<$Res>
    implements _$JobCopyWith<$Res> {
  __$JobCopyWithImpl(this._self, this._then);

  final _Job _self;
  final $Res Function(_Job) _then;

/// Create a copy of Job
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? status = null,Object? userId = freezed,Object? params = null,Object? progress = freezed,Object? error = freezed,Object? result = freezed,Object? createdAt = null,Object? startedAt = freezed,Object? finishedAt = freezed,}) {
  return _then(_Job(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as JobKind,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as JobStatus,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,params: null == params ? _self._params : params // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as JobProgress?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as JobError?,result: freezed == result ? _self._result : result // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of Job
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JobProgressCopyWith<$Res>? get progress {
    if (_self.progress == null) {
    return null;
  }

  return $JobProgressCopyWith<$Res>(_self.progress!, (value) {
    return _then(_self.copyWith(progress: value));
  });
}/// Create a copy of Job
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JobErrorCopyWith<$Res>? get error {
    if (_self.error == null) {
    return null;
  }

  return $JobErrorCopyWith<$Res>(_self.error!, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}

// dart format on
