import type { ReactNode } from 'react'
import { ArrowUpRight } from 'lucide-react'

export function ExternalLink({
  href,
  children,
}: {
  href?: string | null
  children: ReactNode
}) {
  if (!href) return null
  try {
    if (!['https:', 'http:'].includes(new URL(href).protocol)) return null
  } catch {
    return null
  }
  return (
    <a
      href={href}
      target="_blank"
      rel="noopener noreferrer"
      className="inline-flex items-center gap-1 text-xs text-primary hover:underline"
    >
      {children}
      <ArrowUpRight className="size-3 shrink-0" />
    </a>
  )
}
export function PaperLinks({
  pmid,
  doi,
  pdf,
}: {
  pmid?: string | null
  doi?: string | null
  pdf?: string | null
}) {
  return (
    <div className="flex flex-wrap items-center gap-3">
      {pmid && (
        <ExternalLink
          href={
            'https://pubmed.ncbi.nlm.nih.gov/' + encodeURIComponent(pmid) + '/'
          }
        >
          PubMed
        </ExternalLink>
      )}
      {doi && (
        <ExternalLink
          href={
            'https://doi.org/' +
            doi.split('/').map(encodeURIComponent).join('/')
          }
        >
          DOI
        </ExternalLink>
      )}
      <ExternalLink href={pdf}>开放 PDF</ExternalLink>
    </div>
  )
}
export function positivePid(value: string | null) {
  if (!value || !/^\d+$/.test(value)) return null
  const pid = Number(value)
  return Number.isSafeInteger(pid) && pid > 0 ? pid : null
}
export function kindLabel(kind: string) {
  return (
    (
      {
        fact: '事实',
        paragraph: '段落',
        finding: '发现',
        method: '方法',
        limitation: '局限',
        background: '背景',
      } as Record<string, string>
    )[kind] ?? kind
  )
}
