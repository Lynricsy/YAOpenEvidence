// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'problem.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ValidationIssue {

@JsonKey(fromJson: _locFromJson) List<String> get loc; String get msg; String get type;
/// Create a copy of ValidationIssue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValidationIssueCopyWith<ValidationIssue> get copyWith => _$ValidationIssueCopyWithImpl<ValidationIssue>(this as ValidationIssue, _$identity);

  /// Serializes this ValidationIssue to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ValidationIssue;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ValidationIssue&&const DeepCollectionEquality().equals(other.loc, _this.loc)&&(identical(other.msg, _this.msg) || other.msg == _this.msg)&&(identical(other.type, _this.type) || other.type == _this.type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ValidationIssue;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.loc),_this.msg,_this.type);
}

@override
String toString() {
  final _this = this as ValidationIssue;
  return 'ValidationIssue(loc: ${_this.loc}, msg: ${_this.msg}, type: ${_this.type})';
}


}

/// @nodoc
abstract mixin class $ValidationIssueCopyWith<$Res>  {
  factory $ValidationIssueCopyWith(ValidationIssue value, $Res Function(ValidationIssue) _then) = _$ValidationIssueCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _locFromJson) List<String> loc, String msg, String type
});




}
/// @nodoc
class _$ValidationIssueCopyWithImpl<$Res>
    implements $ValidationIssueCopyWith<$Res> {
  _$ValidationIssueCopyWithImpl(this._self, this._then);

  final ValidationIssue _self;
  final $Res Function(ValidationIssue) _then;

/// Create a copy of ValidationIssue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loc = null,Object? msg = null,Object? type = null,}) {
  return _then(ValidationIssue(
loc: null == loc ? _self.loc : loc // ignore: cast_nullable_to_non_nullable
as List<String>,msg: null == msg ? _self.msg : msg // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ValidationIssue].
extension ValidationIssuePatterns on ValidationIssue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ValidationIssue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ValidationIssue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ValidationIssue value)  $default,){
final _that = this;
switch (_that) {
case _ValidationIssue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ValidationIssue value)?  $default,){
final _that = this;
switch (_that) {
case _ValidationIssue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _locFromJson)  List<String> loc,  String msg,  String type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ValidationIssue() when $default != null:
return $default(_that.loc,_that.msg,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _locFromJson)  List<String> loc,  String msg,  String type)  $default,) {final _that = this;
switch (_that) {
case _ValidationIssue():
return $default(_that.loc,_that.msg,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _locFromJson)  List<String> loc,  String msg,  String type)?  $default,) {final _that = this;
switch (_that) {
case _ValidationIssue() when $default != null:
return $default(_that.loc,_that.msg,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ValidationIssue implements ValidationIssue {
  const _ValidationIssue({@JsonKey(fromJson: _locFromJson)  List<String> loc = const <String>[], this.msg = '', this.type = ''}): _loc = loc;
  factory _ValidationIssue.fromJson(Map<String, dynamic> json) => _$ValidationIssueFromJson(json);

 final  List<String> _loc;
@override@JsonKey(fromJson: _locFromJson) List<String> get loc {
  if (_loc is EqualUnmodifiableListView) return _loc;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_loc);
}

@override@JsonKey() final  String msg;
@override@JsonKey() final  String type;

/// Create a copy of ValidationIssue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ValidationIssueCopyWith<_ValidationIssue> get copyWith => __$ValidationIssueCopyWithImpl<_ValidationIssue>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ValidationIssueToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ValidationIssue&&const DeepCollectionEquality().equals(other.loc, _loc)&&(identical(other.msg, msg) || other.msg == msg)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_loc),msg,type);
}

@override
String toString() {
    return 'ValidationIssue(loc: $loc, msg: $msg, type: $type)';
}


}

/// @nodoc
abstract mixin class _$ValidationIssueCopyWith<$Res> implements $ValidationIssueCopyWith<$Res> {
  factory _$ValidationIssueCopyWith(_ValidationIssue value, $Res Function(_ValidationIssue) _then) = __$ValidationIssueCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _locFromJson) List<String> loc, String msg, String type
});




}
/// @nodoc
class __$ValidationIssueCopyWithImpl<$Res>
    implements _$ValidationIssueCopyWith<$Res> {
  __$ValidationIssueCopyWithImpl(this._self, this._then);

  final _ValidationIssue _self;
  final $Res Function(_ValidationIssue) _then;

/// Create a copy of ValidationIssue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loc = null,Object? msg = null,Object? type = null,}) {
  return _then(_ValidationIssue(
loc: null == loc ? _self._loc : loc // ignore: cast_nullable_to_non_nullable
as List<String>,msg: null == msg ? _self.msg : msg // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Problem {

 String? get type; String? get title; int? get status; String? get detail; String? get instance; String? get code; List<ValidationIssue>? get errors;
/// Create a copy of Problem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProblemCopyWith<Problem> get copyWith => _$ProblemCopyWithImpl<Problem>(this as Problem, _$identity);

  /// Serializes this Problem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Problem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Problem&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.detail, _this.detail) || other.detail == _this.detail)&&(identical(other.instance, _this.instance) || other.instance == _this.instance)&&(identical(other.code, _this.code) || other.code == _this.code)&&const DeepCollectionEquality().equals(other.errors, _this.errors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Problem;
  return Object.hash(runtimeType,_this.type,_this.title,_this.status,_this.detail,_this.instance,_this.code,const DeepCollectionEquality().hash(_this.errors));
}

@override
String toString() {
  final _this = this as Problem;
  return 'Problem(type: ${_this.type}, title: ${_this.title}, status: ${_this.status}, detail: ${_this.detail}, instance: ${_this.instance}, code: ${_this.code}, errors: ${_this.errors})';
}


}

/// @nodoc
abstract mixin class $ProblemCopyWith<$Res>  {
  factory $ProblemCopyWith(Problem value, $Res Function(Problem) _then) = _$ProblemCopyWithImpl;
@useResult
$Res call({
 String? type, String? title, int? status, String? detail, String? instance, String? code, List<ValidationIssue>? errors
});




}
/// @nodoc
class _$ProblemCopyWithImpl<$Res>
    implements $ProblemCopyWith<$Res> {
  _$ProblemCopyWithImpl(this._self, this._then);

  final Problem _self;
  final $Res Function(Problem) _then;

/// Create a copy of Problem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = freezed,Object? title = freezed,Object? status = freezed,Object? detail = freezed,Object? instance = freezed,Object? code = freezed,Object? errors = freezed,}) {
  return _then(Problem(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int?,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,instance: freezed == instance ? _self.instance : instance // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,errors: freezed == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as List<ValidationIssue>?,
  ));
}

}


