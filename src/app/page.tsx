import Link from 'next/link'
import { createClient } from '@/lib/supabase/server'
import { DeckCard } from '@/components/deck/DeckCard'
import { WordCard } from '@/components/vocabulary/WordCard'
import { Button } from '@/components/ui/button'
import { Zap, BookOpen, Grid3x3 } from 'lucide-react'
import type { DeckWithCount, VocabularyWithDeck } from '@/types/database'


function pickDailyRandom<T>(items: T[], count: number): T[] {
  if (items.length <= count) return items

  // Seed theo ngày (YYYY-MM-DD) để "ngẫu nhiên hôm nay" nhưng ổn định trong ngày
  const today = new Date().toISOString().slice(0, 10)
  let seed = 0
  for (let i = 0; i < today.length; i++) {
    seed = (seed * 31 + today.charCodeAt(i)) >>> 0
  }

  function nextRandom() {
    // simple LCG
    seed = (seed * 1664525 + 1013904223) >>> 0
    return seed / 0xffffffff
  }

  const indices = new Set<number>()
  while (indices.size < count) {
    const idx = Math.floor(nextRandom() * items.length)
    indices.add(idx)
  }

  return Array.from(indices).map((i) => items[i])
}

export const revalidate = 60

export default async function HomePage() {
  const supabase = await createClient()

  const [decksRes, wordsRes, statsRes] = await Promise.all([
    supabase
      .from('decks')
      .select('id, name, slug, emoji, description, order_index, is_public, vocabulary_count:vocabulary(count)')
      .eq('is_public', true)
      .order('order_index')
      .limit(6),

    supabase
      .from('vocabulary')
      .select(
        'id, word, reading, romanization, meaning_vi, jlpt_level, part_of_speech, deck:decks(name, slug, emoji)',
      )
      .eq('is_active', true)
      .order('order_index')
      .limit(32),

    supabase
      .from('vocabulary')
      .select('count', { count: 'exact', head: true })
      .eq('is_active', true),
  ])

  const decks = ((decksRes.data ?? []) as unknown as Record<string, unknown>[]).map((d) => ({
    ...d,
    vocabulary_count: (d.vocabulary_count as unknown as { count: number }[])[0]?.count ?? 0,
  })) as DeckWithCount[]

  const allWords = (wordsRes.data ?? []) as VocabularyWithDeck[]
  const words = pickDailyRandom(allWords, 3)
  const totalWords = statsRes.count ?? 0

  return (
    <div className="container mx-auto px-4 py-8">
      {/* Hero */}
      <section className="text-center py-12 md:py-20">
        <div className="text-6xl mb-4">🌸</div>
        <h1 className="text-3xl md:text-5xl font-bold mb-4 tracking-tight">
          日本語を学ぼう
        </h1>
        <p className="text-lg md:text-xl text-muted-foreground mb-8 max-w-md mx-auto">
          Học tiếng Nhật mỗi ngày với flashcard, từ vựng và bảng chữ cái
        </p>
        <div className="flex flex-col sm:flex-row gap-3 justify-center">
          <Button asChild size="lg">
            <Link href="/flashcard">
              <Zap className="mr-2 h-5 w-5" />
              Bắt đầu học
            </Link>
          </Button>
          <Button asChild size="lg" variant="outline">
            <Link href="/vocabulary">
              <BookOpen className="mr-2 h-5 w-5" />
              Xem từ vựng
            </Link>
          </Button>
          <Button asChild size="lg" variant="outline">
            <Link href="/alphabet">
              <Grid3x3 className="mr-2 h-5 w-5" />
              Bảng chữ cái
            </Link>
          </Button>
        </div>
      </section>

      {/* Quick Stats */}
      <section className="grid grid-cols-3 gap-4 mb-12 max-w-sm mx-auto">
        {[
          { label: 'Từ vựng', value: totalWords, emoji: '📖' },
          { label: 'Chủ đề', value: decks.length, emoji: '📚' },
          { label: 'Ngôn ngữ', value: 1, emoji: '🇯🇵' },
        ].map(({ label, value, emoji }) => (
          <div key={label} className="text-center p-4 rounded-xl border bg-card">
            <div className="text-2xl mb-1">{emoji}</div>
            <div className="text-2xl font-bold">{value}</div>
            <div className="text-xs text-muted-foreground">{label}</div>
          </div>
        ))}
      </section>

      {/* Featured Decks */}
      {decks.length > 0 && (
        <section className="mb-12">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-xl font-bold">Chủ đề học tập</h2>
            <Link href="/decks" className="text-sm text-primary hover:underline">
              Xem tất cả →
            </Link>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {decks.map((deck) => (
              <DeckCard key={deck.id} deck={deck} />
            ))}
          </div>
        </section>
      )}

      {/* Today's words */}
      {words.length > 0 && (
        <section className="mb-12">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-xl font-bold">Từ ngẫu nhiên hôm nay</h2>
            <Link href="/vocabulary" className="text-sm text-primary hover:underline">
              Xem tất cả →
            </Link>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {words.map((word) => (
              <WordCard key={word.id} word={word} showDeck />
            ))}
          </div>
        </section>
      )}
    </div>
  )
}
