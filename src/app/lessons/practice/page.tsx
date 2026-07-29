import Link from 'next/link'
import { ArrowLeft } from 'lucide-react'
import { createClient } from '@/lib/supabase/server'
import { LessonPractice } from '@/components/lessons/LessonPractice'
import type { LessonWords } from '@/components/lessons/LessonPractice'

export const metadata = {
  title: 'Kiểm tra từ — Minna no Nihongo',
}

interface SearchParams {
  /** Danh sách số bài, ngăn bởi dấu phẩy. Ví dụ `?lessons=1,2,3`. */
  lessons?: string
}

export default async function LessonPracticePage({
  searchParams,
}: {
  searchParams: Promise<SearchParams>
}) {
  const params = await searchParams
  const siteId = process.env.NEXT_PUBLIC_SITE_ID ?? ''
  const supabase = await createClient()

  // Nạp HẾT từ vựng 50 bài một lần. Khoảng 2000 dòng, mỗi dòng vài trường —
  // đổi lại chọn bài nào là ra đề ngay, không phải chờ mạng mỗi lần đổi.
  const [lessonsRes, wordsRes] = await Promise.all([
    supabase
      .from('mnn_lessons')
      .select('id, lesson_number, title_vi')
      .eq('site_id', siteId)
      .order('lesson_number'),
    supabase
      .from('mnn_vocabulary')
      .select('id, lesson_id, word, kanji, reading, meaning_vi')
      .eq('site_id', siteId)
      .order('order_index'),
  ])

  const lessons = (lessonsRes.data ?? []) as unknown as {
    id: string
    lesson_number: number
    title_vi: string
  }[]
  const words = (wordsRes.data ?? []) as unknown as {
    id: string
    lesson_id: string
    word: string
    kanji: string | null
    reading: string | null
    meaning_vi: string
  }[]

  const byLesson = new Map(lessons.map((l) => [l.id, l.lesson_number]))

  const data: LessonWords[] = lessons.map((l) => ({
    number: l.lesson_number,
    title: l.title_vi,
    words: words
      .filter((w) => w.lesson_id === l.id && w.meaning_vi)
      .map((w) => ({
        id: `mnn-${w.id}`,
        // Ưu tiên dạng kanji — hai dạng đề 漢字読み và 表記 chỉ dựng được khi
        // từ viết bằng chữ Hán.
        word: w.kanji || w.word,
        reading: w.reading ?? w.word,
        meaning: w.meaning_vi,
      })),
  }))

  const preset = (params.lessons ?? '')
    .split(',')
    .map((n) => Number(n.trim()))
    .filter((n) => Number.isFinite(n) && byLesson.size > 0)

  return (
    <div className="container mx-auto px-4 py-8 max-w-xl space-y-6">
      <Link
        href="/lessons"
        className="inline-flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors"
      >
        <ArrowLeft className="h-4 w-4" /> Minna no Nihongo
      </Link>

      <div>
        <h1 className="text-2xl font-bold mb-1">Kiểm tra từ vựng</h1>
        <p className="text-sm text-muted-foreground">
          Chọn bao nhiêu bài cũng được — ôn chéo nhiều bài mới sát với đề thi.
        </p>
      </div>

      {data.length === 0 ? (
        <p className="text-center py-12 text-sm text-muted-foreground">
          Chưa có dữ liệu từ vựng.
        </p>
      ) : (
        <LessonPractice lessons={data} preset={preset} />
      )}
    </div>
  )
}
