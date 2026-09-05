import { useRef, useState } from 'react'
import { useNavigate, useParams, useSearchParams } from 'react-router'
import { useMutation } from '@tanstack/react-query'
import {
  ChevronDown,
  RotateCcw,
  Trash2,
  FileSearch,
  AlertCircle,
} from 'lucide-react'
import { FilterColumn, FilterSheet } from '@/components/ask/FilterPanel'
import { ComposerDock } from '@/components/ask/ComposerDock'
import { Hero } from '@/components/ask/Hero'
import { EmptyState } from '@/components/common/EmptyState'
import { ProgressTimeline } from '@/components/ProgressTimeline'
import { DeleteAnswerDialog } from '@/components/common/DeleteAnswerDialog'
import { StatusBadge } from '@/components/common/StatusBadge'
import { AnswerBody } from '@/components/AnswerBody'
import { SourceCard } from '@/components/SourceCard'
import { SourceList } from '@/components/SourceList'
import { PaperSheet } from '@/components/PaperSheet'
import { MARKER_RE } from '@/lib/citations'
import { BREAKPOINTS, useMediaQuery } from '@/lib/useMediaQuery'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Skeleton } from '@/components/ui/skeleton'
import {
  Collapsible,
  CollapsibleTrigger,
  CollapsibleContent,
} from '@/components/ui/collapsible'
import {
  loadFilters,
  saveFilters,
  describeFilters,
  fromAnswerOptions,
  toAnswerCreate,
  validYears,
  type FilterState,
} from '@/lib/filters'
import { relativeTime } from '@/lib/format'
import { createAnswer, queryClient, useAnswer } from '@/api/queries'
import { useJobEvents } from '@/api/useJobEvents'
import { ApiError, jobErrorMessage, problemMessage } from '@/api/errors'

