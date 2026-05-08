import { createClient } from '@/lib/supabase/server'
import { CharacterCell, type AccentColor } from '@/components/alphabet/CharacterCell'
import type { AlphabetCharacter } from '@/types/database'
import Link from 'next/link'
import { PenLine } from 'lucide-react'
import { cn } from '@/lib/utils'

export const metadata = {
  title: 'Bảng chữ cái tiếng Nhật',
  description: 'Hiragana, Katakana — bảng chữ cái cơ bản tiếng Nhật',
}

const BASIC_GROUPS        = ['vowels', 'ka-row', 'sa-row', 'ta-row', 'na-row', 'ha-row', 'ma-row', 'ya-row', 'ra-row', 'wa-row', 'n']
const DAKUTEN_GROUPS      = ['ga-row', 'za-row', 'da-row', 'ba-row', 'pa-row']
const YOON_BASIC_GROUPS   = ['kya-row', 'sha-row', 'cha-row', 'nya-row', 'hya-row', 'mya-row', 'rya-row']
const YOON_DAKUTEN_GROUPS = ['gya-row', 'ja-row', 'bya-row', 'pya-row']
const YOON_GROUPS         = [...YOON_BASIC_GROUPS, ...YOON_DAKUTEN_GROUPS]
const GROUP_ORDER         = [...BASIC_GROUPS]
const DAKUTEN_ORDER       = [...DAKUTEN_GROUPS]
const YOON_ORDER          = [...YOON_GROUPS]

const GROUP_LABELS: Record<string, string> = {
  vowels:    'Nguyên âm',
  'ka-row':  'Hàng K',  'sa-row': 'Hàng S',  'ta-row': 'Hàng T',
  'na-row':  'Hàng N',  'ha-row': 'Hàng H',  'ma-row': 'Hàng M',
  'ya-row':  'Hàng Y',  'ra-row': 'Hàng R',  'wa-row': 'Hàng W',
  n:         'Âm N',
  'ga-row':  'Hàng G',  'za-row': 'Hàng Z',  'da-row': 'Hàng D',
  'ba-row':  'Hàng B',  'pa-row': 'Hàng P',
  'kya-row': 'Âm KY',   'sha-row': 'Âm SH',  'cha-row': 'Âm CH',
  'nya-row': 'Âm NY',   'hya-row': 'Âm HY',  'mya-row': 'Âm MY',
  'rya-row': 'Âm RY',
  'gya-row': 'Âm GY',   'ja-row':  'Âm J',   'bya-row': 'Âm BY',
  'pya-row': 'Âm PY',
}

const GROUP_COLOR: Record<string, AccentColor> = {
  vowels: 'slate', n: 'slate',
  'ka-row': 'blue',   'ga-row': 'blue',   'kya-row': 'blue',  'gya-row': 'blue',
  'sa-row': 'green',  'za-row': 'green',  'sha-row': 'green', 'ja-row':  'green',
  'ta-row': 'amber',  'da-row': 'amber',  'cha-row': 'amber',
  'na-row': 'cyan',   'nya-row': 'cyan',
  'ha-row': 'rose',   'ba-row': 'rose',   'hya-row': 'rose',  'bya-row': 'rose',
  'pa-row': 'purple', 'pya-row': 'purple',
  'ma-row': 'orange', 'mya-row': 'orange',
  'ya-row': 'yellow',
  'ra-row': 'indigo', 'rya-row': 'indigo',
  'wa-row': 'pink',
}

type DakutenMeta = { base: string; baseRoma: string; symbol: string; symbolName: string; labelColor: string }
const DAKUTEN_META: Record<string, DakutenMeta> = {
  'ga-row':  { base: 'か', baseRoma: 'K', symbol: '゛', symbolName: 'ten-ten', labelColor: 'text-blue-500' },
  'za-row':  { base: 'さ', baseRoma: 'S', symbol: '゛', symbolName: 'ten-ten', labelColor: 'text-green-500' },
  'da-row':  { base: 'た', baseRoma: 'T', symbol: '゛', symbolName: 'ten-ten', labelColor: 'text-amber-500' },
  'ba-row':  { base: 'は', baseRoma: 'H', symbol: '゛', symbolName: 'ten-ten', labelColor: 'text-rose-500' },
  'pa-row':  { base: 'は', baseRoma: 'H', symbol: '゜', symbolName: 'maru',    labelColor: 'text-purple-500' },
  'gya-row': { base: 'き', baseRoma: 'KY', symbol: '゛', symbolName: 'ten-ten', labelColor: 'text-blue-500' },
  'ja-row':  { base: 'し', baseRoma: 'SH', symbol: '゛', symbolName: 'ten-ten', labelColor: 'text-green-500' },
  'bya-row': { base: 'ひ', baseRoma: 'HY', symbol: '゛', symbolName: 'ten-ten', labelColor: 'text-rose-500' },
  'pya-row': { base: 'ひ', baseRoma: 'HY', symbol: '゜', symbolName: 'maru',    labelColor: 'text-purple-500' },
}

