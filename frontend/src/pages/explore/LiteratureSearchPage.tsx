import { useState } from 'react'
import { ChevronDown, Search } from 'lucide-react'
import type { CSSProperties } from 'react'
import {
  useLiteratureFulltext,
  useLiteratureSearch,
  type LiteratureSearchParams,
} from '@/api/queries'
import { ApiError } from '@/api/errors'
import { JournalPicker } from '@/components/ask/JournalPicker'
import { YearPicker } from '@/components/ask/YearPicker'
import { EmptyState } from '@/components/common/EmptyState'
import { ListRow, ListRows } from '@/components/common/ListRows'
import { Loading } from '@/components/common/Loading'
import { PageHeader } from '@/components/common/PageHeader'
import { QueryError } from '@/components/common/QueryError'
import { Button } from '@/components/ui/button'
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from '@/components/ui/collapsible'
import { Input } from '@/components/ui/input'
import { ScrollArea } from '@/components/ui/scroll-area'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from '@/components/ui/sheet'
import { Switch } from '@/components/ui/switch'
import { ToggleGroup, ToggleGroupItem } from '@/components/ui/toggle-group'
import {
  DEFAULT_FILTERS,
  validYears,
  yearParams,
  type YearState,
} from '@/lib/filters'

import {
  LiteratureRecordCard,
  PUBLICATION_TYPES,
  type LiteratureRecord,
} from '@/components/literature/LiteratureRecordCard'

function FulltextSheet({
  paper,
  onClose,
}: {
  paper: LiteratureRecord
  onClose: () => void
}) {
  const ident = paper.pmcid || paper.pmid || paper.doi || null
  const [section, setSection] = useState('')
  const directory = useLiteratureFulltext(ident, '')
  const fulltext = useLiteratureFulltext(section ? ident : null, section)
  return (
    <Sheet
      open
      onOpenChange={(open) => {
        if (!open) onClose()
      }}
    >
      <SheetContent
        side="right"
        className="flex h-dvh w-full flex-col gap-0 p-0 sm:max-w-2xl"
      >
        <SheetHeader className="border-b px-5 py-4">
          <SheetTitle className="break-words leading-7">
            {paper.title || '文献全文'}
          </SheetTitle>
          <SheetDescription>
            全文目录{directory.data?.pmcid ? ' · ' + directory.data.pmcid : ''}
          </SheetDescription>
        </SheetHeader>
        <ScrollArea className="min-h-0 flex-1">
          <div className="space-y-6 px-5 py-5">
            {directory.isPending ? (
              <Loading />
            ) : directory.isError ? (
              directory.error instanceof ApiError &&
              directory.error.code === 'fulltext_unavailable' ? (
                <EmptyState title="无可用全文" />
              ) : (
                <QueryError error={directory.error} retry={directory.refetch} />
              )
            ) : (
              <>
                {directory.data.citation && (
                  <p className="metadata break-words">
                    {directory.data.citation}
                  </p>
                )}
                {directory.data.abstract && (
                  <section className="space-y-2">
                    <h2 className="text-sm font-semibold">摘要</h2>
                    <p className="whitespace-pre-wrap break-words text-sm leading-7">
                      {directory.data.abstract}
                    </p>
                  </section>
                )}
                <section className="space-y-2">
                  <h2 className="text-sm font-semibold">章节</h2>
                  {directory.data.sections.length ? (
                    <div className="divide-y">
                      {directory.data.sections.map((entry, index) => (
                        <button
                          type="button"
                          key={index}
                          className="flex w-full items-center justify-between gap-4 rounded-md px-2 py-2.5 text-left text-sm transition-colors hover:bg-accent/60 aria-pressed:bg-accent aria-pressed:text-foreground"
                          aria-pressed={section === entry.title}
                          onClick={() => setSection(entry.title)}
                        >
                          <span className="min-w-0 break-words">
                            {entry.title}
                          </span>
                          <span className="shrink-0 text-xs text-muted-foreground">
                            {entry.chars.toLocaleString()} 字
                          </span>
                        </button>
                      ))}
                    </div>
                  ) : (
                    <p className="text-sm text-muted-foreground">暂无章节</p>
                  )}
                </section>
                {section && (
                  <section className="space-y-3 border-t pt-5">
                    <h2 className="break-words font-semibold">{section}</h2>
                    {fulltext.isPending ? (
                      <Loading />
                    ) : fulltext.isError ? (
                      fulltext.error instanceof ApiError &&
                      fulltext.error.code === 'fulltext_unavailable' ? (
                        <EmptyState title="无可用全文" />
                      ) : (
                        <QueryError
                          error={fulltext.error}
                          retry={fulltext.refetch}
                        />
                      )
                    ) : (
                      <>
                        <p className="whitespace-pre-wrap break-words text-sm leading-7">
                          {fulltext.data?.text || '该章节没有正文'}
                        </p>
                        {fulltext.data?.truncated && (
                          <p className="text-sm text-warning">
                            已按 20000 字符截断
                          </p>
                        )}
                      </>
                    )}
                  </section>
                )}
              </>
            )}
          </div>
        </ScrollArea>
      </SheetContent>
    </Sheet>
  )
}

