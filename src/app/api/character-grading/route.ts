// POST /api/character-grading
import { NextResponse } from 'next/server'
import { gradeCharacterWithGemini } from '@/lib/gemini'

export async function POST(req: Request) {
  try {
    const body = await req.json() as {
      character?: string
      romanization?: string
      script?: string
      image_base64?: string
    }

    const { character, romanization, script, image_base64 } = body

    if (!character || !romanization || !script) {
      return NextResponse.json({ error: 'Thiếu thông tin ký tự.' }, { status: 400 })
    }

    if (!image_base64) {
      return NextResponse.json({ error: 'Thiếu ảnh canvas.' }, { status: 400 })
    }

    // Strip data URL prefix nếu có
    const base64Data = image_base64.replace(/^data:image\/\w+;base64,/, '')

    const result = await gradeCharacterWithGemini(character, romanization, script, base64Data)

    return NextResponse.json(result)
  } catch (err) {
    console.error('[character-grading] Error:', err)
    return NextResponse.json(
      { error: 'Có lỗi xảy ra khi chấm điểm, vui lòng thử lại.' },
      { status: 500 },
    )
  }
}