// ゛゜ standalone bị render thành combining mark — dùng fullwidth space làm base
function MarkSymbol({ symbol, className }: { symbol: string; className?: string }) {
  return (
    <span className={cn('font-japanese inline-block', className)}>{'　'}{symbol}</span>
  )
}

function SectionDivider({ label }: { label: string }) {
  return (
    <div className="flex items-center gap-3 mb-8 -mt-2">
      <div className="flex-1 border-t border-dashed border-border" />
      <span className="text-xs font-semibold text-muted-foreground uppercase tracking-widest whitespace-nowrap">
        {label}
      </span>
      <div className="flex-1 border-t border-dashed border-border" />
    </div>
  )
}

const VOWEL_COLUMNS = ['a', 'i', 'u', 'e', 'o'] as const

function getVowelSlot(romanization: string) {
  const last = romanization[romanization.length - 1]?.toLowerCase()
  return VOWEL_COLUMNS.includes(last as (typeof VOWEL_COLUMNS)[number]) ? last : null
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

function AlphabetGrid({ characters, groupOrder = GROUP_ORDER }: { characters: AlphabetCharacter[]; groupOrder?: string[] }) {
  const groups = groupCharacters(characters)

  return (
    <div className="space-y-8 flex flex-col items-center w-full">
      {groupOrder.filter((g) => groups[g]).map((groupKey) => {
        const dakutenMeta = DAKUTEN_META[groupKey]
        const isYoon = YOON_GROUPS.includes(groupKey)
        const sorted = groups[groupKey].slice().sort((a, b) => (a.order_index ?? 0) - (b.order_index ?? 0))

        return (
          <div key={groupKey} className="w-full">

            {/* Group heading */}
            <div className="text-center mb-3">
              <h3 className="text-base font-semibold text-muted-foreground uppercase tracking-wide inline">
                {GROUP_LABELS[groupKey] ?? groupKey}
              </h3>
              {dakutenMeta && (
                <span className={cn('ml-2 inline-flex items-center gap-1 font-medium', dakutenMeta.labelColor)}>
                  <span className="text-sm">—</span>
                  <span className="font-japanese text-lg">{dakutenMeta.base}</span>
                  <span className="text-sm">({dakutenMeta.baseRoma})</span>
                  <span className="font-japanese text-lg">＋</span>
                  <MarkSymbol symbol={dakutenMeta.symbol} className="text-lg" />
                  <span className="text-sm">({dakutenMeta.symbolName})</span>
                </span>
              )}
            </div>

            {/* Yōon: 3-column grid, header ya/yu/yo */}
            {isYoon ? (
              <div className="max-w-xs mx-auto w-full space-y-1">
                <div className="grid grid-cols-3 gap-x-6 text-center text-xs text-muted-foreground font-medium mb-1">
                  <span>— ya</span><span>— yu</span><span>— yo</span>
                </div>
                <div className="grid grid-cols-3 gap-x-6 gap-y-4">
                  {sorted.map((char) => (
                    <CharacterCell key={char.id} char={char} accent={GROUP_COLOR[groupKey]} />
                  ))}
                </div>
              </div>
            ) : (
              /* Basic / dakuten: 5-column grid with vowel slot placement */
              <div className="grid grid-cols-5 gap-x-6 gap-y-4 justify-items-center">
                {(() => {
                  const slots: (AlphabetCharacter | null)[] = VOWEL_COLUMNS.map(() => null)
                  for (const char of sorted) {
                    const vowel = getVowelSlot(char.romanization)
                    if (vowel) {
                      const idx = VOWEL_COLUMNS.indexOf(vowel as (typeof VOWEL_COLUMNS)[number])
                      if (idx !== -1 && !slots[idx]) { slots[idx] = char; continue }
                    }
                    const fallback = slots.findIndex((s) => s === null)
                    if (fallback !== -1) slots[fallback] = char
                  }
                  return slots.map((char, idx) =>
                    char
                      ? <CharacterCell key={char.id} char={char} accent={GROUP_COLOR[groupKey]} />
                      : <div key={`${groupKey}-${idx}`} className="w-full aspect-square" aria-hidden="true" />,
                  )
                })()}
              </div>
            )}
          </div>
        )
      })}
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
        <p className="text-muted-foreground mb-4">Nhấp vào ký tự để nghe phát âm</p>
        <Link
          href="/alphabet/practice"
          className="inline-flex items-center gap-2 rounded-xl bg-primary px-5 py-2.5 text-sm font-semibold text-primary-foreground hover:bg-primary/90 transition-colors"
        >
          <PenLine className="h-4 w-4" /> Luyện viết
        </Link>
      </div>

      <div className="space-y-16 max-w-7xl mx-auto">
        {/* Hiragana + Katakana side by side */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-12 lg:gap-24">
          <div className="flex flex-col items-center w-full rounded-2xl border border-border bg-muted/60 px-10 py-8 shadow-sm">
            <h2 className="text-2xl font-bold mb-8 text-primary flex items-center gap-2 border-b-2 border-primary/20 pb-2 px-8">
              <span className="text-3xl font-normal">あ</span> Hiragana
            </h2>
            {hiragana.length === 0
              ? <p className="text-muted-foreground text-center">Chưa có dữ liệu Hiragana.</p>
              : <AlphabetGrid characters={hiragana} />}
          </div>

          <div className="flex flex-col items-center w-full rounded-2xl border border-border bg-muted/60 px-10 py-8 shadow-sm">
            <h2 className="text-2xl font-bold mb-8 text-primary flex items-center gap-2 border-b-2 border-primary/20 pb-2 px-8">
              <span className="text-3xl font-normal">ア</span> Katakana
            </h2>
            {katakana.length === 0
              ? <p className="text-muted-foreground text-center">Chưa có dữ liệu Katakana.</p>
              : <AlphabetGrid characters={katakana} />}
          </div>
        </div>

        {/* Ten-ten · Maru — bảng riêng */}
        {(hiragana.some((c) => DAKUTEN_GROUPS.includes(c.group_name ?? '')) ||
          katakana.some((c) => DAKUTEN_GROUPS.includes(c.group_name ?? ''))) && (
          <section>
            <div className="flex items-center gap-4 mb-8">
              <div>
                <h2 className="text-2xl font-bold">Ten-ten · Maru <span className="font-japanese font-normal text-xl text-muted-foreground">(濁音・半濁音)</span></h2>
                <p className="text-sm text-muted-foreground">Thêm ゛(ten-ten) hoặc ゜(maru) vào hàng cơ bản để đổi âm</p>
              </div>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-12 lg:gap-24">
              <div className="rounded-2xl border border-border bg-muted/60 px-10 py-8 shadow-sm">
                <h3 className="text-lg font-bold mb-6 text-primary flex items-center gap-2">
                  <span className="font-japanese text-2xl font-normal">あ</span> Ten-ten · Maru Hiragana
                </h3>
                <AlphabetGrid characters={hiragana} groupOrder={DAKUTEN_ORDER} />
              </div>
              <div className="rounded-2xl border border-border bg-muted/60 px-10 py-8 shadow-sm">
                <h3 className="text-lg font-bold mb-6 text-primary flex items-center gap-2">
                  <span className="font-japanese text-2xl font-normal">ア</span> Ten-ten · Maru Katakana
                </h3>
                <AlphabetGrid characters={katakana} groupOrder={DAKUTEN_ORDER} />
              </div>
            </div>
          </section>
        )}

        {/* Âm ghép (拗音) — bảng riêng bên dưới */}
        {(hiragana.some((c) => YOON_GROUPS.includes(c.group_name ?? '')) ||
          katakana.some((c) => YOON_GROUPS.includes(c.group_name ?? ''))) && (
          <section>
            <div className="flex items-center gap-4 mb-8">
              <div>
                <h2 className="text-2xl font-bold">Âm ghép <span className="font-japanese font-normal text-xl text-muted-foreground">(拗音)</span></h2>
                <p className="text-sm text-muted-foreground">Kết hợp phụ âm + ゃ / ゅ / ょ nhỏ</p>
              </div>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-12 lg:gap-24">
              <div className="rounded-2xl border border-border bg-muted/60 px-10 py-8 shadow-sm">
                <h3 className="text-lg font-bold mb-6 text-primary flex items-center gap-2">
                  <span className="font-japanese text-2xl font-normal">あ</span> Âm ghép Hiragana
                </h3>
                <AlphabetGrid characters={hiragana} groupOrder={YOON_ORDER} />
              </div>
              <div className="rounded-2xl border border-border bg-muted/60 px-10 py-8 shadow-sm">
                <h3 className="text-lg font-bold mb-6 text-primary flex items-center gap-2">
                  <span className="font-japanese text-2xl font-normal">ア</span> Âm ghép Katakana
                </h3>
                <AlphabetGrid characters={katakana} groupOrder={YOON_ORDER} />
              </div>
            </div>
          </section>
        )}
      </div>
    </div>
  )
}
