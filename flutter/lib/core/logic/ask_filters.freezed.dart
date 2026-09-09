// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ask_filters.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AskFilters {

 AnswerEngine get engine; List<int> get quartiles; bool get keepUnranked; YearMode get yearMode; int get years; int? get yearFrom; int? get yearTo; List<String> get journals; int get papers; bool get useKb; int get kbHits; int get maxChars;
/// Create a copy of AskFilters
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AskFiltersCopyWith<AskFilters> get copyWith => _$AskFiltersCopyWithImpl<AskFilters>(this as AskFilters, _$identity);

  /// Serializes this AskFilters to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AskFilters;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AskFilters&&(identical(other.engine, _this.engine) || other.engine == _this.engine)&&const DeepCollectionEquality().equals(other.quartiles, _this.quartiles)&&(identical(other.keepUnranked, _this.keepUnranked) || other.keepUnranked == _this.keepUnranked)&&(identical(other.yearMode, _this.yearMode) || other.yearMode == _this.yearMode)&&(identical(other.years, _this.years) || other.years == _this.years)&&(identical(other.yearFrom, _this.yearFrom) || other.yearFrom == _this.yearFrom)&&(identical(other.yearTo, _this.yearTo) || other.yearTo == _this.yearTo)&&const DeepCollectionEquality().equals(other.journals, _this.journals)&&(identical(other.papers, _this.papers) || other.papers == _this.papers)&&(identical(other.useKb, _this.useKb) || other.useKb == _this.useKb)&&(identical(other.kbHits, _this.kbHits) || other.kbHits == _this.kbHits)&&(identical(other.maxChars, _this.maxChars) || other.maxChars == _this.maxChars));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AskFilters;
  return Object.hash(runtimeType,_this.engine,const DeepCollectionEquality().hash(_this.quartiles),_this.keepUnranked,_this.yearMode,_this.years,_this.yearFrom,_this.yearTo,const DeepCollectionEquality().hash(_this.journals),_this.papers,_this.useKb,_this.kbHits,_this.maxChars);
}

@override
String toString() {
  final _this = this as AskFilters;
  return 'AskFilters(engine: ${_this.engine}, quartiles: ${_this.quartiles}, keepUnranked: ${_this.keepUnranked}, yearMode: ${_this.yearMode}, years: ${_this.years}, yearFrom: ${_this.yearFrom}, yearTo: ${_this.yearTo}, journals: ${_this.journals}, papers: ${_this.papers}, useKb: ${_this.useKb}, kbHits: ${_this.kbHits}, maxChars: ${_this.maxChars})';
}


}

