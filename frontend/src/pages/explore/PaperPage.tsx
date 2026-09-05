import { useState } from 'react'
import { Link, useParams, useSearchParams } from 'react-router'
import { ArrowLeft } from 'lucide-react'
import { usePaper, usePaperFacts, usePaperFulltext } from '@/api/queries'
import { ApiError } from '@/api/errors'
import { EmptyState } from '@/components/common/EmptyState'
import { Loading } from '@/components/common/Loading'
import { ParagraphMarkdown } from '@/components/common/ParagraphMarkdown'
import { QueryError } from '@/components/common/QueryError'
import { RankBadge } from '@/components/common/RankBadge'
import { SourceBadge } from '@/components/common/SourceBadge'
import { VerifiedPill } from '@/components/common/VerifiedPill'
import { Pill } from '@/components/common/Pill'
import {
  TabsListUnderline,
  TabsTriggerUnderline,
} from '@/components/common/UnderlineTabs'
import { Button } from '@/components/ui/button'
import { Tabs, TabsContent } from '@/components/ui/tabs'
import { kindLabel, PaperLinks, positivePid } from './shared'

export default function PaperPage() {
  const { key = '' } = useParams()
  const [params, setParams] = useSearchParams()
  const pid = positivePid(params.get('pid'))
  const [tab, setTab] = useState('fulltext')
  const paper = usePaper(key)
  const fulltext = usePaperFulltext(key, tab === 'fulltext' && paper.isSuccess)
  const facts = usePaperFacts(key, tab === 'facts' && paper.isSuccess)
  const target = key + ':' + (pid ?? '')
  const [previousTarget, setPreviousTarget] = useState(target)
  if (previousTarget !== target) {
    setPreviousTarget(target)
    setTab('fulltext')
  }
  function openParagraph(value: number) {
    setParams((current) => {
      const next = new URLSearchParams(current)
      next.set('pid', String(value))
      return next
    })
    setTab('fulltext')
  }
  return (
    <div className="h-full overflow-y-auto">
      <div className="page min-w-0 max-w-4xl">
        <Link
          to="/library"
          className="mb-6 inline-flex items-center gap-1.5 text-xs text-muted-foreground transition-colors hover:text-foreground"
        >
          <ArrowLeft className="size-4" />
          文献库
        </Link>
        {paper.isPending ? (
          <Loading />
        ) : paper.isError ? (
          paper.error instanceof ApiError && paper.error.status === 404 ? (
            <EmptyState title="文献不存在" />
          ) : (
            <QueryError error={paper.error} retry={paper.refetch} />
          )
        ) : (
          <>
            <header className="rounded-xl border bg-card p-6">
              <h1 className="break-words font-serif text-[22px] font-semibold leading-snug md:text-2xl">
                {paper.data.title || key}
              </h1>
              <p className="metadata mt-3 break-words">
                {paper.data.authors && <span>{paper.data.authors}</span>}
                {paper.data.journal && <i>{paper.data.journal}</i>}
                {paper.data.year && <span>{paper.data.year}</span>}
              </p>
              <div className="mt-3 flex flex-wrap items-center gap-1.5">
                <RankBadge quartile={paper.data.quartile} />
                <SourceBadge source={paper.data.source} />
                {paper.data.types?.map((type) => (
                  <Pill tone="neutral" key={type}>
                    {type}
                  </Pill>
                ))}
              </div>
              <div className="mt-3">
                <PaperLinks pmid={paper.data.pmid} doi={paper.data.doi} />
              </div>
            </header>
            <Tabs value={tab} onValueChange={setTab} className="mt-6 min-w-0">
              <TabsListUnderline>
                <TabsTriggerUnderline value="fulltext">
                  全文
                </TabsTriggerUnderline>
                <TabsTriggerUnderline value="facts">事实</TabsTriggerUnderline>
              </TabsListUnderline>
              <TabsContent value="fulltext" className="min-w-0">
                <div className="mx-auto max-w-[720px] pt-6">
                  {fulltext.isPending ? (
                    <Loading />
                  ) : fulltext.isError ? (
                    <QueryError
                      error={fulltext.error}
                      retry={fulltext.refetch}
                    />
                  ) : fulltext.data ? (
                    <ParagraphMarkdown markdown={fulltext.data} pid={pid} />
                  ) : (
                    <EmptyState title="暂无全文" />
                  )}
                </div>
              </TabsContent>
              <TabsContent value="facts" className="min-w-0">
                <div className="mx-auto max-w-[720px]">
                  {facts.isPending ? (
                    <Loading />
                  ) : facts.isError ? (
                    <QueryError error={facts.error} retry={facts.refetch} />
                  ) : facts.data?.items.length ? (
                    facts.data.items.map((fact, index) => (
                      <article
                        className="space-y-2 border-b py-4 last:border-b-0"
                        key={index}
                      >
                        <div className="flex flex-wrap items-center gap-1.5">
                          <Pill tone="neutral">
                            {kindLabel(fact.kind ?? 'finding')}
                          </Pill>
                          <VerifiedPill value={fact.verified ?? false} />
                          {fact.pid != null && fact.pid > 0 && (
                            <Button
                              size="xs"
                              variant="outline"
                              onClick={() => openParagraph(fact.pid!)}
                            >
                              ¶{fact.pid}
                            </Button>
                          )}
                          <span className="metadata">
                            {fact.sec}
                            {fact.page != null && ' · 第 ' + fact.page + ' 页'}
                          </span>
                        </div>
                        <p className="whitespace-pre-wrap break-words text-[14.5px] leading-7">
                          {fact.fact}
                        </p>
                        {fact.fact_zh && (
                          <p className="whitespace-pre-wrap break-words text-sm leading-7 text-muted-foreground">
                            {fact.fact_zh}
                          </p>
                        )}
                        {fact.quote && (
                          <blockquote className="border-l-2 border-primary/30 pl-3 text-sm leading-7">
                            {fact.quote}
                          </blockquote>
                        )}
                      </article>
                    ))
                  ) : (
                    <EmptyState title="暂无事实条目" />
                  )}
                </div>
              </TabsContent>
            </Tabs>
          </>
        )}
      </div>
    </div>
  )
}