export default function AskPage() {
  const { answerId } = useParams()
  const navigate = useNavigate()
  const [searchParams, setSearchParams] = useSearchParams()
  const paperParam = searchParams.get('paper') ?? ''
  const paperN = /^[1-9]\d{0,2}$/.test(paperParam) ? Number(paperParam) : null
  const pidParam = searchParams.get('pid') ?? ''
  const paperPid = /^\d{1,4}$/.test(pidParam) ? Number(pidParam) : null
  const openPaper = (n: number, pid: number | null) =>
    setSearchParams({
      paper: String(n),
      ...(pid !== null ? { pid: String(pid) } : {}),
    })
  const [filters, setFilters] = useState(loadFilters)
  const [question, setQuestion] = useState('')
  const [deleteId, setDeleteId] = useState<string | null>(null)
  const [sseOpen, setSseOpen] = useState(false)
  const [filterOpen, setFilterOpen] = useState(false)
  const inputRef = useRef<HTMLTextAreaElement>(null)
  const isXl = useMediaQuery(BREAKPOINTS.xl)
  const is2xl = useMediaQuery(BREAKPOINTS['2xl'])
  const answerQuery = useAnswer(answerId, sseOpen)
  const answer = answerQuery.data
  const active = answer?.status === 'queued' || answer?.status === 'running'
  const { live, connection } = useJobEvents(answer?.job_id, active)
  if (sseOpen !== (connection === 'open')) setSseOpen(connection === 'open')
  // 阅读器占用右侧分栏时，<2xl 收起筛选列，改由输入框上方的芯片打开抽屉。
  const readerOpen = !!answer && paperN !== null
  const filterColumn = isXl && (!readerOpen || is2xl)
  const update = (f: FilterState) => {
    setFilters(f)
    saveFilters(f)
  }
  const create = useMutation({
    mutationFn: createAnswer,
    onSuccess: (created) => {
      queryClient.setQueryData(['answer', created.id], created)
      void queryClient.invalidateQueries({ queryKey: ['answers'] })
      setQuestion('')
      navigate('/a/' + created.id)
    },
  })
  const fill = (text: string) => {
    setQuestion(text)
    inputRef.current?.focus()
  }
  const citedCounts: Record<number, number> = {}
  for (const marker of (answer?.body_md ?? '').matchAll(MARKER_RE)) {
    const n = Number(marker[1])
    citedCounts[n] = (citedCounts[n] ?? 0) + 1
  }
  const composer = {
    value: question,
    onChange: setQuestion,
    onSubmit: () => create.mutate(toAnswerCreate(question, filters)),
    pending: create.isPending,
    disabled: !validYears(filters),
    inputRef,
    filterSummary: describeFilters(filters),
    onOpenFilters: filterColumn ? null : () => setFilterOpen(true),
  }
  return (
    <div className="flex min-h-0 flex-1">
      {filterColumn && <FilterColumn value={filters} onChange={update} />}
      <div className="flex min-w-0 flex-1 flex-col">
        <div
          className="min-h-0 flex-1 overflow-y-auto"
          data-testid="answer-scroll"
        >
          {!answerId ? (
            <Hero {...composer} onExample={fill} />
          ) : (
            <div className="mx-auto w-full max-w-[760px] px-5 py-8 md:px-8 md:py-10">
              {answerQuery.isPending ? (
                <div className="min-h-[60dvh] space-y-5">
                  <Skeleton className="h-8 w-3/4" />
                  <Skeleton className="h-4 w-1/3" />
                  <Skeleton className="h-64 w-full" />
                </div>
              ) : answerQuery.error ? (
                <EmptyState
                  icon={AlertCircle}
                  title={
                    answerQuery.error instanceof ApiError &&
                    answerQuery.error.status === 404
                      ? '答案不存在或无权访问'
                      : problemMessage(answerQuery.error)
                  }
                  action={
                    <Button variant="outline" onClick={() => navigate('/')}>
                      返回提问
                    </Button>
                  }
                />
              ) : (
                answer && (
                  <>
                    <section className="border-b pb-6">
                      <p className="section-label mb-3 flex items-center gap-2">
                        <FileSearch className="size-3.5" />
                        文献问答
                      </p>
                      <h1 className="font-serif text-2xl font-semibold leading-snug tracking-tight break-words md:text-[28px]">
                        {answer.question}
                      </h1>
                      <div className="metadata mt-4">
                        <StatusBadge status={answer.status} />
                        {answer.filters_label && (
                          <Badge
                            variant="secondary"
                            className="max-w-full whitespace-normal text-left leading-5"
                          >
                            {answer.filters_label}
                          </Badge>
                        )}
                        <span>{relativeTime(answer.created_at)}</span>
                        {answer.n_papers != null && (
                          <span>
                            {answer.n_papers} 篇文献 · {answer.n_fulltext ?? 0}{' '}
                            篇全文
                          </span>
                        )}
                      </div>
                      {!!answer.queries?.length && (
                        <Collapsible className="mt-4">
                          <CollapsibleTrigger className="flex items-center gap-1 text-xs text-muted-foreground">
                            <ChevronDown className="size-3" />
                            检索式
                          </CollapsibleTrigger>
                          <CollapsibleContent>
                            <ul className="mt-3 space-y-2 rounded-md bg-muted p-3 font-mono text-xs leading-6 break-words">
                              {answer.queries.map((q) => (
                                <li key={q}>{q}</li>
                              ))}
                            </ul>
                          </CollapsibleContent>
                        </Collapsible>
                      )}
                    </section>
                    {active ? (
                      <>
                        <ProgressTimeline
                          key={answer.job_id}
                          live={live}
                          connection={connection}
                          status={answer.status}
                          jobId={answer.job_id ?? null}
                          useKb={answer.options?.use_kb !== false}
                        />
                        {!!live.search?.papers.length && (
                          <section className="border-t py-6">
                            <h2 className="mb-3 text-sm font-semibold">
                              候选文献
                            </h2>
                            {live.search.papers.map((paper) => (
                              <SourceCard
                                key={paper.n}
                                paper={paper}
                                compact
                                onOpen={openPaper}
                              />
                            ))}
                          </section>
                        )}
                      </>
                    ) : (
                      <>
                        {answer.status === 'ready' && (
                          <>
                            <AnswerBody answer={answer} onOpen={openPaper} />
                            <SourceList
                              papers={answer.papers ?? []}
                              nFulltext={answer.n_fulltext ?? 0}
                              citedCounts={citedCounts}
                              onOpen={openPaper}
                            />
                          </>
                        )}
                        {answer.status === 'failed' && (
                          <section className="error-panel my-7">
                            <h2 className="font-medium">
                              {jobErrorMessage(
                                answer.error?.code ?? 'internal_error',
                              )}
                            </h2>
                            {answer.error?.message && (
                              <p className="mt-2 text-xs text-muted-foreground">
                                {answer.error.message}
                              </p>
                            )}
                          </section>
                        )}
                        {answer.status === 'cancelled' && (
                          <EmptyState title="任务已取消" />
                        )}
                        <div className="flex flex-wrap gap-3 border-t pt-6">
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => {
                              update(fromAnswerOptions(answer.options ?? {}))
                              fill(answer.question)
                            }}
                          >
                            <RotateCcw />
                            沿用此次筛选重新提问
                          </Button>
                          <Button
                            variant="ghost"
                            size="sm"
                            className="text-muted-foreground"
                            onClick={() => setDeleteId(answer.id)}
                          >
                            <Trash2 />
                            删除
                          </Button>
                        </div>
                      </>
                    )}
                  </>
                )
              )}
            </div>
          )}
        </div>
        {answerId && <ComposerDock {...composer} />}
      </div>
      <FilterSheet
        open={filterOpen}
        onOpenChange={setFilterOpen}
        value={filters}
        onChange={update}
      />
      <DeleteAnswerDialog
        id={deleteId}
        onClose={() => setDeleteId(null)}
        onDeleted={() => navigate('/history')}
      />
      {answer && paperN !== null && (
        <PaperSheet
          answerId={answer.id}
          n={paperN}
          pid={paperPid}
          papers={answer.papers ?? []}
          citations={answer.citations ?? []}
          onClose={() =>
            setSearchParams((previous) => {
              const next = new URLSearchParams(previous)
              next.delete('paper')
              next.delete('pid')
              return next
            })
          }
        />
      )}
    </div>
  )
}
