/**
 * 把综述正文按 `core/ask.py` `SYN_SYS` 约定的四个标签切成分节，供答案页分模块渲染。
 *
 * 真实语料存在三种标签形态：`**标签**` 独占一行、`**标签** — 正文`、`**标签**:` +
 * 行尾硬换行；模型偶尔改用 `## 标签` 标题。切分只识别标签本身，模块的标题文字与
 * 图标由渲染层的固定元数据决定（见 `SectionHeading`），不复用模型写的字面量。
 */
export type SectionKind =
  'conclusion' | 'evidence' | 'picos' | 'caveats' | 'other'

export type AnswerSection = { kind: SectionKind; markdown: string }

/** `**标签**`（可带 `#` 前缀）后可选 破折号/冒号 分隔符，组 2 为同行余文。 */
const BOLD_LABEL =
  /^\s*(?:#{1,6}\s+)?\*\*([^*\n]+?)\*\*\s*(?:[—–\-:：]\s*)?(.*)$/
/** `## 标签` 形态，无同行余文。 */
const HEADING_LABEL = /^\s*#{1,6}\s+([^\n]+?)\s*$/

/**
 * 标签文字 → 分节类型。全部按「前缀」匹配：真实标签都以关键词开头
 * （`结论 / Bottom line`、`证据 / Evidence`、`PICOS 证据表 / PICOS table`、
 * `局限 / Caveats`）。用包含匹配会把 `# Q: …的证据强度` 这类问题标题误判成分节头。
 * 判定顺序不可调整：picos 先于 evidence。
 */
export function sectionKindOf(label: string): SectionKind | null {
  const l = label.trim()
  const lower = l.toLowerCase()
  if (l.startsWith('结论') || lower.startsWith('bottom line'))
    return 'conclusion'
  if (lower.startsWith('picos')) return 'picos'
  if (l.startsWith('证据') || lower.startsWith('evidence')) return 'evidence'
  if (
    l.startsWith('局限') ||
    lower.startsWith('caveat') ||
    lower.startsWith('limitation')
  )
    return 'caveats'
  return null
}

function sectionHead(line: string): { kind: SectionKind; rest: string } | null {
  const bold = BOLD_LABEL.exec(line)
  if (bold) {
    const kind = sectionKindOf(bold[1] ?? '')
    if (kind) return { kind, rest: bold[2] ?? '' }
  }
  const heading = HEADING_LABEL.exec(line)
  if (heading) {
    const kind = sectionKindOf(heading[1] ?? '')
    if (kind) return { kind, rest: '' }
  }
  return null
}

/**
 * 按分节头切分正文，保持文档顺序。空白节丢弃；同一个已知 kind 重复出现时合并到
 * 首次出现的节（`\n\n` 连接），`other` 可出现多次（前言或未识别标签之间的内容）。
 */
export function splitAnswerSections(markdown: string): AnswerSection[] {
  const sections: AnswerSection[] = []
  let kind: SectionKind = 'other'
  let buffer: string[] = []
  const flush = () => {
    const md = buffer.join('\n').trim()
    buffer = []
    if (!md) return
    const existing =
      kind === 'other' ? undefined : sections.find((s) => s.kind === kind)
    if (existing) existing.markdown += '\n\n' + md
    else sections.push({ kind, markdown: md })
  }
  for (const line of markdown.replace(/\r\n/g, '\n').split('\n')) {
    const head = sectionHead(line)
    if (!head) {
      buffer.push(line)
      continue
    }
    flush()
    kind = head.kind
    if (head.rest) buffer.push(head.rest)
  }
  flush()
  return sections
}

/** 正文里是否出现过已识别的分节头；否则整段走单块渲染回退。 */
export function hasKnownSections(sections: AnswerSection[]): boolean {
  return sections.some((s) => s.kind !== 'other')
}
