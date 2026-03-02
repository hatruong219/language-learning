'use client'

import { useRouter, useSearchParams } from 'next/navigation'
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Button } from '@/components/ui/button'
import { Search, X } from 'lucide-react'
import { useCallback, useTransition } from 'react'

interface Deck {
  id: string
  name: string
  slug: string
  emoji: string | null
}

interface VocabularyFiltersProps {
  decks: Deck[]
  currentParams: { deck?: string; jlpt?: string; q?: string }
}

const JLPT_LEVELS = ['N5', 'N4', 'N3', 'N2', 'N1']

export function VocabularyFilters({ decks, currentParams }: VocabularyFiltersProps) {
  const router = useRouter()
  const searchParams = useSearchParams()
  const [isPending, startTransition] = useTransition()

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

  const hasFilters = currentParams.deck || currentParams.jlpt || currentParams.q

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

      {/* Deck filter */}
      <Select
        value={currentParams.deck ?? 'all'}
        onValueChange={(v) => updateParams({ deck: v === 'all' ? undefined : v })}
      >
        <SelectTrigger className="w-full sm:w-48">
          <SelectValue placeholder="Chủ đề" />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="all">Tất cả chủ đề</SelectItem>
          {decks.map((deck) => (
            <SelectItem key={deck.id} value={deck.id}>
              {deck.emoji} {deck.name}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>

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
          onClick={() => updateParams({ deck: undefined, jlpt: undefined, q: undefined })}
          title="Xoá bộ lọc"
        >
          <X className="h-4 w-4" />
        </Button>
      )}
    </div>
  )
}
