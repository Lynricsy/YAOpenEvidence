# YAOpenEvidence API v1 协议

本文面向浏览器前端、其他客户端与公开 API 用户，描述 YAOpenEvidence 当前实现的 HTTP wire contract。端点与模型的机器可读定义以仓库中的 [`backend/openapi.json`](../backend/openapi.json) 为准。

## 1. 通用约定

### 1.1 基础路径与接口描述

- API base path：`/v1`
- OpenAPI JSON：`GET /v1/openapi.json`
- Swagger UI：`GET /v1/docs`
- ReDoc：`GET /v1/redoc`
- 下文示例使用服务地址 `http://localhost:8765`。

健康检查与上述接口描述入口免鉴权；其余 `/v1` 资源端点需要 API Key。

### 1.2 鉴权

通常在请求头中传入静态 API Key：

```http
Authorization: Bearer <api_key>
```

Key 在服务端 `backend/api_keys.toml` 的 `[[keys]]` 表中定义，每项包含 `id`、`key` 与 `scopes`。凭证缺失或无效返回 `401 unauthenticated`，并带响应头 `WWW-Authenticate: Bearer`。

只有 `GET /v1/jobs/{job_id}/events` 还接受查询参数 `?access_token=<api_key>`。这是为浏览器原生 `EventSource` 无法设置 `Authorization` 请求头提供的例外，采用 RFC 6750 §2.3 的 URI query parameter 方式。其他端点不接受该参数。查询字符串可能进入访问日志和浏览器历史，能设置请求头的客户端仍应优先使用请求头。

| scope | 能力 |
|---|---|
| `read` | 读取 answers、jobs、papers、KB、期刊分区和上游文献；订阅 SSE。非管理员只能看到本 Key 创建的 job。 |
| `write` | 创建 answer；取消或删除本 Key 创建的 answer/job。 |
| `admin` | 重建 KB 索引；与 `read` 组合时查看全部 job；与 `write` 组合时取消或删除任意 Key 的 answer/job。scope 不隐含其他 scope，应按用途显式组合。 |

### 1.3 JSON、时间与分页

- JSON 字段统一使用 `snake_case`。
- 所有资源 ID 均为字符串；文献段落号、答案中的论文序号等明确声明为整数的字段除外。
- API 生成的时间戳为 ISO-8601 UTC、秒精度并带 `Z`，例如 `2026-09-05T12:34:56Z`。
- 分页列表统一接受 `limit`（整数，`1..100`，默认 `20`）与 `offset`（整数，`>=0`，默认 `0`），返回：

```json
{"items": [], "total": 0, "limit": 20, "offset": 0}
```

- answers 与 jobs 按 `created_at` 降序；papers 按 `indexed_at` 降序。相同时间下服务端可使用资源 ID 保持稳定次序。

### 1.4 CORS 与限流

CORS 由 `YAOE_CORS_ORIGINS` 配置，默认空列表，即不添加跨域放行中间件。启用后允许所有 HTTP 方法，请求头允许 `Authorization` 与 `Content-Type`。

v1 没有通用请求速率限制。唯一配额是每个 API Key 的活跃任务数：`queued` 与 `running` job 的合计达到 `YAOE_MAX_ACTIVE_JOBS_PER_KEY`（默认 `2`）后，`POST /v1/answers` 返回 `429 too_many_jobs`。

## 2. 错误模型

错误采用 RFC 9457 Problem Details，响应媒体类型为 `application/problem+json`。客户端应依据稳定的 `code` 分支，不应依赖可能调整的 `detail` 文案。

| 字段 | 类型 | 说明 |
|---|---|---|
| `type` | `string` | 错误类型 URI，形式为 `urn:yaoe:error:{code}`。 |
| `title` | `string` | HTTP 状态的标准英文短语。 |
| `status` | `integer` | HTTP 状态码。 |
| `detail` | `string` | 面向人的具体错误说明。 |
| `instance` | `string` | 触发错误的请求路径，不含查询字符串。 |
| `code` | `string` | 供客户端分支处理的稳定错误码。 |
| `errors` | `array<object> \| null` | 仅请求结构校验失败时出现；每项包含 `loc: string[]`、`msg: string`、`type: string`。 |

真实响应形状示例：

```json
{
  "type": "urn:yaoe:error:not_found",
  "title": "Not Found",
  "status": 404,
  "detail": "answer 'abc' not found",
  "instance": "/v1/answers/abc",
  "code": "not_found"
}
```

错误码如下。这里的 HTTP 错误 `code` 与异步任务的 `job.error.code` 是两套枚举。

| code | HTTP 状态 | 含义 | 典型触发场景 |
|---|---:|---|---|
| `unauthenticated` | 401 | 未通过鉴权 | 缺少、格式错误或无效的 Bearer API Key。 |
| `forbidden` | 403 | Key 缺少所需 scope，或无权修改目标资源 | `read` Key 创建 answer；普通 Key 删除别人的 answer/job。 |
| `not_found` | 404 | 资源不存在或不可见 | answer/paper/段落/章节不存在；普通 Key 查询别人的 job 时也返回 404，避免泄露其存在性。 |
| `fulltext_unavailable` | 404 | 无可用 PMC 全文 | 标识符不能映射到 PMCID，或 Europe PMC 没有全文。 |
| `not_ready` | 409 | answer 尚未就绪 | 在 answer 为 `queued`、`running`、`failed` 或 `cancelled` 时请求渲染稿。 |
| `conflict` | 409 | 当前资源状态不允许操作 | 取消已终态 job；活跃 answer 缺少关联 job。 |
| `validation_error` | 422 | 参数或请求体校验失败 | 参数越界、年份规则冲突、期刊查询没有 `issn` 与 `title`。框架级校验失败另带 `errors` 数组。 |
| `too_many_jobs` | 429 | 当前 Key 的活跃任务达到上限 | 创建 answer 时，本 Key 的 `queued`/`running` job 数已达到配置值。 |
| `upstream_unavailable` | 502 | Redis、PubMed、Semantic Scholar 或 Europe PMC 等上游不可用 | 入队失败、上游超时、上游限流或返回错误。`detail` 会指出来源。 |
| `unavailable` | 503 | 服务依赖不可用 | HTTP 层产生 503 时的默认错误码。就绪探针自身会以其健康响应形状直接返回 503。 |
| `internal_error` | 500 | 未处理的服务端错误 | 服务端内部异常；响应不会暴露堆栈。 |

