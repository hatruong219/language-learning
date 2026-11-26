import Link from 'next/link'
import { ArrowLeft } from 'lucide-react'
import { createClient } from '@/lib/supabase/server'
import { QuizSession } from '@/components/quiz/QuizSession'
import type { QuizWord } from '@/lib/quiz'

export const metadata = {
  title: 'Luyện tập Kanji',
  description: 'Kiểm tra từ vựng chữ Hán',
}

export default async function KanjiPracticePage() {
  const siteId = process.env.NEXT_PUBLIC_SITE_ID ?? ''
  const supabase = await createClient()

  const { data } = await supabase
    .from('jlpt_kanji_words')
    .select('id, word, kana, meaning_vi')
    .eq('site_id', siteId)
    .order('order_index')

  // Tiền tố `kw` nói rõ nguồn — cùng quy ước app iPhone đang dùng, để sau này
  // gộp tiến độ không lẫn id giữa ba nguồn từ vựng.
  const rows = (data ?? []) as unknown as {
    id: string
    word: string
    kana: string
    meaning_vi: string
  }[]

  const words: QuizWord[] = rows.map((w) => ({
    id: `kw-${w.id}`,
    word: w.word,
    reading: w.kana,
    meaning: w.meaning_vi,
  }))

  return (
    <div className="container mx-auto px-4 py-8 max-w-xl space-y-6">
      <Link
        href="/kanji"
        className="inline-flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors"
      >
        <ArrowLeft className="h-4 w-4" /> Từ vựng chữ Hán
      </Link>

      <div>
        <h1 className="text-2xl font-bold mb-1">Luyện tập chữ Hán</h1>
        <p className="text-sm text-muted-foreground">
          Đề thi luôn hỏi kanji TRONG MỘT TỪ, không hỏi chữ đứng riêng.
        </p>
      </div>

      {words.length === 0 ? (
        <p className="text-center py-12 text-sm text-muted-foreground">
          Chưa có dữ liệu để luyện tập.
        </p>
      ) : (
        <QuizSession words={words} kinds={['reading', 'writing']} />
      )}
    </div>
  )
}
