import { fromMarkdown } from 'mdast-util-from-markdown'
import { SKIP, visit } from 'unist-util-visit'
export const MARKER_RE = /\[(\d{1,2})(?:¶(\d{1,4}))?\]/g
export const ANSWER_MD_LINK_RE =
  /^\/v1\/answers\/[^/]+\/papers\/(\d+)\/markdown(?:#p(\d+))?$/
export function markersToLinks(md: string, maxN: number): string {
  const edits: { start: number; end: number; text: string }[] = []
  visit(fromMarkdown(md), (node) => {
    if (
      [
        'link',
        'linkReference',
        'image',
        'imageReference',
        'code',
        'inlineCode',
        'html',
      ].includes(node.type)
    )
      return SKIP
    if (
      node.type !== 'text' ||
      node.position?.start.offset == null ||
      node.position.end.offset == null
    )
      return
    const start = node.position.start.offset,
      end = node.position.end.offset
    const raw = md.slice(start, end)
    const text = raw.replace(
      MARKER_RE,
      (marker, n: string, pid: string | undefined, offset: number) => {
        if (+n < 1 || +n > maxN || raw[offset - 1] === '\\') return marker
        return (
          '[' +
          n +
          (pid ? '¶' + pid : '') +
          '](#cite-' +
          n +
          '-' +
          (pid ?? '') +
          ')'
        )
      },
    )
    if (text !== raw) edits.push({ start, end, text })
  })
  for (const edit of edits.reverse())
    md = md.slice(0, edit.start) + edit.text + md.slice(edit.end)
  return md
}
export function parseCiteHref(
  href: string,
): { n: number; pid: number | null } | null {
  const match = /^#cite-([1-9]\d?)-(\d{1,4})?$/.exec(href)
  return match
    ? { n: Number(match[1]), pid: match[2] ? Number(match[2]) : null }
    : null
}
export const citationColors = [
  '#087f96',
  '#956124',
  '#6366a0',
  '#297d54',
  '#b34f69',
  '#397bb5',
  '#89742c',
  '#7d5b9e',
]
export function citationColor(n: number) {
  return citationColors[(n - 1) % citationColors.length] ?? citationColors[0]
}
