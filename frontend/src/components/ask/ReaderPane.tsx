import { useState, type CSSProperties } from 'react'
import { Star, X } from 'lucide-react'
import * as m from 'motion/react-m'
import type { components } from '@/api/schema'
import { ApiError, problemMessage } from '@/api/errors'
import { useAnswerPaper, usePaperMarkdown } from '@/api/queries'
import { citationColor } from '@/lib/citations'
import { ease } from '@/lib/motion'
import { EmptyState } from '@/components/common/EmptyState'
import { Loading } from '@/components/common/Loading'
import { MarkdownView } from '@/components/common/MarkdownView'
import { ParagraphMarkdown } from '@/components/common/ParagraphMarkdown'
import { Pill } from '@/components/common/Pill'
import { RankBadge } from '@/components/common/RankBadge'
import { SourceBadge } from '@/components/common/SourceBadge'
import { VerifiedPill } from '@/components/common/VerifiedPill'
import {
  TabsListUnderline,
  TabsTriggerUnderline,
} from '@/components/common/UnderlineTabs'
import { Button } from '@/components/ui/button'
import { ScrollArea } from '@/components/ui/scroll-area'
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from '@/components/ui/sheet'
import { Tabs, TabsContent } from '@/components/ui/tabs'
import { PaperExternalLinks } from './SourceCard'

export type ReaderProps = {
  answerId: string
  n: number
  pid: number | null
  papers: components['schemas']['AnswerPaper'][]
  citations: components['schemas']['Citation'][]
  onClose: () => void
}

const factKinds: Record<string, string> = {
  finding: '研究发现',
  method: '研究方法',
  background: '背景',
  limitation: '局限性',
}

