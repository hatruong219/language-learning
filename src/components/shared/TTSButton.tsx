'use client'

import { Volume2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { speak, isTTSSupported } from '@/lib/tts'
import { useEffect, useState } from 'react'

interface TTSButtonProps {
  text: string
  lang?: string
  size?: 'sm' | 'default' | 'lg' | 'icon'
  variant?: 'ghost' | 'outline' | 'default'
  className?: string
}

export function TTSButton({
  text,
  lang = 'ja-JP',
  size = 'icon',
  variant = 'ghost',
  className,
}: TTSButtonProps) {
  const [supported, setSupported] = useState(false)

  useEffect(() => {
    setSupported(isTTSSupported())
  }, [])

  if (!supported) return null

  return (
    <Button
      variant={variant}
      size={size}
      className={className}
      onClick={(e) => {
        e.stopPropagation()
        speak(text, lang)
      }}
      title={`Nghe phát âm: ${text}`}
    >
      <Volume2 className="h-4 w-4" />
      <span className="sr-only">Nghe phát âm</span>
    </Button>
  )
}
