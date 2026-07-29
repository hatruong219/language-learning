import Link from 'next/link'
import { ArrowLeft } from 'lucide-react'
import { createClient } from '@/lib/supabase/server'
import { QuizSession } from '@/components/quiz/QuizSession'
import type { QuizWord } from '@/lib/quiz'

export const metadata = {
  title: 'Luyện tập từ vựng',
}

/** Lấy tối đa bấy nhiêu từ làm kho ra đề. Đủ để nhiễu không lặp lại. */
const POOL_SIZE = 500

interface SearchParams {
  jlpt?: string
  q?: string
}

export default async function VocabularyPracticePage({
  searchParams,
}: {
  searchParams: Promise<SearchParams>
}) {
  const params = await searchParams
  const siteId = process.env.NEXT_PUBLIC_SITE_ID ?? ''
  const supabase = await createClient()

  // Ăn CHUNG bộ lọc với trang danh sách: đang xem N3 thì luyện đúng nhóm N3.
  let query = supabase
    .from('vocabulary')
    .select('id, word, reading, meaning_vi')
    .eq('is_active', true)
    .eq('site_id', siteId)
    .limit(POOL_SIZE)

  if (params.jlpt) query = query.eq('jlpt_level', params.jlpt)
  if (params.q?.trim()) {
    const like = `%${params.q.trim()}%`
    query = query.or(
      `word.ilike.${like},reading.ilike.${like},meaning_vi.ilike.${like}`,
    )
  }

  const { data } = await query

  const rows = (data ?? []) as unknown as {
    id: string
    word: string
    reading: string | null
    meaning_vi: string
  }[]

  // Tiền tố `v` nói rõ nguồn — ba nguồn từ vựng dùng chung màn luyện tập nên
  // id phải phân biệt được.
  const words: QuizWord[] = rows
    .filter((w) => w.meaning_vi)
    .map((w) => ({
      id: `v-${w.id}`,
      word: w.word,
      reading: w.reading ?? w.word,
      meaning: w.meaning_vi,
    }))

  const backHref = `/vocabulary?${new URLSearchParams(
    Object.entries(params).filter(([, v]) => v) as [string, string][],
  )}`

  return (
    <div className="container mx-auto px-4 py-8 max-w-xl space-y-6">
      <Link
        href={backHref}
        className="inline-flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors"
      >
        <ArrowLeft className="h-4 w-4" /> Từ vựng
      </Link>

      <div>
        <h1 className="text-2xl font-bold mb-1">Luyện tập từ vựng</h1>
        <p className="text-sm text-muted-foreground">
          {words.length} từ trong phạm vi đang lọc
          {params.jlpt && ` · ${params.jlpt}`}
        </p>
      </div>

      {words.length < 4 ? (
        <p className="text-center py-12 text-sm text-muted-foreground">
          Cần ít nhất 4 từ mới dựng được đề. Thử nới bộ lọc.
        </p>
      ) : (
        <QuizSession words={words} />
      )}
    </div>
  )
}
