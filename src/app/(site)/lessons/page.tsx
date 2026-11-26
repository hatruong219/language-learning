import Link from 'next/link'
import { Dumbbell } from 'lucide-react'
import { createClient } from '@/lib/supabase/server'
import { LessonList } from '@/components/lessons/LessonList'
import type { MnnLesson } from '@/types/database'
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'みんなの日本語 — Bài học',
  description: 'Học tiếng Nhật theo giáo trình Minna no Nihongo',
}

export default async function LessonsPage() {
  const supabase = await createClient()
  const siteId = process.env.NEXT_PUBLIC_SITE_ID ?? ''

  const { data } = await supabase
    .from('mnn_lessons')
    .select('*')
    .eq('site_id', siteId)
    .order('order_index')

  const lessons = (data ?? []) as MnnLesson[]

  return (
    <div className="container mx-auto px-4 py-8 max-w-2xl">
      <div className="mb-6 flex items-start justify-between gap-4 flex-wrap">
        <div>
          <h1 className="text-3xl font-bold">みんなの日本語</h1>
          <p className="text-muted-foreground mt-1">
            Học theo giáo trình Minna no Nihongo — {lessons.length} bài
          </p>
        </div>
        {/* Kiểm tra từ đứng NGOÀI từng bài để ôn chéo được nhiều bài — đề thi
            không hỏi theo bài. */}
        <Link
          href="/lessons/practice"
          className="inline-flex items-center gap-1.5 rounded-xl border px-3 py-2 text-sm font-medium hover:bg-accent transition-colors shrink-0"
        >
          <Dumbbell className="h-4 w-4" /> Kiểm tra từ
        </Link>
      </div>

      <LessonList lessons={lessons} />
    </div>
  )
}
