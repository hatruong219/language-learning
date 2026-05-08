import Link from 'next/link'
import type { MnnLesson } from '@/types/database'
import { ChevronRight, BookOpen } from 'lucide-react'

export function LessonList({ lessons }: { lessons: MnnLesson[] }) {
  if (lessons.length === 0) {
    return (
      <div className="text-center py-16 text-muted-foreground">
        <BookOpen className="h-12 w-12 mx-auto mb-4 opacity-30" />
        <p>Chưa có bài học nào.</p>
      </div>
    )
  }

  return (
    <div className="space-y-3">
      {lessons.map((lesson) => (
        <Link
          key={lesson.id}
          href={`/lessons/${lesson.lesson_number}`}
          className="flex items-center gap-4 rounded-2xl border bg-card p-5 hover:border-primary/50 hover:shadow-sm transition-all group"
        >
          {/* Lesson number badge */}
          <div className="shrink-0 w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center">
            <span className="text-lg font-bold text-primary">{lesson.lesson_number}</span>
          </div>

          {/* Content */}
          <div className="flex-1 min-w-0">
            <p className="font-japanese text-xl font-semibold leading-tight">{lesson.title_vi}</p>
            {lesson.situation_vi && (
              <p className="text-sm text-muted-foreground mt-0.5 truncate">{lesson.situation_vi}</p>
            )}
          </div>

          <ChevronRight className="h-4 w-4 text-muted-foreground group-hover:text-primary transition-colors shrink-0" />
        </Link>
      ))}
    </div>
  )
}
