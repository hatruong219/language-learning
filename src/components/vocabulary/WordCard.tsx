import Link from 'next/link'
import { Card, CardContent } from '@/components/ui/card'
import { FuriganaText } from '@/components/shared/FuriganaText'
import { JLPTBadge } from '@/components/shared/JLPTBadge'
import { TTSButton } from '@/components/shared/TTSButton'
import type { VocabularyWithDeck } from '@/types/database'

interface WordCardProps {
  word: VocabularyWithDeck
  showDeck?: boolean
}

export function WordCard({ word, showDeck = false }: WordCardProps) {
  return (
    <Card className="group hover:shadow-md transition-all duration-200 hover:-translate-y-0.5">
      <CardContent className="p-4">
        <div className="flex items-start justify-between gap-2">
          <div className="flex-1 min-w-0">
            {/* Word */}
            <div className="flex items-center gap-2 mb-1">
              <Link href={`/vocabulary/${word.id}`}>
                <FuriganaText
                  word={word.word}
                  reading={word.reading}
                  className="text-2xl font-bold leading-tight hover:text-primary transition-colors cursor-pointer"
                />
              </Link>
              <TTSButton text={word.word} />
            </div>

            {/* Romanization */}
            {word.romanization && (
              <p className="text-sm text-muted-foreground mb-1">{word.romanization}</p>
            )}

            {/* Meaning */}
            <p className="text-sm font-medium text-foreground/80 line-clamp-2">{word.meaning_vi}</p>

            {/* Meta */}
            <div className="flex items-center gap-2 mt-2 flex-wrap">
              <JLPTBadge level={word.jlpt_level} />
              {word.part_of_speech && (
                <span className="text-xs text-muted-foreground bg-muted px-1.5 py-0.5 rounded">
                  {word.part_of_speech}
                </span>
              )}
              {showDeck && word.deck && (
                <Link
                  href={`/decks/${word.deck.slug}`}
                  className="text-xs text-muted-foreground hover:text-primary transition-colors"
                >
                  {word.deck.emoji} {word.deck.name}
                </Link>
              )}
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}
