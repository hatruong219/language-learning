import Link from 'next/link'
import { notFound } from 'next/navigation'
import { ArrowLeft } from 'lucide-react'
import { createClient } from '@/lib/supabase/server'
import type { JlptKanji, JlptKanjiWord } from '@/types/database'

export default async function KanjiCharPage({
  params,
}: {
  params: Promise<{ char: string }>
}) {
  const { char: raw } = await params
  const char = decodeURIComponent(raw)
  const siteId = process.env.NEXT_PUBLIC_SITE_ID ?? ''
  const supabase = await createClient()

  const { data } = await supabase
    .from('jlpt_kanji')
    .select('*')
    .eq('site_id', siteId)
    .eq('character', char)
    .maybeSingle()

  const kanji = data as unknown as JlptKanji | null
  if (!kanji) notFound()

  // Các từ chứa chữ này. Lọc bằng `like` trên chuỗi — 448 dòng nên rẻ, và
  // tránh phải giữ thêm một bảng nối chữ ↔ từ có thể lệch với dữ liệu.
  const { data: wordsData } = await supabase
    .from('jlpt_kanji_words')
    .select('id, order_index, word, han_viet, kana, meaning_vi, level')
    .eq('site_id', siteId)
    .like('word', `%${char}%`)
    .order('order_index')

  const words = (wordsData ?? []) as unknown as Pick<
    JlptKanjiWord,
    'id' | 'word' | 'kana' | 'meaning_vi'
  >[]

  return (
    <div className="container mx-auto px-4 py-8 max-w-2xl space-y-6">
      <Link
        href="/kanji"
        className="inline-flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors"
      >
        <ArrowLeft className="h-4 w-4" /> Từ vựng chữ Hán
      </Link>

      <div className="rounded-2xl border bg-card p-6 flex gap-6 items-start">
        <div className="text-7xl font-japanese leading-none shrink-0">
          {kanji.character}
        </div>
        <dl className="space-y-2 text-sm min-w-0">
          {kanji.han_viet && kanji.han_viet.length > 0 && (
            <Row label="Hán-Việt">
              <span className="font-semibold text-primary uppercase">
                {kanji.han_viet.join(' · ')}
              </span>
            </Row>
          )}
          {kanji.meaning_vi ? (
            <Row label="Nghĩa">{kanji.meaning_vi}</Row>
          ) : kanji.meaning_classic ? (
            // Nói rõ đây là nghĩa Hán cổ, không phải nghĩa tiếng Nhật hiện đại
            // — trộn hai thứ làm người học nhớ sai.
            <Row label="Nghĩa Hán cổ">{kanji.meaning_classic}</Row>
          ) : (
            <Row label="Nghĩa">
              <span className="text-muted-foreground italic">chưa có</span>
            </Row>
          )}
          {kanji.on_readings && kanji.on_readings.length > 0 && (
            <Row label="Âm ON">
              <span className="font-japanese">
                {kanji.on_readings.join('・')}
              </span>
            </Row>
          )}
          {kanji.kun_readings && kanji.kun_readings.length > 0 && (
            <Row label="Âm KUN">
              <span className="font-japanese">
                {kanji.kun_readings.join('・')}
              </span>
            </Row>
          )}
          <Row label="Cấp độ">{kanji.jlpt_level}</Row>
          {kanji.stroke_count !== null && (
            <Row label="Số nét">{kanji.stroke_count} nét</Row>
          )}
        </dl>
      </div>

      {kanji.parts && kanji.parts.length > 0 && (
        <section className="space-y-2">
          <h2 className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
            Mảnh cấu tạo
          </h2>
          <div className="flex flex-wrap gap-2">
            {kanji.parts.map((p, i) => (
              <span
                key={`${p}-${i}`}
                className="rounded-lg border bg-card px-3 py-2 text-xl font-japanese"
              >
                {p}
              </span>
            ))}
          </div>
          <p className="text-xs text-muted-foreground">
            Mảnh cấu tạo dùng để phân biệt chữ nhìn giống nhau, không phải
            chặng bắt buộc phải học trước.
          </p>
        </section>
      )}

      <section className="space-y-2">
        <h2 className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
          {words.length > 0
            ? `${words.length} từ có chữ này`
            : 'Chưa có từ nào dùng chữ này'}
        </h2>
        <ul className="space-y-2">
          {words.map((w) => (
            <li key={w.id} className="rounded-xl border bg-card px-4 py-3">
              <div className="flex items-baseline gap-3 flex-wrap">
                <span className="text-lg font-japanese">{w.word}</span>
                <span className="text-sm text-muted-foreground font-japanese">
                  {w.kana}
                </span>
              </div>
              <p className="text-sm text-muted-foreground">{w.meaning_vi}</p>
            </li>
          ))}
        </ul>
      </section>
    </div>
  )
}

function Row({
  label,
  children,
}: {
  label: string
  children: React.ReactNode
}) {
  return (
    <div className="flex gap-3">
      <dt className="w-24 shrink-0 text-muted-foreground">{label}</dt>
      <dd className="min-w-0">{children}</dd>
    </div>
  )
}
