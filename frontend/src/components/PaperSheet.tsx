import { useState } from 'react'
import { Check, LoaderCircle, Star, X } from 'lucide-react'
import type { components } from '@/api/schema'
import { ApiError, problemMessage } from '@/api/errors'
import { useAnswerPaper, usePaperMarkdown } from '@/api/queries'
import { EmptyState } from './EmptyState'
import { MarkdownView } from './MarkdownView'
import { ParagraphMarkdown } from './ParagraphMarkdown'
import { PaperExternalLinks } from './SourceCard'
import { RankBadge } from './RankBadge'
import { SourceBadge } from './SourceBadge'
import { Badge } from './ui/badge'
import { Button } from './ui/button'
import { ScrollArea } from './ui/scroll-area'
import { Sheet, SheetClose, SheetContent, SheetDescription, SheetHeader, SheetTitle } from './ui/sheet'
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs'

export type PaperSheetProps = {
  answerId: string
  n: number
  pid: number | null
  papers: components['schemas']['AnswerPaper'][]
  citations: components['schemas']['Citation'][]
  onClose: () => void
}

function Verification({ verified }: { verified?: boolean }) {
  return <Badge variant="outline" className={verified ? 'status-green' : 'status-amber'}>{verified ? <Check className="size-3" /> : <X className="size-3" />}{verified ? '已核实' : '未核实'}</Badge>
}