422 示例：

```json
{
  "type": "urn:yaoe:error:validation_error",
  "title": "Unprocessable Content",
  "status": 422,
  "detail": "Input should be less than or equal to 30",
  "instance": "/v1/answers",
  "code": "validation_error",
  "errors": [
    {"loc": ["body", "papers"], "msg": "Input should be less than or equal to 30", "type": "less_than_equal"}
  ]
}
```

## 3. 端点总表

表中 25 个路径与 `backend/openapi.json` 的 `paths` 一一对应。一个路径可能支持多个方法。

| 方法 | 路径 | scope | 说明 |
|---|---|---|---|
| `GET` | `/v1/health` | 无 | 存活探针。 |
| `GET` | `/v1/health/ready` | 无 | DB、Redis、LLM、KB、期刊分区就绪检查。 |
| `POST` | `/v1/answers` | `write` | 创建异步问答任务。 |
| `GET` | `/v1/answers` | `read` | 分页浏览 answer。 |
| `GET` | `/v1/answers/{answer_id}` | `read` | 获取 answer 详情。 |
| `DELETE` | `/v1/answers/{answer_id}` | `write`（本人）；任意资源需再有 `admin` | 活跃时请求取消，终态时删除结果。 |
| `GET` | `/v1/answers/{answer_id}/markdown` | `read` | 获取带链接的完整 Markdown 渲染稿。 |
| `GET` | `/v1/answers/{answer_id}/papers/{n}` | `read` | 获取本次问答阅读的第 `n` 篇详情。 |
| `GET` | `/v1/jobs` | `read`；查看全部需再有 `admin` | 分页浏览 job。 |
| `GET` | `/v1/jobs/{job_id}` | `read` | 获取可见 job 详情。 |
| `DELETE` | `/v1/jobs/{job_id}` | `write`（本人）；任意资源需再有 `admin` | 请求取消活跃 job。 |
| `GET` | `/v1/jobs/{job_id}/events` | `read` | 订阅 job 的 SSE 事件流。 |
| `GET` | `/v1/papers` | `read` | 分页浏览本地文献库。 |
| `GET` | `/v1/papers/{key}` | `read` | 获取文献元数据。 |
| `GET` | `/v1/papers/{key}/paragraphs` | `read` | 获取文献全部段落。 |
| `GET` | `/v1/papers/{key}/paragraphs/{pid}` | `read` | 获取单个段落。 |
| `GET` | `/v1/papers/{key}/facts` | `read` | 获取原子事实。 |
| `GET` | `/v1/papers/{key}/fulltext` | `read` | 获取带段落锚点的 Markdown 全文。 |
| `GET` | `/v1/kb/search` | `read` | 语义检索知识库。 |
| `GET` | `/v1/kb/stats` | `read` | 获取知识库统计。 |
| `POST` | `/v1/kb/reindex` | `admin` | 异步重建知识库索引。 |
| `GET` | `/v1/journals/rank` | `read` | 按 ISSN 或标题查询期刊分区。 |
| `GET` | `/v1/literature/search` | `read` | 检索 Semantic Scholar/PubMed。 |
| `GET` | `/v1/literature/{ident}` | `read` | 解析并获取单篇上游文献。 |
| `GET` | `/v1/literature/{ident}/fulltext` | `read` | 获取 Europe PMC 全文目录或正文。 |
| `GET` | `/v1/literature/{ident}/citations` | `read` | 获取引用该文献的文献。 |
| `GET` | `/v1/literature/{ident}/references` | `read` | 获取该文献的参考文献。 |
| `GET` | `/v1/literature/{ident}/recommendations` | `read` | 获取推荐文献。 |

## 4. 分资源详解

以下各节列出的 `401`/`403` 适用于所有受保护端点；参数结构或范围错误均可能返回 `422 validation_error`。

### 4.1 Answers

#### `POST /v1/answers`

请求体为 `AnswerCreate`：

| 字段 | 类型 | 必填 | 默认 | 规则 |
|---|---|---:|---|---|
| `question` | `string` | 是 | — | 去除首尾空白后长度 `1..2000`。 |
| `papers` | `integer` | 否 | `8` | `1..30`。 |
| `years` | `integer \| null` | 否 | `null` | 最近年数，`1..50`；不能与 `year_from` 同时给。 |
| `year_from` | `integer \| null` | 否 | `null` | `1900..2100`。 |
| `year_to` | `integer \| null` | 否 | `null` | `1900..2100`；需要 `year_from`，且不得小于 `year_from`。 |
| `quartiles` | `integer[]` | 否 | `[]` | 每项为 `1..4`；服务端去重并升序保存。 |
| `journals` | `string[]` | 否 | `[]` | 每项去除首尾空白后长度 `1..100`。 |
| `keep_unranked` | `boolean` | 否 | `false` | 使用分区过滤时是否保留未收录期刊。 |
| `use_paywall` | `boolean` | 否 | `true` | 是否尝试机构订阅来源；容器部署不具备该能力，见“未纳入 v1”。 |
| `use_kb` | `boolean` | 否 | `true` | 是否提取事实并写入/使用知识库。 |
| `kb_hits` | `integer` | 否 | `0` | `0..20`，综合后附带的既有 KB 命中数。 |
| `max_chars` | `integer` | 否 | `28000` | 单篇送入流水线的字符预算，`4000..60000`。 |

成功返回 `202 Accepted`、响应头 `Location: /v1/answers/{answer_id}`（其中占位符取响应体的 `id`），响应体为 `Answer`，通常处于 `queued`；若 worker 已推进任务，也可能返回更新后的状态。可能错误：`forbidden`、`validation_error`、`too_many_jobs`、`upstream_unavailable`、`internal_error`。

