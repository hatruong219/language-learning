import { createClient } from '@/lib/supabase/server'
import { DeckCard } from '@/components/deck/DeckCard'
import type { DeckWithCount } from '@/types/database'


export const metadata = {
  title: 'Chủ đề học tập',
  description: 'Danh sách các chủ đề từ vựng tiếng Nhật',
}

export default async function DecksPage() {
  const supabase = await createClient()

  const { data } = await supabase
    .from('decks')
    .select('*, vocabulary_count:vocabulary(count)')
    .eq('is_public', true)
    .order('order_index')

  const decks = ((data ?? []) as unknown as Record<string, unknown>[]).map((d) => ({
    ...d,
    vocabulary_count: (d.vocabulary_count as unknown as { count: number }[])[0]?.count ?? 0,
  })) as DeckWithCount[]

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="mb-8">
        <h1 className="text-2xl font-bold mb-1">Chủ đề học tập</h1>
        <p className="text-muted-foreground">{decks.length} chủ đề</p>
      </div>

      {decks.length === 0 ? (
        <div className="text-center py-16 text-muted-foreground">
          <div className="text-4xl mb-3">📚</div>
          <p>Chưa có chủ đề nào.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {decks.map((deck) => (
            <DeckCard key={deck.id} deck={deck} />
          ))}
        </div>
      )}
    </div>
  )
}
