// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'papers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Paragraph {

 int get id; String get sec; int? get page; String get text;
/// Create a copy of Paragraph
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParagraphCopyWith<Paragraph> get copyWith => _$ParagraphCopyWithImpl<Paragraph>(this as Paragraph, _$identity);

  /// Serializes this Paragraph to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Paragraph;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Paragraph&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.sec, _this.sec) || other.sec == _this.sec)&&(identical(other.page, _this.page) || other.page == _this.page)&&(identical(other.text, _this.text) || other.text == _this.text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Paragraph;
  return Object.hash(runtimeType,_this.id,_this.sec,_this.page,_this.text);
}

@override
String toString() {
  final _this = this as Paragraph;
  return 'Paragraph(id: ${_this.id}, sec: ${_this.sec}, page: ${_this.page}, text: ${_this.text})';
}


}

/// @nodoc
abstract mixin class $ParagraphCopyWith<$Res>  {
  factory $ParagraphCopyWith(Paragraph value, $Res Function(Paragraph) _then) = _$ParagraphCopyWithImpl;
@useResult
$Res call({
 int id, String sec, int? page, String text
});




}
/// @nodoc
class _$ParagraphCopyWithImpl<$Res>
    implements $ParagraphCopyWith<$Res> {
  _$ParagraphCopyWithImpl(this._self, this._then);

  final Paragraph _self;
  final $Res Function(Paragraph) _then;

/// Create a copy of Paragraph
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sec = null,Object? page = freezed,Object? text = null,}) {
  return _then(Paragraph(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,sec: null == sec ? _self.sec : sec // ignore: cast_nullable_to_non_nullable
as String,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Paragraph].
extension ParagraphPatterns on Paragraph {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Paragraph value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Paragraph() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Paragraph value)  $default,){
final _that = this;
switch (_that) {
case _Paragraph():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Paragraph value)?  $default,){
final _that = this;
switch (_that) {
case _Paragraph() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String sec,  int? page,  String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Paragraph() when $default != null:
return $default(_that.id,_that.sec,_that.page,_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String sec,  int? page,  String text)  $default,) {final _that = this;
switch (_that) {
case _Paragraph():
return $default(_that.id,_that.sec,_that.page,_that.text);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String sec,  int? page,  String text)?  $default,) {final _that = this;
switch (_that) {
case _Paragraph() when $default != null:
return $default(_that.id,_that.sec,_that.page,_that.text);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Paragraph implements Paragraph {
  const _Paragraph({required this.id, this.sec = '', this.page, this.text = ''});
  factory _Paragraph.fromJson(Map<String, dynamic> json) => _$ParagraphFromJson(json);

@override final  int id;
@override@JsonKey() final  String sec;
@override final  int? page;
@override@JsonKey() final  String text;

/// Create a copy of Paragraph
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParagraphCopyWith<_Paragraph> get copyWith => __$ParagraphCopyWithImpl<_Paragraph>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParagraphToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Paragraph&&(identical(other.id, id) || other.id == id)&&(identical(other.sec, sec) || other.sec == sec)&&(identical(other.page, page) || other.page == page)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,sec,page,text);
}

@override
String toString() {
    return 'Paragraph(id: $id, sec: $sec, page: $page, text: $text)';
}


}

/// @nodoc
abstract mixin class _$ParagraphCopyWith<$Res> implements $ParagraphCopyWith<$Res> {
  factory _$ParagraphCopyWith(_Paragraph value, $Res Function(_Paragraph) _then) = __$ParagraphCopyWithImpl;
@override @useResult
$Res call({
 int id, String sec, int? page, String text
});




}
/// @nodoc
class __$ParagraphCopyWithImpl<$Res>
    implements _$ParagraphCopyWith<$Res> {
  __$ParagraphCopyWithImpl(this._self, this._then);

  final _Paragraph _self;
  final $Res Function(_Paragraph) _then;

/// Create a copy of Paragraph
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sec = null,Object? page = freezed,Object? text = null,}) {
  return _then(_Paragraph(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,sec: null == sec ? _self.sec : sec // ignore: cast_nullable_to_non_nullable
as String,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Fact {

 String get fact; String get factZh; String get kind; int? get pid; String? get sec; int? get page; String get quote; double get score; bool get verified;
/// Create a copy of Fact
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FactCopyWith<Fact> get copyWith => _$FactCopyWithImpl<Fact>(this as Fact, _$identity);

  /// Serializes this Fact to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Fact;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Fact&&(identical(other.fact, _this.fact) || other.fact == _this.fact)&&(identical(other.factZh, _this.factZh) || other.factZh == _this.factZh)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.pid, _this.pid) || other.pid == _this.pid)&&(identical(other.sec, _this.sec) || other.sec == _this.sec)&&(identical(other.page, _this.page) || other.page == _this.page)&&(identical(other.quote, _this.quote) || other.quote == _this.quote)&&(identical(other.score, _this.score) || other.score == _this.score)&&(identical(other.verified, _this.verified) || other.verified == _this.verified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Fact;
  return Object.hash(runtimeType,_this.fact,_this.factZh,_this.kind,_this.pid,_this.sec,_this.page,_this.quote,_this.score,_this.verified);
}

@override
String toString() {
  final _this = this as Fact;
  return 'Fact(fact: ${_this.fact}, factZh: ${_this.factZh}, kind: ${_this.kind}, pid: ${_this.pid}, sec: ${_this.sec}, page: ${_this.page}, quote: ${_this.quote}, score: ${_this.score}, verified: ${_this.verified})';
}


}

/// @nodoc
abstract mixin class $FactCopyWith<$Res>  {
  factory $FactCopyWith(Fact value, $Res Function(Fact) _then) = _$FactCopyWithImpl;
@useResult
$Res call({
 String fact, String factZh, String kind, int? pid, String? sec, int? page, String quote, double score, bool verified
});




}
/// @nodoc
class _$FactCopyWithImpl<$Res>
    implements $FactCopyWith<$Res> {
  _$FactCopyWithImpl(this._self, this._then);

  final Fact _self;
  final $Res Function(Fact) _then;

/// Create a copy of Fact
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fact = null,Object? factZh = null,Object? kind = null,Object? pid = freezed,Object? sec = freezed,Object? page = freezed,Object? quote = null,Object? score = null,Object? verified = null,}) {
  return _then(Fact(
fact: null == fact ? _self.fact : fact // ignore: cast_nullable_to_non_nullable
as String,factZh: null == factZh ? _self.factZh : factZh // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,pid: freezed == pid ? _self.pid : pid // ignore: cast_nullable_to_non_nullable
as int?,sec: freezed == sec ? _self.sec : sec // ignore: cast_nullable_to_non_nullable
as String?,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,quote: null == quote ? _self.quote : quote // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Fact].
extension FactPatterns on Fact {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Fact value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Fact() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Fact value)  $default,){
final _that = this;
switch (_that) {
case _Fact():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Fact value)?  $default,){
final _that = this;
switch (_that) {
case _Fact() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fact,  String factZh,  String kind,  int? pid,  String? sec,  int? page,  String quote,  double score,  bool verified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Fact() when $default != null:
return $default(_that.fact,_that.factZh,_that.kind,_that.pid,_that.sec,_that.page,_that.quote,_that.score,_that.verified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fact,  String factZh,  String kind,  int? pid,  String? sec,  int? page,  String quote,  double score,  bool verified)  $default,) {final _that = this;
switch (_that) {
case _Fact():
return $default(_that.fact,_that.factZh,_that.kind,_that.pid,_that.sec,_that.page,_that.quote,_that.score,_that.verified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fact,  String factZh,  String kind,  int? pid,  String? sec,  int? page,  String quote,  double score,  bool verified)?  $default,) {final _that = this;
switch (_that) {
case _Fact() when $default != null:
return $default(_that.fact,_that.factZh,_that.kind,_that.pid,_that.sec,_that.page,_that.quote,_that.score,_that.verified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Fact extends Fact {
  const _Fact({this.fact = '', this.factZh = '', this.kind = '', this.pid, this.sec, this.page, this.quote = '', this.score = 0, this.verified = false}): super._();
  factory _Fact.fromJson(Map<String, dynamic> json) => _$FactFromJson(json);

@override@JsonKey() final  String fact;
@override@JsonKey() final  String factZh;
@override@JsonKey() final  String kind;
@override final  int? pid;
@override final  String? sec;
@override final  int? page;
@override@JsonKey() final  String quote;
@override@JsonKey() final  double score;
@override@JsonKey() final  bool verified;

/// Create a copy of Fact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FactCopyWith<_Fact> get copyWith => __$FactCopyWithImpl<_Fact>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FactToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Fact&&(identical(other.fact, fact) || other.fact == fact)&&(identical(other.factZh, factZh) || other.factZh == factZh)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.pid, pid) || other.pid == pid)&&(identical(other.sec, sec) || other.sec == sec)&&(identical(other.page, page) || other.page == page)&&(identical(other.quote, quote) || other.quote == quote)&&(identical(other.score, score) || other.score == score)&&(identical(other.verified, verified) || other.verified == verified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,fact,factZh,kind,pid,sec,page,quote,score,verified);
}

@override
String toString() {
    return 'Fact(fact: $fact, factZh: $factZh, kind: $kind, pid: $pid, sec: $sec, page: $page, quote: $quote, score: $score, verified: $verified)';
}


}

/// @nodoc
abstract mixin class _$FactCopyWith<$Res> implements $FactCopyWith<$Res> {
  factory _$FactCopyWith(_Fact value, $Res Function(_Fact) _then) = __$FactCopyWithImpl;
@override @useResult
$Res call({
 String fact, String factZh, String kind, int? pid, String? sec, int? page, String quote, double score, bool verified
});




}
/// @nodoc
class __$FactCopyWithImpl<$Res>
    implements _$FactCopyWith<$Res> {
  __$FactCopyWithImpl(this._self, this._then);

  final _Fact _self;
  final $Res Function(_Fact) _then;

/// Create a copy of Fact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fact = null,Object? factZh = null,Object? kind = null,Object? pid = freezed,Object? sec = freezed,Object? page = freezed,Object? quote = null,Object? score = null,Object? verified = null,}) {
  return _then(_Fact(
fact: null == fact ? _self.fact : fact // ignore: cast_nullable_to_non_nullable
as String,factZh: null == factZh ? _self.factZh : factZh // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,pid: freezed == pid ? _self.pid : pid // ignore: cast_nullable_to_non_nullable
as int?,sec: freezed == sec ? _self.sec : sec // ignore: cast_nullable_to_non_nullable
as String?,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,quote: null == quote ? _self.quote : quote // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$VerifiedQuote {

 int get claimedPid; int? get pid; String? get sec; int? get page; String get quote; double get score; bool get verified; String? get noteSection; bool get keyFinding;
/// Create a copy of VerifiedQuote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerifiedQuoteCopyWith<VerifiedQuote> get copyWith => _$VerifiedQuoteCopyWithImpl<VerifiedQuote>(this as VerifiedQuote, _$identity);

  /// Serializes this VerifiedQuote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VerifiedQuote;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerifiedQuote&&(identical(other.claimedPid, _this.claimedPid) || other.claimedPid == _this.claimedPid)&&(identical(other.pid, _this.pid) || other.pid == _this.pid)&&(identical(other.sec, _this.sec) || other.sec == _this.sec)&&(identical(other.page, _this.page) || other.page == _this.page)&&(identical(other.quote, _this.quote) || other.quote == _this.quote)&&(identical(other.score, _this.score) || other.score == _this.score)&&(identical(other.verified, _this.verified) || other.verified == _this.verified)&&(identical(other.noteSection, _this.noteSection) || other.noteSection == _this.noteSection)&&(identical(other.keyFinding, _this.keyFinding) || other.keyFinding == _this.keyFinding));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VerifiedQuote;
  return Object.hash(runtimeType,_this.claimedPid,_this.pid,_this.sec,_this.page,_this.quote,_this.score,_this.verified,_this.noteSection,_this.keyFinding);
}

@override
String toString() {
  final _this = this as VerifiedQuote;
  return 'VerifiedQuote(claimedPid: ${_this.claimedPid}, pid: ${_this.pid}, sec: ${_this.sec}, page: ${_this.page}, quote: ${_this.quote}, score: ${_this.score}, verified: ${_this.verified}, noteSection: ${_this.noteSection}, keyFinding: ${_this.keyFinding})';
}


}

/// @nodoc
abstract mixin class $VerifiedQuoteCopyWith<$Res>  {
  factory $VerifiedQuoteCopyWith(VerifiedQuote value, $Res Function(VerifiedQuote) _then) = _$VerifiedQuoteCopyWithImpl;
@useResult
$Res call({
 int claimedPid, int? pid, String? sec, int? page, String quote, double score, bool verified, String? noteSection, bool keyFinding
});




}
/// @nodoc
class _$VerifiedQuoteCopyWithImpl<$Res>
    implements $VerifiedQuoteCopyWith<$Res> {
  _$VerifiedQuoteCopyWithImpl(this._self, this._then);

  final VerifiedQuote _self;
  final $Res Function(VerifiedQuote) _then;

/// Create a copy of VerifiedQuote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? claimedPid = null,Object? pid = freezed,Object? sec = freezed,Object? page = freezed,Object? quote = null,Object? score = null,Object? verified = null,Object? noteSection = freezed,Object? keyFinding = null,}) {
  return _then(VerifiedQuote(
claimedPid: null == claimedPid ? _self.claimedPid : claimedPid // ignore: cast_nullable_to_non_nullable
as int,pid: freezed == pid ? _self.pid : pid // ignore: cast_nullable_to_non_nullable
as int?,sec: freezed == sec ? _self.sec : sec // ignore: cast_nullable_to_non_nullable
as String?,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,quote: null == quote ? _self.quote : quote // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,noteSection: freezed == noteSection ? _self.noteSection : noteSection // ignore: cast_nullable_to_non_nullable
as String?,keyFinding: null == keyFinding ? _self.keyFinding : keyFinding // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [VerifiedQuote].
extension VerifiedQuotePatterns on VerifiedQuote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerifiedQuote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerifiedQuote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerifiedQuote value)  $default,){
final _that = this;
switch (_that) {
case _VerifiedQuote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerifiedQuote value)?  $default,){
final _that = this;
switch (_that) {
case _VerifiedQuote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int claimedPid,  int? pid,  String? sec,  int? page,  String quote,  double score,  bool verified,  String? noteSection,  bool keyFinding)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerifiedQuote() when $default != null:
return $default(_that.claimedPid,_that.pid,_that.sec,_that.page,_that.quote,_that.score,_that.verified,_that.noteSection,_that.keyFinding);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int claimedPid,  int? pid,  String? sec,  int? page,  String quote,  double score,  bool verified,  String? noteSection,  bool keyFinding)  $default,) {final _that = this;
switch (_that) {
case _VerifiedQuote():
return $default(_that.claimedPid,_that.pid,_that.sec,_that.page,_that.quote,_that.score,_that.verified,_that.noteSection,_that.keyFinding);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int claimedPid,  int? pid,  String? sec,  int? page,  String quote,  double score,  bool verified,  String? noteSection,  bool keyFinding)?  $default,) {final _that = this;
switch (_that) {
case _VerifiedQuote() when $default != null:
return $default(_that.claimedPid,_that.pid,_that.sec,_that.page,_that.quote,_that.score,_that.verified,_that.noteSection,_that.keyFinding);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VerifiedQuote implements VerifiedQuote {
  const _VerifiedQuote({this.claimedPid = 0, this.pid, this.sec, this.page, this.quote = '', this.score = 0, this.verified = false, this.noteSection, this.keyFinding = false});
  factory _VerifiedQuote.fromJson(Map<String, dynamic> json) => _$VerifiedQuoteFromJson(json);

@override@JsonKey() final  int claimedPid;
@override final  int? pid;
@override final  String? sec;
@override final  int? page;
@override@JsonKey() final  String quote;
@override@JsonKey() final  double score;
@override@JsonKey() final  bool verified;
@override final  String? noteSection;
@override@JsonKey() final  bool keyFinding;

/// Create a copy of VerifiedQuote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerifiedQuoteCopyWith<_VerifiedQuote> get copyWith => __$VerifiedQuoteCopyWithImpl<_VerifiedQuote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerifiedQuoteToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerifiedQuote&&(identical(other.claimedPid, claimedPid) || other.claimedPid == claimedPid)&&(identical(other.pid, pid) || other.pid == pid)&&(identical(other.sec, sec) || other.sec == sec)&&(identical(other.page, page) || other.page == page)&&(identical(other.quote, quote) || other.quote == quote)&&(identical(other.score, score) || other.score == score)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.noteSection, noteSection) || other.noteSection == noteSection)&&(identical(other.keyFinding, keyFinding) || other.keyFinding == keyFinding));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,claimedPid,pid,sec,page,quote,score,verified,noteSection,keyFinding);
}

@override
String toString() {
    return 'VerifiedQuote(claimedPid: $claimedPid, pid: $pid, sec: $sec, page: $page, quote: $quote, score: $score, verified: $verified, noteSection: $noteSection, keyFinding: $keyFinding)';
}


}

/// @nodoc
abstract mixin class _$VerifiedQuoteCopyWith<$Res> implements $VerifiedQuoteCopyWith<$Res> {
  factory _$VerifiedQuoteCopyWith(_VerifiedQuote value, $Res Function(_VerifiedQuote) _then) = __$VerifiedQuoteCopyWithImpl;
@override @useResult
$Res call({
 int claimedPid, int? pid, String? sec, int? page, String quote, double score, bool verified, String? noteSection, bool keyFinding
});




}
/// @nodoc
class __$VerifiedQuoteCopyWithImpl<$Res>
    implements _$VerifiedQuoteCopyWith<$Res> {
  __$VerifiedQuoteCopyWithImpl(this._self, this._then);

  final _VerifiedQuote _self;
  final $Res Function(_VerifiedQuote) _then;

/// Create a copy of VerifiedQuote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? claimedPid = null,Object? pid = freezed,Object? sec = freezed,Object? page = freezed,Object? quote = null,Object? score = null,Object? verified = null,Object? noteSection = freezed,Object? keyFinding = null,}) {
  return _then(_VerifiedQuote(
claimedPid: null == claimedPid ? _self.claimedPid : claimedPid // ignore: cast_nullable_to_non_nullable
as int,pid: freezed == pid ? _self.pid : pid // ignore: cast_nullable_to_non_nullable
as int?,sec: freezed == sec ? _self.sec : sec // ignore: cast_nullable_to_non_nullable
as String?,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,quote: null == quote ? _self.quote : quote // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,noteSection: freezed == noteSection ? _self.noteSection : noteSection // ignore: cast_nullable_to_non_nullable
as String?,keyFinding: null == keyFinding ? _self.keyFinding : keyFinding // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PaperMeta {

 String get key; String get pmid; String get doi; String get pmcid; String get title; String get year; String get journal; String get issn; String get quartile; String get authors; String get source; List<String> get types; DateTime? get indexedAt; int get nParagraphs; int get nFacts;
/// Create a copy of PaperMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaperMetaCopyWith<PaperMeta> get copyWith => _$PaperMetaCopyWithImpl<PaperMeta>(this as PaperMeta, _$identity);

  /// Serializes this PaperMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PaperMeta;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaperMeta&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.pmid, _this.pmid) || other.pmid == _this.pmid)&&(identical(other.doi, _this.doi) || other.doi == _this.doi)&&(identical(other.pmcid, _this.pmcid) || other.pmcid == _this.pmcid)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.year, _this.year) || other.year == _this.year)&&(identical(other.journal, _this.journal) || other.journal == _this.journal)&&(identical(other.issn, _this.issn) || other.issn == _this.issn)&&(identical(other.quartile, _this.quartile) || other.quartile == _this.quartile)&&(identical(other.authors, _this.authors) || other.authors == _this.authors)&&(identical(other.source, _this.source) || other.source == _this.source)&&const DeepCollectionEquality().equals(other.types, _this.types)&&(identical(other.indexedAt, _this.indexedAt) || other.indexedAt == _this.indexedAt)&&(identical(other.nParagraphs, _this.nParagraphs) || other.nParagraphs == _this.nParagraphs)&&(identical(other.nFacts, _this.nFacts) || other.nFacts == _this.nFacts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PaperMeta;
  return Object.hash(runtimeType,_this.key,_this.pmid,_this.doi,_this.pmcid,_this.title,_this.year,_this.journal,_this.issn,_this.quartile,_this.authors,_this.source,const DeepCollectionEquality().hash(_this.types),_this.indexedAt,_this.nParagraphs,_this.nFacts);
}

@override
String toString() {
  final _this = this as PaperMeta;
  return 'PaperMeta(key: ${_this.key}, pmid: ${_this.pmid}, doi: ${_this.doi}, pmcid: ${_this.pmcid}, title: ${_this.title}, year: ${_this.year}, journal: ${_this.journal}, issn: ${_this.issn}, quartile: ${_this.quartile}, authors: ${_this.authors}, source: ${_this.source}, types: ${_this.types}, indexedAt: ${_this.indexedAt}, nParagraphs: ${_this.nParagraphs}, nFacts: ${_this.nFacts})';
}


}

/// @nodoc
abstract mixin class $PaperMetaCopyWith<$Res>  {
  factory $PaperMetaCopyWith(PaperMeta value, $Res Function(PaperMeta) _then) = _$PaperMetaCopyWithImpl;
@useResult
$Res call({
 String key, String pmid, String doi, String pmcid, String title, String year, String journal, String issn, String quartile, String authors, String source, List<String> types, DateTime? indexedAt, int nParagraphs, int nFacts
});




}
/// @nodoc
class _$PaperMetaCopyWithImpl<$Res>
    implements $PaperMetaCopyWith<$Res> {
  _$PaperMetaCopyWithImpl(this._self, this._then);

  final PaperMeta _self;
  final $Res Function(PaperMeta) _then;

/// Create a copy of PaperMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? pmid = null,Object? doi = null,Object? pmcid = null,Object? title = null,Object? year = null,Object? journal = null,Object? issn = null,Object? quartile = null,Object? authors = null,Object? source = null,Object? types = null,Object? indexedAt = freezed,Object? nParagraphs = null,Object? nFacts = null,}) {
  return _then(PaperMeta(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,pmid: null == pmid ? _self.pmid : pmid // ignore: cast_nullable_to_non_nullable
as String,doi: null == doi ? _self.doi : doi // ignore: cast_nullable_to_non_nullable
as String,pmcid: null == pmcid ? _self.pmcid : pmcid // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String,journal: null == journal ? _self.journal : journal // ignore: cast_nullable_to_non_nullable
as String,issn: null == issn ? _self.issn : issn // ignore: cast_nullable_to_non_nullable
as String,quartile: null == quartile ? _self.quartile : quartile // ignore: cast_nullable_to_non_nullable
as String,authors: null == authors ? _self.authors : authors // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,types: null == types ? _self.types : types // ignore: cast_nullable_to_non_nullable
as List<String>,indexedAt: freezed == indexedAt ? _self.indexedAt : indexedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,nParagraphs: null == nParagraphs ? _self.nParagraphs : nParagraphs // ignore: cast_nullable_to_non_nullable
as int,nFacts: null == nFacts ? _self.nFacts : nFacts // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PaperMeta].
extension PaperMetaPatterns on PaperMeta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaperMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaperMeta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaperMeta value)  $default,){
final _that = this;
switch (_that) {
case _PaperMeta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaperMeta value)?  $default,){
final _that = this;
switch (_that) {
case _PaperMeta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String pmid,  String doi,  String pmcid,  String title,  String year,  String journal,  String issn,  String quartile,  String authors,  String source,  List<String> types,  DateTime? indexedAt,  int nParagraphs,  int nFacts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaperMeta() when $default != null:
return $default(_that.key,_that.pmid,_that.doi,_that.pmcid,_that.title,_that.year,_that.journal,_that.issn,_that.quartile,_that.authors,_that.source,_that.types,_that.indexedAt,_that.nParagraphs,_that.nFacts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String pmid,  String doi,  String pmcid,  String title,  String year,  String journal,  String issn,  String quartile,  String authors,  String source,  List<String> types,  DateTime? indexedAt,  int nParagraphs,  int nFacts)  $default,) {final _that = this;
switch (_that) {
case _PaperMeta():
return $default(_that.key,_that.pmid,_that.doi,_that.pmcid,_that.title,_that.year,_that.journal,_that.issn,_that.quartile,_that.authors,_that.source,_that.types,_that.indexedAt,_that.nParagraphs,_that.nFacts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String pmid,  String doi,  String pmcid,  String title,  String year,  String journal,  String issn,  String quartile,  String authors,  String source,  List<String> types,  DateTime? indexedAt,  int nParagraphs,  int nFacts)?  $default,) {final _that = this;
switch (_that) {
case _PaperMeta() when $default != null:
return $default(_that.key,_that.pmid,_that.doi,_that.pmcid,_that.title,_that.year,_that.journal,_that.issn,_that.quartile,_that.authors,_that.source,_that.types,_that.indexedAt,_that.nParagraphs,_that.nFacts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaperMeta implements PaperMeta {
  const _PaperMeta({required this.key, this.pmid = '', this.doi = '', this.pmcid = '', this.title = '', this.year = '', this.journal = '', this.issn = '', this.quartile = '', this.authors = '', this.source = '',  List<String> types = const <String>[], this.indexedAt, this.nParagraphs = 0, this.nFacts = 0}): _types = types;
  factory _PaperMeta.fromJson(Map<String, dynamic> json) => _$PaperMetaFromJson(json);

@override final  String key;
@override@JsonKey() final  String pmid;
@override@JsonKey() final  String doi;
@override@JsonKey() final  String pmcid;
@override@JsonKey() final  String title;
@override@JsonKey() final  String year;
@override@JsonKey() final  String journal;
@override@JsonKey() final  String issn;
@override@JsonKey() final  String quartile;
@override@JsonKey() final  String authors;
@override@JsonKey() final  String source;
 final  List<String> _types;
@override@JsonKey() List<String> get types {
  if (_types is EqualUnmodifiableListView) return _types;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_types);
}

@override final  DateTime? indexedAt;
@override@JsonKey() final  int nParagraphs;
@override@JsonKey() final  int nFacts;

/// Create a copy of PaperMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaperMetaCopyWith<_PaperMeta> get copyWith => __$PaperMetaCopyWithImpl<_PaperMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaperMetaToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaperMeta&&(identical(other.key, key) || other.key == key)&&(identical(other.pmid, pmid) || other.pmid == pmid)&&(identical(other.doi, doi) || other.doi == doi)&&(identical(other.pmcid, pmcid) || other.pmcid == pmcid)&&(identical(other.title, title) || other.title == title)&&(identical(other.year, year) || other.year == year)&&(identical(other.journal, journal) || other.journal == journal)&&(identical(other.issn, issn) || other.issn == issn)&&(identical(other.quartile, quartile) || other.quartile == quartile)&&(identical(other.authors, authors) || other.authors == authors)&&(identical(other.source, source) || other.source == source)&&const DeepCollectionEquality().equals(other.types, _types)&&(identical(other.indexedAt, indexedAt) || other.indexedAt == indexedAt)&&(identical(other.nParagraphs, nParagraphs) || other.nParagraphs == nParagraphs)&&(identical(other.nFacts, nFacts) || other.nFacts == nFacts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,key,pmid,doi,pmcid,title,year,journal,issn,quartile,authors,source,const DeepCollectionEquality().hash(_types),indexedAt,nParagraphs,nFacts);
}

@override
String toString() {
    return 'PaperMeta(key: $key, pmid: $pmid, doi: $doi, pmcid: $pmcid, title: $title, year: $year, journal: $journal, issn: $issn, quartile: $quartile, authors: $authors, source: $source, types: $types, indexedAt: $indexedAt, nParagraphs: $nParagraphs, nFacts: $nFacts)';
}


}

/// @nodoc
abstract mixin class _$PaperMetaCopyWith<$Res> implements $PaperMetaCopyWith<$Res> {
  factory _$PaperMetaCopyWith(_PaperMeta value, $Res Function(_PaperMeta) _then) = __$PaperMetaCopyWithImpl;
@override @useResult
$Res call({
 String key, String pmid, String doi, String pmcid, String title, String year, String journal, String issn, String quartile, String authors, String source, List<String> types, DateTime? indexedAt, int nParagraphs, int nFacts
});




}
/// @nodoc
class __$PaperMetaCopyWithImpl<$Res>
    implements _$PaperMetaCopyWith<$Res> {
  __$PaperMetaCopyWithImpl(this._self, this._then);

  final _PaperMeta _self;
  final $Res Function(_PaperMeta) _then;

/// Create a copy of PaperMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? pmid = null,Object? doi = null,Object? pmcid = null,Object? title = null,Object? year = null,Object? journal = null,Object? issn = null,Object? quartile = null,Object? authors = null,Object? source = null,Object? types = null,Object? indexedAt = freezed,Object? nParagraphs = null,Object? nFacts = null,}) {
  return _then(_PaperMeta(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,pmid: null == pmid ? _self.pmid : pmid // ignore: cast_nullable_to_non_nullable
as String,doi: null == doi ? _self.doi : doi // ignore: cast_nullable_to_non_nullable
as String,pmcid: null == pmcid ? _self.pmcid : pmcid // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String,journal: null == journal ? _self.journal : journal // ignore: cast_nullable_to_non_nullable
as String,issn: null == issn ? _self.issn : issn // ignore: cast_nullable_to_non_nullable
as String,quartile: null == quartile ? _self.quartile : quartile // ignore: cast_nullable_to_non_nullable
as String,authors: null == authors ? _self.authors : authors // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,types: null == types ? _self._types : types // ignore: cast_nullable_to_non_nullable
as List<String>,indexedAt: freezed == indexedAt ? _self.indexedAt : indexedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,nParagraphs: null == nParagraphs ? _self.nParagraphs : nParagraphs // ignore: cast_nullable_to_non_nullable
as int,nFacts: null == nFacts ? _self.nFacts : nFacts // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
