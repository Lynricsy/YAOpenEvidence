// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'answers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$JobError {

 String get code; String get message;
/// Create a copy of JobError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobErrorCopyWith<JobError> get copyWith => _$JobErrorCopyWithImpl<JobError>(this as JobError, _$identity);

  /// Serializes this JobError to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as JobError;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobError&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as JobError;
  return Object.hash(runtimeType,_this.code,_this.message);
}

@override
String toString() {
  final _this = this as JobError;
  return 'JobError(code: ${_this.code}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $JobErrorCopyWith<$Res>  {
  factory $JobErrorCopyWith(JobError value, $Res Function(JobError) _then) = _$JobErrorCopyWithImpl;
@useResult
$Res call({
 String code, String message
});




}
/// @nodoc
class _$JobErrorCopyWithImpl<$Res>
    implements $JobErrorCopyWith<$Res> {
  _$JobErrorCopyWithImpl(this._self, this._then);

  final JobError _self;
  final $Res Function(JobError) _then;

/// Create a copy of JobError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? message = null,}) {
  return _then(JobError(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [JobError].
extension JobErrorPatterns on JobError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JobError value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JobError() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JobError value)  $default,){
final _that = this;
switch (_that) {
case _JobError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JobError value)?  $default,){
final _that = this;
switch (_that) {
case _JobError() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JobError() when $default != null:
return $default(_that.code,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String message)  $default,) {final _that = this;
switch (_that) {
case _JobError():
return $default(_that.code,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String message)?  $default,) {final _that = this;
switch (_that) {
case _JobError() when $default != null:
return $default(_that.code,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JobError implements JobError {
  const _JobError({this.code = '', this.message = ''});
  factory _JobError.fromJson(Map<String, dynamic> json) => _$JobErrorFromJson(json);

@override@JsonKey() final  String code;
@override@JsonKey() final  String message;

/// Create a copy of JobError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JobErrorCopyWith<_JobError> get copyWith => __$JobErrorCopyWithImpl<_JobError>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JobErrorToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _JobError&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,message);
}

@override
String toString() {
    return 'JobError(code: $code, message: $message)';
}


}

/// @nodoc
abstract mixin class _$JobErrorCopyWith<$Res> implements $JobErrorCopyWith<$Res> {
  factory _$JobErrorCopyWith(_JobError value, $Res Function(_JobError) _then) = __$JobErrorCopyWithImpl;
@override @useResult
$Res call({
 String code, String message
});




}
/// @nodoc
class __$JobErrorCopyWithImpl<$Res>
    implements _$JobErrorCopyWith<$Res> {
  __$JobErrorCopyWithImpl(this._self, this._then);

  final _JobError _self;
  final $Res Function(_JobError) _then;

/// Create a copy of JobError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? message = null,}) {
  return _then(_JobError(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AnswerPaper {

 int get n; String get pmid; String get doi; String get pmcid; String get title; String get year; String get journal; String get issn; String get authors; String get quartile; String get rankLabel;@_sourceKey PaperSource get source; int? get relevance; int get nParagraphs; int get nCitations; int get nCitationsVerified;
/// Create a copy of AnswerPaper
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnswerPaperCopyWith<AnswerPaper> get copyWith => _$AnswerPaperCopyWithImpl<AnswerPaper>(this as AnswerPaper, _$identity);

  /// Serializes this AnswerPaper to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AnswerPaper;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnswerPaper&&(identical(other.n, _this.n) || other.n == _this.n)&&(identical(other.pmid, _this.pmid) || other.pmid == _this.pmid)&&(identical(other.doi, _this.doi) || other.doi == _this.doi)&&(identical(other.pmcid, _this.pmcid) || other.pmcid == _this.pmcid)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.year, _this.year) || other.year == _this.year)&&(identical(other.journal, _this.journal) || other.journal == _this.journal)&&(identical(other.issn, _this.issn) || other.issn == _this.issn)&&(identical(other.authors, _this.authors) || other.authors == _this.authors)&&(identical(other.quartile, _this.quartile) || other.quartile == _this.quartile)&&(identical(other.rankLabel, _this.rankLabel) || other.rankLabel == _this.rankLabel)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.relevance, _this.relevance) || other.relevance == _this.relevance)&&(identical(other.nParagraphs, _this.nParagraphs) || other.nParagraphs == _this.nParagraphs)&&(identical(other.nCitations, _this.nCitations) || other.nCitations == _this.nCitations)&&(identical(other.nCitationsVerified, _this.nCitationsVerified) || other.nCitationsVerified == _this.nCitationsVerified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AnswerPaper;
  return Object.hash(runtimeType,_this.n,_this.pmid,_this.doi,_this.pmcid,_this.title,_this.year,_this.journal,_this.issn,_this.authors,_this.quartile,_this.rankLabel,_this.source,_this.relevance,_this.nParagraphs,_this.nCitations,_this.nCitationsVerified);
}

@override
String toString() {
  final _this = this as AnswerPaper;
  return 'AnswerPaper(n: ${_this.n}, pmid: ${_this.pmid}, doi: ${_this.doi}, pmcid: ${_this.pmcid}, title: ${_this.title}, year: ${_this.year}, journal: ${_this.journal}, issn: ${_this.issn}, authors: ${_this.authors}, quartile: ${_this.quartile}, rankLabel: ${_this.rankLabel}, source: ${_this.source}, relevance: ${_this.relevance}, nParagraphs: ${_this.nParagraphs}, nCitations: ${_this.nCitations}, nCitationsVerified: ${_this.nCitationsVerified})';
}


}

/// @nodoc
abstract mixin class $AnswerPaperCopyWith<$Res>  {
  factory $AnswerPaperCopyWith(AnswerPaper value, $Res Function(AnswerPaper) _then) = _$AnswerPaperCopyWithImpl;
@useResult
$Res call({
 int n, String pmid, String doi, String pmcid, String title, String year, String journal, String issn, String authors, String quartile, String rankLabel,@_sourceKey PaperSource source, int? relevance, int nParagraphs, int nCitations, int nCitationsVerified
});




}
/// @nodoc
class _$AnswerPaperCopyWithImpl<$Res>
    implements $AnswerPaperCopyWith<$Res> {
  _$AnswerPaperCopyWithImpl(this._self, this._then);

  final AnswerPaper _self;
  final $Res Function(AnswerPaper) _then;

/// Create a copy of AnswerPaper
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? n = null,Object? pmid = null,Object? doi = null,Object? pmcid = null,Object? title = null,Object? year = null,Object? journal = null,Object? issn = null,Object? authors = null,Object? quartile = null,Object? rankLabel = null,Object? source = null,Object? relevance = freezed,Object? nParagraphs = null,Object? nCitations = null,Object? nCitationsVerified = null,}) {
  return _then(AnswerPaper(
n: null == n ? _self.n : n // ignore: cast_nullable_to_non_nullable
as int,pmid: null == pmid ? _self.pmid : pmid // ignore: cast_nullable_to_non_nullable
as String,doi: null == doi ? _self.doi : doi // ignore: cast_nullable_to_non_nullable
as String,pmcid: null == pmcid ? _self.pmcid : pmcid // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String,journal: null == journal ? _self.journal : journal // ignore: cast_nullable_to_non_nullable
as String,issn: null == issn ? _self.issn : issn // ignore: cast_nullable_to_non_nullable
as String,authors: null == authors ? _self.authors : authors // ignore: cast_nullable_to_non_nullable
as String,quartile: null == quartile ? _self.quartile : quartile // ignore: cast_nullable_to_non_nullable
as String,rankLabel: null == rankLabel ? _self.rankLabel : rankLabel // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as PaperSource,relevance: freezed == relevance ? _self.relevance : relevance // ignore: cast_nullable_to_non_nullable
as int?,nParagraphs: null == nParagraphs ? _self.nParagraphs : nParagraphs // ignore: cast_nullable_to_non_nullable
as int,nCitations: null == nCitations ? _self.nCitations : nCitations // ignore: cast_nullable_to_non_nullable
as int,nCitationsVerified: null == nCitationsVerified ? _self.nCitationsVerified : nCitationsVerified // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AnswerPaper].
extension AnswerPaperPatterns on AnswerPaper {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnswerPaper value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnswerPaper() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnswerPaper value)  $default,){
final _that = this;
switch (_that) {
case _AnswerPaper():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnswerPaper value)?  $default,){
final _that = this;
switch (_that) {
case _AnswerPaper() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int n,  String pmid,  String doi,  String pmcid,  String title,  String year,  String journal,  String issn,  String authors,  String quartile,  String rankLabel, @_sourceKey  PaperSource source,  int? relevance,  int nParagraphs,  int nCitations,  int nCitationsVerified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnswerPaper() when $default != null:
return $default(_that.n,_that.pmid,_that.doi,_that.pmcid,_that.title,_that.year,_that.journal,_that.issn,_that.authors,_that.quartile,_that.rankLabel,_that.source,_that.relevance,_that.nParagraphs,_that.nCitations,_that.nCitationsVerified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int n,  String pmid,  String doi,  String pmcid,  String title,  String year,  String journal,  String issn,  String authors,  String quartile,  String rankLabel, @_sourceKey  PaperSource source,  int? relevance,  int nParagraphs,  int nCitations,  int nCitationsVerified)  $default,) {final _that = this;
switch (_that) {
case _AnswerPaper():
return $default(_that.n,_that.pmid,_that.doi,_that.pmcid,_that.title,_that.year,_that.journal,_that.issn,_that.authors,_that.quartile,_that.rankLabel,_that.source,_that.relevance,_that.nParagraphs,_that.nCitations,_that.nCitationsVerified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int n,  String pmid,  String doi,  String pmcid,  String title,  String year,  String journal,  String issn,  String authors,  String quartile,  String rankLabel, @_sourceKey  PaperSource source,  int? relevance,  int nParagraphs,  int nCitations,  int nCitationsVerified)?  $default,) {final _that = this;
switch (_that) {
case _AnswerPaper() when $default != null:
return $default(_that.n,_that.pmid,_that.doi,_that.pmcid,_that.title,_that.year,_that.journal,_that.issn,_that.authors,_that.quartile,_that.rankLabel,_that.source,_that.relevance,_that.nParagraphs,_that.nCitations,_that.nCitationsVerified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnswerPaper implements AnswerPaper {
  const _AnswerPaper({required this.n, this.pmid = '', this.doi = '', this.pmcid = '', this.title = '', this.year = '', this.journal = '', this.issn = '', this.authors = '', this.quartile = '', this.rankLabel = '', @_sourceKey this.source = PaperSource.abstract, this.relevance, this.nParagraphs = 0, this.nCitations = 0, this.nCitationsVerified = 0});
  factory _AnswerPaper.fromJson(Map<String, dynamic> json) => _$AnswerPaperFromJson(json);

@override final  int n;
@override@JsonKey() final  String pmid;
@override@JsonKey() final  String doi;
@override@JsonKey() final  String pmcid;
@override@JsonKey() final  String title;
@override@JsonKey() final  String year;
@override@JsonKey() final  String journal;
@override@JsonKey() final  String issn;
@override@JsonKey() final  String authors;
@override@JsonKey() final  String quartile;
@override@JsonKey() final  String rankLabel;
@override@_sourceKey final  PaperSource source;
@override final  int? relevance;
@override@JsonKey() final  int nParagraphs;
@override@JsonKey() final  int nCitations;
@override@JsonKey() final  int nCitationsVerified;

/// Create a copy of AnswerPaper
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnswerPaperCopyWith<_AnswerPaper> get copyWith => __$AnswerPaperCopyWithImpl<_AnswerPaper>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnswerPaperToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnswerPaper&&(identical(other.n, n) || other.n == n)&&(identical(other.pmid, pmid) || other.pmid == pmid)&&(identical(other.doi, doi) || other.doi == doi)&&(identical(other.pmcid, pmcid) || other.pmcid == pmcid)&&(identical(other.title, title) || other.title == title)&&(identical(other.year, year) || other.year == year)&&(identical(other.journal, journal) || other.journal == journal)&&(identical(other.issn, issn) || other.issn == issn)&&(identical(other.authors, authors) || other.authors == authors)&&(identical(other.quartile, quartile) || other.quartile == quartile)&&(identical(other.rankLabel, rankLabel) || other.rankLabel == rankLabel)&&(identical(other.source, source) || other.source == source)&&(identical(other.relevance, relevance) || other.relevance == relevance)&&(identical(other.nParagraphs, nParagraphs) || other.nParagraphs == nParagraphs)&&(identical(other.nCitations, nCitations) || other.nCitations == nCitations)&&(identical(other.nCitationsVerified, nCitationsVerified) || other.nCitationsVerified == nCitationsVerified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,n,pmid,doi,pmcid,title,year,journal,issn,authors,quartile,rankLabel,source,relevance,nParagraphs,nCitations,nCitationsVerified);
}

@override
String toString() {
    return 'AnswerPaper(n: $n, pmid: $pmid, doi: $doi, pmcid: $pmcid, title: $title, year: $year, journal: $journal, issn: $issn, authors: $authors, quartile: $quartile, rankLabel: $rankLabel, source: $source, relevance: $relevance, nParagraphs: $nParagraphs, nCitations: $nCitations, nCitationsVerified: $nCitationsVerified)';
}


}

/// @nodoc
abstract mixin class _$AnswerPaperCopyWith<$Res> implements $AnswerPaperCopyWith<$Res> {
  factory _$AnswerPaperCopyWith(_AnswerPaper value, $Res Function(_AnswerPaper) _then) = __$AnswerPaperCopyWithImpl;
@override @useResult
$Res call({
 int n, String pmid, String doi, String pmcid, String title, String year, String journal, String issn, String authors, String quartile, String rankLabel,@_sourceKey PaperSource source, int? relevance, int nParagraphs, int nCitations, int nCitationsVerified
});




}
/// @nodoc
class __$AnswerPaperCopyWithImpl<$Res>
    implements _$AnswerPaperCopyWith<$Res> {
  __$AnswerPaperCopyWithImpl(this._self, this._then);

  final _AnswerPaper _self;
  final $Res Function(_AnswerPaper) _then;

/// Create a copy of AnswerPaper
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? n = null,Object? pmid = null,Object? doi = null,Object? pmcid = null,Object? title = null,Object? year = null,Object? journal = null,Object? issn = null,Object? authors = null,Object? quartile = null,Object? rankLabel = null,Object? source = null,Object? relevance = freezed,Object? nParagraphs = null,Object? nCitations = null,Object? nCitationsVerified = null,}) {
  return _then(_AnswerPaper(
n: null == n ? _self.n : n // ignore: cast_nullable_to_non_nullable
as int,pmid: null == pmid ? _self.pmid : pmid // ignore: cast_nullable_to_non_nullable
as String,doi: null == doi ? _self.doi : doi // ignore: cast_nullable_to_non_nullable
as String,pmcid: null == pmcid ? _self.pmcid : pmcid // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String,journal: null == journal ? _self.journal : journal // ignore: cast_nullable_to_non_nullable
as String,issn: null == issn ? _self.issn : issn // ignore: cast_nullable_to_non_nullable
as String,authors: null == authors ? _self.authors : authors // ignore: cast_nullable_to_non_nullable
as String,quartile: null == quartile ? _self.quartile : quartile // ignore: cast_nullable_to_non_nullable
as String,rankLabel: null == rankLabel ? _self.rankLabel : rankLabel // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as PaperSource,relevance: freezed == relevance ? _self.relevance : relevance // ignore: cast_nullable_to_non_nullable
as int?,nParagraphs: null == nParagraphs ? _self.nParagraphs : nParagraphs // ignore: cast_nullable_to_non_nullable
as int,nCitations: null == nCitations ? _self.nCitations : nCitations // ignore: cast_nullable_to_non_nullable
as int,nCitationsVerified: null == nCitationsVerified ? _self.nCitationsVerified : nCitationsVerified // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Citation {

 int get n; String get pmid; int get pid; String get sec; int? get page; String get text; List<String> get quotes; bool get fromMarker;
/// Create a copy of Citation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CitationCopyWith<Citation> get copyWith => _$CitationCopyWithImpl<Citation>(this as Citation, _$identity);

  /// Serializes this Citation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Citation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Citation&&(identical(other.n, _this.n) || other.n == _this.n)&&(identical(other.pmid, _this.pmid) || other.pmid == _this.pmid)&&(identical(other.pid, _this.pid) || other.pid == _this.pid)&&(identical(other.sec, _this.sec) || other.sec == _this.sec)&&(identical(other.page, _this.page) || other.page == _this.page)&&(identical(other.text, _this.text) || other.text == _this.text)&&const DeepCollectionEquality().equals(other.quotes, _this.quotes)&&(identical(other.fromMarker, _this.fromMarker) || other.fromMarker == _this.fromMarker));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Citation;
  return Object.hash(runtimeType,_this.n,_this.pmid,_this.pid,_this.sec,_this.page,_this.text,const DeepCollectionEquality().hash(_this.quotes),_this.fromMarker);
}

@override
String toString() {
  final _this = this as Citation;
  return 'Citation(n: ${_this.n}, pmid: ${_this.pmid}, pid: ${_this.pid}, sec: ${_this.sec}, page: ${_this.page}, text: ${_this.text}, quotes: ${_this.quotes}, fromMarker: ${_this.fromMarker})';
}


}

/// @nodoc
abstract mixin class $CitationCopyWith<$Res>  {
  factory $CitationCopyWith(Citation value, $Res Function(Citation) _then) = _$CitationCopyWithImpl;
@useResult
$Res call({
 int n, String pmid, int pid, String sec, int? page, String text, List<String> quotes, bool fromMarker
});




}
/// @nodoc
class _$CitationCopyWithImpl<$Res>
    implements $CitationCopyWith<$Res> {
  _$CitationCopyWithImpl(this._self, this._then);

  final Citation _self;
  final $Res Function(Citation) _then;

/// Create a copy of Citation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? n = null,Object? pmid = null,Object? pid = null,Object? sec = null,Object? page = freezed,Object? text = null,Object? quotes = null,Object? fromMarker = null,}) {
  return _then(Citation(
n: null == n ? _self.n : n // ignore: cast_nullable_to_non_nullable
as int,pmid: null == pmid ? _self.pmid : pmid // ignore: cast_nullable_to_non_nullable
as String,pid: null == pid ? _self.pid : pid // ignore: cast_nullable_to_non_nullable
as int,sec: null == sec ? _self.sec : sec // ignore: cast_nullable_to_non_nullable
as String,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,quotes: null == quotes ? _self.quotes : quotes // ignore: cast_nullable_to_non_nullable
as List<String>,fromMarker: null == fromMarker ? _self.fromMarker : fromMarker // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Citation].
extension CitationPatterns on Citation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Citation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Citation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Citation value)  $default,){
final _that = this;
switch (_that) {
case _Citation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Citation value)?  $default,){
final _that = this;
switch (_that) {
case _Citation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int n,  String pmid,  int pid,  String sec,  int? page,  String text,  List<String> quotes,  bool fromMarker)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Citation() when $default != null:
return $default(_that.n,_that.pmid,_that.pid,_that.sec,_that.page,_that.text,_that.quotes,_that.fromMarker);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int n,  String pmid,  int pid,  String sec,  int? page,  String text,  List<String> quotes,  bool fromMarker)  $default,) {final _that = this;
switch (_that) {
case _Citation():
return $default(_that.n,_that.pmid,_that.pid,_that.sec,_that.page,_that.text,_that.quotes,_that.fromMarker);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int n,  String pmid,  int pid,  String sec,  int? page,  String text,  List<String> quotes,  bool fromMarker)?  $default,) {final _that = this;
switch (_that) {
case _Citation() when $default != null:
return $default(_that.n,_that.pmid,_that.pid,_that.sec,_that.page,_that.text,_that.quotes,_that.fromMarker);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Citation implements Citation {
  const _Citation({required this.n, this.pmid = '', this.pid = 0, this.sec = '', this.page, this.text = '',  List<String> quotes = const <String>[], this.fromMarker = false}): _quotes = quotes;
  factory _Citation.fromJson(Map<String, dynamic> json) => _$CitationFromJson(json);

@override final  int n;
@override@JsonKey() final  String pmid;
@override@JsonKey() final  int pid;
@override@JsonKey() final  String sec;
@override final  int? page;
@override@JsonKey() final  String text;
 final  List<String> _quotes;
@override@JsonKey() List<String> get quotes {
  if (_quotes is EqualUnmodifiableListView) return _quotes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_quotes);
}

@override@JsonKey() final  bool fromMarker;

/// Create a copy of Citation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CitationCopyWith<_Citation> get copyWith => __$CitationCopyWithImpl<_Citation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CitationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Citation&&(identical(other.n, n) || other.n == n)&&(identical(other.pmid, pmid) || other.pmid == pmid)&&(identical(other.pid, pid) || other.pid == pid)&&(identical(other.sec, sec) || other.sec == sec)&&(identical(other.page, page) || other.page == page)&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.quotes, _quotes)&&(identical(other.fromMarker, fromMarker) || other.fromMarker == fromMarker));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,n,pmid,pid,sec,page,text,const DeepCollectionEquality().hash(_quotes),fromMarker);
}

@override
String toString() {
    return 'Citation(n: $n, pmid: $pmid, pid: $pid, sec: $sec, page: $page, text: $text, quotes: $quotes, fromMarker: $fromMarker)';
}


}

/// @nodoc
abstract mixin class _$CitationCopyWith<$Res> implements $CitationCopyWith<$Res> {
  factory _$CitationCopyWith(_Citation value, $Res Function(_Citation) _then) = __$CitationCopyWithImpl;
@override @useResult
$Res call({
 int n, String pmid, int pid, String sec, int? page, String text, List<String> quotes, bool fromMarker
});




}
/// @nodoc
class __$CitationCopyWithImpl<$Res>
    implements _$CitationCopyWith<$Res> {
  __$CitationCopyWithImpl(this._self, this._then);

  final _Citation _self;
  final $Res Function(_Citation) _then;

/// Create a copy of Citation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? n = null,Object? pmid = null,Object? pid = null,Object? sec = null,Object? page = freezed,Object? text = null,Object? quotes = null,Object? fromMarker = null,}) {
  return _then(_Citation(
n: null == n ? _self.n : n // ignore: cast_nullable_to_non_nullable
as int,pmid: null == pmid ? _self.pmid : pmid // ignore: cast_nullable_to_non_nullable
as String,pid: null == pid ? _self.pid : pid // ignore: cast_nullable_to_non_nullable
as int,sec: null == sec ? _self.sec : sec // ignore: cast_nullable_to_non_nullable
as String,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,quotes: null == quotes ? _self._quotes : quotes // ignore: cast_nullable_to_non_nullable
as List<String>,fromMarker: null == fromMarker ? _self.fromMarker : fromMarker // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AnswerSummary {

 String get id; String? get jobId; AnswerStatus get status; String get question; String? get filtersLabel; int? get nPapers; int? get nFulltext; DateTime get createdAt; DateTime? get finishedAt; JobError? get error;
/// Create a copy of AnswerSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnswerSummaryCopyWith<AnswerSummary> get copyWith => _$AnswerSummaryCopyWithImpl<AnswerSummary>(this as AnswerSummary, _$identity);

  /// Serializes this AnswerSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AnswerSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnswerSummary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.jobId, _this.jobId) || other.jobId == _this.jobId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.question, _this.question) || other.question == _this.question)&&(identical(other.filtersLabel, _this.filtersLabel) || other.filtersLabel == _this.filtersLabel)&&(identical(other.nPapers, _this.nPapers) || other.nPapers == _this.nPapers)&&(identical(other.nFulltext, _this.nFulltext) || other.nFulltext == _this.nFulltext)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.finishedAt, _this.finishedAt) || other.finishedAt == _this.finishedAt)&&(identical(other.error, _this.error) || other.error == _this.error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AnswerSummary;
  return Object.hash(runtimeType,_this.id,_this.jobId,_this.status,_this.question,_this.filtersLabel,_this.nPapers,_this.nFulltext,_this.createdAt,_this.finishedAt,_this.error);
}

@override
String toString() {
  final _this = this as AnswerSummary;
  return 'AnswerSummary(id: ${_this.id}, jobId: ${_this.jobId}, status: ${_this.status}, question: ${_this.question}, filtersLabel: ${_this.filtersLabel}, nPapers: ${_this.nPapers}, nFulltext: ${_this.nFulltext}, createdAt: ${_this.createdAt}, finishedAt: ${_this.finishedAt}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $AnswerSummaryCopyWith<$Res>  {
  factory $AnswerSummaryCopyWith(AnswerSummary value, $Res Function(AnswerSummary) _then) = _$AnswerSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String? jobId, AnswerStatus status, String question, String? filtersLabel, int? nPapers, int? nFulltext, DateTime createdAt, DateTime? finishedAt, JobError? error
});


$JobErrorCopyWith<$Res>? get error;

}
/// @nodoc
class _$AnswerSummaryCopyWithImpl<$Res>
    implements $AnswerSummaryCopyWith<$Res> {
  _$AnswerSummaryCopyWithImpl(this._self, this._then);

  final AnswerSummary _self;
  final $Res Function(AnswerSummary) _then;

/// Create a copy of AnswerSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? jobId = freezed,Object? status = null,Object? question = null,Object? filtersLabel = freezed,Object? nPapers = freezed,Object? nFulltext = freezed,Object? createdAt = null,Object? finishedAt = freezed,Object? error = freezed,}) {
  return _then(AnswerSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,jobId: freezed == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AnswerStatus,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,filtersLabel: freezed == filtersLabel ? _self.filtersLabel : filtersLabel // ignore: cast_nullable_to_non_nullable
as String?,nPapers: freezed == nPapers ? _self.nPapers : nPapers // ignore: cast_nullable_to_non_nullable
as int?,nFulltext: freezed == nFulltext ? _self.nFulltext : nFulltext // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as JobError?,
  ));
}
/// Create a copy of AnswerSummary
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


/// Adds pattern-matching-related methods to [AnswerSummary].
extension AnswerSummaryPatterns on AnswerSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnswerSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnswerSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnswerSummary value)  $default,){
final _that = this;
switch (_that) {
case _AnswerSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnswerSummary value)?  $default,){
final _that = this;
switch (_that) {
case _AnswerSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? jobId,  AnswerStatus status,  String question,  String? filtersLabel,  int? nPapers,  int? nFulltext,  DateTime createdAt,  DateTime? finishedAt,  JobError? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnswerSummary() when $default != null:
return $default(_that.id,_that.jobId,_that.status,_that.question,_that.filtersLabel,_that.nPapers,_that.nFulltext,_that.createdAt,_that.finishedAt,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? jobId,  AnswerStatus status,  String question,  String? filtersLabel,  int? nPapers,  int? nFulltext,  DateTime createdAt,  DateTime? finishedAt,  JobError? error)  $default,) {final _that = this;
switch (_that) {
case _AnswerSummary():
return $default(_that.id,_that.jobId,_that.status,_that.question,_that.filtersLabel,_that.nPapers,_that.nFulltext,_that.createdAt,_that.finishedAt,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? jobId,  AnswerStatus status,  String question,  String? filtersLabel,  int? nPapers,  int? nFulltext,  DateTime createdAt,  DateTime? finishedAt,  JobError? error)?  $default,) {final _that = this;
switch (_that) {
case _AnswerSummary() when $default != null:
return $default(_that.id,_that.jobId,_that.status,_that.question,_that.filtersLabel,_that.nPapers,_that.nFulltext,_that.createdAt,_that.finishedAt,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnswerSummary implements AnswerSummary {
  const _AnswerSummary({required this.id, this.jobId, required this.status, this.question = '', this.filtersLabel, this.nPapers, this.nFulltext, required this.createdAt, this.finishedAt, this.error});
  factory _AnswerSummary.fromJson(Map<String, dynamic> json) => _$AnswerSummaryFromJson(json);

@override final  String id;
@override final  String? jobId;
@override final  AnswerStatus status;
@override@JsonKey() final  String question;
@override final  String? filtersLabel;
@override final  int? nPapers;
@override final  int? nFulltext;
@override final  DateTime createdAt;
@override final  DateTime? finishedAt;
@override final  JobError? error;

/// Create a copy of AnswerSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnswerSummaryCopyWith<_AnswerSummary> get copyWith => __$AnswerSummaryCopyWithImpl<_AnswerSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnswerSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnswerSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.status, status) || other.status == status)&&(identical(other.question, question) || other.question == question)&&(identical(other.filtersLabel, filtersLabel) || other.filtersLabel == filtersLabel)&&(identical(other.nPapers, nPapers) || other.nPapers == nPapers)&&(identical(other.nFulltext, nFulltext) || other.nFulltext == nFulltext)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,jobId,status,question,filtersLabel,nPapers,nFulltext,createdAt,finishedAt,error);
}

@override
String toString() {
    return 'AnswerSummary(id: $id, jobId: $jobId, status: $status, question: $question, filtersLabel: $filtersLabel, nPapers: $nPapers, nFulltext: $nFulltext, createdAt: $createdAt, finishedAt: $finishedAt, error: $error)';
}


}

/// @nodoc
abstract mixin class _$AnswerSummaryCopyWith<$Res> implements $AnswerSummaryCopyWith<$Res> {
  factory _$AnswerSummaryCopyWith(_AnswerSummary value, $Res Function(_AnswerSummary) _then) = __$AnswerSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String? jobId, AnswerStatus status, String question, String? filtersLabel, int? nPapers, int? nFulltext, DateTime createdAt, DateTime? finishedAt, JobError? error
});


@override $JobErrorCopyWith<$Res>? get error;

}
/// @nodoc
class __$AnswerSummaryCopyWithImpl<$Res>
    implements _$AnswerSummaryCopyWith<$Res> {
  __$AnswerSummaryCopyWithImpl(this._self, this._then);

  final _AnswerSummary _self;
  final $Res Function(_AnswerSummary) _then;

/// Create a copy of AnswerSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? jobId = freezed,Object? status = null,Object? question = null,Object? filtersLabel = freezed,Object? nPapers = freezed,Object? nFulltext = freezed,Object? createdAt = null,Object? finishedAt = freezed,Object? error = freezed,}) {
  return _then(_AnswerSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,jobId: freezed == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AnswerStatus,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,filtersLabel: freezed == filtersLabel ? _self.filtersLabel : filtersLabel // ignore: cast_nullable_to_non_nullable
as String?,nPapers: freezed == nPapers ? _self.nPapers : nPapers // ignore: cast_nullable_to_non_nullable
as int?,nFulltext: freezed == nFulltext ? _self.nFulltext : nFulltext // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as JobError?,
  ));
}

/// Create a copy of AnswerSummary
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


/// @nodoc
mixin _$Answer {

 String get id; String? get jobId; AnswerStatus get status; String get question; String? get filtersLabel; int? get nPapers; int? get nFulltext; DateTime get createdAt; DateTime? get finishedAt; JobError? get error; String? get questionEn; List<String> get queries; Map<String, dynamic> get options; DateTime? get startedAt; List<AnswerPaper> get papers; String? get bodyMd; List<Citation> get citations; List<KbHit> get kbHits;
/// Create a copy of Answer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnswerCopyWith<Answer> get copyWith => _$AnswerCopyWithImpl<Answer>(this as Answer, _$identity);

  /// Serializes this Answer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Answer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Answer&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.jobId, _this.jobId) || other.jobId == _this.jobId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.question, _this.question) || other.question == _this.question)&&(identical(other.filtersLabel, _this.filtersLabel) || other.filtersLabel == _this.filtersLabel)&&(identical(other.nPapers, _this.nPapers) || other.nPapers == _this.nPapers)&&(identical(other.nFulltext, _this.nFulltext) || other.nFulltext == _this.nFulltext)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.finishedAt, _this.finishedAt) || other.finishedAt == _this.finishedAt)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.questionEn, _this.questionEn) || other.questionEn == _this.questionEn)&&const DeepCollectionEquality().equals(other.queries, _this.queries)&&const DeepCollectionEquality().equals(other.options, _this.options)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&const DeepCollectionEquality().equals(other.papers, _this.papers)&&(identical(other.bodyMd, _this.bodyMd) || other.bodyMd == _this.bodyMd)&&const DeepCollectionEquality().equals(other.citations, _this.citations)&&const DeepCollectionEquality().equals(other.kbHits, _this.kbHits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Answer;
  return Object.hash(runtimeType,_this.id,_this.jobId,_this.status,_this.question,_this.filtersLabel,_this.nPapers,_this.nFulltext,_this.createdAt,_this.finishedAt,_this.error,_this.questionEn,const DeepCollectionEquality().hash(_this.queries),const DeepCollectionEquality().hash(_this.options),_this.startedAt,const DeepCollectionEquality().hash(_this.papers),_this.bodyMd,const DeepCollectionEquality().hash(_this.citations),const DeepCollectionEquality().hash(_this.kbHits));
}

@override
String toString() {
  final _this = this as Answer;
  return 'Answer(id: ${_this.id}, jobId: ${_this.jobId}, status: ${_this.status}, question: ${_this.question}, filtersLabel: ${_this.filtersLabel}, nPapers: ${_this.nPapers}, nFulltext: ${_this.nFulltext}, createdAt: ${_this.createdAt}, finishedAt: ${_this.finishedAt}, error: ${_this.error}, questionEn: ${_this.questionEn}, queries: ${_this.queries}, options: ${_this.options}, startedAt: ${_this.startedAt}, papers: ${_this.papers}, bodyMd: ${_this.bodyMd}, citations: ${_this.citations}, kbHits: ${_this.kbHits})';
}


}

/// @nodoc
abstract mixin class $AnswerCopyWith<$Res>  {
  factory $AnswerCopyWith(Answer value, $Res Function(Answer) _then) = _$AnswerCopyWithImpl;
@useResult
$Res call({
 String id, String? jobId, AnswerStatus status, String question, String? filtersLabel, int? nPapers, int? nFulltext, DateTime createdAt, DateTime? finishedAt, JobError? error, String? questionEn, List<String> queries, Map<String, dynamic> options, DateTime? startedAt, List<AnswerPaper> papers, String? bodyMd, List<Citation> citations, List<KbHit> kbHits
});


$JobErrorCopyWith<$Res>? get error;

}
/// @nodoc
class _$AnswerCopyWithImpl<$Res>
    implements $AnswerCopyWith<$Res> {
  _$AnswerCopyWithImpl(this._self, this._then);

  final Answer _self;
  final $Res Function(Answer) _then;

/// Create a copy of Answer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? jobId = freezed,Object? status = null,Object? question = null,Object? filtersLabel = freezed,Object? nPapers = freezed,Object? nFulltext = freezed,Object? createdAt = null,Object? finishedAt = freezed,Object? error = freezed,Object? questionEn = freezed,Object? queries = null,Object? options = null,Object? startedAt = freezed,Object? papers = null,Object? bodyMd = freezed,Object? citations = null,Object? kbHits = null,}) {
  return _then(Answer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,jobId: freezed == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AnswerStatus,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,filtersLabel: freezed == filtersLabel ? _self.filtersLabel : filtersLabel // ignore: cast_nullable_to_non_nullable
as String?,nPapers: freezed == nPapers ? _self.nPapers : nPapers // ignore: cast_nullable_to_non_nullable
as int?,nFulltext: freezed == nFulltext ? _self.nFulltext : nFulltext // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as JobError?,questionEn: freezed == questionEn ? _self.questionEn : questionEn // ignore: cast_nullable_to_non_nullable
as String?,queries: null == queries ? _self.queries : queries // ignore: cast_nullable_to_non_nullable
as List<String>,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,papers: null == papers ? _self.papers : papers // ignore: cast_nullable_to_non_nullable
as List<AnswerPaper>,bodyMd: freezed == bodyMd ? _self.bodyMd : bodyMd // ignore: cast_nullable_to_non_nullable
as String?,citations: null == citations ? _self.citations : citations // ignore: cast_nullable_to_non_nullable
as List<Citation>,kbHits: null == kbHits ? _self.kbHits : kbHits // ignore: cast_nullable_to_non_nullable
as List<KbHit>,
  ));
}
/// Create a copy of Answer
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


/// Adds pattern-matching-related methods to [Answer].
extension AnswerPatterns on Answer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Answer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Answer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Answer value)  $default,){
final _that = this;
switch (_that) {
case _Answer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Answer value)?  $default,){
final _that = this;
switch (_that) {
case _Answer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? jobId,  AnswerStatus status,  String question,  String? filtersLabel,  int? nPapers,  int? nFulltext,  DateTime createdAt,  DateTime? finishedAt,  JobError? error,  String? questionEn,  List<String> queries,  Map<String, dynamic> options,  DateTime? startedAt,  List<AnswerPaper> papers,  String? bodyMd,  List<Citation> citations,  List<KbHit> kbHits)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Answer() when $default != null:
return $default(_that.id,_that.jobId,_that.status,_that.question,_that.filtersLabel,_that.nPapers,_that.nFulltext,_that.createdAt,_that.finishedAt,_that.error,_that.questionEn,_that.queries,_that.options,_that.startedAt,_that.papers,_that.bodyMd,_that.citations,_that.kbHits);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? jobId,  AnswerStatus status,  String question,  String? filtersLabel,  int? nPapers,  int? nFulltext,  DateTime createdAt,  DateTime? finishedAt,  JobError? error,  String? questionEn,  List<String> queries,  Map<String, dynamic> options,  DateTime? startedAt,  List<AnswerPaper> papers,  String? bodyMd,  List<Citation> citations,  List<KbHit> kbHits)  $default,) {final _that = this;
switch (_that) {
case _Answer():
return $default(_that.id,_that.jobId,_that.status,_that.question,_that.filtersLabel,_that.nPapers,_that.nFulltext,_that.createdAt,_that.finishedAt,_that.error,_that.questionEn,_that.queries,_that.options,_that.startedAt,_that.papers,_that.bodyMd,_that.citations,_that.kbHits);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? jobId,  AnswerStatus status,  String question,  String? filtersLabel,  int? nPapers,  int? nFulltext,  DateTime createdAt,  DateTime? finishedAt,  JobError? error,  String? questionEn,  List<String> queries,  Map<String, dynamic> options,  DateTime? startedAt,  List<AnswerPaper> papers,  String? bodyMd,  List<Citation> citations,  List<KbHit> kbHits)?  $default,) {final _that = this;
switch (_that) {
case _Answer() when $default != null:
return $default(_that.id,_that.jobId,_that.status,_that.question,_that.filtersLabel,_that.nPapers,_that.nFulltext,_that.createdAt,_that.finishedAt,_that.error,_that.questionEn,_that.queries,_that.options,_that.startedAt,_that.papers,_that.bodyMd,_that.citations,_that.kbHits);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Answer implements Answer {
  const _Answer({required this.id, this.jobId, required this.status, this.question = '', this.filtersLabel, this.nPapers, this.nFulltext, required this.createdAt, this.finishedAt, this.error, this.questionEn,  List<String> queries = const <String>[],  Map<String, dynamic> options = const <String, dynamic>{}, this.startedAt,  List<AnswerPaper> papers = const <AnswerPaper>[], this.bodyMd,  List<Citation> citations = const <Citation>[],  List<KbHit> kbHits = const <KbHit>[]}): _queries = queries,_options = options,_papers = papers,_citations = citations,_kbHits = kbHits;
  factory _Answer.fromJson(Map<String, dynamic> json) => _$AnswerFromJson(json);

@override final  String id;
@override final  String? jobId;
@override final  AnswerStatus status;
@override@JsonKey() final  String question;
@override final  String? filtersLabel;
@override final  int? nPapers;
@override final  int? nFulltext;
@override final  DateTime createdAt;
@override final  DateTime? finishedAt;
@override final  JobError? error;
@override final  String? questionEn;
 final  List<String> _queries;
@override@JsonKey() List<String> get queries {
  if (_queries is EqualUnmodifiableListView) return _queries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_queries);
}

 final  Map<String, dynamic> _options;
@override@JsonKey() Map<String, dynamic> get options {
  if (_options is EqualUnmodifiableMapView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_options);
}

@override final  DateTime? startedAt;
 final  List<AnswerPaper> _papers;
@override@JsonKey() List<AnswerPaper> get papers {
  if (_papers is EqualUnmodifiableListView) return _papers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_papers);
}

@override final  String? bodyMd;
 final  List<Citation> _citations;
@override@JsonKey() List<Citation> get citations {
  if (_citations is EqualUnmodifiableListView) return _citations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_citations);
}

 final  List<KbHit> _kbHits;
@override@JsonKey() List<KbHit> get kbHits {
  if (_kbHits is EqualUnmodifiableListView) return _kbHits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_kbHits);
}


/// Create a copy of Answer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnswerCopyWith<_Answer> get copyWith => __$AnswerCopyWithImpl<_Answer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnswerToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Answer&&(identical(other.id, id) || other.id == id)&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.status, status) || other.status == status)&&(identical(other.question, question) || other.question == question)&&(identical(other.filtersLabel, filtersLabel) || other.filtersLabel == filtersLabel)&&(identical(other.nPapers, nPapers) || other.nPapers == nPapers)&&(identical(other.nFulltext, nFulltext) || other.nFulltext == nFulltext)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt)&&(identical(other.error, error) || other.error == error)&&(identical(other.questionEn, questionEn) || other.questionEn == questionEn)&&const DeepCollectionEquality().equals(other.queries, _queries)&&const DeepCollectionEquality().equals(other.options, _options)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&const DeepCollectionEquality().equals(other.papers, _papers)&&(identical(other.bodyMd, bodyMd) || other.bodyMd == bodyMd)&&const DeepCollectionEquality().equals(other.citations, _citations)&&const DeepCollectionEquality().equals(other.kbHits, _kbHits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,jobId,status,question,filtersLabel,nPapers,nFulltext,createdAt,finishedAt,error,questionEn,const DeepCollectionEquality().hash(_queries),const DeepCollectionEquality().hash(_options),startedAt,const DeepCollectionEquality().hash(_papers),bodyMd,const DeepCollectionEquality().hash(_citations),const DeepCollectionEquality().hash(_kbHits));
}

@override
String toString() {
    return 'Answer(id: $id, jobId: $jobId, status: $status, question: $question, filtersLabel: $filtersLabel, nPapers: $nPapers, nFulltext: $nFulltext, createdAt: $createdAt, finishedAt: $finishedAt, error: $error, questionEn: $questionEn, queries: $queries, options: $options, startedAt: $startedAt, papers: $papers, bodyMd: $bodyMd, citations: $citations, kbHits: $kbHits)';
}


}

/// @nodoc
abstract mixin class _$AnswerCopyWith<$Res> implements $AnswerCopyWith<$Res> {
  factory _$AnswerCopyWith(_Answer value, $Res Function(_Answer) _then) = __$AnswerCopyWithImpl;
@override @useResult
$Res call({
 String id, String? jobId, AnswerStatus status, String question, String? filtersLabel, int? nPapers, int? nFulltext, DateTime createdAt, DateTime? finishedAt, JobError? error, String? questionEn, List<String> queries, Map<String, dynamic> options, DateTime? startedAt, List<AnswerPaper> papers, String? bodyMd, List<Citation> citations, List<KbHit> kbHits
});


@override $JobErrorCopyWith<$Res>? get error;

}
/// @nodoc
class __$AnswerCopyWithImpl<$Res>
    implements _$AnswerCopyWith<$Res> {
  __$AnswerCopyWithImpl(this._self, this._then);

  final _Answer _self;
  final $Res Function(_Answer) _then;

/// Create a copy of Answer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? jobId = freezed,Object? status = null,Object? question = null,Object? filtersLabel = freezed,Object? nPapers = freezed,Object? nFulltext = freezed,Object? createdAt = null,Object? finishedAt = freezed,Object? error = freezed,Object? questionEn = freezed,Object? queries = null,Object? options = null,Object? startedAt = freezed,Object? papers = null,Object? bodyMd = freezed,Object? citations = null,Object? kbHits = null,}) {
  return _then(_Answer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,jobId: freezed == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AnswerStatus,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,filtersLabel: freezed == filtersLabel ? _self.filtersLabel : filtersLabel // ignore: cast_nullable_to_non_nullable
as String?,nPapers: freezed == nPapers ? _self.nPapers : nPapers // ignore: cast_nullable_to_non_nullable
as int?,nFulltext: freezed == nFulltext ? _self.nFulltext : nFulltext // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as JobError?,questionEn: freezed == questionEn ? _self.questionEn : questionEn // ignore: cast_nullable_to_non_nullable
as String?,queries: null == queries ? _self._queries : queries // ignore: cast_nullable_to_non_nullable
as List<String>,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,papers: null == papers ? _self._papers : papers // ignore: cast_nullable_to_non_nullable
as List<AnswerPaper>,bodyMd: freezed == bodyMd ? _self.bodyMd : bodyMd // ignore: cast_nullable_to_non_nullable
as String?,citations: null == citations ? _self._citations : citations // ignore: cast_nullable_to_non_nullable
as List<Citation>,kbHits: null == kbHits ? _self._kbHits : kbHits // ignore: cast_nullable_to_non_nullable
as List<KbHit>,
  ));
}

/// Create a copy of Answer
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


/// @nodoc
mixin _$AnswerPaperDetail {

 int get n; String get pmid; String get doi; String get pmcid; String get title; String get year; String get journal; String get issn; String get authors; String get quartile; String get rankLabel;@_sourceKey PaperSource get source; int? get relevance; int get nParagraphs; int get nCitations; int get nCitationsVerified; String get notesMd; List<VerifiedQuote> get citations; List<Fact> get facts; List<Paragraph> get paragraphs; String get fulltextMd;
/// Create a copy of AnswerPaperDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnswerPaperDetailCopyWith<AnswerPaperDetail> get copyWith => _$AnswerPaperDetailCopyWithImpl<AnswerPaperDetail>(this as AnswerPaperDetail, _$identity);

  /// Serializes this AnswerPaperDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AnswerPaperDetail;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnswerPaperDetail&&(identical(other.n, _this.n) || other.n == _this.n)&&(identical(other.pmid, _this.pmid) || other.pmid == _this.pmid)&&(identical(other.doi, _this.doi) || other.doi == _this.doi)&&(identical(other.pmcid, _this.pmcid) || other.pmcid == _this.pmcid)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.year, _this.year) || other.year == _this.year)&&(identical(other.journal, _this.journal) || other.journal == _this.journal)&&(identical(other.issn, _this.issn) || other.issn == _this.issn)&&(identical(other.authors, _this.authors) || other.authors == _this.authors)&&(identical(other.quartile, _this.quartile) || other.quartile == _this.quartile)&&(identical(other.rankLabel, _this.rankLabel) || other.rankLabel == _this.rankLabel)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.relevance, _this.relevance) || other.relevance == _this.relevance)&&(identical(other.nParagraphs, _this.nParagraphs) || other.nParagraphs == _this.nParagraphs)&&(identical(other.nCitations, _this.nCitations) || other.nCitations == _this.nCitations)&&(identical(other.nCitationsVerified, _this.nCitationsVerified) || other.nCitationsVerified == _this.nCitationsVerified)&&(identical(other.notesMd, _this.notesMd) || other.notesMd == _this.notesMd)&&const DeepCollectionEquality().equals(other.citations, _this.citations)&&const DeepCollectionEquality().equals(other.facts, _this.facts)&&const DeepCollectionEquality().equals(other.paragraphs, _this.paragraphs)&&(identical(other.fulltextMd, _this.fulltextMd) || other.fulltextMd == _this.fulltextMd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AnswerPaperDetail;
  return Object.hashAll([runtimeType,_this.n,_this.pmid,_this.doi,_this.pmcid,_this.title,_this.year,_this.journal,_this.issn,_this.authors,_this.quartile,_this.rankLabel,_this.source,_this.relevance,_this.nParagraphs,_this.nCitations,_this.nCitationsVerified,_this.notesMd,const DeepCollectionEquality().hash(_this.citations),const DeepCollectionEquality().hash(_this.facts),const DeepCollectionEquality().hash(_this.paragraphs),_this.fulltextMd]);
}

@override
String toString() {
  final _this = this as AnswerPaperDetail;
  return 'AnswerPaperDetail(n: ${_this.n}, pmid: ${_this.pmid}, doi: ${_this.doi}, pmcid: ${_this.pmcid}, title: ${_this.title}, year: ${_this.year}, journal: ${_this.journal}, issn: ${_this.issn}, authors: ${_this.authors}, quartile: ${_this.quartile}, rankLabel: ${_this.rankLabel}, source: ${_this.source}, relevance: ${_this.relevance}, nParagraphs: ${_this.nParagraphs}, nCitations: ${_this.nCitations}, nCitationsVerified: ${_this.nCitationsVerified}, notesMd: ${_this.notesMd}, citations: ${_this.citations}, facts: ${_this.facts}, paragraphs: ${_this.paragraphs}, fulltextMd: ${_this.fulltextMd})';
}


}

