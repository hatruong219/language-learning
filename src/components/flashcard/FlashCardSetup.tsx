'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { FlashCardDeck } from '@/components/flashcard/FlashCardDeck'
import type { Vocabulary } from '@/types/database'
import { Zap, Shuffle } from 'lucide-react'
import Link from 'next/link'

interface FlashCardSetupProps {
  cards: Vocabulary[]
  deckName?: string
  backHref?: string
}

const PRESETS = [10, 20, 30, 50]
const JLPT_LEVELS = ['N5', 'N4', 'N3', 'N2', 'N1'] as const

function shuffleArray<T>(arr: T[]): T[] {
  const a = [...arr]
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[a[i], a[j]] = [a[j], a[i]]
  }
  return a
}

export function FlashCardSetup({ cards, deckName, backHref = '/decks' }: FlashCardSetupProps) {
  const [selected, setSelected] = useState<number | null>(null)
  const [custom, setCustom] = useState('')
  const [shuffled, setShuffled] = useState(false)
  const [started, setStarted] = useState(false)
  const [studyCards, setStudyCards] = useState<Vocabulary[]>([])
  const [selectedJlpt, setSelectedJlpt] = useState<string[]>([])

  const filteredCards = cards.filter((card) => {
    if (selectedJlpt.length > 0) {
      if (!card.jlpt_level) return false
      return selectedJlpt.includes(card.jlpt_level)
    }
    return true
  })

  const total = filteredCards.length

  if (started && studyCards.length > 0) {
    return <FlashCardDeck cards={studyCards} deckName={deckName} backHref={backHref} />
  }

  function handleToggleJlpt(level: string) {
    setSelectedJlpt((prev) =>
      prev.includes(level) ? prev.filter((l) => l !== level) : [...prev, level],
    )
  }

  function handleStart() {
    if (total === 0) return

    let count = selected === -1 ? Number(custom) : (selected ?? total)
    if (!count || count <= 0) count = total
    if (count > total) count = total

    let baseCards = filteredCards
    if (shuffled) baseCards = shuffleArray(baseCards)

    const subset = baseCards.slice(0, count)
    setStudyCards(subset)
    setStarted(true)
  }

  const customNum = Number(custom)
  const isCustomValid = custom === '' || (customNum >= 1 && customNum <= total)

  return (
    <div className="flex items-center justify-center min-h-[calc(100vh-3.5rem)] p-4">
      <div className="w-full max-w-md">
        {/* Header */}
        <div className="text-center mb-8">
          <div className="text-5xl mb-3">🎴</div>
          <h1 className="text-2xl font-bold mb-1">{deckName ?? 'Học Flashcard'}</h1>
          <p className="text-muted-foreground text-sm">
            {total} từ có sẵn
            {selectedJlpt.length > 0 && ` · JLPT: ${selectedJlpt.join(', ')}`}
          </p>
        </div>

        {/* JLPT multi-select */}
        <div className="bg-card border rounded-2xl px-6 py-4 shadow-sm mb-4">
          <p className="text-sm font-semibold mb-3 text-muted-foreground uppercase tracking-wide">
            Chọn cấp độ JLPT (có thể chọn nhiều)
          </p>
          <div className="flex flex-wrap gap-2">
            {JLPT_LEVELS.map((level) => {
              const active = selectedJlpt.includes(level)
              return (
                <button
                  key={level}
                  type="button"
                  onClick={() => handleToggleJlpt(level)}
                  className={`px-3 py-1.5 rounded-full border text-xs font-semibold transition-all ${
                    active
                      ? 'bg-primary text-primary-foreground border-primary shadow-sm'
                      : 'bg-background text-muted-foreground hover:bg-accent border-border'
                  }`}
                >
                  {level}
                </button>
              )
            })}
          </div>
          {selectedJlpt.length > 0 && total === 0 && (
            <p className="text-xs text-red-500 mt-2">
              Không có từ nào phù hợp với cấp độ JLPT đã chọn.
            </p>
          )}
        </div>

        {/* Choose count */}
        <div className="bg-card border rounded-2xl p-6 shadow-sm mb-4">
          <p className="text-sm font-semibold mb-4 text-muted-foreground uppercase tracking-wide">
            Bạn muốn học bao nhiêu từ?
          </p>

          {/* Preset buttons */}
          <div className="grid grid-cols-2 gap-3 mb-4">
            {PRESETS.filter((n) => n <= total).map((n) => (
              <button
                key={n}
                type="button"
                onClick={() => {
                  setSelected(n)
                  setCustom('')
                }}
                className={`py-3 rounded-xl border text-sm font-semibold transition-all duration-150 ${
                  selected === n
                    ? 'bg-primary text-primary-foreground border-primary shadow-sm scale-[1.02]'
                    : 'bg-background hover:bg-accent border-border'
                }`}
              >
                {n} từ
              </button>
            ))}
            <button
              type="button"
              onClick={() => setSelected(total)}
              className={`py-3 rounded-xl border text-sm font-semibold transition-all duration-150 col-span-2 ${
                selected === total && selected !== -1
                  ? 'bg-primary text-primary-foreground border-primary shadow-sm scale-[1.02]'
                  : 'bg-background hover:bg-accent border-border'
              }`}
            >
              Tất cả ({total} từ)
            </button>
          </div>

          {/* Custom input */}
          <div className="flex items-center gap-2">
            <div className="relative flex-1">
              <input
                type="number"
                min={1}
                max={total}
                value={custom}
                placeholder={`Tùy chỉnh (1-${total || 0})`}
                onChange={(e) => {
                  setCustom(e.target.value)
                  setSelected(-1)
                }}
                className={`w-full px-3 py-2.5 rounded-xl border bg-background text-sm outline-none transition-colors focus:ring-2 focus:ring-primary/30 ${
                  !isCustomValid ? 'border-red-400' : 'border-border focus:border-primary'
                }`}
              />
            </div>
          </div>
          {!isCustomValid && (
            <p className="text-xs text-red-500 mt-1">
              Vui lòng nhập số từ 1 đến {total}
            </p>
          )}
        </div>

        {/* Options */}
        <div className="bg-card border rounded-2xl px-6 py-4 shadow-sm mb-6">
          <button
            type="button"
            onClick={() => setShuffled(!shuffled)}
            className={`flex items-center gap-3 w-full text-sm transition-colors ${
              shuffled ? 'text-primary font-medium' : 'text-muted-foreground'
            }`}
          >
            <div
              className={`w-5 h-5 rounded border-2 flex items-center justify-center transition-colors ${
                shuffled ? 'bg-primary border-primary' : 'border-border'
              }`}
            >
              {shuffled && <Shuffle className="h-3 w-3 text-primary-foreground" />}
            </div>
            Xáo trộn thứ tự thẻ
          </button>
        </div>

        {/* Start */}
        <Button
          className="w-full h-12 text-base font-semibold"
          disabled={
            total === 0 ||
            !isCustomValid ||
            (selected === -1 && (!custom || customNum < 1))
          }
          onClick={handleStart}
        >
          <Zap className="h-4 w-4 mr-2" />
          Bắt đầu học{' '}
          {total === 0
            ? ''
            : selected !== null && selected !== -1
              ? `(${Math.min(selected, total)} từ)`
              : custom
                ? `(${Math.min(customNum, total)} từ)`
                : `(${total} từ)`}
        </Button>

        <div className="text-center mt-4">
          <Link
            href={backHref}
            className="text-sm text-muted-foreground hover:text-foreground transition-colors"
          >
            ← Quay lại
          </Link>
        </div>
      </div>
    </div>
  )
}
