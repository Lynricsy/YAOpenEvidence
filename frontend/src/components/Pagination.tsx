import { ChevronLeft, ChevronRight } from 'lucide-react'
import { Button } from './ui/button'
export function Pagination({ total, limit, offset, onChange }: { total: number; limit: number; offset: number; onChange: (offset: number) => void }) {
  return <nav aria-label="分页" className="flex flex-wrap items-center justify-between gap-3 border-t py-5"><span className="text-xs text-muted-foreground">第 {total ? offset + 1 : 0}–{Math.min(offset + limit, total)} 条，共 {total} 条</span><div className="flex gap-2"><Button variant="outline" size="icon-sm" aria-label="上一页" title="上一页" disabled={offset <= 0} onClick={() => onChange(Math.max(0, offset - limit))}><ChevronLeft /></Button><Button variant="outline" size="icon-sm" aria-label="下一页" title="下一页" disabled={offset + limit >= total} onClick={() => onChange(offset + limit)}><ChevronRight /></Button></div></nav>
}
