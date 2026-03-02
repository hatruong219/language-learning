interface FuriganaTextProps {
  word: string
  reading?: string | null
  className?: string
  readingClassName?: string
}

export function FuriganaText({ word, reading, className, readingClassName }: FuriganaTextProps) {
  if (!reading || reading === word) {
    return <span className={className}>{word}</span>
  }

  return (
    <ruby className={className}>
      {word}
      <rp>(</rp>
      <rt className={readingClassName ?? 'text-xs font-normal'}>{reading}</rt>
      <rp>)</rp>
    </ruby>
  )
}
