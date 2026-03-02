import { createClient } from '@/lib/supabase/server'
import { FlashCardDeck } from '@/components/flashcard/FlashCardDeck'


export const metadata = {
  title: 'Flashcard — Học tất cả từ vựng',
}

export default async function FlashCardAllPage() {
  const supabase = await createClient()

  const { data } = await supabase
    .from('vocabulary')
    .select('*')
    .eq('is_active', true)
    .order('order_index')

  const cards = data ?? []

  if (cards.length === 0) {
    return (
      <div className="flex items-center justify-center min-h-[calc(100vh-3.5rem)]">
        <div className="text-center text-muted-foreground">
          <div className="text-4xl mb-3">📭</div>
          <p>Chưa có từ vựng nào.</p>
        </div>
      </div>
    )
  }

  return (
    <FlashCardDeck
      cards={cards}
      deckName="Tất cả từ vựng"
      backHref="/decks"
    />
  )
}
