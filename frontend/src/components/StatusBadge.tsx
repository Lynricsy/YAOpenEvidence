import { Loader2 } from 'lucide-react'
import { Badge } from './ui/badge'
const statuses: Record<string, [string, string]> = { queued: ['排队中', 'status-neutral'], running: ['进行中', 'status-blue'], ready: ['已完成', 'status-green'], succeeded: ['已完成', 'status-green'], failed: ['失败', 'status-red'], cancelled: ['已取消', 'status-amber'] }
export function StatusBadge({ status }: { status: string }) { const [label, color] = statuses[status] ?? [status, 'status-neutral']; return <Badge variant="outline" className={color}>{status === 'running' && <Loader2 className="size-3 animate-spin" />}{label}</Badge> }
