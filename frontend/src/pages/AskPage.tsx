import { useState } from 'react'
import { FilterSidebar } from '@/components/FilterSidebar'
import { EmptyState } from '@/components/EmptyState'
import { loadFilters, saveFilters, type FilterState } from '@/lib/filters'
export default function AskPage() {
  const [filters, setFilters] = useState(loadFilters)
  const update = (f: FilterState) => { setFilters(f); saveFilters(f) }
  return <div className="relative flex h-[calc(100dvh-3.5rem)]"><FilterSidebar value={filters} onChange={update} /><div className="min-w-0 flex-1 pt-16"><EmptyState title="循证医学文献问答" description="从 PubMed / Europe PMC 检索并逐篇核实，给出可回溯到原文段落的综述" /></div></div>
}
