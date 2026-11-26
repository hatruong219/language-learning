'use client'

import { Volume2 } from 'lucide-react'
import { speak } from '@/lib/tts'
import type { KanjiWord } from '@/lib/daily-kanji'

/**
 * Bấm vào từ để nghe. Đọc theo kana chứ không theo chữ Hán: máy đọc chữ Hán
 * hay sai đúng những từ đọc đặc biệt (今日, 一日…) mà ta muốn luyện.
 */
export function WordList({ words }: { words: KanjiWord[] }) {
  return (
    <ul className="space-y-2">
      {words.map(([word, kana, meaning, note]) => (
        <li key={word}>
          <button
            type="button"
            onClick={() => speak(kana)}
            className="flex w-full items-center gap-3 rounded-xl border bg-card px-4 py-3 text-left transition-colors hover:bg-accent active:bg-accent"
          >
            <span className="min-w-0 flex-1">
              <span className="flex flex-wrap items-baseline gap-x-2">
                <span className="text-lg font-japanese">{word}</span>
                <span className="text-sm text-muted-foreground font-japanese">{kana}</span>
              </span>
              <span className="block text-sm text-muted-foreground">
                {meaning}
                {note && <span className="ml-1.5 text-amber-600 dark:text-amber-400">⚠️ {note}</span>}
              </span>
            </span>
            <Volume2 className="h-4 w-4 shrink-0 text-muted-foreground" />
          </button>
        </li>
      ))}
    </ul>
  )
}
