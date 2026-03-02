'use client'

import { useState } from 'react'
import { speak } from '@/lib/tts'
import { TTSButton } from '@/components/shared/TTSButton'

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
  const [selected, setSelected] = useState(false)

  return (
    <>
      <button
        onClick={() => { setSelected(true); speak(char.character) }}
        className="flex flex-col items-center justify-center p-3 rounded-xl border bg-card hover:bg-accent hover:border-primary transition-all duration-150 cursor-pointer aspect-square"
        title={char.romanization}
      >
        <span className="text-2xl font-bold leading-none mb-1">{char.character}</span>
        <span className="text-xs text-muted-foreground">{char.romanization}</span>
      </button>

      {/* Simple inline popup using dialog */}
      {selected && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm"
          onClick={() => setSelected(false)}
        >
          <div
            className="bg-card border rounded-2xl p-8 text-center shadow-xl max-w-xs w-full mx-4"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="text-7xl font-bold mb-2">{char.character}</div>
            <div className="text-xl text-muted-foreground mb-4">{char.romanization}</div>
            <TTSButton text={char.character} variant="outline" size="default" className="w-full" />
            <button
              onClick={() => setSelected(false)}
              className="mt-3 text-sm text-muted-foreground hover:text-foreground transition-colors"
            >
              Đóng
            </button>
          </div>
        </div>
      )}
    </>
  )
}
