import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth.freezed.dart';
part 'auth.g.dart';

enum UserRole {
  user,
  admin;

  /// 界面文案。
  String get label => switch (this) {
    UserRole.user => '普通用户',
    UserRole.admin => '管理员',
  };
}

@freezed
abstract class UserRead with _$UserRead {
  const factory UserRead({
    required String id,
    required String username,
    required UserRole role,
    required bool isActive,
    required DateTime createdAt,
  }) = _UserRead;

  factory UserRead.fromJson(Map<String, Object?> json) =>
      _$UserReadFromJson(json);
}

@freezed
abstract class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String username,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, Object?> json) =>
      _$LoginRequestFromJson(json);
}

@freezed
abstract class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required String accessToken,
    required String tokenType,
    required DateTime expiresAt,
    required UserRead user,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, Object?> json) =>
      _$LoginResponseFromJson(json);
}

@freezed
abstract class PasswordChangeRequest with _$PasswordChangeRequest {
  const factory PasswordChangeRequest({
    required String currentPassword,
    required String newPassword,
  }) = _PasswordChangeRequest;

  factory PasswordChangeRequest.fromJson(Map<String, Object?> json) =>
      _$PasswordChangeRequestFromJson(json);
}

@freezed
abstract class PasswordResetRequest with _$PasswordResetRequest {
  const factory PasswordResetRequest({required String newPassword}) =
      _PasswordResetRequest;

  factory PasswordResetRequest.fromJson(Map<String, Object?> json) =>
      _$PasswordResetRequestFromJson(json);
}

@freezed
abstract class CreateUserRequest with _$CreateUserRequest {
  const factory CreateUserRequest({
    required String username,
    required String password,
    required UserRole role,
  }) = _CreateUserRequest;

  factory CreateUserRequest.fromJson(Map<String, Object?> json) =>
      _$CreateUserRequestFromJson(json);
}

@freezed
abstract class UserPatch with _$UserPatch {
  const factory UserPatch({required bool isActive}) = _UserPatch;

  factory UserPatch.fromJson(Map<String, Object?> json) =>
      _$UserPatchFromJson(json);
}
