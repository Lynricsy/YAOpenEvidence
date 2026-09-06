// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserRead {

 String get id; String get username; UserRole get role; bool get isActive; DateTime get createdAt;
/// Create a copy of UserRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserReadCopyWith<UserRead> get copyWith => _$UserReadCopyWithImpl<UserRead>(this as UserRead, _$identity);

  /// Serializes this UserRead to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UserRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserRead&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UserRead;
  return Object.hash(runtimeType,_this.id,_this.username,_this.role,_this.isActive,_this.createdAt);
}

@override
String toString() {
  final _this = this as UserRead;
  return 'UserRead(id: ${_this.id}, username: ${_this.username}, role: ${_this.role}, isActive: ${_this.isActive}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $UserReadCopyWith<$Res>  {
  factory $UserReadCopyWith(UserRead value, $Res Function(UserRead) _then) = _$UserReadCopyWithImpl;
@useResult
$Res call({
 String id, String username, UserRole role, bool isActive, DateTime createdAt
});




}
/// @nodoc
class _$UserReadCopyWithImpl<$Res>
    implements $UserReadCopyWith<$Res> {
  _$UserReadCopyWithImpl(this._self, this._then);

  final UserRead _self;
  final $Res Function(UserRead) _then;

/// Create a copy of UserRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? role = null,Object? isActive = null,Object? createdAt = null,}) {
  return _then(UserRead(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [UserRead].
extension UserReadPatterns on UserRead {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserRead value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserRead() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserRead value)  $default,){
final _that = this;
switch (_that) {
case _UserRead():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserRead value)?  $default,){
final _that = this;
switch (_that) {
case _UserRead() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username,  UserRole role,  bool isActive,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserRead() when $default != null:
return $default(_that.id,_that.username,_that.role,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username,  UserRole role,  bool isActive,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _UserRead():
return $default(_that.id,_that.username,_that.role,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username,  UserRole role,  bool isActive,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _UserRead() when $default != null:
return $default(_that.id,_that.username,_that.role,_that.isActive,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserRead implements UserRead {
  const _UserRead({required this.id, required this.username, required this.role, required this.isActive, required this.createdAt});
  factory _UserRead.fromJson(Map<String, dynamic> json) => _$UserReadFromJson(json);

@override final  String id;
@override final  String username;
@override final  UserRole role;
@override final  bool isActive;
@override final  DateTime createdAt;

/// Create a copy of UserRead
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserReadCopyWith<_UserRead> get copyWith => __$UserReadCopyWithImpl<_UserRead>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserReadToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserRead&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.role, role) || other.role == role)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,username,role,isActive,createdAt);
}

@override
String toString() {
    return 'UserRead(id: $id, username: $username, role: $role, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$UserReadCopyWith<$Res> implements $UserReadCopyWith<$Res> {
  factory _$UserReadCopyWith(_UserRead value, $Res Function(_UserRead) _then) = __$UserReadCopyWithImpl;
@override @useResult
$Res call({
 String id, String username, UserRole role, bool isActive, DateTime createdAt
});




}
/// @nodoc
class __$UserReadCopyWithImpl<$Res>
    implements _$UserReadCopyWith<$Res> {
  __$UserReadCopyWithImpl(this._self, this._then);

  final _UserRead _self;
  final $Res Function(_UserRead) _then;

/// Create a copy of UserRead
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? role = null,Object? isActive = null,Object? createdAt = null,}) {
  return _then(_UserRead(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$LoginRequest {

 String get username; String get password;
/// Create a copy of LoginRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginRequestCopyWith<LoginRequest> get copyWith => _$LoginRequestCopyWithImpl<LoginRequest>(this as LoginRequest, _$identity);

  /// Serializes this LoginRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LoginRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginRequest&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.password, _this.password) || other.password == _this.password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LoginRequest;
  return Object.hash(runtimeType,_this.username,_this.password);
}

@override
String toString() {
  final _this = this as LoginRequest;
  return 'LoginRequest(username: ${_this.username}, password: ${_this.password})';
}


}

/// @nodoc
abstract mixin class $LoginRequestCopyWith<$Res>  {
  factory $LoginRequestCopyWith(LoginRequest value, $Res Function(LoginRequest) _then) = _$LoginRequestCopyWithImpl;
@useResult
$Res call({
 String username, String password
});




}
/// @nodoc
class _$LoginRequestCopyWithImpl<$Res>
    implements $LoginRequestCopyWith<$Res> {
  _$LoginRequestCopyWithImpl(this._self, this._then);

  final LoginRequest _self;
  final $Res Function(LoginRequest) _then;

/// Create a copy of LoginRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? username = null,Object? password = null,}) {
  return _then(LoginRequest(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginRequest].
extension LoginRequestPatterns on LoginRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginRequest value)  $default,){
final _that = this;
switch (_that) {
case _LoginRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginRequest value)?  $default,){
final _that = this;
switch (_that) {
case _LoginRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String username,  String password)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginRequest() when $default != null:
return $default(_that.username,_that.password);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String username,  String password)  $default,) {final _that = this;
switch (_that) {
case _LoginRequest():
return $default(_that.username,_that.password);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String username,  String password)?  $default,) {final _that = this;
switch (_that) {
case _LoginRequest() when $default != null:
return $default(_that.username,_that.password);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoginRequest implements LoginRequest {
  const _LoginRequest({required this.username, required this.password});
  factory _LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);

@override final  String username;
@override final  String password;

/// Create a copy of LoginRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginRequestCopyWith<_LoginRequest> get copyWith => __$LoginRequestCopyWithImpl<_LoginRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoginRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginRequest&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,username,password);
}

@override
String toString() {
    return 'LoginRequest(username: $username, password: $password)';
}


}

/// @nodoc
abstract mixin class _$LoginRequestCopyWith<$Res> implements $LoginRequestCopyWith<$Res> {
  factory _$LoginRequestCopyWith(_LoginRequest value, $Res Function(_LoginRequest) _then) = __$LoginRequestCopyWithImpl;
@override @useResult
$Res call({
 String username, String password
});




}
/// @nodoc
class __$LoginRequestCopyWithImpl<$Res>
    implements _$LoginRequestCopyWith<$Res> {
  __$LoginRequestCopyWithImpl(this._self, this._then);

  final _LoginRequest _self;
  final $Res Function(_LoginRequest) _then;

/// Create a copy of LoginRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? username = null,Object? password = null,}) {
  return _then(_LoginRequest(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$LoginResponse {

 String get accessToken; String get tokenType; DateTime get expiresAt; UserRead get user;
/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginResponseCopyWith<LoginResponse> get copyWith => _$LoginResponseCopyWithImpl<LoginResponse>(this as LoginResponse, _$identity);

  /// Serializes this LoginResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LoginResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginResponse&&(identical(other.accessToken, _this.accessToken) || other.accessToken == _this.accessToken)&&(identical(other.tokenType, _this.tokenType) || other.tokenType == _this.tokenType)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.user, _this.user) || other.user == _this.user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LoginResponse;
  return Object.hash(runtimeType,_this.accessToken,_this.tokenType,_this.expiresAt,_this.user);
}

@override
String toString() {
  final _this = this as LoginResponse;
  return 'LoginResponse(accessToken: ${_this.accessToken}, tokenType: ${_this.tokenType}, expiresAt: ${_this.expiresAt}, user: ${_this.user})';
}


}

/// @nodoc
abstract mixin class $LoginResponseCopyWith<$Res>  {
  factory $LoginResponseCopyWith(LoginResponse value, $Res Function(LoginResponse) _then) = _$LoginResponseCopyWithImpl;
@useResult
$Res call({
 String accessToken, String tokenType, DateTime expiresAt, UserRead user
});


$UserReadCopyWith<$Res> get user;

}
/// @nodoc
class _$LoginResponseCopyWithImpl<$Res>
    implements $LoginResponseCopyWith<$Res> {
  _$LoginResponseCopyWithImpl(this._self, this._then);

  final LoginResponse _self;
  final $Res Function(LoginResponse) _then;

/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accessToken = null,Object? tokenType = null,Object? expiresAt = null,Object? user = null,}) {
  return _then(LoginResponse(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,tokenType: null == tokenType ? _self.tokenType : tokenType // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserRead,
  ));
}
/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserReadCopyWith<$Res> get user {
  
  return $UserReadCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [LoginResponse].
extension LoginResponsePatterns on LoginResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginResponse value)  $default,){
final _that = this;
switch (_that) {
case _LoginResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginResponse value)?  $default,){
final _that = this;
switch (_that) {
case _LoginResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String accessToken,  String tokenType,  DateTime expiresAt,  UserRead user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginResponse() when $default != null:
return $default(_that.accessToken,_that.tokenType,_that.expiresAt,_that.user);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String accessToken,  String tokenType,  DateTime expiresAt,  UserRead user)  $default,) {final _that = this;
switch (_that) {
case _LoginResponse():
return $default(_that.accessToken,_that.tokenType,_that.expiresAt,_that.user);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String accessToken,  String tokenType,  DateTime expiresAt,  UserRead user)?  $default,) {final _that = this;
switch (_that) {
case _LoginResponse() when $default != null:
return $default(_that.accessToken,_that.tokenType,_that.expiresAt,_that.user);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoginResponse implements LoginResponse {
  const _LoginResponse({required this.accessToken, required this.tokenType, required this.expiresAt, required this.user});
  factory _LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);

@override final  String accessToken;
@override final  String tokenType;
@override final  DateTime expiresAt;
@override final  UserRead user;

/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginResponseCopyWith<_LoginResponse> get copyWith => __$LoginResponseCopyWithImpl<_LoginResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoginResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginResponse&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.tokenType, tokenType) || other.tokenType == tokenType)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,accessToken,tokenType,expiresAt,user);
}

@override
String toString() {
    return 'LoginResponse(accessToken: $accessToken, tokenType: $tokenType, expiresAt: $expiresAt, user: $user)';
}


}

/// @nodoc
abstract mixin class _$LoginResponseCopyWith<$Res> implements $LoginResponseCopyWith<$Res> {
  factory _$LoginResponseCopyWith(_LoginResponse value, $Res Function(_LoginResponse) _then) = __$LoginResponseCopyWithImpl;
@override @useResult
$Res call({
 String accessToken, String tokenType, DateTime expiresAt, UserRead user
});


@override $UserReadCopyWith<$Res> get user;

}
/// @nodoc
class __$LoginResponseCopyWithImpl<$Res>
    implements _$LoginResponseCopyWith<$Res> {
  __$LoginResponseCopyWithImpl(this._self, this._then);

  final _LoginResponse _self;
  final $Res Function(_LoginResponse) _then;

/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accessToken = null,Object? tokenType = null,Object? expiresAt = null,Object? user = null,}) {
  return _then(_LoginResponse(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,tokenType: null == tokenType ? _self.tokenType : tokenType // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserRead,
  ));
}

