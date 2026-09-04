# PICOSGpt — 本地大模型医学文献问答 Demo

**问一个临床问题 → 自动检索 PubMed / Europe PMC → 下载全文 → 模型逐篇阅读 → 输出带编号引用、可核对的答案。**
全程在本地 GPU 上运行（Qwen3-14B），不依赖任何云端大模型。

```
问题 ──> ask.py 流水线 ──> PubMed / Europe PMC 检索
                       ├─> 全文下载：PMC XML → Unpaywall PDF → 机构订阅 PDF（可选）
                       ├─> Qwen3-14B 逐篇阅读做笔记（vLLM :8000 ← LiteLLM :4000）
                       └─> 综合成答案  answers/<时间戳>.md  +  answers/<时间戳>_papers/（原文 + 笔记）

Codex CLI ──(Responses API)──> LiteLLM :4000 ──> vLLM :8000
   └── MCP: semantic_scholar_mcp.py（Semantic Scholar / PubMed / Europe PMC 全文 / 本地 PDF）
```

## 1. 快速开始（演示流程）

```bash
cd /data1/qyy/smk
./PICOSGpt start          # 启动 vLLM + LiteLLM（tmux 后台，模型加载约 1–3 分钟）
./PICOSGpt status         # 等到 vLLM 和 LiteLLM 都列出模型名
./PICOSGpt ask "SGLT2抑制剂对HFpEF患者有什么获益？"
```

约 2–4 分钟后终端打印答案，并保存到 `answers/<时间戳>.md`。答案结构：

- **结论** —— 直接回答问题
- **证据** —— 每条末尾带 `[n]` 引用，注明研究类型 / 样本量 / 效应量
- **局限** —— 证据质量、矛盾之处
- **参考文献** —— 每条标注 `〔全文(PMC)〕 / 〔全文(PDF)〕 / 〔全文(机构订阅)〕 / 〔仅摘要〕`

`answers/<时间戳>_papers/` 里能看到每篇文献的原文和模型阅读笔记，可以现场打开给观众看"答案是从哪来的"。

常用参数：
```bash
./PICOSGpt ask --papers 12 "..."      # 多读几篇（默认 8 篇）
./PICOSGpt ask --no-paywall "..."     # 不使用机构订阅下载
./PICOSGpt stop                       # 演示结束后停止服务
```

## 2. 命令一览（`./PICOSGpt help`）

| 命令 | 作用 |
|---|---|
| `./PICOSGpt start [14b\|4b] [GPU]` | 启动 vLLM + LiteLLM，默认 Qwen3-14B 在 GPU 2；显存紧张用 `./PICOSGpt start 4b 1` |
| `./PICOSGpt stop` / `status` / `logs` | 停止 / 查看状态 / 打开 tmux 看服务日志 |
| `./PICOSGpt ask "问题"` | **一键流水线**（推荐演示用，每次都真实检索 + 读全文，结果确定） |
| `./PICOSGpt codex ["问题"]` | Codex 交互式 agent：模型自己决定调哪些工具，适合追问（"把 [2] 的摘要贴出来"、"读一下 [3] 的 Results"） |
| `./PICOSGpt paywall get DOI` | 用机构订阅登录态下载付费墙全文到 `pdfs/` |
| `./PICOSGpt verify` | 核对最近一次 Codex 回答里的 PMID/DOI 是否都来自工具返回（防编造） |
| `./PICOSGpt test` | 不经过模型，直接测试检索工具是否可用 |

## 3. 目录结构

```
PICOSGpt/
├── PICOSGpt                      统一入口脚本（上表所有命令）
├── scripts/                 由 PICOSGpt start 调用的底层启动脚本
│   ├── vllm.sh                vLLM 服务（:8000）
│   └── litellm.sh             LiteLLM 代理（:4000）
├── ask.py                   一键流水线主程序
├── semantic_scholar_mcp.py  Codex 用的 MCP 工具服务（检索 / 全文 / 本地 PDF）
├── paywall_fetch.py         机构订阅全文下载（Playwright）
├── spider_auth.py           拦截页 / 登录态检测（来自 SPIDER_PROJECT）
├── verify_citations.py      引用核对
├── test_mcp.py / test_fulltext.py   工具自测
├── litellm_config.yaml      LiteLLM 配置
├── AGENTS.md                Codex 的系统指令（检索工作流 + 回答格式）
├── answers/                 每次问答的输出
├── pdfs/                    本地 PDF（手动放入或 paywall 下载）
├── logs/                    服务日志
└── vendor/                  项目自带的 Python 依赖（pypdf / playwright），不污染 conda 环境
```

