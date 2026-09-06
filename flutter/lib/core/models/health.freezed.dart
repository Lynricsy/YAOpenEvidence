// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HealthResponse {

 String get status; String get version; DateTime get time;
/// Create a copy of HealthResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthResponseCopyWith<HealthResponse> get copyWith => _$HealthResponseCopyWithImpl<HealthResponse>(this as HealthResponse, _$identity);

  /// Serializes this HealthResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HealthResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthResponse&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.time, _this.time) || other.time == _this.time));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HealthResponse;
  return Object.hash(runtimeType,_this.status,_this.version,_this.time);
}

@override
String toString() {
  final _this = this as HealthResponse;
  return 'HealthResponse(status: ${_this.status}, version: ${_this.version}, time: ${_this.time})';
}


}

/// @nodoc
abstract mixin class $HealthResponseCopyWith<$Res>  {
  factory $HealthResponseCopyWith(HealthResponse value, $Res Function(HealthResponse) _then) = _$HealthResponseCopyWithImpl;
@useResult
$Res call({
 String status, String version, DateTime time
});




}
/// @nodoc
class _$HealthResponseCopyWithImpl<$Res>
    implements $HealthResponseCopyWith<$Res> {
  _$HealthResponseCopyWithImpl(this._self, this._then);

  final HealthResponse _self;
  final $Res Function(HealthResponse) _then;

/// Create a copy of HealthResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? version = null,Object? time = null,}) {
  return _then(HealthResponse(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthResponse].
extension HealthResponsePatterns on HealthResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthResponse value)  $default,){
final _that = this;
switch (_that) {
case _HealthResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthResponse value)?  $default,){
final _that = this;
switch (_that) {
case _HealthResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String status,  String version,  DateTime time)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthResponse() when $default != null:
return $default(_that.status,_that.version,_that.time);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String status,  String version,  DateTime time)  $default,) {final _that = this;
switch (_that) {
case _HealthResponse():
return $default(_that.status,_that.version,_that.time);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String status,  String version,  DateTime time)?  $default,) {final _that = this;
switch (_that) {
case _HealthResponse() when $default != null:
return $default(_that.status,_that.version,_that.time);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HealthResponse implements HealthResponse {
  const _HealthResponse({this.status = '', this.version = '', required this.time});
  factory _HealthResponse.fromJson(Map<String, dynamic> json) => _$HealthResponseFromJson(json);

@override@JsonKey() final  String status;
@override@JsonKey() final  String version;
@override final  DateTime time;

/// Create a copy of HealthResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthResponseCopyWith<_HealthResponse> get copyWith => __$HealthResponseCopyWithImpl<_HealthResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HealthResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthResponse&&(identical(other.status, status) || other.status == status)&&(identical(other.version, version) || other.version == version)&&(identical(other.time, time) || other.time == time));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,status,version,time);
}

@override
String toString() {
    return 'HealthResponse(status: $status, version: $version, time: $time)';
}


}

/// @nodoc
abstract mixin class _$HealthResponseCopyWith<$Res> implements $HealthResponseCopyWith<$Res> {
  factory _$HealthResponseCopyWith(_HealthResponse value, $Res Function(_HealthResponse) _then) = __$HealthResponseCopyWithImpl;
@override @useResult
$Res call({
 String status, String version, DateTime time
});




}
/// @nodoc
class __$HealthResponseCopyWithImpl<$Res>
    implements _$HealthResponseCopyWith<$Res> {
  __$HealthResponseCopyWithImpl(this._self, this._then);

  final _HealthResponse _self;
  final $Res Function(_HealthResponse) _then;

/// Create a copy of HealthResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? version = null,Object? time = null,}) {
  return _then(_HealthResponse(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$DependencyCheck {

 bool get ok; String get detail;
/// Create a copy of DependencyCheck
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DependencyCheckCopyWith<DependencyCheck> get copyWith => _$DependencyCheckCopyWithImpl<DependencyCheck>(this as DependencyCheck, _$identity);

  /// Serializes this DependencyCheck to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DependencyCheck;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DependencyCheck&&(identical(other.ok, _this.ok) || other.ok == _this.ok)&&(identical(other.detail, _this.detail) || other.detail == _this.detail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DependencyCheck;
  return Object.hash(runtimeType,_this.ok,_this.detail);
}

@override
String toString() {
  final _this = this as DependencyCheck;
  return 'DependencyCheck(ok: ${_this.ok}, detail: ${_this.detail})';
}


}

/// @nodoc
abstract mixin class $DependencyCheckCopyWith<$Res>  {
  factory $DependencyCheckCopyWith(DependencyCheck value, $Res Function(DependencyCheck) _then) = _$DependencyCheckCopyWithImpl;
@useResult
$Res call({
 bool ok, String detail
});




}
/// @nodoc
class _$DependencyCheckCopyWithImpl<$Res>
    implements $DependencyCheckCopyWith<$Res> {
  _$DependencyCheckCopyWithImpl(this._self, this._then);

  final DependencyCheck _self;
  final $Res Function(DependencyCheck) _then;

/// Create a copy of DependencyCheck
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ok = null,Object? detail = null,}) {
  return _then(DependencyCheck(
ok: null == ok ? _self.ok : ok // ignore: cast_nullable_to_non_nullable
as bool,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DependencyCheck].
extension DependencyCheckPatterns on DependencyCheck {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DependencyCheck value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DependencyCheck() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DependencyCheck value)  $default,){
final _that = this;
switch (_that) {
case _DependencyCheck():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DependencyCheck value)?  $default,){
final _that = this;
switch (_that) {
case _DependencyCheck() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool ok,  String detail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DependencyCheck() when $default != null:
return $default(_that.ok,_that.detail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool ok,  String detail)  $default,) {final _that = this;
switch (_that) {
case _DependencyCheck():
return $default(_that.ok,_that.detail);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool ok,  String detail)?  $default,) {final _that = this;
switch (_that) {
case _DependencyCheck() when $default != null:
return $default(_that.ok,_that.detail);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DependencyCheck implements DependencyCheck {
  const _DependencyCheck({this.ok = false, this.detail = ''});
  factory _DependencyCheck.fromJson(Map<String, dynamic> json) => _$DependencyCheckFromJson(json);

@override@JsonKey() final  bool ok;
@override@JsonKey() final  String detail;

/// Create a copy of DependencyCheck
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DependencyCheckCopyWith<_DependencyCheck> get copyWith => __$DependencyCheckCopyWithImpl<_DependencyCheck>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DependencyCheckToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DependencyCheck&&(identical(other.ok, ok) || other.ok == ok)&&(identical(other.detail, detail) || other.detail == detail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,ok,detail);
}

@override
String toString() {
    return 'DependencyCheck(ok: $ok, detail: $detail)';
}


}

/// @nodoc
abstract mixin class _$DependencyCheckCopyWith<$Res> implements $DependencyCheckCopyWith<$Res> {
  factory _$DependencyCheckCopyWith(_DependencyCheck value, $Res Function(_DependencyCheck) _then) = __$DependencyCheckCopyWithImpl;
@override @useResult
$Res call({
 bool ok, String detail
});




}
/// @nodoc
class __$DependencyCheckCopyWithImpl<$Res>
    implements _$DependencyCheckCopyWith<$Res> {
  __$DependencyCheckCopyWithImpl(this._self, this._then);

  final _DependencyCheck _self;
  final $Res Function(_DependencyCheck) _then;

/// Create a copy of DependencyCheck
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ok = null,Object? detail = null,}) {
  return _then(_DependencyCheck(
ok: null == ok ? _self.ok : ok // ignore: cast_nullable_to_non_nullable
as bool,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ReadinessChecks {

 DependencyCheck get db; DependencyCheck get redis; DependencyCheck get llm; DependencyCheck get kb; DependencyCheck get ranks;
/// Create a copy of ReadinessChecks
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadinessChecksCopyWith<ReadinessChecks> get copyWith => _$ReadinessChecksCopyWithImpl<ReadinessChecks>(this as ReadinessChecks, _$identity);

  /// Serializes this ReadinessChecks to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReadinessChecks;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadinessChecks&&(identical(other.db, _this.db) || other.db == _this.db)&&(identical(other.redis, _this.redis) || other.redis == _this.redis)&&(identical(other.llm, _this.llm) || other.llm == _this.llm)&&(identical(other.kb, _this.kb) || other.kb == _this.kb)&&(identical(other.ranks, _this.ranks) || other.ranks == _this.ranks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReadinessChecks;
  return Object.hash(runtimeType,_this.db,_this.redis,_this.llm,_this.kb,_this.ranks);
}

@override
String toString() {
  final _this = this as ReadinessChecks;
  return 'ReadinessChecks(db: ${_this.db}, redis: ${_this.redis}, llm: ${_this.llm}, kb: ${_this.kb}, ranks: ${_this.ranks})';
}


}

/// @nodoc
abstract mixin class $ReadinessChecksCopyWith<$Res>  {
  factory $ReadinessChecksCopyWith(ReadinessChecks value, $Res Function(ReadinessChecks) _then) = _$ReadinessChecksCopyWithImpl;
@useResult
$Res call({
 DependencyCheck db, DependencyCheck redis, DependencyCheck llm, DependencyCheck kb, DependencyCheck ranks
});


$DependencyCheckCopyWith<$Res> get db;$DependencyCheckCopyWith<$Res> get redis;$DependencyCheckCopyWith<$Res> get llm;$DependencyCheckCopyWith<$Res> get kb;$DependencyCheckCopyWith<$Res> get ranks;

}
/// @nodoc
class _$ReadinessChecksCopyWithImpl<$Res>
    implements $ReadinessChecksCopyWith<$Res> {
  _$ReadinessChecksCopyWithImpl(this._self, this._then);

  final ReadinessChecks _self;
  final $Res Function(ReadinessChecks) _then;

/// Create a copy of ReadinessChecks
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? db = null,Object? redis = null,Object? llm = null,Object? kb = null,Object? ranks = null,}) {
  return _then(ReadinessChecks(
db: null == db ? _self.db : db // ignore: cast_nullable_to_non_nullable
as DependencyCheck,redis: null == redis ? _self.redis : redis // ignore: cast_nullable_to_non_nullable
as DependencyCheck,llm: null == llm ? _self.llm : llm // ignore: cast_nullable_to_non_nullable
as DependencyCheck,kb: null == kb ? _self.kb : kb // ignore: cast_nullable_to_non_nullable
as DependencyCheck,ranks: null == ranks ? _self.ranks : ranks // ignore: cast_nullable_to_non_nullable
as DependencyCheck,
  ));
}
/// Create a copy of ReadinessChecks
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DependencyCheckCopyWith<$Res> get db {
  
  return $DependencyCheckCopyWith<$Res>(_self.db, (value) {
    return _then(_self.copyWith(db: value));
  });
}/// Create a copy of ReadinessChecks
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DependencyCheckCopyWith<$Res> get redis {
  
  return $DependencyCheckCopyWith<$Res>(_self.redis, (value) {
    return _then(_self.copyWith(redis: value));
  });
}/// Create a copy of ReadinessChecks
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DependencyCheckCopyWith<$Res> get llm {
  
  return $DependencyCheckCopyWith<$Res>(_self.llm, (value) {
    return _then(_self.copyWith(llm: value));
  });
}/// Create a copy of ReadinessChecks
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DependencyCheckCopyWith<$Res> get kb {
  
  return $DependencyCheckCopyWith<$Res>(_self.kb, (value) {
    return _then(_self.copyWith(kb: value));
  });
}/// Create a copy of ReadinessChecks
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DependencyCheckCopyWith<$Res> get ranks {
  
  return $DependencyCheckCopyWith<$Res>(_self.ranks, (value) {
    return _then(_self.copyWith(ranks: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReadinessChecks].
extension ReadinessChecksPatterns on ReadinessChecks {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReadinessChecks value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReadinessChecks() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReadinessChecks value)  $default,){
final _that = this;
switch (_that) {
case _ReadinessChecks():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReadinessChecks value)?  $default,){
final _that = this;
switch (_that) {
case _ReadinessChecks() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DependencyCheck db,  DependencyCheck redis,  DependencyCheck llm,  DependencyCheck kb,  DependencyCheck ranks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReadinessChecks() when $default != null:
return $default(_that.db,_that.redis,_that.llm,_that.kb,_that.ranks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DependencyCheck db,  DependencyCheck redis,  DependencyCheck llm,  DependencyCheck kb,  DependencyCheck ranks)  $default,) {final _that = this;
switch (_that) {
case _ReadinessChecks():
return $default(_that.db,_that.redis,_that.llm,_that.kb,_that.ranks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DependencyCheck db,  DependencyCheck redis,  DependencyCheck llm,  DependencyCheck kb,  DependencyCheck ranks)?  $default,) {final _that = this;
switch (_that) {
case _ReadinessChecks() when $default != null:
return $default(_that.db,_that.redis,_that.llm,_that.kb,_that.ranks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReadinessChecks implements ReadinessChecks {
  const _ReadinessChecks({required this.db, required this.redis, required this.llm, required this.kb, required this.ranks});
  factory _ReadinessChecks.fromJson(Map<String, dynamic> json) => _$ReadinessChecksFromJson(json);

@override final  DependencyCheck db;
@override final  DependencyCheck redis;
@override final  DependencyCheck llm;
@override final  DependencyCheck kb;
@override final  DependencyCheck ranks;

/// Create a copy of ReadinessChecks
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadinessChecksCopyWith<_ReadinessChecks> get copyWith => __$ReadinessChecksCopyWithImpl<_ReadinessChecks>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReadinessChecksToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReadinessChecks&&(identical(other.db, db) || other.db == db)&&(identical(other.redis, redis) || other.redis == redis)&&(identical(other.llm, llm) || other.llm == llm)&&(identical(other.kb, kb) || other.kb == kb)&&(identical(other.ranks, ranks) || other.ranks == ranks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,db,redis,llm,kb,ranks);
}

@override
String toString() {
    return 'ReadinessChecks(db: $db, redis: $redis, llm: $llm, kb: $kb, ranks: $ranks)';
}


}

/// @nodoc
abstract mixin class _$ReadinessChecksCopyWith<$Res> implements $ReadinessChecksCopyWith<$Res> {
  factory _$ReadinessChecksCopyWith(_ReadinessChecks value, $Res Function(_ReadinessChecks) _then) = __$ReadinessChecksCopyWithImpl;
@override @useResult
$Res call({
 DependencyCheck db, DependencyCheck redis, DependencyCheck llm, DependencyCheck kb, DependencyCheck ranks
});


@override $DependencyCheckCopyWith<$Res> get db;@override $DependencyCheckCopyWith<$Res> get redis;@override $DependencyCheckCopyWith<$Res> get llm;@override $DependencyCheckCopyWith<$Res> get kb;@override $DependencyCheckCopyWith<$Res> get ranks;

}
/// @nodoc
class __$ReadinessChecksCopyWithImpl<$Res>
    implements _$ReadinessChecksCopyWith<$Res> {
  __$ReadinessChecksCopyWithImpl(this._self, this._then);

  final _ReadinessChecks _self;
  final $Res Function(_ReadinessChecks) _then;

/// Create a copy of ReadinessChecks
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? db = null,Object? redis = null,Object? llm = null,Object? kb = null,Object? ranks = null,}) {
  return _then(_ReadinessChecks(
db: null == db ? _self.db : db // ignore: cast_nullable_to_non_nullable
as DependencyCheck,redis: null == redis ? _self.redis : redis // ignore: cast_nullable_to_non_nullable
as DependencyCheck,llm: null == llm ? _self.llm : llm // ignore: cast_nullable_to_non_nullable
as DependencyCheck,kb: null == kb ? _self.kb : kb // ignore: cast_nullable_to_non_nullable
as DependencyCheck,ranks: null == ranks ? _self.ranks : ranks // ignore: cast_nullable_to_non_nullable
as DependencyCheck,
  ));
}

/// Create a copy of ReadinessChecks
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DependencyCheckCopyWith<$Res> get db {
  
  return $DependencyCheckCopyWith<$Res>(_self.db, (value) {
    return _then(_self.copyWith(db: value));
  });
}/// Create a copy of ReadinessChecks
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DependencyCheckCopyWith<$Res> get redis {
  
  return $DependencyCheckCopyWith<$Res>(_self.redis, (value) {
    return _then(_self.copyWith(redis: value));
  });
}/// Create a copy of ReadinessChecks
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DependencyCheckCopyWith<$Res> get llm {
  
  return $DependencyCheckCopyWith<$Res>(_self.llm, (value) {
    return _then(_self.copyWith(llm: value));
  });
}/// Create a copy of ReadinessChecks
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DependencyCheckCopyWith<$Res> get kb {
  
  return $DependencyCheckCopyWith<$Res>(_self.kb, (value) {
    return _then(_self.copyWith(kb: value));
  });
}/// Create a copy of ReadinessChecks
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DependencyCheckCopyWith<$Res> get ranks {
  
  return $DependencyCheckCopyWith<$Res>(_self.ranks, (value) {
    return _then(_self.copyWith(ranks: value));
  });
}
}


/// @nodoc
mixin _$ReadinessResponse {

 String get status; ReadinessChecks get checks;
/// Create a copy of ReadinessResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadinessResponseCopyWith<ReadinessResponse> get copyWith => _$ReadinessResponseCopyWithImpl<ReadinessResponse>(this as ReadinessResponse, _$identity);

  /// Serializes this ReadinessResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReadinessResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadinessResponse&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.checks, _this.checks) || other.checks == _this.checks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReadinessResponse;
  return Object.hash(runtimeType,_this.status,_this.checks);
}

@override
String toString() {
  final _this = this as ReadinessResponse;
  return 'ReadinessResponse(status: ${_this.status}, checks: ${_this.checks})';
}


}

/// @nodoc
abstract mixin class $ReadinessResponseCopyWith<$Res>  {
  factory $ReadinessResponseCopyWith(ReadinessResponse value, $Res Function(ReadinessResponse) _then) = _$ReadinessResponseCopyWithImpl;
@useResult
$Res call({
 String status, ReadinessChecks checks
});


$ReadinessChecksCopyWith<$Res> get checks;

}
/// @nodoc
class _$ReadinessResponseCopyWithImpl<$Res>
    implements $ReadinessResponseCopyWith<$Res> {
  _$ReadinessResponseCopyWithImpl(this._self, this._then);

  final ReadinessResponse _self;
  final $Res Function(ReadinessResponse) _then;

/// Create a copy of ReadinessResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? checks = null,}) {
  return _then(ReadinessResponse(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,checks: null == checks ? _self.checks : checks // ignore: cast_nullable_to_non_nullable
as ReadinessChecks,
  ));
}
/// Create a copy of ReadinessResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReadinessChecksCopyWith<$Res> get checks {
  
  return $ReadinessChecksCopyWith<$Res>(_self.checks, (value) {
    return _then(_self.copyWith(checks: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReadinessResponse].
extension ReadinessResponsePatterns on ReadinessResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReadinessResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReadinessResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReadinessResponse value)  $default,){
final _that = this;
switch (_that) {
case _ReadinessResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReadinessResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ReadinessResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String status,  ReadinessChecks checks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReadinessResponse() when $default != null:
return $default(_that.status,_that.checks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String status,  ReadinessChecks checks)  $default,) {final _that = this;
switch (_that) {
case _ReadinessResponse():
return $default(_that.status,_that.checks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String status,  ReadinessChecks checks)?  $default,) {final _that = this;
switch (_that) {
case _ReadinessResponse() when $default != null:
return $default(_that.status,_that.checks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReadinessResponse implements ReadinessResponse {
  const _ReadinessResponse({this.status = '', required this.checks});
  factory _ReadinessResponse.fromJson(Map<String, dynamic> json) => _$ReadinessResponseFromJson(json);

@override@JsonKey() final  String status;
@override final  ReadinessChecks checks;

/// Create a copy of ReadinessResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadinessResponseCopyWith<_ReadinessResponse> get copyWith => __$ReadinessResponseCopyWithImpl<_ReadinessResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReadinessResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReadinessResponse&&(identical(other.status, status) || other.status == status)&&(identical(other.checks, checks) || other.checks == checks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,status,checks);
}

@override
String toString() {
    return 'ReadinessResponse(status: $status, checks: $checks)';
}


}

/// @nodoc
abstract mixin class _$ReadinessResponseCopyWith<$Res> implements $ReadinessResponseCopyWith<$Res> {
  factory _$ReadinessResponseCopyWith(_ReadinessResponse value, $Res Function(_ReadinessResponse) _then) = __$ReadinessResponseCopyWithImpl;
@override @useResult
$Res call({
 String status, ReadinessChecks checks
});


@override $ReadinessChecksCopyWith<$Res> get checks;

}
/// @nodoc
class __$ReadinessResponseCopyWithImpl<$Res>
    implements _$ReadinessResponseCopyWith<$Res> {
  __$ReadinessResponseCopyWithImpl(this._self, this._then);

  final _ReadinessResponse _self;
  final $Res Function(_ReadinessResponse) _then;

/// Create a copy of ReadinessResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? checks = null,}) {
  return _then(_ReadinessResponse(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,checks: null == checks ? _self.checks : checks // ignore: cast_nullable_to_non_nullable
as ReadinessChecks,
  ));
}

/// Create a copy of ReadinessResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReadinessChecksCopyWith<$Res> get checks {
  
  return $ReadinessChecksCopyWith<$Res>(_self.checks, (value) {
    return _then(_self.copyWith(checks: value));
  });
}
}

// dart format on
