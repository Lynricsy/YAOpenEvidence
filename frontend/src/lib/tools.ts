import {
  BookOpen,
  Database,
  File,
  FileText,
  type LucideIcon,
  Quote,
  ScrollText,
  Search,
  Sparkles,
  Terminal,
  User,
  Wrench,
} from 'lucide-react'

/** MCP 工具名 -> 中文动作与图标；三端共用同一张表，轨迹在哪读都一样。 */
const TOOLS: Record<string, { label: string; icon: LucideIcon }> = {
  search_papers: { label: '检索 Semantic Scholar', icon: Search },
  pubmed_search: { label: '检索 PubMed', icon: Search },
  get_paper: { label: '查看论文详情', icon: FileText },
  pubmed_fetch: { label: '获取 PubMed 记录', icon: FileText },
  get_citations: { label: '查看引用文献', icon: Quote },
  get_references: { label: '查看参考文献', icon: BookOpen },
  get_recommendations: { label: '查找相似论文', icon: Sparkles },
  search_authors: { label: '检索作者', icon: User },
  get_fulltext: { label: '读取全文（PMC）', icon: ScrollText },
  read_pdf: { label: '读取 PDF', icon: File },
  kb_search: { label: '查询知识库', icon: Database },
  exec: { label: '执行命令', icon: Terminal },
}
/** 未登记的工具退回 `server/tool` 原文：宁可难看，也不要把它藏起来。 */
export function toolLabel(server: string, tool: string) {
  return TOOLS[tool]?.label ?? `${server}/${tool}`
}
export function toolIcon(tool: string): LucideIcon {
  return TOOLS[tool]?.icon ?? Wrench
}
/** 参数里最能说明「在查什么」的那一个键；顺序即优先级。 */
const ARG_KEYS = ['query', 'name', 'paper_id', 'pmids', 'path', 'command']
export function describeToolArgs(args: Record<string, unknown>) {
  const key = ARG_KEYS.find((k) => args[k] !== undefined && args[k] !== null)
  if (!key) return ''
  const raw = String(args[key])
  const section = args.section
  return (
    `「${raw.length > 60 ? `${raw.slice(0, 60)}…` : raw}」` +
    (typeof section === 'string' && section ? ` · ${section}` : '')
  )
}
export function formatDuration(ms: number | null) {
  return ms === null || !Number.isFinite(ms) ? '' : `${(ms / 1000).toFixed(1)}s`
}
