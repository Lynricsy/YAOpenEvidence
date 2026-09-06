// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserRead _$UserReadFromJson(Map<String, dynamic> json) => _UserRead(
  id: json['id'] as String,
  username: json['username'] as String,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  isActive: json['is_active'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$UserReadToJson(_UserRead instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'role': _$UserRoleEnumMap[instance.role]!,
  'is_active': instance.isActive,
  'created_at': instance.createdAt.toIso8601String(),
};

const _$UserRoleEnumMap = {UserRole.user: 'user', UserRole.admin: 'admin'};

_LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) =>
    _LoginRequest(
      username: json['username'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginRequestToJson(_LoginRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
    };

_LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    _LoginResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      user: UserRead.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginResponseToJson(_LoginResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'token_type': instance.tokenType,
      'expires_at': instance.expiresAt.toIso8601String(),
      'user': instance.user.toJson(),
    };

_PasswordChangeRequest _$PasswordChangeRequestFromJson(
  Map<String, dynamic> json,
) => _PasswordChangeRequest(
  currentPassword: json['current_password'] as String,
  newPassword: json['new_password'] as String,
);

Map<String, dynamic> _$PasswordChangeRequestToJson(
  _PasswordChangeRequest instance,
) => <String, dynamic>{
  'current_password': instance.currentPassword,
  'new_password': instance.newPassword,
};

_PasswordResetRequest _$PasswordResetRequestFromJson(
  Map<String, dynamic> json,
) => _PasswordResetRequest(newPassword: json['new_password'] as String);

Map<String, dynamic> _$PasswordResetRequestToJson(
  _PasswordResetRequest instance,
) => <String, dynamic>{'new_password': instance.newPassword};

_CreateUserRequest _$CreateUserRequestFromJson(Map<String, dynamic> json) =>
    _CreateUserRequest(
      username: json['username'] as String,
      password: json['password'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
    );

Map<String, dynamic> _$CreateUserRequestToJson(_CreateUserRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
      'role': _$UserRoleEnumMap[instance.role]!,
    };

_UserPatch _$UserPatchFromJson(Map<String, dynamic> json) =>
    _UserPatch(isActive: json['is_active'] as bool);

Map<String, dynamic> _$UserPatchToJson(_UserPatch instance) =>
    <String, dynamic>{'is_active': instance.isActive};
