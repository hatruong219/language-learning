'use client'

import type { MouseEvent } from 'react'
import Link from 'next/link'
import { useRouter } from 'nextjs-toploader/app'
import { Card, CardContent } from '@/components/ui/card'
import { JLPTBadge } from '@/components/shared/JLPTBadge'
import { TTSButton } from '@/components/shared/TTSButton'
import type { VocabularyWithDeck } from '@/types/database'
import { ChevronRight } from 'lucide-react'

interface WordCardProps {
  word: VocabularyWithDeck
  showDeck?: boolean
}

export function WordCard({ word, showDeck = false }: WordCardProps) {
  const router = useRouter()

  function handleCardClick(e: MouseEvent<HTMLDivElement>) {
    // Không điều hướng khi click nút TTS hoặc link "Xem chi tiết"
    if ((e.target as HTMLElement).closest('[data-no-navigate]')) return
    const sel = window.getSelection()
    if (sel?.type === 'Range' && sel.toString().trim().length > 0) return
    router.push(`/vocabulary/${word.id}`)
  }

  return (
    <Card
      role="button"
      tabIndex={0}
      className="group hover:shadow-md transition-all duration-200 hover:-translate-y-0.5 relative hover:border-primary/50 cursor-pointer"
      onClick={handleCardClick}
      onKeyDown={(e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault()
          router.push(`/vocabulary/${word.id}`)
        }
      }}
      aria-label={`Xem chi tiết từ ${word.word}`}
    >
      <CardContent className="p-4">
        <div className="flex items-start justify-between gap-2">
          {/* Vùng này không nằm trong <a> → kéo chuột bôi đen bình thường */}
          <div className="flex-1 min-w-0 select-text cursor-text">
            {/* Word + Hiragana dưới chữ */}
            <div className="mb-1">
              <div className="flex items-center gap-2">
                <span className="text-2xl font-bold leading-tight group-hover:text-primary transition-colors">
                  {word.word}
                </span>
                <span data-no-navigate>
                  <TTSButton text={word.word} className="relative z-10" />
                </span>
              </div>
              {word.reading && word.reading !== word.word && (
                <div className="text-xs text-muted-foreground mt-0.5">{word.reading}</div>
              )}
            </div>

            {word.romanization && (
              <p className="text-sm text-muted-foreground mb-1">{word.romanization}</p>
            )}

            <p className="text-sm font-medium text-foreground/80 line-clamp-2">
              {word.meaning_vi}
            </p>

            <div className="flex items-center gap-2 mt-2 flex-wrap">
              <JLPTBadge level={word.jlpt_level} />
              {word.part_of_speech && (
                <span className="text-xs text-muted-foreground bg-muted px-1.5 py-0.5 rounded">
                  {word.part_of_speech}
                </span>
              )}
              {showDeck && word.deck && (
                <span className="text-xs text-muted-foreground group-hover:text-primary transition-colors">
                  {word.deck.emoji} {word.deck.name}
                </span>
              )}
            </div>
          </div>

          {/* Link riêng để vào detail + có progress bar */}
          <Link
            href={`/vocabulary/${word.id}`}
            className="self-center shrink-0 p-1.5 rounded-md text-muted-foreground hover:text-primary hover:bg-accent transition-colors"
            aria-label={`Xem chi tiết từ ${word.word}`}
            onClick={(e) => e.stopPropagation()}
          >
            <ChevronRight className="h-5 w-5" />
          </Link>
        </div>
      </CardContent>
    </Card>
  )
}