answer 与关联 job 在同一数据库事务中提交后才入队。Redis 入队失败返回 `502 upstream_unavailable`，两者均保存为 `failed`，带失败信息与结束时间；失败答案可通过列表定位，并正常调用 `DELETE` 删除。

#### `GET /v1/answers`

查询参数：

| 参数 | 类型 | 默认 | 说明 |
|---|---|---|---|
| `status` | `queued \| running \| ready \| failed \| cancelled \| null` | `null` | 精确过滤状态。 |
| `q` | `string` | `""` | 去除首尾空白后对 `question` 做子串匹配。 |
| `limit` | `integer` | `20` | `1..100`。 |
| `offset` | `integer` | `0` | `>=0`。 |

返回 `Page<AnswerSummary>`。持 `read` 的 Key 可读取全部 answer，而不只限于本 Key。可能错误：`validation_error`、`internal_error`。

#### `GET /v1/answers/{answer_id}`

`answer_id` 为字符串路径参数。返回 `Answer`；未完成时 `body_md`、完成时间等字段可为 `null`。可能错误：`not_found`、`internal_error`。

#### `GET /v1/answers/{answer_id}/markdown`

无查询参数。answer 为 `ready` 时返回 `text/markdown; charset=utf-8` 的完整渲染稿，与数据目录下 `answers/{id}.md` 等价。它与 `Answer.body_md` 不同：渲染稿包含可点击链接、参考文献和定位附录。可能错误：`not_found`、`not_ready`、`internal_error`。

#### `GET /v1/answers/{answer_id}/papers/{n}`

`n` 为整数路径参数，最小值 `1`，对应 `Answer.papers[].n`。返回 `AnswerPaperDetail`，包括笔记、核实引文、事实、段落和全文。旧版导入的 answer 没有结构化 `papers`，此端点会返回 `not_found`。可能错误：`validation_error`、`not_found`、`internal_error`。

#### `DELETE /v1/answers/{answer_id}`

无请求体与查询参数，成功返回 `204 No Content`：

- answer 为活跃状态：设置关联 job 的取消标记；取消为异步、协作式。
- answer 为终态：删除数据库记录、`answers/{id}.md` 与 `answers/{id}_papers/`。
- 本地文献库 `library/` 与 KB 不随 answer 删除。

端点始终需要 `write`；创建该 answer 的 Key 可操作，操作其他 Key 的 answer 还必须有 `admin`。可能错误：`not_found`、`forbidden`、`conflict`、`internal_error`。

### 4.2 Jobs

#### `GET /v1/jobs`

| 参数 | 类型 | 默认 | 说明 |
|---|---|---|---|
| `kind` | `ask \| kb_reindex \| null` | `null` | 精确过滤任务种类。 |
| `status` | `queued \| running \| succeeded \| failed \| cancelled \| null` | `null` | 精确过滤状态。 |
| `limit` | `integer` | `20` | `1..100`。 |
| `offset` | `integer` | `0` | `>=0`。 |

返回 `Page<Job>`。持 `read` 的普通 Key 只看到本 Key 的 job；同时持 `read` 与 `admin` 时看到全部。可能错误：`validation_error`、`internal_error`。

#### `GET /v1/jobs/{job_id}`

返回 `Job`。普通 Key 查询别人的 job 与查询不存在的 job 均返回 `404 not_found`。可能错误：`not_found`、`internal_error`。

#### `GET /v1/jobs/{job_id}/events`

返回 `text/event-stream`。鉴权可使用 Bearer 头，或仅在此端点使用字符串查询参数 `access_token`（无默认值）。可选请求头 `Last-Event-ID` 指定上次已处理的 Redis Stream entry ID；缺省时从 `0-0` 开始回放。协议详见“异步任务与 SSE”。可能错误：`unauthenticated`、`forbidden`、`not_found`、`internal_error`。

#### `DELETE /v1/jobs/{job_id}`

无请求体与查询参数。活跃 job 接受取消请求后返回 `204 No Content`；终态 job 返回 `409 conflict`。端点始终需要 `write`；本 Key 的 job 可取消，取消其他 Key 的 job 还必须有 `admin`。普通 Key 对不可见 job 得到 `404 not_found`。可能错误：`not_found`、`forbidden`、`conflict`、`internal_error`。

### 4.3 Papers

`{key}` 必须匹配 `^[A-Za-z0-9._-]{1,80}$`；不匹配按 `404 not_found` 处理。

#### `GET /v1/papers`

参数 `q: string = ""` 对标题或期刊名称做子串匹配；`limit: integer = 20`（`1..100`）；`offset: integer = 0`（`>=0`）。返回 `Page<PaperMeta>`。可能错误：`validation_error`、`internal_error`。

#### `GET /v1/papers/{key}`

返回 `PaperMeta`。可能错误：`not_found`、`internal_error`。

#### `GET /v1/papers/{key}/paragraphs`

返回 `{"items": Paragraph[]}`。可能错误：`not_found`、`internal_error`。

#### `GET /v1/papers/{key}/paragraphs/{pid}`

`pid` 为整数路径参数，返回匹配 `Paragraph.id` 的 `Paragraph`。可能错误：`validation_error`、`not_found`、`internal_error`。

#### `GET /v1/papers/{key}/facts`

返回 `{"items": Fact[]}`；文献存在但没有 facts 文件时 `items` 为空。可能错误：`not_found`、`internal_error`。

#### `GET /v1/papers/{key}/fulltext`

返回 `text/markdown; charset=utf-8`。正文内含形如 `<a id="p24">` 的段落锚点，供前端定位。可能错误：`not_found`、`internal_error`。

### 4.4 Knowledge Base

#### `GET /v1/kb/search`

| 参数 | 类型 | 默认 | 说明 |
|---|---|---|---|
| `q` | `string` | 必填 | 检索文本。 |
| `kind` | `fact \| paragraph \| null` | `null` | 不给时检索两类条目。 |
| `top_k` | `integer` | `8` | `1..50`。 |
| `pmid` | 可重复 `string` | `[]` | 限定 PMID；例如 `?pmid=39133485&pmid=12345678`。 |