/// Adds pattern-matching-related methods to [Problem].
extension ProblemPatterns on Problem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Problem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Problem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Problem value)  $default,){
final _that = this;
switch (_that) {
case _Problem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Problem value)?  $default,){
final _that = this;
switch (_that) {
case _Problem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? type,  String? title,  int? status,  String? detail,  String? instance,  String? code,  List<ValidationIssue>? errors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Problem() when $default != null:
return $default(_that.type,_that.title,_that.status,_that.detail,_that.instance,_that.code,_that.errors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? type,  String? title,  int? status,  String? detail,  String? instance,  String? code,  List<ValidationIssue>? errors)  $default,) {final _that = this;
switch (_that) {
case _Problem():
return $default(_that.type,_that.title,_that.status,_that.detail,_that.instance,_that.code,_that.errors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? type,  String? title,  int? status,  String? detail,  String? instance,  String? code,  List<ValidationIssue>? errors)?  $default,) {final _that = this;
switch (_that) {
case _Problem() when $default != null:
return $default(_that.type,_that.title,_that.status,_that.detail,_that.instance,_that.code,_that.errors);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Problem implements Problem {
  const _Problem({this.type, this.title, this.status, this.detail, this.instance, this.code,  List<ValidationIssue>? errors}): _errors = errors;
  factory _Problem.fromJson(Map<String, dynamic> json) => _$ProblemFromJson(json);

@override final  String? type;
@override final  String? title;
@override final  int? status;
@override final  String? detail;
@override final  String? instance;
@override final  String? code;
 final  List<ValidationIssue>? _errors;
@override List<ValidationIssue>? get errors {
  final value = _errors;
  if (value == null) return null;
  if (_errors is EqualUnmodifiableListView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of Problem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProblemCopyWith<_Problem> get copyWith => __$ProblemCopyWithImpl<_Problem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProblemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Problem&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.instance, instance) || other.instance == instance)&&(identical(other.code, code) || other.code == code)&&const DeepCollectionEquality().equals(other.errors, _errors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,title,status,detail,instance,code,const DeepCollectionEquality().hash(_errors));
}

@override
String toString() {
    return 'Problem(type: $type, title: $title, status: $status, detail: $detail, instance: $instance, code: $code, errors: $errors)';
}


}

/// @nodoc
abstract mixin class _$ProblemCopyWith<$Res> implements $ProblemCopyWith<$Res> {
  factory _$ProblemCopyWith(_Problem value, $Res Function(_Problem) _then) = __$ProblemCopyWithImpl;
@override @useResult
$Res call({
 String? type, String? title, int? status, String? detail, String? instance, String? code, List<ValidationIssue>? errors
});




}
/// @nodoc
class __$ProblemCopyWithImpl<$Res>
    implements _$ProblemCopyWith<$Res> {
  __$ProblemCopyWithImpl(this._self, this._then);

  final _Problem _self;
  final $Res Function(_Problem) _then;

/// Create a copy of Problem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = freezed,Object? title = freezed,Object? status = freezed,Object? detail = freezed,Object? instance = freezed,Object? code = freezed,Object? errors = freezed,}) {
  return _then(_Problem(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int?,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,instance: freezed == instance ? _self.instance : instance // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,errors: freezed == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as List<ValidationIssue>?,
  ));
}


}

// dart format on