/// @nodoc
abstract mixin class $AnswerPaperDetailCopyWith<$Res>  {
  factory $AnswerPaperDetailCopyWith(AnswerPaperDetail value, $Res Function(AnswerPaperDetail) _then) = _$AnswerPaperDetailCopyWithImpl;
@useResult
$Res call({
 int n, String pmid, String doi, String pmcid, String title, String year, String journal, String issn, String authors, String quartile, String rankLabel,@_sourceKey PaperSource source, int? relevance, int nParagraphs, int nCitations, int nCitationsVerified, String notesMd, List<VerifiedQuote> citations, List<Fact> facts, List<Paragraph> paragraphs, String fulltextMd
});




}
/// @nodoc
class _$AnswerPaperDetailCopyWithImpl<$Res>
    implements $AnswerPaperDetailCopyWith<$Res> {
  _$AnswerPaperDetailCopyWithImpl(this._self, this._then);

  final AnswerPaperDetail _self;
  final $Res Function(AnswerPaperDetail) _then;

/// Create a copy of AnswerPaperDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? n = null,Object? pmid = null,Object? doi = null,Object? pmcid = null,Object? title = null,Object? year = null,Object? journal = null,Object? issn = null,Object? authors = null,Object? quartile = null,Object? rankLabel = null,Object? source = null,Object? relevance = freezed,Object? nParagraphs = null,Object? nCitations = null,Object? nCitationsVerified = null,Object? notesMd = null,Object? citations = null,Object? facts = null,Object? paragraphs = null,Object? fulltextMd = null,}) {
  return _then(AnswerPaperDetail(
n: null == n ? _self.n : n // ignore: cast_nullable_to_non_nullable
as int,pmid: null == pmid ? _self.pmid : pmid // ignore: cast_nullable_to_non_nullable
as String,doi: null == doi ? _self.doi : doi // ignore: cast_nullable_to_non_nullable
as String,pmcid: null == pmcid ? _self.pmcid : pmcid // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String,journal: null == journal ? _self.journal : journal // ignore: cast_nullable_to_non_nullable
as String,issn: null == issn ? _self.issn : issn // ignore: cast_nullable_to_non_nullable
as String,authors: null == authors ? _self.authors : authors // ignore: cast_nullable_to_non_nullable
as String,quartile: null == quartile ? _self.quartile : quartile // ignore: cast_nullable_to_non_nullable
as String,rankLabel: null == rankLabel ? _self.rankLabel : rankLabel // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as PaperSource,relevance: freezed == relevance ? _self.relevance : relevance // ignore: cast_nullable_to_non_nullable
as int?,nParagraphs: null == nParagraphs ? _self.nParagraphs : nParagraphs // ignore: cast_nullable_to_non_nullable
as int,nCitations: null == nCitations ? _self.nCitations : nCitations // ignore: cast_nullable_to_non_nullable
as int,nCitationsVerified: null == nCitationsVerified ? _self.nCitationsVerified : nCitationsVerified // ignore: cast_nullable_to_non_nullable
as int,notesMd: null == notesMd ? _self.notesMd : notesMd // ignore: cast_nullable_to_non_nullable
as String,citations: null == citations ? _self.citations : citations // ignore: cast_nullable_to_non_nullable
as List<VerifiedQuote>,facts: null == facts ? _self.facts : facts // ignore: cast_nullable_to_non_nullable
as List<Fact>,paragraphs: null == paragraphs ? _self.paragraphs : paragraphs // ignore: cast_nullable_to_non_nullable
as List<Paragraph>,fulltextMd: null == fulltextMd ? _self.fulltextMd : fulltextMd // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AnswerPaperDetail].
extension AnswerPaperDetailPatterns on AnswerPaperDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnswerPaperDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnswerPaperDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnswerPaperDetail value)  $default,){
final _that = this;
switch (_that) {
case _AnswerPaperDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnswerPaperDetail value)?  $default,){
final _that = this;
switch (_that) {
case _AnswerPaperDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int n,  String pmid,  String doi,  String pmcid,  String title,  String year,  String journal,  String issn,  String authors,  String quartile,  String rankLabel, @_sourceKey  PaperSource source,  int? relevance,  int nParagraphs,  int nCitations,  int nCitationsVerified,  String notesMd,  List<VerifiedQuote> citations,  List<Fact> facts,  List<Paragraph> paragraphs,  String fulltextMd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnswerPaperDetail() when $default != null:
return $default(_that.n,_that.pmid,_that.doi,_that.pmcid,_that.title,_that.year,_that.journal,_that.issn,_that.authors,_that.quartile,_that.rankLabel,_that.source,_that.relevance,_that.nParagraphs,_that.nCitations,_that.nCitationsVerified,_that.notesMd,_that.citations,_that.facts,_that.paragraphs,_that.fulltextMd);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int n,  String pmid,  String doi,  String pmcid,  String title,  String year,  String journal,  String issn,  String authors,  String quartile,  String rankLabel, @_sourceKey  PaperSource source,  int? relevance,  int nParagraphs,  int nCitations,  int nCitationsVerified,  String notesMd,  List<VerifiedQuote> citations,  List<Fact> facts,  List<Paragraph> paragraphs,  String fulltextMd)  $default,) {final _that = this;
switch (_that) {
case _AnswerPaperDetail():
return $default(_that.n,_that.pmid,_that.doi,_that.pmcid,_that.title,_that.year,_that.journal,_that.issn,_that.authors,_that.quartile,_that.rankLabel,_that.source,_that.relevance,_that.nParagraphs,_that.nCitations,_that.nCitationsVerified,_that.notesMd,_that.citations,_that.facts,_that.paragraphs,_that.fulltextMd);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int n,  String pmid,  String doi,  String pmcid,  String title,  String year,  String journal,  String issn,  String authors,  String quartile,  String rankLabel, @_sourceKey  PaperSource source,  int? relevance,  int nParagraphs,  int nCitations,  int nCitationsVerified,  String notesMd,  List<VerifiedQuote> citations,  List<Fact> facts,  List<Paragraph> paragraphs,  String fulltextMd)?  $default,) {final _that = this;
switch (_that) {
case _AnswerPaperDetail() when $default != null:
return $default(_that.n,_that.pmid,_that.doi,_that.pmcid,_that.title,_that.year,_that.journal,_that.issn,_that.authors,_that.quartile,_that.rankLabel,_that.source,_that.relevance,_that.nParagraphs,_that.nCitations,_that.nCitationsVerified,_that.notesMd,_that.citations,_that.facts,_that.paragraphs,_that.fulltextMd);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnswerPaperDetail implements AnswerPaperDetail {
  const _AnswerPaperDetail({required this.n, this.pmid = '', this.doi = '', this.pmcid = '', this.title = '', this.year = '', this.journal = '', this.issn = '', this.authors = '', this.quartile = '', this.rankLabel = '', @_sourceKey this.source = PaperSource.abstract, this.relevance, this.nParagraphs = 0, this.nCitations = 0, this.nCitationsVerified = 0, this.notesMd = '',  List<VerifiedQuote> citations = const <VerifiedQuote>[],  List<Fact> facts = const <Fact>[],  List<Paragraph> paragraphs = const <Paragraph>[], this.fulltextMd = ''}): _citations = citations,_facts = facts,_paragraphs = paragraphs;
  factory _AnswerPaperDetail.fromJson(Map<String, dynamic> json) => _$AnswerPaperDetailFromJson(json);

@override final  int n;
@override@JsonKey() final  String pmid;
@override@JsonKey() final  String doi;
@override@JsonKey() final  String pmcid;
@override@JsonKey() final  String title;
@override@JsonKey() final  String year;
@override@JsonKey() final  String journal;
@override@JsonKey() final  String issn;
@override@JsonKey() final  String authors;
@override@JsonKey() final  String quartile;
@override@JsonKey() final  String rankLabel;
@override@_sourceKey final  PaperSource source;
@override final  int? relevance;
@override@JsonKey() final  int nParagraphs;
@override@JsonKey() final  int nCitations;
@override@JsonKey() final  int nCitationsVerified;
@override@JsonKey() final  String notesMd;
 final  List<VerifiedQuote> _citations;
@override@JsonKey() List<VerifiedQuote> get citations {
  if (_citations is EqualUnmodifiableListView) return _citations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_citations);
}

 final  List<Fact> _facts;
@override@JsonKey() List<Fact> get facts {
  if (_facts is EqualUnmodifiableListView) return _facts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_facts);
}

 final  List<Paragraph> _paragraphs;
@override@JsonKey() List<Paragraph> get paragraphs {
  if (_paragraphs is EqualUnmodifiableListView) return _paragraphs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_paragraphs);
}

@override@JsonKey() final  String fulltextMd;

/// Create a copy of AnswerPaperDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnswerPaperDetailCopyWith<_AnswerPaperDetail> get copyWith => __$AnswerPaperDetailCopyWithImpl<_AnswerPaperDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnswerPaperDetailToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnswerPaperDetail&&(identical(other.n, n) || other.n == n)&&(identical(other.pmid, pmid) || other.pmid == pmid)&&(identical(other.doi, doi) || other.doi == doi)&&(identical(other.pmcid, pmcid) || other.pmcid == pmcid)&&(identical(other.title, title) || other.title == title)&&(identical(other.year, year) || other.year == year)&&(identical(other.journal, journal) || other.journal == journal)&&(identical(other.issn, issn) || other.issn == issn)&&(identical(other.authors, authors) || other.authors == authors)&&(identical(other.quartile, quartile) || other.quartile == quartile)&&(identical(other.rankLabel, rankLabel) || other.rankLabel == rankLabel)&&(identical(other.source, source) || other.source == source)&&(identical(other.relevance, relevance) || other.relevance == relevance)&&(identical(other.nParagraphs, nParagraphs) || other.nParagraphs == nParagraphs)&&(identical(other.nCitations, nCitations) || other.nCitations == nCitations)&&(identical(other.nCitationsVerified, nCitationsVerified) || other.nCitationsVerified == nCitationsVerified)&&(identical(other.notesMd, notesMd) || other.notesMd == notesMd)&&const DeepCollectionEquality().equals(other.citations, _citations)&&const DeepCollectionEquality().equals(other.facts, _facts)&&const DeepCollectionEquality().equals(other.paragraphs, _paragraphs)&&(identical(other.fulltextMd, fulltextMd) || other.fulltextMd == fulltextMd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,n,pmid,doi,pmcid,title,year,journal,issn,authors,quartile,rankLabel,source,relevance,nParagraphs,nCitations,nCitationsVerified,notesMd,const DeepCollectionEquality().hash(_citations),const DeepCollectionEquality().hash(_facts),const DeepCollectionEquality().hash(_paragraphs),fulltextMd]);
}