/// @nodoc
abstract mixin class $AskFiltersCopyWith<$Res>  {
  factory $AskFiltersCopyWith(AskFilters value, $Res Function(AskFilters) _then) = _$AskFiltersCopyWithImpl;
@useResult
$Res call({
 AnswerEngine engine, List<int> quartiles, bool keepUnranked, YearMode yearMode, int years, int? yearFrom, int? yearTo, List<String> journals, int papers, bool useKb, int kbHits, int maxChars
});




}
/// @nodoc
class _$AskFiltersCopyWithImpl<$Res>
    implements $AskFiltersCopyWith<$Res> {
  _$AskFiltersCopyWithImpl(this._self, this._then);

  final AskFilters _self;
  final $Res Function(AskFilters) _then;

/// Create a copy of AskFilters
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? engine = null,Object? quartiles = null,Object? keepUnranked = null,Object? yearMode = null,Object? years = null,Object? yearFrom = freezed,Object? yearTo = freezed,Object? journals = null,Object? papers = null,Object? useKb = null,Object? kbHits = null,Object? maxChars = null,}) {
  return _then(AskFilters(
engine: null == engine ? _self.engine : engine // ignore: cast_nullable_to_non_nullable
as AnswerEngine,quartiles: null == quartiles ? _self.quartiles : quartiles // ignore: cast_nullable_to_non_nullable
as List<int>,keepUnranked: null == keepUnranked ? _self.keepUnranked : keepUnranked // ignore: cast_nullable_to_non_nullable
as bool,yearMode: null == yearMode ? _self.yearMode : yearMode // ignore: cast_nullable_to_non_nullable
as YearMode,years: null == years ? _self.years : years // ignore: cast_nullable_to_non_nullable
as int,yearFrom: freezed == yearFrom ? _self.yearFrom : yearFrom // ignore: cast_nullable_to_non_nullable
as int?,yearTo: freezed == yearTo ? _self.yearTo : yearTo // ignore: cast_nullable_to_non_nullable
as int?,journals: null == journals ? _self.journals : journals // ignore: cast_nullable_to_non_nullable
as List<String>,papers: null == papers ? _self.papers : papers // ignore: cast_nullable_to_non_nullable
as int,useKb: null == useKb ? _self.useKb : useKb // ignore: cast_nullable_to_non_nullable
as bool,kbHits: null == kbHits ? _self.kbHits : kbHits // ignore: cast_nullable_to_non_nullable
as int,maxChars: null == maxChars ? _self.maxChars : maxChars // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AskFilters].
extension AskFiltersPatterns on AskFilters {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AskFilters value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AskFilters() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AskFilters value)  $default,){
final _that = this;
switch (_that) {
case _AskFilters():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AskFilters value)?  $default,){
final _that = this;
switch (_that) {
case _AskFilters() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AnswerEngine engine,  List<int> quartiles,  bool keepUnranked,  YearMode yearMode,  int years,  int? yearFrom,  int? yearTo,  List<String> journals,  int papers,  bool useKb,  int kbHits,  int maxChars)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AskFilters() when $default != null:
return $default(_that.engine,_that.quartiles,_that.keepUnranked,_that.yearMode,_that.years,_that.yearFrom,_that.yearTo,_that.journals,_that.papers,_that.useKb,_that.kbHits,_that.maxChars);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AnswerEngine engine,  List<int> quartiles,  bool keepUnranked,  YearMode yearMode,  int years,  int? yearFrom,  int? yearTo,  List<String> journals,  int papers,  bool useKb,  int kbHits,  int maxChars)  $default,) {final _that = this;
switch (_that) {
case _AskFilters():
return $default(_that.engine,_that.quartiles,_that.keepUnranked,_that.yearMode,_that.years,_that.yearFrom,_that.yearTo,_that.journals,_that.papers,_that.useKb,_that.kbHits,_that.maxChars);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AnswerEngine engine,  List<int> quartiles,  bool keepUnranked,  YearMode yearMode,  int years,  int? yearFrom,  int? yearTo,  List<String> journals,  int papers,  bool useKb,  int kbHits,  int maxChars)?  $default,) {final _that = this;
switch (_that) {
case _AskFilters() when $default != null:
return $default(_that.engine,_that.quartiles,_that.keepUnranked,_that.yearMode,_that.years,_that.yearFrom,_that.yearTo,_that.journals,_that.papers,_that.useKb,_that.kbHits,_that.maxChars);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AskFilters extends AskFilters {
  const _AskFilters({this.engine = AnswerEngine.ask,  List<int> quartiles = const <int>[], this.keepUnranked = false, this.yearMode = YearMode.recent, this.years = 3, this.yearFrom, this.yearTo,  List<String> journals = const <String>[], this.papers = 8, this.useKb = true, this.kbHits = 0, this.maxChars = 28000}): _quartiles = quartiles,_journals = journals,super._();
  factory _AskFilters.fromJson(Map<String, dynamic> json) => _$AskFiltersFromJson(json);

@override@JsonKey() final  AnswerEngine engine;
 final  List<int> _quartiles;
@override@JsonKey() List<int> get quartiles {
  if (_quartiles is EqualUnmodifiableListView) return _quartiles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_quartiles);
}

@override@JsonKey() final  bool keepUnranked;
@override@JsonKey() final  YearMode yearMode;
@override@JsonKey() final  int years;
@override final  int? yearFrom;
@override final  int? yearTo;
 final  List<String> _journals;
@override@JsonKey() List<String> get journals {
  if (_journals is EqualUnmodifiableListView) return _journals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_journals);
}

@override@JsonKey() final  int papers;
@override@JsonKey() final  bool useKb;
@override@JsonKey() final  int kbHits;
@override@JsonKey() final  int maxChars;

/// Create a copy of AskFilters
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AskFiltersCopyWith<_AskFilters> get copyWith => __$AskFiltersCopyWithImpl<_AskFilters>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AskFiltersToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AskFilters&&(identical(other.engine, engine) || other.engine == engine)&&const DeepCollectionEquality().equals(other.quartiles, _quartiles)&&(identical(other.keepUnranked, keepUnranked) || other.keepUnranked == keepUnranked)&&(identical(other.yearMode, yearMode) || other.yearMode == yearMode)&&(identical(other.years, years) || other.years == years)&&(identical(other.yearFrom, yearFrom) || other.yearFrom == yearFrom)&&(identical(other.yearTo, yearTo) || other.yearTo == yearTo)&&const DeepCollectionEquality().equals(other.journals, _journals)&&(identical(other.papers, papers) || other.papers == papers)&&(identical(other.useKb, useKb) || other.useKb == useKb)&&(identical(other.kbHits, kbHits) || other.kbHits == kbHits)&&(identical(other.maxChars, maxChars) || other.maxChars == maxChars));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,engine,const DeepCollectionEquality().hash(_quartiles),keepUnranked,yearMode,years,yearFrom,yearTo,const DeepCollectionEquality().hash(_journals),papers,useKb,kbHits,maxChars);
}

