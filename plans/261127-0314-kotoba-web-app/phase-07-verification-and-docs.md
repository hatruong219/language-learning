# Phase 07 — Kiểm thử tổng + tài liệu

## Context Links
- Tất cả phase 01–06; `CLAUDE.md`, `README.md` của language-learning

## Overview
- Priority: P1 · Status: in-progress · Effort 2h · Phụ thuộc: 02–06
- Chứng minh "xong" bằng số đo, cập nhật tài liệu, để working tree sẵn cho bước user confirm commit/PR (KHÔNG tự commit).

## Test Matrix
| Mức | Cái gì | Công cụ | Ở đâu |
|---|---|---|---|
| Unit (Dart, VM) | KvStore (memory idb), DataCache đọc/hỏng/commitAll nguyên tử, SttClient map lỗi, SilenceDetector, bỏ dấu câu, cấm dart:io trong lib, toàn bộ test cũ | `flutter test` | phase 02, 04 |
| Static | `flutter analyze` 0 issue; `pnpm lint`; TS strict | CLI | mọi phase |
| Integration (Next) | STT route 200/400/403/405/413/415/429-map; rewrite đồng bộ 200; redirect `/kotoba-app/app` | curl | phase 03, 06 |
| E2E desktop | Mở `/kotoba-app` → Mở app → học thẻ, gắn sao, reload còn sao; Đồng bộ thành công; xuất/nhập tiến độ; chế độ đọc qua mic Chrome; không request gstatic; proxy không chạy cho asset | chrome-devtools MCP trên `pnpm build:kotoba && pnpm build && pnpm start` | phase 07 |
| E2E thiết bị (thủ công, BẮT BUỘC) | iPhone Safari + PWA đã cài: mở từ MH chính không thanh URL, mic xin quyền + nhận diện, TTS đọc, dữ liệu còn sau khi tắt mở; Android Chrome: cài app, mic | User tự thử trên production sau merge (hoặc tunnel HTTPS trước merge) | sau 07 |
| Build | Docker AL2023 chạy `scripts/build-kotoba-web.sh` | docker | phase 06 |

## Requirements — tài liệu
- `CLAUDE.md`: thêm dòng bảng route `/kotoba-app` (hướng dẫn cài), `/kotoba-app/app/index.html` (Flutter PWA tĩnh), `/kotoba-app/api/stt` (Groq Whisper), `/kotoba-app/api/kotoba/*` (rewrite admin); mục "Kotoba (Flutter web)": nguồn ở `kotoba/`, build `pnpm build:kotoba` (cần Flutter 3.32.0, tự clone nếu thiếu), output `public/kotoba-app/app` gitignored, Vercel buildCommand; `GROQ_API_KEY` giờ dùng thêm cho STT (`whisper-large-v3-turbo`).
- `README.md`: thêm dòng Features + Routes + một đoạn "Kotoba app" (build lệnh).
- `kotoba/README.md` (ngắn): gốc từ repo `mnn-flashcard` (bản iOS vẫn ở đó, hai bên có thể lệch — sửa logic chung thì nhớ bên kia), khác biệt bản web (IndexedDB, mic qua Groq, không ngoại tuyến), cách chạy `flutter test`, `flutter run -d chrome --web-port 8080` (đồng bộ/mic cần `pnpm dev` + `--dart-define=KOTOBA_API_BASE=http://localhost:3000/kotoba-app`), cách sinh lại font/icon.

## Implementation Steps
1. Chạy đủ matrix tự động; sửa tới khi xanh (không bỏ qua test hỏng).
2. Smoke E2E bằng chrome-devtools; chụp Network để chứng minh 0 request gstatic, 0 request STT khi im lặng.
3. Viết tài liệu.
4. `git status` trong worktree: liệt kê file, đối chiếu không có `public/kotoba-app/app`, `kotoba/build`, `.flutter-sdk`, `.env*`. Soạn sẵn lệnh commit/push/PR (tiếng Anh, conventional commit, VD `feat: add Kotoba Flutter web app at /kotoba-app`) cho user confirm — KHÔNG chạy.

