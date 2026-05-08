'use client'

import { useState, useRef, useCallback, useEffect } from 'react'
import { Button } from '@/components/ui/button'
import { Progress } from '@/components/ui/progress'
import { Badge } from '@/components/ui/badge'
import { cn } from '@/lib/utils'
import { DrawingCanvas, type DrawingCanvasHandle } from './DrawingCanvas'
import type { AlphabetCharacter } from '@/types/database'
import { CheckCircle, XCircle, RefreshCw, ArrowRight, Eraser, PenLine, RotateCcw } from 'lucide-react'

// ─── scoring ─────────────────────────────────────────────────────────────────

function dilate(mask: Uint8Array, w: number, h: number, r: number): Uint8Array {
  const out = new Uint8Array(w * h)
  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++) {
      if (!mask[y * w + x]) continue
      for (let dy = -r; dy <= r; dy++) {
        for (let dx = -r; dx <= r; dx++) {
          const nx = x + dx, ny = y + dy
          if (nx >= 0 && nx < w && ny >= 0 && ny < h) out[ny * w + nx] = 1
        }
      }
    }
  }
  return out
}

// Crop the drawn strokes to their bounding box, then center & scale into SxS
// This makes comparison position-independent — drawing in any corner still scores correctly
function normalizeToBoundingBox(src: HTMLCanvasElement, S: number): HTMLCanvasElement | null {
  const ctx = src.getContext('2d')!
  const { data, width, height } = ctx.getImageData(0, 0, src.width, src.height)

  let minX = width, maxX = 0, minY = height, maxY = 0
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      if (data[(y * width + x) * 4] < 100) {
        if (x < minX) minX = x
        if (x > maxX) maxX = x
        if (y < minY) minY = y
        if (y > maxY) maxY = y
      }
    }
  }
  if (minX > maxX || minY > maxY) return null // empty canvas

  const bw = maxX - minX + 1
  const bh = maxY - minY + 1
  const pad = Math.round(S * 0.12)
  const inner = S - pad * 2

  const out = document.createElement('canvas')
  out.width = S; out.height = S
  const outCtx = out.getContext('2d')!
  outCtx.fillStyle = '#fff'
  outCtx.fillRect(0, 0, S, S)
  outCtx.drawImage(src, minX, minY, bw, bh, pad, pad, inner, inner)
  return out
}

function scoreDrawing(userCanvas: HTMLCanvasElement, char: string): number {
  const S = 160
  const RADIUS = 6

  // Reference: render the correct character, normalized
  const ref = document.createElement('canvas')
  ref.width = S; ref.height = S
  const rCtx = ref.getContext('2d')!
  rCtx.fillStyle = '#fff'
  rCtx.fillRect(0, 0, S, S)
  rCtx.fillStyle = '#000'
  rCtx.font = `${Math.round(S * 0.72)}px "Noto Sans JP", serif`
  rCtx.textAlign = 'center'
  rCtx.textBaseline = 'middle'
  rCtx.fillText(char, S / 2, S / 2)

  // User drawing: normalize to bounding box first (position-independent)
  const normalized = normalizeToBoundingBox(userCanvas, S)
  if (!normalized) return 0

  const refPx = rCtx.getImageData(0, 0, S, S).data
  const usrPx = normalized.getContext('2d')!.getImageData(0, 0, S, S).data

  const N = S * S
  const refMask = new Uint8Array(N)
  const usrMask = new Uint8Array(N)
  for (let i = 0; i < N; i++) {
    refMask[i] = refPx[i * 4] < 100 ? 1 : 0
    usrMask[i] = usrPx[i * 4] < 100 ? 1 : 0
  }

  const dilRef = dilate(refMask, S, S, RADIUS)

  let refTotal = 0, usrTotal = 0, tp = 0
  for (let i = 0; i < N; i++) {
    if (refMask[i]) refTotal++
    if (usrMask[i]) usrTotal++
    if (dilRef[i] && usrMask[i]) tp++
  }

  if (!refTotal || !usrTotal) return 0
  const precision = tp / usrTotal
  const recall = tp / refTotal
  if (precision + recall === 0) return 0
  return Math.round((2 * precision * recall / (precision + recall)) * 100)
}

// ─── types ────────────────────────────────────────────────────────────────────

type Script = 'hiragana' | 'katakana' | 'both'
type Mode = 'type' | 'draw'
type Phase = 'setup' | 'practicing' | 'summary'

