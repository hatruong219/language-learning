'use client'

import { useState } from 'react'
import { speak } from '@/lib/tts'
import { Volume2 } from 'lucide-react'
import { cn } from '@/lib/utils'

interface AlphabetCharacter {
  id: string
  character: string
  romanization: string
  group_name: string | null
}

export type AccentColor =
  | 'slate' | 'blue' | 'green' | 'amber' | 'rose' | 'purple'
  | 'cyan' | 'orange' | 'yellow' | 'indigo' | 'pink'

const ACCENT: Record<AccentColor, { bg: string; border: string; roma: string; playing: string }> = {
  slate:  { bg: 'bg-slate-50 dark:bg-slate-900/40',    border: 'border-slate-200 dark:border-slate-700',   roma: 'text-slate-500',   playing: 'bg-slate-100 border-slate-400' },
  blue:   { bg: 'bg-blue-50 dark:bg-blue-950/40',      border: 'border-blue-200 dark:border-blue-700',     roma: 'text-blue-500',    playing: 'bg-blue-100 border-blue-400' },
  green:  { bg: 'bg-green-50 dark:bg-green-950/40',    border: 'border-green-200 dark:border-green-700',   roma: 'text-green-500',   playing: 'bg-green-100 border-green-400' },
  amber:  { bg: 'bg-amber-50 dark:bg-amber-950/40',    border: 'border-amber-200 dark:border-amber-700',   roma: 'text-amber-500',   playing: 'bg-amber-100 border-amber-400' },
  rose:   { bg: 'bg-rose-50 dark:bg-rose-950/40',      border: 'border-rose-200 dark:border-rose-700',     roma: 'text-rose-500',    playing: 'bg-rose-100 border-rose-400' },
  purple: { bg: 'bg-purple-50 dark:bg-purple-950/40',  border: 'border-purple-200 dark:border-purple-700', roma: 'text-purple-500',  playing: 'bg-purple-100 border-purple-400' },
  cyan:   { bg: 'bg-cyan-50 dark:bg-cyan-950/40',      border: 'border-cyan-200 dark:border-cyan-700',     roma: 'text-cyan-500',    playing: 'bg-cyan-100 border-cyan-400' },
  orange: { bg: 'bg-orange-50 dark:bg-orange-950/40',  border: 'border-orange-200 dark:border-orange-700', roma: 'text-orange-500',  playing: 'bg-orange-100 border-orange-400' },
  yellow: { bg: 'bg-yellow-50 dark:bg-yellow-950/40',  border: 'border-yellow-200 dark:border-yellow-700', roma: 'text-yellow-500',  playing: 'bg-yellow-100 border-yellow-400' },
  indigo: { bg: 'bg-indigo-50 dark:bg-indigo-950/40',  border: 'border-indigo-200 dark:border-indigo-700', roma: 'text-indigo-500',  playing: 'bg-indigo-100 border-indigo-400' },
  pink:   { bg: 'bg-pink-50 dark:bg-pink-950/40',      border: 'border-pink-200 dark:border-pink-700',     roma: 'text-pink-500',    playing: 'bg-pink-100 border-pink-400' },
}

interface CharacterCellProps {
  char: AlphabetCharacter
  accent?: AccentColor
}

export function CharacterCell({ char, accent }: CharacterCellProps) {
  const [playing, setPlaying] = useState(false)
  const a = accent ? ACCENT[accent] : null

  function handleClick() {
    speak(char.character)
    setPlaying(true)
    setTimeout(() => setPlaying(false), 600)
  }

  return (
    <button
      onClick={handleClick}
      className={cn(
        'relative w-full h-20 md:h-24 flex flex-col items-center justify-center px-6 py-4 rounded-2xl border transition-all duration-150 cursor-pointer',
        a ? `${a.bg} ${a.border}` : 'bg-card border-border',
        playing
          ? (a ? a.playing : 'bg-primary/10 border-primary') + ' scale-95'
          : 'hover:border-primary hover:brightness-95',
      )}
      title={`${char.character} — ${char.romanization}`}
    >
      {playing && (
        <span className="absolute top-2 right-2 text-primary/80">
          <span className="absolute inset-0 rounded-full bg-primary/20 animate-ping" />
          <Volume2 className="relative h-4 w-4 animate-pulse drop-shadow-sm" />
        </span>
      )}
      <span className="text-2xl font-bold leading-none mb-2 whitespace-nowrap">{char.character}</span>
      <span className={cn('text-xs', a ? a.roma : 'text-muted-foreground')}>
        {char.romanization}
      </span>
    </button>
  )
}
