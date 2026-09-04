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
./PICOSGpt ask --no-kb "..."          # 不做原子知识抽取 / 向量入库（更快）
./PICOSGpt stop                       # 演示结束后停止服务
```

### 1.1 文献筛选（类 Google Scholar）

```bash
./PICOSGpt ask --years 3 "..."                       # 近三年
./PICOSGpt ask --year 2018-2023 "..."                # 自定义年份区间（或单年 --year 2022）
./PICOSGpt ask --quartile Q1,Q2 "..."                # 只要一区/二区期刊（也可写 --zone 1-3、"一区,二区"）
./PICOSGpt ask --journal "Nature,Lancet,JAMA" "..."  # 期刊名包含关键字（Nature 子刊 = Nature Medicine 等都会命中）
./PICOSGpt ask --years 3 --quartile 1-2 --journal Nature "..."   # 可组合
./PICOSGpt ask --quartile Q1 --keep-unranked "..."   # 分区表里查不到的期刊也保留（默认丢弃）
```

- 分区数据来自 `data/journal_ranks/scimagojr_<年>.csv`（SCImago SJR Best Quartile，Q1–Q4 ≈ 一区–四区），
  按 ISSN 匹配、刊名兜底。更新：`./PICOSGpt rank download 2025`；查询：`./PICOSGpt rank lookup "Lancet"`。
- 要用**中科院分区**：把分区表导出的 CSV 放到 `data/journal_ranks/cas_2025.csv`（需含 ISSN 或刊名列 + 含“分区”的列，
  Top 列可选），会自动加载并覆盖 SCImago 的结果。
- 筛选时会自动扩大候选池（每条 query 取 30+25 条）再过滤，日志里能看到各条件淘汰了多少篇。
- 答案开头与每条参考文献都标注分区，如 `〔Q1 SJR 6.90〕`。

### 1.2 引文定位到原文段落

- 全文/摘要被切成带编号的段落（`¶1, ¶2, …`，PMC 全文按 XML 的 `<p>` 切；PDF 按页/空行切；摘要按 BACKGROUND/METHODS 切），
  `answers/<ts>_papers/<pmid>.md` 里每段都有锚点 `<a id="p12">`。
- 模型阅读时每条发现必须写成 `(¶12: "原文逐字引用")`；程序用模糊匹配核对引用是否真的出现在该段（对不上会在全篇里重新定位，
  找不到则标为未核实），结果存 `<pmid>_citations.json`。
- 综合答案里的引用变成 `[3¶12]` → 可点击链接 `<ts>_papers/<pmid>.md#p12`；文末 **原文定位** 一节按篇列出每个被引段落的
  章节/页码和核实过的原文摘句。

### 1.3 原文保存 + 原子知识 + 向量知识库

每篇读过的文献都会持久保存到 `library/<pmid>/`：`fulltext.md`（带锚点全文）、`paragraphs.json`、`facts.json`（原子知识）、`meta.json`。
原子知识 = 模型从全文抽出的一句话事实（含人群/干预/对照/结局/数字，中英双语），每条带来源段落 `pid` 和逐字 `quote`，并经过同样的核实。
所有事实和段落向量化后追加到 `kb/`（bge-m3 embedding，模型放在 `models/BAAI/bge-m3`；没有模型时退化为哈希词袋向量）。

