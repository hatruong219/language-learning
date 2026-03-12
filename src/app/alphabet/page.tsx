import { createClient } from '@/lib/supabase/server'
import { CharacterCell } from '@/components/alphabet/CharacterCell'
import { AlphabetPageClient } from '@/components/alphabet/AlphabetPageClient'
import type { AlphabetCharacter } from '@/types/database'

export const metadata = {
  title: 'Bảng chữ cái tiếng Nhật',
  description: 'Hiragana, Katakana — bảng chữ cái cơ bản tiếng Nhật',
}

const GROUP_ORDER = ['vowels', 'ka-row', 'sa-row', 'ta-row', 'na-row', 'ha-row', 'ma-row', 'ya-row', 'ra-row', 'wa-row', 'n']
const GROUP_LABELS: Record<string, string> = {
  vowels: 'Nguyên âm',
  'ka-row': 'Hàng K',
  'sa-row': 'Hàng S',
  'ta-row': 'Hàng T',
  'na-row': 'Hàng N',
  'ha-row': 'Hàng H',
  'ma-row': 'Hàng M',
  'ya-row': 'Hàng Y',
  'ra-row': 'Hàng R',
  'wa-row': 'Hàng W',
  n: 'Âm N',
}

const VOWEL_COLUMNS = ['a', 'i', 'u', 'e', 'o'] as const

function getVowelFromRomanization(romanization: string) {
  if (!romanization) return null
  const lastChar = romanization[romanization.length - 1]?.toLowerCase()
  return VOWEL_COLUMNS.includes(lastChar as (typeof VOWEL_COLUMNS)[number]) ? lastChar : null
}

function groupCharacters(chars: AlphabetCharacter[]) {
  const groups: Record<string, AlphabetCharacter[]> = {}
  for (const char of chars) {
    const key = char.group_name ?? 'other'
    if (!groups[key]) groups[key] = []
    groups[key].push(char)
  }
  return groups
}

function AlphabetGrid({ characters }: { characters: AlphabetCharacter[] }) {
  const groups = groupCharacters(characters)

  return (
    <div className="space-y-8 flex flex-col items-center w-full">
      {GROUP_ORDER.filter((g) => groups[g]).map((groupKey) => (
        <div key={groupKey} className="w-full">
          <h3 className="text-sm font-semibold text-muted-foreground mb-3 uppercase tracking-wide text-center">
            {GROUP_LABELS[groupKey] ?? groupKey}
          </h3>
          <div className="grid grid-cols-5 gap-x-6 gap-y-4 justify-items-center">
            {(() => {
              const groupChars = groups[groupKey]
                .slice()
                .sort((a, b) => (a.order_index ?? 0) - (b.order_index ?? 0))

              const slots: (AlphabetCharacter | null)[] = VOWEL_COLUMNS.map(() => null)

              for (const char of groupChars) {
                const vowel = getVowelFromRomanization(char.romanization)
                if (vowel) {
                  const idx = VOWEL_COLUMNS.indexOf(vowel as (typeof VOWEL_COLUMNS)[number])
                  if (idx !== -1 && !slots[idx]) {
                    slots[idx] = char
                    continue
                  }
                }

                // Với các ký tự không khớp nguyên âm (vd. âm N),
                // hoặc khi cột đã có rồi, cho vào ô giữa để vẫn canh hàng.
                const fallbackIndex = 2
                if (!slots[fallbackIndex]) {
                  slots[fallbackIndex] = char
                } else {
                  const firstEmpty = slots.findIndex((s) => s === null)
                  if (firstEmpty !== -1) {
                    slots[firstEmpty] = char
                  }
                }
              }

              return slots.map((char, idx) =>
                char ? (
                  <CharacterCell key={char.id} char={char} />
                ) : (
                  <div key={`${groupKey}-${idx}`} className="w-full aspect-square" aria-hidden="true" />
                ),
              )
            })()}
          </div>
        </div>
      ))}
    </div>
  )
}

export default async function AlphabetPage() {
  const supabase = await createClient()

  const { data } = await supabase
    .from('alphabet_characters')
    .select('*')
    .eq('language_code', 'ja')
    .order('order_index')

  const characters = (data ?? []) as AlphabetCharacter[]
  const hiragana = characters.filter((c) => c.script === 'hiragana')
  const katakana = characters.filter((c) => c.script === 'katakana')

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="mb-12 text-center w-full">
        <h1 className="text-3xl font-bold mb-2">Bảng chữ cái tiếng Nhật</h1>
        <p className="text-muted-foreground mb-4">
          Nhấp vào ký tự để nghe phát âm
        </p>
        <AlphabetPageClient hiragana={hiragana} katakana={katakana} />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-12 lg:gap-24 max-w-7xl mx-auto">
        {/* Hiragana Column */}
        <div className="flex flex-col items-center w-full rounded-2xl border border-border bg-muted/60 px-10 py-8 shadow-sm">
          <h2 className="text-2xl font-bold mb-8 text-primary flex items-center gap-2 border-b-2 border-primary/20 pb-2 px-8">
            <span className="text-3xl font-normal">あ</span> Hiragana
          </h2>
          {hiragana.length === 0 ? (
            <p className="text-muted-foreground text-center">Chưa có dữ liệu Hiragana.</p>
          ) : (
            <AlphabetGrid characters={hiragana} />
          )}
        </div>

        {/* Katakana Column */}
        <div className="flex flex-col items-center w-full rounded-2xl border border-border bg-muted/60 px-10 py-8 shadow-sm">
          <h2 className="text-2xl font-bold mb-8 text-primary flex items-center gap-2 border-b-2 border-primary/20 pb-2 px-8">
            <span className="text-3xl font-normal">ア</span> Katakana
          </h2>
          {katakana.length === 0 ? (
            <p className="text-muted-foreground text-center">Chưa có dữ liệu Katakana.</p>
          ) : (
            <AlphabetGrid characters={katakana} />
          )}
        </div>
      </div>
    </div>
  )
}
