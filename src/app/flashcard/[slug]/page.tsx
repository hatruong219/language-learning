import { notFound } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { FlashCardSetup } from '@/components/flashcard/FlashCardSetup'
import type { Deck } from '@/types/database'

const JLPT_LEVELS = ['N5', 'N4', 'N3', 'N2', 'N1'] as const

export default async function FlashCardDeckPage({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params
  const supabase = await createClient()

  const { data: deckData } = await supabase
    .from('decks')
    .select('id, name, slug, emoji')
    .eq('slug', slug)
    .single()

  if (!deckData) notFound()

  const deck = deckData as unknown as Deck

  const countPromises = JLPT_LEVELS.map((level) =>
    supabase
      .from('vocabulary')
      .select('id', { count: 'exact', head: true })
      .eq('deck_id', deck.id)
      .eq('is_active', true)
      .eq('jlpt_level', level),
  )

  const totalPromise = supabase
    .from('vocabulary')
    .select('id', { count: 'exact', head: true })
    .eq('deck_id', deck.id)
    .eq('is_active', true)

  const [totalRes, ...levelResults] = await Promise.all([totalPromise, ...countPromises])

  const totalAll = totalRes.count ?? 0

  if (totalAll === 0) {
    return (
      <div className="flex items-center justify-center min-h-[calc(100vh-3.5rem)]">
        <div className="text-center text-muted-foreground">
          <div className="text-4xl mb-3">📭</div>
          <p>Chủ đề này chưa có từ nào.</p>
        </div>
      </div>
    )
  }

  const totalByJlpt = Object.fromEntries(
    JLPT_LEVELS.map((level, i) => [level, levelResults[i].count ?? 0]),
  )

  return (
    <FlashCardSetup
      totalByJlpt={totalByJlpt}
      totalAll={totalAll}
      deckId={deck.id}
      deckName={`${deck.emoji ?? ''} ${deck.name}`}
      backHref={`/decks/${deck.slug}`}
    />
  )
}
