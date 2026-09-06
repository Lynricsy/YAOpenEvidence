// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job_live.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StageState {

 StageStatus get status; Map<String, dynamic> get detail;
/// Create a copy of StageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StageStateCopyWith<StageState> get copyWith => _$StageStateCopyWithImpl<StageState>(this as StageState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StageState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StageState&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.detail, _this.detail));
}


@override
int get hashCode {
  final _this = this as StageState;
  return Object.hash(runtimeType,_this.status,const DeepCollectionEquality().hash(_this.detail));
}

@override
String toString() {
  final _this = this as StageState;
  return 'StageState(status: ${_this.status}, detail: ${_this.detail})';
}


}

/// @nodoc
abstract mixin class $StageStateCopyWith<$Res>  {
  factory $StageStateCopyWith(StageState value, $Res Function(StageState) _then) = _$StageStateCopyWithImpl;
@useResult
$Res call({
 StageStatus status, Map<String, dynamic> detail
});




}
/// @nodoc
class _$StageStateCopyWithImpl<$Res>
    implements $StageStateCopyWith<$Res> {
  _$StageStateCopyWithImpl(this._self, this._then);

  final StageState _self;
  final $Res Function(StageState) _then;

/// Create a copy of StageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? detail = null,}) {
  return _then(StageState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StageStatus,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [StageState].
extension StageStatePatterns on StageState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StageState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StageState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StageState value)  $default,){
final _that = this;
switch (_that) {
case _StageState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StageState value)?  $default,){
final _that = this;
switch (_that) {
case _StageState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StageStatus status,  Map<String, dynamic> detail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StageState() when $default != null:
return $default(_that.status,_that.detail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StageStatus status,  Map<String, dynamic> detail)  $default,) {final _that = this;
switch (_that) {
case _StageState():
return $default(_that.status,_that.detail);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StageStatus status,  Map<String, dynamic> detail)?  $default,) {final _that = this;
switch (_that) {
case _StageState() when $default != null:
return $default(_that.status,_that.detail);case _:
  return null;

}
}

}

/// @nodoc


class _StageState implements StageState {
  const _StageState({required this.status,  Map<String, dynamic> detail = const <String, dynamic>{}}): _detail = detail;
  

@override final  StageStatus status;
 final  Map<String, dynamic> _detail;
@override@JsonKey() Map<String, dynamic> get detail {
  if (_detail is EqualUnmodifiableMapView) return _detail;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_detail);
}


/// Create a copy of StageState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StageStateCopyWith<_StageState> get copyWith => __$StageStateCopyWithImpl<_StageState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StageState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.detail, _detail));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_detail));
}

@override
String toString() {
    return 'StageState(status: $status, detail: $detail)';
}


}

