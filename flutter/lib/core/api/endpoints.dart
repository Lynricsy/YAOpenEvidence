import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/answers.dart';
import '../models/auth.dart';
import '../models/health.dart';
import '../models/jobs.dart';
import '../models/kb.dart';
import '../models/literature.dart';
import '../models/meta.dart';
import '../models/page.dart';
import '../models/papers.dart';
import 'api_client.dart';
import 'query_encoding.dart';

part 'endpoints.freezed.dart';

Map<String, Object?> _obj(Object? raw) => raw! as Map<String, Object?>;

/// `{"items": [...]}` 信封直接解析为列表。
List<T> _items<T>(Object? raw, T Function(Map<String, Object?>) fromJson) {
  final items = _obj(raw)['items'];
  if (items is! List) return const [];
  return items
      .map((e) => fromJson(e! as Map<String, Object?>))
      .toList(growable: false);
}

Page<T> _page<T>(Object? raw, T Function(Map<String, Object?>) fromJson) =>
    Page<T>.fromJson(_obj(raw), (e) => fromJson(e! as Map<String, Object?>));

/// 后端每个端点一个方法。路径不含 `/v1`（由 [ApiClient] 拼接）。
extension YaoeEndpoints on ApiClient {
  // MARK: 鉴权与账号

  Future<LoginResponse> login({
    required String username,
    required String password,
  }) => json(
    ApiRequest(
      method: 'POST',
      path: '/auth/login',
      body: LoginRequest(username: username, password: password).toJson(),
      requiresAuth: false,
    ),
    (raw) => LoginResponse.fromJson(_obj(raw)),
  );

  Future<void> logout() =>
      noContent(const ApiRequest(method: 'POST', path: '/auth/logout'));

  Future<UserRead> me() => json(
    const ApiRequest(path: '/auth/me'),
    (raw) => UserRead.fromJson(_obj(raw)),
  );

  Future<void> changePassword({
    required String current,
    required String newPassword,
  }) => noContent(
    ApiRequest(
      method: 'POST',
      path: '/auth/password',
      body: PasswordChangeRequest(
        currentPassword: current,
        newPassword: newPassword,
      ).toJson(),
    ),
  );

  // MARK: 用户管理（管理员）

  Future<Page<UserRead>> users({int limit = 20, int offset = 0}) => json(
    ApiRequest(path: '/users', query: {'limit': limit, 'offset': offset}),
    (raw) => _page(raw, UserRead.fromJson),
  );

  Future<UserRead> createUser({
    required String username,
    required String password,
    required UserRole role,
  }) => json(
    ApiRequest(
      method: 'POST',
      path: '/users',
      body: CreateUserRequest(
        username: username,
        password: password,
        role: role,
      ).toJson(),
    ),
    (raw) => UserRead.fromJson(_obj(raw)),
  );

  Future<UserRead> updateUser({
    required String id,
    required bool isActive,
  }) => json(
    ApiRequest(
      method: 'PATCH',
      path: '/users/${encodePathComponent(id)}',
      body: UserPatch(isActive: isActive).toJson(),
    ),
    (raw) => UserRead.fromJson(_obj(raw)),
  );

  Future<void> resetPassword({
    required String id,
    required String newPassword,
  }) => noContent(
    ApiRequest(
      method: 'POST',
      path: '/users/${encodePathComponent(id)}/password',
      body: PasswordResetRequest(newPassword: newPassword).toJson(),
    ),
  );

  // MARK: 问答

  Future<Page<AnswerSummary>> answers({
    AnswerStatus? status,
    String q = '',
    int limit = 20,
    int offset = 0,
  }) => json(
    ApiRequest(
      path: '/answers',
      query: {
        'limit': limit,
        'offset': offset,
        if (status != null) 'status': status.name,
        if (q.isNotEmpty) 'q': q,
      },
    ),
    (raw) => _page(raw, AnswerSummary.fromJson),
  );

  Future<Answer> answer(String id) => json(
    ApiRequest(path: '/answers/${encodePathComponent(id)}'),
    (raw) => Answer.fromJson(_obj(raw)),
  );

