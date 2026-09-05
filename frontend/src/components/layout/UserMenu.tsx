import { Link } from 'react-router'
import {
  ChevronsUpDown,
  LogOut,
  Monitor,
  Moon,
  Settings,
  Sun,
  type LucideIcon,
} from 'lucide-react'
import { cn } from 'cn'
import { useAuth } from '@/auth/store'
import { useTheme, type Theme } from '@/lib/theme'
import { Pill } from '@/components/common/Pill'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuRadioGroup,
  DropdownMenuRadioItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import {
  Tooltip,
  TooltipContent,
  TooltipTrigger,
} from '@/components/ui/tooltip'

const themes: { value: Theme; label: string; icon: LucideIcon }[] = [
  { value: 'system', label: '跟随系统', icon: Monitor },
  { value: 'light', label: '浅色', icon: Sun },
  { value: 'dark', label: '深色', icon: Moon },
]

export function UserMenu({
  collapsed,
  menuSide = 'top',
}: {
  collapsed: boolean
  menuSide?: 'top' | 'bottom'
}) {
  const { user, isAdmin, logout } = useAuth()
  const { theme, setTheme } = useTheme()
  const role = isAdmin ? '管理员' : '用户'
  // 折叠态只留头像；Tooltip 必须包在 DropdownMenuTrigger 外层，
  // 两个 asChild Slot 才能把 props 逐层透传到同一个 <button>。
  const trigger = (
    <DropdownMenuTrigger asChild>
      <button
        type="button"
        aria-label="账号菜单"
        className={cn(
          'flex w-full items-center gap-2.5 rounded-md px-2 py-2 transition-colors hover:bg-accent/60',
          collapsed && 'justify-center',
        )}
      >
        <span className="grid size-7 shrink-0 place-items-center rounded-full bg-primary/15 text-xs font-semibold uppercase text-primary">
          {user?.username?.[0] ?? '?'}
        </span>
        {!collapsed && (
          <>
            <span className="min-w-0 flex-1 text-left">
              <span className="block truncate text-sm">{user?.username}</span>
              <span className="block text-[11px] text-muted-foreground">
                {role}
              </span>
            </span>
            <ChevronsUpDown className="ml-auto size-3.5 shrink-0 text-muted-foreground" />
          </>
        )}
      </button>
    </DropdownMenuTrigger>
  )
  return (
    <DropdownMenu>
      {collapsed ? (
        <Tooltip>
          <TooltipTrigger asChild>{trigger}</TooltipTrigger>
          <TooltipContent side="right">账号菜单</TooltipContent>
        </Tooltip>
      ) : (
        trigger
      )}
      <DropdownMenuContent
        side={menuSide}
        align={menuSide === 'bottom' ? 'end' : 'start'}
        className="w-56"
      >
        <div className="flex items-center justify-between gap-2 px-2 py-2">
          <span className="min-w-0 truncate text-sm">{user?.username}</span>
          <Pill tone={isAdmin ? 'primary' : 'neutral'}>{role}</Pill>
        </div>
        <DropdownMenuSeparator />
        <DropdownMenuItem asChild>
          <Link to="/account">
            <Settings />
            账号设置
          </Link>
        </DropdownMenuItem>
        <DropdownMenuSeparator />
        <DropdownMenuLabel>主题</DropdownMenuLabel>
        <DropdownMenuRadioGroup
          value={theme}
          onValueChange={(value) => setTheme(value as Theme)}
        >
          {themes.map(({ value, label, icon: Icon }) => (
            <DropdownMenuRadioItem key={value} value={value}>
              <Icon />
              {label}
            </DropdownMenuRadioItem>
          ))}
        </DropdownMenuRadioGroup>
        <DropdownMenuSeparator />
        <DropdownMenuItem variant="destructive" onSelect={() => void logout()}>
          <LogOut />
          退出登录
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  )
}
