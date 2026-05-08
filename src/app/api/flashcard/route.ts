import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

const SELECT = 'id, word, reading, romanization, meaning_vi, meaning_en, jlpt_level, part_of_speech'

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url)
  const jlpt = searchParams.get('jlpt')        // "N5,N4" hoặc null = tất cả
  const deckId = searchParams.get('deck_id')   // optional
  const count = Math.min(Number(searchParams.get('count') ?? 9999), 9999)

  const supabase = await createClient()
  const siteId = process.env.NEXT_PUBLIC_SITE_ID ?? ''

  let query = supabase
    .from('vocabulary')
    .select(SELECT)
    .eq('is_active', true)
    .eq('site_id', siteId)
    .order('order_index')
    .limit(count)

  if (jlpt) {
    const levels = jlpt.split(',').map((l) => l.trim()).filter(Boolean)
    if (levels.length > 0) query = query.in('jlpt_level', levels)
  }

  if (deckId) query = query.eq('deck_id', deckId)

  const { data, error } = await query
  if (error) return NextResponse.json({ error: error.message }, { status: 500 })

  return NextResponse.json({ cards: data ?? [] })
}