  Future<Answer> createAnswer(AnswerCreate payload) => json(
    ApiRequest(method: 'POST', path: '/answers', body: payload.toJson()),
    (raw) => Answer.fromJson(_obj(raw)),
  );

  /// 在智能体会话上追问：新建一轮答案，续接同一 codex thread。
  Future<Answer> followUp(String id, FollowupCreate payload) => json(
    ApiRequest(
      method: 'POST',
      path: '/answers/${encodePathComponent(id)}/followup',
      body: payload.toJson(),
    ),
    (raw) => Answer.fromJson(_obj(raw)),
  );

  /// 同一会话的全部回合，按创建时间升序。
  Future<List<AnswerSummary>> answerThread(String id) => json(
    ApiRequest(path: '/answers/${encodePathComponent(id)}/thread'),
    (raw) => (raw! as List)
        .map((e) => AnswerSummary.fromJson(_obj(e)))
        .toList(growable: false),
  );

  Future<void> deleteAnswer(String id) => noContent(
    ApiRequest(method: 'DELETE', path: '/answers/${encodePathComponent(id)}'),
  );

  Future<String> answerMarkdown(String id) =>
      text(ApiRequest(path: '/answers/${encodePathComponent(id)}/markdown'));

  Future<Download> answerPdf(String id) => download(
    ApiRequest(path: '/answers/${encodePathComponent(id)}/pdf'),
    accept: 'application/pdf',
  );

  Future<AnswerPaperDetail> answerPaper({
    required String id,
    required int n,
  }) => json(
    ApiRequest(path: '/answers/${encodePathComponent(id)}/papers/$n'),
    (raw) => AnswerPaperDetail.fromJson(_obj(raw)),
  );

  Future<String> answerPaperMarkdown({required String id, required int n}) =>
      text(
        ApiRequest(
          path: '/answers/${encodePathComponent(id)}/papers/$n/markdown',
        ),
      );

  // MARK: 任务

  Future<Job> job(String id) => json(
    ApiRequest(path: '/jobs/${encodePathComponent(id)}'),
    (raw) => Job.fromJson(_obj(raw)),
  );

  Future<void> cancelJob(String id) => noContent(
    ApiRequest(
      method: 'POST',
      path: '/jobs/${encodePathComponent(id)}/cancel',
    ),
  );

  // MARK: 文献库

  Future<Page<PaperMeta>> papers({
    String q = '',
    int limit = 20,
    int offset = 0,
  }) => json(
    ApiRequest(
      path: '/papers',
      query: {'limit': limit, 'offset': offset, if (q.isNotEmpty) 'q': q},
    ),
    (raw) => _page(raw, PaperMeta.fromJson),
  );

  Future<PaperMeta> paper(String key) => json(
    ApiRequest(path: '/papers/${encodePathComponent(key)}'),
    (raw) => PaperMeta.fromJson(_obj(raw)),
  );

  Future<List<Paragraph>> paperParagraphs(String key) => json(
    ApiRequest(path: '/papers/${encodePathComponent(key)}/paragraphs'),
    (raw) => _items(raw, Paragraph.fromJson),
  );

  Future<List<Fact>> paperFacts(String key) => json(
    ApiRequest(path: '/papers/${encodePathComponent(key)}/facts'),
    (raw) => _items(raw, Fact.fromJson),
  );

  Future<String> paperFulltext(String key) =>
      text(ApiRequest(path: '/papers/${encodePathComponent(key)}/fulltext'));

  // MARK: 知识库

  Future<KbSearchResult> kbSearch({
    required String q,
    KbKind? kind,
    int topK = 8,
    List<String> pmids = const [],
  }) => json(
    ApiRequest(
      path: '/kb/search',
      query: {
        'q': q,
        'top_k': topK,
        if (kind != null) 'kind': kind.name,
        if (pmids.isNotEmpty) 'pmid': pmids,
      },
    ),
    (raw) => KbSearchResult.fromJson(_obj(raw)),
  );

  Future<KbStats> kbStats() => json(
    const ApiRequest(path: '/kb/stats'),
    (raw) => KbStats.fromJson(_obj(raw)),
  );

  Future<Job> reindexKb() => json(
    const ApiRequest(method: 'POST', path: '/kb/reindex'),
    (raw) => Job.fromJson(_obj(raw)),
  );

