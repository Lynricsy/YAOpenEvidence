import type { CSSProperties } from 'react'
import { ExternalLink } from 'lucide-react'
import type { components } from '@/api/schema'
import { citationColor } from '@/lib/citations'
import { RankBadge } from './RankBadge'
import { SourceBadge } from './SourceBadge'
import { Badge } from './ui/badge'
import { Tooltip, TooltipContent, TooltipTrigger } from './ui/tooltip'

type AnswerPaper = components['schemas']['AnswerPaper']
export type SourceCardProps = {
  paper: AnswerPaper
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
                  className="inline-flex size-9 items-center justify-center rounded-md hover:bg-muted focus-visible:outline-2 focus-visible:outline-ring"
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
  citedCount = 0,
  compact = false,
  onOpen,
}: SourceCardProps) {
  const verified = paper.n_citations_verified ?? 0
  const total = paper.n_citations ?? 0
  return (
    <article className="flex min-w-0 gap-3 border-b py-4 last:border-b-0">
      <span
        data-source-number
        className="flex size-9 shrink-0 items-center justify-center rounded-md border font-mono text-sm"
        style={{ '--citation-color': citationColor(paper.n) } as CSSProperties}
      >
        [{paper.n}]
      </span>
      <div className="min-w-0 flex-1 space-y-2">
        <button
          type="button"
          onClick={() => onOpen(paper.n, null)}
          className="block max-w-full text-left text-sm font-semibold leading-6 break-words hover:text-primary focus-visible:outline-2 focus-visible:outline-ring"
        >
          {paper.title || '未提供标题'}
        </button>
        <div className="flex flex-wrap gap-x-2 gap-y-1 text-xs leading-5 break-words text-muted-foreground">
          {!compact && paper.authors && (
            <span className="min-w-0">{paper.authors} ·</span>
          )}
          {paper.journal && <i>{paper.journal}</i>}
          {paper.year && <span>{paper.year}</span>}
        </div>
        <div className="flex flex-wrap items-center gap-2">
          <RankBadge rank_label={paper.rank_label} quartile={paper.quartile} />
          {!compact && (
            <>
              <SourceBadge source={paper.source} />
              {paper.relevance != null && (
                <Badge variant="outline">相关性 {paper.relevance}</Badge>
              )}
              <Badge
                variant="outline"
                className={verified === total ? 'status-green' : 'status-amber'}
              >
                引文核实 {verified}/{total}
              </Badge>
              <Badge variant="outline">正文引用 {citedCount} 处</Badge>
            </>
          )}
        </div>
      </div>
      {!compact && <PaperExternalLinks paper={paper} />}
    </article>
  )
}
