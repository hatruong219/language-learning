'use client'

import { useRef, useEffect, useImperativeHandle, forwardRef, useState } from 'react'

export interface DrawingCanvasHandle {
  clear: () => void
  getCanvas: () => HTMLCanvasElement | null
  isEmpty: () => boolean
}

export const DrawingCanvas = forwardRef<DrawingCanvasHandle, { size?: number; onDraw?: () => void }>(
  ({ size = 280, onDraw }, ref) => {
    const canvasRef = useRef<HTMLCanvasElement>(null)
    const isDrawingRef = useRef(false)
    const lastPosRef = useRef({ x: 0, y: 0 })
    const [empty, setEmpty] = useState(true)

    useEffect(() => {
      const canvas = canvasRef.current
      if (!canvas) return
      const ctx = canvas.getContext('2d')!
      ctx.fillStyle = '#ffffff'
      ctx.fillRect(0, 0, canvas.width, canvas.height)
      ctx.strokeStyle = '#1a1a1a'
      ctx.lineWidth = 8
      ctx.lineCap = 'round'
      ctx.lineJoin = 'round'
    }, [])

    useEffect(() => {
      const canvas = canvasRef.current
      if (!canvas) return
      const ctx = canvas.getContext('2d')!

      function getPos(e: MouseEvent | TouchEvent) {
        const rect = canvas!.getBoundingClientRect()
        const scaleX = canvas!.width / rect.width
        const scaleY = canvas!.height / rect.height
        if ('touches' in e) {
          return {
            x: (e.touches[0].clientX - rect.left) * scaleX,
            y: (e.touches[0].clientY - rect.top) * scaleY,
          }
        }
        return {
          x: ((e as MouseEvent).clientX - rect.left) * scaleX,
          y: ((e as MouseEvent).clientY - rect.top) * scaleY,
        }
      }

      function onStart(e: MouseEvent | TouchEvent) {
        e.preventDefault()
        isDrawingRef.current = true
        lastPosRef.current = getPos(e)
        setEmpty(false)
        onDraw?.()
      }

      function onMove(e: MouseEvent | TouchEvent) {
        e.preventDefault()
        if (!isDrawingRef.current) return
        const pos = getPos(e)
        ctx.beginPath()
        ctx.moveTo(lastPosRef.current.x, lastPosRef.current.y)
        ctx.lineTo(pos.x, pos.y)
        ctx.stroke()
        lastPosRef.current = pos
      }

      function onEnd() { isDrawingRef.current = false }

      canvas.addEventListener('mousedown', onStart)
      canvas.addEventListener('mousemove', onMove)
      canvas.addEventListener('mouseup', onEnd)
      canvas.addEventListener('mouseleave', onEnd)
      canvas.addEventListener('touchstart', onStart, { passive: false })
      canvas.addEventListener('touchmove', onMove, { passive: false })
      canvas.addEventListener('touchend', onEnd)

      return () => {
        canvas.removeEventListener('mousedown', onStart)
        canvas.removeEventListener('mousemove', onMove)
        canvas.removeEventListener('mouseup', onEnd)
        canvas.removeEventListener('mouseleave', onEnd)
        canvas.removeEventListener('touchstart', onStart)
        canvas.removeEventListener('touchmove', onMove)
        canvas.removeEventListener('touchend', onEnd)
      }
    }, [])

    useImperativeHandle(ref, () => ({
      clear() {
        const canvas = canvasRef.current
        if (!canvas) return
        const ctx = canvas.getContext('2d')!
        ctx.fillStyle = '#ffffff'
        ctx.fillRect(0, 0, canvas.width, canvas.height)
        setEmpty(true)
      },
      getCanvas: () => canvasRef.current,
      isEmpty: () => empty,
    }))

    return (
      <canvas
        ref={canvasRef}
        width={size}
        height={size}
        className="border-2 border-border rounded-2xl cursor-crosshair touch-none bg-white shadow-inner"
        style={{ width: size, height: size }}
      />
    )
  },
)
DrawingCanvas.displayName = 'DrawingCanvas'
