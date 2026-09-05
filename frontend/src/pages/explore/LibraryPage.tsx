import { useEffect, useState } from 'react'
import { Link, useSearchParams } from 'react-router'
import { Search } from 'lucide-react'
import { usePapers } from '@/api/queries'
import { EmptyState } from '@/components/EmptyState'
import { Pagination } from '@/components/Pagination'
import { RankBadge } from '@/components/RankBadge'
import { Badge } from '@/components/ui/badge'
import { Input } from '@/components/ui/input'
import { dateTime } from '@/lib/format'
import { Loading, QueryError } from './shared'

export default function LibraryPage() {
  const [params, setParams] = useSearchParams()
  const q = params.get('q') ?? ''
  const rawOffset = Number(params.get('offset') ?? 0)
  const offset = Number.isSafeInteger(rawOffset) && rawOffset >= 0 ? rawOffset : 0
  const [draft, setDraft] = useState(q)
  const papers = usePapers({ q, limit: 20, offset })
  useEffect(() => { setDraft(q) }, [q])
  useEffect(() => {
    if (draft.trim() === q) return
    const timer = setTimeout(() => setParams(current => {
      const next = new URLSearchParams(current)
      if (draft.trim()) next.set('q', draft.trim()); else next.delete('q')
      next.delete('offset')
      return next
    }, { replace: true }), 300)
    return () => clearTimeout(timer)
  }, [draft, q, setParams])
  return <main className="page min-w-0">
    <div className="page-heading"><h1 className="page-title">文献库</h1></div>
    <div className="toolbar"><div className="relative w-full max-w-lg"><Search className="pointer-events-none absolute left-3 top-2.5 size-4 text-muted-foreground" /><Input className="pl-9" aria-label="搜索文献标题或期刊" placeholder="搜索标题或期刊" value={draft} onChange={event => setDraft(event.target.value)} /></div></div>
    {papers.isPending ? <Loading /> : papers.isError ? <QueryError error={papers.error} retry={papers.refetch} /> : papers.data.items.length ? <>
      <div>{papers.data.items.map(paper => <article key={paper.key} className="list-row min-w-0 space-y-3">
        <Link className="block break-words font-semibold leading-7 hover:text-primary" to={'/library/' + encodeURIComponent(paper.key)}>{paper.title || paper.key}</Link>
        <p className="metadata break-words">{paper.authors}{paper.authors && ' · '}<i>{paper.journal}</i>{paper.year && ' (' + paper.year + ')'}</p>
        <div className="flex flex-wrap items-center gap-2"><RankBadge quartile={paper.quartile} />{paper.types?.map(type => <Badge className="max-w-full whitespace-normal" variant="outline" key={type}>{type}</Badge>)}</div>
        <div className="metadata flex flex-wrap gap-x-4 gap-y-1"><span>{paper.n_paragraphs ?? 0} 段 / {paper.n_facts ?? 0} 条事实</span>{paper.indexed_at && <time dateTime={paper.indexed_at}>入库于 {dateTime(paper.indexed_at)}</time>}</div>
      </article>)}</div>
      <Pagination total={papers.data.total} limit={20} offset={offset} onChange={value => setParams(current => { const next = new URLSearchParams(current); if (value) next.set('offset', String(value)); else next.delete('offset'); return next })} />
    </> : <EmptyState title={q || offset ? '未找到文献' : '文献库为空'} description={q || offset ? '没有符合当前条件的文献。' : '完成一次问答后自动入库'} />}
  </main>
}
