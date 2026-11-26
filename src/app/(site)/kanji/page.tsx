import Link from 'next/link'
import { Dumbbell } from 'lucide-react'
import { createClient } from '@/lib/supabase/server'
import { KanjiWordBrowser } from '@/components/kanji/KanjiWordBrowser'
import type { KanjiWordRow } from '@/components/kanji/KanjiWordBrowser'

export const metadata = {
  title: 'Kanji',
  description: 'Từ vựng chữ Hán N5 · N4',
}

export default async function KanjiPage() {
  const siteId = process.env.NEXT_PUBLIC_SITE_ID ?? ''
  const supabase = await createClient()

  const [wordsRes, charsRes] = await Promise.all([
    supabase
      .from('jlpt_kanji_words')
      .select('id, order_index, word, han_viet, kana, meaning_vi, level')
      .eq('site_id', siteId)
      .order('order_index'),
    // Chữ nào CÓ trang chi tiết. Lấy một lần rồi tra trong bộ nhớ, thay vì hỏi
    // database cho từng từ.
    supabase
      .from('jlpt_kanji')
      .select('character')
      .eq('site_id', siteId),
  ])

  // Supabase suy kiểu ra `never` cho hai bảng này — ép kiểu theo đúng quy ước
  // trong CLAUDE.md của repo.
  const words = (wordsRes.data ?? []) as unknown as KanjiWordRow[]
  const knownChars = (
    (charsRes.data ?? []) as unknown as { character: string }[]
  ).map((k) => k.character)

  return (
    <div className="container mx-auto px-4 py-8 max-w-3xl">
      <div className="mb-6 flex items-start justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold mb-1">Từ vựng chữ Hán</h1>
          <p className="text-muted-foreground">
            {words.length} từ · theo thứ tự giáo trình
          </p>
        </div>
        <Link
          href="/kanji/practice"
          className="inline-flex items-center gap-1.5 rounded-xl border px-3 py-2 text-sm font-medium hover:bg-accent transition-colors shrink-0"
        >
          <Dumbbell className="h-4 w-4" /> Luyện tập
        </Link>
      </div>

      {words.length === 0 ? (
        <div className="text-center py-16 text-muted-foreground">
          <div className="text-4xl mb-3">📚</div>
          <p>Chưa có dữ liệu từ vựng chữ Hán.</p>
        </div>
      ) : (
        <KanjiWordBrowser words={words} knownChars={knownChars} />
      )}
    </div>
  )
}