@override
String toString() {
    return 'AskFilters(engine: $engine, quartiles: $quartiles, keepUnranked: $keepUnranked, yearMode: $yearMode, years: $years, yearFrom: $yearFrom, yearTo: $yearTo, journals: $journals, papers: $papers, useKb: $useKb, kbHits: $kbHits, maxChars: $maxChars)';
}


}

/// @nodoc
abstract mixin class _$AskFiltersCopyWith<$Res> implements $AskFiltersCopyWith<$Res> {
  factory _$AskFiltersCopyWith(_AskFilters value, $Res Function(_AskFilters) _then) = __$AskFiltersCopyWithImpl;
@override @useResult
$Res call({
 AnswerEngine engine, List<int> quartiles, bool keepUnranked, YearMode yearMode, int years, int? yearFrom, int? yearTo, List<String> journals, int papers, bool useKb, int kbHits, int maxChars
});




}
/// @nodoc
class __$AskFiltersCopyWithImpl<$Res>
    implements _$AskFiltersCopyWith<$Res> {
  __$AskFiltersCopyWithImpl(this._self, this._then);

  final _AskFilters _self;
  final $Res Function(_AskFilters) _then;

/// Create a copy of AskFilters
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? engine = null,Object? quartiles = null,Object? keepUnranked = null,Object? yearMode = null,Object? years = null,Object? yearFrom = freezed,Object? yearTo = freezed,Object? journals = null,Object? papers = null,Object? useKb = null,Object? kbHits = null,Object? maxChars = null,}) {
  return _then(_AskFilters(
engine: null == engine ? _self.engine : engine // ignore: cast_nullable_to_non_nullable
as AnswerEngine,quartiles: null == quartiles ? _self._quartiles : quartiles // ignore: cast_nullable_to_non_nullable
as List<int>,keepUnranked: null == keepUnranked ? _self.keepUnranked : keepUnranked // ignore: cast_nullable_to_non_nullable
as bool,yearMode: null == yearMode ? _self.yearMode : yearMode // ignore: cast_nullable_to_non_nullable
as YearMode,years: null == years ? _self.years : years // ignore: cast_nullable_to_non_nullable
as int,yearFrom: freezed == yearFrom ? _self.yearFrom : yearFrom // ignore: cast_nullable_to_non_nullable
as int?,yearTo: freezed == yearTo ? _self.yearTo : yearTo // ignore: cast_nullable_to_non_nullable
as int?,journals: null == journals ? _self._journals : journals // ignore: cast_nullable_to_non_nullable
as List<String>,papers: null == papers ? _self.papers : papers // ignore: cast_nullable_to_non_nullable
as int,useKb: null == useKb ? _self.useKb : useKb // ignore: cast_nullable_to_non_nullable
as bool,kbHits: null == kbHits ? _self.kbHits : kbHits // ignore: cast_nullable_to_non_nullable
as int,maxChars: null == maxChars ? _self.maxChars : maxChars // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
