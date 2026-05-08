import type { MnnGrammar } from '@/types/database'

export function GrammarSection({ grammar }: { grammar: MnnGrammar[] }) {
  return (
    <div className="space-y-3">
      <h3 className="text-base font-semibold">Ngữ pháp ({grammar.length} mẫu câu)</h3>
      <div className="space-y-4">
        {grammar.map((g, i) => (
          <div key={g.id} className="rounded-xl border bg-card p-5 space-y-3">
            <div className="flex items-start gap-3">
              <span className="shrink-0 w-6 h-6 rounded-full bg-primary text-primary-foreground text-xs flex items-center justify-center font-bold mt-0.5">
                {i + 1}
              </span>
              <div className="flex-1 space-y-2">
                <p className="text-xl font-japanese font-bold text-primary">{g.pattern}</p>
                <p className="text-sm text-foreground">{g.explanation_vi}</p>
              </div>
            </div>

            {g.example_ja && (
              <div className="ml-9 rounded-lg bg-muted/60 p-3 space-y-1">
                <p className="font-japanese text-base">
                  <span className="text-muted-foreground text-xs mr-2">例）</span>
                  {g.example_ja}
                </p>
                {g.example_vi && (
                  <p className="text-sm text-muted-foreground">{g.example_vi}</p>
                )}
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  )
}