返回 `{"query": string, "items": KbHit[]}`。首次请求会惰性加载嵌入模型，可能有明显冷启动延迟。可能错误：`validation_error`、`internal_error`。

#### `GET /v1/kb/stats`

无参数，返回 `KbStats`。可能错误：`internal_error`。

#### `POST /v1/kb/reindex`

无请求体与查询参数，需要 `admin`。返回 `202 Accepted` 与状态为 `queued` 的 `Job`（`kind="kb_reindex"`）。可能错误：`forbidden`、`upstream_unavailable`、`internal_error`。

重建与增量入库、逐篇文献保存使用同一跨进程写锁，搜索仍可读取当前完整索引。等待写锁时支持取消，最后一篇处理完成以及暂存写入完成后、发布前都会再次检查取消；未发布的取消快照不会替换线上索引。

### 4.5 Journals

#### `GET /v1/journals/rank`

查询参数 `issn: string = ""` 与 `title: string = ""` 至少有一个去除首尾空白后非空；两者都给时一并用于查询。返回 `RankResult`，未命中不是错误，而是 `found=false`、`rank=null`。可能错误：`validation_error`、`internal_error`。

### 4.6 Literature

#### `GET /v1/literature/search`

| 参数 | 类型 | 默认 | 说明 |
|---|---|---|---|
| `q` | `string` | 必填 | 长度至少 1。 |
| `source` | `auto \| pubmed \| s2` | `auto` | `auto` 先查 Semantic Scholar，发生上游错误时回退 PubMed。 |
| `limit` | `integer` | `10` | `1..30`。 |
| `years` | `integer \| null` | `null` | 最近年数，`1..50`；与 `year_from` 互斥。 |
| `year_from` | `integer \| null` | `null` | `1900..2100`。 |
| `year_to` | `integer \| null` | `null` | `1900..2100`；需要 `year_from`，且不得小于它。 |
| `publication_types` | 可重复 `string` | `[]` | 文献类型过滤，例如 `?publication_types=Review&publication_types=Clinical+Trial`。 |
| `quartiles` | 可重复 `integer` | `[]` | 每项只能为 `1..4`。 |
| `journals` | 可重复 `string` | `[]` | 期刊过滤。 |
| `open_access_only` | `boolean` | `false` | 仅对 Semantic Scholar 检索生效。 |

返回 `LiteratureSearchResult`。`items` 不超过请求的 `limit`，即使 PubMed 为期刊或分区过滤扩大候选池；`total` 仍是上游命中总数，不是本地过滤后的数量。`source=auto` 回退时，结果的 `source` 为 `pubmed`，`fallback_reason` 给出 S2 失败原因；直接指定 `source=s2` 时不回退。可能错误：`validation_error`、`upstream_unavailable`、`internal_error`。

#### 标识符 `{ident}` 的解析

下列 literature 端点共用字符串路径参数 `{ident}`：

1. 纯数字按 PMID；
2. 匹配 `PMC\d+`（不区分大小写）时，经 Europe PMC 映射到 PMID；
3. 以 `10.` 开头时按 DOI，先查 Semantic Scholar，失败后尝试 Europe PMC 映射；
4. 其余按 Semantic Scholar paper ID。

`{ident}` 支持 DOI 中的斜杠，例如 `/v1/literature/10.1000/example`，或将斜杠编码为 `%2F`。详情、`fulltext`、`citations`、`references`、`recommendations` 均支持这两种写法。

上游明确不存在的资源返回 `404 not_found`，无可用 XML 全文返回 `404 fulltext_unavailable`；网络故障、限流或服务故障返回 `502 upstream_unavailable`，不会伪装成空记录。DOI 解析可以由其他上游成功兜底，但存在未恢复的上游故障、无法确认资源缺失时仍返回 `502`。

#### `GET /v1/literature/{ident}`

无查询参数，返回 `LiteratureRecord`。可能错误：`not_found`、`upstream_unavailable`、`internal_error`。

#### `GET /v1/literature/{ident}/fulltext`

| 参数 | 类型 | 默认 | 说明 |
|---|---|---|---|
| `section` | `string` | `""` | 空字符串只返回章节目录和摘要，`text=null`；`all` 返回全部章节；其他值按章节标题做不区分大小写的子串匹配，并选择第一个匹配标题。 |
| `max_chars` | `integer` | `20000` | `1000..100000`；正文超出时截断并令 `truncated=true`。 |

全文只来自 Europe PMC，不下载 Semantic Scholar 的开放 PDF 作为兜底。返回 `FulltextResult`。可能错误：`validation_error`、`not_found`（章节不存在）、`fulltext_unavailable`、`upstream_unavailable`、`internal_error`。

#### `GET /v1/literature/{ident}/citations`
#### `GET /v1/literature/{ident}/references`
#### `GET /v1/literature/{ident}/recommendations`

三者都只调用 Semantic Scholar；查询参数均为 `limit: integer = 10`，范围 `1..50`。成功均返回 `{"items": LiteratureRecord[]}`。可能错误：`validation_error`、`not_found`、`upstream_unavailable`、`internal_error`。

### 4.7 Health

#### `GET /v1/health`

免鉴权、无参数。返回：

```json
{"status": "ok", "version": "0.1.0", "time": "2026-09-05T12:34:56Z"}
```

`version` 取当前后端版本，上例仅展示形状。

#### `GET /v1/health/ready`

免鉴权、无参数。返回 `status: "ok" | "degraded"` 与 `checks`；`checks` 固定包含 `db`、`redis`、`llm`、`kb`、`ranks`，每项形如 `{"ok": boolean, "detail": string}`。

```json
{
  "status": "degraded",
  "checks": {
    "db": {"ok": true, "detail": "ok"},
    "redis": {"ok": true, "detail": "ok"},
    "llm": {"ok": false, "detail": "model unavailable"},
    "kb": {"ok": true, "detail": "embedder=... dim=1024 items=123"},
    "ranks": {"ok": true, "detail": "scimagojr_2024.csv"}
  }
}
```

