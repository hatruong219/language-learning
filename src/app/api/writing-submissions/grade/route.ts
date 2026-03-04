// POST /api/writing-submissions/grade
import { NextResponse } from 'next/server'
import { createServiceClient } from '@/lib/supabase/service'
import { gradeWritingWithGemini } from '@/lib/gemini'

type SubmissionWithPrompt = {
  id: string
  response: string
  writing_prompts: { prompt_vi: string; min_words: number }
}

export async function POST(req: Request) {
  try {
    const { submission_id } = await req.json() as { submission_id?: string }
    if (!submission_id){
      return NextResponse.json({ error: 'Thieu submission_id.' }, { status: 400 })
    }

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const supabase = createServiceClient() as any

    const { data, error } = await supabase
      .from('writing_submissions')
      .select('id, response, writing_prompts(prompt_vi, min_words)')
      .eq('id', submission_id)
      .single() as { data: SubmissionWithPrompt | null; error: unknown }

    if (error || !data){
      return NextResponse.json({ error: 'Khong tim thay submission.' }, { status: 404 })
    }

    const grading = await gradeWritingWithGemini(
      data.writing_prompts.prompt_vi,
      data.response,
      data.writing_prompts.min_words,
    )

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
      .eq('id', submission_id)

    return NextResponse.json({ submission_id, ...grading })
  } catch (err) {
    console.error('Re-grade error:', err)
    return NextResponse.json({ error: 'Co loi khi cham lai bai.' }, { status: 500 })
  }
}
