// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meta.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RankTable {

 String get file; int? get year; int get journals; String get source;
/// Create a copy of RankTable
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RankTableCopyWith<RankTable> get copyWith => _$RankTableCopyWithImpl<RankTable>(this as RankTable, _$identity);

  /// Serializes this RankTable to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RankTable;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RankTable&&(identical(other.file, _this.file) || other.file == _this.file)&&(identical(other.year, _this.year) || other.year == _this.year)&&(identical(other.journals, _this.journals) || other.journals == _this.journals)&&(identical(other.source, _this.source) || other.source == _this.source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RankTable;
  return Object.hash(runtimeType,_this.file,_this.year,_this.journals,_this.source);
}

@override
String toString() {
  final _this = this as RankTable;
  return 'RankTable(file: ${_this.file}, year: ${_this.year}, journals: ${_this.journals}, source: ${_this.source})';
}


}

/// @nodoc
abstract mixin class $RankTableCopyWith<$Res>  {
  factory $RankTableCopyWith(RankTable value, $Res Function(RankTable) _then) = _$RankTableCopyWithImpl;
@useResult
$Res call({
 String file, int? year, int journals, String source
});




}
/// @nodoc
class _$RankTableCopyWithImpl<$Res>
    implements $RankTableCopyWith<$Res> {
  _$RankTableCopyWithImpl(this._self, this._then);

  final RankTable _self;
  final $Res Function(RankTable) _then;

/// Create a copy of RankTable
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? file = null,Object? year = freezed,Object? journals = null,Object? source = null,}) {
  return _then(RankTable(
file: null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as String,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,journals: null == journals ? _self.journals : journals // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RankTable].
extension RankTablePatterns on RankTable {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RankTable value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RankTable() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RankTable value)  $default,){
final _that = this;
switch (_that) {
case _RankTable():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RankTable value)?  $default,){
final _that = this;
switch (_that) {
case _RankTable() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String file,  int? year,  int journals,  String source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RankTable() when $default != null:
return $default(_that.file,_that.year,_that.journals,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String file,  int? year,  int journals,  String source)  $default,) {final _that = this;
switch (_that) {
case _RankTable():
return $default(_that.file,_that.year,_that.journals,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String file,  int? year,  int journals,  String source)?  $default,) {final _that = this;
switch (_that) {
case _RankTable() when $default != null:
return $default(_that.file,_that.year,_that.journals,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RankTable implements RankTable {
  const _RankTable({this.file = '', this.year, this.journals = 0, this.source = 'custom'});
  factory _RankTable.fromJson(Map<String, dynamic> json) => _$RankTableFromJson(json);

@override@JsonKey() final  String file;
@override final  int? year;
@override@JsonKey() final  int journals;
@override@JsonKey() final  String source;

/// Create a copy of RankTable
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RankTableCopyWith<_RankTable> get copyWith => __$RankTableCopyWithImpl<_RankTable>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RankTableToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RankTable&&(identical(other.file, file) || other.file == file)&&(identical(other.year, year) || other.year == year)&&(identical(other.journals, journals) || other.journals == journals)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,file,year,journals,source);
}

@override
String toString() {
    return 'RankTable(file: $file, year: $year, journals: $journals, source: $source)';
}


}

/// @nodoc
abstract mixin class _$RankTableCopyWith<$Res> implements $RankTableCopyWith<$Res> {
  factory _$RankTableCopyWith(_RankTable value, $Res Function(_RankTable) _then) = __$RankTableCopyWithImpl;
@override @useResult
$Res call({
 String file, int? year, int journals, String source
});




}
/// @nodoc
class __$RankTableCopyWithImpl<$Res>
    implements _$RankTableCopyWith<$Res> {
  __$RankTableCopyWithImpl(this._self, this._then);

  final _RankTable _self;
  final $Res Function(_RankTable) _then;

/// Create a copy of RankTable
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? file = null,Object? year = freezed,Object? journals = null,Object? source = null,}) {
  return _then(_RankTable(
file: null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as String,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,journals: null == journals ? _self.journals : journals // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RankTables {

 List<RankTable> get tables; int get issns; int get titles; DateTime? get loadedAt;
/// Create a copy of RankTables
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RankTablesCopyWith<RankTables> get copyWith => _$RankTablesCopyWithImpl<RankTables>(this as RankTables, _$identity);

  /// Serializes this RankTables to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RankTables;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RankTables&&const DeepCollectionEquality().equals(other.tables, _this.tables)&&(identical(other.issns, _this.issns) || other.issns == _this.issns)&&(identical(other.titles, _this.titles) || other.titles == _this.titles)&&(identical(other.loadedAt, _this.loadedAt) || other.loadedAt == _this.loadedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RankTables;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.tables),_this.issns,_this.titles,_this.loadedAt);
}

@override
String toString() {
  final _this = this as RankTables;
  return 'RankTables(tables: ${_this.tables}, issns: ${_this.issns}, titles: ${_this.titles}, loadedAt: ${_this.loadedAt})';
}


}

/// @nodoc
abstract mixin class $RankTablesCopyWith<$Res>  {
  factory $RankTablesCopyWith(RankTables value, $Res Function(RankTables) _then) = _$RankTablesCopyWithImpl;
@useResult
$Res call({
 List<RankTable> tables, int issns, int titles, DateTime? loadedAt
});




}
/// @nodoc
class _$RankTablesCopyWithImpl<$Res>
    implements $RankTablesCopyWith<$Res> {
  _$RankTablesCopyWithImpl(this._self, this._then);

  final RankTables _self;
  final $Res Function(RankTables) _then;

/// Create a copy of RankTables
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tables = null,Object? issns = null,Object? titles = null,Object? loadedAt = freezed,}) {
  return _then(RankTables(
tables: null == tables ? _self.tables : tables // ignore: cast_nullable_to_non_nullable
as List<RankTable>,issns: null == issns ? _self.issns : issns // ignore: cast_nullable_to_non_nullable
as int,titles: null == titles ? _self.titles : titles // ignore: cast_nullable_to_non_nullable
as int,loadedAt: freezed == loadedAt ? _self.loadedAt : loadedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RankTables].
extension RankTablesPatterns on RankTables {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RankTables value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RankTables() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RankTables value)  $default,){
final _that = this;
switch (_that) {
case _RankTables():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RankTables value)?  $default,){
final _that = this;
switch (_that) {
case _RankTables() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<RankTable> tables,  int issns,  int titles,  DateTime? loadedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RankTables() when $default != null:
return $default(_that.tables,_that.issns,_that.titles,_that.loadedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<RankTable> tables,  int issns,  int titles,  DateTime? loadedAt)  $default,) {final _that = this;
switch (_that) {
case _RankTables():
return $default(_that.tables,_that.issns,_that.titles,_that.loadedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<RankTable> tables,  int issns,  int titles,  DateTime? loadedAt)?  $default,) {final _that = this;
switch (_that) {
case _RankTables() when $default != null:
return $default(_that.tables,_that.issns,_that.titles,_that.loadedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RankTables implements RankTables {
  const _RankTables({ List<RankTable> tables = const <RankTable>[], this.issns = 0, this.titles = 0, this.loadedAt}): _tables = tables;
  factory _RankTables.fromJson(Map<String, dynamic> json) => _$RankTablesFromJson(json);

 final  List<RankTable> _tables;
@override@JsonKey() List<RankTable> get tables {
  if (_tables is EqualUnmodifiableListView) return _tables;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tables);
}

@override@JsonKey() final  int issns;
@override@JsonKey() final  int titles;
@override final  DateTime? loadedAt;

/// Create a copy of RankTables
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RankTablesCopyWith<_RankTables> get copyWith => __$RankTablesCopyWithImpl<_RankTables>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RankTablesToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RankTables&&const DeepCollectionEquality().equals(other.tables, _tables)&&(identical(other.issns, issns) || other.issns == issns)&&(identical(other.titles, titles) || other.titles == titles)&&(identical(other.loadedAt, loadedAt) || other.loadedAt == loadedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_tables),issns,titles,loadedAt);
}

@override
String toString() {
    return 'RankTables(tables: $tables, issns: $issns, titles: $titles, loadedAt: $loadedAt)';
}


}

/// @nodoc
abstract mixin class _$RankTablesCopyWith<$Res> implements $RankTablesCopyWith<$Res> {
  factory _$RankTablesCopyWith(_RankTables value, $Res Function(_RankTables) _then) = __$RankTablesCopyWithImpl;
@override @useResult
$Res call({
 List<RankTable> tables, int issns, int titles, DateTime? loadedAt
});




}
/// @nodoc
class __$RankTablesCopyWithImpl<$Res>
    implements _$RankTablesCopyWith<$Res> {
  __$RankTablesCopyWithImpl(this._self, this._then);

  final _RankTables _self;
  final $Res Function(_RankTables) _then;

/// Create a copy of RankTables
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tables = null,Object? issns = null,Object? titles = null,Object? loadedAt = freezed,}) {
  return _then(_RankTables(
tables: null == tables ? _self._tables : tables // ignore: cast_nullable_to_non_nullable
as List<RankTable>,issns: null == issns ? _self.issns : issns // ignore: cast_nullable_to_non_nullable
as int,titles: null == titles ? _self.titles : titles // ignore: cast_nullable_to_non_nullable
as int,loadedAt: freezed == loadedAt ? _self.loadedAt : loadedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$PaywallStatus {

 bool get configured; DateTime? get savedAt; String? get finalUrl; bool get hasSessionStorage; bool get hasContextMeta; bool get playwrightAvailable;
/// Create a copy of PaywallStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaywallStatusCopyWith<PaywallStatus> get copyWith => _$PaywallStatusCopyWithImpl<PaywallStatus>(this as PaywallStatus, _$identity);

  /// Serializes this PaywallStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PaywallStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaywallStatus&&(identical(other.configured, _this.configured) || other.configured == _this.configured)&&(identical(other.savedAt, _this.savedAt) || other.savedAt == _this.savedAt)&&(identical(other.finalUrl, _this.finalUrl) || other.finalUrl == _this.finalUrl)&&(identical(other.hasSessionStorage, _this.hasSessionStorage) || other.hasSessionStorage == _this.hasSessionStorage)&&(identical(other.hasContextMeta, _this.hasContextMeta) || other.hasContextMeta == _this.hasContextMeta)&&(identical(other.playwrightAvailable, _this.playwrightAvailable) || other.playwrightAvailable == _this.playwrightAvailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PaywallStatus;
  return Object.hash(runtimeType,_this.configured,_this.savedAt,_this.finalUrl,_this.hasSessionStorage,_this.hasContextMeta,_this.playwrightAvailable);
}

@override
String toString() {
  final _this = this as PaywallStatus;
  return 'PaywallStatus(configured: ${_this.configured}, savedAt: ${_this.savedAt}, finalUrl: ${_this.finalUrl}, hasSessionStorage: ${_this.hasSessionStorage}, hasContextMeta: ${_this.hasContextMeta}, playwrightAvailable: ${_this.playwrightAvailable})';
}


}

/// @nodoc
abstract mixin class $PaywallStatusCopyWith<$Res>  {
  factory $PaywallStatusCopyWith(PaywallStatus value, $Res Function(PaywallStatus) _then) = _$PaywallStatusCopyWithImpl;
@useResult
$Res call({
 bool configured, DateTime? savedAt, String? finalUrl, bool hasSessionStorage, bool hasContextMeta, bool playwrightAvailable
});




}
/// @nodoc
class _$PaywallStatusCopyWithImpl<$Res>
    implements $PaywallStatusCopyWith<$Res> {
  _$PaywallStatusCopyWithImpl(this._self, this._then);

  final PaywallStatus _self;
  final $Res Function(PaywallStatus) _then;

/// Create a copy of PaywallStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? configured = null,Object? savedAt = freezed,Object? finalUrl = freezed,Object? hasSessionStorage = null,Object? hasContextMeta = null,Object? playwrightAvailable = null,}) {
  return _then(PaywallStatus(
configured: null == configured ? _self.configured : configured // ignore: cast_nullable_to_non_nullable
as bool,savedAt: freezed == savedAt ? _self.savedAt : savedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,finalUrl: freezed == finalUrl ? _self.finalUrl : finalUrl // ignore: cast_nullable_to_non_nullable
as String?,hasSessionStorage: null == hasSessionStorage ? _self.hasSessionStorage : hasSessionStorage // ignore: cast_nullable_to_non_nullable
as bool,hasContextMeta: null == hasContextMeta ? _self.hasContextMeta : hasContextMeta // ignore: cast_nullable_to_non_nullable
as bool,playwrightAvailable: null == playwrightAvailable ? _self.playwrightAvailable : playwrightAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PaywallStatus].
extension PaywallStatusPatterns on PaywallStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaywallStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaywallStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaywallStatus value)  $default,){
final _that = this;
switch (_that) {
case _PaywallStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaywallStatus value)?  $default,){
final _that = this;
switch (_that) {
case _PaywallStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool configured,  DateTime? savedAt,  String? finalUrl,  bool hasSessionStorage,  bool hasContextMeta,  bool playwrightAvailable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaywallStatus() when $default != null:
return $default(_that.configured,_that.savedAt,_that.finalUrl,_that.hasSessionStorage,_that.hasContextMeta,_that.playwrightAvailable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool configured,  DateTime? savedAt,  String? finalUrl,  bool hasSessionStorage,  bool hasContextMeta,  bool playwrightAvailable)  $default,) {final _that = this;
switch (_that) {
case _PaywallStatus():
return $default(_that.configured,_that.savedAt,_that.finalUrl,_that.hasSessionStorage,_that.hasContextMeta,_that.playwrightAvailable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool configured,  DateTime? savedAt,  String? finalUrl,  bool hasSessionStorage,  bool hasContextMeta,  bool playwrightAvailable)?  $default,) {final _that = this;
switch (_that) {
case _PaywallStatus() when $default != null:
return $default(_that.configured,_that.savedAt,_that.finalUrl,_that.hasSessionStorage,_that.hasContextMeta,_that.playwrightAvailable);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaywallStatus implements PaywallStatus {
  const _PaywallStatus({this.configured = false, this.savedAt, this.finalUrl, this.hasSessionStorage = false, this.hasContextMeta = false, this.playwrightAvailable = false});
  factory _PaywallStatus.fromJson(Map<String, dynamic> json) => _$PaywallStatusFromJson(json);

@override@JsonKey() final  bool configured;
@override final  DateTime? savedAt;
@override final  String? finalUrl;
@override@JsonKey() final  bool hasSessionStorage;
@override@JsonKey() final  bool hasContextMeta;
@override@JsonKey() final  bool playwrightAvailable;

/// Create a copy of PaywallStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaywallStatusCopyWith<_PaywallStatus> get copyWith => __$PaywallStatusCopyWithImpl<_PaywallStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaywallStatusToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaywallStatus&&(identical(other.configured, configured) || other.configured == configured)&&(identical(other.savedAt, savedAt) || other.savedAt == savedAt)&&(identical(other.finalUrl, finalUrl) || other.finalUrl == finalUrl)&&(identical(other.hasSessionStorage, hasSessionStorage) || other.hasSessionStorage == hasSessionStorage)&&(identical(other.hasContextMeta, hasContextMeta) || other.hasContextMeta == hasContextMeta)&&(identical(other.playwrightAvailable, playwrightAvailable) || other.playwrightAvailable == playwrightAvailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,configured,savedAt,finalUrl,hasSessionStorage,hasContextMeta,playwrightAvailable);
}

@override
String toString() {
    return 'PaywallStatus(configured: $configured, savedAt: $savedAt, finalUrl: $finalUrl, hasSessionStorage: $hasSessionStorage, hasContextMeta: $hasContextMeta, playwrightAvailable: $playwrightAvailable)';
}


}

/// @nodoc
abstract mixin class _$PaywallStatusCopyWith<$Res> implements $PaywallStatusCopyWith<$Res> {
  factory _$PaywallStatusCopyWith(_PaywallStatus value, $Res Function(_PaywallStatus) _then) = __$PaywallStatusCopyWithImpl;
@override @useResult
$Res call({
 bool configured, DateTime? savedAt, String? finalUrl, bool hasSessionStorage, bool hasContextMeta, bool playwrightAvailable
});




}
/// @nodoc
class __$PaywallStatusCopyWithImpl<$Res>
    implements _$PaywallStatusCopyWith<$Res> {
  __$PaywallStatusCopyWithImpl(this._self, this._then);

  final _PaywallStatus _self;
  final $Res Function(_PaywallStatus) _then;

/// Create a copy of PaywallStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? configured = null,Object? savedAt = freezed,Object? finalUrl = freezed,Object? hasSessionStorage = null,Object? hasContextMeta = null,Object? playwrightAvailable = null,}) {
  return _then(_PaywallStatus(
configured: null == configured ? _self.configured : configured // ignore: cast_nullable_to_non_nullable
as bool,savedAt: freezed == savedAt ? _self.savedAt : savedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,finalUrl: freezed == finalUrl ? _self.finalUrl : finalUrl // ignore: cast_nullable_to_non_nullable
as String?,hasSessionStorage: null == hasSessionStorage ? _self.hasSessionStorage : hasSessionStorage // ignore: cast_nullable_to_non_nullable
as bool,hasContextMeta: null == hasContextMeta ? _self.hasContextMeta : hasContextMeta // ignore: cast_nullable_to_non_nullable
as bool,playwrightAvailable: null == playwrightAvailable ? _self.playwrightAvailable : playwrightAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