只有 DB 或 Redis 检查失败时 HTTP 状态为 `503`；LLM、KB 或分区表不可用只令总体状态为 `degraded`，以便只读浏览能力继续服务。

## 5. 数据模型

表中未标 `null` 的类型不会以 `null` 表示缺失。许多结果模型对旧数据兼容而带默认空值；具体 required/default 信息可由 OpenAPI codegen 保留。

### 5.1 Answer 模型

#### `AnswerCreate`

字段、默认值与校验规则见 `POST /v1/answers` 请求体表。

#### `AnswerSummary`

| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | `string` | answer ID。 |
| `job_id` | `string \| null` | 关联的异步 job ID。 |
| `status` | `queued \| running \| ready \| failed \| cancelled` | answer 生命周期状态。 |
| `question` | `string` | 原始问题。 |
| `filters_label` | `string \| null` | 已归一化的筛选条件展示文本。 |
| `n_papers` | `integer \| null` | 纳入答案的文献数。 |
| `n_fulltext` | `integer \| null` | 纳入文献中读取全文的数量。 |
| `created_at` | `string` | UTC 创建时间。 |
| `finished_at` | `string \| null` | 终态时间。 |
| `error` | `JobError \| null` | 失败信息。 |

#### `Answer`

`Answer` 包含 `AnswerSummary` 的全部字段，并增加：

| 字段 | 类型 | 说明 |
|---|---|---|
| `question_en` | `string \| null` | 流水线使用的英文问题。 |
| `queries` | `string[]` | 实际执行的检索式，默认 `[]`。 |
| `options` | `object` | 创建时保存的选项，旧版导入数据可为空对象。 |
| `started_at` | `string \| null` | 开始执行时间。 |
| `papers` | `AnswerPaper[]` | 纳入结果的论文，按 `n` 编号。 |
| `body_md` | `string \| null` | 供前端渲染的综合正文；引用为裸标记，不含链接。 |
| `citations` | `Citation[]` | 正文引用对应的可定位原文。 |
| `kb_hits` | `KbHit[]` | 综合后附带的既有 KB 命中。 |

`body_md` 中的直接定位标记是 `[n¶pid]`，例如 `[2¶24]` 表示本次 answer 的第 2 篇论文、第 24 段。若段落无法解析，正文降级为 `[n]`。前端可按以下方式处理：

- 详情跳转：`/v1/answers/{answer_id}/papers/{n}`，在返回的 `paragraphs` 中定位 `id=pid`；
- 若论文已进入共享文献库，也可用其 `pmid`/key 请求 `/v1/papers/{key}/paragraphs/{pid}`，或把 `/v1/papers/{key}/fulltext` 中的 `#p{pid}` 锚点用于页面内定位；
- 不希望自行解析标记时，直接获取 `/v1/answers/{answer_id}/markdown` 的完整带链接稿。

#### `AnswerPaper`

| 字段 | 类型 | 说明 |
|---|---|---|
| `n` | `integer` | 论文在本次 answer 中的编号。 |
| `pmid` / `doi` / `pmcid` | `string` | 外部标识符；未知时为空字符串。 |
| `title` / `year` / `journal` / `issn` / `authors` | `string` | 论文元数据；未知时为空字符串。 |
| `quartile` | `string` | 分区值；未知时为空字符串。 |
| `rank_label` | `string` | 已格式化、可直接展示的分区标签。 |
| `source` | `pmc \| pdf \| inst \| abstract` | 流水线实际读取的内容来源，默认 `abstract`。 |
| `relevance` | `integer \| null` | 模型判定的相关性。 |
| `n_paragraphs` | `integer` | 段落数。 |
| `n_citations` | `integer` | 抽取引文数。 |
| `n_citations_verified` | `integer` | 已核实引文数。 |

#### `AnswerPaperDetail`

包含 `AnswerPaper` 全部字段，并增加：

| 字段 | 类型 | 说明 |
|---|---|---|
| `notes_md` | `string` | 单篇阅读笔记 Markdown。 |
| `citations` | `VerifiedQuote[]` | 从笔记中抽取并核实的引文。 |
| `facts` | `Fact[]` | 原子事实。 |
| `paragraphs` | `Paragraph[]` | 自包含的段落列表。 |
| `fulltext_md` | `string` | 本次流水线保存的全文或摘要 Markdown。 |

#### `Citation`

| 字段 | 类型 | 说明 |
|---|---|---|
| `n` | `integer` | answer 内论文编号。 |
| `pmid` | `string` | PMID，未知时为空字符串。 |
| `pid` | `integer` | 被引用段落 ID。 |
| `sec` | `string` | 章节名。 |
| `page` | `integer \| null` | 页码。 |
| `text` | `string` | 该段完整原文。 |
| `quotes` | `string[]` | 落在该段中的已核实引文。 |
| `from_marker` | `boolean` | `true`：正文以 `[n¶pid]` 直接引用该段；`false`：正文只写 `[n]`，服务端补入该论文已核实的 key-finding 段落。 |

### 5.2 Job 模型

#### `Job`

| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | `string` | job ID。 |
| `kind` | `ask \| kb_reindex` | 任务种类。 |
| `status` | `queued \| running \| succeeded \| failed \| cancelled` | job 生命周期状态。 |
| `api_key_id` | `string \| null` | 创建任务的 Key ID，不是秘密 Key 本身。 |
| `params` | `object` | 入队参数。 |
| `progress` | `JobProgress \| null` | 最近一次阶段/进度快照。 |
| `error` | `JobError \| null` | 失败信息。 |
| `result` | `object \| null` | 成功结果；ask 通常为 `{"answer_id": string}`，KB 重建为条目与论文计数。 |
| `created_at` / `started_at` / `finished_at` | `string` / `string \| null` / `string \| null` | UTC 生命周期时间。 |

#### `JobProgress`

