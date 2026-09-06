// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'endpoints.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LiteratureQuery {

 String get q; LiteratureSource get source; int get limit; int? get years; int? get yearFrom; int? get yearTo; List<String> get publicationTypes; List<int> get quartiles; List<String> get journals; bool get openAccessOnly;
/// Create a copy of LiteratureQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiteratureQueryCopyWith<LiteratureQuery> get copyWith => _$LiteratureQueryCopyWithImpl<LiteratureQuery>(this as LiteratureQuery, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LiteratureQuery;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiteratureQuery&&(identical(other.q, _this.q) || other.q == _this.q)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.limit, _this.limit) || other.limit == _this.limit)&&(identical(other.years, _this.years) || other.years == _this.years)&&(identical(other.yearFrom, _this.yearFrom) || other.yearFrom == _this.yearFrom)&&(identical(other.yearTo, _this.yearTo) || other.yearTo == _this.yearTo)&&const DeepCollectionEquality().equals(other.publicationTypes, _this.publicationTypes)&&const DeepCollectionEquality().equals(other.quartiles, _this.quartiles)&&const DeepCollectionEquality().equals(other.journals, _this.journals)&&(identical(other.openAccessOnly, _this.openAccessOnly) || other.openAccessOnly == _this.openAccessOnly));
}


@override
int get hashCode {
  final _this = this as LiteratureQuery;
  return Object.hash(runtimeType,_this.q,_this.source,_this.limit,_this.years,_this.yearFrom,_this.yearTo,const DeepCollectionEquality().hash(_this.publicationTypes),const DeepCollectionEquality().hash(_this.quartiles),const DeepCollectionEquality().hash(_this.journals),_this.openAccessOnly);
}

@override
String toString() {
  final _this = this as LiteratureQuery;
  return 'LiteratureQuery(q: ${_this.q}, source: ${_this.source}, limit: ${_this.limit}, years: ${_this.years}, yearFrom: ${_this.yearFrom}, yearTo: ${_this.yearTo}, publicationTypes: ${_this.publicationTypes}, quartiles: ${_this.quartiles}, journals: ${_this.journals}, openAccessOnly: ${_this.openAccessOnly})';
}


}

/// @nodoc
abstract mixin class $LiteratureQueryCopyWith<$Res>  {
  factory $LiteratureQueryCopyWith(LiteratureQuery value, $Res Function(LiteratureQuery) _then) = _$LiteratureQueryCopyWithImpl;
@useResult
$Res call({
 String q, LiteratureSource source, int limit, int? years, int? yearFrom, int? yearTo, List<String> publicationTypes, List<int> quartiles, List<String> journals, bool openAccessOnly
});




}
/// @nodoc
class _$LiteratureQueryCopyWithImpl<$Res>
    implements $LiteratureQueryCopyWith<$Res> {
  _$LiteratureQueryCopyWithImpl(this._self, this._then);

  final LiteratureQuery _self;
  final $Res Function(LiteratureQuery) _then;

/// Create a copy of LiteratureQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? q = null,Object? source = null,Object? limit = null,Object? years = freezed,Object? yearFrom = freezed,Object? yearTo = freezed,Object? publicationTypes = null,Object? quartiles = null,Object? journals = null,Object? openAccessOnly = null,}) {
  return _then(LiteratureQuery(
q: null == q ? _self.q : q // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as LiteratureSource,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,years: freezed == years ? _self.years : years // ignore: cast_nullable_to_non_nullable
as int?,yearFrom: freezed == yearFrom ? _self.yearFrom : yearFrom // ignore: cast_nullable_to_non_nullable
as int?,yearTo: freezed == yearTo ? _self.yearTo : yearTo // ignore: cast_nullable_to_non_nullable
as int?,publicationTypes: null == publicationTypes ? _self.publicationTypes : publicationTypes // ignore: cast_nullable_to_non_nullable
as List<String>,quartiles: null == quartiles ? _self.quartiles : quartiles // ignore: cast_nullable_to_non_nullable
as List<int>,journals: null == journals ? _self.journals : journals // ignore: cast_nullable_to_non_nullable
as List<String>,openAccessOnly: null == openAccessOnly ? _self.openAccessOnly : openAccessOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LiteratureQuery].
extension LiteratureQueryPatterns on LiteratureQuery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiteratureQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiteratureQuery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiteratureQuery value)  $default,){
final _that = this;
switch (_that) {
case _LiteratureQuery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiteratureQuery value)?  $default,){
final _that = this;
switch (_that) {
case _LiteratureQuery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String q,  LiteratureSource source,  int limit,  int? years,  int? yearFrom,  int? yearTo,  List<String> publicationTypes,  List<int> quartiles,  List<String> journals,  bool openAccessOnly)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiteratureQuery() when $default != null:
return $default(_that.q,_that.source,_that.limit,_that.years,_that.yearFrom,_that.yearTo,_that.publicationTypes,_that.quartiles,_that.journals,_that.openAccessOnly);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String q,  LiteratureSource source,  int limit,  int? years,  int? yearFrom,  int? yearTo,  List<String> publicationTypes,  List<int> quartiles,  List<String> journals,  bool openAccessOnly)  $default,) {final _that = this;
switch (_that) {
case _LiteratureQuery():
return $default(_that.q,_that.source,_that.limit,_that.years,_that.yearFrom,_that.yearTo,_that.publicationTypes,_that.quartiles,_that.journals,_that.openAccessOnly);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String q,  LiteratureSource source,  int limit,  int? years,  int? yearFrom,  int? yearTo,  List<String> publicationTypes,  List<int> quartiles,  List<String> journals,  bool openAccessOnly)?  $default,) {final _that = this;
switch (_that) {
case _LiteratureQuery() when $default != null:
return $default(_that.q,_that.source,_that.limit,_that.years,_that.yearFrom,_that.yearTo,_that.publicationTypes,_that.quartiles,_that.journals,_that.openAccessOnly);case _:
  return null;

}
}

}

