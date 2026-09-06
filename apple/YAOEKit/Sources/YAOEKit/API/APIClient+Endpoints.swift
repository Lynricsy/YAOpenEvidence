import Foundation

/// 后端每个端点一个方法。路径不含 `/v1`（由 `APIClient` 拼接）。
public extension APIClient {
    // MARK: - 鉴权与账号

    func login(username: String, password: String) async throws(APIError) -> LoginResponse {
        try await json(Endpoint(
            method: "POST",
            path: "/auth/login",
            body: Self.encode(LoginRequest(username: username, password: password)),
            requiresAuth: false
        ))
    }

    func logout() async throws(APIError) {
        try await noContent(Endpoint(method: "POST", path: "/auth/logout"))
    }

    func me() async throws(APIError) -> UserRead {
        try await json(Endpoint(path: "/auth/me"))
    }

    func changePassword(current: String, new: String) async throws(APIError) {
        try await noContent(Endpoint(
            method: "POST",
            path: "/auth/password",
            body: Self.encode(PasswordChangeRequest(currentPassword: current, newPassword: new))
        ))
    }

    // MARK: - 用户管理（管理员）

    func users(limit: Int = 20, offset: Int = 0) async throws(APIError) -> Page<UserRead> {
        try await json(Endpoint(path: "/users", query: [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset)),
        ]))
    }

    func createUser(username: String, password: String, role: UserRole) async throws(APIError) -> UserRead {
        try await json(Endpoint(
            method: "POST",
            path: "/users",
            body: Self.encode(CreateUserRequest(username: username, password: password, role: role))
        ))
    }

    func updateUser(id: String, isActive: Bool) async throws(APIError) -> UserRead {
        try await json(Endpoint(
            method: "PATCH",
            path: "/users/\(Endpoint.escape(id))",
            body: Self.encode(UserPatch(isActive: isActive))
        ))
    }

    func resetPassword(id: String, newPassword: String) async throws(APIError) {
        try await noContent(Endpoint(
            method: "POST",
            path: "/users/\(Endpoint.escape(id))/password",
            body: Self.encode(PasswordResetRequest(newPassword: newPassword))
        ))
    }

    // MARK: - 问答

    func answers(
        status: AnswerStatus? = nil,
        q: String = "",
        limit: Int = 20,
        offset: Int = 0
    ) async throws(APIError) -> Page<AnswerSummary> {
        var query = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset)),
        ]
        if let status { query.append(URLQueryItem(name: "status", value: status.rawValue)) }
        if !q.isEmpty { query.append(URLQueryItem(name: "q", value: q)) }
        return try await json(Endpoint(path: "/answers", query: query))
    }

    func answer(id: String) async throws(APIError) -> Answer {
        try await json(Endpoint(path: "/answers/\(Endpoint.escape(id))"))
    }

    func createAnswer(_ payload: AnswerCreate) async throws(APIError) -> Answer {
        try await json(Endpoint(method: "POST", path: "/answers", body: Self.encode(payload)))
    }

    func deleteAnswer(id: String) async throws(APIError) {
        try await noContent(Endpoint(method: "DELETE", path: "/answers/\(Endpoint.escape(id))"))
    }

    func answerMarkdown(id: String) async throws(APIError) -> String {
        try await text(Endpoint(path: "/answers/\(Endpoint.escape(id))/markdown"))
    }

    func answerPaper(id: String, n: Int) async throws(APIError) -> AnswerPaperDetail {
        try await json(Endpoint(path: "/answers/\(Endpoint.escape(id))/papers/\(n)"))
    }

    func answerPaperMarkdown(id: String, n: Int) async throws(APIError) -> String {
        try await text(Endpoint(path: "/answers/\(Endpoint.escape(id))/papers/\(n)/markdown"))
    }

    // MARK: - 任务

    func job(id: String) async throws(APIError) -> Job {
        try await json(Endpoint(path: "/jobs/\(Endpoint.escape(id))"))
    }

    func cancelJob(id: String) async throws(APIError) {
        try await noContent(Endpoint(method: "POST", path: "/jobs/\(Endpoint.escape(id))/cancel"))
    }

    // MARK: - 文献库

    func papers(q: String = "", limit: Int = 20, offset: Int = 0) async throws(APIError) -> Page<PaperMeta> {
        var query = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset)),
        ]
        if !q.isEmpty { query.append(URLQueryItem(name: "q", value: q)) }
        return try await json(Endpoint(path: "/papers", query: query))
    }

    func paper(key: String) async throws(APIError) -> PaperMeta {
        try await json(Endpoint(path: "/papers/\(Endpoint.escape(key))"))
    }

    func paperParagraphs(key: String) async throws(APIError) -> ParagraphList {
        try await json(Endpoint(path: "/papers/\(Endpoint.escape(key))/paragraphs"))
    }

    func paperFacts(key: String) async throws(APIError) -> FactList {
        try await json(Endpoint(path: "/papers/\(Endpoint.escape(key))/facts"))
    }

    func paperFulltext(key: String) async throws(APIError) -> String {
        try await text(Endpoint(path: "/papers/\(Endpoint.escape(key))/fulltext"))
    }

    // MARK: - 知识库

    func kbSearch(q: String, kind: KbKind? = nil, topK: Int = 8, pmids: [String] = []) async throws(APIError) -> KbSearchResult {
        var query = [
            URLQueryItem(name: "q", value: q),
            URLQueryItem(name: "top_k", value: String(topK)),
        ]
        if let kind { query.append(URLQueryItem(name: "kind", value: kind.rawValue)) }
        query.append(contentsOf: pmids.map { URLQueryItem(name: "pmid", value: $0) })
        return try await json(Endpoint(path: "/kb/search", query: query))
    }

    func kbStats() async throws(APIError) -> KbStats {
        try await json(Endpoint(path: "/kb/stats"))
    }

    func reindexKb() async throws(APIError) -> Job {
        try await json(Endpoint(method: "POST", path: "/kb/reindex"))
    }

    // MARK: - 期刊分区

    func journalRank(issn: String = "", title: String = "") async throws(APIError) -> RankResult {
        try await json(Endpoint(path: "/journals/rank", query: [
            URLQueryItem(name: "issn", value: issn),
            URLQueryItem(name: "title", value: title),
        ]))
    }

    // MARK: - 上游文献

    func literatureSearch(_ request: LiteratureQuery) async throws(APIError) -> LiteratureSearchResult {
        try await json(Endpoint(path: "/literature/search", query: request.queryItems))
    }

    func literatureFulltext(ident: String, section: String = "", maxChars: Int = 20000) async throws(APIError) -> FulltextResult {
        try await json(Endpoint(path: "/literature/fulltext", query: [
            URLQueryItem(name: "ident", value: ident),
            URLQueryItem(name: "section", value: section),
            URLQueryItem(name: "max_chars", value: String(maxChars)),
        ]))
    }

    func literatureCitations(ident: String, limit: Int = 10) async throws(APIError) -> LiteratureRecordList {
        try await json(Endpoint(path: "/literature/citations", query: Self.identQuery(ident, limit)))
    }

    func literatureReferences(ident: String, limit: Int = 10) async throws(APIError) -> LiteratureRecordList {
        try await json(Endpoint(path: "/literature/references", query: Self.identQuery(ident, limit)))
    }

    func literatureRecommendations(ident: String, limit: Int = 10) async throws(APIError) -> LiteratureRecordList {
        try await json(Endpoint(path: "/literature/recommendations", query: Self.identQuery(ident, limit)))
    }

    // MARK: - 健康检查

    func health() async throws(APIError) -> HealthResponse {
        try await json(Endpoint(path: "/health", requiresAuth: false))
    }

    func ready() async throws(APIError) -> ReadinessResponse {
        try await json(Endpoint(path: "/health/ready", requiresAuth: false))
    }

    // MARK: - 私有工具

    private static func identQuery(_ ident: String, _ limit: Int) -> [URLQueryItem] {
        [URLQueryItem(name: "ident", value: ident), URLQueryItem(name: "limit", value: String(limit))]
    }

    private static func encode(_ value: some Encodable) -> Data {
        // 模型全部是纯值类型，编码不会失败；真失败也只能视为编程错误。
        (try? JSONCoding.encoder.encode(value)) ?? Data("{}".utf8)
    }
}

