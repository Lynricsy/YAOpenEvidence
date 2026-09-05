import type { ReactNode } from 'react'
export function QuoteHighlight({
  text,
  quotes,
}: {
  text: string
  quotes: string[]
}) {
  const ranges = quotes
    .filter(Boolean)
    .map((quote) => ({ start: text.indexOf(quote), length: quote.length }))
    .filter((r) => r.start >= 0)
    .sort((a, b) => a.start - b.start)
  let cursor = 0
  const parts: ReactNode[] = []
  for (const range of ranges) {
    if (range.start < cursor) continue
    const end = range.start + range.length
    parts.push(
      text.slice(cursor, range.start),
      <mark key={range.start}>{text.slice(range.start, end)}</mark>,
    )
    cursor = end
  }
  return (
    <>
      {parts}
      {text.slice(cursor)}
    </>
  )
}
