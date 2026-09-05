import type { CSSProperties } from 'react'
import { ChevronRight, ExternalLink } from 'lucide-react'
import type { components } from '@/api/schema'
import { citationColor } from '@/lib/citations'
import { ListRow } from '@/components/common/ListRows'
import { Pill } from '@/components/common/Pill'
import { RankBadge } from '@/components/common/RankBadge'
import { SourceBadge } from '@/components/common/SourceBadge'
import {
  Tooltip,
  TooltipContent,
  TooltipTrigger,
} from '@/components/ui/tooltip'

type AnswerPaper = components['schemas']['AnswerPaper']
export type SourceCardProps = {
  paper: AnswerPaper
  index: number
  citedCount?: number
  compact?: boolean
  onOpen: (n: number, pid: number | null) => void
}

export function PaperExternalLinks({ paper }: { paper: AnswerPaper }) {
  const links = [
    paper.pmid
      ? {
          label: '在 PubMed 查看',
          href:
            'https://pubmed.ncbi.nlm.nih.gov/' +
            encodeURIComponent(paper.pmid) +
            '/',
        }
      : null,
    paper.doi
      ? {
          label: '通过 DOI 查看',
          href: 'https://doi.org/' + encodeURIComponent(paper.doi),
        }
      : null,
  ]
  return (
    <div className="flex shrink-0 items-center gap-1">
      {links.map(
        (link) =>
          link && (
            <Tooltip key={link.label}>
              <TooltipTrigger asChild>
                <a
                  href={link.href}
                  target="_blank"
                  rel="noopener noreferrer"
                  aria-label={link.label}
                  className="inline-flex size-8 items-center justify-center rounded-md text-muted-foreground transition-colors hover:bg-accent hover:text-foreground focus-visible:outline-2 focus-visible:outline-ring"
                >
                  <ExternalLink className="size-4" />
                </a>
              </TooltipTrigger>
              <TooltipContent>{link.label}</TooltipContent>
            </Tooltip>
          ),
      )}
    </div>
  )
}

export function SourceCard({
  paper,
  index,
  citedCount = 0,
  compact = false,
  onOpen,
}: SourceCardProps) {
  const verified = paper.n_citations_verified ?? 0
  const total = paper.n_citations ?? 0
  return (
    <ListRow index={index} className="flex gap-3 py-3.5">
      <span
        data-source-number
        className="tone-surface grid size-8 shrink-0 place-items-center rounded-md border font-mono text-[12px] font-semibold"
        style={{ '--citation-color': citationColor(paper.n) } as CSSProperties}
      >
        {paper.n}
      </span>
      <div className="min-w-0 flex-1 space-y-1.5">
        <button
          type="button"
          onClick={() => onOpen(paper.n, null)}
          className="block max-w-full text-left text-[14px] font-medium leading-6 break-words transition-colors group-hover:text-primary focus-visible:outline-2 focus-visible:outline-ring"
        >
          {paper.title || '未提供标题'}
        </button>
        <div className="metadata">
          {!compact && paper.authors && (
            <span className="min-w-0 break-words">{paper.authors}</span>
          )}
          {paper.journal && <i>{paper.journal}</i>}
          {paper.year && <span>{paper.year}</span>}
        </div>
        <div className="flex flex-wrap items-center gap-1.5">
          <RankBadge rank_label={paper.rank_label} quartile={paper.quartile} />
          {!compact && (
            <>
              <SourceBadge source={paper.source} />
              {paper.relevance != null && <Pill>相关性 {paper.relevance}</Pill>}
              <Pill tone={verified === total ? 'success' : 'warning'}>
                引文核实 {verified}/{total}
              </Pill>
              <span className="text-xs text-muted-foreground">
                正文引用 {citedCount} 处
              </span>
            </>
          )}
        </div>
      </div>
      <div className="flex shrink-0 items-center gap-1">
        {!compact && <PaperExternalLinks paper={paper} />}
        <ChevronRight className="size-4 text-muted-foreground opacity-0 transition-opacity group-hover:opacity-100" />
      </div>
    </ListRow>
  )
}
