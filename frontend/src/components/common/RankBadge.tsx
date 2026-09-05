import type { CSSProperties } from 'react'
import { Pill } from './Pill'

export function RankBadge({
  rank_label,
  quartile,
}: {
  rank_label?: string | null
  quartile?: string | number | null
}) {
  const q = String(quartile ?? '').match(/^(?:Q)?([1-4])$/i)?.[1]
  if (!q) return <Pill>{rank_label || '未收录'}</Pill>
  return (
    <Pill style={{ '--tone': 'var(--q' + q + ')' } as CSSProperties}>
      {rank_label || 'Q' + q}
    </Pill>
  )
}
