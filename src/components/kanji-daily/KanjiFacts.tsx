import type { DailyKanji } from '@/lib/daily-kanji'
import { WordList } from './WordList'

/** Thông tin một chữ: Hán-Việt, nghĩa, On/Kun, từ ví dụ, chữ dễ nhầm. */
export function KanjiFacts({ kanji: k, showChar = true }: { kanji: DailyKanji; showChar?: boolean }) {
  return (
    <div className="space-y-5">
      <div className="flex items-center gap-5">
        {showChar && <div className="text-7xl font-japanese leading-none shrink-0">{k.k}</div>}
        <div className="min-w-0 space-y-1">
          <p className="text-xl font-bold tracking-wide text-primary">{k.hv}</p>
          <p className="text-lg">{k.mean}</p>
        </div>
      </div>

      <dl className="grid grid-cols-[4rem_1fr] gap-y-1.5 text-sm">
        <dt className="text-muted-foreground">Âm On</dt>
        <dd className="font-japanese">{k.on}</dd>
        <dt className="text-muted-foreground">Âm Kun</dt>
        <dd className="font-japanese">{k.kun || '—'}</dd>
      </dl>

      <section className="space-y-2">
        <h2 className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
          Từ ví dụ · bấm để nghe
        </h2>
        <WordList words={k.words} />
      </section>

      {k.similar && k.similar.length > 0 && (
        <p className="text-sm">
          <span className="text-muted-foreground">Dễ nhầm với: </span>
          {k.similar.map(([c, m], i) => (
            <span key={c}>
              {i > 0 && ' · '}
              <span className="font-japanese text-base">{c}</span> ({m})
            </span>
          ))}
        </p>
      )}
    </div>
  )
}
