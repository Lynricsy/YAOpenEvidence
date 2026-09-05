import type { ReactNode } from 'react'
import { ArrowUpRight, Check, LoaderCircle, RotateCw, X } from 'lucide-react'
import { problemMessage } from '@/api/errors'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'

export function Loading({ children = '正在加载…' }: { children?: ReactNode }) {
  return <div role="status" className="flex items-center gap-2 py-8 text-sm text-muted-foreground"><LoaderCircle className="size-4 shrink-0 animate-spin" />{children}</div>
}
export function QueryError({ error, retry }: { error: unknown; retry: () => unknown }) {
  return <div role="alert" className="error-panel flex flex-wrap items-center justify-between gap-3"><span className="min-w-0 break-words">{problemMessage(error)}</span><Button variant="outline" size="sm" onClick={() => void retry()}><RotateCw />重试</Button></div>
}
export function Verified({ value }: { value?: boolean | null }) {
  if (value == null) return null
  return <Badge variant="outline" className={value ? 'status-green' : 'status-amber'}>{value ? <Check className="size-3" /> : <X className="size-3" />}{value ? '已核实' : '未核实'}</Badge>
}
export function ExternalLink({ href, children }: { href?: string | null; children: ReactNode }) {
  if (!href) return null
  try { if (!['https:', 'http:'].includes(new URL(href).protocol)) return null } catch { return null }
  return <a href={href} target="_blank" rel="noopener noreferrer" className="inline-flex items-center gap-1 text-sm text-primary hover:underline">{children}<ArrowUpRight className="size-3.5 shrink-0" /></a>
}
export function PaperLinks({ pmid, doi, pdf }: { pmid?: string | null; doi?: string | null; pdf?: string | null }) {
  return <div className="flex flex-wrap items-center gap-4">{pmid && <ExternalLink href={'https://pubmed.ncbi.nlm.nih.gov/' + encodeURIComponent(pmid) + '/'}>PubMed</ExternalLink>}{doi && <ExternalLink href={'https://doi.org/' + doi.split('/').map(encodeURIComponent).join('/')}>DOI</ExternalLink>}<ExternalLink href={pdf}>开放 PDF</ExternalLink></div>
}
export function positivePid(value: string | null) {
  if (!value || !/^\d+$/.test(value)) return null
  const pid = Number(value)
  return Number.isSafeInteger(pid) && pid > 0 ? pid : null
}
export function kindLabel(kind: string) { return ({ fact: '事实', paragraph: '段落', finding: '发现', method: '方法', limitation: '局限', background: '背景' } as Record<string, string>)[kind] ?? kind }