## Todo List
- [ ] Matrix tự động: `flutter test` 528 pass, analyze clean, tsc/eslint file đổi clean, Next build OK. CHƯA đạt: `pnpm lint` 0 error (8 lỗi có sẵn)
- [ ] Smoke E2E: đã có 3/6 luồng (render, progress còn sau reload, sync OK) bằng Puppeteer. Thiếu: mic, xuất/nhập, im lặng không gửi STT, proxy không chạy cho asset. Công cụ là Puppeteer thay chrome-devtools (lý do chưa ghi nhận)
- [ ] CLAUDE.md, README.md, kotoba/README.md (doc-writer đang viết)
- [ ] E2E thiết bị thủ công (BẮT BUỘC sau deploy): iPhone Safari + PWA (mic, TTS, cài ra màn hình chính, dữ liệu còn sau khi tắt mở, xuất file). Android Chrome (cài, mic). Owner: user
- [ ] Kiểm `git status` + soạn lệnh commit/PR chờ user confirm (chưa làm, chưa commit)

### Delivery notes
- In-progress. Chưa commit, chưa push, chưa tạo PR.
- Không có tiêu chí nào trong phase này được coi là đạt cho tới khi có bằng chứng (lệnh + kết quả).

## Success Criteria (đo được)
- `flutter analyze` 0 issue; `flutter test` 100% pass, số test ≥ baseline phase 01.
- `pnpm lint` 0 error; `pnpm build` thành công.
- Smoke: 6 luồng E2E desktop pass; tải lần đầu app (đã tự host) liệt kê tổng KB trong báo cáo.
- iPhone: checklist thủ công điền đủ sau deploy.

## Risk Assessment
| Rủi ro | Khả năng | Tác động | Đối sách |
|---|---|---|---|
| Mic iPhone chỉ kiểm được sau merge | Cao | Cao | Tunnel HTTPS (cloudflared) tới máy dev trước merge; nếu hỏng sau merge thì chế độ gõ vẫn dùng được, sửa ở PR sau |
| Chrome-devtools không cấp mic giả | TB | Thấp | Dùng flag `--use-fake-ui-for-media-stream --use-file-for-fake-audio-capture=sample.wav` |

## Rollback
Revert PR (không có migration, không dữ liệu server). Tắt riêng: xoá `buildCommand` + nav link.

## Security Considerations
Kiểm lại: không key trong `kotoba/` (dart-define không chứa secret), `.gitignore` chặn build output.

## Unresolved Questions

Cập nhật 2026-11-27: Q1 đã đóng (Docker dùng). Q2 đã đóng (route handler, không forward cookie). Q3 đảo (rate limit in-memory đã làm). Q4, Q5 giữ nguyên. Thêm mới:
- N1: `pnpm lint` còn 8 lỗi có sẵn. Waiver hay fix? (owner: user)
- N2: Bằng chứng mic Chrome "せんせい" và smoke 3 luồng còn lại chưa có. Làm bằng chrome-devtools/Puppeteer? (owner: Claude, khi user cho lệnh)
- N3: Tên model `whisper-large-v3-turbo` đã đối chiếu docs Groq chưa? (owner: Claude, ghi link docs vào phase 03)
1. Có Docker trên máy để diễn tập build AL2023 không? Nếu không: tạm bật deploy preview cho branch `feat.kotoba-web-app` trong Vercel (thao tác cloud → cần user cho phép trong lượt). Mặc định đề xuất: Docker.
2. External rewrite gửi kèm cookie phiên study.truongha.com sang admin.truongha.com (cùng chủ nên rủi ro thấp). Mặc định: chấp nhận; nếu muốn chặt thì thay rewrite bằng route handler GET không kèm cookie (+30').
3. Rate-limit theo IP cho `/kotoba-app/api/stt`: mặc định KHÔNG làm (Groq free tự chặn 429); thêm nếu thấy lạm dụng.
4. Offline (service worker tự viết): ngoài phạm vi PR này; mở issue follow-up nếu cần dùng khi mất mạng.
5. Đồng bộ ngược logic với repo iOS `mnn-flashcard` về lâu dài (hai bản sẽ lệch): ngoài phạm vi; ghi chú trong `kotoba/README.md`.
