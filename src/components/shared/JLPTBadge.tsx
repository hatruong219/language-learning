import { Badge } from '@/components/ui/badge'
import { cn } from '@/lib/utils'

const JLPT_COLORS: Record<string, string> = {
  N1: 'bg-red-100 text-red-800 border-red-200 dark:bg-red-900/20 dark:text-red-400',
  N2: 'bg-orange-100 text-orange-800 border-orange-200 dark:bg-orange-900/20 dark:text-orange-400',
  N3: 'bg-yellow-100 text-yellow-800 border-yellow-200 dark:bg-yellow-900/20 dark:text-yellow-400',
  N4: 'bg-blue-100 text-blue-800 border-blue-200 dark:bg-blue-900/20 dark:text-blue-400',
  N5: 'bg-green-100 text-green-800 border-green-200 dark:bg-green-900/20 dark:text-green-400',
}

export function JLPTBadge({ level, className }: { level: string | null; className?: string }) {
  if (!level) return null
  return (
    <Badge
      variant="outline"
      className={cn('text-xs font-semibold', JLPT_COLORS[level] ?? '', className)}
    >
      {level}
    </Badge>
  )
}
