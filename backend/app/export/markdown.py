"""正文 Markdown → 打印用 HTML，并把段落级引用标记变成可跳转的芯片。

标记与链接的识别规则逐字对齐 `frontend/src/lib/citations.ts`（`MARKER_RE`、
`ANSWER_MD_LINK_RE`、`citationColors`）。两种引用来源都要处理：

* 结构化正文里的裸标记 `[3]` / `[3¶12]`（`core/ask.py` `resolve_markers` 归一化后的形态）；
* `services.answers.http_answer_markdown` 重写出来的
  `[3¶12](/v1/answers/<id>/papers/3/markdown#p12)` 链接。

解析器一律 `html=False`：正文里的原始 HTML 被转义，不存在 sanitize 白名单问题。
"""
from __future__ import annotations

import re
from html import escape
from typing import TypedDict

from markdown_it import MarkdownIt
from markdown_it.rules_core import StateCore
from markdown_it.token import Token


class Env(TypedDict):
    """core 规则与调用方之间的上下文：引用上限、附录段落集合、收集到的引用。"""

    max_n: int
    passages: set[tuple[int, int]]
    used: list[tuple[int, int | None]]


#: `[3]` / `[3¶12]`；与 Web 端同一个正则。
MARKER_RE = re.compile(r"\[(\d{1,2})(?:¶(\d{1,4}))?\]")
#: 本次阅读快照的原文链接，组 1 是论文编号，组 2 是段落 id。
ANSWER_MD_LINK_RE = re.compile(r"^/v1/answers/[^/]+/papers/(\d+)/markdown(?:#p(\d+))?$")

#: 论文编号 → 芯片颜色；与 Web `citationColors`、Apple / Flutter 同源。
CITATION_COLORS = [
    "#087f96",
    "#956124",
    "#6366a0",
    "#297d54",
    "#b34f69",
    "#397bb5",
    "#89742c",
    "#7d5b9e",
]


def citation_color(n: int) -> str:
    if n < 1:
        return CITATION_COLORS[0]
    return CITATION_COLORS[(n - 1) % len(CITATION_COLORS)]


def _chip_html(n: int, pid: int | None, passages: set[tuple[int, int]]) -> str:
    """引用芯片：命中附录段落时链到附录条目，否则链到参考文献条目。"""
    suffix = f"<span>¶{pid}</span>" if pid is not None else ""
    href = f"#c-{n}-{pid}" if pid is not None and (n, pid) in passages else f"#ref-{n}"
    return f'<a class="cite" href="{href}" style="--c:{citation_color(n)}">{n}{suffix}</a>'


def _chip_token(n: int, pid: int | None, env: Env) -> Token:
    env["used"].append((n, pid))
    return Token("html_inline", "", 0, content=_chip_html(n, pid, env["passages"]))


def _split_markers(content: str, env: Env) -> list[Token]:
    """把一段纯文本按标记切成 文本/芯片 交替的 token 序列。"""
    out: list[Token] = []
    cursor = 0
    for match in MARKER_RE.finditer(content):
        n = int(match.group(1))
        if not 1 <= n <= env["max_n"]:  # 越界编号与 [2024] 这类年份保持字面
            continue
        if match.start() > cursor:
            out.append(Token("text", "", 0, content=content[cursor:match.start()]))
        pid = int(match.group(2)) if match.group(2) else None
        out.append(_chip_token(n, pid, env))
        cursor = match.end()
    if not out:
        return []
    if cursor < len(content):
        out.append(Token("text", "", 0, content=content[cursor:]))
    return out


def _citations(state: StateCore) -> None:
    """core 规则：把标记与原文链接换成芯片。

    必须挂在 `text_join` 之前——转义产生的 `text_special`（`\\[1¶3]`）此时还是独立
    token，不会被 `MARKER_RE` 扫到，合并之后就分不出来了。行内代码是 `code_inline`，
    天然跳过；外链保持原样。
    """
    env: Env = state.env
    for token in state.tokens:
        if token.type != "inline" or not token.children:
            continue
        out: list[Token] = []
        depth = 0
        dropping = False
        for child in token.children:
            if child.type == "link_open":
                depth += 1
                if depth == 1:
                    match = ANSWER_MD_LINK_RE.match(child.attrGet("href") or "")
                    if match:
                        dropping = True
                        pid = int(match.group(2)) if match.group(2) else None
                        out.append(_chip_token(int(match.group(1)), pid, env))
                        continue
                if not dropping:
                    out.append(child)
                continue
            if child.type == "link_close":
                depth -= 1
                if depth == 0 and dropping:
                    dropping = False
                    continue
                if not dropping:
                    out.append(child)
                continue
            if dropping:
                continue
            if child.type == "text" and depth == 0 and env["max_n"] > 0:
                pieces = _split_markers(child.content, env)
                if pieces:
                    out.extend(pieces)
                    continue
            out.append(child)
        token.children = out


def _parser() -> MarkdownIt:
    md = MarkdownIt("commonmark", {"html": False}).enable(["table", "strikethrough"])
    md.core.ruler.before("text_join", "citations", _citations)
    return md


_MD = _parser()


def render_markdown(
    markdown: str, *, max_n: int, passages: set[tuple[int, int]]
) -> tuple[str, list[tuple[int, int | None]]]:
    """渲染一段正文。

    `max_n` 是本次论文数上限（0 表示不把裸标记当引用，用于没有结构化 papers 的答案），
    `passages` 是附录里真实存在的 `(n, pid)`。返回 HTML 与出现过的引用列表（可重复，
    用于统计每篇被正文引用了几处）。
    """
    env: Env = {"max_n": max_n, "passages": passages, "used": []}
    html = _MD.render(markdown, env)
    return html, env["used"]


def highlight_quotes(text: str, quotes: list[str]) -> str:
    """在段落原文里高亮核实过的引文；算法与 `QuoteHighlight.tsx` 一致。

    每条 quote 只取首次出现位置，按起点排序，与已高亮区间重叠的直接跳过。
    """
    ranges = sorted(
        (start, start + len(q))
        for q in quotes
        if q and (start := text.find(q)) >= 0
    )
    out: list[str] = []
    cursor = 0
    for start, end in ranges:
        if start < cursor:
            continue
        out.append(escape(text[cursor:start]))
        out.append(f"<mark>{escape(text[start:end])}</mark>")
        cursor = end
    out.append(escape(text[cursor:]))
    return "".join(out)
