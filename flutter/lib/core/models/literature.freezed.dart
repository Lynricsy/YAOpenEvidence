// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'literature.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RankInfo {

 String get title; List<String> get issns; int get zone; String get quartile; double? get sjr; String? get hIndex; String get categories; bool get top; String get source;
/// Create a copy of RankInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RankInfoCopyWith<RankInfo> get copyWith => _$RankInfoCopyWithImpl<RankInfo>(this as RankInfo, _$identity);

  /// Serializes this RankInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RankInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RankInfo&&(identical(other.title, _this.title) || other.title == _this.title)&&const DeepCollectionEquality().equals(other.issns, _this.issns)&&(identical(other.zone, _this.zone) || other.zone == _this.zone)&&(identical(other.quartile, _this.quartile) || other.quartile == _this.quartile)&&(identical(other.sjr, _this.sjr) || other.sjr == _this.sjr)&&(identical(other.hIndex, _this.hIndex) || other.hIndex == _this.hIndex)&&(identical(other.categories, _this.categories) || other.categories == _this.categories)&&(identical(other.top, _this.top) || other.top == _this.top)&&(identical(other.source, _this.source) || other.source == _this.source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RankInfo;
  return Object.hash(runtimeType,_this.title,const DeepCollectionEquality().hash(_this.issns),_this.zone,_this.quartile,_this.sjr,_this.hIndex,_this.categories,_this.top,_this.source);
}

@override
String toString() {
  final _this = this as RankInfo;
  return 'RankInfo(title: ${_this.title}, issns: ${_this.issns}, zone: ${_this.zone}, quartile: ${_this.quartile}, sjr: ${_this.sjr}, hIndex: ${_this.hIndex}, categories: ${_this.categories}, top: ${_this.top}, source: ${_this.source})';
}


}

