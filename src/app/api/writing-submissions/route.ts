import { NextResponse } from 'next/server'
import { createServiceClient } from '@/lib/supabase/service'
import { gradeWritingWithGemini } from '@/lib/gemini'
import type { WritingPrompt, WritingSubmission } from '@/types/database'

export async function POST(req: Request) {
  try {
    const body = await req.json()
    const { prompt_id, prompt_vi: clientPromptVi, min_words: clientMinWords, session_id, response } = body as {
      prompt_id?: string
      prompt_vi?: string
      min_words?: number
      session_id?: string
      response?: string
    }

    if (!response?.trim()) {
      return NextResponse.json({ error: 'Thieu noi dung bai viet.' }, { status: 400 })
    }

    const siteId = process.env.NEXT_PUBLIC_SITE_ID
    if (!siteId) {
      return NextResponse.json({ error: 'NEXT_PUBLIC_SITE_ID chua cau hinh' }, { status: 500 })
    }

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const supabase = createServiceClient() as any

    // Uu tien prompt_vi/min_words tu client (cho fallback prompt)
    // Neu co prompt_id UUID hop le thi fetch them tu DB
    let promptVi = clientPromptVi
    let minWords = clientMinWords ?? 50
    const isFallback = !prompt_id || prompt_id === 'fallback'

    if (!isFallback) {
      const { data: promptData } = await supabase
        .from('writing_prompts')
        .select('prompt_vi, min_words')
        .eq('id', prompt_id)
        .single() as { data: Pick<WritingPrompt, 'prompt_vi' | 'min_words'> | null; error: unknown }
      if (promptData) {
        promptVi = promptData.prompt_vi
        minWords = promptData.min_words
      }
    }

    if (!promptVi) {
      return NextResponse.json({ error: 'Khong xac dinh duoc de bai.' }, { status: 400 })
    }

    // Luu submission (chi khi co prompt_id UUID hop le)
    let submissionId: string | null = null
    if (!isFallback) {
      const { data: submission } = await supabase
        .from('writing_submissions')
        .insert({
          site_id: siteId,
          prompt_id,
          session_id: session_id ?? null,
          response: response.trim(),
        })
        .select('id')
        .single() as { data: Pick<WritingSubmission, 'id'> | null; error: unknown }
      submissionId = submission?.id ?? null
    }

    const grading = await gradeWritingWithGemini(promptVi, response.trim(), minWords)

    if (submissionId) {
      await supabase
        .from('writing_submissions')
        .update({
          score: grading.score,
          score_grammar: grading.score_grammar,
          score_vocab: grading.score_vocab,
          score_content: grading.score_content,
          feedback_vi: grading.feedback_vi,
          errors: grading.errors,
          is_valid_lang: grading.is_valid_lang,
          graded_at: new Date().toISOString(),
        })
        .eq('id', submissionId)
    }

    return NextResponse.json({
      submission_id: submissionId,
      ...grading,
    })
  } catch (err) {
    console.error('Writing submission error:', err)
    return NextResponse.json({ error: 'Co loi xay ra, vui long thu lai.' }, { status: 500 })
  }
}
