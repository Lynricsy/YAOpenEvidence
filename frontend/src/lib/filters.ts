import type { components } from '@/api/schema'
export type Engine = 'ask' | 'codex'
export type FilterState = {
  engine: Engine
  quartiles: number[]
  keepUnranked: boolean
  yearMode: 'any' | 'recent' | 'range'
  years: number
  yearFrom: number | null
  yearTo: number | null
  journals: string[]
  papers: number
  useKb: boolean
  kbHits: number
  maxChars: number
}
export type YearState = Pick<
  FilterState,
  'yearMode' | 'years' | 'yearFrom' | 'yearTo'
>
export const DEFAULT_FILTERS: FilterState = {
  engine: 'ask',
  quartiles: [],
  keepUnranked: false,
  yearMode: 'recent',
  years: 3,
  yearFrom: null,
  yearTo: null,
  journals: [],
  papers: 8,
  useKb: true,
  kbHits: 0,
  maxChars: 28000,
}
export function validYears(f: YearState) {
  const now = new Date().getFullYear()
  return (
    f.yearMode !== 'range' ||
    (f.yearFrom !== null &&
      Number.isInteger(f.yearFrom) &&
      f.yearFrom >= 1900 &&
      f.yearFrom <= now &&
      (f.yearTo === null ||
        (Number.isInteger(f.yearTo) &&
          f.yearTo >= f.yearFrom &&
          f.yearTo <= now)))
  )
}
export function yearParams(f: YearState) {
  return f.yearMode === 'recent'
    ? { years: f.years }
    : f.yearMode === 'range'
      ? {
          year_from: f.yearFrom!,
          ...(f.yearTo !== null ? { year_to: f.yearTo } : {}),
        }
      : {}
}
export function toAnswerCreate(
  question: string,
  f: FilterState,
): components['schemas']['AnswerCreate'] {
  // codex 引擎不走确定性流水线：只发它真会用到的字段，避免让人以为字符预算等仍生效
  const codex = f.engine === 'codex'
  return {
    question: question.trim(),
    engine: f.engine,
    papers: f.papers,
    ...yearParams(f),
    quartiles: f.quartiles,
    ...(f.quartiles.length && !codex ? { keep_unranked: f.keepUnranked } : {}),
    journals: f.journals,
    use_kb: f.useKb,
    ...(codex
      ? {}
      : { kb_hits: f.useKb ? f.kbHits : 0, max_chars: f.maxChars }),
  }
}
const number = (v: unknown, fallback: number, min: number, max: number) =>
  typeof v === 'number' && Number.isInteger(v) && v >= min && v <= max
    ? v
    : fallback
function normalize(o: Partial<FilterState>): FilterState {
  return {
    ...DEFAULT_FILTERS,
    engine: o.engine === 'codex' ? 'codex' : 'ask',
    quartiles: Array.isArray(o.quartiles)
      ? [
          ...new Set(
            o.quartiles.filter((q) => Number.isInteger(q) && q >= 1 && q <= 4),
          ),
        ].sort()
      : [],
    keepUnranked: o.keepUnranked === true,
    yearMode:
      o.yearMode === 'range' || o.yearMode === 'any' ? o.yearMode : 'recent',
    years: number(o.years, 3, 1, 50),
    yearFrom: o.yearFrom == null ? null : number(o.yearFrom, 1900, 1900, 2100),
    yearTo:
      o.yearTo == null
        ? null
        : number(o.yearTo, new Date().getFullYear(), 1900, 2100),
    journals: Array.isArray(o.journals)
      ? [
          ...new Set(
            o.journals
              .filter((s): s is string => typeof s === 'string')
              .map((s) => s.trim().toLowerCase())
              .filter((s) => s.length > 0 && s.length <= 100),
          ),
        ]
      : [],
    papers: number(o.papers, 8, 1, 30),
    useKb: o.useKb !== false,
    kbHits: number(o.kbHits, 0, 0, 20),
    maxChars: number(o.maxChars, 28000, 4000, 60000),
  }
}
export function fromAnswerOptions(o: Record<string, unknown>): FilterState {
  return normalize({
    engine: o.engine === 'codex' ? 'codex' : 'ask',
    quartiles: o.quartiles as number[],
    keepUnranked: o.keep_unranked as boolean,
    yearMode:
      o.years != null ? 'recent' : o.year_from != null ? 'range' : 'any',
    years: o.years as number,
    yearFrom: o.year_from as number,
    yearTo: o.year_to as number,
    journals: o.journals as string[],
    papers: o.papers as number,
    useKb: o.use_kb as boolean,
    kbHits: o.kb_hits as number,
    maxChars: o.max_chars as number,
  })
}
export function describeFilters(f: FilterState): string {
  return [
    f.yearMode === 'recent'
      ? '近' + f.years + '年'
      : f.yearMode === 'range'
        ? (f.yearFrom ?? '起始年') + '–' + (f.yearTo ?? '至今')
        : '年份不限',
    f.quartiles.length
      ? f.quartiles.map((q) => 'Q' + q).join('/') +
        (f.keepUnranked ? ' + 未收录' : '')
      : '分区不限',
    ...(f.journals.length ? ['期刊含 ' + f.journals.join('|')] : []),
    f.papers + ' 篇',
  ].join(' · ')
}
export function loadFilters(): FilterState {
  try {
    return normalize(JSON.parse(localStorage.getItem('picoseek.filters') ?? '{}'))
  } catch {
    return { ...DEFAULT_FILTERS }
  }
}
export function saveFilters(f: FilterState) {
  localStorage.setItem('picoseek.filters', JSON.stringify(f))
}
