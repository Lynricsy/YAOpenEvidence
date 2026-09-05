import { Badge } from './ui/badge'
export function SourceBadge({ source }: { source?: string }) { return <Badge variant="secondary">{({ pmc: '全文 · PMC', pdf: '全文 · PDF', inst: '全文 · 机构', abstract: '仅摘要' } as Record<string, string>)[source ?? 'abstract'] ?? source}</Badge> }
