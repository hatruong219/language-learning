'use client'

import { useMemo, useState } from 'react'
import Link from 'next/link'
import { Search, X } from 'lucide-react'
import { cn } from '@/lib/utils'

export type KanjiWordRow = {
  id: string
  order_index: number
  word: string
  han_viet: string
  kana: string
  meaning_vi: string
  level: string
}

interface Props {
  words: KanjiWordRow[]
  /** Chữ CÓ trang chi tiết. Chữ ngoài danh sách này không vẽ liên kết. */
  knownChars: string[]
}

const KANJI = /[一-鿿]/u
const LEVEL_ORDER = ['N5', 'N4', 'N3', 'N2', 'N1']

/** Bỏ dấu tiếng Việt để tìm được khi gõ không dấu. */
const MARKS = 'àáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩị' +
  'òóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđ'
const PLAIN = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiii' +
  'ooooooooooooooooouuuuuuuuuuuyyyyyd'

function fold(s: string): string {
  let out = ''
  for (const ch of s.toLowerCase()) {
    const i = MARKS.indexOf(ch)
    out += i < 0 ? ch : PLAIN[i]
  }
  return out
}

/**
 * Danh sách 448 từ chữ Hán.
 *
 * Nạp hết một lần rồi lọc ngay trên máy — 448 dòng là nhỏ, và đổi lại tìm kiếm
 * hiện kết quả tức thì thay vì mỗi lần gõ một chữ lại chờ mạng.
 *
 * Giữ ĐÚNG thứ tự giáo trình, không sắp lại: người soạn xếp theo chủ đề — gia
 * đình, công việc, địa danh — và học theo cụm nghĩa liên quan nhớ tốt hơn.
 */
export function KanjiWordBrowser({ words, knownChars }: Props) {
  const [query, setQuery] = useState('')
  const [level, setLevel] = useState('')
  const [onlyCompound, setOnlyCompound] = useState(false)

  const known = useMemo(() => new Set(knownChars), [knownChars])

  /**
   * Các cấp CÓ THẬT trong dữ liệu, xếp từ dễ tới khó.
   *
   * Gom từ dữ liệu chứ không viết cứng ['N5','N4']: hiện tất cả là N4 nên chỉ
   * một mục, nhưng hôm nào database phân lại cấp là web tự có thêm nút — không
   * phải sửa mã. Cấp lạ ngoài thang JLPT vẫn hiện, xếp cuối: thà thấy nhãn khó
   * hiểu còn hơn im lặng giấu mất cả nhóm từ.
   */
  const levels = useMemo(() => {
    const found = new Set(words.map((w) => w.level).filter(Boolean))
    const known = LEVEL_ORDER.filter((l) => found.has(l))
    const rest = [...found].filter((l) => !LEVEL_ORDER.includes(l)).sort()
    return [...known, ...rest]
  }, [words])

  const rows = useMemo(() => {
    const q = fold(query.trim())
    return words.filter((w) => {
      if (level && w.level !== level) return false
      if (onlyCompound && countKanji(w.word) < 2) return false
      if (!q) return true
      return (
        w.word.includes(query) ||
        w.kana.includes(query) ||
        fold(w.han_viet).includes(q) ||
        fold(w.meaning_vi).includes(q)
      )
    })
  }, [words, query, level, onlyCompound])

  return (
    <div className="space-y-4">
      <div className="relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
        <input
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Tìm chữ, cách đọc, âm Hán-Việt, hoặc nghĩa"
          className="w-full rounded-xl border bg-background pl-9 pr-9 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-ring"
          autoComplete="off"
        />
        {query && (
          <button
            onClick={() => setQuery('')}
            aria-label="Xoá tìm kiếm"
            className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
          >
            <X className="h-4 w-4" />
          </button>
        )}
      </div>

      {/* Một cấp thì không hiện hàng lọc — một nút luôn bật không phải lựa
          chọn, chỉ chiếm chỗ. */}
      {levels.length > 1 && (
        <div className="flex flex-wrap gap-2">
          <Chip label="Tất cả" on={level === ''} onClick={() => setLevel('')} />
          {levels.map((l) => (
            <Chip
              key={l}
              label={l}
              on={level === l}
              onClick={() => setLevel(l)}
            />
          ))}
        </div>
      )}

      <div className="flex items-center justify-between gap-3 text-sm">
        <span className="text-muted-foreground">
          {rows.length === words.length
            ? `${words.length} từ`
            : `${rows.length} / ${words.length} từ`}
        </span>
        <label className="flex items-center gap-2 cursor-pointer">
          <span className="text-muted-foreground">Chỉ từ ghép</span>
          <input
            type="checkbox"
            checked={onlyCompound}
            onChange={(e) => setOnlyCompound(e.target.checked)}
            className="h-4 w-4 rounded border-input accent-primary"
          />
        </label>
      </div>

      {rows.length === 0 ? (
        <p className="text-center py-12 text-sm text-muted-foreground">
          Không tìm thấy từ nào
        </p>
      ) : (
        <ul className="space-y-2">
          {rows.map((w) => (
            <li
              key={w.id}
              className="rounded-xl border bg-card px-4 py-3 space-y-1"
            >
              <div className="flex items-baseline gap-3 flex-wrap">
                <span className="text-xl font-japanese">
                  {[...w.word].map((ch, i) =>
                    KANJI.test(ch) && known.has(ch) ? (
                      <Link
                        key={`${w.id}-${i}`}
                        href={`/kanji/${encodeURIComponent(ch)}`}
                        className="underline decoration-border underline-offset-4 hover:decoration-primary"
                      >
                        {ch}
                      </Link>
                    ) : (
                      <span key={`${w.id}-${i}`}>{ch}</span>
                    ),
                  )}
                </span>
                <span className="text-sm text-muted-foreground font-japanese">
                  {w.kana}
                </span>
              </div>
              <div className="flex items-baseline gap-2 flex-wrap text-sm">
                {w.han_viet && (
                  <span className="text-xs font-semibold tracking-wide text-primary">
                    {w.han_viet}
                  </span>
                )}
                <span className="text-muted-foreground">{w.meaning_vi}</span>
              </div>
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}

function countKanji(s: string): number {
  return (s.match(/[一-鿿]/gu) ?? []).length
}

function Chip({
  label,
  on,
  onClick,
}: {
  label: string
  on: boolean
  onClick: () => void
}) {
  return (
    <button
      onClick={onClick}
      className={cn(
        'rounded-lg border px-3 py-1.5 text-sm font-medium transition-colors',
        on ? 'border-primary bg-primary/10' : 'hover:bg-accent',
      )}
    >
      {label}
    </button>
  )
}
