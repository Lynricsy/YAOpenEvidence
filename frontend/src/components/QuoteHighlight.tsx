import { Fragment } from 'react'
export function QuoteHighlight({ text, quotes }: { text: string; quotes: string[] }) {
  const ranges = quotes.filter(Boolean).map(quote => ({ start: text.indexOf(quote), length: quote.length })).filter(r => r.start >= 0).sort((a,b) => a.start - b.start)
  let cursor = 0
  const parts = ranges.map((r,i) => { if (r.start < cursor) return null; const prefix = text.slice(cursor,r.start); cursor = r.start + r.length; return <Fragment key={i}>{prefix}<mark>{text.slice(r.start,cursor)}</mark></Fragment> })
  return <>{parts}{text.slice(cursor)}</>
}
