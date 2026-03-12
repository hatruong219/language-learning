'use client'

import { useState, useRef, useCallback, useEffect } from 'react'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { DrawingCanvas, type DrawingCanvasRef } from './DrawingCanvas'
import { speak } from '@/lib/tts'
import { gradeCharacterWithOCR } from '@/lib/ocr'
import {
  Volume2,
  Send,
  ChevronRight,
  RotateCcw,
  Settings2,
  CheckCircle2,
  XCircle,
  RefreshCw,
  Shuffle,
  List,
} from 'lucide-react'
import { cn } from '@/lib/utils'
import type { AlphabetCharacter, CharacterGradingResult } from '@/types/database'

// ── Helpers ────────────────────────────────────────────────────────────────

function shuffleArray<T>(arr: T[]): T[] {
  const a = [...arr]
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
      ;[a[i], a[j]] = [a[j], a[i]]
  }
  return a
}

// ── Types ──────────────────────────────────────────────────────────────────

type ScriptMode = 'hiragana' | 'katakana'
type OrderMode = 'sequential' | 'random'
type Phase = 'settings' | 'writing' | 'submitting' | 'result'

interface Props {
  hiragana: AlphabetCharacter[]
  katakana: AlphabetCharacter[]
  open: boolean
  onClose: () => void
}

// ── Score color ────────────────────────────────────────────────────────────

function scoreColor(score: number) {
  if (score >= 80) return 'text-green-600'
  if (score >= 55) return 'text-yellow-600'
  return 'text-red-500'
}

// ── Main component ─────────────────────────────────────────────────────────

