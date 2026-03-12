'use client'

import { useRef, useEffect, useImperativeHandle, forwardRef, useState, useCallback } from 'react'
import { Button } from '@/components/ui/button'
import { Undo2, Trash2 } from 'lucide-react'

export interface DrawingCanvasRef {
  getImageBase64: () => string
  getCanvasElement: () => HTMLCanvasElement | null
  isEmpty: () => boolean
  clear: () => void
}

interface Props {
  width?: number
  height?: number
  lineWidth?: number
  strokeColor?: string
  onCanvasReady?: (el: HTMLCanvasElement) => void
}

type Point = { x: number; y: number }

export const DrawingCanvas = forwardRef<DrawingCanvasRef, Props>(function DrawingCanvas(
  { width = 320, height = 280, lineWidth = 6, strokeColor = '#1a1a1a', onCanvasReady },
  ref,
) {
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const drawing = useRef(false)
  // Completed strokes: array of point-arrays
  const completedStrokes = useRef<Point[][]>([])
  // Current in-progress stroke
  const currentStroke = useRef<Point[]>([])
  const [hasStrokes, setHasStrokes] = useState(false)

  // ── Draw guide lines on a fresh canvas ──────────────────────────────────
  const drawGuide = useCallback((ctx: CanvasRenderingContext2D, w: number, h: number) => {
    ctx.save()
    ctx.strokeStyle = '#e5e7eb'
    ctx.lineWidth = 1
    ctx.setLineDash([4, 4])
    ctx.beginPath()
    ctx.moveTo(w / 2, 0); ctx.lineTo(w / 2, h)
    ctx.moveTo(0, h / 2); ctx.lineTo(w, h / 2)
    ctx.stroke()
    ctx.setLineDash([])
    ctx.restore()
  }, [])

  // ── Full redraw from stored strokes ──────────────────────────────────────
  const redraw = useCallback(() => {
    const canvas = canvasRef.current
    if (!canvas) return
    const ctx = canvas.getContext('2d')
    if (!ctx) return

    ctx.clearRect(0, 0, canvas.width, canvas.height)
    ctx.fillStyle = '#ffffff'
    ctx.fillRect(0, 0, canvas.width, canvas.height)
    drawGuide(ctx, canvas.width, canvas.height)

    ctx.strokeStyle = strokeColor
    ctx.lineWidth = lineWidth
    ctx.lineCap = 'round'
    ctx.lineJoin = 'round'

    for (const stroke of completedStrokes.current) {
      if (stroke.length < 2) continue
      ctx.beginPath()
      ctx.moveTo(stroke[0].x, stroke[0].y)
      for (let i = 1; i < stroke.length; i++) ctx.lineTo(stroke[i].x, stroke[i].y)
      ctx.stroke()
    }
  }, [lineWidth, strokeColor, drawGuide])

  // Initial draw + notify parent of canvas element
  useEffect(() => {
    redraw()
    if (canvasRef.current && onCanvasReady) onCanvasReady(canvasRef.current)
  }, [redraw, onCanvasReady])

  // ── Get canvas-relative position from mouse/touch ────────────────────────
  function getPos(e: MouseEvent | Touch, canvas: HTMLCanvasElement): Point {
    const rect = canvas.getBoundingClientRect()
    return {
      x: (e.clientX - rect.left) * (canvas.width / rect.width),
      y: (e.clientY - rect.top) * (canvas.height / rect.height),
    }
  }

  // ── Draw a single new segment (for live preview) ─────────────────────────
  function drawSegment(ctx: CanvasRenderingContext2D, from: Point, to: Point) {
    ctx.strokeStyle = strokeColor
    ctx.lineWidth = lineWidth
    ctx.lineCap = 'round'
    ctx.lineJoin = 'round'
    ctx.beginPath()
    ctx.moveTo(from.x, from.y)
    ctx.lineTo(to.x, to.y)
    ctx.stroke()
  }

  // ── Event handlers ───────────────────────────────────────────────────────
  useEffect(() => {
    const canvas = canvasRef.current
    if (!canvas) return

    const onStart = (pt: Point) => {
      drawing.current = true
      currentStroke.current = [pt]
    }

    const onMove = (pt: Point) => {
      if (!drawing.current) return
      const prev = currentStroke.current[currentStroke.current.length - 1]
      currentStroke.current.push(pt)
      const ctx = canvas.getContext('2d')
      if (ctx && prev) drawSegment(ctx, prev, pt)
    }

    const onEnd = () => {
      if (!drawing.current) return
      drawing.current = false
      if (currentStroke.current.length >= 2) {
        // Save completed stroke (copy the array)
        completedStrokes.current = [...completedStrokes.current, [...currentStroke.current]]
        setHasStrokes(true)
      }
      currentStroke.current = []
    }

    // Mouse
    const onMouseDown = (e: MouseEvent) => { e.preventDefault(); onStart(getPos(e, canvas)) }
    const onMouseMove = (e: MouseEvent) => { onMove(getPos(e, canvas)) }
    const onMouseUp = () => { onEnd() }

    // Touch
    const onTouchStart = (e: TouchEvent) => { e.preventDefault(); onStart(getPos(e.touches[0], canvas)) }
    const onTouchMove = (e: TouchEvent) => { e.preventDefault(); onMove(getPos(e.touches[0], canvas)) }
    const onTouchEnd = () => { onEnd() }

    canvas.addEventListener('mousedown', onMouseDown)
    canvas.addEventListener('mousemove', onMouseMove)
    canvas.addEventListener('mouseup', onMouseUp)
    canvas.addEventListener('mouseleave', onMouseUp)
    canvas.addEventListener('touchstart', onTouchStart, { passive: false })
    canvas.addEventListener('touchmove', onTouchMove, { passive: false })
    canvas.addEventListener('touchend', onTouchEnd)

    return () => {
      canvas.removeEventListener('mousedown', onMouseDown)
      canvas.removeEventListener('mousemove', onMouseMove)
      canvas.removeEventListener('mouseup', onMouseUp)
      canvas.removeEventListener('mouseleave', onMouseUp)
      canvas.removeEventListener('touchstart', onTouchStart)
      canvas.removeEventListener('touchmove', onTouchMove)
      canvas.removeEventListener('touchend', onTouchEnd)
    }
  }, [lineWidth, strokeColor]) // eslint-disable-line react-hooks/exhaustive-deps

  // ── Imperative API ───────────────────────────────────────────────────────
  useImperativeHandle(ref, () => ({
    getImageBase64: () => canvasRef.current?.toDataURL('image/png').replace(/^data:image\/png;base64,/, '') ?? '',
    getCanvasElement: () => canvasRef.current,
    isEmpty: () => completedStrokes.current.length === 0,
    clear: () => {
      completedStrokes.current = []
      currentStroke.current = []
      setHasStrokes(false)
      redraw()
    },
  }))

  const handleUndo = () => {
    completedStrokes.current = completedStrokes.current.slice(0, -1)
    setHasStrokes(completedStrokes.current.length > 0)
    redraw()
  }

  const handleClear = () => {
    completedStrokes.current = []
    currentStroke.current = []
    setHasStrokes(false)
    redraw()
  }

  return (
    <div className="flex flex-col items-center gap-3">
      <canvas
        ref={canvasRef}
        width={width}
        height={height}
        className="rounded-2xl border-2 border-border bg-white cursor-crosshair shadow-inner touch-none w-full"
        style={{ maxWidth: width }}
      />
      <div className="flex gap-2">
        <Button variant="outline" size="sm" onClick={handleUndo} disabled={!hasStrokes} className="gap-1.5">
          <Undo2 className="h-3.5 w-3.5" /> Hoàn tác
        </Button>
        <Button variant="outline" size="sm" onClick={handleClear} disabled={!hasStrokes} className="gap-1.5">
          <Trash2 className="h-3.5 w-3.5" /> Xóa
        </Button>
      </div>
    </div>
  )
})