function PaperReader({ answerId, n, pid, papers, citations }: Omit<PaperSheetProps, 'onClose'>) {
  const detail = useAnswerPaper(answerId, n)
  const fallbackEnabled = detail.error instanceof ApiError && detail.error.status === 404
  const fallback = usePaperMarkdown(answerId, n, fallbackEnabled)
  const [tab, setTab] = useState('fulltext')
  const [targetPid, setTargetPid] = useState(pid)
  const paper = detail.data ?? papers.find(item => item.n === n)
  const error = fallbackEnabled ? fallback.error : detail.error
  const pending = fallbackEnabled ? fallback.isPending : detail.isPending
  const missing = fallbackEnabled && fallback.error instanceof ApiError && fallback.error.status === 404
  const markdown = fallbackEnabled ? fallback.data : detail.data?.fulltext_md
  const quotes = citations.find(citation => citation.n === n && citation.pid === targetPid)?.quotes
  const verifiedQuotes = detail.data?.citations ?? []
  const facts = detail.data?.facts ?? []
  const openParagraph = (nextPid: number) => { setTargetPid(nextPid); setTab('fulltext') }

  return <>
    <SheetHeader className="max-h-[35dvh] shrink-0 overflow-y-auto border-b pr-14">
      <SheetTitle className="text-base leading-6 break-words">[{n}] {paper?.title || '第 ' + n + ' 篇文献'}</SheetTitle>
      <SheetDescription className="sr-only">第 {n} 篇文献的原文、阅读笔记、核实引文与事实</SheetDescription>
      {paper && <>
        <div className="text-xs leading-5 break-words text-muted-foreground">{paper.authors && <p>{paper.authors}</p>}<i>{paper.journal}</i>{paper.year && <span>（{paper.year}）</span>}</div>
        <div className="flex flex-wrap items-center gap-2"><RankBadge rank_label={paper.rank_label} quartile={paper.quartile} /><SourceBadge source={paper.source} /><PaperExternalLinks paper={paper} /></div>
      </>}
    </SheetHeader>
    {pending ? <div role="status" className="flex items-center justify-center gap-2 p-8 text-sm text-muted-foreground"><LoaderCircle className="size-4 animate-spin" />正在加载文献材料…</div>
      : missing ? <EmptyState title="此答案没有逐篇材料（旧版导入）" />
      : error ? <div role="alert" className="error-panel m-4"><p>{problemMessage(error)}</p>{error instanceof ApiError && error.detail && error.detail !== problemMessage(error) && <p className="mt-2 text-sm break-words">{error.detail}</p>}<Button variant="outline" size="sm" className="mt-3" onClick={() => { void (fallbackEnabled ? fallback.refetch() : detail.refetch()) }}>重试</Button></div>
      : <Tabs value={tab} onValueChange={setTab} className="min-h-0 flex-1 gap-0">
        <TabsList className="mx-4 mb-3 grid w-auto shrink-0" style={{ gridTemplateColumns: fallbackEnabled ? '1fr' : 'repeat(4, minmax(0, 1fr))' }}>
          <TabsTrigger value="fulltext">原文</TabsTrigger>
          {!fallbackEnabled && <><TabsTrigger value="notes">阅读笔记</TabsTrigger><TabsTrigger value="quotes">核实引文</TabsTrigger><TabsTrigger value="facts">事实</TabsTrigger></>}
        </TabsList>
        <ScrollArea className="min-h-0 flex-1">
          <div className="min-w-0 px-4 pb-8 break-words sm:px-6">
            <TabsContent value="fulltext" className="min-w-0">
              {markdown ? <ParagraphMarkdown markdown={markdown} pid={targetPid} quotes={quotes} /> : <EmptyState title="暂无原文或摘要" />}
            </TabsContent>
            {!fallbackEnabled && <>
              <TabsContent value="notes" className="min-w-0">{detail.data?.notes_md ? <MarkdownView markdown={detail.data.notes_md} /> : <EmptyState title="暂无阅读笔记" />}</TabsContent>
              <TabsContent value="quotes" className="min-w-0">
                {!verifiedQuotes.length && <EmptyState title="暂无核实引文" />}
                {verifiedQuotes.map((quote, index) => <article key={index} className="space-y-3 border-b py-4 last:border-b-0">
                  <div className="flex flex-wrap items-center gap-2"><Verification verified={quote.verified} />{quote.key_finding && <Badge variant="outline"><Star className="size-3" />关键发现</Badge>}{quote.note_section && <span className="text-xs text-muted-foreground">{quote.note_section}</span>}</div>
                  <blockquote className="border-l-2 border-primary/40 pl-3 text-sm leading-7 whitespace-pre-wrap">{quote.quote}</blockquote>
                  <div className="flex flex-wrap items-center gap-2 text-xs text-muted-foreground">{quote.sec && <span>{quote.sec}</span>}{quote.page != null && <span>第 {quote.page} 页</span>}{quote.pid != null && <Button variant="outline" size="sm" aria-label={'查看原文段落 ' + quote.pid} onClick={() => openParagraph(quote.pid!)}>¶{quote.pid}</Button>}</div>
                </article>)}
              </TabsContent>
              <TabsContent value="facts" className="min-w-0">
                {!facts.length && <EmptyState title="暂无事实记录" />}
                {facts.map((fact, index) => <article key={index} className="space-y-3 border-b py-4 last:border-b-0">
                  <div className="flex flex-wrap items-center gap-2"><Badge variant="secondary">{({ finding: '研究发现', method: '研究方法', background: '背景', limitation: '局限性' } as Record<string, string>)[fact.kind ?? 'finding'] ?? fact.kind}</Badge><Verification verified={fact.verified} /></div>
                  <p className="text-sm leading-7 whitespace-pre-wrap">{fact.fact}</p>{fact.fact_zh && <p className="text-sm leading-7 whitespace-pre-wrap text-muted-foreground">{fact.fact_zh}</p>}
                  {fact.quote && <blockquote className="border-l-2 pl-3 text-sm leading-7 whitespace-pre-wrap text-muted-foreground">{fact.quote}</blockquote>}
                  <div className="flex flex-wrap items-center gap-2 text-xs text-muted-foreground">{fact.sec && <span>{fact.sec}</span>}{fact.page != null && <span>第 {fact.page} 页</span>}{fact.pid != null && <Button variant="outline" size="sm" aria-label={'查看原文段落 ' + fact.pid} onClick={() => openParagraph(fact.pid!)}>¶{fact.pid}</Button>}</div>
                </article>)}
              </TabsContent>
            </>}
          </div>
        </ScrollArea>
      </Tabs>}
  </>
}

export function PaperSheet({ onClose, ...props }: PaperSheetProps) {
  return <Sheet open onOpenChange={open => { if (!open) onClose() }}>
    <SheetContent side="right" showCloseButton={false} className="h-dvh w-full gap-3 overflow-hidden sm:max-w-3xl">
      <SheetClose asChild><Button variant="ghost" size="icon" className="absolute top-3 right-3 z-10" aria-label="关闭原文阅读器" title="关闭原文阅读器"><X className="size-4" /></Button></SheetClose>
      <PaperReader key={props.answerId + ':' + props.n + ':' + (props.pid ?? '')} {...props} />
    </SheetContent>
  </Sheet>
}