/// @nodoc
abstract mixin class _$StageStateCopyWith<$Res> implements $StageStateCopyWith<$Res> {
  factory _$StageStateCopyWith(_StageState value, $Res Function(_StageState) _then) = __$StageStateCopyWithImpl;
@override @useResult
$Res call({
 StageStatus status, Map<String, dynamic> detail
});




}
/// @nodoc
class __$StageStateCopyWithImpl<$Res>
    implements _$StageStateCopyWith<$Res> {
  __$StageStateCopyWithImpl(this._self, this._then);

  final _StageState _self;
  final $Res Function(_StageState) _then;

/// Create a copy of StageState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? detail = null,}) {
  return _then(_StageState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StageStatus,detail: null == detail ? _self._detail : detail // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

/// @nodoc
mixin _$ProgressState {

 StageKey get stage; int get current; int get total; String? get title;
/// Create a copy of ProgressState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProgressStateCopyWith<ProgressState> get copyWith => _$ProgressStateCopyWithImpl<ProgressState>(this as ProgressState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProgressState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProgressState&&(identical(other.stage, _this.stage) || other.stage == _this.stage)&&(identical(other.current, _this.current) || other.current == _this.current)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.title, _this.title) || other.title == _this.title));
}


@override
int get hashCode {
  final _this = this as ProgressState;
  return Object.hash(runtimeType,_this.stage,_this.current,_this.total,_this.title);
}

@override
String toString() {
  final _this = this as ProgressState;
  return 'ProgressState(stage: ${_this.stage}, current: ${_this.current}, total: ${_this.total}, title: ${_this.title})';
}


}

/// @nodoc
abstract mixin class $ProgressStateCopyWith<$Res>  {
  factory $ProgressStateCopyWith(ProgressState value, $Res Function(ProgressState) _then) = _$ProgressStateCopyWithImpl;
@useResult
$Res call({
 StageKey stage, int current, int total, String? title
});




}
/// @nodoc
class _$ProgressStateCopyWithImpl<$Res>
    implements $ProgressStateCopyWith<$Res> {
  _$ProgressStateCopyWithImpl(this._self, this._then);

  final ProgressState _self;
  final $Res Function(ProgressState) _then;

/// Create a copy of ProgressState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stage = null,Object? current = null,Object? total = null,Object? title = freezed,}) {
  return _then(ProgressState(
stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as StageKey,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProgressState].
extension ProgressStatePatterns on ProgressState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProgressState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProgressState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProgressState value)  $default,){
final _that = this;
switch (_that) {
case _ProgressState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProgressState value)?  $default,){
final _that = this;
switch (_that) {
case _ProgressState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StageKey stage,  int current,  int total,  String? title)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProgressState() when $default != null:
return $default(_that.stage,_that.current,_that.total,_that.title);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StageKey stage,  int current,  int total,  String? title)  $default,) {final _that = this;
switch (_that) {
case _ProgressState():
return $default(_that.stage,_that.current,_that.total,_that.title);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StageKey stage,  int current,  int total,  String? title)?  $default,) {final _that = this;
switch (_that) {
case _ProgressState() when $default != null:
return $default(_that.stage,_that.current,_that.total,_that.title);case _:
  return null;

}
}

}

/// @nodoc


class _ProgressState implements ProgressState {
  const _ProgressState({required this.stage, this.current = 0, this.total = 0, this.title});
  

@override final  StageKey stage;
@override@JsonKey() final  int current;
@override@JsonKey() final  int total;
@override final  String? title;

/// Create a copy of ProgressState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProgressStateCopyWith<_ProgressState> get copyWith => __$ProgressStateCopyWithImpl<_ProgressState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProgressState&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.current, current) || other.current == current)&&(identical(other.total, total) || other.total == total)&&(identical(other.title, title) || other.title == title));
}


@override
int get hashCode {
    return Object.hash(runtimeType,stage,current,total,title);
}

@override
String toString() {
    return 'ProgressState(stage: $stage, current: $current, total: $total, title: $title)';
}


}

