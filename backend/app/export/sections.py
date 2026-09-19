"""把综述正文按 `core/ask.py` `SYN_SYS` 约定的四个标签切成分节。

逐字移植自 `frontend/src/lib/answerSections.ts`（Apple / Flutter 各有一份同源实现，
这是第四份）：真实语料存在三种标签形态——`**标签**` 独占一行、`**标签** — 正文`、
`**标签**:` + 行尾硬换行；模型偶尔改用 `## 标签` 标题。切分只识别标签本身，模块的
标题文字由渲染层的固定元数据决定（见 `answer_pdf.MODULES`），不复用模型写的字面量。
任何一端改规则，四份必须同步。
"""
from __future__ import annotations

import re
from dataclasses import dataclass
from typing import Literal

SectionKind = Literal["conclusion", "evidence", "picos", "caveats", "other"]

#: `**标签**`（可带 `#` 前缀）后可选 破折号/冒号 分隔符，组 2 为同行余文。
BOLD_LABEL = re.compile(r"^\s*(?:#{1,6}\s+)?\*\*([^*\n]+?)\*\*\s*(?:[—–\-:：]\s*)?(.*)$")
#: `## 标签` 形态，无同行余文。
HEADING_LABEL = re.compile(r"^\s*#{1,6}\s+([^\n]+?)\s*$")


@dataclass
class AnswerSection:
    kind: SectionKind
    markdown: str


def section_kind_of(label: str) -> SectionKind | None:
    """标签文字 → 分节类型。

    全部按「前缀」匹配：真实标签都以关键词开头（`结论 / Bottom line`、`证据 / Evidence`、
    `PICOS 证据表 / PICOS table`、`局限 / Caveats`）。用包含匹配会把 `# Q: …的证据强度`
    这类问题标题误判成分节头。判定顺序不可调整：picos 先于 evidence。
    """
    label = label.strip()
    lower = label.lower()
    if label.startswith("结论") or lower.startswith("bottom line"):
        return "conclusion"
    if lower.startswith("picos"):
        return "picos"
    if label.startswith("证据") or lower.startswith("evidence"):
        return "evidence"
    if label.startswith("局限") or lower.startswith(("caveat", "limitation")):
        return "caveats"
    return None


def _section_head(line: str) -> tuple[SectionKind, str] | None:
    bold = BOLD_LABEL.match(line)
    if bold:
        kind = section_kind_of(bold.group(1) or "")
        if kind:
            return kind, bold.group(2) or ""
    heading = HEADING_LABEL.match(line)
    if heading:
        kind = section_kind_of(heading.group(1) or "")
        if kind:
            return kind, ""
    return None


def split_answer_sections(markdown: str) -> list[AnswerSection]:
    """按分节头切分正文，保持文档顺序。

    空白节丢弃；同一个已知 kind 重复出现时合并到首次出现的节（`\\n\\n` 连接），
    `other` 可出现多次（前言或未识别标签之间的内容）。
    """
    sections: list[AnswerSection] = []
    kind: SectionKind = "other"
    buffer: list[str] = []

    def flush() -> None:
        nonlocal buffer
        md = "\n".join(buffer).strip()
        buffer = []
        if not md:
            return
        existing = None if kind == "other" else next((s for s in sections if s.kind == kind), None)
        if existing is not None:
            existing.markdown += "\n\n" + md
        else:
            sections.append(AnswerSection(kind, md))

    for line in markdown.replace("\r\n", "\n").split("\n"):
        head = _section_head(line)
        if head is None:
            buffer.append(line)
            continue
        flush()
        kind, rest = head
        if rest:
            buffer.append(rest)
    flush()
    return sections


def has_known_sections(sections: list[AnswerSection]) -> bool:
    """正文里是否出现过已识别的分节头；否则整段走单块渲染回退。"""
    return any(s.kind != "other" for s in sections)
