import { useEffect, useMemo, useRef } from 'react'
import { MarkdownView } from './MarkdownView'
export function ParagraphMarkdown({
  markdown,
  pid,
  quotes = [],
}: {
  markdown: string
  pid: number | null
  quotes?: string[]
}) {
  const root = useRef<HTMLDivElement>(null)
  const highlighted = useMemo(() => {
    if (pid == null || !quotes.length) return markdown
    return markdown
      .split('\n')
      .map((line) => {
        if (!line.includes('<a id="p' + pid + '"')) return line
        for (const quote of quotes) {
          if (quote)
            line = line.replace(quote, () => '<mark>' + quote + '</mark>')
        }
        return line
      })
      .join('\n')
  }, [markdown, pid, quotes])
  useEffect(() => {
    if (pid == null) return
    let timer: number | undefined
    let paragraph: HTMLElement | null = null
    const frame = requestAnimationFrame(() => {
      const anchor = root.current?.querySelector<HTMLElement>(
        '[id="user-content-p' + pid + '"]',
      )
      paragraph = anchor?.parentElement ?? null
      if (paragraph) {
        paragraph.scrollIntoView({ block: 'center' })
        paragraph.classList.add('paragraph-highlight')
        timer = setTimeout(
          () => paragraph?.classList.remove('paragraph-highlight'),
          2000,
        )
      }
    })
    return () => {
      cancelAnimationFrame(frame)
      clearTimeout(timer)
      paragraph?.classList.remove('paragraph-highlight')
    }
  }, [highlighted, pid])
  return (
    <div ref={root}>
      <MarkdownView markdown={highlighted} />
    </div>
  )
}