| 字段 | 类型 | 说明 |
|---|---|---|
| `stage` | `string` | 最近阶段。问答流水线取值见 SSE 表。 |
| `current` | `integer \| null` | 已完成数量。 |
| `total` | `integer \| null` | 总数量。 |

#### `JobError`

| 字段 | 类型 | 说明 |
|---|---|---|
| `code` | `string` | `no_papers \| nothing_relevant \| llm_unavailable \| timeout \| internal_error`。 |
| `message` | `string` | 面向人的失败原因。 |

### 5.3 论文、知识库与分区模型

#### `Paragraph`

| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | `integer` | 段落 ID。 |
| `sec` | `string` | 章节名。 |
| `page` | `integer \| null` | 页码。 |
| `text` | `string` | 段落原文。 |

#### `Fact`

| 字段 | 类型 | 说明 |
|---|---|---|
| `fact` | `string` | 原子事实。 |
| `fact_zh` | `string` | 中文事实文本，未知时为空。 |
| `kind` | `string` | 事实类型，默认 `finding`。 |
| `pid` | `integer \| null` | 支撑段落 ID。 |
| `sec` | `string \| null` | 支撑章节。 |
| `page` | `integer \| null` | 页码。 |
| `quote` | `string` | 支撑引文。 |
| `score` | `number` | 匹配/核实分数。 |
| `verified` | `boolean` | 是否已核实定位。 |

#### `VerifiedQuote`

| 字段 | 类型 | 说明 |
|---|---|---|
| `claimed_pid` | `integer` | 笔记声称的段落号。 |
| `pid` | `integer \| null` | 核实后的段落号。 |
| `sec` | `string \| null` | 核实后的章节。 |
| `page` | `integer \| null` | 页码。 |
| `quote` | `string` | 引文。 |
| `score` | `number` | 匹配分数。 |
| `verified` | `boolean` | 是否核实通过。 |
| `note_section` | `string \| null` | 引文在阅读笔记中的小节。 |
| `key_finding` | `boolean` | 是否属于关键发现。 |

#### `PaperMeta`

| 字段 | 类型 | 说明 |
|---|---|---|
| `key` | `string` | 本地文献库 key。 |
| `pmid` / `doi` / `pmcid` | `string` | 外部标识符。 |
| `title` / `year` / `journal` / `issn` / `quartile` / `authors` / `source` | `string` | 文献元数据。 |
| `types` | `string[]` | 文献类型。 |
| `indexed_at` | `string \| null` | 入库时间。 |
| `n_paragraphs` / `n_facts` | `integer` | 段落与事实数。 |

#### `KbHit`

| 字段 | 类型 | 说明 |
|---|---|---|
| `kind` | `fact \| paragraph` | 命中类型。 |
| `pmid` / `doi` / `pmcid` | `string` | 论文标识符。 |
| `title` / `year` / `journal` / `quartile` / `source` / `authors` | `string` | 论文元数据。 |
| `pid` | `integer \| null` | 段落 ID。 |
| `sec` | `string \| null` | 章节。 |
| `page` | `integer \| null` | 页码。 |
| `text` | `string` | 命中文本。 |
| `text_zh` | `string \| null` | 中文文本。 |
| `fact_kind` | `string \| null` | 事实类型，仅 fact 命中适用。 |
| `quote` | `string \| null` | 支撑引文。 |
| `verified` | `boolean \| null` | 核实状态。 |
| `score` | `number` | 相似度分数。 |

#### `KbStats`

| 字段 | 类型 | 说明 |
|---|---|---|
| `items` | `integer` | 索引条目总数。 |
| `papers` | `integer` | 涉及论文数。 |
| `by_kind` | `object<string, integer>` | 按条目类型统计。 |
| `embedder` | `string \| null` | 嵌入器标识。 |
| `dim` | `integer \| null` | 向量维数。 |

#### `RankInfo`

| 字段 | 类型 | 说明 |
|---|---|---|
| `title` | `string` | 期刊标题。 |
| `issns` | `string[]` | 已知 ISSN。 |
| `zone` | `integer` | 分区数字。 |
| `quartile` | `string` | 如 `Q1`。 |
| `sjr` | `number \| null` | SJR。 |
| `h_index` | `string \| null` | H-index；wire 类型为字符串。 |
| `categories` | `string` | 学科类别。 |
| `top` | `boolean` | 是否为 Top。 |
| `source` | `string` | 分区数据来源。 |

#### `RankResult`

| 字段 | 类型 | 说明 |
|---|---|---|
| `query` | `{issn: string, title: string}` | 原查询。 |
| `found` | `boolean` | 是否命中。 |
| `rank` | `RankInfo \| null` | 分区详情。 |
| `label` | `string` | 已格式化、可直接展示的标签。 |

### 5.4 Literature 模型

#### `LiteratureRecord`

| 字段 | 类型 | 说明 |
|---|---|---|
| `source` | `pubmed \| s2` | 记录来源。 |
| `id` | `string` | 来源侧主 ID。 |
| `pmid` / `pmcid` / `doi` / `s2_id` | `string \| null` | 外部标识符。 |
| `title` | `string` | 标题。 |
| `abstract` | `string \| null` | 摘要。 |
| `year` / `journal` / `issn` | `string \| null` | 出版元数据。 |
| `authors` | `string[]` | 作者。 |
| `types` | `string[]` | 文献类型。 |
| `cited_by` | `integer \| null` | 被引数。 |
| `open_access_pdf` | `string \| null` | S2 提供的开放 PDF URL。 |
| `tldr` | `string \| null` | S2 TLDR。 |
| `rank` | `RankInfo \| null` | 期刊分区。 |

#### `LiteratureSearchResult`

| 字段 | 类型 | 说明 |
|---|---|---|
| `source` | `pubmed \| s2` | 实际返回结果的来源。 |
| `total` | `integer` | 上游报告的结果总数。 |
| `items` | `LiteratureRecord[]` | 当前结果。 |
| `fallback_reason` | `string \| null` | `auto` 从 S2 回退 PubMed 时的原因。 |

#### `FulltextResult`

