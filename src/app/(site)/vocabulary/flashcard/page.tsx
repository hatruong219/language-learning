import { createClient } from '@/lib/supabase/server'
import { FlashCardSetup } from '@/components/flashcard/FlashCardSetup'

export const metadata = {
  title: 'Flashcard — Học tất cả từ vựng',
}

const JLPT_LEVELS = ['N5', 'N4', 'N3', 'N2', 'N1'] as const

export default async function FlashCardAllPage() {
  const supabase = await createClient()
  const siteId = process.env.NEXT_PUBLIC_SITE_ID ?? ''

  const countPromises = JLPT_LEVELS.map((level) =>
    supabase
      .from('vocabulary')
      .select('id', { count: 'exact', head: true })
      .eq('is_active', true)
      .eq('site_id', siteId)
      .eq('jlpt_level', level),
  )

  const totalPromise = supabase
    .from('vocabulary')
    .select('id', { count: 'exact', head: true })
    .eq('is_active', true)
    .eq('site_id', siteId)

  const [totalRes, ...levelResults] = await Promise.all([totalPromise, ...countPromises])

  const totalAll = totalRes.count ?? 0

  if (totalAll === 0) {
    return (
      <div className="flex items-center justify-center min-h-[calc(100vh-3.5rem)]">
        <div className="text-center text-muted-foreground">
          <div className="text-4xl mb-3">📭</div>
          <p>Chưa có từ vựng nào.</p>
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
      deckName="Tất cả từ vựng"
      backHref="/decks"
    />
  )
}
