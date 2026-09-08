import { BookOpen, ChevronDown } from 'lucide-react'
import type { components } from '@/api/schema'
import { Pill } from '@/components/common/Pill'
import { RankBadge } from '@/components/common/RankBadge'
import { Button } from '@/components/ui/button'
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from '@/components/ui/collapsible'
import { PaperLinks } from '@/pages/explore/shared'

export type LiteratureRecord = components['schemas']['LiteratureRecord']

/** 上游 publicationType -> 中文；顺序即检索页筛选器的展示顺序。 */
export const PUBLICATION_TYPES = [
  ['Review', '综述'],
  ['Systematic Review', '系统综述'],
  ['Meta-Analysis', '荟萃分析'],
  ['Randomized Controlled Trial', '随机对照试验'],
  ['Clinical Trial', '临床试验'],
  ['Observational Study', '观察性研究'],
]

/**
 * 一条上游文献记录的卡片：检索结果与文献详情的引文图谱共用。
 * 不带 `onOpenFulltext` 时不渲染「查看全文目录」按钮。
 */
export function LiteratureRecordCard({
  paper,
  onOpenFulltext,
}: {
  paper: LiteratureRecord
  onOpenFulltext?: (paper: LiteratureRecord) => void
}) {
  return (
    <>
      <h2 className="break-words text-[15px] font-medium leading-6">
        {paper.title || paper.id}
      </h2>
      <p className="metadata break-words">
        {paper.authors?.slice(0, 3).join(', ')}
        {(paper.authors?.length ?? 0) > 3 && ' et al.'}
      </p>
      <p className="metadata">
        <i>{paper.journal}</i>
        {paper.year && ' (' + paper.year + ')'}
      </p>
      <div className="flex flex-wrap items-center gap-1.5">
        <RankBadge quartile={paper.rank?.quartile} />
        {paper.rank?.top && <Pill tone="success">Top</Pill>}
        {paper.types?.map((type) => (
          <Pill key={type}>
            {PUBLICATION_TYPES.find(([v]) => v === type)?.[1] ?? type}
          </Pill>
        ))}
        {paper.cited_by != null && (
          <span className="metadata">被引 {paper.cited_by}</span>
        )}
      </div>
      {(paper.tldr || paper.abstract) && (
        <Collapsible>
          <CollapsibleTrigger asChild>
            <Button variant="ghost" size="xs" className="px-0">
              <ChevronDown />
              摘要
            </Button>
          </CollapsibleTrigger>
          <CollapsibleContent className="space-y-3 pt-2">
            {paper.tldr && (
              <p className="whitespace-pre-wrap break-words text-sm leading-7">
                {paper.tldr}
              </p>
            )}
            {paper.abstract && (
              <p className="whitespace-pre-wrap break-words text-sm leading-7 text-muted-foreground">
                {paper.abstract}
              </p>
            )}
          </CollapsibleContent>
        </Collapsible>
      )}
      <div className="flex flex-wrap items-center justify-between gap-3">
        <PaperLinks
          pmid={paper.pmid}
          doi={paper.doi}
          pdf={paper.open_access_pdf}
        />
        {onOpenFulltext && (paper.pmcid || paper.pmid || paper.doi) && (
          <Button
            variant="outline"
            size="sm"
            onClick={() => onOpenFulltext(paper)}
          >
            <BookOpen />
            查看全文目录
          </Button>
        )}
      </div>
    </>
  )
}