| 字段 | 类型 | 说明 |
|---|---|---|
| `pmcid` | `string` | 全文对应 PMCID。 |
| `citation` | `string` | Europe PMC 引用信息。 |
| `sections` | `{title: string, chars: integer}[]` | 章节目录与各章字符数。 |
| `abstract` | `string` | 摘要，缺失时为空字符串。 |
| `section` | `string \| null` | 实际选择的章节标题、`all` 或 `null`。 |
| `text` | `string \| null` | 请求了 `section` 时的正文。 |
| `truncated` | `boolean` | 是否按 `max_chars` 截断。 |

### 5.5 通用模型

#### `Page`（`Page<T>`）

| 字段 | 类型 | 说明 |
|---|---|---|
| `items` | `T[]` | 当前页条目。 |
| `total` | `integer` | 过滤后总数。 |
| `limit` | `integer` | 本次页大小。 |
| `offset` | `integer` | 本次偏移量。 |

#### `Problem`

字段见“错误模型”。`errors` 为可选的 `object[] | null`，校验错误项的实际形状为 `{loc: string[], msg: string, type: string}`。

## 6. 异步任务与 SSE

### 6.1 生命周期

```text
POST /v1/answers
  └─ 202 + Location + Answer(status="queued", job_id=...)
       ├─ GET /v1/jobs/{job_id}/events  持续接收阶段与逐篇进度
       │    └─ succeeded / failed / cancelled 终态事件后服务端关闭流
       └─ GET /v1/jobs/{job_id}         可用于轮询或恢复状态
            └─ succeeded 后 GET /v1/answers/{answer_id}
                              GET /v1/answers/{answer_id}/papers/{n}
                              GET /v1/answers/{answer_id}/markdown
```

Answer 状态迁移为 `queued → running → ready|failed|cancelled`；对应 Job 为 `queued → running → succeeded|failed|cancelled`。

每条 SSE 包含：

- `id:` Redis Stream entry ID；
- `event:` 事件类型；
- `data:` JSON 对象。

### 6.2 事件

| event | `data` 字段 |
|---|---|
| `stage` | `{stage, status, detail}`。`stage` 为 `queries \| search \| fulltext \| read \| kb \| synthesize`；`status` 为 `started \| finished`；`detail` 为对象。`search/finished` 包含 `candidates`、`kept`、`dropped:{year,quartile,unranked,journal}`、`papers:[{n,pmid,title,year,journal,rank_label,pmcid}]`；`read/finished` 包含 `relevant`、`total`。其他阶段也可在 `detail` 中报告该阶段计数或结果摘要。 |
| `progress` | `{stage, current, total, pmid, title}`，其中 `stage: string`、`current: integer`、`total: integer`、`pmid: string \| null`、`title: string \| null`；逐篇进度主要来自 `fulltext`、`read`、`kb` 阶段。 |
| `log` | `{level, message}`；当前 `level` 为 `info \| warning`。只适合展示运行日志，不应据其文案驱动状态机。 |
| `succeeded` | 问答任务为 `{answer_id}`；KB 重建任务为 `{items, papers}`。终态。 |
| `failed` | `{code, message}`，其中 `code` 为 JobError 枚举。终态。 |
| `cancelled` | `{}`。终态。 |

`kb` 阶段仅在 `use_kb=true` 时出现。

### 6.3 重连、心跳与过期

- 初次连接未给 `Last-Event-ID` 时，从 `0-0` 开始回放当前 Redis Stream 中仍保留的事件。
- 断线重连时，把最后成功处理的 SSE `id` 放进 `Last-Event-ID` 请求头；服务端从该 ID **之后**续传。
- 连接空闲时约每 15 秒发送一条 SSE 注释心跳。客户端应忽略注释行。
- 事件流默认保留 7 天，并受最大长度配置约束。订阅开始时以及活动订阅的空读周期（约 5 秒）会检查数据库终态；数据库连接只用于短期查询，不随 SSE 长连接持续占用。
- 数据库已终态时，先回放游标之后仍保留的事件；若终态事件发布失败、已过期，或客户端游标已越过终态事件，则补发数据库中的终态并关闭。合成事件沿用最后游标（没有历史游标时为 `0-0`），客户端不得仅因 ID 与上一条相同而丢弃终态。
- 合成 `succeeded` 使用 `job.result`，`failed` 使用 `job.error`，`cancelled` 的 `data` 为空对象。已终态任务无需等待下一个空读周期。

取消是异步且协作式的：`DELETE` 成功只表示已写入取消请求。worker 在任务开始前、阶段边界和逐篇完成边界检查取消标记；它不会中断正在执行的 LLM 调用，因此取消延迟不超过当前一个流水线步骤（≤ 一步）。

### 6.4 浏览器 `EventSource`

```js
const apiKey = "yaoe_replace_me_frontend";
const jobId = "<job_id>";
const url = new URL(`http://localhost:8765/v1/jobs/${jobId}/events`);
url.searchParams.set("access_token", apiKey);

const stream = new EventSource(url);
for (const name of ["stage", "progress", "log", "succeeded", "failed", "cancelled"]) {
  stream.addEventListener(name, (event) => {
    const data = JSON.parse(event.data);
    console.log(name, event.lastEventId, data);
    if (["succeeded", "failed", "cancelled"].includes(name)) stream.close();
  });
}
stream.onerror = (error) => console.error("SSE disconnected", error);
```

浏览器会按 SSE 规范在自动重连时携带其已处理的 last event ID。

命令行：

```bash
curl -N \
  'http://localhost:8765/v1/jobs/<job_id>/events?access_token=yaoe_replace_me_frontend'
```

需手工续传时：

```bash
curl -N \
  -H 'Authorization: Bearer yaoe_replace_me_frontend' \
  -H 'Last-Event-ID: 1725537600000-0' \
  'http://localhost:8765/v1/jobs/<job_id>/events'
