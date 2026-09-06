// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kb.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$KbHit {

 KbKind get kind; String get pmid; String get doi; String get pmcid; String get title; String get year; String get journal; String get quartile; String get source; String get authors; int? get pid; String? get sec; int? get page; String get text; String? get textZh; String? get factKind; String? get quote; bool? get verified; double get score;
/// Create a copy of KbHit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KbHitCopyWith<KbHit> get copyWith => _$KbHitCopyWithImpl<KbHit>(this as KbHit, _$identity);

  /// Serializes this KbHit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as KbHit;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KbHit&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.pmid, _this.pmid) || other.pmid == _this.pmid)&&(identical(other.doi, _this.doi) || other.doi == _this.doi)&&(identical(other.pmcid, _this.pmcid) || other.pmcid == _this.pmcid)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.year, _this.year) || other.year == _this.year)&&(identical(other.journal, _this.journal) || other.journal == _this.journal)&&(identical(other.quartile, _this.quartile) || other.quartile == _this.quartile)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.authors, _this.authors) || other.authors == _this.authors)&&(identical(other.pid, _this.pid) || other.pid == _this.pid)&&(identical(other.sec, _this.sec) || other.sec == _this.sec)&&(identical(other.page, _this.page) || other.page == _this.page)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.textZh, _this.textZh) || other.textZh == _this.textZh)&&(identical(other.factKind, _this.factKind) || other.factKind == _this.factKind)&&(identical(other.quote, _this.quote) || other.quote == _this.quote)&&(identical(other.verified, _this.verified) || other.verified == _this.verified)&&(identical(other.score, _this.score) || other.score == _this.score));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as KbHit;
  return Object.hashAll([runtimeType,_this.kind,_this.pmid,_this.doi,_this.pmcid,_this.title,_this.year,_this.journal,_this.quartile,_this.source,_this.authors,_this.pid,_this.sec,_this.page,_this.text,_this.textZh,_this.factKind,_this.quote,_this.verified,_this.score]);
}

@override
String toString() {
  final _this = this as KbHit;
  return 'KbHit(kind: ${_this.kind}, pmid: ${_this.pmid}, doi: ${_this.doi}, pmcid: ${_this.pmcid}, title: ${_this.title}, year: ${_this.year}, journal: ${_this.journal}, quartile: ${_this.quartile}, source: ${_this.source}, authors: ${_this.authors}, pid: ${_this.pid}, sec: ${_this.sec}, page: ${_this.page}, text: ${_this.text}, textZh: ${_this.textZh}, factKind: ${_this.factKind}, quote: ${_this.quote}, verified: ${_this.verified}, score: ${_this.score})';
}


}

