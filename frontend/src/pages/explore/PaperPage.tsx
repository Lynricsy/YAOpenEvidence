import { useEffect, useState } from 'react'
import { Link, useParams, useSearchParams } from 'react-router'
import { ArrowLeft } from 'lucide-react'
import { usePaper, usePaperFacts, usePaperFulltext } from '@/api/queries'
import { ApiError } from '@/api/errors'
import { EmptyState } from '@/components/EmptyState'
import { ParagraphMarkdown } from '@/components/ParagraphMarkdown'
import { RankBadge } from '@/components/RankBadge'
import { SourceBadge } from '@/components/SourceBadge'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { kindLabel, Loading, PaperLinks, positivePid, QueryError, Verified } from './shared'

export default function PaperPage() {
  const { key = '' } = useParams()
  const [params, setParams] = useSearchParams()
  const pid = positivePid(params.get('pid'))
  const [tab, setTab] = useState('fulltext')
  const paper = usePaper(key)
  const fulltext = usePaperFulltext(key, tab === 'fulltext' && paper.isSuccess)
  const facts = usePaperFacts(key, tab === 'facts' && paper.isSuccess)
  useEffect(() => { setTab('fulltext') }, [key, pid])
  function openParagraph(value: number) {
    setParams(current => { const next = new URLSearchParams(current); next.set('pid', String(value)); return next })
    setTab('fulltext')
  }
  return <main className="page min-w-0">
    <Link to="/library" className="mb-5 inline-flex items-center gap-2 text-sm text-muted-foreground hover:text-primary"><ArrowLeft className="size-4" />文献库</Link>
    {paper.isPending ? <Loading /> : paper.isError ? paper.error instanceof ApiError && paper.error.status === 404 ? <EmptyState title="文献不存在" /> : <QueryError error={paper.error} retry={paper.refetch} /> : <>
      <header className="space-y-4 border-b pb-6"><h1 className="break-words text-xl font-semibold leading-8">{paper.data.title || key}</h1><p className="metadata break-words">{paper.data.authors}</p><p className="metadata"><i>{paper.data.journal}</i>{paper.data.year && ' (' + paper.data.year + ')'}</p><div className="flex flex-wrap gap-2"><RankBadge quartile={paper.data.quartile} /><SourceBadge source={paper.data.source} />{paper.data.types?.map(type => <Badge variant="outline" className="max-w-full whitespace-normal" key={type}>{type}</Badge>)}</div><PaperLinks pmid={paper.data.pmid} doi={paper.data.doi} /></header>
      <Tabs value={tab} onValueChange={setTab} className="mt-5 min-w-0"><TabsList><TabsTrigger value="fulltext">全文</TabsTrigger><TabsTrigger value="facts">事实</TabsTrigger></TabsList>
        <TabsContent value="fulltext" className="min-w-0 pt-4">{fulltext.isPending ? <Loading /> : fulltext.isError ? <QueryError error={fulltext.error} retry={fulltext.refetch} /> : fulltext.data ? <ParagraphMarkdown markdown={fulltext.data} pid={pid} /> : <EmptyState title="暂无全文" />}</TabsContent>
        <TabsContent value="facts" className="min-w-0 pt-4">{facts.isPending ? <Loading /> : facts.isError ? <QueryError error={facts.error} retry={facts.refetch} /> : facts.data?.items.length ? facts.data.items.map((fact, index) => <article className="list-row space-y-3" key={index}><div className="flex flex-wrap items-center gap-2"><Badge variant="outline">{kindLabel(fact.kind ?? 'finding')}</Badge><Verified value={fact.verified ?? false} />{fact.pid != null && fact.pid > 0 && <Button size="sm" variant="ghost" onClick={() => openParagraph(fact.pid!)}>¶{fact.pid}</Button>}<span className="metadata">{fact.sec}{fact.page != null && ' · 第 ' + fact.page + ' 页'}</span></div><p className="whitespace-pre-wrap break-words leading-7">{fact.fact}</p>{fact.fact_zh && <p className="whitespace-pre-wrap break-words text-sm leading-7 text-muted-foreground">{fact.fact_zh}</p>}{fact.quote && <blockquote className="border-l-2 pl-4 text-sm leading-7 text-muted-foreground">{fact.quote}</blockquote>}</article>) : <EmptyState title="暂无事实条目" />}</TabsContent>
      </Tabs>
    </>}
  </main>
}
