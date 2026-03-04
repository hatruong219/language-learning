'use client'

import { useState, FormEvent } from 'react'
import { Button } from '@/components/ui/button'

interface FeedbackFormProps {
  siteId: string
}

type SubmitState = 'idle' | 'submitting' | 'success' | 'error'

export function FeedbackForm({ siteId }: FeedbackFormProps) {
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [message, setMessage] = useState('')
  const [rating, setRating] = useState<number | null>(5)
  const [state, setState] = useState<SubmitState>('idle')
  const [error, setError] = useState<string | null>(null)

  async function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault()
    if (!name.trim() || !message.trim() || rating === null) {
      setError('Vui lòng nhập tên, nội dung và chọn điểm đánh giá.')
      return
    }

    setState('submitting')
    setError(null)

    try {
      const res = await fetch('/api/feedback', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          siteId,
          name: name.trim(),
          email: email.trim() || null,
          message: message.trim(),
          rating,
        }),
      })

      if (!res.ok) {
        const data = (await res.json().catch(() => null)) as { error?: string } | null
        setError(data?.error ?? 'Gửi phản hồi thất bại, vui lòng thử lại.')
        setState('error')
        return
      }

      setState('success')
      setName('')
      setEmail('')
      setMessage('')
      setRating(5)
    } catch {
      setError('Có lỗi xảy ra, vui lòng thử lại sau.')
      setState('error')
    }
  }

  return (
    <form
      onSubmit={handleSubmit}
      className="space-y-6 max-w-lg mx-auto bg-card border rounded-2xl p-6 shadow-sm"
    >
      <div className="space-y-1">
        <label htmlFor="name" className="text-sm font-medium">
          Tên của bạn *
        </label>
        <input
          id="name"
          type="text"
          value={name}
          onChange={(e) => setName(e.target.value)}
          className="w-full px-3 py-2 rounded-xl border bg-background text-sm outline-none transition-colors focus:ring-2 focus:ring-primary/30 border-border focus:border-primary"
          placeholder="Ví dụ: Nguyễn Văn A"
        />
      </div>

      <div className="space-y-1">
        <label htmlFor="email" className="text-sm font-medium">
          Email (tuỳ chọn)
        </label>
        <input
          id="email"
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          className="w-full px-3 py-2 rounded-xl border bg-background text-sm outline-none transition-colors focus:ring-2 focus:ring-primary/30 border-border focus:border-primary"
          placeholder="Để mình có thể liên hệ lại nếu cần"
        />
      </div>

      <div className="space-y-2">
        <p className="text-sm font-medium">Đánh giá trải nghiệm *</p>
        <div className="flex gap-2">
          {[1, 2, 3, 4, 5].map((value) => {
            const active = rating === value
            return (
              <button
                key={value}
                type="button"
                onClick={() => setRating(value)}
                className={`w-10 h-10 rounded-full border text-sm font-semibold flex items-center justify-center transition-all ${
                  active
                    ? 'bg-primary text-primary-foreground border-primary shadow-sm scale-105'
                    : 'bg-background text-muted-foreground border-border hover:bg-accent'
                }`}
                aria-label={`${value} sao`}
              >
                {value}
              </button>
            )
          })}
        </div>
        <p className="text-xs text-muted-foreground">
          1 sao: rất không hài lòng · 5 sao: rất hài lòng
        </p>
      </div>

      <div className="space-y-1">
        <label htmlFor="message" className="text-sm font-medium">
          Nội dung góp ý *
        </label>
        <textarea
          id="message"
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          rows={4}
          className="w-full px-3 py-2 rounded-xl border bg-background text-sm outline-none transition-colors focus:ring-2 focus:ring-primary/30 border-border focus:border-primary resize-none"
          placeholder="Bạn thích / chưa hài lòng điều gì? Tính năng nào muốn bổ sung?"
        />
      </div>

      {error && <p className="text-xs text-red-500">{error}</p>}
      {state === 'success' && (
        <p className="text-xs text-emerald-600">
          Cảm ơn bạn! Phản hồi đã được gửi đến chúng mình.
        </p>
      )}

      <Button
        type="submit"
        className="w-full h-11 text-sm font-semibold"
        disabled={state === 'submitting'}
      >
        {state === 'submitting' ? 'Đang gửi...' : 'Gửi phản hồi'}
      </Button>
    </form>
  )
}

