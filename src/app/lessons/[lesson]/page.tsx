import { createClient } from '@/lib/supabase/server'
import { LessonDetail } from '@/components/lessons/LessonDetail'
import type { MnnLessonFull } from '@/types/database'
import type { Metadata } from 'next'
import Link from 'next/link'
import { ArrowLeft } from 'lucide-react'
import { notFound } from 'next/navigation'

interface Props {
  params: Promise<{ lesson: string }>
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { lesson } = await params
  return {
    title: `Bài ${lesson} — みんなの日本語`,
  }
}

export default async function LessonPage({ params }: Props) {
  const { lesson: lessonParam } = await params
  const lessonNumber = parseInt(lessonParam, 10)

  if (isNaN(lessonNumber)) notFound()

  const supabase = await createClient()
  const siteId = process.env.NEXT_PUBLIC_SITE_ID ?? ''

  const { data } = await supabase
    .from('mnn_lessons')
    .select(`
      *,
      mnn_vocabulary ( * ),
      mnn_grammar ( * ),
      mnn_exercises ( * )
    `)
    .eq('site_id', siteId)
    .eq('lesson_number', lessonNumber)
    .order('order_index', { referencedTable: 'mnn_vocabulary' })
    .order('order_index', { referencedTable: 'mnn_grammar' })
    .order('order_index', { referencedTable: 'mnn_exercises' })
    .single()

  if (!data) notFound()

  const lesson = data as unknown as MnnLessonFull

  return (
    <div className="container mx-auto px-4 py-8 max-w-4xl">
      <div className="mb-6">
        <Link
          href="/lessons"
          className="inline-flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors mb-4"
        >
          <ArrowLeft className="h-4 w-4" /> みんなの日本語
        </Link>
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center shrink-0">
            <span className="text-base font-bold text-primary">{lessonNumber}</span>
          </div>
          <div>
            <h1 className="text-2xl font-bold font-japanese">{lesson.title_vi}</h1>
            {lesson.situation_vi && (
              <p className="text-sm text-muted-foreground mt-0.5">{lesson.situation_vi}</p>
            )}
          </div>
        </div>
      </div>

      <LessonDetail lesson={lesson} />
    </div>
  )
}
