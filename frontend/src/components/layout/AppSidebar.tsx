import { Link, NavLink, useNavigate } from 'react-router'
import { PanelLeftClose, PanelLeftOpen, Plus } from 'lucide-react'
import { cn } from 'cn'
import { useAnswers } from '@/api/queries'
import { useAuth } from '@/auth/store'
import { BrandLogo } from '@/components/common/BrandLogo'
import { statusTone } from '@/components/common/StatusBadge'
import { Button } from '@/components/ui/button'
import { Separator } from '@/components/ui/separator'
import { Skeleton } from '@/components/ui/skeleton'
import {
  Tooltip,
  TooltipContent,
  TooltipTrigger,
} from '@/components/ui/tooltip'
import { NAV_GROUPS } from './nav'
import { UserMenu } from './UserMenu'

const toneVar: Record<string, string> = {
  neutral: 'var(--muted-foreground)',
  info: 'var(--info)',
  success: 'var(--success)',
  warning: 'var(--warning)',
  danger: 'var(--danger)',
  primary: 'var(--primary)',
}

function RecentAnswers() {
  const recent = useAnswers({ limit: 5, offset: 0 })
  if (recent.isPending)
    return (
      <div className="space-y-2 px-2.5 pt-4">
        {[0, 1, 2].map((i) => (
          <Skeleton key={i} className="h-4 w-full" />
        ))}
      </div>
    )
  const items = recent.data?.items ?? []
  if (!items.length) return null
  return (
    <>
      <p className="section-label px-2 pt-3 pb-1">最近问答</p>
      {items.map((answer) => (
        <NavLink
          key={answer.id}
          to={'/a/' + answer.id}
          title={answer.question}
          className={({ isActive }) =>
            cn(
              'flex h-8 items-center gap-2 rounded-md px-2.5 text-[13px] text-muted-foreground transition-colors hover:bg-accent/60 hover:text-foreground',
              isActive && 'bg-accent font-medium text-foreground',
            )
          }
        >
          <span
            className="size-1.5 shrink-0 rounded-full"
            style={{ background: toneVar[statusTone(answer.status)] }}
          />
          <span className="truncate">{answer.question}</span>
        </NavLink>
      ))}
    </>
  )
}

export function AppSidebar({
  collapsed,
  onToggle,
}: {
  collapsed: boolean
  onToggle: () => void
}) {
  const { isAdmin } = useAuth()
  const navigate = useNavigate()
  const toggleButton = (
    <Button
      variant="ghost"
      size="icon-sm"
      aria-label={collapsed ? '展开侧边栏' : '折叠侧边栏'}
      title="⌘/Ctrl + B"
      onClick={onToggle}
      className={collapsed ? 'mx-auto' : 'ml-auto'}
    >
      {collapsed ? <PanelLeftOpen /> : <PanelLeftClose />}
    </Button>
  )
  return (
    <aside
      className={cn(
        'hidden h-full shrink-0 flex-col border-r bg-sidebar transition-[width] duration-200 ease-[cubic-bezier(.22,1,.36,1)] md:flex',
        collapsed ? 'w-16' : 'w-64',
      )}
    >
      <div className="flex h-14 items-center gap-2 px-3">
        <Link
          to="/"
          className="flex min-w-0 items-center gap-2"
          aria-label="PicoSeek 首页"
        >
          <BrandLogo size={28} />
          {!collapsed && (
            <span className="truncate font-serif text-[15px] font-semibold tracking-tight">
              PicoSeek
            </span>
          )}
        </Link>
        {!collapsed && toggleButton}
      </div>
      {collapsed && <div className="flex px-3 pb-1">{toggleButton}</div>}
      <div className="px-3 pb-2">
        {collapsed ? (
          <Tooltip>
            <TooltipTrigger asChild>
              <Button
                size="icon"
                aria-label="新建问答"
                className="mx-auto"
                onClick={() => navigate('/', { state: { focus: Date.now() } })}
              >
                <Plus />
              </Button>
            </TooltipTrigger>
            <TooltipContent side="right">新建问答</TooltipContent>
          </Tooltip>
        ) : (
          <Button
            className="w-full justify-start"
            onClick={() => navigate('/', { state: { focus: Date.now() } })}
          >
            <Plus />
            新建问答
          </Button>
        )}
      </div>
      <nav
        aria-label="主导航"
        className="flex-1 overflow-y-auto px-3 py-2"
        data-testid="sidebar-nav"
      >
        {NAV_GROUPS.map((group, groupIndex) => {
          const items = group.items.filter((item) => isAdmin || !item.admin)
          if (!items.length) return null
          return (
            <div key={group.label}>
              {collapsed ? (
                groupIndex > 0 && <Separator className="my-2" />
              ) : (
                <p className="section-label px-2 pt-3 pb-1">{group.label}</p>
              )}
              {items.map(({ to, label, icon: Icon, end }) => {
                const link = (
                  <NavLink
                    to={to}
                    end={end}
                    className={({ isActive }) =>
                      cn(
                        'flex h-9 items-center gap-2.5 rounded-md px-2.5 text-sm text-muted-foreground transition-colors hover:bg-accent/60 hover:text-foreground',
                        isActive &&
                          'bg-accent font-medium text-foreground [&>svg]:text-primary',
                        collapsed && 'justify-center px-0',
                      )
                    }
                  >
                    <Icon className="size-4 shrink-0" />
                    {!collapsed && label}
                  </NavLink>
                )
                return collapsed ? (
                  <Tooltip key={to}>
                    <TooltipTrigger asChild>{link}</TooltipTrigger>
                    <TooltipContent side="right">{label}</TooltipContent>
                  </Tooltip>
                ) : (
                  <div key={to}>{link}</div>
                )
              })}
              {!collapsed && groupIndex === 0 && <RecentAnswers />}
            </div>
          )
        })}
      </nav>
      <div className="border-t p-2">
        <UserMenu collapsed={collapsed} />
      </div>
    </aside>
  )
}