/// @nodoc


class _LiteratureQuery extends LiteratureQuery {
  const _LiteratureQuery({required this.q, this.source = LiteratureSource.auto, this.limit = 10, this.years, this.yearFrom, this.yearTo,  List<String> publicationTypes = const <String>[],  List<int> quartiles = const <int>[],  List<String> journals = const <String>[], this.openAccessOnly = false}): _publicationTypes = publicationTypes,_quartiles = quartiles,_journals = journals,super._();
  

@override final  String q;
@override@JsonKey() final  LiteratureSource source;
@override@JsonKey() final  int limit;
@override final  int? years;
@override final  int? yearFrom;
@override final  int? yearTo;
 final  List<String> _publicationTypes;
@override@JsonKey() List<String> get publicationTypes {
  if (_publicationTypes is EqualUnmodifiableListView) return _publicationTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_publicationTypes);
}

 final  List<int> _quartiles;
@override@JsonKey() List<int> get quartiles {
  if (_quartiles is EqualUnmodifiableListView) return _quartiles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_quartiles);
}

 final  List<String> _journals;
@override@JsonKey() List<String> get journals {
  if (_journals is EqualUnmodifiableListView) return _journals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_journals);
}

@override@JsonKey() final  bool openAccessOnly;

/// Create a copy of LiteratureQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiteratureQueryCopyWith<_LiteratureQuery> get copyWith => __$LiteratureQueryCopyWithImpl<_LiteratureQuery>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiteratureQuery&&(identical(other.q, q) || other.q == q)&&(identical(other.source, source) || other.source == source)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.years, years) || other.years == years)&&(identical(other.yearFrom, yearFrom) || other.yearFrom == yearFrom)&&(identical(other.yearTo, yearTo) || other.yearTo == yearTo)&&const DeepCollectionEquality().equals(other.publicationTypes, _publicationTypes)&&const DeepCollectionEquality().equals(other.quartiles, _quartiles)&&const DeepCollectionEquality().equals(other.journals, _journals)&&(identical(other.openAccessOnly, openAccessOnly) || other.openAccessOnly == openAccessOnly));
}


@override
int get hashCode {
    return Object.hash(runtimeType,q,source,limit,years,yearFrom,yearTo,const DeepCollectionEquality().hash(_publicationTypes),const DeepCollectionEquality().hash(_quartiles),const DeepCollectionEquality().hash(_journals),openAccessOnly);
}

@override
String toString() {
    return 'LiteratureQuery(q: $q, source: $source, limit: $limit, years: $years, yearFrom: $yearFrom, yearTo: $yearTo, publicationTypes: $publicationTypes, quartiles: $quartiles, journals: $journals, openAccessOnly: $openAccessOnly)';
}


}

/// @nodoc
abstract mixin class _$LiteratureQueryCopyWith<$Res> implements $LiteratureQueryCopyWith<$Res> {
  factory _$LiteratureQueryCopyWith(_LiteratureQuery value, $Res Function(_LiteratureQuery) _then) = __$LiteratureQueryCopyWithImpl;
@override @useResult
$Res call({
 String q, LiteratureSource source, int limit, int? years, int? yearFrom, int? yearTo, List<String> publicationTypes, List<int> quartiles, List<String> journals, bool openAccessOnly
});




}
/// @nodoc
class __$LiteratureQueryCopyWithImpl<$Res>
    implements _$LiteratureQueryCopyWith<$Res> {
  __$LiteratureQueryCopyWithImpl(this._self, this._then);

  final _LiteratureQuery _self;
  final $Res Function(_LiteratureQuery) _then;

/// Create a copy of LiteratureQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? q = null,Object? source = null,Object? limit = null,Object? years = freezed,Object? yearFrom = freezed,Object? yearTo = freezed,Object? publicationTypes = null,Object? quartiles = null,Object? journals = null,Object? openAccessOnly = null,}) {
  return _then(_LiteratureQuery(
q: null == q ? _self.q : q // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as LiteratureSource,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,years: freezed == years ? _self.years : years // ignore: cast_nullable_to_non_nullable
as int?,yearFrom: freezed == yearFrom ? _self.yearFrom : yearFrom // ignore: cast_nullable_to_non_nullable
as int?,yearTo: freezed == yearTo ? _self.yearTo : yearTo // ignore: cast_nullable_to_non_nullable
as int?,publicationTypes: null == publicationTypes ? _self._publicationTypes : publicationTypes // ignore: cast_nullable_to_non_nullable
as List<String>,quartiles: null == quartiles ? _self._quartiles : quartiles // ignore: cast_nullable_to_non_nullable
as List<int>,journals: null == journals ? _self._journals : journals // ignore: cast_nullable_to_non_nullable
as List<String>,openAccessOnly: null == openAccessOnly ? _self.openAccessOnly : openAccessOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
