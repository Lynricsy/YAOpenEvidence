import type { ReactNode } from 'react'
import { useLocation } from 'react-router'
import { AnimatePresence } from 'motion/react'
import * as m from 'motion/react-m'
import { ease } from '@/lib/motion'
import { routeKey } from './nav'

export function PageTransition({ children }: { children: ReactNode }) {
  const { pathname } = useLocation()
  return (
    <AnimatePresence mode="wait" initial={false}>
      <m.div
        key={routeKey(pathname)}
        className="flex min-h-0 flex-1 flex-col"
        initial={{ opacity: 0, y: 6 }}
        animate={{ opacity: 1, y: 0 }}
        exit={{ opacity: 0, y: -4 }}
        transition={{ duration: 0.18, ease }}
      >
        {children}
      </m.div>
    </AnimatePresence>
  )
}