  // MARK: 期刊分区

  Future<RankResult> journalRank({String issn = '', String title = ''}) => json(
    ApiRequest(
      path: '/journals/rank',
      query: {'issn': issn, 'title': title},
    ),
    (raw) => RankResult.fromJson(_obj(raw)),
  );

  Future<RankTables> rankTables() => json(
    const ApiRequest(path: '/journals/tables'),
    (raw) => RankTables.fromJson(_obj(raw)),
  );

  // MARK: 机构访问

  Future<PaywallStatus> paywallStatus() => json(
    const ApiRequest(path: '/paywall/status'),
    (raw) => PaywallStatus.fromJson(_obj(raw)),
  );

  // MARK: 上游文献

  Future<LiteratureSearchResult> literatureSearch(LiteratureQuery query) =>
      json(
        ApiRequest(path: '/literature/search', query: query.queryParams),
        (raw) => LiteratureSearchResult.fromJson(_obj(raw)),
      );

  Future<FulltextResult> literatureFulltext({
    required String ident,
    String section = '',
    int maxChars = 20000,
  }) => json(
    ApiRequest(
      path: '/literature/fulltext',
      query: {'ident': ident, 'section': section, 'max_chars': maxChars},
    ),
    (raw) => FulltextResult.fromJson(_obj(raw)),
  );

  Future<List<LiteratureRecord>> literatureCitations({
    required String ident,
    int limit = 10,
  }) => json(
    ApiRequest(
      path: '/literature/citations',
      query: {'ident': ident, 'limit': limit},
    ),
    (raw) => _items(raw, LiteratureRecord.fromJson),
  );

  Future<List<LiteratureRecord>> literatureReferences({
    required String ident,
    int limit = 10,
  }) => json(
    ApiRequest(
      path: '/literature/references',
      query: {'ident': ident, 'limit': limit},
    ),
    (raw) => _items(raw, LiteratureRecord.fromJson),
  );

  Future<List<LiteratureRecord>> literatureRecommendations({
    required String ident,
    int limit = 10,
  }) => json(
    ApiRequest(
      path: '/literature/recommendations',
      query: {'ident': ident, 'limit': limit},
    ),
    (raw) => _items(raw, LiteratureRecord.fromJson),
  );

  // MARK: 健康检查

  Future<HealthResponse> health() => json(
    const ApiRequest(path: '/health', requiresAuth: false),
    (raw) => HealthResponse.fromJson(_obj(raw)),
  );

  /// 就绪探针是唯一「非 2xx 也返回业务模型」的端点：503 仍是 [ReadinessResponse]，
  /// 里面才有各依赖的失败原因，不能当成 Problem 丢掉。
  Future<ReadinessResponse> ready() => json(
    const ApiRequest(
      path: '/health/ready',
      requiresAuth: false,
      acceptStatuses: {503},
    ),
    (raw) => ReadinessResponse.fromJson(_obj(raw)),
  );
}

/// `/v1/literature/search` 的查询参数集合。
@freezed
abstract class LiteratureQuery with _$LiteratureQuery {
  const LiteratureQuery._();

  const factory LiteratureQuery({
    required String q,
    @Default(LiteratureSource.auto) LiteratureSource source,
    @Default(10) int limit,
    int? years,
    int? yearFrom,
    int? yearTo,
    @Default(<String>[]) List<String> publicationTypes,
    @Default(<int>[]) List<int> quartiles,
    @Default(<String>[]) List<String> journals,
    @Default(false) bool openAccessOnly,
  }) = _LiteratureQuery;

  Map<String, Object?> get queryParams => {
    'q': q,
    'source': source.name,
    'limit': limit,
    if (years != null) 'years': years,
    if (yearFrom != null) 'year_from': yearFrom,
    if (yearTo != null) 'year_to': yearTo,
    if (publicationTypes.isNotEmpty) 'publication_types': publicationTypes,
    if (quartiles.isNotEmpty) 'quartiles': quartiles,
    if (journals.isNotEmpty) 'journals': journals,
    if (openAccessOnly) 'open_access_only': 'true',
  };
}
