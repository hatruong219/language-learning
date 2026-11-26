'use client'

import { useEffect, useRef, useState } from 'react'
import { Eraser, PenLine, Play } from 'lucide-react'

type Stroke = { d: string; num?: { x: number; y: number } }

const SIZE = 300 // px hiển thị; KanjiVG dùng viewBox 109×109
const STROKE_MS = 700
const GAP_MS = 150

/**
 * Đọc file KanjiVG: thứ tự các <path> chính là thứ tự nét, mỗi <text> mang vị
 * trí của số thứ tự nét. Ưu tiên file tự host trong /public/kanjivg, thiếu thì
 * lấy từ CDN (khi thêm chữ vào danh sách mà quên copy file).
 */
async function loadStrokes(code: string): Promise<Stroke[]> {
  const urls = [
    `/kanjivg/${code}.svg`,
    `https://cdn.jsdelivr.net/gh/KanjiVG/kanjivg@master/kanji/${code}.svg`,
  ]
  for (const url of urls) {
    try {
      const res = await fetch(url)
      if (!res.ok) continue
      const doc = new DOMParser().parseFromString(await res.text(), 'image/svg+xml')
      const paths = [...doc.querySelectorAll('path')].map((p) => p.getAttribute('d') ?? '')
      const nums = [...doc.querySelectorAll('text')].map((t) => {
        const m = (t.getAttribute('transform') ?? '').match(
          /matrix\(1 0 0 1 ([\d.]+) ([\d.]+)\)/,
        )
        return m ? { x: Number(m[1]), y: Number(m[2]) } : undefined
      })
      if (paths.length) return paths.map((d, i) => ({ d, num: nums[i] }))
    } catch {
      // thử URL tiếp theo
    }
  }
  return []
}

export function KanjiStrokePlayer({ kanji, code }: { kanji: string; code: string }) {
  const [strokes, setStrokes] = useState<Stroke[] | null>(null)
  const [mode, setMode] = useState<'anim' | 'trace'>('anim')
  const [run, setRun] = useState(0)

  useEffect(() => {
    let alive = true
    loadStrokes(code).then((s) => alive && setStrokes(s))
    return () => {
      alive = false
    }
  }, [code])

  return (
    <section className="space-y-3">
      <div className="flex items-center justify-between gap-2">
        <h2 className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
          {strokes?.length ? `Cách viết · ${strokes.length} nét` : 'Cách viết'}
        </h2>
        <div className="flex gap-2">
          <ModeButton
            active={mode === 'anim'}
            onClick={() => {
              setMode('anim')
              setRun((r) => r + 1)
            }}
          >
            <Play className="h-4 w-4" /> Xem lại
          </ModeButton>
          <ModeButton active={mode === 'trace'} onClick={() => setMode('trace')}>
            <PenLine className="h-4 w-4" /> Tập viết
          </ModeButton>
        </div>
      </div>

      <div
        className="relative mx-auto rounded-2xl border bg-card text-foreground"
        style={{ width: SIZE, height: SIZE }}
      >
        {strokes === null ? (
          <p className="absolute inset-0 grid place-items-center text-sm text-muted-foreground">
            Đang tải nét chữ…
          </p>
        ) : strokes.length === 0 ? (
          <p className="absolute inset-0 grid place-items-center text-sm text-muted-foreground">
            Chưa có dữ liệu nét cho {kanji}
          </p>
        ) : (
          <>
            <Grid />
            {mode === 'anim' ? (
              <Animated key={run} strokes={strokes} />
            ) : (
              <Trace strokes={strokes} />
            )}
          </>
        )}
      </div>
    </section>
  )
}

function ModeButton({
  active,
  onClick,
  children,
}: {
  active: boolean
  onClick: () => void
  children: React.ReactNode
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={`inline-flex items-center gap-1.5 rounded-xl border px-3 py-1.5 text-sm font-medium transition-colors ${
        active ? 'bg-primary text-primary-foreground' : 'hover:bg-accent'
      }`}
    >
      {children}
    </button>
  )
}

function Layer({ children }: { children: React.ReactNode }) {
  return (
    <svg
      viewBox="0 0 109 109"
      width={SIZE}
      height={SIZE}
      className="absolute inset-0"
      fill="none"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      {children}
    </svg>
  )
}

function Grid() {
  return (
    <Layer>
      <path
        d="M54.5 0V109M0 54.5H109"
        stroke="currentColor"
        strokeOpacity={0.12}
        strokeWidth={0.5}
        strokeDasharray="2 2"
      />
    </Layer>
  )
}

