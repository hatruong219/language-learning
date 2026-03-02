import { createClient } from '@/lib/supabase/server'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { CharacterCell } from '@/components/alphabet/CharacterCell'
import type { AlphabetCharacter } from '@/types/database'


export const metadata = {
  title: 'Bảng chữ cái tiếng Nhật',
  description: 'Hiragana, Katakana — bảng chữ cái cơ bản tiếng Nhật',
}

const GROUP_ORDER = ['vowels', 'ka-row', 'sa-row', 'ta-row', 'na-row', 'ha-row', 'ma-row', 'ya-row', 'ra-row', 'wa-row', 'n']
const GROUP_LABELS: Record<string, string> = {
  vowels: 'Nguyên âm',
  'ka-row': 'Hàng Ka',
  'sa-row': 'Hàng Sa',
  'ta-row': 'Hàng Ta',
  'na-row': 'Hàng Na',
  'ha-row': 'Hàng Ha',
  'ma-row': 'Hàng Ma',
  'ya-row': 'Hàng Ya',
  'ra-row': 'Hàng Ra',
  'wa-row': 'Hàng Wa',
  n: 'Âm N',
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
    <div className="space-y-8">
      {GROUP_ORDER.filter((g) => groups[g]).map((groupKey) => (
        <div key={groupKey}>
          <h3 className="text-sm font-semibold text-muted-foreground mb-3 uppercase tracking-wide">
            {GROUP_LABELS[groupKey] ?? groupKey}
          </h3>
          <div className="grid grid-cols-5 gap-2 max-w-sm">
            {groups[groupKey]
              .sort((a, b) => (a.order_index ?? 0) - (b.order_index ?? 0))
              .map((char) => (
                <CharacterCell key={char.id} char={char} />
              ))}
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
      <div className="mb-8">
        <h1 className="text-2xl font-bold mb-1">Bảng chữ cái tiếng Nhật</h1>
        <p className="text-muted-foreground">
          Nhấp vào ký tự để nghe phát âm
        </p>
      </div>

      <Tabs defaultValue="hiragana">
        <TabsList className="mb-6">
          <TabsTrigger value="hiragana">
            ひ Hiragana ({hiragana.length})
          </TabsTrigger>
          <TabsTrigger value="katakana">
            カ Katakana ({katakana.length})
          </TabsTrigger>
        </TabsList>

        <TabsContent value="hiragana">
          {hiragana.length === 0 ? (
            <p className="text-muted-foreground">Chưa có dữ liệu Hiragana.</p>
          ) : (
            <AlphabetGrid characters={hiragana} />
          )}
        </TabsContent>

        <TabsContent value="katakana">
          {katakana.length === 0 ? (
            <p className="text-muted-foreground">Chưa có dữ liệu Katakana.</p>
          ) : (
            <AlphabetGrid characters={katakana} />
          )}
        </TabsContent>
      </Tabs>
    </div>
  )
}