## 4. 怎么证明答案不是编的

1. `answers/<ts>_papers/` 里每篇都有原文和模型笔记，引用可逐条溯源。
2. Codex 模式下，运行输出里必须有 `mcp: semantic_scholar/xxx (completed)`；之后跑 `./PICOSGpt verify`，不在工具返回里的 PMID/DOI 会标 `SUSPECT`。
3. 追问核对具体数字："把 [2] 的摘要原文贴出来" 或 "用 pubmed_fetch 36041474"。
4. 完整原始记录（含工具返回全文）：`~/.codex/sessions/<date>/rollout-*.jsonl`。

## 5. 全文获取

| 来源 | 说明 |
|---|---|
| PMC（开放获取） | 自动。Codex 里可说 "读一下 [2] 的全文 Results 部分"（`get_fulltext` 按章节读） |
| Unpaywall PDF | 自动 |
| 机构订阅 | 需先在**有显示器的机器**上登录一次生成 `sd_state.json`，见下 |
| 本地 PDF | 放到 `pdfs/`，Codex 里说 "用 read_pdf 读 xxx.pdf" |

机构订阅登录（一次性）：
```bash
# 在有浏览器的机器上：
python paywall_fetch.py login --url https://www.sciencedirect.com/
# 浏览器弹出 → 机构登录（OpenAthens / Shibboleth / CARSI）→ 打开一篇付费文章确认能看全文 → 回终端按 Enter
scp sd_state.json* tx@10.107.231.69:/data1/qyy/smk/
# 服务器上验证：
./PICOSGpt paywall get 10.1016/j.jacc.2023.10.021
```
之后 `./PICOSGpt ask` 自动启用（每次最多下载 `PAYWALL_MAX_PER_RUN`=5 篇，串行、间隔 4–9 秒）。
注意：登录态可能与出口 IP 绑定；请只按需下载，遵守出版社许可。

## 6. 环境与配置

- conda 环境 `clarify`（vllm 0.27 / litellm 1.98 / mcp 1.29）；Codex CLI 在 `~/.local/bin/codex`
- 模型：`/data1/clarify/qwen14b`（Qwen3-14B）、`/data1/clarify/qwen4b`
- `LOCAL_QWEN_KEY` 需等于 `litellm_config.yaml` 的 `master_key`（`PICOSGpt` 已默认设置）
- 可选 API key：`S2_API_KEY`（Semantic Scholar，无 key 时基本 429，会自动退到 PubMed）、`NCBI_API_KEY`（PubMed 3→10 req/s）
- Codex 配置 `~/.codex/config.toml` 要点：
  - `model = "qwen3-14b"`, `model_provider = "local-qwen"`, `base_url = http://127.0.0.1:4000/v1`, `wire_api = "responses"`
  - `[mcp_servers.semantic_scholar] default_tools_approval_mode = "approve"` —— 否则 `codex exec` 下 MCP 调用会被拒，模型会凭记忆编参考文献

## 7. 排错

| 现象 | 处理 |
|---|---|
| `./PICOSGpt status` 显示 not ready | 等 1–3 分钟；`./PICOSGpt logs` 看 vLLM 是否还在加载 / 显存不足 |
| 显存不够 | `./PICOSGpt stop && ./PICOSGpt start 4b <空闲GPU>` |
| 检索无结果 / 429 | `./PICOSGpt test` 直接测工具；配置 `S2_API_KEY` |
| Codex 回答没有 `mcp:` 行 | 检查 `~/.codex/config.toml` 的 `default_tools_approval_mode = "approve"` |
| 手动验证代理 | `curl -H "Authorization: Bearer sk-123456" http://127.0.0.1:4000/v1/models` 应列出 `qwen3-14b` |

*本工具输出为文献综述，仅供科研/教学参考，不构成医疗建议。*