export function WritingPracticeDialog({ hiragana, katakana, open, onClose }: Props) {
  // Settings
  const [scriptMode, setScriptMode] = useState<ScriptMode>('hiragana')
  const [orderMode, setOrderMode] = useState<OrderMode>('sequential')

  // Practice state
  const [phase, setPhase] = useState<Phase>('settings')
  const [queue, setQueue] = useState<AlphabetCharacter[]>([])
  const [currentIndex, setCurrentIndex] = useState(0)
  const [result, setResult] = useState<CharacterGradingResult | null>(null)
  const [error, setError] = useState<string | null>(null)

  const canvasRef = useRef<DrawingCanvasRef>(null)

  const currentChar = queue[currentIndex] ?? null

  // ── Build queue ────────────────────────────────────────────────────────

  function buildQueue(script: ScriptMode, order: OrderMode) {
    const source = script === 'hiragana' ? hiragana : katakana
    const sorted = [...source].sort((a, b) => (a.order_index ?? 0) - (b.order_index ?? 0))
    return order === 'random' ? shuffleArray(sorted) : sorted
  }

  function handleStart() {
    const q = buildQueue(scriptMode, orderMode)
    setQueue(q)
    setCurrentIndex(0)
    setPhase('writing')
    setResult(null)
    setError(null)
    canvasRef.current?.clear()
  }

  // ── Submit ─────────────────────────────────────────────────────────────

  const handleSubmit = useCallback(async () => {
    if (!currentChar) return
    if (canvasRef.current?.isEmpty()) {
      setError('Hãy vẽ ký tự trước khi nộp bài!')
      return
    }

    const canvasEl = canvasRef.current?.getCanvasElement()
    if (!canvasEl) {
      setError('Không tìm thấy canvas.')
      return
    }

    setPhase('submitting')
    setError(null)

    try {
      const grading = await gradeCharacterWithOCR(
        currentChar.character,
        currentChar.romanization,
        canvasEl,
      )
      setResult(grading)
      setPhase('result')
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Có lỗi xảy ra')
      setPhase('writing')
    }
  }, [currentChar])

  // ── Next char ──────────────────────────────────────────────────────────

  function handleNext() {
    const next = currentIndex + 1
    if (next >= queue.length) {
      // Rebuild queue (re-shuffle if random)
      const q = buildQueue(scriptMode, orderMode)
      setQueue(q)
      setCurrentIndex(0)
    } else {
      setCurrentIndex(next)
    }
    setPhase('writing')
    setResult(null)
    setError(null)
    canvasRef.current?.clear()
  }

  function handleRetry() {
    setPhase('writing')
    setResult(null)
    setError(null)
    canvasRef.current?.clear()
  }

  function handleOpenSettings() {
    setPhase('settings')
    setResult(null)
    setError(null)
  }

  // ── TTS ────────────────────────────────────────────────────────────────

  useEffect(() => {
    if (phase === 'writing' && currentChar) {
      speak(currentChar.character)
    }
  }, [currentChar?.id, phase]) // eslint-disable-line react-hooks/exhaustive-deps

  // ── Close reset ────────────────────────────────────────────────────────

  function handleClose() {
    setPhase('settings')
    setResult(null)
    setError(null)
    onClose()
  }

  if (!open) return null

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4"
      onClick={(e) => e.target === e.currentTarget && handleClose()}
    >
      {/* Backdrop */}
      <div className="absolute inset-0 bg-black/50 backdrop-blur-sm" onClick={handleClose} />

      {/* Dialog */}
      <div className="relative z-10 w-full max-w-md rounded-3xl border border-border bg-card shadow-2xl overflow-hidden animate-in fade-in zoom-in-95 duration-200">

        {/* Header */}
        <div className="flex items-center justify-between px-6 pt-5 pb-4 border-b border-border/60">
          <div className="flex items-center gap-2">
            <span className="text-xl">✏️</span>
            <h2 className="font-bold text-lg">Luyện chữ</h2>
            {phase !== 'settings' && currentChar && (
              <Badge variant="secondary" className="capitalize">
                {currentChar.script === 'hiragana' ? 'Hiragana' : 'Katakana'}
              </Badge>
            )}
          </div>
          <div className="flex items-center gap-1">
            {phase !== 'settings' && (
              <Button variant="ghost" size="icon" onClick={handleOpenSettings} title="Cài đặt">
                <Settings2 className="h-4 w-4" />
              </Button>
            )}
            <Button variant="ghost" size="icon" onClick={handleClose}>
              <span className="text-lg leading-none">×</span>
            </Button>
          </div>
        </div>

        {/* ── SETTINGS PANEL ── */}
        {phase === 'settings' && (
          <div className="px-6 py-6 space-y-6">
            {/* Script selection */}
            <div className="space-y-2">
              <p className="text-sm font-semibold text-muted-foreground uppercase tracking-wide">Bảng chữ</p>
              <div className="grid grid-cols-2 gap-2">
                {(['hiragana', 'katakana'] as ScriptMode[]).map((s) => (
                  <button
                    key={s}
                    onClick={() => setScriptMode(s)}
                    className={cn(
                      'flex flex-col items-center gap-1.5 rounded-2xl border-2 py-4 transition-all duration-150',
                      scriptMode === s
                        ? 'border-primary bg-primary/8 text-primary'
                        : 'border-border bg-muted/40 text-muted-foreground hover:border-primary/40',
                    )}
                  >
                    <span className="text-3xl font-bold">{s === 'hiragana' ? 'あ' : 'ア'}</span>
                    <span className="text-xs font-medium capitalize">{s === 'hiragana' ? 'Hiragana' : 'Katakana'}</span>
                    <span className="text-[11px] text-muted-foreground">
                      ({s === 'hiragana' ? hiragana.length : katakana.length} chữ)
                    </span>
                  </button>
                ))}
              </div>
            </div>

            {/* Order mode */}
            <div className="space-y-2">
              <p className="text-sm font-semibold text-muted-foreground uppercase tracking-wide">Thứ tự luyện tập</p>
              <div className="grid grid-cols-2 gap-2">
                <button
                  onClick={() => setOrderMode('sequential')}
                  className={cn(
                    'flex items-center gap-2.5 rounded-xl border-2 px-4 py-3 text-sm font-medium transition-all duration-150',
                    orderMode === 'sequential'
                      ? 'border-primary bg-primary/8 text-primary'
                      : 'border-border bg-muted/40 text-muted-foreground hover:border-primary/40',
                  )}
                >
                  <List className="h-4 w-4 shrink-0" />
                  Tuần tự
                </button>
                <button
                  onClick={() => setOrderMode('random')}
                  className={cn(
                    'flex items-center gap-2.5 rounded-xl border-2 px-4 py-3 text-sm font-medium transition-all duration-150',
                    orderMode === 'random'
                      ? 'border-primary bg-primary/8 text-primary'
                      : 'border-border bg-muted/40 text-muted-foreground hover:border-primary/40',
                  )}
                >
                  <Shuffle className="h-4 w-4 shrink-0" />
                  Xáo trộn
                </button>
              </div>
            </div>

            <Button onClick={handleStart} className="w-full" size="lg">
              Bắt đầu luyện tập →
            </Button>
          </div>
        )}

        {/* ── PRACTICE / RESULT PANEL ── */}
        {phase !== 'settings' && currentChar && (
          <div className="px-6 py-5 space-y-4">
            {/* Character display — chỉ hiện phiên âm, ẩn ký tự */}
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-4">
                {/* Ô ký tự bị che — user phải tự nhớ */}
                <div className="flex flex-col items-center justify-center w-20 h-20 rounded-2xl bg-muted/40 border-2 border-dashed border-border select-none">
                  <span className="text-2xl text-muted-foreground/30">?</span>
                </div>
                <div className="space-y-0.5">
                  <p className="text-xs text-muted-foreground">Hãy viết chữ</p>
                  <p className="text-2xl font-bold tracking-widest">{currentChar.romanization.toUpperCase()}</p>
                  <p className="text-xs text-muted-foreground">
                    {currentIndex + 1} / {queue.length}
                  </p>
                </div>
              </div>
              <Button
                variant="ghost"
                size="icon"
                onClick={() => speak(currentChar.character)}
                title="Nghe phát âm"
                className="text-primary"
              >
                <Volume2 className="h-5 w-5" />
              </Button>
            </div>

            {/* Canvas — hidden when result shown */}
            {phase !== 'result' && (
              <DrawingCanvas
                ref={canvasRef}
                width={360}
                height={280}
              />
            )}

            {/* Placeholder khi đang hiện result (canvas đã unmount) */}
            {phase === 'result' && <div />}

            {/* Error */}
            {error && (
              <div className="flex items-center gap-2 text-sm text-destructive rounded-xl border border-destructive/30 bg-destructive/5 px-3 py-2">
                <XCircle className="h-4 w-4 shrink-0" />
                {error}
              </div>
            )}

            {/* Submit button */}
            {(phase === 'writing' || phase === 'submitting') && (
              <Button
                onClick={handleSubmit}
                disabled={phase === 'submitting'}
                className="w-full gap-2"
                size="lg"
              >
                {phase === 'submitting' ? (
                  <>
                    <RefreshCw className="h-4 w-4 animate-spin" />
                    Đang nhận dạng chữ viết...
                  </>
                ) : (
                  <>
                    <Send className="h-4 w-4" />
                    Nộp bài
                  </>
                )}
              </Button>
            )}

            {/* Result */}
            {phase === 'result' && result && (
              <div className="space-y-4">
                {/* Hiện ký tự đúng để so sánh */}
                <div className="flex items-center gap-3 p-3 rounded-2xl bg-muted/40 border border-border">
                  <div className="flex flex-col items-center justify-center w-16 h-16 rounded-xl bg-card border border-border shrink-0">
                    <span className="text-3xl font-bold leading-none">{currentChar.character}</span>
                    <span className="text-[10px] text-muted-foreground mt-1">{currentChar.romanization}</span>
                  </div>
                  <p className="text-sm text-muted-foreground">← Ký tự chuẩn để so sánh</p>
                </div>

                {/* Score */}
                <div className={cn(
                  'flex items-center gap-4 rounded-2xl border p-4',
                  result.is_correct
                    ? 'border-green-200 bg-green-50 dark:bg-green-900/10 dark:border-green-800'
                    : 'border-orange-200 bg-orange-50 dark:bg-orange-900/10 dark:border-orange-800',
                )}>
                  <div className={cn(
                    'flex flex-col items-center justify-center w-16 h-16 rounded-full border-4 shrink-0',
                    result.is_correct ? 'border-green-300' : 'border-orange-300',
                  )}>
                    <span className={cn('text-xl font-bold', scoreColor(result.score))}>
                      {result.score}
                    </span>
                    <span className="text-[10px] text-muted-foreground">/ 100</span>
                  </div>
                  <div className="flex-1 space-y-1">
                    <div className="flex items-center gap-1.5">
                      {result.is_correct ? (
                        <CheckCircle2 className="h-4 w-4 text-green-600" />
                      ) : (
                        <XCircle className="h-4 w-4 text-orange-500" />
                      )}
                      <span className={cn('font-semibold text-sm', result.is_correct ? 'text-green-700 dark:text-green-400' : 'text-orange-600 dark:text-orange-400')}>
                        {result.is_correct ? 'Chính xác!' : 'Cần luyện thêm'}
                      </span>
                    </div>
                    <p className="text-sm text-muted-foreground leading-snug">{result.feedback_vi}</p>
                  </div>
                </div>

                {/* OCR notes */}
                {result.stroke_notes.length > 0 && (
                  <div className="rounded-xl border border-border bg-muted/30 p-3 space-y-1.5">
                    <p className="text-xs font-semibold text-muted-foreground uppercase tracking-wide">
                      Chi tiết nhận dạng
                    </p>
                    {result.stroke_notes.map((note, i) => (
                      <div key={i} className="flex items-start gap-2 text-sm">
                        <span className="text-muted-foreground shrink-0">•</span>
                        <span>{note}</span>
                      </div>
                    ))}
                  </div>
                )}

                {/* Actions */}
                <div className="flex gap-2">
                  <Button onClick={handleRetry} variant="outline" className="flex-1 gap-1.5">
                    <RotateCcw className="h-3.5 w-3.5" />
                    Thử lại
                  </Button>
                  <Button onClick={handleNext} className="flex-1 gap-1.5">
                    Tiếp theo
                    <ChevronRight className="h-3.5 w-3.5" />
                  </Button>
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  )
}
