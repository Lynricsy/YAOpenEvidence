import { Pill } from './Pill'

const labels: Record<string, string> = {
  pmc: '全文 · PMC',
  pdf: '全文 · PDF',
  inst: '全文 · 机构',
  upload: '全文 · 上传',
  abstract: '仅摘要',
}

export function SourceBadge({ source }: { source?: string }) {
  return <Pill>{labels[source ?? 'abstract'] ?? source}</Pill>
}
