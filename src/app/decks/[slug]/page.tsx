import { notFound } from 'next/navigation'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/server'
import { WordCard } from '@/components/vocabulary/WordCard'
import { Button } from '@/components/ui/button'
import { ChevronLeft, Zap } from 'lucide-react'
import type { Deck, VocabularyWithDeck } from '@/types/database'


export default async function DeckDetailPage({
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

  const { data: words, count } = await supabase
    .from('vocabulary')
    .select('*, deck:decks(name, slug, emoji)', { count: 'exact' })
    .eq('deck_id', deck.id)
    .eq('is_active', true)
    .order('order_index')

  return (
    <div className="container mx-auto px-4 py-8">
      {/* Breadcrumb */}
      <Link href="/decks" className="flex items-center gap-1 text-sm text-muted-foreground hover:text-foreground transition-colors mb-6">
        <ChevronLeft className="h-4 w-4" />
        Chủ đề
      </Link>

      {/* Header */}
      <div className="flex items-start justify-between gap-4 mb-8">
        <div>
          <div className="flex items-center gap-3 mb-2">
            <span className="text-4xl">{deck.emoji ?? '📚'}</span>
            <h1 className="text-2xl font-bold">{deck.name}</h1>
          </div>
          {deck.description && (
            <p className="text-muted-foreground">{deck.description}</p>
          )}
          <p className="text-sm text-muted-foreground mt-1">{count ?? 0} từ</p>
        </div>
        <Button asChild size="lg" className="shrink-0">
          <Link href={`/flashcard/${deck.slug}`}>
            <Zap className="mr-2 h-4 w-4" />
            Học Flashcard
          </Link>
        </Button>
      </div>

      {/* Words */}
      {(words ?? []).length === 0 ? (
        <div className="text-center py-16 text-muted-foreground">
          <p>Chưa có từ nào trong chủ đề này.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {(words as VocabularyWithDeck[]).map((word) => (
            <WordCard key={word.id} word={word} />
          ))}
        </div>
      )}
    </div>
  )
}
