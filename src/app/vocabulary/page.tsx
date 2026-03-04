import { createClient } from '@/lib/supabase/server'
import { WordCard } from '@/components/vocabulary/WordCard'
import { VocabularyFilters } from '@/components/vocabulary/VocabularyFilters'
import type { VocabularyWithDeck } from '@/types/database'

const PAGE_SIZE = 24

interface SearchParams {
  deck?: string
  jlpt?: string
  q?: string
  page?: string
}

export const metadata = {
  title: 'Từ vựng',
  description: 'Danh sách từ vựng tiếng Nhật',
}

export default async function VocabularyPage({
  searchParams,
}: {
  searchParams: Promise<SearchParams>
}) {
  const params = await searchParams
  const page = Math.max(1, Number(params.page ?? 1))
  const from = (page - 1) * PAGE_SIZE
  const to = from + PAGE_SIZE - 1

  const supabase = await createClient()

  // Build query
  let query = supabase
    .from('vocabulary')
    .select('*, deck:decks(name, slug, emoji)', { count: 'exact' })
    .eq('is_active', true)
    .order('order_index')
    .range(from, to)

  if (params.deck) query = query.eq('deck_id', params.deck)
  if (params.jlpt) query = query.eq('jlpt_level', params.jlpt)
  if (params.q) query = query.ilike('word', `%${params.q}%`)

  const [wordsRes, decksRes] = await Promise.all([
    query,
    supabase
      .from('decks')
      .select('id, name, slug, emoji')
      .eq('is_public', true)
      .order('order_index'),
  ])

  const words = (wordsRes.data ?? []) as VocabularyWithDeck[]
  const totalCount = wordsRes.count ?? 0
  const totalPages = Math.ceil(totalCount / PAGE_SIZE)
  const decks = decksRes.data ?? []

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="mb-6">
        <h1 className="text-2xl font-bold mb-1">Từ vựng tiếng Nhật</h1>
        <p className="text-muted-foreground">{totalCount} từ</p>
      </div>

      <VocabularyFilters decks={decks} currentParams={params} />

      {words.length === 0 ? (
        <div className="text-center py-16 text-muted-foreground">
          <div className="text-4xl mb-3">🔍</div>
          <p>Không tìm thấy từ nào phù hợp.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {words.map((word) => (
            <WordCard key={word.id} word={word} showDeck />
          ))}
        </div>
      )}

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="flex justify-center items-center gap-1 mt-8 flex-wrap">
          {/* Prev */}
          {page > 1 && (
            <a
              href={`?${new URLSearchParams({ ...params, page: String(page - 1) })}`}
              className="px-3 py-1.5 rounded-md text-sm font-medium border border-border hover:bg-accent transition-colors"
            >
              ←
            </a>
          )}

          {/* Page numbers with windowing */}
          {(() => {
            const delta = 2
            const range: (number | 'ellipsis')[] = []
            const left = Math.max(2, page - delta)
            const right = Math.min(totalPages - 1, page + delta)

            // Always show first page
            range.push(1)

            if (left > 2) range.push('ellipsis')

            for (let i = left; i <= right; i++) range.push(i)

            if (right < totalPages - 1) range.push('ellipsis')

            // Always show last page
            if (totalPages > 1) range.push(totalPages)

            return range.map((item, idx) =>
              item === 'ellipsis' ? (
                <span key={`ellipsis-${idx}`} className="px-2 py-1.5 text-sm text-muted-foreground">
                  …
                </span>
              ) : (
                <a
                  key={item}
                  href={`?${new URLSearchParams({ ...params, page: String(item) })}`}
                  className={`px-3 py-1.5 rounded-md text-sm font-medium border transition-colors ${item === page
                      ? 'bg-primary text-primary-foreground border-primary'
                      : 'border-border hover:bg-accent'
                    }`}
                >
                  {item}
                </a>
              )
            )
          })()}

          {/* Next */}
          {page < totalPages && (
            <a
              href={`?${new URLSearchParams({ ...params, page: String(page + 1) })}`}
              className="px-3 py-1.5 rounded-md text-sm font-medium border border-border hover:bg-accent transition-colors"
            >
              →
            </a>
          )}
        </div>
      )}
    </div>
  )
}