export default function LiteratureSearchPage() {
  const [q, setQ] = useState('')
  const [source, setSource] = useState<'auto' | 'pubmed' | 's2'>('auto')
  const [limit, setLimit] = useState('10')
  const [years, setYears] = useState<YearState>(DEFAULT_FILTERS)
  const [types, setTypes] = useState<string[]>([])
  const [quartiles, setQuartiles] = useState<string[]>([])
  const [journals, setJournals] = useState<string[]>([])
  const [oa, setOa] = useState(false)
  const [submitted, setSubmitted] = useState<LiteratureSearchParams | null>(
    null,
  )
  const results = useLiteratureSearch(submitted)
  const [opened, setOpened] = useState<LiteratureRecord | null>(null)
  return (
    <div className="h-full overflow-y-auto">
      <div className="page">
        <PageHeader
          title="查文献"
          description="直接检索 PubMed / Semantic Scholar 上游并预览全文目录"
        />
        <form
          className="space-y-5 border-b pb-6"
          onSubmit={(event) => {
            event.preventDefault()
            if (!q.trim() || !validYears(years)) return
            const next = {
              q: q.trim(),
              source,
              limit: Number(limit),
              ...yearParams(years),
              publication_types: types,
              quartiles: quartiles.map(Number).sort(),
              journals,
              open_access_only: source === 's2' && oa,
            }
            if (JSON.stringify(next) === JSON.stringify(submitted))
              void results.refetch()
            else setSubmitted(next)
          }}
        >
          <div className="flex flex-col gap-2 md:flex-row md:items-center">
            <Input
              aria-label="检索词"
              required
              value={q}
              onChange={(e) => setQ(e.target.value)}
              placeholder="搜索文献"
              className="h-10 flex-1"
            />
            <Select
              value={source}
              onValueChange={(v) => {
                if (v === 'auto' || v === 'pubmed' || v === 's2') setSource(v)
              }}
            >
              <SelectTrigger aria-label="来源" className="h-10 w-full md:w-44">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="auto">自动</SelectItem>
                <SelectItem value="pubmed">PubMed</SelectItem>
                <SelectItem value="s2">Semantic Scholar</SelectItem>
              </SelectContent>
            </Select>
            <Select value={limit} onValueChange={setLimit}>
              <SelectTrigger aria-label="条数" className="h-10 w-full md:w-24">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {['10', '20', '30'].map((v) => (
                  <SelectItem value={v} key={v}>
                    {v}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            <Button
              type="submit"
              className="h-10"
              disabled={!q.trim() || !validYears(years) || results.isFetching}
            >
              <Search />
              检索
            </Button>
          </div>
          <Collapsible>
            <CollapsibleTrigger className="mt-3 inline-flex items-center gap-1 text-xs text-muted-foreground transition-colors hover:text-foreground [&>svg]:transition-transform [&[data-state=open]>svg]:rotate-180">
              高级筛选
              <ChevronDown className="size-3.5" />
            </CollapsibleTrigger>
            <CollapsibleContent className="mt-4 grid gap-5 rounded-xl border bg-card p-5 md:grid-cols-2">
              <div>
                <p className="section-label mb-3">年份</p>
                <YearPicker
                  value={years}
                  onChange={(v) => setYears((c) => ({ ...c, ...v }))}
                />
              </div>
              <div>
                <p className="section-label mb-3">期刊分区</p>
                <ToggleGroup
                  type="multiple"
                  value={quartiles}
                  onValueChange={setQuartiles}
                  className="flex flex-wrap gap-1.5"
                >
                  {['1', '2', '3', '4'].map((v) => (
                    <ToggleGroupItem
                      className="chip"
                      key={v}
                      value={v}
                      aria-label={v + '区'}
                    >
                      <span
                        className="size-1.5 rounded-full"
                        style={
                          { background: 'var(--q' + v + ')' } as CSSProperties
                        }
                      />
                      Q{v}
                    </ToggleGroupItem>
                  ))}
                </ToggleGroup>
              </div>
              <div>
                <p className="section-label mb-3">文献类型</p>
                <ToggleGroup
                  type="multiple"
                  value={types}
                  onValueChange={setTypes}
                  className="flex flex-wrap gap-1.5"
                >
                  {PUBLICATION_TYPES.map(([v, l]) => (
                    <ToggleGroupItem className="chip" key={v} value={v}>
                      {l}
                    </ToggleGroupItem>
                  ))}
                </ToggleGroup>
              </div>
              <div>
                <p className="section-label mb-3">期刊家族（含子刊）</p>
                <JournalPicker value={journals} onChange={setJournals} />
              </div>
              <div className="flex items-center gap-3 md:col-span-2">
                <Switch
                  id="literature-oa"
                  checked={oa}
                  disabled={source !== 's2'}
                  onCheckedChange={setOa}
                />
                <label
                  htmlFor="literature-oa"
                  className={
                    source !== 's2'
                      ? 'text-sm text-muted-foreground'
                      : 'text-sm'
                  }
                >
                  仅开放获取（仅 S2）
                </label>
              </div>
            </CollapsibleContent>
          </Collapsible>
        </form>
        {submitted &&
          (results.isFetching ? (
            <Loading>正在检索文献…</Loading>
          ) : results.isError ? (
            <QueryError error={results.error} retry={results.refetch} />
          ) : (
            results.data && (
              <section className="pt-5">
                {results.data.fallback_reason && (
                  <p
                    role="status"
                    className="mb-4 rounded-lg border border-info/30 bg-info/5 px-3 py-2 text-xs leading-5"
                  >
                    Semantic Scholar 不可用，已改用 PubMed：
                    {results.data.fallback_reason}
                  </p>
                )}
                <p className="metadata mb-2">
                  来源{' '}
                  {results.data.source === 's2' ? 'Semantic Scholar' : 'PubMed'}{' '}
                  · 上游命中 {results.data.total.toLocaleString()}
                </p>
                {results.data.items.length ? (
                  <ListRows>
                    {results.data.items.map((paper, index) => (
                      <ListRow
                        index={index}
                        key={paper.source + ':' + paper.id + ':' + index}
                        className="space-y-3"
                      >
                        <LiteratureRecordCard
                          paper={paper}
                          onOpenFulltext={setOpened}
                        />
                      </ListRow>
                    ))}
                  </ListRows>
                ) : (
                  <EmptyState title="未找到符合条件的文献" />
                )}
              </section>
            )
          ))}
        {opened && (
          <FulltextSheet
            key={opened.pmcid || opened.pmid || opened.doi}
            paper={opened}
            onClose={() => setOpened(null)}
          />
        )}
      </div>
    </div>
  )
}
