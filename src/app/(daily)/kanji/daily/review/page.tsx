import Link from 'next/link'
import type { Metadata } from 'next'
import { ArrowLeft } from 'lucide-react'
import { todayVN } from '@/lib/daily-kanji'
import { ReviewDeck } from '@/components/kanji-daily/ReviewDeck'

export const dynamic = 'force-dynamic'

export const metadata: Metadata = { title: 'Ôn tập kanji' }

export default function DailyKanjiReviewPage() {
  return (
    <div className="space-y-4">
      <Link
        href="/kanji/daily"
        className="inline-flex items-center gap-1.5 text-sm text-muted-foreground transition-colors hover:text-foreground"
      >
        <ArrowLeft className="h-4 w-4" /> Lịch sử
      </Link>
      <ReviewDeck today={todayVN()} />
    </div>
  )
}
