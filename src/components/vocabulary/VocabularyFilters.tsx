'use client'

import { useRouter, useSearchParams } from 'next/navigation'
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Button } from '@/components/ui/button'
import { Search, X } from 'lucide-react'
import { useCallback, useEffect, useTransition } from 'react'

interface VocabularyFiltersProps {
  currentParams: { jlpt?: string; q?: string }
}

const JLPT_LEVELS = ['N5', 'N4', 'N3', 'N2', 'N1']

/**
 * Nhớ bộ lọc lần trước cho màn hình khỏi trống lúc quay lại.
 *
 * CHỈ nhớ bộ lọc — không lưu tiến độ học. Đây là trạng thái giao diện, không
 * phải kết quả học.
 */
const FILTER_KEY = 'vocabulary-filter'

export function VocabularyFilters({ currentParams }: VocabularyFiltersProps) {
  const router = useRouter()
  const searchParams = useSearchParams()
  const [, startTransition] = useTransition()

  // Ghi lại mỗi lần bộ lọc đổi.
  useEffect(() => {
    const saved = JSON.stringify({
      jlpt: currentParams.jlpt ?? '',
      q: currentParams.q ?? '',
    })
    try {
      window.localStorage.setItem(FILTER_KEY, saved)
    } catch {
      // Trình duyệt chặn localStorage (chế độ riêng tư) — bỏ qua, không phải
      // lỗi người dùng cần biết.
    }
  }, [currentParams.jlpt, currentParams.q])

  // Vào trang không kèm tham số nào thì khôi phục bộ lọc lần trước.
  useEffect(() => {
    if (searchParams.toString() !== '') return
    try {
      const raw = window.localStorage.getItem(FILTER_KEY)
      if (!raw) return
      const { jlpt, q } = JSON.parse(raw) as { jlpt?: string; q?: string }
      if (!jlpt && !q) return
      const next = new URLSearchParams()
      if (jlpt) next.set('jlpt', jlpt)
      if (q) next.set('q', q)
      router.replace(`?${next.toString()}`)
    } catch {
      // JSON hỏng thì coi như chưa nhớ gì.
    }
    // Chỉ chạy một lần lúc vào trang trống — thêm phụ thuộc là nó tự chuyển
    // hướng ngay sau khi người dùng chủ động xoá bộ lọc.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  const updateParams = useCallback(
    (updates: Record<string, string | undefined>) => {
      const params = new URLSearchParams(searchParams.toString())
      Object.entries(updates).forEach(([key, value]) => {
        if (value) {
          params.set(key, value)
        } else {
          params.delete(key)
        }
      })
      params.delete('page')
      startTransition(() => {
        router.push(`?${params.toString()}`)
      })
    },
    [router, searchParams],
  )

  const hasFilters = currentParams.jlpt || currentParams.q

  return (
    <div className="flex flex-col sm:flex-row gap-3 mb-6">
      {/* Search */}
      <div className="relative flex-1">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
        <Input
          placeholder="Tìm từ vựng..."
          className="pl-9"
          defaultValue={currentParams.q}
          onChange={(e) => {
            const val = e.target.value
            if (val.length === 0 || val.length >= 2) {
              updateParams({ q: val || undefined })
            }
          }}
        />
      </div>

      {/* JLPT filter */}
      <Select
        value={currentParams.jlpt ?? 'all'}
        onValueChange={(v) => updateParams({ jlpt: v === 'all' ? undefined : v })}
      >
        <SelectTrigger className="w-full sm:w-32">
          <SelectValue placeholder="JLPT" />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="all">Tất cả</SelectItem>
          {JLPT_LEVELS.map((level) => (
            <SelectItem key={level} value={level}>
              {level}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>

      {/* Clear filters */}
      {hasFilters && (
        <Button
          variant="ghost"
          size="icon"
          onClick={() => updateParams({ jlpt: undefined, q: undefined })}
          title="Xoá bộ lọc"
        >
          <X className="h-4 w-4" />
        </Button>
      )}
    </div>
  )
}
