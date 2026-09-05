import { Badge } from './ui/badge'
export function RankBadge({ rank_label, quartile }: { rank_label?: string | null; quartile?: string | number | null }) {
  const q = String(quartile ?? '').match(/^(?:Q)?([1-4])$/i)?.[1]
  return <Badge variant="outline" className={q ? 'rank-badge' : 'status-neutral'} style={q ? { color: 'var(--q' + q + ')', borderColor: 'color-mix(in oklch, var(--q' + q + ') 35%, transparent)', backgroundColor: 'color-mix(in oklch, var(--q' + q + ') 9%, transparent)' } : undefined}>{rank_label || (q ? 'Q' + q : '未收录')}</Badge>
}