interface Result {
  char: AlphabetCharacter
  correct?: boolean   // type mode
  score?: number      // draw mode
}

function shuffle<T>(arr: T[]): T[] {
  const a = [...arr]
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]]
  }
  return a
}

// ─── main component ────────────────────────────────────────────────────────────

export function PracticeClient({ characters }: { characters: AlphabetCharacter[] }) {
  const [phase, setPhase] = useState<Phase>('setup')
  const [script, setScript] = useState<Script>('hiragana')
  const [mode, setMode] = useState<Mode>('type')

  const [queue, setQueue] = useState<AlphabetCharacter[]>([])
  const [index, setIndex] = useState(0)
  const [results, setResults] = useState<Result[]>([])

  // type mode state
  const [input, setInput] = useState('')
  const [checked, setChecked] = useState(false)
  const [isCorrect, setIsCorrect] = useState(false)
  const inputRef = useRef<HTMLInputElement>(null)

  // draw mode state
  const canvasRef = useRef<DrawingCanvasHandle>(null)
  const [drawScore, setDrawScore] = useState<number | null>(null)
  const [canvasEmpty, setCanvasEmpty] = useState(true)

  const current = queue[index]

  function start() {
    const filtered = characters.filter((c) =>
      script === 'both' ? true : c.script === script,
    )
    const shuffled = shuffle(filtered)
    setQueue(shuffled)
    setIndex(0)
    setResults([])
    setInput('')
    setChecked(false)
    setDrawScore(null)
    setPhase('practicing')
  }

  // auto-focus input in type mode
  useEffect(() => {
    if (phase === 'practicing' && mode === 'type' && !checked) {
      setTimeout(() => inputRef.current?.focus(), 50)
    }
  }, [phase, mode, checked, index])

  const checkType = useCallback(() => {
    if (!current || !input.trim()) return
    const correct = input.trim().toLowerCase() === current.romanization.toLowerCase()
    setIsCorrect(correct)
    setChecked(true)
    setResults((r) => [...r, { char: current, correct }])
  }, [current, input])

  const submitDraw = useCallback(() => {
    const canvas = canvasRef.current?.getCanvas()
    if (!canvas || canvasRef.current?.isEmpty()) return
    const score = scoreDrawing(canvas, current.character)
    setDrawScore(score)
    setResults((r) => [...r, { char: current, score }])
  }, [current])

  function next() {
    const nextIndex = index + 1
    if (nextIndex >= queue.length) {
      setPhase('summary')
      return
    }
    setIndex(nextIndex)
    setInput('')
    setChecked(false)
    setIsCorrect(false)
    setDrawScore(null)
    setCanvasEmpty(true)
    canvasRef.current?.clear()
  }

  function restart() {
    setPhase('setup')
    setResults([])
  }

  // ── SETUP ──────────────────────────────────────────────────────────────────

  if (phase === 'setup') {
    return (
      <div className="max-w-lg mx-auto space-y-8">
        {/* Script */}
        <div className="space-y-3">
          <p className="text-sm font-semibold text-muted-foreground uppercase tracking-wide">Bộ ký tự</p>
          <div className="grid grid-cols-3 gap-3">
            {([
              ['hiragana', 'あ', 'Hiragana'],
              ['katakana', 'ア', 'Katakana'],
              ['both', '両', 'Cả hai'],
            ] as const).map(([val, icon, label]) => (
              <button
                key={val}
                onClick={() => setScript(val)}
                className={cn(
                  'flex flex-col items-center gap-1 rounded-xl border-2 py-4 font-medium transition-colors',
                  script === val
                    ? 'border-primary bg-primary/10 text-primary'
                    : 'border-border hover:border-primary/50',
                )}
              >
                <span className="text-2xl font-japanese">{icon}</span>
                <span className="text-sm">{label}</span>
              </button>
            ))}
          </div>
        </div>

        {/* Mode */}
        <div className="space-y-3">
          <p className="text-sm font-semibold text-muted-foreground uppercase tracking-wide">Chế độ luyện tập</p>
          <div className="grid grid-cols-2 gap-3">
            <button
              onClick={() => setMode('type')}
              className={cn(
                'flex flex-col items-start gap-2 rounded-xl border-2 p-4 text-left transition-colors',
                mode === 'type'
                  ? 'border-primary bg-primary/10'
                  : 'border-border hover:border-primary/50',
              )}
            >
              <span className="text-xl">⌨️</span>
              <span className="font-semibold text-sm">Nhìn chữ → gõ romaji</span>
              <span className="text-xs text-muted-foreground">Thấy あ → gõ "a"</span>
            </button>
            <button
              onClick={() => setMode('draw')}
              className={cn(
                'flex flex-col items-start gap-2 rounded-xl border-2 p-4 text-left transition-colors',
                mode === 'draw'
                  ? 'border-primary bg-primary/10'
                  : 'border-border hover:border-primary/50',
              )}
            >
              <span className="text-xl">✏️</span>
              <span className="font-semibold text-sm">Nhìn romaji → vẽ chữ</span>
              <span className="text-xs text-muted-foreground">Thấy "a" → vẽ あ</span>
            </button>
          </div>
        </div>

        <Button onClick={start} className="w-full" size="lg">
          Bắt đầu luyện tập
        </Button>
      </div>
    )
  }

  // ── SUMMARY ────────────────────────────────────────────────────────────────

  if (phase === 'summary') {
    const typeResults = results.filter((r) => r.correct !== undefined)
    const drawResults = results.filter((r) => r.score !== undefined)
    const correctCount = typeResults.filter((r) => r.correct).length
    const avgScore = drawResults.length
      ? Math.round(drawResults.reduce((s, r) => s + (r.score ?? 0), 0) / drawResults.length)
      : null

    const wrongChars = typeResults.filter((r) => !r.correct)
    const lowScoreChars = drawResults.filter((r) => (r.score ?? 0) < 60)

    return (
      <div className="max-w-md mx-auto space-y-6 text-center">
        <div className="rounded-2xl border bg-card p-8 space-y-4">
          <div className="text-5xl">🎉</div>
          <h2 className="text-2xl font-bold">Hoàn thành!</h2>

          {mode === 'type' && (
            <div className="space-y-1">
              <p className="text-4xl font-bold text-primary">{correctCount}<span className="text-2xl text-muted-foreground">/{results.length}</span></p>
              <p className="text-muted-foreground">câu trả lời đúng</p>
            </div>
          )}
          {mode === 'draw' && avgScore !== null && (
            <div className="space-y-1">
              <p className={cn(
                'text-4xl font-bold',
                avgScore >= 70 ? 'text-green-600' : avgScore >= 45 ? 'text-yellow-600' : 'text-red-500',
              )}>{avgScore}%</p>
              <p className="text-muted-foreground">điểm trung bình</p>
            </div>
          )}

          {(wrongChars.length > 0 || lowScoreChars.length > 0) && (
            <div className="text-left space-y-2">
              <p className="text-sm font-semibold text-muted-foreground">Cần ôn lại:</p>
              <div className="flex flex-wrap gap-2">
                {[...wrongChars, ...lowScoreChars].map((r, i) => (
                  <span key={i} className="text-2xl font-japanese border rounded-lg px-2 py-1 bg-muted">
                    {r.char.character}
                    <span className="text-xs text-muted-foreground ml-1">{r.char.romanization}</span>
                  </span>
                ))}
              </div>
            </div>
          )}
        </div>

        <div className="flex gap-3">
          <Button variant="outline" onClick={start} className="flex-1 gap-2">
            <RefreshCw className="h-4 w-4" /> Luyện lại
          </Button>
          <Button variant="outline" onClick={restart} className="flex-1 gap-2">
            <RotateCcw className="h-4 w-4" /> Cài đặt lại
          </Button>
        </div>
      </div>
    )
  }

  // ── PRACTICING ─────────────────────────────────────────────────────────────

  if (!current) return null

  const progress = ((index) / queue.length) * 100
  const scriptBadge = current.script === 'hiragana' ? 'Hiragana' : 'Katakana'

  return (
    <div className="max-w-md mx-auto space-y-6">
      {/* Progress */}
      <div className="space-y-2">
        <div className="flex justify-between text-sm text-muted-foreground">
          <span>{index + 1} / {queue.length}</span>
          <Badge variant="secondary">{scriptBadge}</Badge>
        </div>
        <Progress value={progress} className="h-2" />
      </div>

      {/* Card */}
      <div className="rounded-2xl border bg-card p-8 flex flex-col items-center gap-6">

        {/* TYPE MODE */}
        {mode === 'type' && (
          <>
            <p className="text-muted-foreground text-sm">Ký tự này đọc là gì?</p>
            <span className="text-8xl font-japanese leading-none">{current.character}</span>

            {!checked ? (
              <div className="w-full space-y-3">
                <input
                  ref={inputRef}
                  type="text"
                  value={input}
                  onChange={(e) => setInput(e.target.value)}
                  onKeyDown={(e) => { if (e.key === 'Enter') checkType() }}
                  placeholder="Gõ romaji... (vd: a, ka, shi)"
                  className="w-full rounded-xl border bg-background px-4 py-3 text-center text-lg focus:outline-none focus:ring-2 focus:ring-ring"
                  autoComplete="off"
                  autoCapitalize="none"
                />
                <Button onClick={checkType} disabled={!input.trim()} className="w-full">
                  Kiểm tra
                </Button>
              </div>
            ) : (
              <div className="w-full space-y-4">
                <div className={cn(
                  'flex items-center gap-3 rounded-xl p-4',
                  isCorrect ? 'bg-green-50 border border-green-200' : 'bg-red-50 border border-red-200',
                )}>
                  {isCorrect
                    ? <CheckCircle className="h-5 w-5 text-green-600 shrink-0" />
                    : <XCircle className="h-5 w-5 text-red-500 shrink-0" />}
                  <div>
                    {isCorrect
                      ? <p className="font-semibold text-green-700">Đúng rồi!</p>
                      : <p className="font-semibold text-red-600">Chưa đúng — đáp án: <strong>{current.romanization}</strong></p>}
                  </div>
                </div>
                <Button onClick={next} className="w-full gap-2">
                  {index + 1 < queue.length ? <><ArrowRight className="h-4 w-4" /> Tiếp theo</> : 'Xem kết quả'}
                </Button>
              </div>
            )}
          </>
        )}

        {/* DRAW MODE */}
        {mode === 'draw' && (
          <>
            <p className="text-muted-foreground text-sm">Vẽ ký tự có âm đọc sau:</p>
            <div className="text-center space-y-1">
              <span className="text-5xl font-bold tracking-widest">{current.romanization}</span>
              <p className="text-xs text-muted-foreground">{scriptBadge}</p>
            </div>

            <div className="relative">
              <DrawingCanvas ref={canvasRef} size={280} onDraw={() => setCanvasEmpty(false)} />
              {/* Reference overlay after submit */}
              {drawScore !== null && (
                <div className="absolute inset-0 flex items-center justify-center pointer-events-none rounded-2xl overflow-hidden">
                  <span
                    className="font-japanese text-primary/30"
                    style={{ fontSize: '210px', lineHeight: 1, fontFamily: '"Noto Sans JP", serif' }}
                  >
                    {current.character}
                  </span>
                </div>
              )}
            </div>

            {drawScore === null ? (
              <div className="flex gap-3 w-full">
                <Button
                  variant="outline"
                  onClick={() => { canvasRef.current?.clear(); setCanvasEmpty(true) }}
                  className="flex-1 gap-2"
                >
                  <Eraser className="h-4 w-4" /> Xóa
                </Button>
                <Button
                  onClick={submitDraw}
                  disabled={canvasEmpty}
                  className="flex-1 gap-2"
                >
                  <PenLine className="h-4 w-4" /> Nộp bài
                </Button>
              </div>
            ) : (
              <div className="w-full space-y-4">
                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span className="text-muted-foreground">Độ chính xác</span>
                    <span className={cn(
                      'font-bold',
                      drawScore >= 70 ? 'text-green-600' : drawScore >= 45 ? 'text-yellow-600' : 'text-red-500',
                    )}>{drawScore}%</span>
                  </div>
                  <Progress
                    value={drawScore}
                    className={cn(
                      'h-3',
                      drawScore >= 70 ? '[&>div]:bg-green-500'
                        : drawScore >= 45 ? '[&>div]:bg-yellow-500'
                        : '[&>div]:bg-red-500',
                    )}
                  />
                  <p className="text-xs text-muted-foreground text-center">
                    Ký tự đúng: <span className="font-japanese text-base font-bold">{current.character}</span>
                    {' '}(ảnh mờ phía sau)
                  </p>
                </div>
                <Button onClick={next} className="w-full gap-2">
                  {index + 1 < queue.length ? <><ArrowRight className="h-4 w-4" /> Tiếp theo</> : 'Xem kết quả'}
                </Button>
              </div>
            )}
          </>
        )}
      </div>
    </div>
  )
}
