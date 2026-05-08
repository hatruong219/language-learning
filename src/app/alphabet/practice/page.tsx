import { createClient } from '@/lib/supabase/server'
import { PracticeClient } from '@/components/alphabet/PracticeClient'
import type { AlphabetCharacter } from '@/types/database'
import type { Metadata } from 'next'
import Link from 'next/link'
import { ArrowLeft } from 'lucide-react'

export const metadata: Metadata = {
  title: 'Luyện viết bảng chữ cái',
  description: 'Luyện gõ romaji và vẽ Hiragana/Katakana',
}

export default async function AlphabetPracticePage() {
  const supabase = await createClient()

  const { data } = await supabase
    .from('alphabet_characters')
    .select('*')
    .eq('language_code', 'ja')
    .in('script', ['hiragana', 'katakana'])
    .lte('order_index', 46)
    .order('order_index')

  const characters = (data ?? []) as AlphabetCharacter[]

  return (
    <div className="container mx-auto px-4 py-8 max-w-2xl">
      <div className="mb-8">
        <Link
          href="/alphabet"
          className="inline-flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors mb-4"
        >
          <ArrowLeft className="h-4 w-4" /> Bảng chữ cái
        </Link>
        <h1 className="text-3xl font-bold">Luyện viết</h1>
        <p className="text-muted-foreground mt-1">Chọn chế độ và bộ ký tự để bắt đầu</p>
      </div>

      <PracticeClient characters={characters} />
    </div>
  )
}
