import type { CSSProperties } from 'react'
import type { components } from '@/api/schema'
import { citationColor } from '@/lib/citations'
import {
  HoverCard,
  HoverCardContent,
  HoverCardTrigger,
} from '@/components/ui/hover-card'
import { RankBadge } from '@/components/common/RankBadge'
import { QuoteHighlight } from '@/components/common/QuoteHighlight'
type Schemas = components['schemas']
export function CitationChip({
  n,
  pid,
  papers,
  citations,
  onOpen,
}: {
  n: number
  pid: number | null
  papers: Schemas['AnswerPaper'][]
  citations: Schemas['Citation'][]
  onOpen: (n: number, pid: number | null) => void
}) {
  const paper = papers.find((p) => p.n === n)
  const citation =
    pid === null ? undefined : citations.find((c) => c.n === n && c.pid === pid)
  const color = citationColor(n)
  return (
    <HoverCard openDelay={200} closeDelay={120}>
      <HoverCardTrigger asChild>
        <button
          type="button"
          data-citation={n + '-' + (pid ?? '')}
          aria-label={
            '查看第 ' +
            n +
            ' 篇' +
            (pid !== null ? '第 ' + pid + ' 段' : '文献')
          }
          onClick={() => onOpen(n, pid)}
          className="mx-0.5 inline-flex h-[18px] items-center rounded-[4px] border px-1 align-[2px] font-mono text-[10.5px] font-semibold leading-none no-underline transition-[filter] hover:brightness-95 dark:hover:brightness-125"
          style={{ '--citation-color': color } as CSSProperties}
        >
          {n}
          {pid !== null && <span className="ml-0.5 opacity-75">¶{pid}</span>}
        </button>
      </HoverCardTrigger>
      <HoverCardContent
        align="start"
        className="w-[min(400px,calc(100vw-2rem))] overflow-hidden p-0"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex gap-3 px-4 pt-3 pb-2">
          <span
            data-source-number
            className="tone-surface grid size-7 shrink-0 place-items-center rounded-md border font-mono text-[11px] font-semibold"
            style={{ '--citation-color': color } as CSSProperties}
          >
            {n}
          </span>
          <div className="min-w-0 flex-1">
            <p className="line-clamp-2 text-sm font-medium leading-5">
              {paper?.title || '第 ' + n + ' 篇'}
            </p>
            {paper && (
              <div className="metadata mt-1">
                {paper.journal && <i>{paper.journal}</i>}
                {paper.year && <span>{paper.year}</span>}
                <RankBadge
                  rank_label={paper.rank_label}
                  quartile={paper.quartile}
                />
              </div>
            )}
          </div>
        </div>
        <div className="border-t px-4 py-3">
          {citation ? (
            <>
              <p className="text-[11px] text-muted-foreground">
                {citation.sec} · ¶{citation.pid}
                {citation.page != null && ' · p.' + citation.page}
              </p>
              <div className="mt-1.5 max-h-52 overflow-y-auto border-l-2 border-primary/30 pl-3 text-xs leading-6">
                <QuoteHighlight
                  text={citation.text}
                  quotes={citation.quotes ?? []}
                />
              </div>
            </>
          ) : pid === null ? (
            <div className="space-y-2">
              {citations
                .filter((c) => c.n === n)
                .flatMap((c) => c.quotes ?? [])
                .slice(0, 3)
                .map((quote, i) => (
                  <p
                    className="border-l-2 border-primary/30 pl-3 text-xs leading-6"
                    key={i}
                  >
                    {quote}
                  </p>
                ))}
            </div>
          ) : (
            <p className="text-xs text-muted-foreground">¶{pid}</p>
          )}
        </div>
        <p className="border-t bg-muted/40 px-4 py-2 text-[11px] text-muted-foreground">
          点击在阅读器中定位到该段落
        </p>
      </HoverCardContent>
    </HoverCard>
  )
}
