import { formatDistanceToNow, format } from 'date-fns'
import { zhCN } from 'date-fns/locale'
export function relativeTime(value?: string | null) { if (!value) return ''; const date = new Date(value); return Number.isNaN(date.getTime()) ? value : formatDistanceToNow(date, { addSuffix: true, locale: zhCN }) }
export function dateTime(value?: string | null) { if (!value) return ''; const date = new Date(value); return Number.isNaN(date.getTime()) ? value : format(date, 'yyyy-MM-dd HH:mm') }