/// @nodoc
abstract mixin class $RankInfoCopyWith<$Res>  {
  factory $RankInfoCopyWith(RankInfo value, $Res Function(RankInfo) _then) = _$RankInfoCopyWithImpl;
@useResult
$Res call({
 String title, List<String> issns, int zone, String quartile, double? sjr, String? hIndex, String categories, bool top, String source
});




}
/// @nodoc
class _$RankInfoCopyWithImpl<$Res>
    implements $RankInfoCopyWith<$Res> {
  _$RankInfoCopyWithImpl(this._self, this._then);

  final RankInfo _self;
  final $Res Function(RankInfo) _then;

/// Create a copy of RankInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? issns = null,Object? zone = null,Object? quartile = null,Object? sjr = freezed,Object? hIndex = freezed,Object? categories = null,Object? top = null,Object? source = null,}) {
  return _then(RankInfo(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,issns: null == issns ? _self.issns : issns // ignore: cast_nullable_to_non_nullable
as List<String>,zone: null == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as int,quartile: null == quartile ? _self.quartile : quartile // ignore: cast_nullable_to_non_nullable
as String,sjr: freezed == sjr ? _self.sjr : sjr // ignore: cast_nullable_to_non_nullable
as double?,hIndex: freezed == hIndex ? _self.hIndex : hIndex // ignore: cast_nullable_to_non_nullable
as String?,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as String,top: null == top ? _self.top : top // ignore: cast_nullable_to_non_nullable
as bool,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RankInfo].
extension RankInfoPatterns on RankInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RankInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RankInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RankInfo value)  $default,){
final _that = this;
switch (_that) {
case _RankInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RankInfo value)?  $default,){
final _that = this;
switch (_that) {
case _RankInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  List<String> issns,  int zone,  String quartile,  double? sjr,  String? hIndex,  String categories,  bool top,  String source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RankInfo() when $default != null:
return $default(_that.title,_that.issns,_that.zone,_that.quartile,_that.sjr,_that.hIndex,_that.categories,_that.top,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  List<String> issns,  int zone,  String quartile,  double? sjr,  String? hIndex,  String categories,  bool top,  String source)  $default,) {final _that = this;
switch (_that) {
case _RankInfo():
return $default(_that.title,_that.issns,_that.zone,_that.quartile,_that.sjr,_that.hIndex,_that.categories,_that.top,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  List<String> issns,  int zone,  String quartile,  double? sjr,  String? hIndex,  String categories,  bool top,  String source)?  $default,) {final _that = this;
switch (_that) {
case _RankInfo() when $default != null:
return $default(_that.title,_that.issns,_that.zone,_that.quartile,_that.sjr,_that.hIndex,_that.categories,_that.top,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RankInfo implements RankInfo {
  const _RankInfo({this.title = '',  List<String> issns = const <String>[], this.zone = 0, this.quartile = '', this.sjr, this.hIndex, this.categories = '', this.top = false, this.source = ''}): _issns = issns;
  factory _RankInfo.fromJson(Map<String, dynamic> json) => _$RankInfoFromJson(json);

@override@JsonKey() final  String title;
 final  List<String> _issns;
@override@JsonKey() List<String> get issns {
  if (_issns is EqualUnmodifiableListView) return _issns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_issns);
}

@override@JsonKey() final  int zone;
@override@JsonKey() final  String quartile;
@override final  double? sjr;
@override final  String? hIndex;
@override@JsonKey() final  String categories;
@override@JsonKey() final  bool top;
@override@JsonKey() final  String source;

/// Create a copy of RankInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RankInfoCopyWith<_RankInfo> get copyWith => __$RankInfoCopyWithImpl<_RankInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RankInfoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RankInfo&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.issns, _issns)&&(identical(other.zone, zone) || other.zone == zone)&&(identical(other.quartile, quartile) || other.quartile == quartile)&&(identical(other.sjr, sjr) || other.sjr == sjr)&&(identical(other.hIndex, hIndex) || other.hIndex == hIndex)&&(identical(other.categories, categories) || other.categories == categories)&&(identical(other.top, top) || other.top == top)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,title,const DeepCollectionEquality().hash(_issns),zone,quartile,sjr,hIndex,categories,top,source);
}

@override
String toString() {
    return 'RankInfo(title: $title, issns: $issns, zone: $zone, quartile: $quartile, sjr: $sjr, hIndex: $hIndex, categories: $categories, top: $top, source: $source)';
}


}

/// @nodoc
abstract mixin class _$RankInfoCopyWith<$Res> implements $RankInfoCopyWith<$Res> {
  factory _$RankInfoCopyWith(_RankInfo value, $Res Function(_RankInfo) _then) = __$RankInfoCopyWithImpl;
@override @useResult
$Res call({
 String title, List<String> issns, int zone, String quartile, double? sjr, String? hIndex, String categories, bool top, String source
});




}
/// @nodoc
class __$RankInfoCopyWithImpl<$Res>
    implements _$RankInfoCopyWith<$Res> {
  __$RankInfoCopyWithImpl(this._self, this._then);

  final _RankInfo _self;
  final $Res Function(_RankInfo) _then;

/// Create a copy of RankInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? issns = null,Object? zone = null,Object? quartile = null,Object? sjr = freezed,Object? hIndex = freezed,Object? categories = null,Object? top = null,Object? source = null,}) {
  return _then(_RankInfo(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,issns: null == issns ? _self._issns : issns // ignore: cast_nullable_to_non_nullable
as List<String>,zone: null == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as int,quartile: null == quartile ? _self.quartile : quartile // ignore: cast_nullable_to_non_nullable
as String,sjr: freezed == sjr ? _self.sjr : sjr // ignore: cast_nullable_to_non_nullable
as double?,hIndex: freezed == hIndex ? _self.hIndex : hIndex // ignore: cast_nullable_to_non_nullable
as String?,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as String,top: null == top ? _self.top : top // ignore: cast_nullable_to_non_nullable
as bool,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RankQuery {

 String get issn; String get title;
/// Create a copy of RankQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RankQueryCopyWith<RankQuery> get copyWith => _$RankQueryCopyWithImpl<RankQuery>(this as RankQuery, _$identity);

  /// Serializes this RankQuery to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RankQuery;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RankQuery&&(identical(other.issn, _this.issn) || other.issn == _this.issn)&&(identical(other.title, _this.title) || other.title == _this.title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RankQuery;
  return Object.hash(runtimeType,_this.issn,_this.title);
}

@override
String toString() {
  final _this = this as RankQuery;
  return 'RankQuery(issn: ${_this.issn}, title: ${_this.title})';
}


}

/// @nodoc
abstract mixin class $RankQueryCopyWith<$Res>  {
  factory $RankQueryCopyWith(RankQuery value, $Res Function(RankQuery) _then) = _$RankQueryCopyWithImpl;
@useResult
$Res call({
 String issn, String title
});




}
/// @nodoc
class _$RankQueryCopyWithImpl<$Res>
    implements $RankQueryCopyWith<$Res> {
  _$RankQueryCopyWithImpl(this._self, this._then);

  final RankQuery _self;
  final $Res Function(RankQuery) _then;

/// Create a copy of RankQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? issn = null,Object? title = null,}) {
  return _then(RankQuery(
issn: null == issn ? _self.issn : issn // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RankQuery].
extension RankQueryPatterns on RankQuery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RankQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RankQuery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RankQuery value)  $default,){
final _that = this;
switch (_that) {
case _RankQuery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RankQuery value)?  $default,){
final _that = this;
switch (_that) {
case _RankQuery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String issn,  String title)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RankQuery() when $default != null:
return $default(_that.issn,_that.title);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String issn,  String title)  $default,) {final _that = this;
switch (_that) {
case _RankQuery():
return $default(_that.issn,_that.title);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String issn,  String title)?  $default,) {final _that = this;
switch (_that) {
case _RankQuery() when $default != null:
return $default(_that.issn,_that.title);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RankQuery implements RankQuery {
  const _RankQuery({this.issn = '', this.title = ''});
  factory _RankQuery.fromJson(Map<String, dynamic> json) => _$RankQueryFromJson(json);

@override@JsonKey() final  String issn;
@override@JsonKey() final  String title;

/// Create a copy of RankQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RankQueryCopyWith<_RankQuery> get copyWith => __$RankQueryCopyWithImpl<_RankQuery>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RankQueryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RankQuery&&(identical(other.issn, issn) || other.issn == issn)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,issn,title);
}

@override
String toString() {
    return 'RankQuery(issn: $issn, title: $title)';
}


}

/// @nodoc
abstract mixin class _$RankQueryCopyWith<$Res> implements $RankQueryCopyWith<$Res> {
  factory _$RankQueryCopyWith(_RankQuery value, $Res Function(_RankQuery) _then) = __$RankQueryCopyWithImpl;
@override @useResult
$Res call({
 String issn, String title
});




}
/// @nodoc
class __$RankQueryCopyWithImpl<$Res>
    implements _$RankQueryCopyWith<$Res> {
  __$RankQueryCopyWithImpl(this._self, this._then);

  final _RankQuery _self;
  final $Res Function(_RankQuery) _then;

/// Create a copy of RankQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? issn = null,Object? title = null,}) {
  return _then(_RankQuery(
issn: null == issn ? _self.issn : issn // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RankResult {

 RankQuery get query; bool get found; RankInfo? get rank; String get label;
/// Create a copy of RankResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RankResultCopyWith<RankResult> get copyWith => _$RankResultCopyWithImpl<RankResult>(this as RankResult, _$identity);

  /// Serializes this RankResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RankResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RankResult&&(identical(other.query, _this.query) || other.query == _this.query)&&(identical(other.found, _this.found) || other.found == _this.found)&&(identical(other.rank, _this.rank) || other.rank == _this.rank)&&(identical(other.label, _this.label) || other.label == _this.label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RankResult;
  return Object.hash(runtimeType,_this.query,_this.found,_this.rank,_this.label);
}

@override
String toString() {
  final _this = this as RankResult;
  return 'RankResult(query: ${_this.query}, found: ${_this.found}, rank: ${_this.rank}, label: ${_this.label})';
}


}

/// @nodoc
abstract mixin class $RankResultCopyWith<$Res>  {
  factory $RankResultCopyWith(RankResult value, $Res Function(RankResult) _then) = _$RankResultCopyWithImpl;
@useResult
$Res call({
 RankQuery query, bool found, RankInfo? rank, String label
});


$RankQueryCopyWith<$Res> get query;$RankInfoCopyWith<$Res>? get rank;

}
/// @nodoc
class _$RankResultCopyWithImpl<$Res>
    implements $RankResultCopyWith<$Res> {
  _$RankResultCopyWithImpl(this._self, this._then);

  final RankResult _self;
  final $Res Function(RankResult) _then;

/// Create a copy of RankResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? found = null,Object? rank = freezed,Object? label = null,}) {
  return _then(RankResult(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as RankQuery,found: null == found ? _self.found : found // ignore: cast_nullable_to_non_nullable
as bool,rank: freezed == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as RankInfo?,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of RankResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RankQueryCopyWith<$Res> get query {
  
  return $RankQueryCopyWith<$Res>(_self.query, (value) {
    return _then(_self.copyWith(query: value));
  });
}/// Create a copy of RankResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RankInfoCopyWith<$Res>? get rank {
    if (_self.rank == null) {
    return null;
  }

  return $RankInfoCopyWith<$Res>(_self.rank!, (value) {
    return _then(_self.copyWith(rank: value));
  });
}
}


/// Adds pattern-matching-related methods to [RankResult].
extension RankResultPatterns on RankResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RankResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RankResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RankResult value)  $default,){
final _that = this;
switch (_that) {
case _RankResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RankResult value)?  $default,){
final _that = this;
switch (_that) {
case _RankResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RankQuery query,  bool found,  RankInfo? rank,  String label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RankResult() when $default != null:
return $default(_that.query,_that.found,_that.rank,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RankQuery query,  bool found,  RankInfo? rank,  String label)  $default,) {final _that = this;
switch (_that) {
case _RankResult():
return $default(_that.query,_that.found,_that.rank,_that.label);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RankQuery query,  bool found,  RankInfo? rank,  String label)?  $default,) {final _that = this;
switch (_that) {
case _RankResult() when $default != null:
return $default(_that.query,_that.found,_that.rank,_that.label);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RankResult implements RankResult {
  const _RankResult({required this.query, this.found = false, this.rank, this.label = ''});
  factory _RankResult.fromJson(Map<String, dynamic> json) => _$RankResultFromJson(json);

@override final  RankQuery query;
@override@JsonKey() final  bool found;
@override final  RankInfo? rank;
@override@JsonKey() final  String label;

/// Create a copy of RankResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RankResultCopyWith<_RankResult> get copyWith => __$RankResultCopyWithImpl<_RankResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RankResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RankResult&&(identical(other.query, query) || other.query == query)&&(identical(other.found, found) || other.found == found)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,query,found,rank,label);
}

@override
String toString() {
    return 'RankResult(query: $query, found: $found, rank: $rank, label: $label)';
}


}

/// @nodoc
abstract mixin class _$RankResultCopyWith<$Res> implements $RankResultCopyWith<$Res> {
  factory _$RankResultCopyWith(_RankResult value, $Res Function(_RankResult) _then) = __$RankResultCopyWithImpl;
@override @useResult
$Res call({
 RankQuery query, bool found, RankInfo? rank, String label
});


@override $RankQueryCopyWith<$Res> get query;@override $RankInfoCopyWith<$Res>? get rank;

}
/// @nodoc
class __$RankResultCopyWithImpl<$Res>
    implements _$RankResultCopyWith<$Res> {
  __$RankResultCopyWithImpl(this._self, this._then);

  final _RankResult _self;
  final $Res Function(_RankResult) _then;

/// Create a copy of RankResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? found = null,Object? rank = freezed,Object? label = null,}) {
  return _then(_RankResult(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as RankQuery,found: null == found ? _self.found : found // ignore: cast_nullable_to_non_nullable
as bool,rank: freezed == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as RankInfo?,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of RankResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RankQueryCopyWith<$Res> get query {
  
  return $RankQueryCopyWith<$Res>(_self.query, (value) {
    return _then(_self.copyWith(query: value));
  });
}/// Create a copy of RankResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RankInfoCopyWith<$Res>? get rank {
    if (_self.rank == null) {
    return null;
  }

  return $RankInfoCopyWith<$Res>(_self.rank!, (value) {
    return _then(_self.copyWith(rank: value));
  });
}
}


/// @nodoc
mixin _$LiteratureRecord {

 LiteratureSource get source; String get id; String? get pmid; String? get pmcid; String? get doi; String? get s2Id; String get title; String? get abstract; String? get year; String? get journal; String? get issn; List<String> get authors; List<String> get types; int? get citedBy; String? get openAccessPdf; String? get tldr; RankInfo? get rank;
/// Create a copy of LiteratureRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiteratureRecordCopyWith<LiteratureRecord> get copyWith => _$LiteratureRecordCopyWithImpl<LiteratureRecord>(this as LiteratureRecord, _$identity);

  /// Serializes this LiteratureRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LiteratureRecord;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiteratureRecord&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.pmid, _this.pmid) || other.pmid == _this.pmid)&&(identical(other.pmcid, _this.pmcid) || other.pmcid == _this.pmcid)&&(identical(other.doi, _this.doi) || other.doi == _this.doi)&&(identical(other.s2Id, _this.s2Id) || other.s2Id == _this.s2Id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.abstract, _this.abstract) || other.abstract == _this.abstract)&&(identical(other.year, _this.year) || other.year == _this.year)&&(identical(other.journal, _this.journal) || other.journal == _this.journal)&&(identical(other.issn, _this.issn) || other.issn == _this.issn)&&const DeepCollectionEquality().equals(other.authors, _this.authors)&&const DeepCollectionEquality().equals(other.types, _this.types)&&(identical(other.citedBy, _this.citedBy) || other.citedBy == _this.citedBy)&&(identical(other.openAccessPdf, _this.openAccessPdf) || other.openAccessPdf == _this.openAccessPdf)&&(identical(other.tldr, _this.tldr) || other.tldr == _this.tldr)&&(identical(other.rank, _this.rank) || other.rank == _this.rank));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LiteratureRecord;
  return Object.hash(runtimeType,_this.source,_this.id,_this.pmid,_this.pmcid,_this.doi,_this.s2Id,_this.title,_this.abstract,_this.year,_this.journal,_this.issn,const DeepCollectionEquality().hash(_this.authors),const DeepCollectionEquality().hash(_this.types),_this.citedBy,_this.openAccessPdf,_this.tldr,_this.rank);
}

@override
String toString() {
  final _this = this as LiteratureRecord;
  return 'LiteratureRecord(source: ${_this.source}, id: ${_this.id}, pmid: ${_this.pmid}, pmcid: ${_this.pmcid}, doi: ${_this.doi}, s2Id: ${_this.s2Id}, title: ${_this.title}, abstract: ${_this.abstract}, year: ${_this.year}, journal: ${_this.journal}, issn: ${_this.issn}, authors: ${_this.authors}, types: ${_this.types}, citedBy: ${_this.citedBy}, openAccessPdf: ${_this.openAccessPdf}, tldr: ${_this.tldr}, rank: ${_this.rank})';
}


}

/// @nodoc
abstract mixin class $LiteratureRecordCopyWith<$Res>  {
  factory $LiteratureRecordCopyWith(LiteratureRecord value, $Res Function(LiteratureRecord) _then) = _$LiteratureRecordCopyWithImpl;
@useResult
$Res call({
 LiteratureSource source, String id, String? pmid, String? pmcid, String? doi, String? s2Id, String title, String? abstract, String? year, String? journal, String? issn, List<String> authors, List<String> types, int? citedBy, String? openAccessPdf, String? tldr, RankInfo? rank
});


$RankInfoCopyWith<$Res>? get rank;

}
/// @nodoc
class _$LiteratureRecordCopyWithImpl<$Res>
    implements $LiteratureRecordCopyWith<$Res> {
  _$LiteratureRecordCopyWithImpl(this._self, this._then);

  final LiteratureRecord _self;
  final $Res Function(LiteratureRecord) _then;

/// Create a copy of LiteratureRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? source = null,Object? id = null,Object? pmid = freezed,Object? pmcid = freezed,Object? doi = freezed,Object? s2Id = freezed,Object? title = null,Object? abstract = freezed,Object? year = freezed,Object? journal = freezed,Object? issn = freezed,Object? authors = null,Object? types = null,Object? citedBy = freezed,Object? openAccessPdf = freezed,Object? tldr = freezed,Object? rank = freezed,}) {
  return _then(LiteratureRecord(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as LiteratureSource,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,pmid: freezed == pmid ? _self.pmid : pmid // ignore: cast_nullable_to_non_nullable
as String?,pmcid: freezed == pmcid ? _self.pmcid : pmcid // ignore: cast_nullable_to_non_nullable
as String?,doi: freezed == doi ? _self.doi : doi // ignore: cast_nullable_to_non_nullable
as String?,s2Id: freezed == s2Id ? _self.s2Id : s2Id // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,abstract: freezed == abstract ? _self.abstract : abstract // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String?,journal: freezed == journal ? _self.journal : journal // ignore: cast_nullable_to_non_nullable
as String?,issn: freezed == issn ? _self.issn : issn // ignore: cast_nullable_to_non_nullable
as String?,authors: null == authors ? _self.authors : authors // ignore: cast_nullable_to_non_nullable
as List<String>,types: null == types ? _self.types : types // ignore: cast_nullable_to_non_nullable
as List<String>,citedBy: freezed == citedBy ? _self.citedBy : citedBy // ignore: cast_nullable_to_non_nullable
as int?,openAccessPdf: freezed == openAccessPdf ? _self.openAccessPdf : openAccessPdf // ignore: cast_nullable_to_non_nullable
as String?,tldr: freezed == tldr ? _self.tldr : tldr // ignore: cast_nullable_to_non_nullable
as String?,rank: freezed == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as RankInfo?,
  ));
}
/// Create a copy of LiteratureRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RankInfoCopyWith<$Res>? get rank {
    if (_self.rank == null) {
    return null;
  }

  return $RankInfoCopyWith<$Res>(_self.rank!, (value) {
    return _then(_self.copyWith(rank: value));
  });
}
}


/// Adds pattern-matching-related methods to [LiteratureRecord].
extension LiteratureRecordPatterns on LiteratureRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiteratureRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiteratureRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiteratureRecord value)  $default,){
final _that = this;
switch (_that) {
case _LiteratureRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiteratureRecord value)?  $default,){
final _that = this;
switch (_that) {
case _LiteratureRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LiteratureSource source,  String id,  String? pmid,  String? pmcid,  String? doi,  String? s2Id,  String title,  String? abstract,  String? year,  String? journal,  String? issn,  List<String> authors,  List<String> types,  int? citedBy,  String? openAccessPdf,  String? tldr,  RankInfo? rank)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiteratureRecord() when $default != null:
return $default(_that.source,_that.id,_that.pmid,_that.pmcid,_that.doi,_that.s2Id,_that.title,_that.abstract,_that.year,_that.journal,_that.issn,_that.authors,_that.types,_that.citedBy,_that.openAccessPdf,_that.tldr,_that.rank);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LiteratureSource source,  String id,  String? pmid,  String? pmcid,  String? doi,  String? s2Id,  String title,  String? abstract,  String? year,  String? journal,  String? issn,  List<String> authors,  List<String> types,  int? citedBy,  String? openAccessPdf,  String? tldr,  RankInfo? rank)  $default,) {final _that = this;
switch (_that) {
case _LiteratureRecord():
return $default(_that.source,_that.id,_that.pmid,_that.pmcid,_that.doi,_that.s2Id,_that.title,_that.abstract,_that.year,_that.journal,_that.issn,_that.authors,_that.types,_that.citedBy,_that.openAccessPdf,_that.tldr,_that.rank);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LiteratureSource source,  String id,  String? pmid,  String? pmcid,  String? doi,  String? s2Id,  String title,  String? abstract,  String? year,  String? journal,  String? issn,  List<String> authors,  List<String> types,  int? citedBy,  String? openAccessPdf,  String? tldr,  RankInfo? rank)?  $default,) {final _that = this;
switch (_that) {
case _LiteratureRecord() when $default != null:
return $default(_that.source,_that.id,_that.pmid,_that.pmcid,_that.doi,_that.s2Id,_that.title,_that.abstract,_that.year,_that.journal,_that.issn,_that.authors,_that.types,_that.citedBy,_that.openAccessPdf,_that.tldr,_that.rank);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LiteratureRecord extends LiteratureRecord {
  const _LiteratureRecord({required this.source, required this.id, this.pmid, this.pmcid, this.doi, this.s2Id, this.title = '', this.abstract, this.year, this.journal, this.issn,  List<String> authors = const <String>[],  List<String> types = const <String>[], this.citedBy, this.openAccessPdf, this.tldr, this.rank}): _authors = authors,_types = types,super._();
  factory _LiteratureRecord.fromJson(Map<String, dynamic> json) => _$LiteratureRecordFromJson(json);

@override final  LiteratureSource source;
@override final  String id;
@override final  String? pmid;
@override final  String? pmcid;
@override final  String? doi;
@override final  String? s2Id;
@override@JsonKey() final  String title;
@override final  String? abstract;
@override final  String? year;
@override final  String? journal;
@override final  String? issn;
 final  List<String> _authors;
@override@JsonKey() List<String> get authors {
  if (_authors is EqualUnmodifiableListView) return _authors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_authors);
}

 final  List<String> _types;
@override@JsonKey() List<String> get types {
  if (_types is EqualUnmodifiableListView) return _types;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_types);
}

@override final  int? citedBy;
@override final  String? openAccessPdf;
@override final  String? tldr;
@override final  RankInfo? rank;

/// Create a copy of LiteratureRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiteratureRecordCopyWith<_LiteratureRecord> get copyWith => __$LiteratureRecordCopyWithImpl<_LiteratureRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LiteratureRecordToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiteratureRecord&&(identical(other.source, source) || other.source == source)&&(identical(other.id, id) || other.id == id)&&(identical(other.pmid, pmid) || other.pmid == pmid)&&(identical(other.pmcid, pmcid) || other.pmcid == pmcid)&&(identical(other.doi, doi) || other.doi == doi)&&(identical(other.s2Id, s2Id) || other.s2Id == s2Id)&&(identical(other.title, title) || other.title == title)&&(identical(other.abstract, abstract) || other.abstract == abstract)&&(identical(other.year, year) || other.year == year)&&(identical(other.journal, journal) || other.journal == journal)&&(identical(other.issn, issn) || other.issn == issn)&&const DeepCollectionEquality().equals(other.authors, _authors)&&const DeepCollectionEquality().equals(other.types, _types)&&(identical(other.citedBy, citedBy) || other.citedBy == citedBy)&&(identical(other.openAccessPdf, openAccessPdf) || other.openAccessPdf == openAccessPdf)&&(identical(other.tldr, tldr) || other.tldr == tldr)&&(identical(other.rank, rank) || other.rank == rank));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,source,id,pmid,pmcid,doi,s2Id,title,abstract,year,journal,issn,const DeepCollectionEquality().hash(_authors),const DeepCollectionEquality().hash(_types),citedBy,openAccessPdf,tldr,rank);
}

@override
String toString() {
    return 'LiteratureRecord(source: $source, id: $id, pmid: $pmid, pmcid: $pmcid, doi: $doi, s2Id: $s2Id, title: $title, abstract: $abstract, year: $year, journal: $journal, issn: $issn, authors: $authors, types: $types, citedBy: $citedBy, openAccessPdf: $openAccessPdf, tldr: $tldr, rank: $rank)';
}


}

/// @nodoc
abstract mixin class _$LiteratureRecordCopyWith<$Res> implements $LiteratureRecordCopyWith<$Res> {
  factory _$LiteratureRecordCopyWith(_LiteratureRecord value, $Res Function(_LiteratureRecord) _then) = __$LiteratureRecordCopyWithImpl;
@override @useResult
$Res call({
 LiteratureSource source, String id, String? pmid, String? pmcid, String? doi, String? s2Id, String title, String? abstract, String? year, String? journal, String? issn, List<String> authors, List<String> types, int? citedBy, String? openAccessPdf, String? tldr, RankInfo? rank
});


@override $RankInfoCopyWith<$Res>? get rank;

}
/// @nodoc
class __$LiteratureRecordCopyWithImpl<$Res>
    implements _$LiteratureRecordCopyWith<$Res> {
  __$LiteratureRecordCopyWithImpl(this._self, this._then);

  final _LiteratureRecord _self;
  final $Res Function(_LiteratureRecord) _then;

/// Create a copy of LiteratureRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? source = null,Object? id = null,Object? pmid = freezed,Object? pmcid = freezed,Object? doi = freezed,Object? s2Id = freezed,Object? title = null,Object? abstract = freezed,Object? year = freezed,Object? journal = freezed,Object? issn = freezed,Object? authors = null,Object? types = null,Object? citedBy = freezed,Object? openAccessPdf = freezed,Object? tldr = freezed,Object? rank = freezed,}) {
  return _then(_LiteratureRecord(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as LiteratureSource,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,pmid: freezed == pmid ? _self.pmid : pmid // ignore: cast_nullable_to_non_nullable
as String?,pmcid: freezed == pmcid ? _self.pmcid : pmcid // ignore: cast_nullable_to_non_nullable
as String?,doi: freezed == doi ? _self.doi : doi // ignore: cast_nullable_to_non_nullable
as String?,s2Id: freezed == s2Id ? _self.s2Id : s2Id // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,abstract: freezed == abstract ? _self.abstract : abstract // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String?,journal: freezed == journal ? _self.journal : journal // ignore: cast_nullable_to_non_nullable
as String?,issn: freezed == issn ? _self.issn : issn // ignore: cast_nullable_to_non_nullable
as String?,authors: null == authors ? _self._authors : authors // ignore: cast_nullable_to_non_nullable
as List<String>,types: null == types ? _self._types : types // ignore: cast_nullable_to_non_nullable
as List<String>,citedBy: freezed == citedBy ? _self.citedBy : citedBy // ignore: cast_nullable_to_non_nullable
as int?,openAccessPdf: freezed == openAccessPdf ? _self.openAccessPdf : openAccessPdf // ignore: cast_nullable_to_non_nullable
as String?,tldr: freezed == tldr ? _self.tldr : tldr // ignore: cast_nullable_to_non_nullable
as String?,rank: freezed == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as RankInfo?,
  ));
}

/// Create a copy of LiteratureRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RankInfoCopyWith<$Res>? get rank {
    if (_self.rank == null) {
    return null;
  }

  return $RankInfoCopyWith<$Res>(_self.rank!, (value) {
    return _then(_self.copyWith(rank: value));
  });
}
}


