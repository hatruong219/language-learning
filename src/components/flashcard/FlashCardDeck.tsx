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
import { X, RotateCcw, CheckCircle, MinusCircle, XCircle, Volume2, Home } from 'lucide-react'
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
  const done = state.results.correct.length + state.results.review.length + state.results.wrong.length

  // Keyboard shortcuts
  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if (state.phase === 'complete') return
      if (e.code === 'Space') { e.preventDefault(); dispatch({ type: 'FLIP' }) }
      if (state.isFlipped) {
        if (e.code === 'ArrowLeft') dispatch({ type: 'MARK', result: 'wrong' })
        if (e.code === 'ArrowRight') dispatch({ type: 'MARK', result: 'correct' })
        if (e.code === 'ArrowDown') dispatch({ type: 'MARK', result: 'review' })
      }
    }
    window.addEventListener('keydown', handler)
    return () => window.removeEventListener('keydown', handler)
  }, [state.phase, state.isFlipped])

  // Auto-play TTS when card flips
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
          {done + 1} / {state.cards.length}
        </div>
        <div className="w-5" />
      </div>

      {/* Progress */}
      <Progress value={progress} className="h-1 rounded-none" />

      {/* Card area */}
      <div className="flex-1 flex items-center justify-center p-4">
        <div
          className="w-full max-w-lg cursor-pointer select-none"
          onClick={() => !state.isFlipped && dispatch({ type: 'FLIP' })}
        >
          <AnimatePresence mode="wait">
            <motion.div
              key={currentCard.id + (state.isFlipped ? '-back' : '-front')}
              initial={{ rotateY: state.isFlipped ? -90 : 90, opacity: 0 }}
              animate={{ rotateY: 0, opacity: 1 }}
              exit={{ rotateY: state.isFlipped ? 90 : -90, opacity: 0 }}
              transition={{ duration: 0.25, ease: 'easeOut' }}
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
                  <p className="text-sm text-muted-foreground mt-2">Nhấp để lật thẻ</p>
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
      </div>

      {/* Action buttons */}
      <div className="px-4 py-6 border-t">
        {!state.isFlipped ? (
          <Button
            className="w-full"
            size="lg"
            onClick={() => dispatch({ type: 'FLIP' })}
          >
            Lật thẻ
          </Button>
        ) : (
          <div className="flex gap-3 max-w-lg mx-auto">
            <Button
              variant="outline"
              className="flex-1 border-red-300 text-red-600 hover:bg-red-50 hover:text-red-700 dark:border-red-800 dark:text-red-400"
              onClick={() => dispatch({ type: 'MARK', result: 'wrong' })}
            >
              <XCircle className="h-4 w-4 mr-1" />
              <span className="hidden sm:inline">Chưa thuộc</span>
              <span className="sm:hidden">←</span>
            </Button>
            <Button
              variant="outline"
              className="flex-1 border-yellow-300 text-yellow-600 hover:bg-yellow-50 dark:border-yellow-800 dark:text-yellow-400"
              onClick={() => dispatch({ type: 'MARK', result: 'review' })}
            >
              <MinusCircle className="h-4 w-4 mr-1" />
              <span className="hidden sm:inline">Xem lại</span>
              <span className="sm:hidden">↓</span>
            </Button>
            <Button
              variant="outline"
              className="flex-1 border-green-300 text-green-600 hover:bg-green-50 dark:border-green-800 dark:text-green-400"
              onClick={() => dispatch({ type: 'MARK', result: 'correct' })}
            >
              <CheckCircle className="h-4 w-4 mr-1" />
              <span className="hidden sm:inline">Đã thuộc</span>
              <span className="sm:hidden">→</span>
            </Button>
          </div>
        )}
        <p className="text-center text-xs text-muted-foreground mt-2">
          {state.isFlipped
            ? 'Space: lật · ← Chưa thuộc · ↓ Xem lại · → Đã thuộc'
            : 'Space hoặc nhấp vào thẻ để lật'}
        </p>
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
  const total = state.cards.length
  const correctPct = Math.round((state.results.correct.length / total) * 100)

  return (
    <div className="flex items-center justify-center min-h-[calc(100vh-3.5rem)]">
      <div className="text-center max-w-md px-4">
        <div className="text-6xl mb-4">
          {correctPct >= 80 ? '🎉' : correctPct >= 50 ? '💪' : '📚'}
        </div>
        <h2 className="text-2xl font-bold mb-2">Hoàn thành!</h2>
        <p className="text-muted-foreground mb-8">
          Bạn đã học xong {total} từ.
        </p>

        {/* Results */}
        <div className="grid grid-cols-3 gap-4 mb-8">
          <div className="p-4 rounded-xl border bg-green-50 dark:bg-green-900/20">
            <div className="text-2xl font-bold text-green-600">{state.results.correct.length}</div>
            <div className="text-xs text-muted-foreground">Đã thuộc</div>
          </div>
          <div className="p-4 rounded-xl border bg-yellow-50 dark:bg-yellow-900/20">
            <div className="text-2xl font-bold text-yellow-600">{state.results.review.length}</div>
            <div className="text-xs text-muted-foreground">Xem lại</div>
          </div>
          <div className="p-4 rounded-xl border bg-red-50 dark:bg-red-900/20">
            <div className="text-2xl font-bold text-red-600">{state.results.wrong.length}</div>
            <div className="text-xs text-muted-foreground">Chưa thuộc</div>
          </div>
        </div>

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
