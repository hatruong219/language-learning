# Phase 03 — Route Next `/kotoba-app/api/stt` → Groq Whisper

## Context Links
- Mẫu route: `src/app/api/writing-submissions/grade/route.ts` (try/catch, `NextResponse.json({error})`)
- Groq hiện có: `src/lib/groq.ts` (chat completions, `GROQ_API_KEY`)
- Groq STT: `POST https://api.groq.com/openai/v1/audio/transcriptions` (multipart: `file`, `model`, `language`, `response_format`, `temperature`)

## Overview
- Priority: P1 · Status: done (hardened) · Effort 1.5h · Phụ thuộc: 01 · Song song với 02, 06
- Endpoint không cần đăng nhập, nhận bytes âm thanh thô, trả `{ text }` hoặc `{ error }` tiếng Việt.

## Key Insights
- Model: `whisper-large-v3-turbo` (rẻ/nhanh, hỗ trợ `ja`). Kiểm lại tên ở https://console.groq.com/docs/speech-to-text lúc làm; fallback `whisper-large-v3`.
- KHÔNG truyền đáp án làm `prompt` — Whisper sẽ "nghe ra" đúng đáp án → chấm vô nghĩa. Không gửi prompt (hoặc tối đa một câu trung tính cố định).
- Hợp đồng đơn giản: body = raw audio, `Content-Type` = mime → client Dart khỏi dựng multipart.
- Vercel function body tối đa 4.5 MB; giới hạn 1 MB của mình nằm dưới mức đó. WAV 16 kHz mono 16-bit = 32 KB/s → 8 s ≈ 256 KB.
- Next 16 route chỉ export `POST` → method khác tự trả 405.

## Requirements
- Chặn: `content-length` > 1 MB → 413 (kiểm cả sau `arrayBuffer()` vì có thể chunked); body rỗng/< 1 KB → 400; type ngoài allowlist `audio/wav, audio/x-wav, audio/webm, audio/mp4, audio/mpeg, audio/ogg` (bỏ `;codecs=`) → 415; `Sec-Fetch-Site` có mặt mà khác `same-origin` → 403 (chặn web khác lợi dụng quota, không chặn client không gửi header).
- Thiếu `GROQ_API_KEY` → 500 "Chưa cấu hình nhận diện giọng nói."
- Groq 429 → 429 "Đang quá tải, thử lại sau ít phút."; lỗi khác/timeout 15 s → 502 "Không nhận diện được, thử lại."
- Thành công → `{ text: string }` (đã `trim()`); không log nội dung âm thanh.

## Architecture
```
Flutter → POST /kotoba-app/api/stt (audio/wav bytes)
  route.ts: method → origin → size → type → arrayBuffer → size lần 2
         → transcribeJapanese(bytes, mime)  [src/lib/groqTranscribe.ts]
             FormData{file: Blob(name 'audio.<ext>'), model, language:'ja', response_format:'json', temperature:'0'}
             fetch + AbortSignal.timeout(15000)
         → 200 {text} | 4xx/5xx {error}
```

## Related Code Files
- Tạo: `src/app/kotoba-app/api/stt/route.ts`, `src/lib/groqTranscribe.ts` (camelCase theo quy ước utils)
- File ownership: chỉ 2 file trên. KHÔNG sửa `src/proxy.ts` (phase 06 lo matcher).

## Implementation Steps
1. `groqTranscribe.ts`: hằng `GROQ_STT_URL`, `STT_MODEL`; hàm `transcribeJapanese(bytes: ArrayBuffer, mime: string): Promise<string>`; ném `SttError` có `status` + `message` tiếng Việt.
2. `route.ts`: hằng `MAX_BYTES = 1_000_000`, `ALLOWED_TYPES`; thứ tự kiểm như Architecture; `export const runtime = 'nodejs'` nếu cần `FormData/Blob` (Node 20 có sẵn).
3. Thử tay: `curl -X POST --data-binary @sample.wav -H 'Content-Type: audio/wav' localhost:3000/kotoba-app/api/stt` (file mẫu ghi bằng `arecord`/ffmpeg đọc "せんせい"); thử 413/415/405.
4. `pnpm lint` + `pnpm build`.

## Todo List
- [x] Xác minh tên model trên docs Groq (`whisper-large-v3-turbo`; bằng chứng chưa ghi trong báo cáo, xem unresolved ở plan)
- [x] groqTranscribe.ts
- [x] route.ts + các chặn
- [x] curl 200/400/405/413/415 (curl matrix OK)
- [x] lint/build xanh (file đổi sạch, `pnpm build` OK)

### Delivery notes
- Done, hardened. Không gửi prompt lên Whisper (đúng plan).
- Drift 1: chỉ nhận WAV (`audio/wav`, `audio/x-wav`) thay allowlist 6 mime. Lý do: phase 04 chỉ gửi WAV. Chi phí: client khác không gửi được webm/mp4.
- Drift 2: giới hạn 800 KB (plan 1 MB). Lý do: 8 s WAV ≈ 256 KB, dư đủ.
- Drift 3: same-origin = `Sec-Fetch-Site` hoặc `Origin == Host` (plan chỉ dùng Sec-Fetch-Site).
- Drift 4: rate limit in-memory 30 req/phút/IP (`src/lib/sttGuards.ts`), đảo Q3 của plan (plan để follow-up). Chi phí: state theo từng instance serverless, không chặn toàn cục.

## Success Criteria
- curl file WAV tiếng Nhật trả `{text}` hợp lý; mỗi nhánh lỗi trả đúng mã + câu tiếng Việt.
- Không chuỗi secret nào trong mã; key chỉ đọc `process.env.GROQ_API_KEY`.

## Risk Assessment
| Rủi ro | Khả năng | Tác động | Đối sách |
|---|---|---|---|
| Lạm dụng endpoint ẩn danh đốt quota | TB | TB | Cap size, allowlist type, `Sec-Fetch-Site`; tài khoản Groq free tự trả 429 thay vì tính tiền. Rate-limit theo IP = follow-up nếu thấy lạm dụng |
| Whisper ảo giác khi im lặng ("ご視聴ありがとうございました") | Cao | TB | Client không gửi khi chưa nghe thấy tiếng (phase 04); người dùng luôn sửa được trước khi chấm |
| Tên model đổi/deprecate | Thấp | TB | Hằng một chỗ, fallback `whisper-large-v3` |

## Rollback
Xoá 2 file; không ảnh hưởng route khác.

## Security Considerations
Không đăng nhập theo quyết định user; không lưu âm thanh; không trả lỗi gốc của Groq cho client (chỉ log server, không log body).

## Next Steps
Hợp đồng `{POST raw audio → {text}|{error}}` giao cho phase 04.
