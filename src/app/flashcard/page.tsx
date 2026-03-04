import { createClient } from '@/lib/supabase/server'
import { FlashCardSetup } from '@/components/flashcard/FlashCardSetup'
import type { Vocabulary } from '@/types/database'


export const metadata = {
  title: 'Flashcard — Học tất cả từ vựng',
}

export default async function FlashCardAllPage() {
  const supabase = await createClient()

  // Để tránh giới hạn 1000 rows mặc định của Supabase,
  // fetch theo từng cấp JLPT (mỗi cấp < 1000) rồi gộp lại.
  const levels = ['N5', 'N4', 'N3', 'N2', 'N1'] as const

  const levelPromises = levels.map((level) =>
    supabase
      .from('vocabulary')
      .select('*')
      .eq('is_active', true)
      .eq('jlpt_level', level)
      .order('order_index'),
  )

  const otherPromise = supabase
    .from('vocabulary')
    .select('*')
    .eq('is_active', true)
    .is('jlpt_level', null)
    .order('order_index')

  const results = await Promise.all([...levelPromises, otherPromise])

  const allCards: Vocabulary[] = results.flatMap((res) => (res.data ?? [])) as Vocabulary[]

  const cards = allCards

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
    <FlashCardSetup
      cards={cards}
      deckName="Tất cả từ vựng"
      backHref="/decks"
    />
  )
}
