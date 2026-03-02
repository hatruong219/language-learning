import Link from 'next/link'
import { Card, CardContent } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Zap, BookOpen } from 'lucide-react'
import type { DeckWithCount } from '@/types/database'

interface DeckCardProps {
  deck: DeckWithCount
}

export function DeckCard({ deck }: DeckCardProps) {
  return (
    <Card className="group hover:shadow-md transition-all duration-200 hover:-translate-y-0.5 overflow-hidden">
      <CardContent className="p-5">
        <div className="flex items-start gap-3 mb-3">
          <span className="text-3xl leading-none">{deck.emoji ?? '📚'}</span>
          <div className="flex-1 min-w-0">
            <h3 className="font-bold text-base leading-tight truncate">{deck.name}</h3>
            <p className="text-xs text-muted-foreground mt-0.5">
              {deck.vocabulary_count} từ
            </p>
          </div>
        </div>

        {deck.description && (
          <p className="text-sm text-muted-foreground mb-4 line-clamp-2">{deck.description}</p>
        )}

        <div className="flex gap-2">
          <Button asChild size="sm" className="flex-1">
            <Link href={`/flashcard/${deck.slug}`}>
              <Zap className="h-3.5 w-3.5 mr-1" />
              Học ngay
            </Link>
          </Button>
          <Button asChild size="sm" variant="outline" className="flex-1">
            <Link href={`/decks/${deck.slug}`}>
              <BookOpen className="h-3.5 w-3.5 mr-1" />
              Xem từ
            </Link>
          </Button>
        </div>
      </CardContent>
    </Card>
  )
}
