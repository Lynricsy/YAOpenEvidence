import { ChevronDown } from 'lucide-react'
import type { components } from '@/api/schema'
import { SourceCard } from './SourceCard'
import { EmptyState } from './EmptyState'
import { Collapsible, CollapsibleContent, CollapsibleTrigger } from './ui/collapsible'

export type SourceListProps = {
  papers: components['schemas']['AnswerPaper'][]
  nFulltext: number
  citedCounts: Record<number, number>
  onOpen: (n: number, pid: number | null) => void
}

export function SourceList({ papers, nFulltext, citedCounts, onOpen }: SourceListProps) {
  const ordered = [...papers].sort((a, b) => a.n - b.n)
  const selected = ordered.filter(paper => paper.relevance !== 0)
  const unused = ordered.filter(paper => paper.relevance === 0)
  return <section aria-label="来源" className="min-w-0 border-t pt-6">
    <h2 className="mb-2 text-lg font-semibold">来源（{papers.length} 篇，{nFulltext} 篇全文）</h2>
    {!papers.length && <EmptyState title="没有结构化来源记录" />}
    {selected.map(paper => <SourceCard key={paper.n} paper={paper} citedCount={citedCounts[paper.n] ?? 0} onOpen={onOpen} />)}
    {unused.length > 0 && <Collapsible className="mt-3 border-t">
      <CollapsibleTrigger className="flex w-full items-center justify-between gap-2 py-4 text-left text-sm text-muted-foreground [&[data-state=open]>svg]:rotate-180">已阅读但未采用（{unused.length}）<ChevronDown className="size-4 shrink-0 transition-transform" /></CollapsibleTrigger>
      <CollapsibleContent className="text-muted-foreground">{unused.map(paper => <SourceCard key={paper.n} paper={paper} citedCount={citedCounts[paper.n] ?? 0} onOpen={onOpen} />)}</CollapsibleContent>
    </Collapsible>}
  </section>
}
