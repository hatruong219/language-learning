import { notFound } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { FlashCardDeck } from '@/components/flashcard/FlashCardDeck'
import type { Deck, Vocabulary } from '@/types/database'


export default async function FlashCardDeckPage({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params
  const supabase = await createClient()

  const { data: deckData } = await supabase
    .from('decks')
    .select('*')
    .eq('slug', slug)
    .single()

  if (!deckData) notFound()

  const deck = deckData as unknown as Deck

  const { data } = await supabase
    .from('vocabulary')
    .select('*')
    .eq('deck_id', deck.id)
    .eq('is_active', true)
    .order('order_index')

  const cards = (data ?? []) as unknown as Vocabulary[]

  if (cards.length === 0) {
    return (
      <div className="flex items-center justify-center min-h-[calc(100vh-3.5rem)]">
        <div className="text-center text-muted-foreground">
          <div className="text-4xl mb-3">📭</div>
          <p>Chủ đề này chưa có từ nào.</p>
        </div>
      </div>
    )
  }

  return (
    <FlashCardDeck
      cards={cards}
      deckName={`${deck.emoji ?? ''} ${deck.name}`}
      backHref={`/decks/${deck.slug}`}
    />
  )
}
