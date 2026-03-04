'use client'

import { useState, useCallback } from 'react'
import { Button } from '@/components/ui/button'
import { Progress } from '@/components/ui/progress'
import { Badge } from '@/components/ui/badge'
import { Separator } from '@/components/ui/separator'
import { cn } from '@/lib/utils'
import type { WritingPrompt, GradingResult, GradingError } from '@/types/database'
import { RefreshCw, Send, CheckCircle, XCircle, AlertCircle, ChevronDown, ChevronUp } from 'lucide-react'

interface Props {
  initialPrompt: WritingPrompt
}

type Phase = 'writing' | 'submitting' | 'result'

function ScoreBar({
  label,
  score,
  max,
  color,
}: {
  label: string
  score: number
  max: number
  color: string
}) {
  return (
    <div className="space-y-1">
      <div className="flex justify-between text-sm">
        <span className="text-muted-foreground">{label}</span>
        <span className="font-semibold">
          {score}/{max}
        </span>
      </div>
      <Progress value={(score / max) * 100} className={cn('h-2', color)} />
    </div>
  )
}

function ErrorCard({ err }: { err: GradingError }) {
  return (
    <div className="rounded-lg border border-destructive/30 bg-destructive/5 p-3 text-sm space-y-1">
      <div className="flex gap-2">
        <span className="line-through text-muted-foreground">{err.original}</span>
        <span className="text-green-600 font-medium">→ {err.corrected}</span>
      </div>
      <p className="text-muted-foreground">{err.explanation_vi}</p>
    </div>
  )
}

