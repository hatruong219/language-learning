import { NextResponse } from 'next/server'
import { createServiceClient } from '@/lib/supabase/service'

export async function POST(req: Request) {
  try {
    const body = await req.json()

    const { siteId, name, email, message, rating } = body as {
      siteId?: string
      name?: string
      email?: string
      message?: string
      rating?: number
    }

    if (!siteId || !name || !message || typeof rating !== 'number') {
      return NextResponse.json(
        { error: 'Thiếu dữ liệu cần thiết.' },
        { status: 400 },
      )
    }

    const supabase = createServiceClient()

    const payload = {
      site_id: siteId,
      name: name.trim(),
      email: email?.trim() || null,
      message: message.trim(),
      rating,
      metadata: {
        source: 'language-learning',
      },
    }

    // Cast để tránh mismatch type giữa schema local và Supabase types trên build server.
    const { error } = await supabase
      .from('feedbacks')
      .insert(payload as never)

    if (error) {
      console.error('Insert feedback error:', error)
      return NextResponse.json(
        { error: 'Không thể lưu phản hồi.' },
        { status: 500 },
      )
    }

    return NextResponse.json({ success: true })
  } catch (err) {
    console.error('Feedback API error:', err)
    return NextResponse.json(
      { error: 'Có lỗi xảy ra, vui lòng thử lại sau.' },
      { status: 500 },
    )
  }
}

