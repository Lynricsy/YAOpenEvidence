import { ChevronDown } from 'lucide-react'
import type { components } from '@/api/schema'
import { EmptyState } from '@/components/common/EmptyState'
import { ListRows } from '@/components/common/ListRows'
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from '@/components/ui/collapsible'
import { SourceCard } from './SourceCard'
import { SectionHeading } from './SectionHeading'

export type SourceListProps = {
  papers: components['schemas']['AnswerPaper'][]
  nFulltext: number
  citedCounts: Record<number, number>
  onOpen: (n: number, pid: number | null) => void
}

export function SourceList({
  papers,
  nFulltext,
  citedCounts,
  onOpen,
}: SourceListProps) {
  const ordered = [...papers].sort((a, b) => a.n - b.n)
  const selected = ordered.filter((paper) => paper.relevance !== 0)
  const unused = ordered.filter((paper) => paper.relevance === 0)
  return (
    <section aria-label="来源" className="min-w-0">
      <SectionHeading
        module="sources"
        count={`${papers.length} 篇 · ${nFulltext} 篇全文`}
      />
      {!papers.length && <EmptyState title="没有结构化来源记录" />}
      <div className="mt-2">
        <ListRows>
          {selected.map((paper, index) => (
            <SourceCard
              key={paper.n}
              index={index}
              paper={paper}
              citedCount={citedCounts[paper.n] ?? 0}
              onOpen={onOpen}
            />
          ))}
        </ListRows>
      </div>
      {unused.length > 0 && (
        <Collapsible>
          <CollapsibleTrigger className="mt-2 flex w-full items-center justify-between border-t py-3 text-sm text-muted-foreground transition-colors hover:text-foreground [&>svg]:transition-transform [&[data-state=open]>svg]:rotate-180">
            已阅读但未采用（{unused.length}）
            <ChevronDown className="size-4 shrink-0" />
          </CollapsibleTrigger>
          <CollapsibleContent className="text-muted-foreground">
            <ListRows>
              {unused.map((paper, index) => (
                <SourceCard
                  key={paper.n}
                  index={index}
                  paper={paper}
                  citedCount={citedCounts[paper.n] ?? 0}
                  onOpen={onOpen}
                />
              ))}
            </ListRows>
          </CollapsibleContent>
        </Collapsible>
      )}
    </section>
  )
}