/// @nodoc
abstract mixin class _$ProgressStateCopyWith<$Res> implements $ProgressStateCopyWith<$Res> {
  factory _$ProgressStateCopyWith(_ProgressState value, $Res Function(_ProgressState) _then) = __$ProgressStateCopyWithImpl;
@override @useResult
$Res call({
 StageKey stage, int current, int total, String? title
});




}
/// @nodoc
class __$ProgressStateCopyWithImpl<$Res>
    implements _$ProgressStateCopyWith<$Res> {
  __$ProgressStateCopyWithImpl(this._self, this._then);

  final _ProgressState _self;
  final $Res Function(_ProgressState) _then;

/// Create a copy of ProgressState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stage = null,Object? current = null,Object? total = null,Object? title = freezed,}) {
  return _then(_ProgressState(
stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as StageKey,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$LogLine {

 LogLevel get level; String get message;
/// Create a copy of LogLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LogLineCopyWith<LogLine> get copyWith => _$LogLineCopyWithImpl<LogLine>(this as LogLine, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LogLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogLine&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.message, _this.message) || other.message == _this.message));
}


@override
int get hashCode {
  final _this = this as LogLine;
  return Object.hash(runtimeType,_this.level,_this.message);
}

@override
String toString() {
  final _this = this as LogLine;
  return 'LogLine(level: ${_this.level}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $LogLineCopyWith<$Res>  {
  factory $LogLineCopyWith(LogLine value, $Res Function(LogLine) _then) = _$LogLineCopyWithImpl;
@useResult
$Res call({
 LogLevel level, String message
});




}
/// @nodoc
class _$LogLineCopyWithImpl<$Res>
    implements $LogLineCopyWith<$Res> {
  _$LogLineCopyWithImpl(this._self, this._then);

  final LogLine _self;
  final $Res Function(LogLine) _then;

/// Create a copy of LogLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? level = null,Object? message = null,}) {
  return _then(LogLine(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as LogLevel,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LogLine].
extension LogLinePatterns on LogLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LogLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LogLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LogLine value)  $default,){
final _that = this;
switch (_that) {
case _LogLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LogLine value)?  $default,){
final _that = this;
switch (_that) {
case _LogLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LogLevel level,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LogLine() when $default != null:
return $default(_that.level,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LogLevel level,  String message)  $default,) {final _that = this;
switch (_that) {
case _LogLine():
return $default(_that.level,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LogLevel level,  String message)?  $default,) {final _that = this;
switch (_that) {
case _LogLine() when $default != null:
return $default(_that.level,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _LogLine implements LogLine {
  const _LogLine({this.level = LogLevel.info, this.message = ''});
  

@override@JsonKey() final  LogLevel level;
@override@JsonKey() final  String message;

/// Create a copy of LogLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LogLineCopyWith<_LogLine> get copyWith => __$LogLineCopyWithImpl<_LogLine>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LogLine&&(identical(other.level, level) || other.level == level)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,level,message);
}

@override
String toString() {
    return 'LogLine(level: $level, message: $message)';
}


}

/// @nodoc
abstract mixin class _$LogLineCopyWith<$Res> implements $LogLineCopyWith<$Res> {
  factory _$LogLineCopyWith(_LogLine value, $Res Function(_LogLine) _then) = __$LogLineCopyWithImpl;
@override @useResult
$Res call({
 LogLevel level, String message
});




}
/// @nodoc
class __$LogLineCopyWithImpl<$Res>
    implements _$LogLineCopyWith<$Res> {
  __$LogLineCopyWithImpl(this._self, this._then);

  final _LogLine _self;
  final $Res Function(_LogLine) _then;

/// Create a copy of LogLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? level = null,Object? message = null,}) {
  return _then(_LogLine(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as LogLevel,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CandidatePaper {

 int? get n; String? get pmid; String? get title; String? get year; String? get journal; String? get rankLabel; String? get pmcid;
/// Create a copy of CandidatePaper
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CandidatePaperCopyWith<CandidatePaper> get copyWith => _$CandidatePaperCopyWithImpl<CandidatePaper>(this as CandidatePaper, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CandidatePaper;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CandidatePaper&&(identical(other.n, _this.n) || other.n == _this.n)&&(identical(other.pmid, _this.pmid) || other.pmid == _this.pmid)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.year, _this.year) || other.year == _this.year)&&(identical(other.journal, _this.journal) || other.journal == _this.journal)&&(identical(other.rankLabel, _this.rankLabel) || other.rankLabel == _this.rankLabel)&&(identical(other.pmcid, _this.pmcid) || other.pmcid == _this.pmcid));
}


@override
int get hashCode {
  final _this = this as CandidatePaper;
  return Object.hash(runtimeType,_this.n,_this.pmid,_this.title,_this.year,_this.journal,_this.rankLabel,_this.pmcid);
}

@override
String toString() {
  final _this = this as CandidatePaper;
  return 'CandidatePaper(n: ${_this.n}, pmid: ${_this.pmid}, title: ${_this.title}, year: ${_this.year}, journal: ${_this.journal}, rankLabel: ${_this.rankLabel}, pmcid: ${_this.pmcid})';
}


}

/// @nodoc
abstract mixin class $CandidatePaperCopyWith<$Res>  {
  factory $CandidatePaperCopyWith(CandidatePaper value, $Res Function(CandidatePaper) _then) = _$CandidatePaperCopyWithImpl;
@useResult
$Res call({
 int? n, String? pmid, String? title, String? year, String? journal, String? rankLabel, String? pmcid
});




}
/// @nodoc
class _$CandidatePaperCopyWithImpl<$Res>
    implements $CandidatePaperCopyWith<$Res> {
  _$CandidatePaperCopyWithImpl(this._self, this._then);

  final CandidatePaper _self;
  final $Res Function(CandidatePaper) _then;

/// Create a copy of CandidatePaper
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? n = freezed,Object? pmid = freezed,Object? title = freezed,Object? year = freezed,Object? journal = freezed,Object? rankLabel = freezed,Object? pmcid = freezed,}) {
  return _then(CandidatePaper(
n: freezed == n ? _self.n : n // ignore: cast_nullable_to_non_nullable
as int?,pmid: freezed == pmid ? _self.pmid : pmid // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String?,journal: freezed == journal ? _self.journal : journal // ignore: cast_nullable_to_non_nullable
as String?,rankLabel: freezed == rankLabel ? _self.rankLabel : rankLabel // ignore: cast_nullable_to_non_nullable
as String?,pmcid: freezed == pmcid ? _self.pmcid : pmcid // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CandidatePaper].
extension CandidatePaperPatterns on CandidatePaper {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CandidatePaper value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CandidatePaper() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CandidatePaper value)  $default,){
final _that = this;
switch (_that) {
case _CandidatePaper():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CandidatePaper value)?  $default,){
final _that = this;
switch (_that) {
case _CandidatePaper() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? n,  String? pmid,  String? title,  String? year,  String? journal,  String? rankLabel,  String? pmcid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CandidatePaper() when $default != null:
return $default(_that.n,_that.pmid,_that.title,_that.year,_that.journal,_that.rankLabel,_that.pmcid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? n,  String? pmid,  String? title,  String? year,  String? journal,  String? rankLabel,  String? pmcid)  $default,) {final _that = this;
switch (_that) {
case _CandidatePaper():
return $default(_that.n,_that.pmid,_that.title,_that.year,_that.journal,_that.rankLabel,_that.pmcid);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? n,  String? pmid,  String? title,  String? year,  String? journal,  String? rankLabel,  String? pmcid)?  $default,) {final _that = this;
switch (_that) {
case _CandidatePaper() when $default != null:
return $default(_that.n,_that.pmid,_that.title,_that.year,_that.journal,_that.rankLabel,_that.pmcid);case _:
  return null;

}
}

}

/// @nodoc


class _CandidatePaper implements CandidatePaper {
  const _CandidatePaper({this.n, this.pmid, this.title, this.year, this.journal, this.rankLabel, this.pmcid});
  

@override final  int? n;
@override final  String? pmid;
@override final  String? title;
@override final  String? year;
@override final  String? journal;
@override final  String? rankLabel;
@override final  String? pmcid;

/// Create a copy of CandidatePaper
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CandidatePaperCopyWith<_CandidatePaper> get copyWith => __$CandidatePaperCopyWithImpl<_CandidatePaper>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CandidatePaper&&(identical(other.n, n) || other.n == n)&&(identical(other.pmid, pmid) || other.pmid == pmid)&&(identical(other.title, title) || other.title == title)&&(identical(other.year, year) || other.year == year)&&(identical(other.journal, journal) || other.journal == journal)&&(identical(other.rankLabel, rankLabel) || other.rankLabel == rankLabel)&&(identical(other.pmcid, pmcid) || other.pmcid == pmcid));
}


@override
int get hashCode {
    return Object.hash(runtimeType,n,pmid,title,year,journal,rankLabel,pmcid);
}

@override
String toString() {
    return 'CandidatePaper(n: $n, pmid: $pmid, title: $title, year: $year, journal: $journal, rankLabel: $rankLabel, pmcid: $pmcid)';
}


}

/// @nodoc
abstract mixin class _$CandidatePaperCopyWith<$Res> implements $CandidatePaperCopyWith<$Res> {
  factory _$CandidatePaperCopyWith(_CandidatePaper value, $Res Function(_CandidatePaper) _then) = __$CandidatePaperCopyWithImpl;
@override @useResult
$Res call({
 int? n, String? pmid, String? title, String? year, String? journal, String? rankLabel, String? pmcid
});




}
/// @nodoc
class __$CandidatePaperCopyWithImpl<$Res>
    implements _$CandidatePaperCopyWith<$Res> {
  __$CandidatePaperCopyWithImpl(this._self, this._then);

  final _CandidatePaper _self;
  final $Res Function(_CandidatePaper) _then;

/// Create a copy of CandidatePaper
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? n = freezed,Object? pmid = freezed,Object? title = freezed,Object? year = freezed,Object? journal = freezed,Object? rankLabel = freezed,Object? pmcid = freezed,}) {
  return _then(_CandidatePaper(
n: freezed == n ? _self.n : n // ignore: cast_nullable_to_non_nullable
as int?,pmid: freezed == pmid ? _self.pmid : pmid // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String?,journal: freezed == journal ? _self.journal : journal // ignore: cast_nullable_to_non_nullable
as String?,rankLabel: freezed == rankLabel ? _self.rankLabel : rankLabel // ignore: cast_nullable_to_non_nullable
as String?,pmcid: freezed == pmcid ? _self.pmcid : pmcid // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$SearchSummary {

 int get candidates; int get kept; Map<String, int> get dropped; List<CandidatePaper> get papers;
/// Create a copy of SearchSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchSummaryCopyWith<SearchSummary> get copyWith => _$SearchSummaryCopyWithImpl<SearchSummary>(this as SearchSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SearchSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchSummary&&(identical(other.candidates, _this.candidates) || other.candidates == _this.candidates)&&(identical(other.kept, _this.kept) || other.kept == _this.kept)&&const DeepCollectionEquality().equals(other.dropped, _this.dropped)&&const DeepCollectionEquality().equals(other.papers, _this.papers));
}


@override
int get hashCode {
  final _this = this as SearchSummary;
  return Object.hash(runtimeType,_this.candidates,_this.kept,const DeepCollectionEquality().hash(_this.dropped),const DeepCollectionEquality().hash(_this.papers));
}

@override
String toString() {
  final _this = this as SearchSummary;
  return 'SearchSummary(candidates: ${_this.candidates}, kept: ${_this.kept}, dropped: ${_this.dropped}, papers: ${_this.papers})';
}


}

/// @nodoc
abstract mixin class $SearchSummaryCopyWith<$Res>  {
  factory $SearchSummaryCopyWith(SearchSummary value, $Res Function(SearchSummary) _then) = _$SearchSummaryCopyWithImpl;
@useResult
$Res call({
 int candidates, int kept, Map<String, int> dropped, List<CandidatePaper> papers
});




}
/// @nodoc
class _$SearchSummaryCopyWithImpl<$Res>
    implements $SearchSummaryCopyWith<$Res> {
  _$SearchSummaryCopyWithImpl(this._self, this._then);

  final SearchSummary _self;
  final $Res Function(SearchSummary) _then;

/// Create a copy of SearchSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? candidates = null,Object? kept = null,Object? dropped = null,Object? papers = null,}) {
  return _then(SearchSummary(
candidates: null == candidates ? _self.candidates : candidates // ignore: cast_nullable_to_non_nullable
as int,kept: null == kept ? _self.kept : kept // ignore: cast_nullable_to_non_nullable
as int,dropped: null == dropped ? _self.dropped : dropped // ignore: cast_nullable_to_non_nullable
as Map<String, int>,papers: null == papers ? _self.papers : papers // ignore: cast_nullable_to_non_nullable
as List<CandidatePaper>,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchSummary].
extension SearchSummaryPatterns on SearchSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchSummary value)  $default,){
final _that = this;
switch (_that) {
case _SearchSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchSummary value)?  $default,){
final _that = this;
switch (_that) {
case _SearchSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int candidates,  int kept,  Map<String, int> dropped,  List<CandidatePaper> papers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchSummary() when $default != null:
return $default(_that.candidates,_that.kept,_that.dropped,_that.papers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int candidates,  int kept,  Map<String, int> dropped,  List<CandidatePaper> papers)  $default,) {final _that = this;
switch (_that) {
case _SearchSummary():
return $default(_that.candidates,_that.kept,_that.dropped,_that.papers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int candidates,  int kept,  Map<String, int> dropped,  List<CandidatePaper> papers)?  $default,) {final _that = this;
switch (_that) {
case _SearchSummary() when $default != null:
return $default(_that.candidates,_that.kept,_that.dropped,_that.papers);case _:
  return null;

}
}

}

/// @nodoc


class _SearchSummary implements SearchSummary {
  const _SearchSummary({this.candidates = 0, this.kept = 0,  Map<String, int> dropped = const <String, int>{},  List<CandidatePaper> papers = const <CandidatePaper>[]}): _dropped = dropped,_papers = papers;
  

@override@JsonKey() final  int candidates;
@override@JsonKey() final  int kept;
 final  Map<String, int> _dropped;
@override@JsonKey() Map<String, int> get dropped {
  if (_dropped is EqualUnmodifiableMapView) return _dropped;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_dropped);
}

 final  List<CandidatePaper> _papers;
@override@JsonKey() List<CandidatePaper> get papers {
  if (_papers is EqualUnmodifiableListView) return _papers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_papers);
}


/// Create a copy of SearchSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchSummaryCopyWith<_SearchSummary> get copyWith => __$SearchSummaryCopyWithImpl<_SearchSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchSummary&&(identical(other.candidates, candidates) || other.candidates == candidates)&&(identical(other.kept, kept) || other.kept == kept)&&const DeepCollectionEquality().equals(other.dropped, _dropped)&&const DeepCollectionEquality().equals(other.papers, _papers));
}


@override
int get hashCode {
    return Object.hash(runtimeType,candidates,kept,const DeepCollectionEquality().hash(_dropped),const DeepCollectionEquality().hash(_papers));
}

@override
String toString() {
    return 'SearchSummary(candidates: $candidates, kept: $kept, dropped: $dropped, papers: $papers)';
}


}

/// @nodoc
abstract mixin class _$SearchSummaryCopyWith<$Res> implements $SearchSummaryCopyWith<$Res> {
  factory _$SearchSummaryCopyWith(_SearchSummary value, $Res Function(_SearchSummary) _then) = __$SearchSummaryCopyWithImpl;
@override @useResult
$Res call({
 int candidates, int kept, Map<String, int> dropped, List<CandidatePaper> papers
});




}
/// @nodoc
class __$SearchSummaryCopyWithImpl<$Res>
    implements _$SearchSummaryCopyWith<$Res> {
  __$SearchSummaryCopyWithImpl(this._self, this._then);

  final _SearchSummary _self;
  final $Res Function(_SearchSummary) _then;

/// Create a copy of SearchSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? candidates = null,Object? kept = null,Object? dropped = null,Object? papers = null,}) {
  return _then(_SearchSummary(
candidates: null == candidates ? _self.candidates : candidates // ignore: cast_nullable_to_non_nullable
as int,kept: null == kept ? _self.kept : kept // ignore: cast_nullable_to_non_nullable
as int,dropped: null == dropped ? _self._dropped : dropped // ignore: cast_nullable_to_non_nullable
as Map<String, int>,papers: null == papers ? _self._papers : papers // ignore: cast_nullable_to_non_nullable
as List<CandidatePaper>,
  ));
}


}

/// @nodoc
mixin _$JobLive {

 Map<StageKey, StageState> get stages; ProgressState? get progress; List<LogLine> get logs; SearchSummary? get search; Terminal? get terminal;
/// Create a copy of JobLive
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobLiveCopyWith<JobLive> get copyWith => _$JobLiveCopyWithImpl<JobLive>(this as JobLive, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as JobLive;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobLive&&const DeepCollectionEquality().equals(other.stages, _this.stages)&&(identical(other.progress, _this.progress) || other.progress == _this.progress)&&const DeepCollectionEquality().equals(other.logs, _this.logs)&&(identical(other.search, _this.search) || other.search == _this.search)&&(identical(other.terminal, _this.terminal) || other.terminal == _this.terminal));
}


@override
int get hashCode {
  final _this = this as JobLive;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.stages),_this.progress,const DeepCollectionEquality().hash(_this.logs),_this.search,_this.terminal);
}

@override
String toString() {
  final _this = this as JobLive;
  return 'JobLive(stages: ${_this.stages}, progress: ${_this.progress}, logs: ${_this.logs}, search: ${_this.search}, terminal: ${_this.terminal})';
}


}

