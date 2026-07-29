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

/**
 * Một ô có thể bị ẩn theo cột, nhưng BẤM VÀO thì lộ riêng ô đó.
 *
 * Đây mới là chỗ ẩn cột trở nên hữu ích: che nghĩa đi rồi tự dò từng dòng, dòng
 * nào không nhớ thì bấm xem ngay tại chỗ — không phải bật lại cả cột rồi nhìn
 * thấy hết đáp án của những dòng chưa đoán.
 *
 * Bấm lần nữa thì che lại, để dò lại được.
 */
function HidableCell({
  hidden,
  revealed,
  onToggle,
  children,
}: {
  hidden: boolean
  revealed: boolean
  onToggle: () => void
  children: React.ReactNode
}) {
  if (!hidden) return <>{children}</>
  if (revealed) {
    return (
      <button
        onClick={onToggle}
        title="Ẩn lại"
        className="text-left w-full cursor-pointer"
      >
        {children}
      </button>
    )
  }
  return (
    <button
      onClick={onToggle}
      title="Bấm để xem"
      className="text-left w-full text-muted-foreground/30 hover:text-muted-foreground/60 select-none cursor-pointer transition-colors"
    >
      ———
    </button>
  )
}

export function VocabSection({ vocabulary }: { vocabulary: MnnVocabulary[] }) {
  const [hideWord, setHideWord] = useState(false)
  const [hideRomaji, setHideRomaji] = useState(false)
  const [hideMeaning, setHideMeaning] = useState(false)

  /** Ô đã bấm để lộ, khoá dạng `id:cột`. */
  const [revealed, setRevealed] = useState<Set<string>>(new Set())

  function toggleCell(key: string) {
    setRevealed((prev) => {
      const next = new Set(prev)
      if (!next.delete(key)) next.add(key)
      return next
    })
  }

  /**
   * Bật/tắt cả cột thì XOÁ hết ô đã lộ của cột đó.
   *
   * Không xoá thì ẩn cột lại vẫn thấy lố nhố mấy ô đã bấm từ lượt trước —
   * người dùng tưởng ẩn hỏng.
   */
  function toggleColumn(col: string, set: (f: (v: boolean) => boolean) => void) {
    set((v) => !v)
    setRevealed((prev) => {
      const next = new Set(prev)
      for (const k of prev) if (k.endsWith(`:${col}`)) next.delete(k)
      return next
    })
  }

  return (
    <div className="space-y-3">
      <h3 className="text-base font-semibold">Từ vựng ({vocabulary.length} từ)</h3>
      <div className="rounded-xl border">
        <table className="w-full text-sm table-fixed">
          <colgroup>
            <col style={{ width: 40 }} />
            <col style={{ width: 160 }} />
            <col style={{ width: 130 }} />
            <col style={{ width: 200 }} />
            <col style={{ width: 100 }} />
            <col style={{ width: 48 }} />
          </colgroup>
          <thead className="sticky top-14 z-10">
            <tr>
              <th className="text-left px-4 py-3 font-medium text-muted-foreground bg-muted">#</th>
              <th className="text-left px-5 py-3 font-medium text-muted-foreground bg-muted">
                <span>Chữ</span>
                <ColumnToggle
                  hidden={hideWord}
                  onToggle={() => toggleColumn('word', setHideWord)}
                />
              </th>
              <th className="text-left px-5 py-3 font-medium text-muted-foreground bg-muted hidden sm:table-cell">
                <span>Romaji</span>
                <ColumnToggle
                  hidden={hideRomaji}
                  onToggle={() => toggleColumn('romaji', setHideRomaji)}
                />
              </th>
              <th className="text-left px-5 py-3 font-medium text-muted-foreground bg-muted">
                <span>Nghĩa</span>
                <ColumnToggle
                  hidden={hideMeaning}
                  onToggle={() => toggleColumn('meaning', setHideMeaning)}
                />
              </th>
              <th className="text-left px-5 py-3 font-medium text-muted-foreground bg-muted hidden md:table-cell">Loại từ</th>
              <th className="px-3 py-3 bg-muted" />
            </tr>
          </thead>
          <tbody>
            {vocabulary.map((v, i) => (
              <tr key={v.id} className="border-t hover:bg-muted/30 transition-colors">
                <td className="px-4 py-3.5 text-muted-foreground">{i + 1}</td>
                <td className="px-5 py-3.5">
                  <HidableCell
                    hidden={hideWord}
                    revealed={revealed.has(`${v.id}:word`)}
                    onToggle={() => toggleCell(`${v.id}:word`)}
                  >
                    <div>
                      <span className="font-japanese text-lg font-medium">{v.word}</span>
                      {v.reading && v.reading !== v.word && (
                        <span className="text-xs text-muted-foreground ml-1.5">({v.reading})</span>
                      )}
                    </div>
                  </HidableCell>
                </td>
                <td className="px-5 py-3.5 hidden sm:table-cell">
                  <HidableCell
                    hidden={hideRomaji}
                    revealed={revealed.has(`${v.id}:romaji`)}
                    onToggle={() => toggleCell(`${v.id}:romaji`)}
                  >
                    <span className="text-muted-foreground">{v.romanization}</span>
                  </HidableCell>
                </td>
                <td className="px-5 py-3.5 font-medium">
                  <HidableCell
                    hidden={hideMeaning}
                    revealed={revealed.has(`${v.id}:meaning`)}
                    onToggle={() => toggleCell(`${v.id}:meaning`)}
                  >
                    <span>{v.meaning_vi}</span>
                  </HidableCell>
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
