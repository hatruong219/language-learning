# Phase 06 — Tích hợp Next: trang hướng dẫn, nav, rewrite, build Vercel

## Context Links
- `next.config.ts` (đang có `redirects()`), `vercel.json` (chỉ deploy `master`), `package.json` (scripts), `src/proxy.ts` (gọi `supabase.auth.getUser()` mọi request không phải static), `src/components/layout/Header.tsx` (`NAV_LINKS` dùng cho cả desktop + Sheet mobile, icon lucide)

## Overview
- Priority: P1 (đụng deploy production) · Status: done · Effort 2h · Phụ thuộc: 01 · Song song với 02–05
- Next phục vụ app tĩnh, proxy API đồng bộ, có trang hướng dẫn cài, và Vercel tự build Flutter khi deploy master.

## Key Insights
- `public/kotoba-app/app/index.html` được serve tĩnh đúng đường dẫn; `/kotoba-app/app/` bị Next redirect bỏ `/` → dùng `/kotoba-app/app/index.html` làm URL chuẩn + redirect `/kotoba-app/app` → đó (không dùng `trailingSlash`/`skipTrailingSlashRedirect` toàn site).
- Rewrite ra ngoài (`https://admin.truongha.com/...`) chạy được trên Vercel; cùng origin → app không cần CORS.
- `proxy.ts` matcher hiện chỉ loại ảnh → mỗi file `.js/.wasm/.json/.ttf` của Flutter sẽ gọi Supabase một lần. Phải loại `kotoba-app/app/` và `kotoba-app/api/`.
- Asset Flutter không có hash trong tên (`main.dart.js`, `flutter_bootstrap.js`) → giữ cache mặc định của Vercel cho `public/` (`max-age=0, must-revalidate` + ETag), KHÔNG thêm header immutable.
- Ảnh build Vercel là Amazon Linux 2023, chạy root; Flutter cần `git`, `curl`, `unzip` (tải dart-sdk). Thiếu thì `dnf install -y unzip` (Vercel cho phép dnf trong build).
- Vercel chỉ deploy `master` → build Flutter trên Vercel chỉ thật sự chạy khi merge. Diễn tập bằng Docker `amazonlinux:2023` trước khi merge.
- Build fail → Vercel giữ bản deploy cũ → site không sập, chỉ không lên bản mới. Chọn fail-fast (không deploy nút "Mở app" trỏ vào 404).

## Requirements
- `/kotoba-app` (Server Component, `metadata` title "Kotoba — app học từ vựng"): giới thiệu ngắn; nút "Mở app" = `<a href="/kotoba-app/app/index.html">` (không dùng `next/link`: không phải route Next); hướng dẫn iOS (Safari hoặc trình duyệt bất kỳ → nút Chia sẻ → "Thêm vào MH chính"), Android (Chrome ⋮ → "Cài đặt ứng dụng"/"Thêm vào màn hình chính"); lưu ý: dữ liệu học lưu trong máy, nên cài ra màn hình chính (iOS có thể xoá dữ liệu trang web không mở 7 ngày) và xuất sao lưu ở Cài đặt; mic cần cho phép quyền, cần mạng.
- Header: `{ href: '/kotoba-app', label: 'Kotoba', icon: Smartphone }`.
- `next.config.ts`: thêm redirect `/kotoba-app/app` → `/kotoba-app/app/index.html` (`permanent: false`) + `rewrites()`: `/kotoba-app/api/kotoba/:path*` → `https://admin.truongha.com/api/kotoba/:path*`.
- `src/proxy.ts` matcher: thêm `kotoba-app/app/|kotoba-app/api/` vào negative lookahead.
- `scripts/build-kotoba-web.sh` (`set -euo pipefail`):
  1. Tìm Flutter: `$FLUTTER_BIN` → `flutter` trên PATH → `$HOME/sdk/flutter/bin/flutter` → không có thì `git clone --depth 1 --branch 3.32.0 https://github.com/flutter/flutter.git .flutter-sdk`. Kiểm đúng version 3.32.0 (in cảnh báo nếu khác).
  2. Thiếu `unzip` và có `dnf` → `dnf install -y unzip`.
  3. `flutter config --no-analytics`; `cd kotoba && flutter pub get && flutter build web --release --base-href /kotoba-app/app/ --no-web-resources-cdn`.
  4. `rm -rf public/kotoba-app/app && mkdir -p public/kotoba-app && cp -r kotoba/build/web public/kotoba-app/app`.
