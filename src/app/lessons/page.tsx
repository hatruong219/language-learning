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
      <div className="mb-8">
        <h1 className="text-3xl font-bold">みんなの日本語</h1>
        <p className="text-muted-foreground mt-1">
          Học theo giáo trình Minna no Nihongo — {lessons.length} bài
        </p>
      </div>

      <LessonList lessons={lessons} />
    </div>
  )
}
