'use client'

import { useReducer, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { FuriganaText } from '@/components/shared/FuriganaText'
import { JLPTBadge } from '@/components/shared/JLPTBadge'
import { Button } from '@/components/ui/button'
import { Progress } from '@/components/ui/progress'
import { speak } from '@/lib/tts'
import {
  studyReducer,
  createInitialState,
  getProgress,
  type StudyState,
} from '@/lib/flashcard-utils'
import type { Vocabulary } from '@/types/database'
import { X, RotateCcw, Volume2, Home, ChevronLeft, ChevronRight } from 'lucide-react'
import Link from 'next/link'

interface FlashCardDeckProps {
  cards: Vocabulary[]
  deckName?: string
  backHref?: string
}

export function FlashCardDeck({ cards, deckName, backHref = '/decks' }: FlashCardDeckProps) {
  const [state, dispatch] = useReducer(studyReducer, cards, createInitialState)

  const currentCard = state.cards[state.currentIndex]
  const progress = getProgress(state)

  // Keyboard shortcuts
  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if (state.phase === 'complete') return
      if (e.code === 'Space') { e.preventDefault(); dispatch({ type: 'FLIP' }) }
      if (e.code === 'ArrowLeft') dispatch({ type: 'PREV' })
      if (e.code === 'ArrowRight') dispatch({ type: 'NEXT' })
    }
    window.addEventListener('keydown', handler)
    return () => window.removeEventListener('keydown', handler)
  }, [state.phase])

  // Auto-play TTS when card flips to back
  useEffect(() => {
    if (state.isFlipped && currentCard) {
      speak(currentCard.word)
    }
  }, [state.isFlipped, currentCard])

  if (state.phase === 'complete') {
    return <StudyResult state={state} onRestart={() => dispatch({ type: 'RESTART' })} backHref={backHref} />
  }

  if (!currentCard) return null

  return (
    <div className="flex flex-col h-[calc(100vh-3.5rem)]">
      {/* Top bar */}
      <div className="flex items-center justify-between px-4 py-3 border-b">
        <Link href={backHref} className="text-muted-foreground hover:text-foreground transition-colors">
          <X className="h-5 w-5" />
        </Link>
        <div className="text-sm text-muted-foreground font-medium">
          {deckName && <span className="mr-2">{deckName}</span>}
          {state.currentIndex + 1} / {state.cards.length}
        </div>
        <div className="w-5" />
      </div>

      {/* Progress */}
      <Progress value={progress} className="h-1 rounded-none" />

      {/* Card area with flanking arrows */}
      <div className="flex-1 flex items-center justify-center p-4">
        <div className="flex items-center gap-3 w-full max-w-xl">

          {/* Prev */}
          <button
            onClick={() => dispatch({ type: 'PREV' })}
            disabled={state.currentIndex === 0}
            className="shrink-0 rounded-full p-3 border bg-background hover:bg-muted disabled:opacity-20 disabled:cursor-not-allowed transition-colors"
            aria-label="Thẻ trước"
          >
            <ChevronLeft className="h-5 w-5" />
          </button>

          {/* Card */}
          <div
            className="flex-1 cursor-pointer select-none"
            onClick={() => dispatch({ type: 'FLIP' })}
          >
            <AnimatePresence mode="wait">
              <motion.div
                key={currentCard.id + (state.isFlipped ? '-back' : '-front')}
                initial={{ rotateY: state.isFlipped ? -90 : 90, opacity: 0 }}
                animate={{ rotateY: 0, opacity: 1 }}
                exit={{ rotateY: state.isFlipped ? 90 : -90, opacity: 0 }}
                transition={{ duration: 0.2, ease: 'easeOut' }}
                className="bg-card border rounded-2xl shadow-lg min-h-64 flex flex-col items-center justify-center p-8 text-center"
              >
                {!state.isFlipped ? (
                  /* Front */
                  <>
                    <FuriganaText
                      word={currentCard.word}
                      reading={currentCard.reading}
                      className="text-5xl md:text-6xl font-bold mb-4 leading-tight"
                      readingClassName="text-sm font-normal text-muted-foreground"
                    />
                    <p className="text-sm text-muted-foreground mt-2">Nhấp để xem nghĩa</p>
                  </>
                ) : (
                  /* Back */
                  <>
                    <div className="flex items-center gap-2 mb-2">
                      <FuriganaText
                        word={currentCard.word}
                        reading={currentCard.reading}
                        className="text-2xl font-bold"
                      />
                      <Button
                        size="icon"
                        variant="ghost"
                        onClick={(e) => { e.stopPropagation(); speak(currentCard.word) }}
                      >
                        <Volume2 className="h-4 w-4" />
                      </Button>
                    </div>
                    {currentCard.romanization && (
                      <p className="text-sm text-muted-foreground mb-3">{currentCard.romanization}</p>
                    )}
                    <p className="text-2xl font-semibold mb-2">{currentCard.meaning_vi}</p>
                    {currentCard.meaning_en && (
                      <p className="text-sm text-muted-foreground mb-3">{currentCard.meaning_en}</p>
                    )}
                    <div className="flex gap-2 mt-2">
                      <JLPTBadge level={currentCard.jlpt_level} />
                      {currentCard.part_of_speech && (
                        <span className="text-xs bg-muted px-2 py-0.5 rounded text-muted-foreground">
                          {currentCard.part_of_speech}
                        </span>
                      )}
                    </div>
                  </>
                )}
              </motion.div>
            </AnimatePresence>
          </div>

          {/* Next */}
          <button
            onClick={() => dispatch({ type: 'NEXT' })}
            className="shrink-0 rounded-full p-3 border bg-background hover:bg-muted transition-colors"
            aria-label="Thẻ tiếp theo"
          >
            <ChevronRight className="h-5 w-5" />
          </button>

        </div>
      </div>

      {/* Keyboard hint */}
      <div className="py-4 text-center">
        <p className="text-xs text-muted-foreground">Space: lật · ← trước · → tiếp</p>
      </div>
    </div>
  )
}

function StudyResult({
  state,
  onRestart,
  backHref,
}: {
  state: StudyState
  onRestart: () => void
  backHref: string
}) {
  return (
    <div className="flex items-center justify-center min-h-[calc(100vh-3.5rem)]">
      <div className="text-center max-w-md px-4">
        <div className="text-6xl mb-4">🎉</div>
        <h2 className="text-2xl font-bold mb-2">Xong rồi!</h2>
        <p className="text-muted-foreground mb-8">
          Bạn đã xem qua {state.cards.length} từ.
        </p>

        <div className="flex gap-3">
          <Button onClick={onRestart} className="flex-1">
            <RotateCcw className="h-4 w-4 mr-2" />
            Học lại
          </Button>
          <Button asChild variant="outline" className="flex-1">
            <Link href={backHref}>
              <Home className="h-4 w-4 mr-2" />
              Về chủ đề
            </Link>
          </Button>
        </div>
      </div>
    </div>
  )
}