/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserReadCopyWith<$Res> get user {
  
  return $UserReadCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// @nodoc
mixin _$PasswordChangeRequest {

 String get currentPassword; String get newPassword;
/// Create a copy of PasswordChangeRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordChangeRequestCopyWith<PasswordChangeRequest> get copyWith => _$PasswordChangeRequestCopyWithImpl<PasswordChangeRequest>(this as PasswordChangeRequest, _$identity);

  /// Serializes this PasswordChangeRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PasswordChangeRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordChangeRequest&&(identical(other.currentPassword, _this.currentPassword) || other.currentPassword == _this.currentPassword)&&(identical(other.newPassword, _this.newPassword) || other.newPassword == _this.newPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PasswordChangeRequest;
  return Object.hash(runtimeType,_this.currentPassword,_this.newPassword);
}

@override
String toString() {
  final _this = this as PasswordChangeRequest;
  return 'PasswordChangeRequest(currentPassword: ${_this.currentPassword}, newPassword: ${_this.newPassword})';
}


}

/// @nodoc
abstract mixin class $PasswordChangeRequestCopyWith<$Res>  {
  factory $PasswordChangeRequestCopyWith(PasswordChangeRequest value, $Res Function(PasswordChangeRequest) _then) = _$PasswordChangeRequestCopyWithImpl;
@useResult
$Res call({
 String currentPassword, String newPassword
});




}
/// @nodoc
class _$PasswordChangeRequestCopyWithImpl<$Res>
    implements $PasswordChangeRequestCopyWith<$Res> {
  _$PasswordChangeRequestCopyWithImpl(this._self, this._then);

  final PasswordChangeRequest _self;
  final $Res Function(PasswordChangeRequest) _then;

/// Create a copy of PasswordChangeRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentPassword = null,Object? newPassword = null,}) {
  return _then(PasswordChangeRequest(
currentPassword: null == currentPassword ? _self.currentPassword : currentPassword // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PasswordChangeRequest].
extension PasswordChangeRequestPatterns on PasswordChangeRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PasswordChangeRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PasswordChangeRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PasswordChangeRequest value)  $default,){
final _that = this;
switch (_that) {
case _PasswordChangeRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PasswordChangeRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PasswordChangeRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String currentPassword,  String newPassword)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PasswordChangeRequest() when $default != null:
return $default(_that.currentPassword,_that.newPassword);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String currentPassword,  String newPassword)  $default,) {final _that = this;
switch (_that) {
case _PasswordChangeRequest():
return $default(_that.currentPassword,_that.newPassword);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String currentPassword,  String newPassword)?  $default,) {final _that = this;
switch (_that) {
case _PasswordChangeRequest() when $default != null:
return $default(_that.currentPassword,_that.newPassword);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PasswordChangeRequest implements PasswordChangeRequest {
  const _PasswordChangeRequest({required this.currentPassword, required this.newPassword});
  factory _PasswordChangeRequest.fromJson(Map<String, dynamic> json) => _$PasswordChangeRequestFromJson(json);

@override final  String currentPassword;
@override final  String newPassword;

/// Create a copy of PasswordChangeRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PasswordChangeRequestCopyWith<_PasswordChangeRequest> get copyWith => __$PasswordChangeRequestCopyWithImpl<_PasswordChangeRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PasswordChangeRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PasswordChangeRequest&&(identical(other.currentPassword, currentPassword) || other.currentPassword == currentPassword)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,currentPassword,newPassword);
}

@override
String toString() {
    return 'PasswordChangeRequest(currentPassword: $currentPassword, newPassword: $newPassword)';
}


}

/// @nodoc
abstract mixin class _$PasswordChangeRequestCopyWith<$Res> implements $PasswordChangeRequestCopyWith<$Res> {
  factory _$PasswordChangeRequestCopyWith(_PasswordChangeRequest value, $Res Function(_PasswordChangeRequest) _then) = __$PasswordChangeRequestCopyWithImpl;
@override @useResult
$Res call({
 String currentPassword, String newPassword
});




}
/// @nodoc
class __$PasswordChangeRequestCopyWithImpl<$Res>
    implements _$PasswordChangeRequestCopyWith<$Res> {
  __$PasswordChangeRequestCopyWithImpl(this._self, this._then);

  final _PasswordChangeRequest _self;
  final $Res Function(_PasswordChangeRequest) _then;

/// Create a copy of PasswordChangeRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentPassword = null,Object? newPassword = null,}) {
  return _then(_PasswordChangeRequest(
currentPassword: null == currentPassword ? _self.currentPassword : currentPassword // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PasswordResetRequest {

 String get newPassword;
/// Create a copy of PasswordResetRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordResetRequestCopyWith<PasswordResetRequest> get copyWith => _$PasswordResetRequestCopyWithImpl<PasswordResetRequest>(this as PasswordResetRequest, _$identity);

  /// Serializes this PasswordResetRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PasswordResetRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordResetRequest&&(identical(other.newPassword, _this.newPassword) || other.newPassword == _this.newPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PasswordResetRequest;
  return Object.hash(runtimeType,_this.newPassword);
}

@override
String toString() {
  final _this = this as PasswordResetRequest;
  return 'PasswordResetRequest(newPassword: ${_this.newPassword})';
}


}

/// @nodoc
abstract mixin class $PasswordResetRequestCopyWith<$Res>  {
  factory $PasswordResetRequestCopyWith(PasswordResetRequest value, $Res Function(PasswordResetRequest) _then) = _$PasswordResetRequestCopyWithImpl;
@useResult
$Res call({
 String newPassword
});




}
/// @nodoc
class _$PasswordResetRequestCopyWithImpl<$Res>
    implements $PasswordResetRequestCopyWith<$Res> {
  _$PasswordResetRequestCopyWithImpl(this._self, this._then);

  final PasswordResetRequest _self;
  final $Res Function(PasswordResetRequest) _then;

/// Create a copy of PasswordResetRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? newPassword = null,}) {
  return _then(PasswordResetRequest(
newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PasswordResetRequest].
extension PasswordResetRequestPatterns on PasswordResetRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PasswordResetRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PasswordResetRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PasswordResetRequest value)  $default,){
final _that = this;
switch (_that) {
case _PasswordResetRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PasswordResetRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PasswordResetRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String newPassword)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PasswordResetRequest() when $default != null:
return $default(_that.newPassword);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String newPassword)  $default,) {final _that = this;
switch (_that) {
case _PasswordResetRequest():
return $default(_that.newPassword);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String newPassword)?  $default,) {final _that = this;
switch (_that) {
case _PasswordResetRequest() when $default != null:
return $default(_that.newPassword);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PasswordResetRequest implements PasswordResetRequest {
  const _PasswordResetRequest({required this.newPassword});
  factory _PasswordResetRequest.fromJson(Map<String, dynamic> json) => _$PasswordResetRequestFromJson(json);

@override final  String newPassword;

/// Create a copy of PasswordResetRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PasswordResetRequestCopyWith<_PasswordResetRequest> get copyWith => __$PasswordResetRequestCopyWithImpl<_PasswordResetRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PasswordResetRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PasswordResetRequest&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,newPassword);
}

@override
String toString() {
    return 'PasswordResetRequest(newPassword: $newPassword)';
}


}

/// @nodoc
abstract mixin class _$PasswordResetRequestCopyWith<$Res> implements $PasswordResetRequestCopyWith<$Res> {
  factory _$PasswordResetRequestCopyWith(_PasswordResetRequest value, $Res Function(_PasswordResetRequest) _then) = __$PasswordResetRequestCopyWithImpl;
@override @useResult
$Res call({
 String newPassword
});




}
/// @nodoc
class __$PasswordResetRequestCopyWithImpl<$Res>
    implements _$PasswordResetRequestCopyWith<$Res> {
  __$PasswordResetRequestCopyWithImpl(this._self, this._then);

  final _PasswordResetRequest _self;
  final $Res Function(_PasswordResetRequest) _then;

/// Create a copy of PasswordResetRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? newPassword = null,}) {
  return _then(_PasswordResetRequest(
newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CreateUserRequest {

 String get username; String get password; UserRole get role;
/// Create a copy of CreateUserRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateUserRequestCopyWith<CreateUserRequest> get copyWith => _$CreateUserRequestCopyWithImpl<CreateUserRequest>(this as CreateUserRequest, _$identity);

  /// Serializes this CreateUserRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateUserRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateUserRequest&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.role, _this.role) || other.role == _this.role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateUserRequest;
  return Object.hash(runtimeType,_this.username,_this.password,_this.role);
}

@override
String toString() {
  final _this = this as CreateUserRequest;
  return 'CreateUserRequest(username: ${_this.username}, password: ${_this.password}, role: ${_this.role})';
}


}

/// @nodoc
abstract mixin class $CreateUserRequestCopyWith<$Res>  {
  factory $CreateUserRequestCopyWith(CreateUserRequest value, $Res Function(CreateUserRequest) _then) = _$CreateUserRequestCopyWithImpl;
@useResult
$Res call({
 String username, String password, UserRole role
});




}
/// @nodoc
class _$CreateUserRequestCopyWithImpl<$Res>
    implements $CreateUserRequestCopyWith<$Res> {
  _$CreateUserRequestCopyWithImpl(this._self, this._then);

  final CreateUserRequest _self;
  final $Res Function(CreateUserRequest) _then;

/// Create a copy of CreateUserRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? username = null,Object? password = null,Object? role = null,}) {
  return _then(CreateUserRequest(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateUserRequest].
extension CreateUserRequestPatterns on CreateUserRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateUserRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateUserRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateUserRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateUserRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateUserRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateUserRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String username,  String password,  UserRole role)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateUserRequest() when $default != null:
return $default(_that.username,_that.password,_that.role);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String username,  String password,  UserRole role)  $default,) {final _that = this;
switch (_that) {
case _CreateUserRequest():
return $default(_that.username,_that.password,_that.role);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String username,  String password,  UserRole role)?  $default,) {final _that = this;
switch (_that) {
case _CreateUserRequest() when $default != null:
return $default(_that.username,_that.password,_that.role);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateUserRequest implements CreateUserRequest {
  const _CreateUserRequest({required this.username, required this.password, required this.role});
  factory _CreateUserRequest.fromJson(Map<String, dynamic> json) => _$CreateUserRequestFromJson(json);

@override final  String username;
@override final  String password;
@override final  UserRole role;

/// Create a copy of CreateUserRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateUserRequestCopyWith<_CreateUserRequest> get copyWith => __$CreateUserRequestCopyWithImpl<_CreateUserRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateUserRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateUserRequest&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,username,password,role);
}

@override
String toString() {
    return 'CreateUserRequest(username: $username, password: $password, role: $role)';
}


}

/// @nodoc
abstract mixin class _$CreateUserRequestCopyWith<$Res> implements $CreateUserRequestCopyWith<$Res> {
  factory _$CreateUserRequestCopyWith(_CreateUserRequest value, $Res Function(_CreateUserRequest) _then) = __$CreateUserRequestCopyWithImpl;
@override @useResult
$Res call({
 String username, String password, UserRole role
});




}
/// @nodoc
class __$CreateUserRequestCopyWithImpl<$Res>
    implements _$CreateUserRequestCopyWith<$Res> {
  __$CreateUserRequestCopyWithImpl(this._self, this._then);

  final _CreateUserRequest _self;
  final $Res Function(_CreateUserRequest) _then;

/// Create a copy of CreateUserRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? username = null,Object? password = null,Object? role = null,}) {
  return _then(_CreateUserRequest(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,
  ));
}


}


/// @nodoc
mixin _$UserPatch {

 bool get isActive;
/// Create a copy of UserPatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserPatchCopyWith<UserPatch> get copyWith => _$UserPatchCopyWithImpl<UserPatch>(this as UserPatch, _$identity);

  /// Serializes this UserPatch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UserPatch;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserPatch&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UserPatch;
  return Object.hash(runtimeType,_this.isActive);
}

@override
String toString() {
  final _this = this as UserPatch;
  return 'UserPatch(isActive: ${_this.isActive})';
}


}

/// @nodoc
abstract mixin class $UserPatchCopyWith<$Res>  {
  factory $UserPatchCopyWith(UserPatch value, $Res Function(UserPatch) _then) = _$UserPatchCopyWithImpl;
@useResult
$Res call({
 bool isActive
});




}
/// @nodoc
class _$UserPatchCopyWithImpl<$Res>
    implements $UserPatchCopyWith<$Res> {
  _$UserPatchCopyWithImpl(this._self, this._then);

  final UserPatch _self;
  final $Res Function(UserPatch) _then;

/// Create a copy of UserPatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isActive = null,}) {
  return _then(UserPatch(
isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UserPatch].
extension UserPatchPatterns on UserPatch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserPatch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserPatch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserPatch value)  $default,){
final _that = this;
switch (_that) {
case _UserPatch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserPatch value)?  $default,){
final _that = this;
switch (_that) {
case _UserPatch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserPatch() when $default != null:
return $default(_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isActive)  $default,) {final _that = this;
switch (_that) {
case _UserPatch():
return $default(_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _UserPatch() when $default != null:
return $default(_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserPatch implements UserPatch {
  const _UserPatch({required this.isActive});
  factory _UserPatch.fromJson(Map<String, dynamic> json) => _$UserPatchFromJson(json);

@override final  bool isActive;

/// Create a copy of UserPatch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserPatchCopyWith<_UserPatch> get copyWith => __$UserPatchCopyWithImpl<_UserPatch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserPatchToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserPatch&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,isActive);
}

@override
String toString() {
    return 'UserPatch(isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$UserPatchCopyWith<$Res> implements $UserPatchCopyWith<$Res> {
  factory _$UserPatchCopyWith(_UserPatch value, $Res Function(_UserPatch) _then) = __$UserPatchCopyWithImpl;
@override @useResult
$Res call({
 bool isActive
});




}
/// @nodoc
class __$UserPatchCopyWithImpl<$Res>
    implements _$UserPatchCopyWith<$Res> {
  __$UserPatchCopyWithImpl(this._self, this._then);

  final _UserPatch _self;
  final $Res Function(_UserPatch) _then;

/// Create a copy of UserPatch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isActive = null,}) {
  return _then(_UserPatch(
isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
