import { Suspense, useCallback, useEffect, useState } from 'react'
import { Outlet } from 'react-router'
import { BREAKPOINTS } from '@/lib/useMediaQuery'
import { AppSidebar } from './AppSidebar'
import { MobileTabBar } from './MobileTabBar'
import { MobileTopBar } from './MobileTopBar'
import { PageSkeleton } from './PageSkeleton'
import { PageTransition } from './PageTransition'

export function AppShell() {
  // 未手动设置过时按视口决定：≥xl 展开，md–xl 折叠为图标栏。
  const [collapsed, setCollapsed] = useState(() => {
    const saved = localStorage.getItem('yaoe.sidebar')
    return saved ? saved === 'collapsed' : !matchMedia(BREAKPOINTS.xl).matches
  })
  const toggle = useCallback(
    () =>
      setCollapsed((current) => {
        localStorage.setItem('yaoe.sidebar', current ? 'expanded' : 'collapsed')
        return !current
      }),
    [],
  )
  useEffect(() => {
    const onKeyDown = (event: KeyboardEvent) => {
      if (!(event.metaKey || event.ctrlKey) || event.key.toLowerCase() !== 'b')
        return
      const target = event.target as HTMLElement | null
      if (
        target?.isContentEditable ||
        target?.tagName === 'INPUT' ||
        target?.tagName === 'TEXTAREA'
      )
        return
      event.preventDefault()
      toggle()
    }
    window.addEventListener('keydown', onKeyDown)
    return () => window.removeEventListener('keydown', onKeyDown)
  }, [toggle])
  return (
    <div className="flex h-dvh flex-col md:flex-row">
      <AppSidebar collapsed={collapsed} onToggle={toggle} />
      <MobileTopBar />
      <main id="main-content" className="flex min-h-0 flex-1 flex-col">
        <PageTransition>
          <Suspense fallback={<PageSkeleton />}>
            <Outlet />
          </Suspense>
        </PageTransition>
      </main>
      <MobileTabBar />
    </div>
  )
}
