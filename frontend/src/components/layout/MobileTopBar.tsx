import { Link } from 'react-router'
import { BookOpenCheck } from 'lucide-react'
import { UserMenu } from './UserMenu'

export function MobileTopBar() {
  return (
    <header className="flex h-12 shrink-0 items-center justify-between gap-2 border-b bg-background/90 px-3 backdrop-blur md:hidden">
      <Link
        to="/"
        className="flex min-w-0 items-center gap-2"
        aria-label="YAOpenEvidence 首页"
      >
        <span className="grid size-6 shrink-0 place-items-center rounded-md bg-primary text-primary-foreground">
          <BookOpenCheck className="size-3.5" />
        </span>
        <span className="truncate font-serif text-sm font-semibold tracking-tight">
          YAOpenEvidence
        </span>
      </Link>
      <div className="w-9 shrink-0">
        <UserMenu collapsed menuSide="bottom" />
      </div>
    </header>
  )
}
