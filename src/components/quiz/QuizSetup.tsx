'use client'

import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'
import { countAvailable, DEFAULT_LENGTH } from '@/lib/quiz'
import type { QuizKind, QuizWord } from '@/lib/quiz'

const KIND_LABELS: { key: QuizKind; label: string; note: string }[] = [
  { key: 'vi2ja', label: 'Việt → Nhật', note: 'gõ kana' },
  { key: 'ja2vi', label: 'Nhật → Việt', note: 'chọn nghĩa' },
  { key: 'reading', label: 'Đọc kanji', note: 'chọn cách đọc' },
  { key: 'writing', label: 'Viết kanji', note: 'chọn dạng chữ' },
]

const COUNTS = [5, 10, 20, 40]

interface Props {
  words: QuizWord[]
  count: number
  kinds: QuizKind[]
  onCount: (n: number) => void
  onKinds: (k: QuizKind[]) => void
  onStart: () => void
}

/**
 * Màn chuẩn bị phiên luyện tập.
 *
 * Nói TRƯỚC số câu dựng được, thay vì để người dùng bấm Bắt đầu rồi mới thấy
 * hụt. Hai dạng kanji chỉ dựng được với từ có chữ Hán, nên con số đổi theo lựa
 * chọn — đó là thông tin, không phải lỗi.
 */
export function QuizSetup({
  words,
  count,
  kinds,
  onCount,
  onKinds,
  onStart,
}: Props) {
  const available = countAvailable(words, kinds)
  const enough = available > 0

  function toggle(kind: QuizKind) {
    const next = kinds.includes(kind)
      ? kinds.filter((k) => k !== kind)
      : [...kinds, kind]
    // Tắt hết thì không còn dạng nào để ra đề. Giữ lại ít nhất một, thay vì
    // cho tắt sạch rồi báo lỗi.
    if (next.length > 0) onKinds(next)
  }

  return (
    <div className="space-y-6">
      <section className="space-y-2">
        <h3 className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
          Dạng câu hỏi
        </h3>
        <div className="grid grid-cols-2 gap-2">
          {KIND_LABELS.map(({ key, label, note }) => (
            <button
              key={key}
              onClick={() => toggle(key)}
              className={cn(
                'rounded-xl border px-3 py-2.5 text-left transition-colors',
                kinds.includes(key)
                  ? 'border-primary bg-primary/10'
                  : 'hover:bg-accent',
              )}
            >
              <span className="block text-sm font-medium">{label}</span>
              <span className="block text-xs text-muted-foreground">
                {note}
              </span>
            </button>
          ))}
        </div>
      </section>

      <section className="space-y-2">
        <h3 className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
          Số câu
        </h3>
        <div className="flex flex-wrap gap-2">
          {COUNTS.map((n) => (
            <button
              key={n}
              onClick={() => onCount(n)}
              className={cn(
                'rounded-lg border px-4 py-2 text-sm font-medium transition-colors',
                n === count
                  ? 'border-primary bg-primary/10'
                  : 'hover:bg-accent',
              )}
            >
              {n}
            </button>
          ))}
        </div>
      </section>

      <p className="text-sm text-muted-foreground">
        {enough
          ? `${available} từ ra đề được với lựa chọn này.`
          : 'Không có từ nào ra đề được — thử bật thêm dạng câu hỏi hoặc nới bộ lọc.'}
      </p>

      <Button
        onClick={onStart}
        disabled={!enough}
        size="lg"
        className="w-full"
      >
        {enough
          ? `Bắt đầu · ${Math.min(available, count)} câu`
          : 'Chưa dựng được câu nào'}
      </Button>
    </div>
  )
}

export { DEFAULT_LENGTH }