```bash
./PICOSGpt kb search "SGLT2 HFpEF 心衰住院"     # 语义检索（中英文均可）
./PICOSGpt kb search "..." --kind paragraph      # 只搜原文段落
./PICOSGpt kb stats / reindex                    # 统计 / 从 library/ 重建索引
./PICOSGpt ask --kb-hits 5 "..."                 # 答案末尾附上知识库中相关的旧事实
```
Codex 模式下对应工具：`kb_search`。

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
├── ask.py                   一键流水线主程序（筛选 / 段落定位 / 知识抽取）
├── journal_rank.py          期刊分区表加载与查询（SCImago / 自定义中科院分区 CSV）
├── knowledge_store.py       段落切分、引文核实、原子知识抽取、向量知识库
├── semantic_scholar_mcp.py  Codex 用的 MCP 工具服务（检索 / 全文 / 本地 PDF / kb_search）
├── paywall_fetch.py         机构订阅全文下载（Playwright）
├── spider_auth.py           拦截页 / 登录态检测（来自 SPIDER_PROJECT）
├── verify_citations.py      引用核对
├── test_mcp.py / test_fulltext.py   工具自测
├── litellm_config.yaml      LiteLLM 配置
├── AGENTS.md                Codex 的系统指令（检索工作流 + 回答格式）
├── answers/                 每次问答的输出
├── library/                 持久保存的每篇文献（全文 + 段落 + 原子知识）
├── kb/                      向量知识库（meta.jsonl + vectors.npy）
├── data/journal_ranks/      期刊分区表
├── models/                  embedding 模型（bge-m3，不入库，见 §6.1 重建）
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

### 6.1 embedding 环境（`kb` 子命令，无 GPU 亦可）

`models/`（约 2.2G 权重）与虚拟环境均不入库，需按下面安装。任选 conda/venv/uv，只要满足 **Python 3.12**（torch 尚无 3.13+ 轮子）：

```bash
cd <项目根>                            # 即 knowledge_store.py 所在目录
python -m pip install torch --index-url https://download.pytorch.org/whl/cpu   # 有 GPU 则装对应 CUDA 版
python -m pip install sentence-transformers
python -c "from huggingface_hub import snapshot_download as d; \
  d('BAAI/bge-m3', local_dir='models/BAAI/bge-m3', \
    ignore_patterns=['onnx/*','*.onnx','*.onnx_data'])"
```

- 目标路径固定为 `<项目根>/models/BAAI/bge-m3`（`knowledge_store.py` 的 `EMBED_MODEL` 默认值，可用同名环境变量覆盖）。
- 末级目录名必须正好是 `bge-m3`：`Embedder` 的后端名取自 `os.path.basename(model_path)`，要与 `kb/info.json` 的 `"embedder": "bge-m3"` 一致。
- 排除 `onnx/`：`onnx/model.onnx_data` 单独 2.27G，与 `pytorch_model.bin` 是同一模型的另一份格式，`SentenceTransformer` 只读 `.bin`。排除后约 2.2G。
- 无 GPU 无需改代码，`Embedder` 只在 `torch.cuda.is_available()` 为真时才切 GPU。
- **装完必须验证**：缺模型或缺 torch 时 `Embedder` 只打一行 log 就静默退化成 `hash-bow-v1`(4096 维)，而现有 `kb/vectors.npy` 是 1024 维，`search` 会在矩阵乘处维度报错。

```bash
python -c "from knowledge_store import Embedder; e=Embedder(); print(e.name, e.dim)"
# 必须打印: bge-m3 1024   （打印 hash-bow-v1 4096 就是没加载上）
python knowledge_store.py stats
python knowledge_store.py search "SGLT2 HFpEF 心衰住院"
```

> `./PICOSGpt kb` 走的是 `PICOSGpt` 里硬编码的 `ENV=/data/anaconda3/envs/clarify`，**不会**使用上面新建的环境。若装在别处，直接用该环境的解释器调 `knowledge_store.py`，或同步修改 `PICOSGpt` 的 `ENV`。

## 7. 排错

| 现象 | 处理 |
|---|---|
| `./PICOSGpt status` 显示 not ready | 等 1–3 分钟；`./PICOSGpt logs` 看 vLLM 是否还在加载 / 显存不足 |
| 显存不够 | `./PICOSGpt stop && ./PICOSGpt start 4b <空闲GPU>` |
| 检索无结果 / 429 | `./PICOSGpt test` 直接测工具；配置 `S2_API_KEY` |
| Codex 回答没有 `mcp:` 行 | 检查 `~/.codex/config.toml` 的 `default_tools_approval_mode = "approve"` |
| 手动验证代理 | `curl -H "Authorization: Bearer sk-123456" http://127.0.0.1:4000/v1/models` 应列出 `qwen3-14b` |

*本工具输出为文献综述，仅供科研/教学参考，不构成医疗建议。*