export function WritingTestClient({ initialPrompt }: Props) {
  const [prompt, setPrompt] = useState<WritingPrompt>(initialPrompt)
  const [response, setResponse] = useState('')
  const [phase, setPhase] = useState<Phase>('writing')
  const [result, setResult] = useState<GradingResult | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [showErrors, setShowErrors] = useState(false)
  const [loadingNewPrompt, setLoadingNewPrompt] = useState(false)

  const wordCount = response.trim() ? response.trim().split(/\s+/).length : 0
  const isUnderMin = wordCount < prompt.min_words

  const handleSubmit = useCallback(async () => {
    if (!response.trim()) return
    setPhase('submitting')
    setError(null)

    // session_id đơn giản dùng localStorage
    let sessionId = sessionStorage.getItem('writing_session_id')
    if (!sessionId) {
      sessionId = crypto.randomUUID()
      sessionStorage.setItem('writing_session_id', sessionId)
    }

    try {
      const res = await fetch('/api/writing-submissions', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          prompt_id: prompt.id,
          prompt_vi: prompt.prompt_vi,
          min_words: prompt.min_words,
          session_id: sessionId,
          response: response.trim(),
        }),
      })

      const data = await res.json()
      if (!res.ok) throw new Error(data.error ?? 'Lỗi không xác định')

      setResult(data as GradingResult)
      setPhase('result')
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Có lỗi xảy ra')
      setPhase('writing')
    }
  }, [prompt.id, response])

  const handleNewPrompt = useCallback(async () => {
    setLoadingNewPrompt(true)
    try {
      const res = await fetch('/api/writing-prompts/random')
      const data = await res.json()
      setPrompt(data as WritingPrompt)
      setResponse('')
      setResult(null)
      setPhase('writing')
      setError(null)
    } catch {
      // keep current prompt
    } finally {
      setLoadingNewPrompt(false)
    }
  }, [])

  const handleRetry = useCallback(() => {
    setResponse('')
    setResult(null)
    setPhase('writing')
    setError(null)
  }, [])

  const scoreColor =
    (result?.score ?? 0) >= 70
      ? 'text-green-600'
      : (result?.score ?? 0) >= 50
        ? 'text-yellow-600'
        : 'text-red-500'

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      {/* Prompt card */}
      <div className="rounded-xl border bg-card p-5 space-y-3">
        <div className="flex items-start justify-between gap-3">
          <div className="space-y-1 flex-1">
            <div className="flex items-center gap-2 flex-wrap">
              <h2 className="font-bold text-lg">{prompt.title}</h2>
              {prompt.jlpt_level && (
                <Badge variant="secondary">{prompt.jlpt_level}</Badge>
              )}
              <Badge variant="outline" className="capitalize">
                {{
                  self: 'Bản thân',
                  family: 'Gia đình',
                  hobby: 'Sở thích',
                  general: 'Tổng hợp',
                }[prompt.category] ?? prompt.category}
              </Badge>
            </div>
            <p className="text-muted-foreground">{prompt.prompt_vi}</p>
            {prompt.prompt_ja && (
              <p className="text-sm text-muted-foreground font-japanese">{prompt.prompt_ja}</p>
            )}
          </div>
          <Button
            variant="ghost"
            size="icon"
            onClick={handleNewPrompt}
            disabled={loadingNewPrompt || phase === 'submitting'}
            title="Đổi đề khác"
          >
            <RefreshCw className={cn('h-4 w-4', loadingNewPrompt && 'animate-spin')} />
          </Button>
        </div>
        <p className="text-xs text-muted-foreground">
          Viết tối thiểu <strong>{prompt.min_words}</strong> từ bằng <strong>tiếng Nhật</strong>
        </p>
      </div>

      {/* Writing area — ẩn khi có kết quả */}
      {phase !== 'result' && (
        <div className="space-y-3">
          <textarea
            className={cn(
              'w-full min-h-[220px] rounded-xl border bg-background p-4 text-base resize-y',
              'placeholder:text-muted-foreground/50 focus:outline-none focus:ring-2 focus:ring-ring',
              'font-japanese leading-relaxed',
              phase === 'submitting' && 'opacity-60 pointer-events-none',
            )}
            placeholder="私は..."
            value={response}
            onChange={(e) => setResponse(e.target.value)}
            disabled={phase === 'submitting'}
            lang="ja"
          />
          <div className="flex items-center justify-between">
            <span
              className={cn(
                'text-sm',
                isUnderMin ? 'text-muted-foreground' : 'text-green-600 font-medium',
              )}
            >
              {wordCount} / {prompt.min_words} từ
              {!isUnderMin && ' ✓'}
            </span>
            <Button
              onClick={handleSubmit}
              disabled={!response.trim() || phase === 'submitting'}
              className="gap-2"
            >
              {phase === 'submitting' ? (
                <>
                  <RefreshCw className="h-4 w-4 animate-spin" />
                  Đang chấm bài...
                </>
              ) : (
                <>
                  <Send className="h-4 w-4" />
                  Nộp bài
                </>
              )}
            </Button>
          </div>

          {error && (
            <div className="flex items-center gap-2 text-sm text-destructive rounded-lg border border-destructive/30 bg-destructive/5 p-3">
              <AlertCircle className="h-4 w-4 shrink-0" />
              {error}
            </div>
          )}
        </div>
      )}

      {/* Result */}
      {phase === 'result' && result && (
        <div className="rounded-xl border bg-card p-5 space-y-5">
          {/* Valid lang check */}
          {!result.is_valid_lang ? (
            <div className="flex items-center gap-3 p-4 rounded-lg bg-destructive/10 border border-destructive/30">
              <XCircle className="h-6 w-6 text-destructive shrink-0" />
              <div>
                <p className="font-semibold text-destructive">Bài viết không hợp lệ</p>
                <p className="text-sm text-muted-foreground mt-0.5">{result.feedback_vi}</p>
              </div>
            </div>
          ) : (
            <>
              {/* Score circle */}
              <div className="flex items-center gap-5">
                <div className="flex-shrink-0 w-20 h-20 rounded-full border-4 border-primary/20 flex flex-col items-center justify-center">
                  <span className={cn('text-2xl font-bold', scoreColor)}>{result.score}</span>
                  <span className="text-xs text-muted-foreground">/ 100</span>
                </div>
                <div className="flex-1 space-y-3">
                  <ScoreBar label="Ngữ pháp" score={result.score_grammar} max={40} color="[&>div]:bg-blue-500" />
                  <ScoreBar label="Từ vựng" score={result.score_vocab} max={30} color="[&>div]:bg-purple-500" />
                  <ScoreBar label="Nội dung" score={result.score_content} max={30} color="[&>div]:bg-orange-500" />
                </div>
              </div>

              <Separator />

              {/* Feedback */}
              <div className="flex gap-3">
                <CheckCircle className="h-5 w-5 text-green-500 shrink-0 mt-0.5" />
                <p className="text-sm leading-relaxed">{result.feedback_vi}</p>
              </div>

              {/* Errors */}
              {result.errors.length > 0 && (
                <div className="space-y-2">
                  <button
                    onClick={() => setShowErrors((v) => !v)}
                    className="flex items-center gap-1.5 text-sm font-medium text-muted-foreground hover:text-foreground transition-colors"
                  >
                    {showErrors ? (
                      <ChevronUp className="h-4 w-4" />
                    ) : (
                      <ChevronDown className="h-4 w-4" />
                    )}
                    Xem {result.errors.length} lỗi cần sửa
                  </button>
                  {showErrors && (
                    <div className="space-y-2">
                      {result.errors.map((err, i) => (
                        <ErrorCard key={i} err={err} />
                      ))}
                    </div>
                  )}
                </div>
              )}
            </>
          )}

          <Separator />

          {/* Bài viết gốc */}
          <details className="group">
            <summary className="cursor-pointer text-sm text-muted-foreground hover:text-foreground select-none">
              Xem lại bài viết của bạn
            </summary>
            <div className="mt-2 rounded-lg bg-muted/50 p-3 text-sm font-japanese leading-relaxed whitespace-pre-wrap">
              {response}
            </div>
          </details>

          {/* Actions */}
          <div className="flex gap-3">
            <Button onClick={handleRetry} variant="outline" className="flex-1">
              Viết lại bài này
            </Button>
            <Button onClick={handleNewPrompt} className="flex-1 gap-2" disabled={loadingNewPrompt}>
              <RefreshCw className={cn('h-4 w-4', loadingNewPrompt && 'animate-spin')} />
              Đề mới
            </Button>
          </div>
        </div>
      )}
    </div>
  )
}
