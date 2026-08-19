'use client'

import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'
import { countAvailable } from '@/lib/quiz'
import type { QuizKind, QuizWord } from '@/lib/quiz'

/**
 * Nhãn của từng dạng đề.
 *
 * Mỗi phần chỉ bày ĐÚNG HAI dạng hợp với nó — xem `KINDS_FOR` bên dưới. Bày cả
 * bốn thì màn chuẩn bị phức tạp hơn cả việc học, mà hai dạng chữ Hán vốn không
 * hợp với từ vựng Minna (phần lớn viết bằng kana).
 */
const LABELS: Record<QuizKind, { title: string; note: string }> = {
  vi2ja: { title: 'Việt → Nhật', note: 'gõ lại bằng kana' },
  ja2vi: { title: 'Nhật → Việt', note: 'chọn nghĩa đúng' },
  reading: { title: 'Đọc chữ Hán', note: 'chọn cách đọc' },
  writing: { title: 'Viết chữ Hán', note: 'chọn dạng chữ' },
}

interface Props {
  words: QuizWord[]
  /** Hai dạng đề của phần này. Dạng đầu là mặc định. */
  kinds: readonly QuizKind[]
  kind: QuizKind
  onKind: (k: QuizKind) => void
  onStart: () => void
}

/**
 * Màn chuẩn bị phiên luyện tập.
 *
 * CHỌN MỘT, không chọn nhiều. Trộn nhiều dạng trong một phiên thì mỗi câu một
 * kiểu, người học phải đổi cách nghĩ liên tục và cuối phiên không biết mình yếu
 * ở dạng nào.
 *
 * KHÔNG có tuỳ chọn "số câu". Phạm vi đã chọn CHÍNH LÀ cỡ phiên — chọn 400 từ
 * rồi lại bắt chọn tối đa 40 câu là thừa một bước mà vẫn không kiểm soát được
 * gì. Muốn ngắn thì chọn ít bài.
 */
export function QuizSetup({ words, kinds, kind, onKind, onStart }: Props) {
  const available = countAvailable(words, kind)
  const enough = available >= 4

  return (
    <div className="space-y-6">
      <section className="space-y-2">
        <h3 className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
          Dạng câu hỏi
        </h3>
        <div className="grid grid-cols-2 gap-2">
          {kinds.map((k) => (
            <button
              key={k}
              onClick={() => onKind(k)}
              className={cn(
                'rounded-xl border px-3 py-2.5 text-left transition-colors',
                k === kind
                  ? 'border-primary bg-primary/10'
                  : 'hover:bg-accent',
              )}
            >
              <span className="block text-sm font-medium">
                {LABELS[k].title}
              </span>
              <span className="block text-xs text-muted-foreground">
                {LABELS[k].note}
              </span>
            </button>
          ))}
        </div>
      </section>

      <p className="text-sm text-muted-foreground">
        {enough
          ? `${available} từ trong phạm vi này.`
          : 'Cần ít nhất 4 từ mới dựng được đề — chọn thêm bài hoặc đổi dạng câu hỏi.'}
      </p>

      <Button onClick={onStart} disabled={!enough} size="lg" className="w-full">
        {enough ? `Bắt đầu · ${available} câu` : 'Chưa dựng được đề'}
      </Button>
    </div>
  )
}
