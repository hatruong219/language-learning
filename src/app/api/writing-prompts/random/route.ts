import { NextResponse } from 'next/server'
import { createServiceClient } from '@/lib/supabase/service'
import type { WritingPrompt } from '@/types/database'

export async function GET(req: Request) {
  const { searchParams } = new URL(req.url)
  const category = searchParams.get('category')
  const exclude = searchParams.get('exclude')
  const jlptLevelParam = searchParams.get('jlpt_level')
  const jlptLevels = jlptLevelParam ? jlptLevelParam.split(',').filter(Boolean) : []

  const siteId = process.env.NEXT_PUBLIC_SITE_ID
  if (!siteId){
    return NextResponse.json({ error: 'NEXT_PUBLIC_SITE_ID chua cau hinh' }, { status: 500 })
  }

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const supabase = createServiceClient() as any

  let listQuery = supabase
    .from('writing_prompts')
    .select('id')
    .eq('site_id', siteId)
    .eq('is_active', true)

  if (category) listQuery = listQuery.eq('category', category)
  if (jlptLevels.length > 0) listQuery = listQuery.in('jlpt_level', jlptLevels)
  if (exclude) listQuery = listQuery.neq('id', exclude)

  const { data: ids, error: listError } = await listQuery

  // Nếu loại trừ hết (chỉ có 1 đề) → fetch lại không loại trừ
  if (listError || !ids?.length) {
    let fallbackQuery = supabase
      .from('writing_prompts')
      .select('id')
      .eq('site_id', siteId)
      .eq('is_active', true)
    if (category) fallbackQuery = fallbackQuery.eq('category', category)
    if (jlptLevels.length > 0) fallbackQuery = fallbackQuery.in('jlpt_level', jlptLevels)
    const { data: fallbackIds, error: fbErr } = await fallbackQuery
    if (fbErr || !fallbackIds?.length){
      return NextResponse.json({ error: 'Chua co de bai nao.' }, { status: 404 })
    }
    // chỉ có 1 đề duy nhất, trả luôn
    const { data, error } = await supabase
      .from('writing_prompts')
      .select('id, site_id, title, prompt_vi, prompt_ja, category, jlpt_level, min_words, is_active, order_index, created_at')
      .eq('id', fallbackIds[0].id)
      .single()
    if (error) return NextResponse.json({ error: error.message }, { status: 500 })
    return NextResponse.json(data as WritingPrompt)
  }

  const randomId = ids[Math.floor(Math.random() * ids.length)].id

  const { data, error } = await supabase
    .from('writing_prompts')
    .select('id, site_id, title, prompt_vi, prompt_ja, category, jlpt_level, min_words, is_active, order_index, created_at')
    .eq('id', randomId)
    .single()

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }

  return NextResponse.json(data as WritingPrompt)
}
