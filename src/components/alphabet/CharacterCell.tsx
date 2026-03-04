'use client'

import { useState } from 'react'
import { speak } from '@/lib/tts'
import { Volume2 } from 'lucide-react'

interface AlphabetCharacter {
  id: string
  character: string
  romanization: string
  group_name: string | null
}

interface CharacterCellProps {
  char: AlphabetCharacter
}

export function CharacterCell({ char }: CharacterCellProps) {
  const [playing, setPlaying] = useState(false)

  function handleClick() {
    speak(char.character)
    setPlaying(true)
    setTimeout(() => setPlaying(false), 600)
  }

  return (
    <button
      onClick={handleClick}
      className={`relative w-full h-20 md:h-24 flex flex-col items-center justify-center px-6 py-4 rounded-2xl border bg-card hover:bg-accent hover:border-primary transition-all duration-150 cursor-pointer ${playing ? 'bg-primary/10 border-primary scale-95' : ''
        }`}
      title={`${char.character} — ${char.romanization}`}
    >
      {playing && (
        <span className="absolute top-2 right-2 text-primary/80">
          <span className="absolute inset-0 rounded-full bg-primary/20 animate-ping" />
          <Volume2 className="relative h-4 w-4 animate-pulse drop-shadow-sm" />
        </span>
      )}

      <span className="text-2xl font-bold leading-none mb-2">
        {char.character}
      </span>
      <span className="text-xs text-muted-foreground">
        {char.romanization}
      </span>
    </button>
  )
}