@override
String toString() {
    return 'AnswerPaperDetail(n: $n, pmid: $pmid, doi: $doi, pmcid: $pmcid, title: $title, year: $year, journal: $journal, issn: $issn, authors: $authors, quartile: $quartile, rankLabel: $rankLabel, source: $source, relevance: $relevance, nParagraphs: $nParagraphs, nCitations: $nCitations, nCitationsVerified: $nCitationsVerified, notesMd: $notesMd, citations: $citations, facts: $facts, paragraphs: $paragraphs, fulltextMd: $fulltextMd)';
}


}

/// @nodoc
abstract mixin class _$AnswerPaperDetailCopyWith<$Res> implements $AnswerPaperDetailCopyWith<$Res> {
  factory _$AnswerPaperDetailCopyWith(_AnswerPaperDetail value, $Res Function(_AnswerPaperDetail) _then) = __$AnswerPaperDetailCopyWithImpl;
@override @useResult
$Res call({
 int n, String pmid, String doi, String pmcid, String title, String year, String journal, String issn, String authors, String quartile, String rankLabel,@_sourceKey PaperSource source, int? relevance, int nParagraphs, int nCitations, int nCitationsVerified, String notesMd, List<VerifiedQuote> citations, List<Fact> facts, List<Paragraph> paragraphs, String fulltextMd
});




}
/// @nodoc
class __$AnswerPaperDetailCopyWithImpl<$Res>
    implements _$AnswerPaperDetailCopyWith<$Res> {
  __$AnswerPaperDetailCopyWithImpl(this._self, this._then);

  final _AnswerPaperDetail _self;
  final $Res Function(_AnswerPaperDetail) _then;

/// Create a copy of AnswerPaperDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? n = null,Object? pmid = null,Object? doi = null,Object? pmcid = null,Object? title = null,Object? year = null,Object? journal = null,Object? issn = null,Object? authors = null,Object? quartile = null,Object? rankLabel = null,Object? source = null,Object? relevance = freezed,Object? nParagraphs = null,Object? nCitations = null,Object? nCitationsVerified = null,Object? notesMd = null,Object? citations = null,Object? facts = null,Object? paragraphs = null,Object? fulltextMd = null,}) {
  return _then(_AnswerPaperDetail(
n: null == n ? _self.n : n // ignore: cast_nullable_to_non_nullable
as int,pmid: null == pmid ? _self.pmid : pmid // ignore: cast_nullable_to_non_nullable
as String,doi: null == doi ? _self.doi : doi // ignore: cast_nullable_to_non_nullable
as String,pmcid: null == pmcid ? _self.pmcid : pmcid // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String,journal: null == journal ? _self.journal : journal // ignore: cast_nullable_to_non_nullable
as String,issn: null == issn ? _self.issn : issn // ignore: cast_nullable_to_non_nullable
as String,authors: null == authors ? _self.authors : authors // ignore: cast_nullable_to_non_nullable
as String,quartile: null == quartile ? _self.quartile : quartile // ignore: cast_nullable_to_non_nullable
as String,rankLabel: null == rankLabel ? _self.rankLabel : rankLabel // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as PaperSource,relevance: freezed == relevance ? _self.relevance : relevance // ignore: cast_nullable_to_non_nullable
as int?,nParagraphs: null == nParagraphs ? _self.nParagraphs : nParagraphs // ignore: cast_nullable_to_non_nullable
as int,nCitations: null == nCitations ? _self.nCitations : nCitations // ignore: cast_nullable_to_non_nullable
as int,nCitationsVerified: null == nCitationsVerified ? _self.nCitationsVerified : nCitationsVerified // ignore: cast_nullable_to_non_nullable
as int,notesMd: null == notesMd ? _self.notesMd : notesMd // ignore: cast_nullable_to_non_nullable
as String,citations: null == citations ? _self._citations : citations // ignore: cast_nullable_to_non_nullable
as List<VerifiedQuote>,facts: null == facts ? _self._facts : facts // ignore: cast_nullable_to_non_nullable
as List<Fact>,paragraphs: null == paragraphs ? _self._paragraphs : paragraphs // ignore: cast_nullable_to_non_nullable
as List<Paragraph>,fulltextMd: null == fulltextMd ? _self.fulltextMd : fulltextMd // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AnswerCreate {

 String get question; int get papers; int? get years; int? get yearFrom; int? get yearTo; List<int> get quartiles; List<String> get journals; bool? get keepUnranked; bool get useKb; int get kbHits; int get maxChars;
/// Create a copy of AnswerCreate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnswerCreateCopyWith<AnswerCreate> get copyWith => _$AnswerCreateCopyWithImpl<AnswerCreate>(this as AnswerCreate, _$identity);

  /// Serializes this AnswerCreate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AnswerCreate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnswerCreate&&(identical(other.question, _this.question) || other.question == _this.question)&&(identical(other.papers, _this.papers) || other.papers == _this.papers)&&(identical(other.years, _this.years) || other.years == _this.years)&&(identical(other.yearFrom, _this.yearFrom) || other.yearFrom == _this.yearFrom)&&(identical(other.yearTo, _this.yearTo) || other.yearTo == _this.yearTo)&&const DeepCollectionEquality().equals(other.quartiles, _this.quartiles)&&const DeepCollectionEquality().equals(other.journals, _this.journals)&&(identical(other.keepUnranked, _this.keepUnranked) || other.keepUnranked == _this.keepUnranked)&&(identical(other.useKb, _this.useKb) || other.useKb == _this.useKb)&&(identical(other.kbHits, _this.kbHits) || other.kbHits == _this.kbHits)&&(identical(other.maxChars, _this.maxChars) || other.maxChars == _this.maxChars));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AnswerCreate;
  return Object.hash(runtimeType,_this.question,_this.papers,_this.years,_this.yearFrom,_this.yearTo,const DeepCollectionEquality().hash(_this.quartiles),const DeepCollectionEquality().hash(_this.journals),_this.keepUnranked,_this.useKb,_this.kbHits,_this.maxChars);
}

@override
String toString() {
  final _this = this as AnswerCreate;
  return 'AnswerCreate(question: ${_this.question}, papers: ${_this.papers}, years: ${_this.years}, yearFrom: ${_this.yearFrom}, yearTo: ${_this.yearTo}, quartiles: ${_this.quartiles}, journals: ${_this.journals}, keepUnranked: ${_this.keepUnranked}, useKb: ${_this.useKb}, kbHits: ${_this.kbHits}, maxChars: ${_this.maxChars})';
}


}

/// @nodoc
abstract mixin class $AnswerCreateCopyWith<$Res>  {
  factory $AnswerCreateCopyWith(AnswerCreate value, $Res Function(AnswerCreate) _then) = _$AnswerCreateCopyWithImpl;
@useResult
$Res call({
 String question, int papers, int? years, int? yearFrom, int? yearTo, List<int> quartiles, List<String> journals, bool? keepUnranked, bool useKb, int kbHits, int maxChars
});




}
/// @nodoc
class _$AnswerCreateCopyWithImpl<$Res>
    implements $AnswerCreateCopyWith<$Res> {
  _$AnswerCreateCopyWithImpl(this._self, this._then);

  final AnswerCreate _self;
  final $Res Function(AnswerCreate) _then;

/// Create a copy of AnswerCreate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? question = null,Object? papers = null,Object? years = freezed,Object? yearFrom = freezed,Object? yearTo = freezed,Object? quartiles = null,Object? journals = null,Object? keepUnranked = freezed,Object? useKb = null,Object? kbHits = null,Object? maxChars = null,}) {
  return _then(AnswerCreate(
question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,papers: null == papers ? _self.papers : papers // ignore: cast_nullable_to_non_nullable
as int,years: freezed == years ? _self.years : years // ignore: cast_nullable_to_non_nullable
as int?,yearFrom: freezed == yearFrom ? _self.yearFrom : yearFrom // ignore: cast_nullable_to_non_nullable
as int?,yearTo: freezed == yearTo ? _self.yearTo : yearTo // ignore: cast_nullable_to_non_nullable
as int?,quartiles: null == quartiles ? _self.quartiles : quartiles // ignore: cast_nullable_to_non_nullable
as List<int>,journals: null == journals ? _self.journals : journals // ignore: cast_nullable_to_non_nullable
as List<String>,keepUnranked: freezed == keepUnranked ? _self.keepUnranked : keepUnranked // ignore: cast_nullable_to_non_nullable
as bool?,useKb: null == useKb ? _self.useKb : useKb // ignore: cast_nullable_to_non_nullable
as bool,kbHits: null == kbHits ? _self.kbHits : kbHits // ignore: cast_nullable_to_non_nullable
as int,maxChars: null == maxChars ? _self.maxChars : maxChars // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AnswerCreate].
extension AnswerCreatePatterns on AnswerCreate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnswerCreate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnswerCreate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnswerCreate value)  $default,){
final _that = this;
switch (_that) {
case _AnswerCreate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnswerCreate value)?  $default,){
final _that = this;
switch (_that) {
case _AnswerCreate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String question,  int papers,  int? years,  int? yearFrom,  int? yearTo,  List<int> quartiles,  List<String> journals,  bool? keepUnranked,  bool useKb,  int kbHits,  int maxChars)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnswerCreate() when $default != null:
return $default(_that.question,_that.papers,_that.years,_that.yearFrom,_that.yearTo,_that.quartiles,_that.journals,_that.keepUnranked,_that.useKb,_that.kbHits,_that.maxChars);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String question,  int papers,  int? years,  int? yearFrom,  int? yearTo,  List<int> quartiles,  List<String> journals,  bool? keepUnranked,  bool useKb,  int kbHits,  int maxChars)  $default,) {final _that = this;
switch (_that) {
case _AnswerCreate():
return $default(_that.question,_that.papers,_that.years,_that.yearFrom,_that.yearTo,_that.quartiles,_that.journals,_that.keepUnranked,_that.useKb,_that.kbHits,_that.maxChars);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String question,  int papers,  int? years,  int? yearFrom,  int? yearTo,  List<int> quartiles,  List<String> journals,  bool? keepUnranked,  bool useKb,  int kbHits,  int maxChars)?  $default,) {final _that = this;
switch (_that) {
case _AnswerCreate() when $default != null:
return $default(_that.question,_that.papers,_that.years,_that.yearFrom,_that.yearTo,_that.quartiles,_that.journals,_that.keepUnranked,_that.useKb,_that.kbHits,_that.maxChars);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnswerCreate implements AnswerCreate {
  const _AnswerCreate({required this.question, required this.papers, this.years, this.yearFrom, this.yearTo,  List<int> quartiles = const <int>[],  List<String> journals = const <String>[], this.keepUnranked, this.useKb = true, this.kbHits = 0, this.maxChars = 28000}): _quartiles = quartiles,_journals = journals;
  factory _AnswerCreate.fromJson(Map<String, dynamic> json) => _$AnswerCreateFromJson(json);

@override final  String question;
@override final  int papers;
@override final  int? years;
@override final  int? yearFrom;
@override final  int? yearTo;
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

@override final  bool? keepUnranked;
@override@JsonKey() final  bool useKb;
@override@JsonKey() final  int kbHits;
@override@JsonKey() final  int maxChars;

/// Create a copy of AnswerCreate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnswerCreateCopyWith<_AnswerCreate> get copyWith => __$AnswerCreateCopyWithImpl<_AnswerCreate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnswerCreateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnswerCreate&&(identical(other.question, question) || other.question == question)&&(identical(other.papers, papers) || other.papers == papers)&&(identical(other.years, years) || other.years == years)&&(identical(other.yearFrom, yearFrom) || other.yearFrom == yearFrom)&&(identical(other.yearTo, yearTo) || other.yearTo == yearTo)&&const DeepCollectionEquality().equals(other.quartiles, _quartiles)&&const DeepCollectionEquality().equals(other.journals, _journals)&&(identical(other.keepUnranked, keepUnranked) || other.keepUnranked == keepUnranked)&&(identical(other.useKb, useKb) || other.useKb == useKb)&&(identical(other.kbHits, kbHits) || other.kbHits == kbHits)&&(identical(other.maxChars, maxChars) || other.maxChars == maxChars));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,question,papers,years,yearFrom,yearTo,const DeepCollectionEquality().hash(_quartiles),const DeepCollectionEquality().hash(_journals),keepUnranked,useKb,kbHits,maxChars);
}

@override
String toString() {
    return 'AnswerCreate(question: $question, papers: $papers, years: $years, yearFrom: $yearFrom, yearTo: $yearTo, quartiles: $quartiles, journals: $journals, keepUnranked: $keepUnranked, useKb: $useKb, kbHits: $kbHits, maxChars: $maxChars)';
}


}

/// @nodoc
abstract mixin class _$AnswerCreateCopyWith<$Res> implements $AnswerCreateCopyWith<$Res> {
  factory _$AnswerCreateCopyWith(_AnswerCreate value, $Res Function(_AnswerCreate) _then) = __$AnswerCreateCopyWithImpl;
@override @useResult
$Res call({
 String question, int papers, int? years, int? yearFrom, int? yearTo, List<int> quartiles, List<String> journals, bool? keepUnranked, bool useKb, int kbHits, int maxChars
});




}
/// @nodoc
class __$AnswerCreateCopyWithImpl<$Res>
    implements _$AnswerCreateCopyWith<$Res> {
  __$AnswerCreateCopyWithImpl(this._self, this._then);

  final _AnswerCreate _self;
  final $Res Function(_AnswerCreate) _then;

/// Create a copy of AnswerCreate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? question = null,Object? papers = null,Object? years = freezed,Object? yearFrom = freezed,Object? yearTo = freezed,Object? quartiles = null,Object? journals = null,Object? keepUnranked = freezed,Object? useKb = null,Object? kbHits = null,Object? maxChars = null,}) {
  return _then(_AnswerCreate(
question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,papers: null == papers ? _self.papers : papers // ignore: cast_nullable_to_non_nullable
as int,years: freezed == years ? _self.years : years // ignore: cast_nullable_to_non_nullable
as int?,yearFrom: freezed == yearFrom ? _self.yearFrom : yearFrom // ignore: cast_nullable_to_non_nullable
as int?,yearTo: freezed == yearTo ? _self.yearTo : yearTo // ignore: cast_nullable_to_non_nullable
as int?,quartiles: null == quartiles ? _self._quartiles : quartiles // ignore: cast_nullable_to_non_nullable
as List<int>,journals: null == journals ? _self._journals : journals // ignore: cast_nullable_to_non_nullable
as List<String>,keepUnranked: freezed == keepUnranked ? _self.keepUnranked : keepUnranked // ignore: cast_nullable_to_non_nullable
as bool?,useKb: null == useKb ? _self.useKb : useKb // ignore: cast_nullable_to_non_nullable
as bool,kbHits: null == kbHits ? _self.kbHits : kbHits // ignore: cast_nullable_to_non_nullable
as int,maxChars: null == maxChars ? _self.maxChars : maxChars // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