/// @nodoc
abstract mixin class $JobLiveCopyWith<$Res>  {
  factory $JobLiveCopyWith(JobLive value, $Res Function(JobLive) _then) = _$JobLiveCopyWithImpl;
@useResult
$Res call({
 Map<StageKey, StageState> stages, ProgressState? progress, List<LogLine> logs, SearchSummary? search, Terminal? terminal
});


$ProgressStateCopyWith<$Res>? get progress;$SearchSummaryCopyWith<$Res>? get search;

}
/// @nodoc
class _$JobLiveCopyWithImpl<$Res>
    implements $JobLiveCopyWith<$Res> {
  _$JobLiveCopyWithImpl(this._self, this._then);

  final JobLive _self;
  final $Res Function(JobLive) _then;

/// Create a copy of JobLive
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stages = null,Object? progress = freezed,Object? logs = null,Object? search = freezed,Object? terminal = freezed,}) {
  return _then(JobLive(
stages: null == stages ? _self.stages : stages // ignore: cast_nullable_to_non_nullable
as Map<StageKey, StageState>,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as ProgressState?,logs: null == logs ? _self.logs : logs // ignore: cast_nullable_to_non_nullable
as List<LogLine>,search: freezed == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as SearchSummary?,terminal: freezed == terminal ? _self.terminal : terminal // ignore: cast_nullable_to_non_nullable
as Terminal?,
  ));
}
/// Create a copy of JobLive
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProgressStateCopyWith<$Res>? get progress {
    if (_self.progress == null) {
    return null;
  }

  return $ProgressStateCopyWith<$Res>(_self.progress!, (value) {
    return _then(_self.copyWith(progress: value));
  });
}/// Create a copy of JobLive
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SearchSummaryCopyWith<$Res>? get search {
    if (_self.search == null) {
    return null;
  }

  return $SearchSummaryCopyWith<$Res>(_self.search!, (value) {
    return _then(_self.copyWith(search: value));
  });
}
}


