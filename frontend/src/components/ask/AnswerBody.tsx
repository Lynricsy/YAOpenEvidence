import { ChevronDown } from 'lucide-react'
import type { components } from '@/api/schema'
import { useAnswerMarkdown } from '@/api/queries'
import { problemMessage } from '@/api/errors'
import {
  ANSWER_MD_LINK_RE,
  markersToLinks,
  parseCiteHref,
} from '@/lib/citations'
import { MarkdownView } from '@/components/common/MarkdownView'
import { Pill } from '@/components/common/Pill'
import { Skeleton } from '@/components/ui/skeleton'
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from '@/components/ui/collapsible'
import { CitationChip } from './CitationChip'

export function AnswerBody({
  answer,
  onOpen,
}: {
  answer: components['schemas']['Answer']
  onOpen: (n: number, pid: number | null) => void
}) {
  const legacy = useAnswerMarkdown(
    answer.id,
    answer.body_md == null && answer.status === 'ready',
  )
  const papers = answer.papers ?? [],
    citations = answer.citations ?? []
  const markdown =
    answer.body_md != null
      ? markersToLinks(answer.body_md, Math.max(0, ...papers.map((p) => p.n)))
      : (legacy.data ?? '')
  return (
    <section>
      {legacy.isFetching && !legacy.data && answer.body_md == null ? (
        <Skeleton className="h-60 w-full" />
      ) : legacy.error && answer.body_md == null ? (
        <p className="error-panel">{problemMessage(legacy.error)}</p>
      ) : (
        <MarkdownView
          markdown={markdown}
          className="prose-answer"
          components={{
            a: ({ href, children }) => {
              const parsed = parseCiteHref(href ?? '')
              const old = ANSWER_MD_LINK_RE.exec(href ?? '')
              const cite =
                parsed ??
                (old
                  ? { n: Number(old[1]), pid: old[2] ? Number(old[2]) : null }
                  : null)
              return cite ? (
                <CitationChip
                  {...cite}
                  papers={papers}
                  citations={citations}
                  onOpen={onOpen}
                />
              ) : (
                <a href={href} target="_blank" rel="noreferrer">
                  {children}
                </a>
              )
            },
          }}
        />
      )}
      {!!answer.kb_hits?.length && (
        <Collapsible>
          <CollapsibleTrigger className="mt-10 flex w-full items-center justify-between border-t pt-4 text-sm font-medium [&>svg]:transition-transform [&[data-state=open]>svg]:rotate-180">
            知识库补充（{answer.kb_hits.length}）
            <ChevronDown className="size-4 shrink-0" />
          </CollapsibleTrigger>
          <CollapsibleContent>
            {answer.kb_hits.map((hit, i) => (
              <article
                className="space-y-2 border-b py-4 last:border-b-0"
                key={i}
              >
                <div className="metadata">
                  <Pill>{hit.kind === 'fact' ? '事实' : '段落'}</Pill>
                  <span className="tabular-nums">
                    相似度 {hit.score.toFixed(2)}
                  </span>
                </div>
                <p className="text-sm leading-7">{hit.text}</p>
                {hit.text_zh && (
                  <p className="text-sm text-muted-foreground">{hit.text_zh}</p>
                )}
                <p className="metadata">
                  {hit.title} · {hit.journal} ({hit.year})
                </p>
              </article>
            ))}
          </CollapsibleContent>
        </Collapsible>
      )}
    </section>
  )
}
