import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/api/endpoints.dart';
import '../../core/models/meta.dart';
import '../../core/session/session_controller.dart';

part 'filter_meta.g.dart';

/// 分区筛选的依据；空表意味着 Q1–Q4 不会生效。
@riverpod
Future<RankTables> rankTables(Ref ref) =>
    ref.watch(apiClientProvider).rankTables();

/// 机构订阅登录态；决定付费全文能不能取到。
@riverpod
Future<PaywallStatus> paywallStatus(Ref ref) =>
    ref.watch(apiClientProvider).paywallStatus();
