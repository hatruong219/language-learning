---
title: "Port app Flutter Kotoba sang web (PWA) trong language-learning"
description: "Chép mã Flutter Kotoba vào kotoba/, build web phục vụ ở /kotoba-app/app, mic qua Groq Whisper, lưu trữ IndexedDB, một PR."
status: in-progress
priority: P2
effort: 16h
branch: feat.kotoba-web-app
tags: [flutter-web, pwa, groq, whisper, indexeddb, vercel]
created: 2026-11-27
updated: 2026-11-27
---

# Kotoba web app (PWA) — một PR

Nguồn: `/home/gnourt/my-project/mnn-flashcard` (giữ nguyên, sau này vẫn là bản iOS).
Đích: worktree `../language-learning-kotoba`, branch `feat.kotoba-web-app` tách từ `master`.
KHÔNG đụng `src/components/kanji/KanjiWordBrowser.tsx` đang dở ở worktree chính.

## Luồng dữ liệu tổng (as built)

```
Header "Kotoba" → /kotoba-app (hướng dẫn cài) → nút "Mở app"
  → /kotoba-app/app/index.html (static Flutter build trong public/, ngoài proxy.ts)
     ├─ đọc assets/*.json đóng gói | bản đồng bộ trong IndexedDB (KvStore)
     ├─ Đồng bộ: GET /kotoba-app/api/kotoba/{kanji,kanji-words,grammar}
     │     → route handler src/app/kotoba-app/api/kotoba/[resource]/route.ts → admin (không forward cookie)
     ├─ Mic: record WAV 16k mono → POST /kotoba-app/api/stt (raw bytes)
     │     → route.ts: method/origin/size 800 KB/WAV only/rate 30 req/phút/IP → Groq whisper-large-v3-turbo, ja, không prompt
     │     → bỏ dấu câu → tra ngược kanji→kana → ô "đã nghe" cho sửa → chấm
     └─ TTS: flutter_tts (web = speechSynthesis)
```

## Phases

| # | Phase | Effort | Phụ thuộc | Status |
|---|-------|--------|-----------|--------|
| 01 | [Worktree + chép mã Flutter, baseline xanh](phase-01-worktree-and-import-flutter-source.md) | 1.5h | — | done |
| 02 | [Lưu trữ IndexedDB thay dart:io/path_provider](phase-02-storage-indexeddb-kv-store.md) | 3h | 01 | done |
| 03 | [Route Next `/kotoba-app/api/stt` → Groq Whisper](phase-03-stt-api-route-groq-whisper.md) | 1.5h | 01 | done (hardened) |
| 04 | [Mic trên web: ghi âm + gửi STT](phase-04-flutter-mic-recording-and-transcribe.md) | 3h | 02, 03 (contract) | done (iPhone chưa test) |
| 05 | [Thích nghi web: sync same-origin, font, PWA](phase-05-web-adaptation-sync-tts-fonts-pwa.md) | 3h | 04 (cùng pubspec) | done |
| 06 | [Tích hợp Next: trang hướng dẫn, nav, route, build Vercel](phase-06-next-integration-guide-page-and-vercel-build.md) | 2h | 01 | done |
| 07 | [Kiểm thử tổng + tài liệu](phase-07-verification-and-docs.md) | 2h | 02–06 | in-progress |

Tiến độ: 6/7 phase done. Phase 07 còn: docs (doc-writer đang làm), smoke 3/6 luồng, `pnpm lint` 0 error, E2E iPhone/Android (user), git status + lệnh commit/PR chờ user confirm.

Song song được: 02 ‖ 03 ‖ 06. Chuỗi Flutter tuần tự 02 → 04 → 05 (dùng chung `pubspec.yaml`, `settings_*`).

## Quyết định chính

- Lưu trữ: một `KvStore` trên IndexedDB qua `idb_shim` (web). Commit đồng bộ = 1 transaction, bỏ `.tmp/.bak`.
- Mic: package `record` WAV 16 kHz mono. Không gửi đáp án làm `prompt` cho Whisper.
- `KOTOBA_API_BASE` mặc định `/kotoba-app` → `/kotoba-app/api/kotoba/grammar`.
- URL vào app: `/kotoba-app/app/index.html`; `/kotoba-app/app` redirect về đó.
- Sync đi qua route handler thay `next.config` rewrite (đảo quyết định phase 06; không forward cookie).
- Không service worker riêng (Flutter đang bỏ SW mặc định). PWA cài được nhờ manifest. Offline = follow-up.
- Build Flutter chỉ qua `pnpm build:kotoba` + `vercel.json buildCommand`.

## Rủi ro (cập nhật 2026-11-27)

| # | Rủi ro | Trạng thái | Owner / đường xử lý |
|---|--------|-----------|---------------------|
| 1 | Build Vercel lần đầu | MỞ: Docker AL2023 xanh (~292 s), Vercel thật chỉ chạy khi merge master | user, sau merge |
| 2 | `record` trên iOS Safari | MỞ: Chrome OK, iPhone chưa test | user, phase 07 manual |
| 3 | Lạm dụng endpoint STT | GIẢM: size/type/origin + rate limit in-memory; limit theo instance, không toàn cục | — |
| 4 | ITP xoá dữ liệu iOS | GIẢM: trang hướng dẫn + persist + banner; MỞ đến khi test cài PWA | user, phase 07 manual |
| 5 | Export trên iOS không còn share sheet | MỞ: export = tải file, chưa kiểm iPhone | user, phase 07 manual |
| 6 | `pnpm lint` còn 8 lỗi có sẵn (file không đụng) | MỞ: không đạt tiêu chí "0 error" | user quyết waiver hoặc fix ở PR khác |

## Ngoài phạm vi / follow-up

- Gộp tiến độ đa tab (single user, chấp nhận). Test runner cho Next (repo chưa có). Offline SW. Đồng bộ ngược với repo iOS `mnn-flashcard`.

## Câu hỏi còn mở

Xem cuối [phase-07](phase-07-verification-and-docs.md#unresolved-questions).