/// Adds pattern-matching-related methods to [JobLive].
extension JobLivePatterns on JobLive {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JobLive value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JobLive() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JobLive value)  $default,){
final _that = this;
switch (_that) {
case _JobLive():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JobLive value)?  $default,){
final _that = this;
switch (_that) {
case _JobLive() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<StageKey, StageState> stages,  ProgressState? progress,  List<LogLine> logs,  SearchSummary? search,  Terminal? terminal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JobLive() when $default != null:
return $default(_that.stages,_that.progress,_that.logs,_that.search,_that.terminal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<StageKey, StageState> stages,  ProgressState? progress,  List<LogLine> logs,  SearchSummary? search,  Terminal? terminal)  $default,) {final _that = this;
switch (_that) {
case _JobLive():
return $default(_that.stages,_that.progress,_that.logs,_that.search,_that.terminal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<StageKey, StageState> stages,  ProgressState? progress,  List<LogLine> logs,  SearchSummary? search,  Terminal? terminal)?  $default,) {final _that = this;
switch (_that) {
case _JobLive() when $default != null:
return $default(_that.stages,_that.progress,_that.logs,_that.search,_that.terminal);case _:
  return null;

}
}

}

/// @nodoc


class _JobLive extends JobLive {
  const _JobLive({ Map<StageKey, StageState> stages = const <StageKey, StageState>{}, this.progress,  List<LogLine> logs = const <LogLine>[], this.search, this.terminal}): _stages = stages,_logs = logs,super._();
  

 final  Map<StageKey, StageState> _stages;
@override@JsonKey() Map<StageKey, StageState> get stages {
  if (_stages is EqualUnmodifiableMapView) return _stages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_stages);
}

@override final  ProgressState? progress;
 final  List<LogLine> _logs;
@override@JsonKey() List<LogLine> get logs {
  if (_logs is EqualUnmodifiableListView) return _logs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_logs);
}