function PaperReader({
  answerId,
  n,
  pid,
  papers,
  citations,
  onClose,
}: ReaderProps) {
  const detail = useAnswerPaper(answerId, n)
  const fallbackEnabled =
    detail.error instanceof ApiError && detail.error.status === 404
  const fallback = usePaperMarkdown(answerId, n, fallbackEnabled)
  const [tab, setTab] = useState('fulltext')
  const [targetPid, setTargetPid] = useState(pid)
  const paper = detail.data ?? papers.find((item) => item.n === n)
  const error = fallbackEnabled ? fallback.error : detail.error
  const pending = fallbackEnabled ? fallback.isPending : detail.isPending
  const missing =
    fallbackEnabled &&
    fallback.error instanceof ApiError &&
    fallback.error.status === 404
  const markdown = fallbackEnabled ? fallback.data : detail.data?.fulltext_md
  const quotes = citations.find(
    (citation) => citation.n === n && citation.pid === targetPid,
  )?.quotes
  const verifiedQuotes = detail.data?.citations ?? []
  const facts = detail.data?.facts ?? []
  const openParagraph = (nextPid: number) => {
    setTargetPid(nextPid)
    setTab('fulltext')
  }
  return (
    <>
      <div className="flex items-start gap-3 border-b px-4 py-3">
        <span
          data-source-number
          className="tone-surface grid size-7 shrink-0 place-items-center rounded-md border font-mono text-[11px] font-semibold"
          style={{ '--citation-color': citationColor(n) } as CSSProperties}
        >
          {n}
        </span>
        <div className="min-w-0 flex-1">
          <p
            className="line-clamp-3 text-[14px] font-medium leading-5 break-words"
            title={paper?.title || undefined}
          >
            {paper?.title || '第 ' + n + ' 篇文献'}
          </p>
          {paper && (
            <>
              <div className="metadata mt-1">
                {paper.authors && (
                  <span className="min-w-0 break-words">{paper.authors}</span>
                )}
                {paper.journal && <i>{paper.journal}</i>}
                {paper.year && <span>{paper.year}</span>}
              </div>
              <div className="flex flex-wrap items-center gap-1.5 pt-1">
                <RankBadge
                  rank_label={paper.rank_label}
                  quartile={paper.quartile}
                />
                <SourceBadge source={paper.source} />
                <PaperExternalLinks paper={paper} />
              </div>
            </>
          )}
        </div>
        <Button
          variant="ghost"
          size="icon-sm"
          aria-label="关闭原文阅读器"
          title="关闭原文阅读器"
          onClick={onClose}
        >
          <X />
        </Button>
      </div>
      {pending ? (
        <div className="px-4 sm:px-6">
          <Loading>正在加载文献材料…</Loading>
        </div>
      ) : missing ? (
        <EmptyState title="此答案没有逐篇材料（旧版导入）" />
      ) : error ? (
        <div role="alert" className="error-panel m-4">
          <p>{problemMessage(error)}</p>
          {error instanceof ApiError &&
            error.detail &&
            error.detail !== problemMessage(error) && (
              <p className="mt-2 text-sm break-words">{error.detail}</p>
            )}
          <Button
            variant="outline"
            size="sm"
            className="mt-3"
            onClick={() => {
              void (fallbackEnabled ? fallback.refetch() : detail.refetch())
            }}
          >
            重试
          </Button>
        </div>
      ) : (
        <Tabs
          value={tab}
          onValueChange={setTab}
          className="min-h-0 flex-1 gap-0"
        >
          <TabsListUnderline className="shrink-0 px-4 sm:px-6">
            <TabsTriggerUnderline value="fulltext">原文</TabsTriggerUnderline>
            {!fallbackEnabled && (
              <>
                <TabsTriggerUnderline value="notes">
                  阅读笔记
                </TabsTriggerUnderline>
                <TabsTriggerUnderline value="quotes">
                  核实引文
                </TabsTriggerUnderline>
                <TabsTriggerUnderline value="facts">事实</TabsTriggerUnderline>
              </>
            )}
          </TabsListUnderline>
          <ScrollArea className="min-h-0 flex-1">
            <div className="mx-auto min-w-0 max-w-[720px] px-4 pt-5 pb-10 break-words sm:px-6">
              <TabsContent value="fulltext" className="min-w-0">
                {markdown ? (
                  <ParagraphMarkdown
                    markdown={markdown}
                    pid={targetPid}
                    quotes={quotes}
                  />
                ) : (
                  <EmptyState title="暂无原文或摘要" />
                )}
              </TabsContent>
              {!fallbackEnabled && (
                <>
                  <TabsContent value="notes" className="min-w-0">
                    {detail.data?.notes_md ? (
                      <MarkdownView markdown={detail.data.notes_md} />
                    ) : (
                      <EmptyState title="暂无阅读笔记" />
                    )}
                  </TabsContent>
                  <TabsContent value="quotes" className="min-w-0">
                    {!verifiedQuotes.length && (
                      <EmptyState title="暂无核实引文" />
                    )}
                    {verifiedQuotes.map((quote, index) => (
                      <article
                        key={index}
                        className="space-y-2.5 border-b py-4 last:border-b-0"
                      >
                        <div className="flex flex-wrap items-center gap-1.5">
                          <VerifiedPill value={quote.verified ?? false} />
                          {quote.key_finding && (
                            <Pill tone="primary">
                              <Star />
                              关键发现
                            </Pill>
                          )}
                          {quote.note_section && (
                            <span className="text-xs text-muted-foreground">
                              {quote.note_section}
                            </span>
                          )}
                        </div>
                        <blockquote className="border-l-2 border-primary/30 pl-3 text-sm leading-7 whitespace-pre-wrap">
                          {quote.quote}
                        </blockquote>
                        <div className="metadata">
                          {quote.sec && <span>{quote.sec}</span>}
                          {quote.page != null && <span>第 {quote.page} 页</span>}
                          {quote.pid != null && (
                            <Button
                              variant="outline"
                              size="xs"
                              aria-label={'查看原文段落 ' + quote.pid}
                              onClick={() => openParagraph(quote.pid!)}
                            >
                              ¶{quote.pid}
                            </Button>
                          )}
                        </div>
                      </article>
                    ))}
                  </TabsContent>
                  <TabsContent value="facts" className="min-w-0">
                    {!facts.length && <EmptyState title="暂无事实记录" />}
                    {facts.map((fact, index) => (
                      <article
                        key={index}
                        className="space-y-2.5 border-b py-4 last:border-b-0"
                      >
                        <div className="flex flex-wrap items-center gap-1.5">
                          <Pill>
                            {factKinds[fact.kind ?? 'finding'] ?? fact.kind}
                          </Pill>
                          <VerifiedPill value={fact.verified ?? false} />
                        </div>
                        <p className="text-sm leading-7 whitespace-pre-wrap">
                          {fact.fact}
                        </p>
                        {fact.fact_zh && (
                          <p className="text-sm leading-7 whitespace-pre-wrap text-muted-foreground">
                            {fact.fact_zh}
                          </p>
                        )}
                        {fact.quote && (
                          <blockquote className="border-l-2 border-primary/30 pl-3 text-sm leading-7 whitespace-pre-wrap text-muted-foreground">
                            {fact.quote}
                          </blockquote>
                        )}
                        <div className="metadata">
                          {fact.sec && <span>{fact.sec}</span>}
                          {fact.page != null && <span>第 {fact.page} 页</span>}
                          {fact.pid != null && (
                            <Button
                              variant="outline"
                              size="xs"
                              aria-label={'查看原文段落 ' + fact.pid}
                              onClick={() => openParagraph(fact.pid!)}
                            >
                              ¶{fact.pid}
                            </Button>
                          )}
                        </div>
                      </article>
                    ))}
                  </TabsContent>
                </>
              )}
            </div>
          </ScrollArea>
        </Tabs>
      )}
    </>
  )
}

/** ≥xl 与答案并排的阅读器分栏。 */
export function ReaderPane(props: ReaderProps) {
  return (
    <m.section
      initial={{ opacity: 0, x: 12 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ duration: 0.22, ease }}
      className="flex h-full min-h-0 flex-col bg-card"
      aria-label="原文阅读器"
    >
      <PaperReader
        key={props.answerId + ':' + props.n + ':' + (props.pid ?? '')}
        {...props}
      />
    </m.section>
  )
}

/** <xl 的全屏/右侧抽屉。 */
export function ReaderSheet(props: ReaderProps) {
  return (
    <Sheet
      open
      onOpenChange={(open) => {
        if (!open) props.onClose()
      }}
    >
      <SheetContent
        side="right"
        showCloseButton={false}
        className="flex h-dvh w-full flex-col gap-0 p-0 sm:max-w-3xl"
      >
        <SheetHeader className="sr-only">
          <SheetTitle>第 {props.n} 篇文献原文</SheetTitle>
          <SheetDescription>
            第 {props.n} 篇文献的原文、阅读笔记、核实引文与事实
          </SheetDescription>
        </SheetHeader>
        <PaperReader
          key={props.answerId + ':' + props.n + ':' + (props.pid ?? '')}
          {...props}
        />
      </SheetContent>
    </Sheet>
  )
}
