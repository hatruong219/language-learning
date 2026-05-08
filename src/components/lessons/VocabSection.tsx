'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { speak } from '@/lib/tts'
import type { MnnVocabulary } from '@/types/database'
import { Volume2, Eye, EyeOff } from 'lucide-react'
import { cn } from '@/lib/utils'

function TtsButton({ word }: { word: string }) {
  return (
    <Button size="icon" variant="ghost" className="h-8 w-8" onClick={() => speak(word)}>
      <Volume2 className="h-4 w-4" />
    </Button>
  )
}

function ColumnToggle({ hidden, onToggle }: { hidden: boolean; onToggle: () => void }) {
  return (
    <button
      onClick={onToggle}
      className={cn(
        'ml-1.5 inline-flex items-center justify-center h-5 w-5 rounded transition-colors',
        hidden
          ? 'text-primary bg-primary/10 hover:bg-primary/20'
          : 'text-muted-foreground hover:text-foreground hover:bg-muted',
      )}
      title={hidden ? 'Hiện cột' : 'Ẩn cột'}
    >
      {hidden ? <Eye className="h-3 w-3" /> : <EyeOff className="h-3 w-3" />}
    </button>
  )
}

export function VocabSection({ vocabulary }: { vocabulary: MnnVocabulary[] }) {
  const [hideRomaji, setHideRomaji] = useState(false)
  const [hideMeaning, setHideMeaning] = useState(false)

  return (
    <div className="space-y-3">
      <h3 className="text-base font-semibold">Từ vựng ({vocabulary.length} từ)</h3>
      <div className="rounded-xl border overflow-hidden">
        <table className="w-full text-sm table-fixed">
          <colgroup>
            <col style={{ width: 40 }} />
            <col style={{ width: 160 }} />
            <col style={{ width: 130 }} />
            <col style={{ width: 200 }} />
            <col style={{ width: 100 }} />
            <col style={{ width: 48 }} />
          </colgroup>
          <thead className="bg-muted/60">
            <tr>
              <th className="text-left px-4 py-3 font-medium text-muted-foreground">#</th>
              <th className="text-left px-5 py-3 font-medium text-muted-foreground">Chữ</th>
              <th className="text-left px-5 py-3 font-medium text-muted-foreground hidden sm:table-cell">
                <span>Romaji</span>
                <ColumnToggle hidden={hideRomaji} onToggle={() => setHideRomaji((v) => !v)} />
              </th>
              <th className="text-left px-5 py-3 font-medium text-muted-foreground">
                <span>Nghĩa</span>
                <ColumnToggle hidden={hideMeaning} onToggle={() => setHideMeaning((v) => !v)} />
              </th>
              <th className="text-left px-5 py-3 font-medium text-muted-foreground hidden md:table-cell">Loại từ</th>
              <th className="px-3 py-3" />
            </tr>
          </thead>
          <tbody>
            {vocabulary.map((v, i) => (
              <tr key={v.id} className="border-t hover:bg-muted/30 transition-colors">
                <td className="px-4 py-3.5 text-muted-foreground">{i + 1}</td>
                <td className="px-5 py-3.5">
                  <div>
                    <span className="font-japanese text-lg font-medium">{v.word}</span>
                    {v.reading && v.reading !== v.word && (
                      <span className="text-xs text-muted-foreground ml-1.5">({v.reading})</span>
                    )}
                  </div>
                </td>
                <td className="px-5 py-3.5 hidden sm:table-cell">
                  {hideRomaji
                    ? <span className="text-muted-foreground/30 select-none">———</span>
                    : <span className="text-muted-foreground">{v.romanization}</span>}
                </td>
                <td className="px-5 py-3.5 font-medium">
                  {hideMeaning
                    ? <span className="text-muted-foreground/30 select-none">———</span>
                    : v.meaning_vi}
                </td>
                <td className="px-5 py-3.5 hidden md:table-cell">
                  {v.part_of_speech && (
                    <span className="text-xs bg-muted px-2 py-0.5 rounded font-japanese text-muted-foreground whitespace-nowrap">
                      {v.part_of_speech}
                    </span>
                  )}
                </td>
                <td className="px-3 py-3.5">
                  <TtsButton word={v.word} />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}
