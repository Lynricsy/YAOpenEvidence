import 'package:freezed_annotation/freezed_annotation.dart';

part 'meta.freezed.dart';
part 'meta.g.dart';

/// 已加载的一张期刊分区表。`year` 由后端从文件名推断，推不出来为 null。
@freezed
abstract class RankTable with _$RankTable {
  const factory RankTable({
    @Default('') String file,
    int? year,
    @Default(0) int journals,
    @Default('custom') String source,
  }) = _RankTable;

  factory RankTable.fromJson(Map<String, Object?> json) =>
      _$RankTableFromJson(json);
}

/// 分区筛选的依据。`tables` 为空说明 Q1–Q4 过滤不会生效。
@freezed
abstract class RankTables with _$RankTables {
  const factory RankTables({
    @Default(<RankTable>[]) List<RankTable> tables,
    @Default(0) int issns,
    @Default(0) int titles,
    DateTime? loadedAt,
  }) = _RankTables;

  factory RankTables.fromJson(Map<String, Object?> json) =>
      _$RankTablesFromJson(json);
}

/// 机构订阅登录态的只读观测；决定付费全文能不能取到。
@freezed
abstract class PaywallStatus with _$PaywallStatus {
  const factory PaywallStatus({
    @Default(false) bool configured,
    DateTime? savedAt,
    String? finalUrl,
    @Default(false) bool hasSessionStorage,
    @Default(false) bool hasContextMeta,
    @Default(false) bool playwrightAvailable,
  }) = _PaywallStatus;

  factory PaywallStatus.fromJson(Map<String, Object?> json) =>
      _$PaywallStatusFromJson(json);
}