function Animated({ strokes }: { strokes: Stroke[] }) {
  const refs = useRef<(SVGPathElement | null)[]>([])
  const [shown, setShown] = useState(0) // số nét đã bắt đầu vẽ → hiện số thứ tự

  useEffect(() => {
    const anims: Animation[] = []
    const timers: ReturnType<typeof setTimeout>[] = []
    refs.current.forEach((el, i) => {
      if (!el) return
      const len = el.getTotalLength()
      el.style.strokeDasharray = `${len}`
      el.style.strokeDashoffset = `${len}`
      const delay = i * (STROKE_MS + GAP_MS)
      anims.push(
        el.animate([{ strokeDashoffset: len }, { strokeDashoffset: 0 }], {
          duration: STROKE_MS,
          delay,
          fill: 'forwards',
          easing: 'ease-in-out',
        }),
      )
      timers.push(setTimeout(() => setShown(i + 1), delay))
    })
    return () => {
      anims.forEach((a) => a.cancel())
      timers.forEach(clearTimeout)
    }
  }, [strokes])

  return (
    <Layer>
      {strokes.map((s, i) => (
        <path key={`bg${i}`} d={s.d} stroke="currentColor" strokeOpacity={0.12} strokeWidth={3} />
      ))}
      {strokes.map((s, i) => (
        <path
          key={i}
          ref={(el) => {
            refs.current[i] = el
          }}
          d={s.d}
          stroke="currentColor"
          strokeWidth={3.5}
        />
      ))}
      {strokes.slice(0, shown).map((s, i) =>
        s.num ? (
          <text key={`n${i}`} x={s.num.x} y={s.num.y} fontSize={7} fill="#e0457b" stroke="none">
            {i + 1}
          </text>
        ) : null,
      )}
    </Layer>
  )
}

function Trace({ strokes }: { strokes: Stroke[] }) {
  const canvas = useRef<HTMLCanvasElement>(null)
  const drawing = useRef(false)

  const ctx = () => canvas.current?.getContext('2d') ?? null

  useEffect(() => {
    const c = canvas.current
    const g = c?.getContext('2d')
    if (!c || !g) return
    const dpr = window.devicePixelRatio || 1
    c.width = SIZE * dpr
    c.height = SIZE * dpr
    g.scale(dpr, dpr)
    g.lineWidth = 9
    g.lineCap = 'round'
    g.lineJoin = 'round'
    g.strokeStyle = '#3b82f6'
  }, [])

  const pos = (e: React.PointerEvent<HTMLCanvasElement>) => {
    const r = e.currentTarget.getBoundingClientRect()
    return [e.clientX - r.left, e.clientY - r.top] as const
  }
  const down = (e: React.PointerEvent<HTMLCanvasElement>) => {
    const g = ctx()
    if (!g) return
    drawing.current = true
    e.currentTarget.setPointerCapture(e.pointerId)
    g.beginPath()
    g.moveTo(...pos(e))
  }
  const move = (e: React.PointerEvent<HTMLCanvasElement>) => {
    const g = ctx()
    if (!drawing.current || !g) return
    g.lineTo(...pos(e))
    g.stroke()
  }
  const up = () => {
    drawing.current = false
  }
  const clear = () => {
    const c = canvas.current
    c?.getContext('2d')?.clearRect(0, 0, c.width, c.height)
  }

  return (
    <>
      <Layer>
        {strokes.map((s, i) => (
          <path key={i} d={s.d} stroke="currentColor" strokeOpacity={0.15} strokeWidth={4} />
        ))}
        {strokes.map((s, i) =>
          s.num ? (
            <text
              key={`n${i}`}
              x={s.num.x}
              y={s.num.y}
              fontSize={6}
              fill="currentColor"
              fillOpacity={0.35}
              stroke="none"
            >
              {i + 1}
            </text>
          ) : null,
        )}
      </Layer>
      <canvas
        ref={canvas}
        className="absolute inset-0 touch-none"
        style={{ width: SIZE, height: SIZE }}
        onPointerDown={down}
        onPointerMove={move}
        onPointerUp={up}
        onPointerCancel={up}
        onPointerLeave={up}
      />
      <button
        type="button"
        onClick={clear}
        className="absolute right-2 bottom-2 inline-flex items-center gap-1 rounded-lg border bg-card px-2.5 py-1 text-xs font-medium hover:bg-accent transition-colors"
      >
        <Eraser className="h-3.5 w-3.5" /> Xoá
      </button>
    </>
  )
}
