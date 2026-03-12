'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { WritingPracticeDialog } from '@/components/alphabet/WritingPracticeDialog'
import type { AlphabetCharacter } from '@/types/database'
import { PenLine } from 'lucide-react'

interface Props {
  hiragana: AlphabetCharacter[]
  katakana: AlphabetCharacter[]
}

export function AlphabetPageClient({ hiragana, katakana }: Props) {
  const [dialogOpen, setDialogOpen] = useState(false)

  return (
    <>
      <Button
        onClick={() => setDialogOpen(true)}
        className="gap-2"
        variant="outline"
        size="sm"
      >
        <PenLine className="h-4 w-4" />
        Luyện chữ
      </Button>

      <WritingPracticeDialog
        hiragana={hiragana}
        katakana={katakana}
        open={dialogOpen}
        onClose={() => setDialogOpen(false)}
      />
    </>
  )
}
