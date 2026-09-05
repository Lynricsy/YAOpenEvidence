import type { components } from '@/api/schema'
import { useAnswerMarkdown } from '@/api/queries'
import { problemMessage } from '@/api/errors'
import { ANSWER_MD_LINK_RE, markersToLinks, parseCiteHref } from '@/lib/citations'
import { MarkdownView } from './MarkdownView'
import { CitationChip } from './CitationChip'
import { Badge } from './ui/badge'
import { Skeleton } from './ui/skeleton'
import { Collapsible, CollapsibleTrigger, CollapsibleContent } from './ui/collapsible'
import { ChevronDown, ListChecks } from 'lucide-react'
export function AnswerBody({ answer, onOpen }: { answer: components['schemas']['Answer']; onOpen: (n: number, pid: number | null) => void }) {
  const legacy = useAnswerMarkdown(answer.id, answer.body_md == null && answer.status === 'ready')
  const papers = answer.papers ?? [], citations = answer.citations ?? []
  const markdown = answer.body_md != null ? markersToLinks(answer.body_md, Math.max(0,...papers.map(p => p.n))) : legacy.data ?? ''
  return <section className="py-7"><h2 className="section-eyebrow mb-5"><ListChecks className="size-4" />回答</h2>{legacy.isFetching && !legacy.data && answer.body_md == null ? <Skeleton className="h-60 w-full" /> : legacy.error && answer.body_md == null ? <p className="error-panel">{problemMessage(legacy.error)}</p> : <MarkdownView markdown={markdown} components={{ a: ({ href, children }) => { const parsed = parseCiteHref(href ?? ''); const old = ANSWER_MD_LINK_RE.exec(href ?? ''); const cite = parsed ?? (old ? {n:Number(old[1]),pid:old[2] ? Number(old[2]) : null} : null); return cite ? <CitationChip {...cite} papers={papers} citations={citations} onOpen={onOpen} /> : <a href={href} target="_blank" rel="noreferrer">{children}</a> } }} />}{!!answer.kb_hits?.length && <Collapsible className="mt-8 border-t pt-4"><CollapsibleTrigger className="flex items-center gap-2 text-sm"><ChevronDown className="size-4" />知识库补充（{answer.kb_hits.length}）</CollapsibleTrigger><CollapsibleContent>{answer.kb_hits.map((hit,i) => <article className="list-row space-y-3" key={i}><div className="metadata"><Badge variant="secondary">{hit.kind === 'fact' ? '事实' : '段落'}</Badge><span>相似度 {hit.score.toFixed(2)}</span></div><p className="text-sm leading-7">{hit.text}</p>{hit.text_zh && <p className="text-sm text-muted-foreground">{hit.text_zh}</p>}<p className="metadata">{hit.title} · {hit.journal} ({hit.year})</p></article>)}</CollapsibleContent></Collapsible>}</section>
}