- `package.json`: `"build:kotoba": "bash scripts/build-kotoba-web.sh"`. `dev`/`build` không đổi.
- `vercel.json`: thêm `"buildCommand": "pnpm build:kotoba && pnpm build"`, giữ khối `git.deploymentEnabled`.

## Related Code Files
- Tạo: `src/app/kotoba-app/page.tsx`, `scripts/build-kotoba-web.sh`
- Sửa: `next.config.ts`, `src/proxy.ts`, `src/components/layout/Header.tsx`, `package.json`, `vercel.json`
- File ownership: chỉ các file trên; không đụng `kotoba/**`, không đụng `src/app/kotoba-app/api/**` (phase 03).

## Implementation Steps
1. Header + trang `/kotoba-app` (< 200 dòng; tách `src/components/kotoba/KotobaInstallGuide.tsx` nếu dài).
2. next.config redirect + rewrite; `curl -i localhost:3000/kotoba-app/api/kotoba/grammar` → 200 JSON.
3. proxy matcher; kiểm bằng log tạm hoặc đếm request Supabase khi tải app (không còn gọi `getUser` cho asset).
4. Script build; chạy local `pnpm build:kotoba && pnpm build && pnpm start` → `/kotoba-app/app` redirect → app chạy.
5. Diễn tập Vercel: `docker run --rm -v "$PWD":/src -w /src amazonlinux:2023 bash -c 'dnf install -y git tar gzip xz which findutils && bash scripts/build-kotoba-web.sh'` → đo thời gian (mục tiêu < 6 phút).
6. `pnpm lint && pnpm build`.

## Todo List
- [x] Header + trang hướng dẫn (có ghi chú sao lưu/migration)
- [x] Redirect `/kotoba-app/app` (rewrite đã thay bằng route handler, xem drift)
- [x] proxy matcher
- [x] build script + package.json + vercel.json
- [x] Diễn tập Docker `amazonlinux:2023` (~292 s, mục tiêu < 6 phút; output 27 MB)
- [x] lint/build xanh (file đổi sạch, `pnpm build` OK)

### Delivery notes
- Done.
- Drift: `rewrite` không dùng; đồng bộ đi qua route handler (xem phase 05). Rollback phase này giờ là bỏ route handler, không còn là bỏ rewrite.
- Rủi ro 1 chưa đóng hoàn toàn: Vercel chỉ build thật khi merge master.

## Success Criteria
- `curl -sI /kotoba-app/app` → 307 tới `/kotoba-app/app/index.html`; index 200.
- `/kotoba-app/api/kotoba/{kanji,kanji-words,grammar}` → 200 JSON qua Next.
- Không request asset nào của app đi qua `proxy()`.
- Build Docker AL2023 xanh, có `public/kotoba-app/app/main.dart.js`.

## Risk Assessment
| Rủi ro | Khả năng | Tác động | Đối sách |
|---|---|---|---|
| Build Vercel lỗi lần đầu (thiếu tool, mạng clone) | TB | Cao (chặn mọi deploy site) | Diễn tập Docker; fail-fast giữ bản cũ; rollback = bỏ `buildCommand` trong vercel.json |
| Thời gian build tăng 3–6 phút mỗi deploy | Chắc chắn | Thấp | Chấp nhận; cache SDK là follow-up |
| admin.truongha.com đổi/chết → đồng bộ lỗi | Thấp | Thấp | App đã có thông điệp lỗi tiếng Việt, dữ liệu cũ giữ nguyên |
| Matcher regex sai làm trang Next khác mất refresh session | Thấp | TB | Chỉ thêm 2 tiền tố; thử đăng nhập `/writing-test` sau khi sửa |

## Rollback
Từng mảnh độc lập: bỏ `buildCommand` (site build như cũ, nút "Mở app" 404), bỏ rewrite, bỏ nav. Revert PR là sạch hoàn toàn (không migration DB).

## Security Considerations
Rewrite chỉ GET dữ liệu công khai của admin; không chuyển cookie nhạy cảm (Next gửi kèm cookie của domain study → cân nhắc: admin là domain khác nên cookie phiên Supabase của study KHÔNG nên lộ — kiểm header request đi ra; nếu có, đổi sang route handler GET tự fetch không kèm cookie). Không secret trong script; `GROQ_API_KEY` đã có trên Vercel.

## Next Steps
07.