/// `/v1/literature/search` 的查询参数集合。
public struct LiteratureQuery: Sendable, Hashable {
    public var q: String
    public var source: LiteratureSource
    public var limit: Int
    public var years: Int?
    public var yearFrom: Int?
    public var yearTo: Int?
    public var publicationTypes: [String]
    public var quartiles: [Int]
    public var journals: [String]
    public var openAccessOnly: Bool

    public init(
        q: String,
        source: LiteratureSource = .auto,
        limit: Int = 10,
        years: Int? = nil,
        yearFrom: Int? = nil,
        yearTo: Int? = nil,
        publicationTypes: [String] = [],
        quartiles: [Int] = [],
        journals: [String] = [],
        openAccessOnly: Bool = false
    ) {
        self.q = q
        self.source = source
        self.limit = limit
        self.years = years
        self.yearFrom = yearFrom
        self.yearTo = yearTo
        self.publicationTypes = publicationTypes
        self.quartiles = quartiles
        self.journals = journals
        self.openAccessOnly = openAccessOnly
    }

    public var queryItems: [URLQueryItem] {
        var items = [
            URLQueryItem(name: "q", value: q),
            URLQueryItem(name: "source", value: source.rawValue),
            URLQueryItem(name: "limit", value: String(limit)),
        ]
        if let years { items.append(URLQueryItem(name: "years", value: String(years))) }
        if let yearFrom { items.append(URLQueryItem(name: "year_from", value: String(yearFrom))) }
        if let yearTo { items.append(URLQueryItem(name: "year_to", value: String(yearTo))) }
        items += publicationTypes.map { URLQueryItem(name: "publication_types", value: $0) }
        items += quartiles.map { URLQueryItem(name: "quartiles", value: String($0)) }
        items += journals.map { URLQueryItem(name: "journals", value: $0) }
        if openAccessOnly { items.append(URLQueryItem(name: "open_access_only", value: "true")) }
        return items
    }
}
