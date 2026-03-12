/**
 * Tesseract.js-based grading for Japanese handwriting practice.
 * Runs entirely in the browser — no API key, no server call.
 *
 * is_correct = Tesseract recognized the target character (regardless of confidence)
 * score      = confidence if correct, 0 if wrong
 *
 * Language pack (~20MB) is fetched from CDN on first use and cached by the browser.
 */
import type { CharacterGradingResult } from '@/types/database'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let workerPromise: Promise<any> | null = null

async function getWorker() {
  if (typeof window === 'undefined') throw new Error('OCR chỉ chạy trên browser')
  if (!workerPromise) {
    workerPromise = (async () => {
      const mod = await import('tesseract.js')
      const createWorker = mod.createWorker
      // PSM 10 = SINGLE_CHAR (best for isolated kana)
      const w = await createWorker('jpn', 1, { logger: () => {} })
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      await w.setParameters({ tessedit_pageseg_mode: '10' as any })
      return w
    })()
  }
  return workerPromise
}

// ── Preprocess: crop to content, center, scale to 200×200 ──────────────────
function preprocessCanvas(src: HTMLCanvasElement): HTMLCanvasElement {
  const SIZE = 200
  const out = document.createElement('canvas')
  out.width = SIZE
  out.height = SIZE
  const ctx = out.getContext('2d')!
  ctx.fillStyle = '#ffffff'
  ctx.fillRect(0, 0, SIZE, SIZE)

  const srcCtx = src.getContext('2d')!
  const w = src.width, h = src.height
  const { data } = srcCtx.getImageData(0, 0, w, h)

  let minX = w, minY = h, maxX = 0, maxY = 0
  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++) {
      if (data[(y * w + x) * 4] < 128) {
        if (x < minX) minX = x
        if (x > maxX) maxX = x
        if (y < minY) minY = y
        if (y > maxY) maxY = y
      }
    }
  }

  if (maxX < minX || maxY < minY) return out  // blank

  const pad = 20
  const cw = maxX - minX + 1
  const ch = maxY - minY + 1
  const scale = Math.min((SIZE - pad * 2) / cw, (SIZE - pad * 2) / ch)
  const dw = cw * scale, dh = ch * scale
  ctx.drawImage(src, minX, minY, cw, ch, (SIZE - dw) / 2, (SIZE - dh) / 2, dw, dh)
  return out
}

// ── Public grading function ─────────────────────────────────────────────────

export async function gradeCharacterWithOCR(
  targetCharacter: string,
  targetRomanization: string,
  canvasEl: HTMLCanvasElement,
): Promise<CharacterGradingResult> {
  // Empty check
  const { data } = canvasEl.getContext('2d')!.getImageData(0, 0, canvasEl.width, canvasEl.height)
  if (!Array.from(data).some((v, i) => i % 4 === 0 && v < 128)) {
    return {
      is_correct: false, score: 0,
      feedback_vi: 'Chưa vẽ gì cả! Hãy vẽ ký tự vào ô trắng.',
      stroke_notes: [],
    }
  }

  try {
    const worker = await getWorker()
    const preprocessed = preprocessCanvas(canvasEl)
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const { data: ocrData } = await worker.recognize(preprocessed) as any
    const recognized: string = (ocrData.text ?? '').trim().replace(/\s/g, '')
    const confidence: number = Math.round(ocrData.confidence ?? 0)

    // ── Correct = Tesseract found the target character (no confidence threshold) ──
    const isCorrect = recognized.includes(targetCharacter)
    const score = isCorrect ? Math.max(60, confidence) : 0

    return {
      is_correct: isCorrect,
      score,
      feedback_vi: isCorrect
        ? confidence >= 75
          ? `Chính xác! (${confidence}%)`
          : `Đúng rồi, nhưng hãy viết rõ nét hơn. (${confidence}%)`
        : 'Chưa đúng.',
      stroke_notes: [],
    }
  } catch (err) {
    console.error('[OCR]', err)
    return {
      is_correct: false, score: 0,
      feedback_vi: 'Có lỗi khi nhận dạng. Vui lòng thử lại.',
      stroke_notes: [],
    }
  }
}
