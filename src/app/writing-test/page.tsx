import { createServiceClient } from '@/lib/supabase/service'
import { WritingTestClient } from '@/components/writing/WritingTestClient'
import type { WritingPrompt } from '@/types/database'
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Luyện viết — Chấm điểm AI',
  description: 'Nhận đề viết ngẫu nhiên và được chấm điểm tự động bằng AI Gemini.',
}

export default async function WritingTestPage() {
  const siteId = process.env.NEXT_PUBLIC_SITE_ID
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const supabase = createServiceClient() as any

  let prompt: WritingPrompt | null = null

  if (siteId) {
    // Lấy tất cả IDs rồi random phía server
    const { data: ids } = await supabase
      .from('writing_prompts')
      .select('id')
      .eq('site_id', siteId)
      .eq('is_active', true)

    if (ids?.length) {
      const randomId = ids[Math.floor(Math.random() * ids.length)].id
      const { data } = await supabase
        .from('writing_prompts')
        .select('id, title, prompt_vi, prompt_ja, category, jlpt_level, min_words, is_active, order_index, created_at, site_id')
        .eq('id', randomId)
        .single()
      prompt = data as WritingPrompt | null
    }
  }

  // Fallback nếu chưa có data trong DB
  const fallbackPrompt: WritingPrompt = {
    id: 'fallback',
    site_id: siteId ?? '',
    title: 'Mô tả bản thân',
    prompt_vi: 'Hãy viết một đoạn văn tiếng Nhật giới thiệu về bản thân bạn (tên, tuổi, quê quán, công việc hoặc sở thích).',
    prompt_ja: '自己紹介をしてください。',
    category: 'self',
    jlpt_level: 'N5',
    min_words: 50,
    is_active: true,
    order_index: 0,
    created_at: new Date().toISOString(),
  }

  return (
    <main className="container mx-auto px-4 py-8">
      <div className="mb-8 text-center space-y-2">
        <h1 className="text-3xl font-bold tracking-tight">✍️ Luyện viết</h1>
        <p className="text-muted-foreground max-w-md mx-auto">
          Nhận đề bài ngẫu nhiên, viết bằng tiếng Nhật và nhận điểm số cùng nhận xét từ AI ngay lập tức.
        </p>
      </div>

      <WritingTestClient initialPrompt={prompt ?? fallbackPrompt} />
    </main>
  )
}
