import { notFound } from 'next/navigation'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/server'
import { FuriganaText } from '@/components/shared/FuriganaText'
import { JLPTBadge } from '@/components/shared/JLPTBadge'
import { TTSButton } from '@/components/shared/TTSButton'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { Separator } from '@/components/ui/separator'
import { ChevronLeft, Zap } from 'lucide-react'
import type { VocabularyWithExamples } from '@/types/database'


export default async function VocabularyDetailPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params
  const supabase = await createClient()

  const { data } = await supabase
    .from('vocabulary')
    .select('*, vocabulary_examples(*), deck:decks(name, slug, emoji)')
    .eq('id', id)
    .single()

  if (!data) notFound()

  const word = data as unknown as VocabularyWithExamples

  return (
    <div className="container mx-auto px-4 py-8 max-w-2xl">
      {/* Breadcrumb */}
      <div className="flex items-center gap-2 mb-6 text-sm text-muted-foreground">
        <Link href="/vocabulary" className="hover:text-foreground transition-colors flex items-center gap-1">
          <ChevronLeft className="h-4 w-4" />
          Từ vựng
        </Link>
        {word.deck && (
          <>
            <span>/</span>
            <Link href={`/decks/${word.deck.slug}`} className="hover:text-foreground transition-colors">
              {word.deck.emoji} {word.deck.name}
            </Link>
          </>
        )}
      </div>

      {/* Main card */}
      <Card className="mb-6">
        <CardContent className="p-8 text-center">
          {/* Word */}
          <div className="flex items-center justify-center gap-3 mb-4">
            <FuriganaText
              word={word.word}
              reading={word.reading}
              className="text-5xl font-bold"
              readingClassName="text-base font-normal text-muted-foreground"
            />
            <TTSButton text={word.word} size="default" variant="outline" />
          </div>

          {/* Romanization */}
          {word.romanization && (
            <p className="text-lg text-muted-foreground mb-4">{word.romanization}</p>
          )}

          <Separator className="my-4" />

          {/* Meaning */}
          <div className="mb-4">
            <p className="text-2xl font-semibold">{word.meaning_vi}</p>
            {word.meaning_en && (
              <p className="text-base text-muted-foreground mt-1">{word.meaning_en}</p>
            )}
          </div>

          {/* Badges */}
          <div className="flex items-center justify-center gap-2 flex-wrap">
            <JLPTBadge level={word.jlpt_level} />
            {word.part_of_speech && (
              <span className="text-sm bg-muted px-2 py-0.5 rounded text-muted-foreground">
                {word.part_of_speech}
              </span>
            )}
            {word.tags?.map((tag) => (
              <span key={tag} className="text-xs bg-secondary px-2 py-0.5 rounded text-secondary-foreground">
                {tag}
              </span>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Examples */}
      {word.vocabulary_examples && word.vocabulary_examples.length > 0 && (
        <Card className="mb-6">
          <CardContent className="p-6">
            <h2 className="font-bold text-base mb-4">Câu ví dụ</h2>
            <div className="space-y-4">
              {word.vocabulary_examples.map((ex, i) => (
                <div key={ex.id}>
                  {i > 0 && <Separator className="mb-4" />}
                  <div className="flex items-start gap-2">
                    <div className="flex-1">
                      <div className="flex items-center gap-2">
                        <p className="text-base font-medium">{ex.sentence}</p>
                        <TTSButton text={ex.sentence} />
                      </div>
                      {ex.sentence_reading && (
                        <p className="text-sm text-muted-foreground">{ex.sentence_reading}</p>
                      )}
                      {ex.translation_vi && (
                        <p className="text-sm mt-1 text-foreground/80">{ex.translation_vi}</p>
                      )}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      )}

      {/* Actions */}
      <div className="flex justify-center">
        {word.deck && (
          <Button asChild>
            <Link href={`/flashcard/${word.deck.slug}`}>
              <Zap className="mr-2 h-4 w-4" />
              Học flashcard deck này
            </Link>
          </Button>
        )}
      </div>
    </div>
  )
}
