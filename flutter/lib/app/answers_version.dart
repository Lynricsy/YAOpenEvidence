import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'answers_version.g.dart';

/// 问答列表版本号。创建/删除答案后 `bump()`，侧栏「最近问答」与历史页
/// `ref.watch` 它以触发重取（避免各页面互相持有 provider 引用）。
@Riverpod(keepAlive: true)
class AnswersVersion extends _$AnswersVersion {
  @override
  int build() => 0;

  void bump() => state++;
}
