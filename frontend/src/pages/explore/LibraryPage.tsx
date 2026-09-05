import { useEffect, useState } from 'react'
import { Link, useSearchParams } from 'react-router'
import { Search } from 'lucide-react'
import { usePapers } from '@/api/queries'
import { EmptyState } from '@/components/common/EmptyState'
import { ListRow, ListRows } from '@/components/common/ListRows'
import { Loading } from '@/components/common/Loading'
import { PageHeader } from '@/components/common/PageHeader'
import { Pagination } from '@/components/common/Pagination'
import { Pill } from '@/components/common/Pill'
import { QueryError } from '@/components/common/QueryError'
import { RankBadge } from '@/components/common/RankBadge'
import { Input } from '@/components/ui/input'
import { dateTime } from '@/lib/format'

export default function LibraryPage() {
  const [params, setParams] = useSearchParams()
  const q = params.get('q') ?? ''
  const rawOffset = Number(params.get('offset') ?? 0)
  const offset =
    Number.isSafeInteger(rawOffset) && rawOffset >= 0 ? rawOffset : 0
  const [draft, setDraft] = useState(q)
  const papers = usePapers({ q, limit: 20, offset })
  const [previousQuery, setPreviousQuery] = useState(q)
  if (previousQuery !== q) {
    setPreviousQuery(q)
    setDraft(q)
  }
  useEffect(() => {
    if (draft.trim() === q) return
    const timer = setTimeout(
      () =>
        setParams(
          (current) => {
            const next = new URLSearchParams(current)
            if (draft.trim()) next.set('q', draft.trim())
            else next.delete('q')
            next.delete('offset')
            return next
          },
          { replace: true },
        ),
      300,
    )
    return () => clearTimeout(timer)
  }, [draft, q, setParams])
  return (
    <div className="h-full overflow-y-auto">
      <div className="page min-w-0">
        <PageHeader
          title="文献库"
          description="问答过程中解析入库的全文与事实，按标题或期刊检索"
        />
        <div className="relative max-w-lg">
          <Search className="pointer-events-none absolute left-3 top-3 size-4 text-muted-foreground" />
          <Input
            className="h-10 rounded-lg pl-9"
            aria-label="搜索文献标题或期刊"
            placeholder="搜索标题或期刊"
            value={draft}
            onChange={(event) => setDraft(event.target.value)}
          />
        </div>
        {papers.isPending ? (
          <Loading />
        ) : papers.isError ? (
          <QueryError error={papers.error} retry={papers.refetch} />
        ) : papers.data.items.length ? (
          <>
            <ListRows className="mt-6">
              {papers.data.items.map((paper, index) => (
                <ListRow
                  index={index}
                  key={paper.key}
                  className="min-w-0 space-y-3"
                >
                  <Link
                    className="block break-words text-[15px] font-medium leading-6 transition-colors group-hover:text-primary"
                    to={'/library/' + encodeURIComponent(paper.key)}
                  >
                    {paper.title || paper.key}
                  </Link>
                  <p className="metadata break-words">
                    {paper.authors && <span>{paper.authors}</span>}
                    {paper.journal && <i>{paper.journal}</i>}
                    {paper.year && <span>{paper.year}</span>}
                  </p>
                  <div className="flex flex-wrap items-center gap-1.5">
                    <RankBadge quartile={paper.quartile} />
                    {paper.types?.map((type) => (
                      <Pill
                        tone="neutral"
                        className="max-w-full whitespace-normal"
                        key={type}
                      >
                        {type}
                      </Pill>
                    ))}
                  </div>
                  <div className="metadata">
                    <span>
                      {paper.n_paragraphs ?? 0} 段 / {paper.n_facts ?? 0} 条事实
                    </span>
                    {paper.indexed_at && (
                      <time dateTime={paper.indexed_at}>
                        入库于 {dateTime(paper.indexed_at)}
                      </time>
                    )}
                  </div>
                </ListRow>
              ))}
            </ListRows>
            <Pagination
              total={papers.data.total}
              limit={20}
              offset={offset}
              onChange={(value) =>
                setParams((current) => {
                  const next = new URLSearchParams(current)
                  if (value) next.set('offset', String(value))
                  else next.delete('offset')
                  return next
                })
              }
            />
          </>
        ) : (
          <EmptyState
            title={q || offset ? '未找到文献' : '文献库为空'}
            description={
              q || offset
                ? '没有符合当前条件的文献。'
                : '完成一次问答后自动入库'
            }
          />
        )}
      </div>
    </div>
  )
}