```

## 7. 完整 curl 流程

### 7.1 创建、观察并读取结果

创建任务；同时查看响应头可取得 `Location`：

```bash
curl -i -X POST 'http://localhost:8765/v1/answers' \
  -H 'Authorization: Bearer yaoe_replace_me_frontend' \
  -H 'Content-Type: application/json' \
  -d '{
    "question": "SGLT2抑制剂对HFpEF患者有什么获益？",
    "papers": 2,
    "years": 3,
    "quartiles": [1, 2],
    "keep_unranked": false,
    "use_kb": false
  }'
```

从响应体记下 `id` 与 `job_id`，然后订阅进度：

```bash
curl -N \
  'http://localhost:8765/v1/jobs/<job_id>/events?access_token=yaoe_replace_me_frontend'
```

也可读取 job 快照：

```bash
curl -s \
  -H 'Authorization: Bearer yaoe_replace_me_frontend' \
  'http://localhost:8765/v1/jobs/<job_id>'
```

收到 `succeeded` 后读取结构化答案、某篇详情与完整渲染稿：

```bash
curl -s \
  -H 'Authorization: Bearer yaoe_replace_me_frontend' \
  'http://localhost:8765/v1/answers/<answer_id>'

curl -s \
  -H 'Authorization: Bearer yaoe_replace_me_frontend' \
  'http://localhost:8765/v1/answers/<answer_id>/papers/1'

curl -s \
  -H 'Authorization: Bearer yaoe_replace_me_frontend' \
  'http://localhost:8765/v1/answers/<answer_id>/markdown'
```

### 7.2 取消

对仍在 `queued` 或 `running` 的任务请求取消：

```bash
curl -i -X DELETE \
  -H 'Authorization: Bearer yaoe_replace_me_frontend' \
  'http://localhost:8765/v1/jobs/<job_id>'
```

也可对活跃 answer 使用：

```bash
curl -i -X DELETE \
  -H 'Authorization: Bearer yaoe_replace_me_frontend' \
  'http://localhost:8765/v1/answers/<answer_id>'
```

随后通过 SSE 或 `GET /v1/jobs/{job_id}` 等待 `cancelled` 终态。注意：若对终态 answer 调用 `DELETE`，语义是删除 answer 结果，不是取消。

### 7.3 只读端点

```bash
# 文献库
curl -s -H 'Authorization: Bearer yaoe_replace_me_frontend' \
  'http://localhost:8765/v1/papers?q=Lancet&limit=10&offset=0'

# KB；pmid 可重复
curl -sG -H 'Authorization: Bearer yaoe_replace_me_frontend' \
  --data-urlencode 'q=SGLT2 HFpEF 心衰住院' \
  --data-urlencode 'kind=fact' \
  --data-urlencode 'top_k=8' \
  --data-urlencode 'pmid=39133485' \
  'http://localhost:8765/v1/kb/search'

# 期刊分区
curl -sG -H 'Authorization: Bearer yaoe_replace_me_frontend' \
  --data-urlencode 'title=Lancet' \
  'http://localhost:8765/v1/journals/rank'

# 上游检索
curl -sG -H 'Authorization: Bearer yaoe_replace_me_frontend' \
  --data-urlencode 'q=SGLT2 inhibitors HFpEF' \
  --data-urlencode 'source=auto' \
  --data-urlencode 'limit=2' \
  --data-urlencode 'years=3' \
  'http://localhost:8765/v1/literature/search'

# Europe PMC 章节
curl -sG -H 'Authorization: Bearer yaoe_replace_me_frontend' \
  --data-urlencode 'section=Conclusion' \
  --data-urlencode 'max_chars=20000' \
  'http://localhost:8765/v1/literature/PMC9306514/fulltext'

# 管理员异步重建 KB
curl -s -X POST -H 'Authorization: Bearer yaoe_replace_me_ops' \
  'http://localhost:8765/v1/kb/reindex'
```

## 8. 前端接入建议

1. 使用入库的 `backend/openapi.json` 生成请求客户端与 TypeScript/其他语言类型；运行中也可从 `/v1/openapi.json` 获取同一描述。SSE 事件的动态 `data` 形状按本文事件表处理。
2. 对需要实时阶段与逐篇进度的界面使用 SSE；后台恢复、列表页与不需要细粒度进度的客户端可轮询 `GET /v1/jobs/{job_id}`。无论哪种方式，都应以 job/answer 终态字段为最终事实。
3. `GET /v1/kb/search` 首次请求会加载 bge-m3；实测冷启动约 15 秒并占用约 2 GiB 内存。界面应允许首请求较长，并显示明确的加载状态。
4. `source=auto` 时 Semantic Scholar 可能因限流（常见为 429）回退 PubMed。若 `fallback_reason` 非空，可提示用户“已改用 PubMed”，不要把成功的回退结果显示为整体失败。
5. `AnswerPaper.rank_label` 与 `RankResult.label` 已由后端格式化，可直接展示；需要结构化筛选或自定义视觉样式时再读取 `quartile`/`rank`。
6. 解析 `body_md` 时保留 `[n¶pid]` 的二元定位关系，并以 `citations` 作为段落正文和核实引文的数据源；不要从显示文案反推 PMID。

## 9. 未纳入 v1

- **无通用限流。** v1 只限制每个 Key 的活跃任务数，不提供按秒/分钟的请求配额响应头。
- **无用户与租户体系。** API Key 是服务凭证，不是最终用户账号。持 `read` scope 的 Key 可读取全部 answers、papers 与 KB；job 列表/详情按 Key 隔离，`read` 与 `admin` 组合时可查看全部 job。删除与取消始终需要 `write`，且仅限创建资源的 Key；跨 Key 操作还需要 `admin`。
- **容器内不支持机构订阅下载。** 镜像不包含 `core/vendor/`，因此 v1 容器服务不会通过机构订阅抓取付费全文；开放全文仅使用 Europe PMC，问答流水线在无全文时可使用摘要。本机原有 CLI 内核的机构订阅能力不属于本 API 协议。
- **全文透传不下载 OA PDF 兜底。** `/v1/literature/{ident}/fulltext` 只读 Europe PMC；`LiteratureRecord.open_access_pdf` 即使存在，也只是上游元数据。