/// @nodoc
abstract mixin class $KbHitCopyWith<$Res>  {
  factory $KbHitCopyWith(KbHit value, $Res Function(KbHit) _then) = _$KbHitCopyWithImpl;
@useResult
$Res call({
 KbKind kind, String pmid, String doi, String pmcid, String title, String year, String journal, String quartile, String source, String authors, int? pid, String? sec, int? page, String text, String? textZh, String? factKind, String? quote, bool? verified, double score
});




}
/// @nodoc
class _$KbHitCopyWithImpl<$Res>
    implements $KbHitCopyWith<$Res> {
  _$KbHitCopyWithImpl(this._self, this._then);

  final KbHit _self;
  final $Res Function(KbHit) _then;

/// Create a copy of KbHit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? pmid = null,Object? doi = null,Object? pmcid = null,Object? title = null,Object? year = null,Object? journal = null,Object? quartile = null,Object? source = null,Object? authors = null,Object? pid = freezed,Object? sec = freezed,Object? page = freezed,Object? text = null,Object? textZh = freezed,Object? factKind = freezed,Object? quote = freezed,Object? verified = freezed,Object? score = null,}) {
  return _then(KbHit(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as KbKind,pmid: null == pmid ? _self.pmid : pmid // ignore: cast_nullable_to_non_nullable
as String,doi: null == doi ? _self.doi : doi // ignore: cast_nullable_to_non_nullable
as String,pmcid: null == pmcid ? _self.pmcid : pmcid // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String,journal: null == journal ? _self.journal : journal // ignore: cast_nullable_to_non_nullable
as String,quartile: null == quartile ? _self.quartile : quartile // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,authors: null == authors ? _self.authors : authors // ignore: cast_nullable_to_non_nullable
as String,pid: freezed == pid ? _self.pid : pid // ignore: cast_nullable_to_non_nullable
as int?,sec: freezed == sec ? _self.sec : sec // ignore: cast_nullable_to_non_nullable
as String?,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,textZh: freezed == textZh ? _self.textZh : textZh // ignore: cast_nullable_to_non_nullable
as String?,factKind: freezed == factKind ? _self.factKind : factKind // ignore: cast_nullable_to_non_nullable
as String?,quote: freezed == quote ? _self.quote : quote // ignore: cast_nullable_to_non_nullable
as String?,verified: freezed == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool?,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [KbHit].
extension KbHitPatterns on KbHit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KbHit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KbHit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KbHit value)  $default,){
final _that = this;
switch (_that) {
case _KbHit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KbHit value)?  $default,){
final _that = this;
switch (_that) {
case _KbHit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( KbKind kind,  String pmid,  String doi,  String pmcid,  String title,  String year,  String journal,  String quartile,  String source,  String authors,  int? pid,  String? sec,  int? page,  String text,  String? textZh,  String? factKind,  String? quote,  bool? verified,  double score)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KbHit() when $default != null:
return $default(_that.kind,_that.pmid,_that.doi,_that.pmcid,_that.title,_that.year,_that.journal,_that.quartile,_that.source,_that.authors,_that.pid,_that.sec,_that.page,_that.text,_that.textZh,_that.factKind,_that.quote,_that.verified,_that.score);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( KbKind kind,  String pmid,  String doi,  String pmcid,  String title,  String year,  String journal,  String quartile,  String source,  String authors,  int? pid,  String? sec,  int? page,  String text,  String? textZh,  String? factKind,  String? quote,  bool? verified,  double score)  $default,) {final _that = this;
switch (_that) {
case _KbHit():
return $default(_that.kind,_that.pmid,_that.doi,_that.pmcid,_that.title,_that.year,_that.journal,_that.quartile,_that.source,_that.authors,_that.pid,_that.sec,_that.page,_that.text,_that.textZh,_that.factKind,_that.quote,_that.verified,_that.score);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( KbKind kind,  String pmid,  String doi,  String pmcid,  String title,  String year,  String journal,  String quartile,  String source,  String authors,  int? pid,  String? sec,  int? page,  String text,  String? textZh,  String? factKind,  String? quote,  bool? verified,  double score)?  $default,) {final _that = this;
switch (_that) {
case _KbHit() when $default != null:
return $default(_that.kind,_that.pmid,_that.doi,_that.pmcid,_that.title,_that.year,_that.journal,_that.quartile,_that.source,_that.authors,_that.pid,_that.sec,_that.page,_that.text,_that.textZh,_that.factKind,_that.quote,_that.verified,_that.score);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KbHit implements KbHit {
  const _KbHit({required this.kind, this.pmid = '', this.doi = '', this.pmcid = '', this.title = '', this.year = '', this.journal = '', this.quartile = '', this.source = '', this.authors = '', this.pid, this.sec, this.page, this.text = '', this.textZh, this.factKind, this.quote, this.verified, this.score = 0});
  factory _KbHit.fromJson(Map<String, dynamic> json) => _$KbHitFromJson(json);

@override final  KbKind kind;
@override@JsonKey() final  String pmid;
@override@JsonKey() final  String doi;
@override@JsonKey() final  String pmcid;
@override@JsonKey() final  String title;
@override@JsonKey() final  String year;
@override@JsonKey() final  String journal;
@override@JsonKey() final  String quartile;
@override@JsonKey() final  String source;
@override@JsonKey() final  String authors;
@override final  int? pid;
@override final  String? sec;
@override final  int? page;
@override@JsonKey() final  String text;
@override final  String? textZh;
@override final  String? factKind;
@override final  String? quote;
@override final  bool? verified;
@override@JsonKey() final  double score;

/// Create a copy of KbHit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KbHitCopyWith<_KbHit> get copyWith => __$KbHitCopyWithImpl<_KbHit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KbHitToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _KbHit&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.pmid, pmid) || other.pmid == pmid)&&(identical(other.doi, doi) || other.doi == doi)&&(identical(other.pmcid, pmcid) || other.pmcid == pmcid)&&(identical(other.title, title) || other.title == title)&&(identical(other.year, year) || other.year == year)&&(identical(other.journal, journal) || other.journal == journal)&&(identical(other.quartile, quartile) || other.quartile == quartile)&&(identical(other.source, source) || other.source == source)&&(identical(other.authors, authors) || other.authors == authors)&&(identical(other.pid, pid) || other.pid == pid)&&(identical(other.sec, sec) || other.sec == sec)&&(identical(other.page, page) || other.page == page)&&(identical(other.text, text) || other.text == text)&&(identical(other.textZh, textZh) || other.textZh == textZh)&&(identical(other.factKind, factKind) || other.factKind == factKind)&&(identical(other.quote, quote) || other.quote == quote)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.score, score) || other.score == score));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,kind,pmid,doi,pmcid,title,year,journal,quartile,source,authors,pid,sec,page,text,textZh,factKind,quote,verified,score]);
}

@override
String toString() {
    return 'KbHit(kind: $kind, pmid: $pmid, doi: $doi, pmcid: $pmcid, title: $title, year: $year, journal: $journal, quartile: $quartile, source: $source, authors: $authors, pid: $pid, sec: $sec, page: $page, text: $text, textZh: $textZh, factKind: $factKind, quote: $quote, verified: $verified, score: $score)';
}


}

/// @nodoc
abstract mixin class _$KbHitCopyWith<$Res> implements $KbHitCopyWith<$Res> {
  factory _$KbHitCopyWith(_KbHit value, $Res Function(_KbHit) _then) = __$KbHitCopyWithImpl;
@override @useResult
$Res call({
 KbKind kind, String pmid, String doi, String pmcid, String title, String year, String journal, String quartile, String source, String authors, int? pid, String? sec, int? page, String text, String? textZh, String? factKind, String? quote, bool? verified, double score
});




}
/// @nodoc
class __$KbHitCopyWithImpl<$Res>
    implements _$KbHitCopyWith<$Res> {
  __$KbHitCopyWithImpl(this._self, this._then);

  final _KbHit _self;
  final $Res Function(_KbHit) _then;

/// Create a copy of KbHit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? pmid = null,Object? doi = null,Object? pmcid = null,Object? title = null,Object? year = null,Object? journal = null,Object? quartile = null,Object? source = null,Object? authors = null,Object? pid = freezed,Object? sec = freezed,Object? page = freezed,Object? text = null,Object? textZh = freezed,Object? factKind = freezed,Object? quote = freezed,Object? verified = freezed,Object? score = null,}) {
  return _then(_KbHit(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as KbKind,pmid: null == pmid ? _self.pmid : pmid // ignore: cast_nullable_to_non_nullable
as String,doi: null == doi ? _self.doi : doi // ignore: cast_nullable_to_non_nullable
as String,pmcid: null == pmcid ? _self.pmcid : pmcid // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String,journal: null == journal ? _self.journal : journal // ignore: cast_nullable_to_non_nullable
as String,quartile: null == quartile ? _self.quartile : quartile // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,authors: null == authors ? _self.authors : authors // ignore: cast_nullable_to_non_nullable
as String,pid: freezed == pid ? _self.pid : pid // ignore: cast_nullable_to_non_nullable
as int?,sec: freezed == sec ? _self.sec : sec // ignore: cast_nullable_to_non_nullable
as String?,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,textZh: freezed == textZh ? _self.textZh : textZh // ignore: cast_nullable_to_non_nullable
as String?,factKind: freezed == factKind ? _self.factKind : factKind // ignore: cast_nullable_to_non_nullable
as String?,quote: freezed == quote ? _self.quote : quote // ignore: cast_nullable_to_non_nullable
as String?,verified: freezed == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool?,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$KbSearchResult {

 String get query; List<KbHit> get items;
/// Create a copy of KbSearchResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KbSearchResultCopyWith<KbSearchResult> get copyWith => _$KbSearchResultCopyWithImpl<KbSearchResult>(this as KbSearchResult, _$identity);

  /// Serializes this KbSearchResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as KbSearchResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KbSearchResult&&(identical(other.query, _this.query) || other.query == _this.query)&&const DeepCollectionEquality().equals(other.items, _this.items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as KbSearchResult;
  return Object.hash(runtimeType,_this.query,const DeepCollectionEquality().hash(_this.items));
}

@override
String toString() {
  final _this = this as KbSearchResult;
  return 'KbSearchResult(query: ${_this.query}, items: ${_this.items})';
}


}

/// @nodoc
abstract mixin class $KbSearchResultCopyWith<$Res>  {
  factory $KbSearchResultCopyWith(KbSearchResult value, $Res Function(KbSearchResult) _then) = _$KbSearchResultCopyWithImpl;
@useResult
$Res call({
 String query, List<KbHit> items
});




}
/// @nodoc
class _$KbSearchResultCopyWithImpl<$Res>
    implements $KbSearchResultCopyWith<$Res> {
  _$KbSearchResultCopyWithImpl(this._self, this._then);

  final KbSearchResult _self;
  final $Res Function(KbSearchResult) _then;

/// Create a copy of KbSearchResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? items = null,}) {
  return _then(KbSearchResult(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<KbHit>,
  ));
}

}


/// Adds pattern-matching-related methods to [KbSearchResult].
extension KbSearchResultPatterns on KbSearchResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KbSearchResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KbSearchResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KbSearchResult value)  $default,){
final _that = this;
switch (_that) {
case _KbSearchResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KbSearchResult value)?  $default,){
final _that = this;
switch (_that) {
case _KbSearchResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String query,  List<KbHit> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KbSearchResult() when $default != null:
return $default(_that.query,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String query,  List<KbHit> items)  $default,) {final _that = this;
switch (_that) {
case _KbSearchResult():
return $default(_that.query,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String query,  List<KbHit> items)?  $default,) {final _that = this;
switch (_that) {
case _KbSearchResult() when $default != null:
return $default(_that.query,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KbSearchResult implements KbSearchResult {
  const _KbSearchResult({this.query = '',  List<KbHit> items = const <KbHit>[]}): _items = items;
  factory _KbSearchResult.fromJson(Map<String, dynamic> json) => _$KbSearchResultFromJson(json);

@override@JsonKey() final  String query;
 final  List<KbHit> _items;
@override@JsonKey() List<KbHit> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of KbSearchResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KbSearchResultCopyWith<_KbSearchResult> get copyWith => __$KbSearchResultCopyWithImpl<_KbSearchResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KbSearchResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _KbSearchResult&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other.items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,query,const DeepCollectionEquality().hash(_items));
}

@override
String toString() {
    return 'KbSearchResult(query: $query, items: $items)';
}


}

/// @nodoc
abstract mixin class _$KbSearchResultCopyWith<$Res> implements $KbSearchResultCopyWith<$Res> {
  factory _$KbSearchResultCopyWith(_KbSearchResult value, $Res Function(_KbSearchResult) _then) = __$KbSearchResultCopyWithImpl;
@override @useResult
$Res call({
 String query, List<KbHit> items
});




}
/// @nodoc
class __$KbSearchResultCopyWithImpl<$Res>
    implements _$KbSearchResultCopyWith<$Res> {
  __$KbSearchResultCopyWithImpl(this._self, this._then);

  final _KbSearchResult _self;
  final $Res Function(_KbSearchResult) _then;

/// Create a copy of KbSearchResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? items = null,}) {
  return _then(_KbSearchResult(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<KbHit>,
  ));
}


}


/// @nodoc
mixin _$KbStats {

 int get items; int get papers; Map<String, int> get byKind; String? get embedder; int? get dim;
/// Create a copy of KbStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KbStatsCopyWith<KbStats> get copyWith => _$KbStatsCopyWithImpl<KbStats>(this as KbStats, _$identity);

  /// Serializes this KbStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as KbStats;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KbStats&&(identical(other.items, _this.items) || other.items == _this.items)&&(identical(other.papers, _this.papers) || other.papers == _this.papers)&&const DeepCollectionEquality().equals(other.byKind, _this.byKind)&&(identical(other.embedder, _this.embedder) || other.embedder == _this.embedder)&&(identical(other.dim, _this.dim) || other.dim == _this.dim));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as KbStats;
  return Object.hash(runtimeType,_this.items,_this.papers,const DeepCollectionEquality().hash(_this.byKind),_this.embedder,_this.dim);
}

@override
String toString() {
  final _this = this as KbStats;
  return 'KbStats(items: ${_this.items}, papers: ${_this.papers}, byKind: ${_this.byKind}, embedder: ${_this.embedder}, dim: ${_this.dim})';
}


}

/// @nodoc
abstract mixin class $KbStatsCopyWith<$Res>  {
  factory $KbStatsCopyWith(KbStats value, $Res Function(KbStats) _then) = _$KbStatsCopyWithImpl;
@useResult
$Res call({
 int items, int papers, Map<String, int> byKind, String? embedder, int? dim
});




}
/// @nodoc
class _$KbStatsCopyWithImpl<$Res>
    implements $KbStatsCopyWith<$Res> {
  _$KbStatsCopyWithImpl(this._self, this._then);

  final KbStats _self;
  final $Res Function(KbStats) _then;

/// Create a copy of KbStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? papers = null,Object? byKind = null,Object? embedder = freezed,Object? dim = freezed,}) {
  return _then(KbStats(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as int,papers: null == papers ? _self.papers : papers // ignore: cast_nullable_to_non_nullable
as int,byKind: null == byKind ? _self.byKind : byKind // ignore: cast_nullable_to_non_nullable
as Map<String, int>,embedder: freezed == embedder ? _self.embedder : embedder // ignore: cast_nullable_to_non_nullable
as String?,dim: freezed == dim ? _self.dim : dim // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [KbStats].
extension KbStatsPatterns on KbStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KbStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KbStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KbStats value)  $default,){
final _that = this;
switch (_that) {
case _KbStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KbStats value)?  $default,){
final _that = this;
switch (_that) {
case _KbStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int items,  int papers,  Map<String, int> byKind,  String? embedder,  int? dim)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KbStats() when $default != null:
return $default(_that.items,_that.papers,_that.byKind,_that.embedder,_that.dim);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int items,  int papers,  Map<String, int> byKind,  String? embedder,  int? dim)  $default,) {final _that = this;
switch (_that) {
case _KbStats():
return $default(_that.items,_that.papers,_that.byKind,_that.embedder,_that.dim);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int items,  int papers,  Map<String, int> byKind,  String? embedder,  int? dim)?  $default,) {final _that = this;
switch (_that) {
case _KbStats() when $default != null:
return $default(_that.items,_that.papers,_that.byKind,_that.embedder,_that.dim);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KbStats implements KbStats {
  const _KbStats({this.items = 0, this.papers = 0,  Map<String, int> byKind = const <String, int>{}, this.embedder, this.dim}): _byKind = byKind;
  factory _KbStats.fromJson(Map<String, dynamic> json) => _$KbStatsFromJson(json);

@override@JsonKey() final  int items;
@override@JsonKey() final  int papers;
 final  Map<String, int> _byKind;
@override@JsonKey() Map<String, int> get byKind {
  if (_byKind is EqualUnmodifiableMapView) return _byKind;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_byKind);
}

@override final  String? embedder;
@override final  int? dim;

/// Create a copy of KbStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KbStatsCopyWith<_KbStats> get copyWith => __$KbStatsCopyWithImpl<_KbStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KbStatsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _KbStats&&(identical(other.items, items) || other.items == items)&&(identical(other.papers, papers) || other.papers == papers)&&const DeepCollectionEquality().equals(other.byKind, _byKind)&&(identical(other.embedder, embedder) || other.embedder == embedder)&&(identical(other.dim, dim) || other.dim == dim));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,items,papers,const DeepCollectionEquality().hash(_byKind),embedder,dim);
}

@override
String toString() {
    return 'KbStats(items: $items, papers: $papers, byKind: $byKind, embedder: $embedder, dim: $dim)';
}


}

/// @nodoc
abstract mixin class _$KbStatsCopyWith<$Res> implements $KbStatsCopyWith<$Res> {
  factory _$KbStatsCopyWith(_KbStats value, $Res Function(_KbStats) _then) = __$KbStatsCopyWithImpl;
@override @useResult
$Res call({
 int items, int papers, Map<String, int> byKind, String? embedder, int? dim
});




}
/// @nodoc
class __$KbStatsCopyWithImpl<$Res>
    implements _$KbStatsCopyWith<$Res> {
  __$KbStatsCopyWithImpl(this._self, this._then);

  final _KbStats _self;
  final $Res Function(_KbStats) _then;

/// Create a copy of KbStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? papers = null,Object? byKind = null,Object? embedder = freezed,Object? dim = freezed,}) {
  return _then(_KbStats(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as int,papers: null == papers ? _self.papers : papers // ignore: cast_nullable_to_non_nullable
as int,byKind: null == byKind ? _self._byKind : byKind // ignore: cast_nullable_to_non_nullable
as Map<String, int>,embedder: freezed == embedder ? _self.embedder : embedder // ignore: cast_nullable_to_non_nullable
as String?,dim: freezed == dim ? _self.dim : dim // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
