import type { components } from '@/api/schema'
import { citationColor } from '@/lib/citations'
import { HoverCard, HoverCardTrigger, HoverCardContent } from './ui/hover-card'
import { RankBadge } from './RankBadge'
import { QuoteHighlight } from './QuoteHighlight'
type Schemas = components['schemas']
export function CitationChip({ n, pid, papers, citations, onOpen }: { n: number; pid: number | null; papers: Schemas['AnswerPaper'][]; citations: Schemas['Citation'][]; onOpen: (n: number, pid: number | null) => void }) {
  const paper = papers.find(p => p.n === n)
  const citation = pid === null ? undefined : citations.find(c => c.n === n && c.pid === pid)
  const color = citationColor(n)
  return <HoverCard openDelay={200} closeDelay={120}><HoverCardTrigger asChild><button type="button" data-citation={n + '-' + (pid ?? '')} aria-label={'查看第 ' + n + ' 篇' + (pid !== null ? '第 ' + pid + ' 段' : '文献')} onClick={() => onOpen(n,pid)} className="mx-0.5 inline-flex h-5 items-center rounded border px-1.5 align-baseline font-mono text-[11px] font-semibold leading-none no-underline" style={{color,backgroundColor:color+'12',borderColor:color+'35'}}>{n}{pid !== null && <span className="ml-0.5 opacity-75">¶{pid}</span>}</button></HoverCardTrigger><HoverCardContent align="start" className="w-[min(420px,calc(100vw-2rem))] space-y-3 text-sm" onClick={e => e.stopPropagation()}><p className="line-clamp-2 font-semibold leading-6">{paper?.title || '第 ' + n + ' 篇'}</p>{paper && <div className="metadata"><i>{paper.journal}</i><span>{paper.year}</span><RankBadge rank_label={paper.rank_label} quartile={paper.quartile} /></div>}{citation ? <><p className="text-xs text-muted-foreground">{citation.sec} · ¶{citation.pid}{citation.page != null && ' · p.' + citation.page}</p><p className="max-h-56 overflow-y-auto border-l-2 border-primary/25 pl-3 text-xs leading-6"><QuoteHighlight text={citation.text} quotes={citation.quotes ?? []} /></p></> : pid === null ? citations.filter(c => c.n === n).flatMap(c => c.quotes ?? []).slice(0,3).map((quote,i) => <p className="border-l-2 pl-3 text-xs leading-6" key={i}>{quote}</p>) : <p className="text-xs text-muted-foreground">¶{pid}</p>}</HoverCardContent></HoverCard>
}
