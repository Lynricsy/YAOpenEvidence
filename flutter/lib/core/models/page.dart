import 'package:freezed_annotation/freezed_annotation.dart';

part 'page.freezed.dart';
part 'page.g.dart';

/// 分页信封：`GET /v1/answers`、`/v1/papers`、`/v1/auth/users` 共用。
@Freezed(genericArgumentFactories: true)
abstract class Page<T> with _$Page<T> {
  const factory Page({
    required List<T> items,
    required int total,
    required int limit,
    required int offset,
  }) = _Page<T>;

  factory Page.fromJson(
    Map<String, Object?> json,
    T Function(Object?) fromJsonT,
  ) => _$PageFromJson(json, fromJsonT);
}