@override final  SearchSummary? search;
@override final  Terminal? terminal;

/// Create a copy of JobLive
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JobLiveCopyWith<_JobLive> get copyWith => __$JobLiveCopyWithImpl<_JobLive>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _JobLive&&const DeepCollectionEquality().equals(other.stages, _stages)&&(identical(other.progress, progress) || other.progress == progress)&&const DeepCollectionEquality().equals(other.logs, _logs)&&(identical(other.search, search) || other.search == search)&&(identical(other.terminal, terminal) || other.terminal == terminal));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_stages),progress,const DeepCollectionEquality().hash(_logs),search,terminal);
}

@override
String toString() {
    return 'JobLive(stages: $stages, progress: $progress, logs: $logs, search: $search, terminal: $terminal)';
}


}

/// @nodoc
abstract mixin class _$JobLiveCopyWith<$Res> implements $JobLiveCopyWith<$Res> {
  factory _$JobLiveCopyWith(_JobLive value, $Res Function(_JobLive) _then) = __$JobLiveCopyWithImpl;
@override @useResult
$Res call({
 Map<StageKey, StageState> stages, ProgressState? progress, List<LogLine> logs, SearchSummary? search, Terminal? terminal
});


@override $ProgressStateCopyWith<$Res>? get progress;@override $SearchSummaryCopyWith<$Res>? get search;

}
/// @nodoc
class __$JobLiveCopyWithImpl<$Res>
    implements _$JobLiveCopyWith<$Res> {
  __$JobLiveCopyWithImpl(this._self, this._then);

  final _JobLive _self;
  final $Res Function(_JobLive) _then;

/// Create a copy of JobLive
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stages = null,Object? progress = freezed,Object? logs = null,Object? search = freezed,Object? terminal = freezed,}) {
  return _then(_JobLive(
stages: null == stages ? _self._stages : stages // ignore: cast_nullable_to_non_nullable
as Map<StageKey, StageState>,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as ProgressState?,logs: null == logs ? _self._logs : logs // ignore: cast_nullable_to_non_nullable
as List<LogLine>,search: freezed == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as SearchSummary?,terminal: freezed == terminal ? _self.terminal : terminal // ignore: cast_nullable_to_non_nullable
as Terminal?,
  ));
}

/// Create a copy of JobLive
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProgressStateCopyWith<$Res>? get progress {
    if (_self.progress == null) {
    return null;
  }

  return $ProgressStateCopyWith<$Res>(_self.progress!, (value) {
    return _then(_self.copyWith(progress: value));
  });
}/// Create a copy of JobLive
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SearchSummaryCopyWith<$Res>? get search {
    if (_self.search == null) {
    return null;
  }

  return $SearchSummaryCopyWith<$Res>(_self.search!, (value) {
    return _then(_self.copyWith(search: value));
  });
}
}

// dart format on