/// @nodoc
mixin _$LiteratureSearchResult {

 LiteratureSource get source; int get total; List<LiteratureRecord> get items; String? get fallbackReason;
/// Create a copy of LiteratureSearchResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiteratureSearchResultCopyWith<LiteratureSearchResult> get copyWith => _$LiteratureSearchResultCopyWithImpl<LiteratureSearchResult>(this as LiteratureSearchResult, _$identity);

  /// Serializes this LiteratureSearchResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LiteratureSearchResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiteratureSearchResult&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.total, _this.total) || other.total == _this.total)&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.fallbackReason, _this.fallbackReason) || other.fallbackReason == _this.fallbackReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LiteratureSearchResult;
  return Object.hash(runtimeType,_this.source,_this.total,const DeepCollectionEquality().hash(_this.items),_this.fallbackReason);
}

@override
String toString() {
  final _this = this as LiteratureSearchResult;
  return 'LiteratureSearchResult(source: ${_this.source}, total: ${_this.total}, items: ${_this.items}, fallbackReason: ${_this.fallbackReason})';
}


}

/// @nodoc
abstract mixin class $LiteratureSearchResultCopyWith<$Res>  {
  factory $LiteratureSearchResultCopyWith(LiteratureSearchResult value, $Res Function(LiteratureSearchResult) _then) = _$LiteratureSearchResultCopyWithImpl;
@useResult
$Res call({
 LiteratureSource source, int total, List<LiteratureRecord> items, String? fallbackReason
});




}
/// @nodoc
class _$LiteratureSearchResultCopyWithImpl<$Res>
    implements $LiteratureSearchResultCopyWith<$Res> {
  _$LiteratureSearchResultCopyWithImpl(this._self, this._then);

  final LiteratureSearchResult _self;
  final $Res Function(LiteratureSearchResult) _then;

/// Create a copy of LiteratureSearchResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? source = null,Object? total = null,Object? items = null,Object? fallbackReason = freezed,}) {
  return _then(LiteratureSearchResult(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as LiteratureSource,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<LiteratureRecord>,fallbackReason: freezed == fallbackReason ? _self.fallbackReason : fallbackReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LiteratureSearchResult].
extension LiteratureSearchResultPatterns on LiteratureSearchResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiteratureSearchResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiteratureSearchResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiteratureSearchResult value)  $default,){
final _that = this;
switch (_that) {
case _LiteratureSearchResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiteratureSearchResult value)?  $default,){
final _that = this;
switch (_that) {
case _LiteratureSearchResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LiteratureSource source,  int total,  List<LiteratureRecord> items,  String? fallbackReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiteratureSearchResult() when $default != null:
return $default(_that.source,_that.total,_that.items,_that.fallbackReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LiteratureSource source,  int total,  List<LiteratureRecord> items,  String? fallbackReason)  $default,) {final _that = this;
switch (_that) {
case _LiteratureSearchResult():
return $default(_that.source,_that.total,_that.items,_that.fallbackReason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LiteratureSource source,  int total,  List<LiteratureRecord> items,  String? fallbackReason)?  $default,) {final _that = this;
switch (_that) {
case _LiteratureSearchResult() when $default != null:
return $default(_that.source,_that.total,_that.items,_that.fallbackReason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LiteratureSearchResult implements LiteratureSearchResult {
  const _LiteratureSearchResult({required this.source, this.total = 0,  List<LiteratureRecord> items = const <LiteratureRecord>[], this.fallbackReason}): _items = items;
  factory _LiteratureSearchResult.fromJson(Map<String, dynamic> json) => _$LiteratureSearchResultFromJson(json);

@override final  LiteratureSource source;
@override@JsonKey() final  int total;
 final  List<LiteratureRecord> _items;
@override@JsonKey() List<LiteratureRecord> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? fallbackReason;

/// Create a copy of LiteratureSearchResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiteratureSearchResultCopyWith<_LiteratureSearchResult> get copyWith => __$LiteratureSearchResultCopyWithImpl<_LiteratureSearchResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LiteratureSearchResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiteratureSearchResult&&(identical(other.source, source) || other.source == source)&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.fallbackReason, fallbackReason) || other.fallbackReason == fallbackReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,source,total,const DeepCollectionEquality().hash(_items),fallbackReason);
}

@override
String toString() {
    return 'LiteratureSearchResult(source: $source, total: $total, items: $items, fallbackReason: $fallbackReason)';
}


}

/// @nodoc
abstract mixin class _$LiteratureSearchResultCopyWith<$Res> implements $LiteratureSearchResultCopyWith<$Res> {
  factory _$LiteratureSearchResultCopyWith(_LiteratureSearchResult value, $Res Function(_LiteratureSearchResult) _then) = __$LiteratureSearchResultCopyWithImpl;
@override @useResult
$Res call({
 LiteratureSource source, int total, List<LiteratureRecord> items, String? fallbackReason
});




}
/// @nodoc
class __$LiteratureSearchResultCopyWithImpl<$Res>
    implements _$LiteratureSearchResultCopyWith<$Res> {
  __$LiteratureSearchResultCopyWithImpl(this._self, this._then);

  final _LiteratureSearchResult _self;
  final $Res Function(_LiteratureSearchResult) _then;

/// Create a copy of LiteratureSearchResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? source = null,Object? total = null,Object? items = null,Object? fallbackReason = freezed,}) {
  return _then(_LiteratureSearchResult(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as LiteratureSource,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<LiteratureRecord>,fallbackReason: freezed == fallbackReason ? _self.fallbackReason : fallbackReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$FulltextSection {

 String get title; int get chars;
/// Create a copy of FulltextSection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FulltextSectionCopyWith<FulltextSection> get copyWith => _$FulltextSectionCopyWithImpl<FulltextSection>(this as FulltextSection, _$identity);

  /// Serializes this FulltextSection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FulltextSection;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FulltextSection&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.chars, _this.chars) || other.chars == _this.chars));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FulltextSection;
  return Object.hash(runtimeType,_this.title,_this.chars);
}

@override
String toString() {
  final _this = this as FulltextSection;
  return 'FulltextSection(title: ${_this.title}, chars: ${_this.chars})';
}


}

/// @nodoc
abstract mixin class $FulltextSectionCopyWith<$Res>  {
  factory $FulltextSectionCopyWith(FulltextSection value, $Res Function(FulltextSection) _then) = _$FulltextSectionCopyWithImpl;
@useResult
$Res call({
 String title, int chars
});




}
/// @nodoc
class _$FulltextSectionCopyWithImpl<$Res>
    implements $FulltextSectionCopyWith<$Res> {
  _$FulltextSectionCopyWithImpl(this._self, this._then);

  final FulltextSection _self;
  final $Res Function(FulltextSection) _then;

/// Create a copy of FulltextSection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? chars = null,}) {
  return _then(FulltextSection(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,chars: null == chars ? _self.chars : chars // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FulltextSection].
extension FulltextSectionPatterns on FulltextSection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FulltextSection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FulltextSection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FulltextSection value)  $default,){
final _that = this;
switch (_that) {
case _FulltextSection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FulltextSection value)?  $default,){
final _that = this;
switch (_that) {
case _FulltextSection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  int chars)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FulltextSection() when $default != null:
return $default(_that.title,_that.chars);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  int chars)  $default,) {final _that = this;
switch (_that) {
case _FulltextSection():
return $default(_that.title,_that.chars);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  int chars)?  $default,) {final _that = this;
switch (_that) {
case _FulltextSection() when $default != null:
return $default(_that.title,_that.chars);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FulltextSection implements FulltextSection {
  const _FulltextSection({this.title = '', this.chars = 0});
  factory _FulltextSection.fromJson(Map<String, dynamic> json) => _$FulltextSectionFromJson(json);

@override@JsonKey() final  String title;
@override@JsonKey() final  int chars;

/// Create a copy of FulltextSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FulltextSectionCopyWith<_FulltextSection> get copyWith => __$FulltextSectionCopyWithImpl<_FulltextSection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FulltextSectionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FulltextSection&&(identical(other.title, title) || other.title == title)&&(identical(other.chars, chars) || other.chars == chars));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,title,chars);
}

@override
String toString() {
    return 'FulltextSection(title: $title, chars: $chars)';
}


}

/// @nodoc
abstract mixin class _$FulltextSectionCopyWith<$Res> implements $FulltextSectionCopyWith<$Res> {
  factory _$FulltextSectionCopyWith(_FulltextSection value, $Res Function(_FulltextSection) _then) = __$FulltextSectionCopyWithImpl;
@override @useResult
$Res call({
 String title, int chars
});




}
/// @nodoc
class __$FulltextSectionCopyWithImpl<$Res>
    implements _$FulltextSectionCopyWith<$Res> {
  __$FulltextSectionCopyWithImpl(this._self, this._then);

  final _FulltextSection _self;
  final $Res Function(_FulltextSection) _then;

/// Create a copy of FulltextSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? chars = null,}) {
  return _then(_FulltextSection(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,chars: null == chars ? _self.chars : chars // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$FulltextResult {

 String get pmcid; String get citation; List<FulltextSection> get sections; String get abstract; String? get section; String? get text; bool get truncated;
/// Create a copy of FulltextResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FulltextResultCopyWith<FulltextResult> get copyWith => _$FulltextResultCopyWithImpl<FulltextResult>(this as FulltextResult, _$identity);

  /// Serializes this FulltextResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FulltextResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FulltextResult&&(identical(other.pmcid, _this.pmcid) || other.pmcid == _this.pmcid)&&(identical(other.citation, _this.citation) || other.citation == _this.citation)&&const DeepCollectionEquality().equals(other.sections, _this.sections)&&(identical(other.abstract, _this.abstract) || other.abstract == _this.abstract)&&(identical(other.section, _this.section) || other.section == _this.section)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.truncated, _this.truncated) || other.truncated == _this.truncated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FulltextResult;
  return Object.hash(runtimeType,_this.pmcid,_this.citation,const DeepCollectionEquality().hash(_this.sections),_this.abstract,_this.section,_this.text,_this.truncated);
}

@override
String toString() {
  final _this = this as FulltextResult;
  return 'FulltextResult(pmcid: ${_this.pmcid}, citation: ${_this.citation}, sections: ${_this.sections}, abstract: ${_this.abstract}, section: ${_this.section}, text: ${_this.text}, truncated: ${_this.truncated})';
}


}

/// @nodoc
abstract mixin class $FulltextResultCopyWith<$Res>  {
  factory $FulltextResultCopyWith(FulltextResult value, $Res Function(FulltextResult) _then) = _$FulltextResultCopyWithImpl;
@useResult
$Res call({
 String pmcid, String citation, List<FulltextSection> sections, String abstract, String? section, String? text, bool truncated
});




}
/// @nodoc
class _$FulltextResultCopyWithImpl<$Res>
    implements $FulltextResultCopyWith<$Res> {
  _$FulltextResultCopyWithImpl(this._self, this._then);

  final FulltextResult _self;
  final $Res Function(FulltextResult) _then;

/// Create a copy of FulltextResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pmcid = null,Object? citation = null,Object? sections = null,Object? abstract = null,Object? section = freezed,Object? text = freezed,Object? truncated = null,}) {
  return _then(FulltextResult(
pmcid: null == pmcid ? _self.pmcid : pmcid // ignore: cast_nullable_to_non_nullable
as String,citation: null == citation ? _self.citation : citation // ignore: cast_nullable_to_non_nullable
as String,sections: null == sections ? _self.sections : sections // ignore: cast_nullable_to_non_nullable
as List<FulltextSection>,abstract: null == abstract ? _self.abstract : abstract // ignore: cast_nullable_to_non_nullable
as String,section: freezed == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,truncated: null == truncated ? _self.truncated : truncated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FulltextResult].
extension FulltextResultPatterns on FulltextResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FulltextResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FulltextResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FulltextResult value)  $default,){
final _that = this;
switch (_that) {
case _FulltextResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FulltextResult value)?  $default,){
final _that = this;
switch (_that) {
case _FulltextResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String pmcid,  String citation,  List<FulltextSection> sections,  String abstract,  String? section,  String? text,  bool truncated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FulltextResult() when $default != null:
return $default(_that.pmcid,_that.citation,_that.sections,_that.abstract,_that.section,_that.text,_that.truncated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String pmcid,  String citation,  List<FulltextSection> sections,  String abstract,  String? section,  String? text,  bool truncated)  $default,) {final _that = this;
switch (_that) {
case _FulltextResult():
return $default(_that.pmcid,_that.citation,_that.sections,_that.abstract,_that.section,_that.text,_that.truncated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String pmcid,  String citation,  List<FulltextSection> sections,  String abstract,  String? section,  String? text,  bool truncated)?  $default,) {final _that = this;
switch (_that) {
case _FulltextResult() when $default != null:
return $default(_that.pmcid,_that.citation,_that.sections,_that.abstract,_that.section,_that.text,_that.truncated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FulltextResult implements FulltextResult {
  const _FulltextResult({this.pmcid = '', this.citation = '',  List<FulltextSection> sections = const <FulltextSection>[], this.abstract = '', this.section, this.text, this.truncated = false}): _sections = sections;
  factory _FulltextResult.fromJson(Map<String, dynamic> json) => _$FulltextResultFromJson(json);

@override@JsonKey() final  String pmcid;
@override@JsonKey() final  String citation;
 final  List<FulltextSection> _sections;
@override@JsonKey() List<FulltextSection> get sections {
  if (_sections is EqualUnmodifiableListView) return _sections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sections);
}

@override@JsonKey() final  String abstract;
@override final  String? section;
@override final  String? text;
@override@JsonKey() final  bool truncated;

/// Create a copy of FulltextResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FulltextResultCopyWith<_FulltextResult> get copyWith => __$FulltextResultCopyWithImpl<_FulltextResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FulltextResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FulltextResult&&(identical(other.pmcid, pmcid) || other.pmcid == pmcid)&&(identical(other.citation, citation) || other.citation == citation)&&const DeepCollectionEquality().equals(other.sections, _sections)&&(identical(other.abstract, abstract) || other.abstract == abstract)&&(identical(other.section, section) || other.section == section)&&(identical(other.text, text) || other.text == text)&&(identical(other.truncated, truncated) || other.truncated == truncated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,pmcid,citation,const DeepCollectionEquality().hash(_sections),abstract,section,text,truncated);
}

@override
String toString() {
    return 'FulltextResult(pmcid: $pmcid, citation: $citation, sections: $sections, abstract: $abstract, section: $section, text: $text, truncated: $truncated)';
}


}

/// @nodoc
abstract mixin class _$FulltextResultCopyWith<$Res> implements $FulltextResultCopyWith<$Res> {
  factory _$FulltextResultCopyWith(_FulltextResult value, $Res Function(_FulltextResult) _then) = __$FulltextResultCopyWithImpl;
@override @useResult
$Res call({
 String pmcid, String citation, List<FulltextSection> sections, String abstract, String? section, String? text, bool truncated
});




}
/// @nodoc
class __$FulltextResultCopyWithImpl<$Res>
    implements _$FulltextResultCopyWith<$Res> {
  __$FulltextResultCopyWithImpl(this._self, this._then);

  final _FulltextResult _self;
  final $Res Function(_FulltextResult) _then;

/// Create a copy of FulltextResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pmcid = null,Object? citation = null,Object? sections = null,Object? abstract = null,Object? section = freezed,Object? text = freezed,Object? truncated = null,}) {
  return _then(_FulltextResult(
pmcid: null == pmcid ? _self.pmcid : pmcid // ignore: cast_nullable_to_non_nullable
as String,citation: null == citation ? _self.citation : citation // ignore: cast_nullable_to_non_nullable
as String,sections: null == sections ? _self._sections : sections // ignore: cast_nullable_to_non_nullable
as List<FulltextSection>,abstract: null == abstract ? _self.abstract : abstract // ignore: cast_nullable_to_non_nullable
as String,section: freezed == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,truncated: null == truncated ? _self.truncated : truncated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
